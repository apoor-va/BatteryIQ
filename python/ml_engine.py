"""
BatteryIQ - Remaining Useful Life (RUL) Machine Learning Engine
Trains, compares, evaluates, and registers cycle-based battery RUL prediction models.
Enforces:
  1. Strict cell-level train/test separation (No row-level leakage).
  2. Defined End-of-Life (EOL) capacity threshold (e.g. 70.0% nominal).
  3. Evaluation metrics: MAE, RMSE, R² on unseen holdout test cells.
  4. Comparison of multiple candidate algorithms.
  5. Serialized model registry & configuration storage in JSON.
"""

import os
import json
import math
from typing import Dict, Any, List, Tuple, Optional
import numpy as np

from dataset_loader import load_cell_dataset, DATASET_METADATA


MODELS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "models")
REGISTRY_FILE = os.path.join(MODELS_DIR, "rul_model_registry.json")


def compute_metrics(y_true: np.ndarray, y_pred: np.ndarray) -> Dict[str, float]:
    """Compute MAE, RMSE, and R2 regression metrics."""
    errors = y_true - y_pred
    mae = float(np.mean(np.abs(errors)))
    rmse = float(np.sqrt(np.mean(errors ** 2)))
    
    ss_tot = float(np.sum((y_true - np.mean(y_true)) ** 2))
    ss_res = float(np.sum(errors ** 2))
    r2 = float(1.0 - (ss_res / ss_tot)) if ss_tot > 0 else 0.0
    
    return {
        "mae": round(mae, 2),
        "rmse": round(rmse, 2),
        "r2_score": round(max(-2.0, min(1.0, r2)), 4)
    }


class LinearDegradationModel:
    """Baseline Simple Linear Regression Model."""
    def __init__(self):
        self.slope = 0.0
        self.intercept = 0.0
        self.name = "Linear Regression (OLS Baseline)"

    def fit(self, X: np.ndarray, y: np.ndarray):
        # X: (N, 1) cycle index, y: (N,) RUL
        x_flat = X[:, 0]
        x_mean = np.mean(x_flat)
        y_mean = np.mean(y)
        var_x = np.sum((x_flat - x_mean) ** 2)
        if var_x == 0:
            self.slope = -1.0
            self.intercept = y_mean
        else:
            self.slope = float(np.sum((x_flat - x_mean) * (y - y_mean)) / var_x)
            self.intercept = float(y_mean - self.slope * x_mean)

    def predict(self, X: np.ndarray) -> np.ndarray:
        x_flat = X[:, 0]
        preds = self.intercept + self.slope * x_flat
        return np.maximum(0.0, preds)


class PolynomialDegradationModel:
    """Polynomial Degree-2 Regression Model to capture non-linear degradation knee."""
    def __init__(self):
        self.coeffs = []
        self.name = "Polynomial Regression (Degree-2 Knee Fit)"

    def fit(self, X: np.ndarray, y: np.ndarray):
        x_flat = X[:, 0]
        poly = np.polyfit(x_flat, y, 2)
        self.coeffs = [float(c) for c in poly]

    def predict(self, X: np.ndarray) -> np.ndarray:
        x_flat = X[:, 0]
        a, b, c = self.coeffs
        preds = a * (x_flat ** 2) + b * x_flat + c
        return np.maximum(0.0, preds)


class MultiFeatureRidgeModel:
    """Multi-Feature Regularized Ridge Regression Model."""
    def __init__(self, alpha: float = 1.0):
        self.alpha = alpha
        self.weights = None
        self.intercept = 0.0
        self.means = None
        self.stds = None
        self.name = "Multi-Feature Ridge Regressor (L2 Regularized)"

    def fit(self, X: np.ndarray, y: np.ndarray):
        # Features: [cycle_index, capacity_ah, capacity_fade_ah, internal_resistance_ohms]
        self.means = np.mean(X, axis=0)
        self.stds = np.std(X, axis=0)
        self.stds[self.stds == 0] = 1.0
        
        X_norm = (X - self.means) / self.stds
        n, d = X_norm.shape
        X_ext = np.column_stack([np.ones(n), X_norm])
        
        # Ridge regularized normal equation: (X^T X + alpha * I)^-1 X^T y
        reg_matrix = self.alpha * np.eye(d + 1)
        reg_matrix[0, 0] = 0.0 # Do not regularize bias
        
        theta = np.linalg.inv(X_ext.T @ X_ext + reg_matrix) @ X_ext.T @ y
        self.intercept = float(theta[0])
        self.weights = [float(w) for w in theta[1:]]

    def predict(self, X: np.ndarray) -> np.ndarray:
        X_norm = (X - self.means) / self.stds
        preds = self.intercept + X_norm @ np.array(self.weights)
        return np.maximum(0.0, preds)


