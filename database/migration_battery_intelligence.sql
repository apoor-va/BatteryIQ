-- ==============================================================================
-- BatteryIQ - Non-Destructive Database Migration: Battery Intelligence Subsystem
-- Database Engine: MySQL 8.x / 5.7+
-- Target Compatibility: Apache Tomcat 9 / Java Servlets / JSP
-- Safe Migration: Uses CREATE TABLE IF NOT EXISTS and non-destructive inserts.
-- Preserves all existing tables: vehicles, users, health_reports, inquiries.
-- ==============================================================================

USE batteryiq_db;

-- ------------------------------------------------------------------------------
-- 1. Battery Chemistry Profiles (Configurable electrochemical parameters)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS battery_chemistry_profiles (
    profile_id VARCHAR(40) PRIMARY KEY,
    chemistry_name VARCHAR(60) NOT NULL,
    nominal_cell_voltage DECIMAL(4,2) NOT NULL,
    cutoff_voltage DECIMAL(4,2) NOT NULL,
    max_charge_voltage DECIMAL(4,2) NOT NULL,
    coulombic_efficiency DECIMAL(4,3) NOT NULL DEFAULT 0.985,
    thermal_warning_temp_celsius DECIMAL(4,1) NOT NULL DEFAULT 45.0,
    thermal_critical_temp_celsius DECIMAL(4,1) NOT NULL DEFAULT 55.0,
    eol_soh_threshold_pct DECIMAL(4,1) NOT NULL DEFAULT 70.0,
    ocv_lookup_table_json TEXT NOT NULL,
    profile_notes TEXT
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 2. Battery Telemetry Sessions (Supports Ah & kWh, Nullable Sensors, Consistent Reference)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS battery_telemetry_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NULL,
    session_uuid VARCHAR(64) NOT NULL UNIQUE,
    source_type ENUM('PUBLIC_DATASET', 'SIMULATOR', 'LIVE_OBD') NOT NULL,
    dataset_name VARCHAR(100),
    cell_or_pack_identifier VARCHAR(60) NOT NULL,
    chemistry_profile_id VARCHAR(40) NOT NULL,
    
    -- Dual Unit Capacity Support (Ah for cells, kWh for EV packs)
    nominal_capacity_value DECIMAL(8,3) NOT NULL,
    fresh_baseline_capacity_value DECIMAL(8,3) NULL,
    current_measured_capacity_value DECIMAL(8,3) NULL,
    capacity_unit ENUM('AH', 'KWH') NOT NULL,
    active_reference_type ENUM('RATED_NOMINAL', 'FRESH_BASELINE') NOT NULL DEFAULT 'RATED_NOMINAL',
    
    -- Telemetry & Analysis Summary
    initial_soc_pct DECIMAL(4,1) NULL,
    soc_estimation_method ENUM('COULOMB_COUNTING', 'OCV_REST_LOOKUP', 'BMS_CAN_REPORTED', 'UNAVAILABLE') NOT NULL DEFAULT 'UNAVAILABLE',
    estimated_soh_pct DECIMAL(4,1) NULL,
    estimated_rul_cycles INT NULL,
    condition_category ENUM('EXCELLENT', 'GOOD', 'MODERATE', 'POOR', 'CRITICAL', 'UNAVAILABLE') NOT NULL DEFAULT 'UNAVAILABLE',
    
    -- Independent Verification Separation (Live data is NOT auto-verified)
    telemetry_status ENUM('RAW_STREAMING', 'PROCESSED_CLEAN', 'PROCESSED_WITH_ANOMALIES', 'INSUFFICIENT_TELEMETRY') NOT NULL DEFAULT 'RAW_STREAMING',
    verification_status ENUM('UNVERIFIED_DEMO', 'UNVERIFIED_DATASET', 'UNVERIFIED_LIVE_TELEMETRY', 'PHYSICALLY_VERIFIED') NOT NULL DEFAULT 'UNVERIFIED_DEMO',
    
    hardware_adapter_used VARCHAR(80) NULL,
    protocol_target_profile VARCHAR(80) NULL,
    is_hardware_physically_validated BOOLEAN DEFAULT FALSE,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_session_vehicle (vehicle_id),
    INDEX idx_session_source (source_type),
    INDEX idx_session_recorded (recorded_at),
    CONSTRAINT fk_session_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE SET NULL,
    CONSTRAINT fk_session_chem FOREIGN KEY (chemistry_profile_id) REFERENCES battery_chemistry_profiles(profile_id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 3. Time-Series Telemetry Data Points (Strictly Nullable Sensor Readings - No Invented Zeros)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS battery_timeseries_readings (
    reading_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    timestamp_offset_ms BIGINT NOT NULL,
    voltage_volts DECIMAL(6,3) NULL,
    current_amps DECIMAL(6,3) NULL,
    temperature_celsius DECIMAL(4,1) NULL,
    soc_percentage DECIMAL(4,1) NULL,
    cell_delta_mv INT NULL,
    active_power_kw DECIMAL(6,2) NULL,
    c_rate DECIMAL(4,2) NULL,
    has_anomaly BOOLEAN DEFAULT FALSE,
    anomaly_description VARCHAR(150) NULL,
    INDEX idx_readings_session (session_id),
    INDEX idx_readings_session_time (session_id, timestamp_offset_ms),
    CONSTRAINT fk_readings_session FOREIGN KEY (session_id) REFERENCES battery_telemetry_sessions(session_id) ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 4. Public Dataset Experiments & Cycle Records
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dataset_battery_experiments (
    experiment_id INT AUTO_INCREMENT PRIMARY KEY,
    dataset_source VARCHAR(60) NOT NULL, -- e.g. 'NASA_PCOE', 'CALCE'
    cell_id VARCHAR(40) NOT NULL,
    split_role ENUM('TRAIN', 'TEST', 'VALIDATION') NOT NULL,
    chemistry_profile_id VARCHAR(40) NOT NULL,
    nominal_capacity_ah DECIMAL(5,3) NOT NULL,
    initial_measured_capacity_ah DECIMAL(5,3) NOT NULL,
    total_recorded_cycles INT NOT NULL,
    eol_cycle_reached INT NULL,
    ambient_temp_celsius DECIMAL(4,1) NOT NULL,
    dataset_description TEXT,
    cycle_data_json MEDIUMTEXT NOT NULL,
    UNIQUE KEY uq_dataset_cell (dataset_source, cell_id),
    INDEX idx_dataset_split (split_role),
    CONSTRAINT fk_dataset_chem FOREIGN KEY (chemistry_profile_id) REFERENCES battery_chemistry_profiles(profile_id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 5. ML Model Registry with Strict Cell Split & Academic Disclosures
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ml_model_registry (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(80) NOT NULL,
    algorithm_type VARCHAR(60) NOT NULL,
    train_cells VARCHAR(120) NOT NULL, -- e.g. 'NASA_B0005, NASA_B0006'
    test_cells VARCHAR(120) NOT NULL,  -- e.g. 'NASA_B0007, NASA_B0018' (Holdout test)
    training_date DATE NOT NULL,
    mae_cycles DECIMAL(6,2) NOT NULL,
    rmse_cycles DECIMAL(6,2) NOT NULL,
    r2_score DECIMAL(5,4) NOT NULL,
    eol_threshold_pct DECIMAL(4,1) DEFAULT 70.0,
    academic_disclosure_notice TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_ml_model_active (is_active)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- Seed Verified Battery Chemistry Profiles (Scientifically Supported Specifications)
-- ------------------------------------------------------------------------------
INSERT INTO battery_chemistry_profiles (
    profile_id, chemistry_name, nominal_cell_voltage, cutoff_voltage, max_charge_voltage,
    coulombic_efficiency, thermal_warning_temp_celsius, thermal_critical_temp_celsius,
    eol_soh_threshold_pct, ocv_lookup_table_json, profile_notes
) VALUES
(
    'CHEM_LFP_01',
    'Lithium Iron Phosphate (LiFePO4 / LFP)',
    3.20,
    2.50,
    3.65,
    0.990,
    50.0,
    60.0,
    80.0,
    '[{"soc":0,"ocv":2.50},{"soc":5,"ocv":3.05},{"soc":10,"ocv":3.18},{"soc":20,"ocv":3.22},{"soc":30,"ocv":3.24},{"soc":50,"ocv":3.26},{"soc":70,"ocv":3.28},{"soc":80,"ocv":3.29},{"soc":90,"ocv":3.32},{"soc":95,"ocv":3.35},{"soc":100,"ocv":3.65}]',
    'High thermal stability and long cycle life (2000-3000+ cycles). Flat OCV plateau between 20% and 80% SOC limits resting OCV lookup accuracy to low and high boundaries.'
),
(
    'CHEM_NMC_01',
    'Lithium Nickel Manganese Cobalt Oxide (NMC 622/811)',
    3.70,
    3.00,
    4.20,
    0.985,
    45.0,
    55.0,
    70.0,
    '[{"soc":0,"ocv":3.00},{"soc":5,"ocv":3.30},{"soc":10,"ocv":3.45},{"soc":20,"ocv":3.58},{"soc":30,"ocv":3.65},{"soc":50,"ocv":3.78},{"soc":70,"ocv":3.92},{"soc":80,"ocv":4.02},{"soc":90,"ocv":4.12},{"soc":95,"ocv":4.16},{"soc":100,"ocv":4.20}]',
    'High energy density automotive chemistry. Sloped monotonic OCV curve provides reliable correlation with SOC under resting conditions. Sensitive to continuous temperatures above 45°C.'
),
(
    'CHEM_NCA_01',
    'Lithium Nickel Cobalt Aluminum Oxide (NCA 2170/18650)',
    3.65,
    3.00,
    4.20,
    0.985,
    45.0,
    55.0,
    70.0,
    '[{"soc":0,"ocv":3.00},{"soc":5,"ocv":3.28},{"soc":10,"ocv":3.42},{"soc":20,"ocv":3.55},{"soc":30,"ocv":3.62},{"soc":50,"ocv":3.75},{"soc":70,"ocv":3.90},{"soc":80,"ocv":4.00},{"soc":90,"ocv":4.10},{"soc":95,"ocv":4.15},{"soc":100,"ocv":4.20}]',
    'High specific energy chemistry utilized in long-range passenger EVs. Requires active thermal management during high C-rate fast charging to minimize calendar fade.'
),
(
    'CHEM_NASA_18650',
    'NASA PCoE Benchmark Cell (LiCoO2 / LCO 18650)',
    3.70,
    2.70,
    4.20,
    0.980,
    40.0,
    50.0,
    70.0,
    '[{"soc":0,"ocv":2.70},{"soc":5,"ocv":3.25},{"soc":10,"ocv":3.40},{"soc":20,"ocv":3.55},{"soc":30,"ocv":3.65},{"soc":50,"ocv":3.80},{"soc":70,"ocv":3.95},{"soc":80,"ocv":4.05},{"soc":90,"ocv":4.12},{"soc":95,"ocv":4.16},{"soc":100,"ocv":4.20}]',
    'Experimental benchmark laboratory single-cell profile from NASA Ames Prognostics Center of Excellence (PCoE). Cycled under 2A discharge at 24°C chamber. Not an operational EV pack.'
)
ON DUPLICATE KEY UPDATE
    chemistry_name = VALUES(chemistry_name),
    nominal_cell_voltage = VALUES(nominal_cell_voltage),
    cutoff_voltage = VALUES(cutoff_voltage),
    max_charge_voltage = VALUES(max_charge_voltage),
    coulombic_efficiency = VALUES(coulombic_efficiency),
    thermal_warning_temp_celsius = VALUES(thermal_warning_temp_celsius),
    thermal_critical_temp_celsius = VALUES(thermal_critical_temp_celsius),
    eol_soh_threshold_pct = VALUES(eol_soh_threshold_pct),
    ocv_lookup_table_json = VALUES(ocv_lookup_table_json),
    profile_notes = VALUES(profile_notes);

