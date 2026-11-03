"""
BatteryIQ - Battery Anomaly Detection Engine
Evaluates telemetry points against configurable, chemistry-specific bounds.
Detects:
  - Overvoltage & undervoltage
  - Thermal runaway danger, overheat warning, and sub-zero charge hazard (lithium plating)
  - Excessive charge/discharge C-rate
  - Module cell-voltage divergence (imbalance)
Does not use universal battery limits; respects the active chemistry profile.
"""

from typing import Dict, Any, List, Optional
from chemistry_profiles import get_profile


def detect_anomalies_for_reading(
    reading: Dict[str, Any],
    chemistry_profile_id: str = "CHEM_NMC_01",
    nominal_capacity_ah: Optional[float] = None
) -> List[Dict[str, Any]]:
    """
    Check an individual telemetry point against chemistry-specific limits.
    Returns list of anomaly objects, empty if all nominal.
    """
    profile = get_profile(chemistry_profile_id)
    anomalies: List[Dict[str, Any]] = []

    v = reading.get("voltage_volts")
    i = reading.get("current_amps")
    t = reading.get("temperature_celsius")
    delta_mv = reading.get("cell_delta_mv")

    # 1. Voltage Checks (Per cell or scaled)
    # If voltage is cell-level (< 10V) or scaled against profile limits
    cutoff_v = profile.get("cutoff_voltage", 3.00)
    max_charge_v = profile.get("max_charge_voltage", 4.20)

    if v is not None:
        if v < 10.0:  # Single cell or low-voltage module
            if v < cutoff_v:
                anomalies.append({
                    "parameter": "VOLTAGE",
                    "severity": "CRITICAL",
                    "observed_value": v,
                    "threshold": cutoff_v,
                    "description": f"Cell voltage ({v}V) dropped below {profile['chemistry_name']} safe cutoff ({cutoff_v}V). Risk of copper dissolution and permanent damage."
                })
            elif v > max_charge_v + 0.05:
                anomalies.append({
                    "parameter": "VOLTAGE",
                    "severity": "CRITICAL",
                    "observed_value": v,
                    "threshold": max_charge_v,
                    "description": f"Cell voltage ({v}V) exceeded {profile['chemistry_name']} maximum upper limit ({max_charge_v}V). Overcharge hazard."
                })

    # 2. Thermal Checks
    warn_t = profile.get("thermal_warning_temp_celsius", 45.0)
    crit_t = profile.get("thermal_critical_temp_celsius", 55.0)
    low_charge_t = profile.get("low_temp_charge_limit_celsius", 0.0)

    if t is not None:
        if t >= crit_t:
            anomalies.append({
                "parameter": "TEMPERATURE",
                "severity": "CRITICAL",
                "observed_value": t,
                "threshold": crit_t,
                "description": f"Battery temperature ({t}°C) reached critical threshold ({crit_t}°C). Severe thermal runaway risk for {profile['chemistry_name']}."
            })
        elif t >= warn_t:
            anomalies.append({
                "parameter": "TEMPERATURE",
                "severity": "WARNING",
                "observed_value": t,
                "threshold": warn_t,
                "description": f"Battery temperature ({t}°C) exceeds nominal warning threshold ({warn_t}°C). Accelerated calendar degradation expected."
            })

        # Sub-zero charging anomaly (Lithium plating risk)
        # Sign convention: charging current is negative (I < -0.5 A)
        if i is not None and i < -0.5 and t < low_charge_t:
            anomalies.append({
                "parameter": "TEMPERATURE_CHARGING",
                "severity": "CRITICAL",
                "observed_value": t,
                "threshold": low_charge_t,
                "description": f"Active charging ({abs(i)}A) below {low_charge_t}°C. Severe lithium plating hazard on anode, risking internal short circuit."
            })

    # 3. Cell-to-Cell Voltage Divergence Checks
    warn_delta = profile.get("max_cell_delta_mv_warning", 25)
    crit_delta = profile.get("max_cell_delta_mv_critical", 50)

    if delta_mv is not None:
        if delta_mv >= crit_delta:
            anomalies.append({
                "parameter": "CELL_BALANCE",
                "severity": "CRITICAL",
                "observed_value": delta_mv,
                "threshold": crit_delta,
                "description": f"Cell module voltage delta ({delta_mv} mV) exceeds critical rejection limit ({crit_delta} mV). Severe module imbalance."
            })
        elif delta_mv >= warn_delta:
            anomalies.append({
                "parameter": "CELL_BALANCE",
                "severity": "WARNING",
                "observed_value": delta_mv,
                "threshold": warn_delta,
                "description": f"Cell module voltage delta ({delta_mv} mV) exceeds recommended balance limit ({warn_delta} mV). Active cell balancing required."
            })

    # 4. Current & C-Rate Checks
    max_discharge_c = profile.get("max_discharge_c_rate", 2.5)
    max_charge_c = profile.get("max_charge_c_rate", 1.0)

    if i is not None and nominal_capacity_ah and nominal_capacity_ah > 0:
        c_rate = abs(i) / nominal_capacity_ah
        if i > 0 and c_rate > max_discharge_c:
            anomalies.append({
                "parameter": "CURRENT_DISCHARGE",
                "severity": "WARNING",
                "observed_value": round(c_rate, 2),
                "threshold": max_discharge_c,
                "description": f"Discharge C-rate ({round(c_rate, 2)}C) exceeds continuous rating ({max_discharge_c}C)."
            })
        elif i < 0 and c_rate > max_charge_c:
            anomalies.append({
                "parameter": "CURRENT_CHARGE",
                "severity": "WARNING",
                "observed_value": round(c_rate, 2),
                "threshold": max_charge_c,
                "description": f"Charge C-rate ({round(c_rate, 2)}C) exceeds continuous charging rating ({max_charge_c}C)."
            })

    return anomalies


def scan_telemetry_batch_anomalies(
    readings: List[Dict[str, Any]],
    chemistry_profile_id: str = "CHEM_NMC_01",
    nominal_capacity_ah: Optional[float] = None
) -> Dict[str, Any]:
    """
    Scan an entire array of telemetry readings.
    Returns anomaly summary, total count, breakdown by severity, and annotated readings.
    """
    total_anomalies = 0
    warning_count = 0
    critical_count = 0
    unique_types = set()
    annotated_readings = []

    for r in readings:
        r_anomalies = detect_anomalies_for_reading(r, chemistry_profile_id, nominal_capacity_ah)
        has_anom = len(r_anomalies) > 0
        desc = "; ".join([a["description"] for a in r_anomalies]) if has_anom else None

        for a in r_anomalies:
            total_anomalies += 1
            unique_types.add(a["parameter"])
            if a["severity"] == "CRITICAL":
                critical_count += 1
            else:
                warning_count += 1

        annotated = dict(r)
        annotated["has_anomaly"] = has_anom
        annotated["anomaly_description"] = desc
        annotated["anomalies_detail"] = r_anomalies
        annotated_readings.append(annotated)

    return {
        "total_anomalies_detected": total_anomalies,
        "critical_count": critical_count,
        "warning_count": warning_count,
        "affected_parameters": sorted(list(unique_types)),
        "chemistry_profile_id": chemistry_profile_id,
        "status": "ANOMALIES_DETECTED" if total_anomalies > 0 else "CLEAN_NOMINAL",
        "annotated_readings": annotated_readings
    }