class ExponentialDecayModel:
    """Physical Exponential Decay Inversion Model."""
    def __init__(self):
        self.a = 2.0
        self.b = 0.003
        self.eol_cap = 1.4
        self.name = "Exponential Decay Fade Extrapolator"

    def fit(self, X: np.ndarray, y: np.ndarray, cap_values: np.ndarray, eol_cap: float):
        self.eol_cap = eol_cap
        x_flat = X[:, 0]
        # ln(C) = ln(a) - b * k
        valid_idx = (cap_values > 0)
        x_valid = x_flat[valid_idx]
        ln_cap = np.log(cap_values[valid_idx])
        
        p = np.polyfit(x_valid, ln_cap, 1)
        self.b = float(-p[0])
        self.a = float(np.exp(p[1]))

    def predict(self, X: np.ndarray) -> np.ndarray:
        x_flat = X[:, 0]
        # k_eol = (ln(a) - ln(eol_cap)) / b
        if self.b > 0 and self.a > self.eol_cap:
            k_eol = (np.log(self.a) - np.log(self.eol_cap)) / self.b
            preds = k_eol - x_flat
        else:
            preds = np.zeros_like(x_flat)
        return np.maximum(0.0, preds)


def build_dataset_features(dataset_key: str, cell_ids: List[str]) -> Tuple[np.ndarray, np.ndarray, np.ndarray, float]:
    """
    Extract multi-cell features for strict train or test split.
    Avoids data leakage by aggregating at the cell level.
    """
    all_x = []
    all_y = []
    all_caps = []
    eol_cap_threshold = 1.4

    for cid in cell_ids:
        cell_data = load_cell_dataset(dataset_key, cid)
        eol_cap_threshold = cell_data["eol_capacity_threshold"]
        for c in cell_data["cycles"]:
            if c["capacity_ah"] is not None and c["actual_rul_cycles"] is not None:
                # Features:
                # 0: cycle_index
                # 1: capacity_ah
                # 2: capacity_fade_ah
                # 3: internal_resistance_ohms (or default 0.08)
                r_int = c["internal_resistance_ohms"] if c["internal_resistance_ohms"] is not None else 0.08
                all_x.append([
                    float(c["cycle_index"]),
                    float(c["capacity_ah"]),
                    float(c["capacity_fade_ah"]),
                    float(r_int)
                ])
                all_y.append(float(c["actual_rul_cycles"]))
                all_caps.append(float(c["capacity_ah"]))

    return np.array(all_x), np.array(all_y), np.array(all_caps), eol_cap_threshold


