"""
BatteryIQ - Phase 5 Dataset Integration & ML Model Development Test Suite
Tests dataset ingestion, column validation, SOH/fade calculations,
model comparison (MAE, RMSE, R2), and REST API endpoints.
"""

import unittest
import json
import os
import sys

# Ensure python directory is in path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app
from dataset_loader import list_available_datasets, load_cell_dataset
from ml_engine import train_and_compare_models, compute_metrics
import numpy as np


class Phase5DatasetAndMLTests(unittest.TestCase):

    def setUp(self):
        self.client = app.test_client()
        self.client.testing = True

    # 1. Dataset Listing Endpoint
    def test_list_datasets_endpoint(self):
        res = self.client.get("/api/datasets")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertEqual(data["status"], "SUCCESS")
        self.assertEqual(data["count"], 2)
        
        dataset_ids = [d["dataset_id"] for d in data["datasets"]]
        self.assertIn("NASA_PCOE", dataset_ids)
        self.assertIn("CALCE", dataset_ids)

    # 2. NASA Cell B0005 Ingestion and Calculations
    def test_nasa_cell_b0005_ingestion(self):
        res = self.client.get("/api/datasets/NASA_PCOE/B0005")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()["data"]
        
        self.assertEqual(data["cell_id"], "B0005")
        self.assertEqual(data["split_role"], "TRAIN")
        self.assertEqual(data["nominal_capacity_ah"], 2.0)
        self.assertEqual(data["total_cycles"], 168)
        self.assertIsNotNone(data["eol_cycle_reached"])
        
        # Verify cycles data structure and calculations
        cycles = data["cycles"]
        self.assertEqual(len(cycles), 168)
        c1 = cycles[0]
        self.assertEqual(c1["cycle_index"], 1)
        self.assertGreater(c1["soh_pct"], 90.0)
        self.assertIsNotNone(c1["actual_rul_cycles"])
        self.assertIn("EXPERIMENTAL LABORATORY CELL DATA ONLY", data["academic_disclosure"])

    # 3. NASA Cell B0007 (Holdout Test Cell)
    def test_nasa_cell_b0007_holdout(self):
        res = self.client.get("/api/datasets/NASA_PCOE/B0007")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()["data"]
        self.assertEqual(data["cell_id"], "B0007")
        self.assertEqual(data["split_role"], "TEST") # Strict cell-level holdout

    # 4. CALCE Cell CS2_35 Ingestion
    def test_calce_cell_cs2_35_ingestion(self):
        res = self.client.get("/api/datasets/CALCE/CS2_35")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()["data"]
        self.assertEqual(data["cell_id"], "CS2_35")
        self.assertEqual(data["total_cycles"], 800)
        self.assertEqual(data["capacity_unit"], "AH")

    # 5. Invalid Dataset / Cell Error Handling
    def test_invalid_dataset_or_cell_error(self):
        res = self.client.get("/api/datasets/UNKNOWN_DS/B0005")
        self.assertEqual(res.status_code, 404)
        
        res2 = self.client.get("/api/datasets/NASA_PCOE/INVALID_CELL")
        self.assertEqual(res2.status_code, 404)

    # 6. ML Model Registry & Algorithm Comparison
    def test_ml_model_comparison_and_registry(self):
        res = self.client.get("/api/ml/models?dataset=NASA_PCOE")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()["model_registry"]
        
        self.assertIn("model_comparison", data)
        comparisons = data["model_comparison"]
        self.assertGreaterEqual(len(comparisons), 4) # At least 4 candidate models compared
        
        # Verify required metrics are calculated for all candidates
        for entry in comparisons:
            self.assertIn("test_mae", entry)
            self.assertIn("test_rmse", entry)
            self.assertIn("test_r2", entry)
            self.assertGreater(entry["test_rmse"], 0.0)

        # Verify academic disclosure notice and limitations
        self.assertIn("academic_disclosure_notice", data)
        self.assertIn("known_limitations", data)
        self.assertGreaterEqual(len(data["known_limitations"]), 1)

    # 7. Metric Calculation Utility Test
    def test_metrics_calculation(self):
        y_true = np.array([100.0, 80.0, 60.0, 40.0, 20.0, 0.0])
        y_pred = np.array([95.0, 82.0, 58.0, 41.0, 22.0, 2.0])
        metrics = compute_metrics(y_true, y_pred)
        
        self.assertAlmostEqual(metrics["mae"], 2.33, places=1)
        self.assertGreater(metrics["r2_score"], 0.95)


if __name__ == "__main__":
    unittest.main()

