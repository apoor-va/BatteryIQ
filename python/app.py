"""
BatteryIQ - Python Battery Intelligence Microservice
Port: 5001
Single Source of Truth for Battery Scientific Calculations, Telemetry Processing,
Coulomb Counting, SOH Analysis, Anomaly Detection, and RUL Prediction.

Uses Flask and Waitress WSGI.
"""

import sys
import time
from flask import Flask, request, jsonify
from waitress import serve

from chemistry_profiles import get_all_profiles, get_profile
from data_processor import validate_telemetry_payload
from soc_calculator import calculate_coulomb_counting, estimate_soc_from_resting_voltage
from soh_analyzer import analyze_soh_and_degradation
from anomaly_detector import scan_telemetry_batch_anomalies, detect_anomalies_for_reading
from rul_predictor import predict_rul_from_cycle_history, NASA_MODEL_BENCHMARKS
from dataset_loader import list_available_datasets, load_cell_dataset, DATASET_METADATA
from ml_engine import train_and_compare_models, get_registered_model_info


app = Flask(__name__)
SERVICE_START_TIME = time.time()
SERVICE_VERSION = "1.0.0"


# ------------------------------------------------------------------------------
# 1. Service Health Check
# ------------------------------------------------------------------------------
@app.route("/health", methods=["GET"])
@app.route("/api/health", methods=["GET"])
def health_check():
    """Service health and uptime endpoint."""
    uptime_sec = round(time.time() - SERVICE_START_TIME, 1)
    return jsonify({
        "service": "BatteryIQ Scientific Intelligence Microservice",
        "status": "HEALTHY",
        "version": SERVICE_VERSION,
        "python_version": sys.version.split()[0],
        "port": 5001,
        "uptime_seconds": uptime_sec,
        "supported_chemistries": [p["profile_id"] for p in get_all_profiles()],
        "scientific_engine": "Active (NumPy & Pure-Math Analytical Solver)"
    }), 200


# ------------------------------------------------------------------------------
# 2. Chemistry Profiles Endpoints
# ------------------------------------------------------------------------------
@app.route("/api/chemistry/profiles", methods=["GET"])
def list_chemistry_profiles():
    """List all configured battery chemistry profiles."""
    profiles = get_all_profiles()
    return jsonify({
        "status": "SUCCESS",
        "count": len(profiles),
        "profiles": profiles
    }), 200


@app.route("/api/chemistry/profiles/<profile_id>", methods=["GET"])
def get_chemistry_profile(profile_id):
    """Retrieve detailed specification for a specific chemistry profile."""
    profile = get_profile(profile_id)
    if not profile or profile.get("profile_id") != profile_id:
        return jsonify({
            "status": "NOT_FOUND",
            "message": f"Chemistry profile '{profile_id}' not found.",
            "fallback_used": profile.get("profile_id")
        }), 404
    return jsonify({
        "status": "SUCCESS",
        "profile": profile
    }), 200


# ------------------------------------------------------------------------------
# 3. Telemetry Processing & Validation
# ------------------------------------------------------------------------------
@app.route("/api/telemetry/process", methods=["POST"])
def process_telemetry():
    """
    Validate and clean incoming battery telemetry.
    Enforces null safety (no fake zeros) and validates physical plausibility.
    """
    payload = request.get_json(silent=True) or {}
    is_valid, err_msg, cleaned = validate_telemetry_payload(payload)

    if not is_valid:
        return jsonify({
            "status": "VALIDATION_ERROR",
            "message": err_msg
        }), 400

    return jsonify({
        "status": "SUCCESS",
        "processed_data": cleaned
    }), 200


