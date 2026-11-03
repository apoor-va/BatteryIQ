"""
BatteryIQ - Public Battery Dataset Loader & Ingestion Module
Loads, validates, and analyzes public research battery datasets (NASA Ames PCoE, CALCE).
Calculates capacity fade, SOH, degradation percentage, anomalous capacity jumps/drops,
and ground-truth remaining useful life (RUL) relative to End-of-Life (EOL) thresholds.
"""

import os
import json
from typing import Dict, Any, List, Optional, Tuple
import pandas as pd
import numpy as np


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATASETS_DIR = os.path.join(BASE_DIR, "data", "datasets")

# Research Dataset Metadata Specifications
DATASET_METADATA = {
    "NASA_PCOE": {
        "display_name": "NASA Ames Prognostics Center of Excellence (PCoE)",
        "battery_type": "Single 18650 Cylindrical Cell",
        "chemistry_profile_id": "CHEM_NASA_18650",
        "chemistry_name": "LiCoO2 / Graphite (LCO 18650)",
        "nominal_capacity_ah": 2.0,
        "capacity_unit": "AH",
        "default_eol_threshold_pct": 70.0,  # 1.40 Ah EOL
        "test_conditions": "Constant current 2A discharge to 2.7V cutoff, 24°C thermal chamber.",
        "cells": {
            "B0005": {"split_role": "TRAIN", "reference_capacity_ah": 1.8565},
            "B0006": {"split_role": "TRAIN", "reference_capacity_ah": 2.0353},
            "B0007": {"split_role": "TEST",  "reference_capacity_ah": 1.8911},
            "B0018": {"split_role": "TEST",  "reference_capacity_ah": 1.8550}
        },
        "academic_disclosure": (
            "EXPERIMENTAL LABORATORY CELL DATA ONLY. "
            "NASA PCoE benchmark cells were cycled under constant laboratory conditions at 24°C. "
            "These measurements represent single isolated 18650 cells, NOT complete multi-cell electric vehicle battery packs."
        )
    },
    "CALCE": {
        "display_name": "Center for Advanced Life Cycle Engineering (CALCE) - Univ. of Maryland",
        "battery_type": "Prismatic Cell CS2",
        "chemistry_profile_id": "CHEM_NMC_01",
        "chemistry_name": "LiCoO2 / Graphite Prismatic",
        "nominal_capacity_ah": 1.1,
        "capacity_unit": "AH",
        "default_eol_threshold_pct": 70.0,  # 0.77 Ah EOL
        "test_conditions": "0.5C / 1.0C room temperature cycling to 2.7V cutoff.",
        "cells": {
            "CS2_35": {"split_role": "TRAIN", "reference_capacity_ah": 1.0850},
            "CS2_36": {"split_role": "TEST",  "reference_capacity_ah": 1.0920}
        },
        "academic_disclosure": (
            "EXPERIMENTAL LABORATORY PRISMATIC CELL DATA ONLY. "
            "CALCE datasets represent single-cell bench cycling under controlled ambient temperatures. "
            "Results cannot be directly transferred to automotive EV battery packs with active BMS cooling."
        )
    }
}


def list_available_datasets() -> List[Dict[str, Any]]:
    """List all available public research datasets and their cells."""
    summaries = []
    for ds_key, meta in DATASET_METADATA.items():
        cell_summaries = []
        folder_name = "nasa" if ds_key == "NASA_PCOE" else "calce"
        folder_path = os.path.join(DATASETS_DIR, folder_name)
        
        for cell_id, cell_info in meta["cells"].items():
            csv_path = os.path.join(folder_path, f"{cell_id}.csv")
            has_file = os.path.isfile(csv_path)
            total_cycles = 0
            if has_file:
                try:
                    df = pd.read_csv(csv_path)
                    total_cycles = len(df)
                except Exception:
                    total_cycles = 0
                    
            cell_summaries.append({
                "cell_id": cell_id,
                "split_role": cell_info["split_role"],
                "reference_capacity_ah": cell_info["reference_capacity_ah"],
                "total_cycles": total_cycles,
                "data_available": has_file
            })
            
        summaries.append({
            "dataset_id": ds_key,
            "display_name": meta["display_name"],
            "battery_type": meta["battery_type"],
            "chemistry_profile_id": meta["chemistry_profile_id"],
            "chemistry_name": meta["chemistry_name"],
            "nominal_capacity_ah": meta["nominal_capacity_ah"],
            "capacity_unit": meta["capacity_unit"],
            "default_eol_threshold_pct": meta["default_eol_threshold_pct"],
            "test_conditions": meta["test_conditions"],
            "academic_disclosure": meta["academic_disclosure"],
            "cells": cell_summaries
        })
    return summaries