def train_and_compare_models(dataset_key: str = "NASA_PCOE") -> Dict[str, Any]:
    """
    Execute end-to-end model training, comparison on unseen test cells,
    and save the optimal model to the model registry.
    """
    meta = DATASET_METADATA.get(dataset_key.upper())
    if not meta:
        raise ValueError(f"Unknown dataset: {dataset_key}")

    train_cells = [cid for cid, info in meta["cells"].items() if info["split_role"] == "TRAIN"]
    test_cells = [cid for cid, info in meta["cells"].items() if info["split_role"] == "TEST"]

    print(f"=== Training RUL Models for {dataset_key} ===")
    print(f"Train Cells (Cell-Level Split): {train_cells}")
    print(f"Holdout Test Cells (Unseen):   {test_cells}")

    # Build Training and Holdout Test Datasets
    X_train, y_train, caps_train, eol_cap = build_dataset_features(dataset_key, train_cells)
    X_test, y_test, caps_test, _ = build_dataset_features(dataset_key, test_cells)

    if len(X_train) == 0 or len(X_test) == 0:
        raise RuntimeError("Insufficient dataset rows for training and testing.")

    # Candidate Models Comparison
    candidates = [
        LinearDegradationModel(),
        PolynomialDegradationModel(),
        MultiFeatureRidgeModel(alpha=10.0),
        ExponentialDecayModel()
    ]

    model_evaluations = []
    best_model = None
    best_rmse = float("inf")

    for model in candidates:
        # Fit
        if isinstance(model, MultiFeatureRidgeModel):
            model.fit(X_train, y_train)
            pred_train = model.predict(X_train)
            pred_test = model.predict(X_test)
        elif isinstance(model, ExponentialDecayModel):
            model.fit(X_train, y_train, caps_train, eol_cap)
            pred_train = model.predict(X_train)
            pred_test = model.predict(X_test)
        else:
            model.fit(X_train, y_train)
            pred_train = model.predict(X_train)
            pred_test = model.predict(X_test)

        train_metrics = compute_metrics(y_train, pred_train)
        test_metrics = compute_metrics(y_test, pred_test)

        eval_entry = {
            "model_name": model.name,
            "train_mae": train_metrics["mae"],
            "train_rmse": train_metrics["rmse"],
            "train_r2": train_metrics["r2_score"],
            "test_mae": test_metrics["mae"],
            "test_rmse": test_metrics["rmse"],
            "test_r2": test_metrics["r2_score"]
        }
        model_evaluations.append(eval_entry)

        print(f"[{model.name}] Test RMSE: {test_metrics['rmse']} cycles, Test R2: {test_metrics['r2_score']}, Test MAE: {test_metrics['mae']}")

        if test_metrics["rmse"] < best_rmse:
            best_rmse = test_metrics["rmse"]
            best_model = model

    # Generate Actual vs Predicted Curve on Test Cell B0007 / CS2_36
    sample_test_cell = test_cells[0]
    sample_cell_data = load_cell_dataset(dataset_key, sample_test_cell)
    comparison_curve = []

    for c in sample_cell_data["cycles"]:
        if c["capacity_ah"] is not None and c["actual_rul_cycles"] is not None:
            r_int = c["internal_resistance_ohms"] if c["internal_resistance_ohms"] is not None else 0.08
            x_point = np.array([[float(c["cycle_index"]), float(c["capacity_ah"]), float(c["capacity_fade_ah"]), float(r_int)]])
            pred_rul = float(best_model.predict(x_point)[0])
            comparison_curve.append({
                "cycle_index": c["cycle_index"],
                "capacity_ah": c["capacity_ah"],
                "actual_rul_cycles": c["actual_rul_cycles"],
                "predicted_rul_cycles": round(pred_rul, 1),
                "prediction_error_cycles": round(pred_rul - c["actual_rul_cycles"], 1)
            })

    # Prepare serialized Registry payload
    os.makedirs(MODELS_DIR, exist_ok=True)
    registry_data = {
        "dataset_key": dataset_key,
        "selected_model_name": best_model.name,
        "train_cells": ", ".join(train_cells),
        "test_cells": ", ".join(test_cells),
        "total_train_samples": len(X_train),
        "total_test_samples": len(X_test),
        "eol_capacity_threshold": eol_cap,
        "model_comparison": model_evaluations,
        "best_test_metrics": {
            "test_mae": min(e["test_mae"] for e in model_evaluations if e["model_name"] == best_model.name),
            "test_rmse": best_rmse,
            "test_r2": max(e["test_r2"] for e in model_evaluations if e["model_name"] == best_model.name)
        },
        "sample_test_cell_evaluated": sample_test_cell,
        "actual_vs_predicted_trajectory": comparison_curve[:50],  # Sample points for visualization
        "academic_disclosure_notice": meta["academic_disclosure"],
        "known_limitations": [
            "Cell-to-cell variability in electrode mass creates offset in absolute cycle endurance.",
            "Rest interval capacity regeneration bumps temporarily alter linear and polynomial slope.",
            "Bench conditions at 24°C do not account for EV pack thermal gradients or high C-rate fast charging."
        ]
    }

    with open(REGISTRY_FILE, "w", encoding="utf-8") as f:
        json.dump(registry_data, f, indent=2)

    print(f"Model registry saved to: {REGISTRY_FILE}")
    return registry_data


def get_registered_model_info() -> Dict[str, Any]:
    """Retrieve existing trained model registry info or train if missing."""
    if not os.path.isfile(REGISTRY_FILE):
        return train_and_compare_models("NASA_PCOE")
    try:
        with open(REGISTRY_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return train_and_compare_models("NASA_PCOE")