# ------------------------------------------------------------------------------
# 4. State of Charge (SOC) Calculation
# ------------------------------------------------------------------------------
@app.route("/api/soc/calculate", methods=["POST"])
def calculate_soc():
    """
    Calculate battery SOC via Coulomb Counting with time-unit conversions (Δt_ms to hours).
    Supports initial SOC and resting OCV checks. Never invents values.
    """
    payload = request.get_json(silent=True) or {}
    readings = payload.get("readings", [])
    initial_soc = payload.get("initial_soc_pct")
    usable_cap = payload.get("usable_capacity")
    cap_unit = payload.get("capacity_unit", "AH")
    chem_id = payload.get("chemistry_profile_id", "CHEM_NMC_01")
    method = payload.get("method", "COULOMB_COUNTING").upper()

    try:
        initial_soc = float(initial_soc) if initial_soc is not None else None
    except (ValueError, TypeError):
        initial_soc = None

    try:
        usable_cap = float(usable_cap) if usable_cap is not None else None
    except (ValueError, TypeError):
        usable_cap = None

    if method == "RESTING_OCV":
        voltage = payload.get("voltage_volts")
        current = payload.get("current_amps")
        result = estimate_soc_from_resting_voltage(voltage, current, chem_id)
    else:
        result = calculate_coulomb_counting(readings, initial_soc, usable_cap, cap_unit, chem_id)

    status_code = 200 if result.get("status") in ("COMPUTED", "ESTIMATED") else 422
    return jsonify(result), status_code


# ------------------------------------------------------------------------------
# 5. State of Health (SOH) & Degradation Analysis
# ------------------------------------------------------------------------------
@app.route("/api/soh/analyze", methods=["POST"])
def analyze_soh():
    """
    Calculate SOH percentage, degradation rate, and condition rating
    using a consistently anchored reference capacity.
    """
    payload = request.get_json(silent=True) or {}

    try:
        current_cap = float(payload.get("current_measured_capacity")) if payload.get("current_measured_capacity") is not None else None
    except (ValueError, TypeError):
        current_cap = None

    try:
        nom_cap = float(payload.get("nominal_capacity")) if payload.get("nominal_capacity") is not None else None
    except (ValueError, TypeError):
        nom_cap = None

    try:
        fresh_cap = float(payload.get("fresh_baseline_capacity")) if payload.get("fresh_baseline_capacity") is not None else None
    except (ValueError, TypeError):
        fresh_cap = None

    ref_type = payload.get("active_reference_type", "RATED_NOMINAL")
    cap_unit = payload.get("capacity_unit", "KWH")
    chem_id = payload.get("chemistry_profile_id", "CHEM_NMC_01")

    result = analyze_soh_and_degradation(
        current_measured_capacity=current_cap,
        nominal_capacity=nom_cap,
        fresh_baseline_capacity=fresh_cap,
        active_reference_type=ref_type,
        capacity_unit=cap_unit,
        chemistry_profile_id=chem_id
    )

    status_code = 200 if result.get("status") == "COMPUTED" else 422
    return jsonify(result), status_code


# ------------------------------------------------------------------------------
# 6. Anomaly Detection
# ------------------------------------------------------------------------------
@app.route("/api/anomaly/detect", methods=["POST"])
def detect_anomalies():
    """
    Scan telemetry readings against chemistry-specific limits.
    Returns anomaly breakdown by severity (WARNING, CRITICAL) and annotated points.
    """
    payload = request.get_json(silent=True) or {}
    readings = payload.get("readings", [])
    chem_id = payload.get("chemistry_profile_id", "CHEM_NMC_01")
    nom_cap = payload.get("nominal_capacity")

    try:
        nom_cap = float(nom_cap) if nom_cap is not None else None
    except (ValueError, TypeError):
        nom_cap = None

    result = scan_telemetry_batch_anomalies(readings, chem_id, nom_cap)
    return jsonify(result), 200


# ------------------------------------------------------------------------------
# 7. Remaining Useful Life (RUL) Prediction
# ------------------------------------------------------------------------------
@app.route("/api/rul/predict", methods=["POST"])
def predict_rul():
    """
    Predict remaining cycles to defined EOL threshold.
    Returns honest UNAVAILABLE / INSUFFICIENT_DATA status if data is sparse.
    Includes academic single-cell limitation notice.
    """
    payload = request.get_json(silent=True) or {}
    cycles = payload.get("cycle_history", [])
    chem_id = payload.get("chemistry_profile_id", "CHEM_NASA_18650")
    cap_unit = payload.get("capacity_unit", "AH")

    try:
        curr_cap = float(payload.get("current_capacity")) if payload.get("current_capacity") is not None else None
    except (ValueError, TypeError):
        curr_cap = None

    try:
        ref_cap = float(payload.get("reference_capacity")) if payload.get("reference_capacity") is not None else None
    except (ValueError, TypeError):
        ref_cap = None

    try:
        eol_pct = float(payload.get("eol_threshold_pct")) if payload.get("eol_threshold_pct") is not None else None
    except (ValueError, TypeError):
        eol_pct = None

    result = predict_rul_from_cycle_history(
        cycle_history=cycles,
        current_capacity=curr_cap,
        reference_capacity=ref_cap,
        capacity_unit=cap_unit,
        chemistry_profile_id=chem_id,
        custom_eol_pct=eol_pct
    )

    return jsonify(result), 200