def load_cell_dataset(dataset_key: str, cell_id: str, custom_eol_pct: Optional[float] = None) -> Dict[str, Any]:
    """
    Load and process an individual battery cell dataset.
    Computes capacity fade, SOH, degradation %, anomaly markers, and ground-truth RUL.
    """
    ds_key = dataset_key.upper()
    if ds_key not in DATASET_METADATA:
        raise ValueError(f"Unknown dataset '{dataset_key}'. Supported: {list(DATASET_METADATA.keys())}")
        
    meta = DATASET_METADATA[ds_key]
    if cell_id not in meta["cells"]:
        raise ValueError(f"Cell '{cell_id}' not found in dataset '{dataset_key}'. Supported: {list(meta['cells'].keys())}")
        
    folder_name = "nasa" if ds_key == "NASA_PCOE" else "calce"
    csv_path = os.path.join(DATASETS_DIR, folder_name, f"{cell_id}.csv")
    
    if not os.path.isfile(csv_path):
        raise FileNotFoundError(f"Dataset file not found: {csv_path}")
        
    df = pd.read_csv(csv_path)
    required_cols = ["cycle_index", "capacity_ah"]
    for col in required_cols:
        if col not in df.columns:
            raise ValueError(f"Dataset missing mandatory column: '{col}'")

    cell_meta = meta["cells"][cell_id]
    nom_cap = float(meta["nominal_capacity_ah"])
    ref_cap = float(cell_meta["reference_capacity_ah"])
    eol_pct = float(custom_eol_pct if custom_eol_pct is not None else meta["default_eol_threshold_pct"])
    eol_capacity_threshold = round(nom_cap * (eol_pct / 100.0), 4)

    # 1. Sort by cycle index
    df = df.sort_values(by="cycle_index").reset_index(drop=True)

    # 2. Null safety & anomaly scanning
    processed_cycles = []
    prev_cap = None
    eol_cycle = None

    # First pass: find EOL cycle
    for idx, row in df.iterrows():
        cap = row.get("capacity_ah")
        if pd.notnull(cap) and float(cap) <= eol_capacity_threshold:
            eol_cycle = int(row["cycle_index"])
            break

    # If cell didn't cross EOL, set eol_cycle to max recorded + extrapolate or None
    if eol_cycle is None:
        last_row = df.iloc[-1]
        last_cap = float(last_row["capacity_ah"])
        if last_cap > eol_capacity_threshold:
            # Linear extrapolation for EOL cycle
            avg_fade = (float(df.iloc[0]["capacity_ah"]) - last_cap) / max(1, len(df))
            if avg_fade > 0:
                needed_fade = last_cap - eol_capacity_threshold
                eol_cycle = int(round(len(df) + needed_fade / avg_fade))

    # Second pass: compute metrics for each cycle
    for idx, row in df.iterrows():
        cycle_idx = int(row["cycle_index"])
        cap = float(row["capacity_ah"]) if pd.notnull(row.get("capacity_ah")) else None
        
        if cap is not None:
            # SOH based on clearly documented reference capacity
            soh_pct = round((cap / ref_cap) * 100.0, 2)
            fade_ah = round(ref_cap - cap, 4)
            degrade_pct = round(100.0 - soh_pct, 2)
            
            # Anomaly detection: Capacity regeneration jumps or sudden degradation drops
            has_anomaly = False
            anomaly_desc = None
            if prev_cap is not None:
                delta = cap - prev_cap
                if delta > 0.020:
                    has_anomaly = True
                    anomaly_desc = f"Capacity Regeneration Jump (+{round(delta, 4)} Ah) following rest interval."
                elif delta < -0.035:
                    has_anomaly = True
                    anomaly_desc = f"Abnormal Capacity Drop ({round(delta, 4)} Ah) detected."
            prev_cap = cap
        else:
            soh_pct = None
            fade_ah = None
            degrade_pct = None
            has_anomaly = False
            anomaly_desc = "Capacity reading unavailable."

        # Ground-truth Remaining Useful Life (RUL)
        actual_rul = None
        if eol_cycle is not None:
            actual_rul = max(0, eol_cycle - cycle_idx)

        amb_temp = float(row["ambient_temp_celsius"]) if "ambient_temp_celsius" in row and pd.notnull(row["ambient_temp_celsius"]) else None
        r_int = float(row["internal_resistance_ohms"]) if "internal_resistance_ohms" in row and pd.notnull(row["internal_resistance_ohms"]) else None
        disch_time = float(row["discharge_time_s"]) if "discharge_time_s" in row and pd.notnull(row["discharge_time_s"]) else None

        processed_cycles.append({
            "cycle_index": cycle_idx,
            "capacity_ah": cap,
            "soh_pct": soh_pct,
            "capacity_fade_ah": fade_ah,
            "degradation_pct": degrade_pct,
            "has_anomaly": has_anomaly,
            "anomaly_desc": anomaly_desc,
            "actual_rul_cycles": actual_rul,
            "ambient_temp_celsius": amb_temp,
            "internal_resistance_ohms": r_int,
            "discharge_time_s": disch_time
        })

    # Summary statistics
    initial_measured = processed_cycles[0]["capacity_ah"]
    final_measured = processed_cycles[-1]["capacity_ah"]
    total_cycles_count = len(processed_cycles)
    net_fade = round(initial_measured - final_measured, 4) if (initial_measured and final_measured) else None
    net_soh_drop = round(processed_cycles[0]["soh_pct"] - processed_cycles[-1]["soh_pct"], 2) if (processed_cycles[0]["soh_pct"] and processed_cycles[-1]["soh_pct"]) else None

    return {
        "dataset_key": ds_key,
        "dataset_display_name": meta["display_name"],
        "cell_id": cell_id,
        "split_role": cell_meta["split_role"],
        "chemistry_profile_id": meta["chemistry_profile_id"],
        "chemistry_name": meta["chemistry_name"],
        "nominal_capacity_ah": nom_cap,
        "reference_capacity_ah": ref_cap,
        "capacity_unit": meta["capacity_unit"],
        "eol_threshold_pct": eol_pct,
        "eol_capacity_threshold": eol_capacity_threshold,
        "eol_cycle_reached": eol_cycle,
        "total_cycles": total_cycles_count,
        "initial_capacity_ah": initial_measured,
        "final_capacity_ah": final_measured,
        "net_capacity_fade_ah": net_fade,
        "net_soh_drop_pct": net_soh_drop,
        "test_conditions": meta["test_conditions"],
        "academic_disclosure": meta["academic_disclosure"],
        "cycles": processed_cycles
    }

