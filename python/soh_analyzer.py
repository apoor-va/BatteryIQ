"""
BatteryIQ - State of Health (SOH) and Degradation Analysis Module
Implements capacity-based SOH estimation using consistently anchored reference capacities.
Supports both Rated Nominal (nameplate) and Fresh Measured Baseline (Cycle 1) references.
Classifies battery condition against chemistry-specific thresholds.
"""

from typing import Dict, Any, Optional
from chemistry_profiles import get_profile


def analyze_soh_and_degradation(
    current_measured_capacity: Optional[float],
    nominal_capacity: Optional[float],
    fresh_baseline_capacity: Optional[float] = None,
    active_reference_type: str = "RATED_NOMINAL",
    capacity_unit: str = "KWH",
    chemistry_profile_id: str = "CHEM_NMC_01"
) -> Dict[str, Any]:
    """
    Calculate SOH percentage, degradation rate, and condition category.
    Clearly documents the reference capacity selected and chemistry assumptions.
    """
    profile = get_profile(chemistry_profile_id)
    ref_type = str(active_reference_type).upper()

    # Determine reference capacity
    if ref_type == "FRESH_BASELINE" and fresh_baseline_capacity is not None and fresh_baseline_capacity > 0:
        ref_capacity = float(fresh_baseline_capacity)
        ref_label = f"Fresh-Cell Measured Baseline ({ref_capacity} {capacity_unit})"
    elif nominal_capacity is not None and nominal_capacity > 0:
        ref_capacity = float(nominal_capacity)
        ref_label = f"Manufacturer Rated Nominal Nameplate ({ref_capacity} {capacity_unit})"
        ref_type = "RATED_NOMINAL"
    else:
        return {
            "status": "UNAVAILABLE",
            "message": "Valid reference capacity (nominal or fresh baseline) is required for SOH calculation.",
            "soh_percentage": None,
            "degradation_percentage": None,
            "condition_category": "UNAVAILABLE",
            "active_reference_type": ref_type,
            "reference_capacity_value": None,
            "capacity_unit": capacity_unit
        }

    if current_measured_capacity is None or current_measured_capacity <= 0:
        return {
            "status": "UNAVAILABLE",
            "message": "Current usable measured capacity is missing. SOH cannot be calculated without current physical measurements.",
            "soh_percentage": None,
            "degradation_percentage": None,
            "condition_category": "UNAVAILABLE",
            "active_reference_type": ref_type,
            "reference_capacity_value": ref_capacity,
            "capacity_unit": capacity_unit
        }

    # SOH Calculation: (C_current / C_reference) * 100%
    soh_pct = (current_measured_capacity / ref_capacity) * 100.0
    soh_pct = round(soh_pct, 2)

    # Degradation Calculation: ((C_reference - C_current) / C_reference) * 100%
    degradation_pct = max(0.0, round(100.0 - soh_pct, 2))

    # Condition Categorization using active chemistry profile thresholds
    thresholds = profile.get("condition_thresholds", {
        "EXCELLENT": 92.0,
        "GOOD": 85.0,
        "MODERATE": 78.0,
        "POOR": 70.0,
        "CRITICAL": 0.0
    })

    if soh_pct >= thresholds.get("EXCELLENT", 92.0):
        condition = "EXCELLENT"
    elif soh_pct >= thresholds.get("GOOD", 85.0):
        condition = "GOOD"
    elif soh_pct >= thresholds.get("MODERATE", 78.0):
        condition = "MODERATE"
    elif soh_pct >= thresholds.get("POOR", 70.0):
        condition = "POOR"
    else:
        condition = "CRITICAL"

    eol_threshold = profile.get("eol_soh_threshold_pct", 70.0)
    is_eol_reached = soh_pct <= eol_threshold

    return {
        "status": "COMPUTED",
        "soh_percentage": soh_pct,
        "degradation_percentage": degradation_pct,
        "condition_category": condition,
        "active_reference_type": ref_type,
        "reference_capacity_label": ref_label,
        "reference_capacity_value": ref_capacity,
        "current_measured_capacity": current_measured_capacity,
        "capacity_unit": capacity_unit,
        "chemistry_profile_id": chemistry_profile_id,
        "chemistry_name": profile["chemistry_name"],
        "eol_threshold_pct": eol_threshold,
        "is_eol_reached": is_eol_reached,
        "calculation_steps": [
            f"1. Identified active reference capacity: {ref_capacity} {capacity_unit} ({ref_label}).",
            f"2. Current usable capacity from discharge test: {current_measured_capacity} {capacity_unit}.",
            f"3. SOH = ({current_measured_capacity} / {ref_capacity}) * 100% = {soh_pct}%.",
            f"4. Total degradation fade = {degradation_pct}%.",
            f"5. Categorized as '{condition}' based on {profile['chemistry_name']} thresholds."
        ],
        "assumptions": [
            "Assumes discharge capacity was measured down to chemistry standard cutoff voltage.",
            "Capacity values should be normalized to standard 25°C ambient temperature.",
            "Coulombic retention reflects usable energy under moderate discharge rates (C/3 or C/2)."
        ]
    }