# ------------------------------------------------------------------------------
# 8. Unified Battery Diagnostic & Analysis
# ------------------------------------------------------------------------------
@app.route("/api/battery/analyze", methods=["POST"])
def comprehensive_battery_analysis():
    """
    Unified end-to-end diagnostic endpoint.
    Performs validation, Coulomb Counting, SOH analysis, anomaly detection,
    and RUL prediction with strict provenance tagging.
    """
    payload = request.get_json(silent=True) or {}
    is_valid, err_msg, cleaned = validate_telemetry_payload(payload)

    if not is_valid:
        return jsonify({"status": "VALIDATION_ERROR", "message": err_msg}), 400

    source_type = cleaned["source_type"]
    chem_id = cleaned["chemistry_profile_id"]
    cap_unit = cleaned["capacity_unit"]
    nom_cap = cleaned["nominal_capacity"]
    fresh_cap = cleaned["fresh_baseline_capacity"]
    curr_cap = cleaned["current_measured_capacity"]
    ref_type = cleaned["active_reference_type"]
    readings = cleaned["readings"]

    # Assign provenance and non-destructive verification tags
    if source_type == "PUBLIC_DATASET":
        verification_status = "UNVERIFIED_DATASET"
        provenance_banner = "LABORATORY BENCHMARK: NASA Ames PCoE 18650 Experimental Single-Cell Aging Dataset. Not an EV vehicle pack."
    elif source_type == "SIMULATOR":
        verification_status = "UNVERIFIED_DEMO"
        provenance_banner = "DEMO DATA – SIMULATED BATTERY READINGS. Generated via dynamic electro-thermal physics model for demonstration."
    elif source_type == "LIVE_OBD":
        verification_status = "UNVERIFIED_LIVE_TELEMETRY"
        provenance_banner = "LIVE VEHICLE TELEMETRY RECEIVED. Note: Live data reception does NOT constitute an independent physical verification."
    else:
        verification_status = "UNVERIFIED"
        provenance_banner = "UNVERIFIED TELEMETRY SOURCE."

    # 1. Anomaly Scan
    anomaly_result = scan_telemetry_batch_anomalies(readings, chem_id, nom_cap if cap_unit == "AH" else None)

    # 2. SOH Analysis
    soh_result = analyze_soh_and_degradation(
        current_measured_capacity=curr_cap,
        nominal_capacity=nom_cap,
        fresh_baseline_capacity=fresh_cap,
        active_reference_type=ref_type,
        capacity_unit=cap_unit,
        chemistry_profile_id=chem_id
    )

    # 3. SOC Coulomb Counting (if readings present)
    initial_soc = payload.get("initial_soc_pct")
    try:
        initial_soc = float(initial_soc) if initial_soc is not None else None
    except (ValueError, TypeError):
        initial_soc = None

    soc_result = calculate_coulomb_counting(
        readings=readings,
        initial_soc_pct=initial_soc,
        usable_capacity=curr_cap or nom_cap,
        capacity_unit=cap_unit,
        chemistry_profile_id=chem_id
    )

    # 4. RUL Forecast (if cycle history provided)
    cycle_history = payload.get("cycle_history", [])
    rul_result = predict_rul_from_cycle_history(
        cycle_history=cycle_history,
        current_capacity=curr_cap,
        reference_capacity=soh_result.get("reference_capacity_value"),
        capacity_unit=cap_unit,
        chemistry_profile_id=chem_id
    )

    return jsonify({
        "status": "SUCCESS",
        "provenance": {
            "source_type": source_type,
            "verification_status": verification_status,
            "provenance_banner": provenance_banner,
            "is_physically_verified": False  # Only certified technicians can physically verify
        },
        "pack_metadata": {
            "cell_or_pack_identifier": cleaned["cell_or_pack_identifier"],
            "chemistry_profile_id": chem_id,
            "capacity_unit": cap_unit,
            "nominal_capacity": nom_cap,
            "fresh_baseline_capacity": fresh_cap,
            "current_measured_capacity": curr_cap,
            "active_reference_type": ref_type
        },
        "soh_analysis": soh_result,
        "soc_analysis": soc_result,
        "anomaly_analysis": anomaly_result,
        "rul_prediction": rul_result
    }), 200


