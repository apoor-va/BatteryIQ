"""
BatteryIQ - Comprehensive Independent Test Suite for Python Microservice
Tests all core modules and REST API endpoints directly via Flask test client.
"""

import unittest
import json
from app import app


class BatteryIQServiceTests(unittest.TestCase):

    def setUp(self):
        self.client = app.test_client()
        self.client.testing = True

    # 1. Health Endpoint Test
    def test_health_check(self):
        res = self.client.get("/health")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertEqual(data["status"], "HEALTHY")
        self.assertEqual(data["port"], 5001)
        self.assertIn("CHEM_NMC_01", data["supported_chemistries"])
        self.assertIn("CHEM_LFP_01", data["supported_chemistries"])

    # 2. Chemistry Profiles Endpoints
    def test_chemistry_profiles_list_and_get(self):
        res = self.client.get("/api/chemistry/profiles")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertGreaterEqual(data["count"], 4)

        # Get specific LFP profile
        res_lfp = self.client.get("/api/chemistry/profiles/CHEM_LFP_01")
        self.assertEqual(res_lfp.status_code, 200)
        lfp_data = res_lfp.get_json()["profile"]
        self.assertEqual(lfp_data["nominal_cell_voltage"], 3.20)
        self.assertEqual(lfp_data["cutoff_voltage"], 2.50)
        self.assertEqual(lfp_data["coulombic_efficiency"], 0.990)

    # 3. Telemetry Ingestion and Null Safety
    def test_telemetry_processing_null_safety(self):
        payload = {
            "source_type": "SIMULATOR",
            "capacity_unit": "KWH",
            "nominal_capacity": 75.0,
            "readings": [
                {
                    "timestamp_offset_ms": 0,
                    "voltage_volts": 400.2,
                    "current_amps": 15.0,
                    "temperature_celsius": 26.5,
                    "soc_percentage": 80.0,
                    "cell_delta_mv": 12
                },
                {
                    "timestamp_offset_ms": 1000,
                    "voltage_volts": None,  # Testing missing voltage
                    "current_amps": "unavailable",  # Testing missing string value
                    "temperature_celsius": 26.6,
                    "soc_percentage": None,
                    "cell_delta_mv": None
                }
            ]
        }
        res = self.client.post("/api/telemetry/process", data=json.dumps(payload), content_type="application/json")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()["processed_data"]
        readings = data["readings"]
        self.assertEqual(len(readings), 2)
        # Verify first point has active power: 400.2V * 15A / 1000 = 6.003 kW
        self.assertAlmostEqual(readings[0]["active_power_kw"], 6.003, places=2)
        # Verify second point preserves strictly None (NOT fake 0.0)
        self.assertIsNone(readings[1]["voltage_volts"])
        self.assertIsNone(readings[1]["current_amps"])
        self.assertIsNone(readings[1]["active_power_kw"])

    # 4. Coulomb Counting Time Conversion and Current Signs
    def test_soc_coulomb_counting_accuracy(self):
        # 10 Amp-hour cell, starting at 100% SOC.
        # Discharging at constant 10 Amps for 1800 seconds (0.5 hours).
        # Throughput = 10 A * 0.5 h = 5.0 Ah consumed.
        # Expected final SOC = 100% - (5.0 / 10.0)*100% = 50.0%
        payload = {
            "method": "COULOMB_COUNTING",
            "initial_soc_pct": 100.0,
            "usable_capacity": 10.0,
            "capacity_unit": "AH",
            "chemistry_profile_id": "CHEM_NMC_01",
            "readings": [
                {"timestamp_offset_ms": 0, "current_amps": 10.0},
                {"timestamp_offset_ms": 1_800_000, "current_amps": 10.0}  # 1800 seconds
            ]
        }
        res = self.client.post("/api/soc/calculate", data=json.dumps(payload), content_type="application/json")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertEqual(data["status"], "COMPUTED")
        self.assertAlmostEqual(data["final_soc_pct"], 50.0, places=1)
        self.assertAlmostEqual(data["total_discharge_throughput"], 5.0, places=2)

    # 5. SOC Missing Data Handling
    def test_soc_missing_inputs_returns_unavailable(self):
        payload = {
            "method": "COULOMB_COUNTING",
            "initial_soc_pct": None,  # Missing initial SOC
            "usable_capacity": 50.0,
            "readings": [{"timestamp_offset_ms": 0, "current_amps": 10.0}]
        }
        res = self.client.post("/api/soc/calculate", data=json.dumps(payload), content_type="application/json")
        self.assertEqual(res.status_code, 422)
        data = res.get_json()
        self.assertEqual(data["status"], "UNAVAILABLE")
        self.assertIsNone(data["final_soc_pct"])

    # 6. SOH Analysis & Reference Consistency
    def test_soh_analysis_nominal_and_baseline(self):
        # Rated Nominal Reference: 100 kWh, current usable 88 kWh -> SOH = 88.0%, Degradation = 12.0%
        payload_nom = {
            "current_measured_capacity": 88.0,
            "nominal_capacity": 100.0,
            "fresh_baseline_capacity": 98.0,
            "active_reference_type": "RATED_NOMINAL",
            "capacity_unit": "KWH",
            "chemistry_profile_id": "CHEM_NMC_01"
        }
        res = self.client.post("/api/soh/analyze", data=json.dumps(payload_nom), content_type="application/json")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertEqual(data["soh_percentage"], 88.0)
        self.assertEqual(data["degradation_percentage"], 12.0)
        self.assertEqual(data["condition_category"], "GOOD")
        self.assertEqual(data["active_reference_type"], "RATED_NOMINAL")

        # Fresh Baseline Reference: current usable 88 kWh, baseline was 98.0 kWh -> SOH = (88/98)*100 = 89.8%
        payload_base = dict(payload_nom)
        payload_base["active_reference_type"] = "FRESH_BASELINE"
        res_base = self.client.post("/api/soh/analyze", data=json.dumps(payload_base), content_type="application/json")
        self.assertEqual(res_base.status_code, 200)
        data_base = res_base.get_json()
        self.assertAlmostEqual(data_base["soh_percentage"], 89.8, places=1)
        self.assertEqual(data_base["active_reference_type"], "FRESH_BASELINE")

    # 7. Chemistry-Specific Anomaly Detection
    def test_anomaly_detection_chemistry_specific(self):
        # Test 1: Sub-zero charging anomaly (Lithium plating hazard)
        payload_subzero = {
            "chemistry_profile_id": "CHEM_NMC_01",
            "readings": [
                {
                    "timestamp_offset_ms": 0,
                    "voltage_volts": 3.8,
                    "current_amps": -10.0,  # Negative current = charging
                    "temperature_celsius": -5.0,  # Below 0°C
                    "cell_delta_mv": 10
                }
            ]
        }
        res = self.client.post("/api/anomaly/detect", data=json.dumps(payload_subzero), content_type="application/json")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertGreater(data["critical_count"], 0)
        self.assertIn("TEMPERATURE_CHARGING", data["affected_parameters"])

        # Test 2: Severe cell imbalance anomaly (> 50 mV)
        payload_imbalance = {
            "chemistry_profile_id": "CHEM_NMC_01",
            "readings": [
                {
                    "timestamp_offset_ms": 0,
                    "voltage_volts": 3.8,
                    "current_amps": 5.0,
                    "temperature_celsius": 25.0,
                    "cell_delta_mv": 65  # Imbalance > 50 mV critical
                }
            ]
        }
        res2 = self.client.post("/api/anomaly/detect", data=json.dumps(payload_imbalance), content_type="application/json")
        self.assertEqual(res2.status_code, 200)
        data2 = res2.get_json()
        self.assertIn("CELL_BALANCE", data2["affected_parameters"])

    # 8. RUL Prediction and Limitations
    def test_rul_prediction_and_sparse_data_handling(self):
        # Case A: Insufficient cycle history (< 5 cycles) -> must return INSUFFICIENT_DATA
        payload_sparse = {
            "cycle_history": [
                {"cycle_index": 1, "capacity": 2.0},
                {"cycle_index": 2, "capacity": 1.95}
            ],
            "current_capacity": 1.95,
            "reference_capacity": 2.0,
            "capacity_unit": "AH"
        }
        res_sparse = self.client.post("/api/rul/predict", data=json.dumps(payload_sparse), content_type="application/json")
        self.assertEqual(res_sparse.status_code, 200)
        data_sparse = res_sparse.get_json()
        self.assertEqual(data_sparse["status"], "INSUFFICIENT_DATA")
        self.assertIsNone(data_sparse["estimated_rul_cycles"])

        # Case B: Sufficient cycle history -> predicts RUL with metrics & academic disclosure
        payload_valid = {
            "cycle_history": [
                {"cycle_index": 1, "capacity": 2.00},
                {"cycle_index": 20, "capacity": 1.92},
                {"cycle_index": 40, "capacity": 1.84},
                {"cycle_index": 60, "capacity": 1.76},
                {"cycle_index": 80, "capacity": 1.68},
                {"cycle_index": 100, "capacity": 1.60}
            ],
            "current_capacity": 1.60,
            "reference_capacity": 2.00,
            "capacity_unit": "AH",
            "chemistry_profile_id": "CHEM_NASA_18650"
        }
        res_valid = self.client.post("/api/rul/predict", data=json.dumps(payload_valid), content_type="application/json")
        self.assertEqual(res_valid.status_code, 200)
        data_valid = res_valid.get_json()
        self.assertEqual(data_valid["status"], "PREDICTED")
        self.assertIsNotNone(data_valid["estimated_rul_cycles"])
        self.assertIn("evaluation_metrics", data_valid)
        self.assertIn("academic_disclosure", data_valid)
        self.assertIn("EXPERIMENTAL LABORATORY", data_valid["academic_disclosure"])

    # 9. Unified Battery Analyze Endpoint with Provenance
    def test_comprehensive_analyze_provenance(self):
        payload = {
            "source_type": "LIVE_OBD",
            "cell_or_pack_identifier": "TEST_EV_PACK_01",
            "chemistry_profile_id": "CHEM_NMC_01",
            "capacity_unit": "KWH",
            "nominal_capacity": 75.0,
            "current_measured_capacity": 70.0,
            "initial_soc_pct": 85.0,
            "readings": [
                {
                    "timestamp_offset_ms": 0,
                    "voltage_volts": 380.5,
                    "current_amps": 20.0,
                    "temperature_celsius": 28.0,
                    "cell_delta_mv": 12
                },
                {
                    "timestamp_offset_ms": 10_000,
                    "voltage_volts": 379.8,
                    "current_amps": 20.0,
                    "temperature_celsius": 28.1,
                    "cell_delta_mv": 12
                }
            ]
        }
        res = self.client.post("/api/battery/analyze", data=json.dumps(payload), content_type="application/json")
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertEqual(data["status"], "SUCCESS")
        # Verify provenance tags: Live OBD must NOT be marked as physically verified!
        provenance = data["provenance"]
        self.assertEqual(provenance["source_type"], "LIVE_OBD")
        self.assertEqual(provenance["verification_status"], "UNVERIFIED_LIVE_TELEMETRY")
        self.assertFalse(provenance["is_physically_verified"])
        # Verify SOH calculated
        self.assertAlmostEqual(data["soh_analysis"]["soh_percentage"], 93.33, places=1)


if __name__ == "__main__":
    unittest.main()

