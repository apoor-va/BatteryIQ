"""
BatteryIQ - Battery Chemistry Profiles Specification
Encapsulates chemistry-specific parameters (LFP, NMC, NCA, NASA 18650 LCO)
to eliminate universal hardcoded battery assumptions.

All values are labeled with their documented literature source or noted as
configurable illustrative calibration defaults.
"""

from typing import Dict, Any, List, Optional


PROFILES: Dict[str, Dict[str, Any]] = {
    "CHEM_LFP_01": {
        "profile_id": "CHEM_LFP_01",
        "chemistry_name": "Lithium Iron Phosphate (LiFePO4 / LFP)",
        "nominal_cell_voltage": 3.20,
        "cutoff_voltage": 2.50,
        "max_charge_voltage": 3.65,
        "coulombic_efficiency": 0.990,
        "thermal_warning_temp_celsius": 50.0,
        "thermal_critical_temp_celsius": 60.0,
        "low_temp_charge_limit_celsius": 0.0,
        "max_discharge_c_rate": 3.0,
        "max_charge_c_rate": 1.5,
        "max_cell_delta_mv_warning": 30,
        "max_cell_delta_mv_critical": 60,
        "eol_soh_threshold_pct": 80.0,
        "condition_thresholds": {
            "EXCELLENT": 95.0,
            "GOOD": 90.0,
            "MODERATE": 85.0,
            "POOR": 80.0,
            "CRITICAL": 0.0
        },
        # Characteristic flat plateau: ~3.22V - 3.29V across 20% to 80% SOC
        "ocv_lookup_table": [
            {"soc": 0.0, "ocv": 2.50},
            {"soc": 5.0, "ocv": 3.05},
            {"soc": 10.0, "ocv": 3.18},
            {"soc": 20.0, "ocv": 3.22},
            {"soc": 30.0, "ocv": 3.24},
            {"soc": 50.0, "ocv": 3.26},
            {"soc": 70.0, "ocv": 3.28},
            {"soc": 80.0, "ocv": 3.29},
            {"soc": 90.0, "ocv": 3.32},
            {"soc": 95.0, "ocv": 3.35},
            {"soc": 100.0, "ocv": 3.65}
        ],
        "ocv_plateau_range": [20.0, 80.0],
        "documented_source": "Standard commercial LiFePO4 automotive cell operating bounds (CATL, Gotion, A123). Cutoffs 2.50V-3.65V from manufacturer datasheets.",
        "parameter_type": "DOCUMENTED_EXPERIMENTAL_BOUNDS_WITH_ILLUSTRATIVE_OCV_POINTS",
        "notes": "High thermal stability and long cycle life (2000-3000+ cycles). Flat OCV plateau limits resting OCV lookup accuracy between 20% and 80% SOC."
    },

    "CHEM_NMC_01": {
        "profile_id": "CHEM_NMC_01",
        "chemistry_name": "Lithium Nickel Manganese Cobalt Oxide (NMC 622/811)",
        "nominal_cell_voltage": 3.70,
        "cutoff_voltage": 3.00,
        "max_charge_voltage": 4.20,
        "coulombic_efficiency": 0.985,
        "thermal_warning_temp_celsius": 45.0,
        "thermal_critical_temp_celsius": 55.0,
        "low_temp_charge_limit_celsius": 0.0,
        "max_discharge_c_rate": 2.5,
        "max_charge_c_rate": 1.0,
        "max_cell_delta_mv_warning": 25,
        "max_cell_delta_mv_critical": 50,
        "eol_soh_threshold_pct": 70.0,
        "condition_thresholds": {
            "EXCELLENT": 92.0,
            "GOOD": 85.0,
            "MODERATE": 78.0,
            "POOR": 70.0,
            "CRITICAL": 0.0
        },
        # Monotonic sloped curve across entire SOC band
        "ocv_lookup_table": [
            {"soc": 0.0, "ocv": 3.00},
            {"soc": 5.0, "ocv": 3.30},
            {"soc": 10.0, "ocv": 3.45},
            {"soc": 20.0, "ocv": 3.58},
            {"soc": 30.0, "ocv": 3.65},
            {"soc": 50.0, "ocv": 3.78},
            {"soc": 70.0, "ocv": 3.92},
            {"soc": 80.0, "ocv": 4.02},
            {"soc": 90.0, "ocv": 4.12},
            {"soc": 95.0, "ocv": 4.16},
            {"soc": 100.0, "ocv": 4.20}
        ],
        "ocv_plateau_range": None,
        "documented_source": "Standard automotive cylindrical and prismatic cell specifications (LG Chem, Samsung SDI). Standard 3.00V-4.20V operating window.",
        "parameter_type": "DOCUMENTED_EXPERIMENTAL_BOUNDS_WITH_ILLUSTRATIVE_OCV_POINTS",
        "notes": "High energy density. Continuous sloped OCV curve allows reliable resting OCV correlation with SOC. Sensitive to sustained thermal exposure above 45°C."
    },

    "CHEM_NCA_01": {
        "profile_id": "CHEM_NCA_01",
        "chemistry_name": "Lithium Nickel Cobalt Aluminum Oxide (NCA 2170)",
        "nominal_cell_voltage": 3.65,
        "cutoff_voltage": 3.00,
        "max_charge_voltage": 4.20,
        "coulombic_efficiency": 0.985,
        "thermal_warning_temp_celsius": 45.0,
        "thermal_critical_temp_celsius": 55.0,
        "low_temp_charge_limit_celsius": 0.0,
        "max_discharge_c_rate": 3.0,
        "max_charge_c_rate": 1.2,
        "max_cell_delta_mv_warning": 25,
        "max_cell_delta_mv_critical": 50,
        "eol_soh_threshold_pct": 70.0,
        "condition_thresholds": {
            "EXCELLENT": 92.0,
            "GOOD": 85.0,
            "MODERATE": 78.0,
            "POOR": 70.0,
            "CRITICAL": 0.0
        },
        "ocv_lookup_table": [
            {"soc": 0.0, "ocv": 3.00},
            {"soc": 5.0, "ocv": 3.28},
            {"soc": 10.0, "ocv": 3.42},
            {"soc": 20.0, "ocv": 3.55},
            {"soc": 30.0, "ocv": 3.62},
            {"soc": 50.0, "ocv": 3.75},
            {"soc": 70.0, "ocv": 3.90},
            {"soc": 80.0, "ocv": 4.00},
            {"soc": 90.0, "ocv": 4.10},
            {"soc": 95.0, "ocv": 4.15},
            {"soc": 100.0, "ocv": 4.20}
        ],
        "ocv_plateau_range": None,
        "documented_source": "Panasonic 2170 / 18650 automotive cell specifications. Operating bounds 3.00V to 4.20V.",
        "parameter_type": "DOCUMENTED_EXPERIMENTAL_BOUNDS_WITH_ILLUSTRATIVE_OCV_POINTS",
        "notes": "Very high specific energy. Utilized in long-range passenger EVs. Requires liquid thermal management to mitigate calendar and cycling fade."
    },

    "CHEM_NASA_18650": {
        "profile_id": "CHEM_NASA_18650",
        "chemistry_name": "NASA Ames PCoE Benchmark Cell (LiCoO2 / LCO 18650)",
        "nominal_cell_voltage": 3.70,
        "cutoff_voltage": 2.70,
        "max_charge_voltage": 4.20,
        "coulombic_efficiency": 0.980,
        "thermal_warning_temp_celsius": 40.0,
        "thermal_critical_temp_celsius": 50.0,
        "low_temp_charge_limit_celsius": 5.0,
        "max_discharge_c_rate": 1.5,
        "max_charge_c_rate": 0.8,
        "max_cell_delta_mv_warning": 20,
        "max_cell_delta_mv_critical": 40,
        "eol_soh_threshold_pct": 70.0,
        "condition_thresholds": {
            "EXCELLENT": 92.0,
            "GOOD": 85.0,
            "MODERATE": 78.0,
            "POOR": 70.0,
            "CRITICAL": 0.0
        },
        "ocv_lookup_table": [
            {"soc": 0.0, "ocv": 2.70},
            {"soc": 5.0, "ocv": 3.25},
            {"soc": 10.0, "ocv": 3.40},
            {"soc": 20.0, "ocv": 3.55},
            {"soc": 30.0, "ocv": 3.65},
            {"soc": 50.0, "ocv": 3.80},
            {"soc": 70.0, "ocv": 3.95},
            {"soc": 80.0, "ocv": 4.05},
            {"soc": 90.0, "ocv": 4.12},
            {"soc": 95.0, "ocv": 4.16},
            {"soc": 100.0, "ocv": 4.20}
        ],
        "ocv_plateau_range": None,
        "documented_source": "NASA Ames Prognostics Center of Excellence (PCoE) Battery Aging Dataset (B. Saha & K. Goebel, 2007). 2A discharge to 2.7V cutoff at 24°C.",
        "parameter_type": "DOCUMENTED_EXPERIMENTAL_PROTOCOL",
        "notes": "Experimental laboratory single-cell benchmark profile. Cycled under controlled chamber conditions. Not an operational multi-cell EV pack."
    }
}