# ------------------------------------------------------------------------------
# 8. Public Battery Datasets Endpoints
# ------------------------------------------------------------------------------
@app.route("/api/datasets", methods=["GET"])
def get_datasets():
    """List all available public research datasets (NASA Ames PCoE, CALCE)."""
    try:
        datasets = list_available_datasets()
        return jsonify({
            "status": "SUCCESS",
            "count": len(datasets),
            "datasets": datasets
        }), 200
    except Exception as e:
        return jsonify({
            "status": "ERROR",
            "message": f"Failed to list datasets: {str(e)}"
        }), 500


@app.route("/api/datasets/<dataset_name>/<cell_id>", methods=["GET"])
def get_dataset_cell(dataset_name, cell_id):
    """Retrieve full cycle degradation history, SOH %, and anomalies for a cell."""
    try:
        custom_eol = request.args.get("eol_threshold_pct", type=float)
        cell_data = load_cell_dataset(dataset_name, cell_id, custom_eol_pct=custom_eol)
        return jsonify({
            "status": "SUCCESS",
            "data": cell_data
        }), 200
    except ValueError as ve:
        return jsonify({
            "status": "NOT_FOUND",
            "message": str(ve)
        }), 404
    except Exception as e:
        return jsonify({
            "status": "ERROR",
            "message": f"Failed to load cell data: {str(e)}"
        }), 500


# ------------------------------------------------------------------------------
# 9. ML Model Registry & Evaluation Endpoints
# ------------------------------------------------------------------------------
@app.route("/api/ml/models", methods=["GET"])
def get_ml_models():
    """Retrieve active ML model comparison, metrics (MAE, RMSE, R²), and disclosures."""
    try:
        dataset_key = request.args.get("dataset", default="NASA_PCOE").upper()
        info = get_registered_model_info()
        # If requested dataset differs from cached registry, retrain/fetch for it
        if info.get("dataset_key") != dataset_key:
            info = train_and_compare_models(dataset_key)
        return jsonify({
            "status": "SUCCESS",
            "model_registry": info
        }), 200
    except Exception as e:
        return jsonify({
            "status": "ERROR",
            "message": f"Failed to retrieve model registry: {str(e)}"
        }), 500


@app.route("/api/ml/train", methods=["POST"])
def retrain_ml_models():
    """Trigger training, algorithm comparison, and registry update."""
    payload = request.get_json(silent=True) or {}
    dataset_key = payload.get("dataset_key", "NASA_PCOE").upper()
    try:
        result = train_and_compare_models(dataset_key)
        return jsonify({
            "status": "SUCCESS",
            "message": f"Model training and comparison completed for {dataset_key}.",
            "model_registry": result
        }), 200
    except Exception as e:
        return jsonify({
            "status": "TRAINING_ERROR",
            "message": f"Training failed: {str(e)}"
        }), 500



# ------------------------------------------------------------------------------
# Main Runner with Waitress WSGI
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    port = 5001
    print(f"============================================================")
    print(f"  BatteryIQ Scientific Intelligence Microservice")
    print(f"  Running on Waitress WSGI at http://127.0.0.1:{port}")
    print(f"============================================================")
    try:
        serve(app, host="127.0.0.1", port=port)
    except Exception as e:
        print(f"Waitress failed to start ({e}), falling back to Flask dev server...")
        app.run(host="127.0.0.1", port=port, debug=False)

