"""
BatteryIQ - Battery Data Processing Module
Handles ingestion, schema validation, null safety, and time conversions.
Enforces strict provenance tagging and supports Ah and kWh units.
"""

from typing import Dict, Any, List, Optional, Tuple


VALID_SOURCE_TYPES = {"PUBLIC_DATASET", "SIMULATOR", "LIVE_OBD"}
VALID_CAPACITY_UNITS = {"AH", "KWH"}


def validate_telemetry_payload(payload: Dict[str, Any]) -> Tuple[bool, Optional[str], Dict[str, Any]]:
    """
    Validate incoming battery telemetry payload.
    Ensures source_type is declared, capacity units are valid, and readings list is well-formed.
    """
    if not isinstance(payload, dict):
        return False, "Payload must be a JSON object", {}

    source_type = payload.get("source_type")
    if not source_type or source_type not in VALID_SOURCE_TYPES:
        return False, f"source_type must be one of: {sorted(list(VALID_SOURCE_TYPES))}", {}

    capacity_unit = str(payload.get("capacity_unit", "KWH")).upper()
    if capacity_unit not in VALID_CAPACITY_UNITS:
        return False, f"capacity_unit must be one of: {sorted(list(VALID_CAPACITY_UNITS))}", {}

    raw_readings = payload.get("readings", [])
    if not isinstance(raw_readings, list):
        return False, "readings must be an array of telemetry objects", {}

    cleaned_readings: List[Dict[str, Any]] = []
    nominal_capacity = payload.get("nominal_capacity")
    try:
        nominal_capacity = float(nominal_capacity) if nominal_capacity is not None else None
    except (ValueError, TypeError):
        nominal_capacity = None

    for idx, r in enumerate(raw_readings):
        if not isinstance(r, dict):
            continue

        # timestamp_offset_ms must be non-negative integer or float
        t_ms = r.get("timestamp_offset_ms")
        try:
            t_ms = int(t_ms) if t_ms is not None else (idx * 1000)
            if t_ms < 0:
                t_ms = 0
        except (ValueError, TypeError):
            t_ms = idx * 1000

        # Sensor readings: Keep strictly None if missing or invalid. DO NOT invent zeros.
        v = _clean_float(r.get("voltage_volts"))
        i = _clean_float(r.get("current_amps"))
        temp = _clean_float(r.get("temperature_celsius"))
        soc = _clean_float(r.get("soc_percentage"))
        delta = _clean_int(r.get("cell_delta_mv"))

        # Physical sanity bounds check (flagging impossible sensor readings)
        if v is not None and (v < 0.0 or v > 1200.0):
            v = None
        if temp is not None and (temp < -60.0 or temp > 150.0):
            temp = None
        if soc is not None and (soc < 0.0 or soc > 100.0):
            soc = None

        # Derived active power (kW) = (V * I) / 1000.0 (if both present)
        power_kw = None
        if v is not None and i is not None:
            power_kw = round((v * i) / 1000.0, 3)

        # Derived C-rate = abs(I) / nominal_capacity_Ah (if capacity in Ah is known)
        c_rate = None
        if i is not None and nominal_capacity and capacity_unit == "AH" and nominal_capacity > 0:
            c_rate = round(abs(i) / nominal_capacity, 3)

        cleaned_readings.append({
            "timestamp_offset_ms": t_ms,
            "voltage_volts": v,
            "current_amps": i,
            "temperature_celsius": temp,
            "soc_percentage": soc,
            "cell_delta_mv": delta,
            "active_power_kw": power_kw,
            "c_rate": c_rate
        })

    # Sort readings chronologically by timestamp
    cleaned_readings.sort(key=lambda x: x["timestamp_offset_ms"])

    processed_data = {
        "source_type": source_type,
        "cell_or_pack_identifier": payload.get("cell_or_pack_identifier", "UNKNOWN_PACK"),
        "chemistry_profile_id": payload.get("chemistry_profile_id", "CHEM_NMC_01"),
        "capacity_unit": capacity_unit,
        "nominal_capacity": nominal_capacity,
        "fresh_baseline_capacity": _clean_float(payload.get("fresh_baseline_capacity")),
        "current_measured_capacity": _clean_float(payload.get("current_measured_capacity")),
        "active_reference_type": str(payload.get("active_reference_type", "RATED_NOMINAL")).upper(),
        "readings_count": len(cleaned_readings),
        "readings": cleaned_readings
    }

    return True, None, processed_data


def _clean_float(val: Any) -> Optional[float]:
    if val is None or val == "" or str(val).strip().lower() in ("null", "none", "nan", "unavailable"):
        return None
    try:
        return float(val)
    except (ValueError, TypeError):
        return None


def _clean_int(val: Any) -> Optional[int]:
    if val is None or val == "" or str(val).strip().lower() in ("null", "none", "nan", "unavailable"):
        return None
    try:
        return int(float(val))
    except (ValueError, TypeError):
        return None