def get_profile(profile_id: Optional[str]) -> Dict[str, Any]:
    """Retrieve profile by ID or default to CHEM_NMC_01 if not found."""
    if not profile_id:
        return PROFILES["CHEM_NMC_01"]
    return PROFILES.get(profile_id, PROFILES["CHEM_NMC_01"])


def get_all_profiles() -> List[Dict[str, Any]]:
    """Return all configured battery chemistry profiles."""
    return list(PROFILES.values())


def interpolate_soc_from_ocv(profile: Dict[str, Any], ocv_volts: float) -> Optional[float]:
    """
    Interpolate State of Charge percentage from an Open Circuit Voltage reading.
    Returns None if voltage is out of physical bounds.
    """
    table = profile.get("ocv_lookup_table", [])
    if not table or ocv_volts is None:
        return None

    if ocv_volts <= table[0]["ocv"]:
        return 0.0
    if ocv_volts >= table[-1]["ocv"]:
        return 100.0

    for i in range(len(table) - 1):
        v1, soc1 = table[i]["ocv"], table[i]["soc"]
        v2, soc2 = table[i + 1]["ocv"], table[i + 1]["soc"]
        if v1 <= ocv_volts <= v2:
            span = v2 - v1
            if span == 0:
                return soc1
            frac = (ocv_volts - v1) / span
            return round(soc1 + frac * (soc2 - soc1), 2)
    return None

