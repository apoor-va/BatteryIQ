"""
BatteryIQ - State of Charge (SOC) Calculation Engine
Implements time-accurate discrete Coulomb Counting and resting OCV lookup.
Converts milliseconds/seconds to hours: Δt_hours = Δt_ms / 3,600,000.0.
Follows strict automotive current sign conventions:
  - Discharge: I > 0 A (energy leaves pack -> SOC decreases)
  - Charge:    I < 0 A (energy enters pack -> SOC increases with efficiency factor eta)
"""

from typing import Dict, Any, List, Optional
from chemistry_profiles import get_profile, interpolate_soc_from_ocv


def calculate_coulomb_counting(
    readings: List[Dict[str, Any]],
    initial_soc_pct: Optional[float],
    usable_capacity: Optional[float],
    capacity_unit: str = "AH",
    chemistry_profile_id: str = "CHEM_NMC_01"
) -> Dict[str, Any]:
    """
    Run discrete Coulomb Counting across a time-series of readings.
    Requires initial_soc_pct, usable_capacity, and readings with valid current_amps.
    DO NOT invent SOC if required inputs are missing.
    """
    profile = get_profile(chemistry_profile_id)
    base_eta = profile.get("coulombic_efficiency", 0.985)

    if usable_capacity is None or usable_capacity <= 0:
        return {
            "status": "UNAVAILABLE",
            "message": "Usable capacity is required and must be greater than zero for Coulomb Counting.",
            "soc_series": [],
            "final_soc_pct": None,
            "total_discharge_throughput": 0.0,
            "total_charge_throughput": 0.0,
            "capacity_unit": capacity_unit
        }

    if initial_soc_pct is None:
        # Check if first point has resting voltage to initialize SOC from OCV
        first_r = readings[0] if readings else None
        if first_r and first_r.get("voltage_volts") is not None and (first_r.get("current_amps") is None or abs(first_r["current_amps"]) < 0.05):
            initial_soc_pct = interpolate_soc_from_ocv(profile, first_r["voltage_volts"])

        if initial_soc_pct is None:
            return {
                "status": "UNAVAILABLE",
                "message": "Initial SOC is missing and cannot be reliably established from resting OCV. Coulomb Counting cannot start.",
                "soc_series": [],
                "final_soc_pct": None,
                "total_discharge_throughput": 0.0,
                "total_charge_throughput": 0.0,
                "capacity_unit": capacity_unit
            }

    soc_series: List[Dict[str, Any]] = []
    current_soc = float(initial_soc_pct)
    total_discharge = 0.0
    total_charge = 0.0
    valid_integration_points = 0

    prev_time_ms = None

    for r in readings:
        t_ms = r.get("timestamp_offset_ms")
        i_amps = r.get("current_amps")
        temp = r.get("temperature_celsius")

        if prev_time_ms is None or t_ms is None:
            prev_time_ms = t_ms
            soc_series.append({
                "timestamp_offset_ms": t_ms,
                "soc_percentage": round(current_soc, 2),
                "current_amps": i_amps,
                "method": "INITIAL_ANCHOR"
            })
            continue

        delta_ms = t_ms - prev_time_ms
        prev_time_ms = t_ms

        if delta_ms <= 0 or i_amps is None:
            # Cannot integrate this interval due to missing current reading or non-advancing time
            soc_series.append({
                "timestamp_offset_ms": t_ms,
                "soc_percentage": round(current_soc, 2),
                "current_amps": i_amps,
                "method": "HELD_PREVIOUS_SOC"
            })
            continue

        # Convert elapsed time in milliseconds to hours:
        # Δt_hours = Δt_ms / 3,600,000.0
        delta_hours = delta_ms / 3_600_000.0

        # Adjust charging efficiency if temperature is low
        eta = base_eta
        if i_amps < 0 and temp is not None and temp < 10.0:
            # Low temperature reduces charge acceptance
            eta = max(0.85, base_eta - (10.0 - temp) * 0.01)

        # Delta throughput in Ah (or normalized energy units)
        # Sign convention:
        # If I > 0 (discharge): delta_q > 0 -> SOC decreases
        # If I < 0 (charge): delta_q < 0 -> SOC increases
        if i_amps >= 0:
            delta_q = i_amps * delta_hours  # Discharge: 100% efficient by definition
            total_discharge += delta_q
        else:
            delta_q = (i_amps * eta) * delta_hours  # Charge: negative delta_q
            total_charge += abs(delta_q)

        # Update SOC: SOC(t) = SOC(t-1) - (ΔQ / C_usable) * 100%
        delta_soc = (delta_q / usable_capacity) * 100.0
        current_soc = current_soc - delta_soc

        # Clamp physically between 0.0% and 100.0%
        current_soc = max(0.0, min(100.0, current_soc))
        valid_integration_points += 1

        soc_series.append({
            "timestamp_offset_ms": t_ms,
            "soc_percentage": round(current_soc, 2),
            "current_amps": i_amps,
            "delta_hours": round(delta_hours, 6),
            "method": "COULOMB_COUNTING"
        })

    return {
        "status": "COMPUTED",
        "method": "COULOMB_COUNTING",
        "initial_soc_pct": round(float(initial_soc_pct), 2),
        "final_soc_pct": round(current_soc, 2),
        "usable_capacity": usable_capacity,
        "capacity_unit": capacity_unit,
        "total_discharge_throughput": round(total_discharge, 4),
        "total_charge_throughput": round(total_charge, 4),
        "valid_points_integrated": valid_integration_points,
        "soc_series": soc_series,
        "chemistry_profile_id": chemistry_profile_id,
        "disclaimer": "Coulomb counting requires continuous non-drifting current integration. Cumulative drift error may increase over prolonged multi-hour intervals without resting OCV recalibration."
    }


def estimate_soc_from_resting_voltage(
    voltage_volts: Optional[float],
    current_amps: Optional[float] = None,
    chemistry_profile_id: str = "CHEM_NMC_01"
) -> Dict[str, Any]:
    """
    Estimate SOC from resting Open Circuit Voltage (OCV).
    Warns if current is flowing or if battery chemistry has a flat OCV plateau (e.g., LFP).
    """
    profile = get_profile(chemistry_profile_id)

    if voltage_volts is None:
        return {
            "status": "UNAVAILABLE",
            "message": "Voltage reading is missing. Cannot estimate SOC from OCV.",
            "estimated_soc_pct": None
        }

    # Rest check
    is_resting = True
    if current_amps is not None and abs(current_amps) > 0.05:
        is_resting = False

    soc = interpolate_soc_from_ocv(profile, voltage_volts)
    if soc is None:
        return {
            "status": "OUT_OF_BOUNDS",
            "message": f"Voltage {voltage_volts}V is outside the profile calibration range ({profile['cutoff_voltage']}V - {profile['max_charge_voltage']}V).",
            "estimated_soc_pct": None
        }

    plateau = profile.get("ocv_plateau_range")
    plateau_warning = None
    if plateau and plateau[0] <= soc <= plateau[1]:
        plateau_warning = f"Chemistry {profile['chemistry_name']} has a flat OCV plateau between {plateau[0]}% and {plateau[1]}% SOC. Voltage-based estimation has higher uncertainty in this band."

    return {
        "status": "ESTIMATED",
        "method": "RESTING_OCV_LOOKUP",
        "estimated_soc_pct": soc,
        "voltage_volts": voltage_volts,
        "is_confirmed_resting": is_resting,
        "plateau_warning": plateau_warning,
        "chemistry_profile_id": chemistry_profile_id
    }

