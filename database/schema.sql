-- ==============================================================================
-- BatteryIQ - Database Schema & Demo Seed Data
-- Database Engine: MySQL 8.x / 5.7+
-- Target Platform: Apache Tomcat 9 / Java Servlets / JSP
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS batteryiq_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE batteryiq_db;

-- Drop tables in reverse foreign key order if re-initializing
DROP TABLE IF EXISTS inquiries;
DROP TABLE IF EXISTS health_reports;
DROP TABLE IF EXISTS battery_reports;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS users;

-- ------------------------------------------------------------------------------
-- 1. Users Table (Buyers, Private Sellers, Certified Dealers, Admins)
-- ------------------------------------------------------------------------------
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('BUYER', 'SELLER', 'DEALER', 'ADMIN', 'VERIFIER') DEFAULT 'BUYER',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 2. Vehicles Table (Automotive Marketplace: Cars, Bikes & Scooters; Petrol, Diesel, Electric; New & Used)
-- ------------------------------------------------------------------------------
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    variant_trim VARCHAR(60),
    manufacturing_year INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    odometer_km INT NOT NULL DEFAULT 0,
    
    -- Category, Fuel & Condition
    category ENUM('CAR', 'BIKE', 'SCOOTER') NOT NULL DEFAULT 'CAR',
    fuel_type ENUM('PETROL', 'DIESEL', 'ELECTRIC') NOT NULL DEFAULT 'ELECTRIC',
    condition_type ENUM('NEW', 'USED') NOT NULL DEFAULT 'USED',
    body_type VARCHAR(50) DEFAULT 'Sedan',
    transmission VARCHAR(40) DEFAULT 'Automatic',
    
    -- Engine Performance (Petrol / Diesel ICE)
    engine_displacement_cc INT DEFAULT 0,
    mileage_kmpl DECIMAL(4,1) DEFAULT 0.0,
    max_power_bhp INT DEFAULT 0,
    seating_capacity INT DEFAULT 5,
    owner_count INT DEFAULT 1,
    
    -- EV Specific Performance
    battery_pack_kwh DECIMAL(5,2) DEFAULT 0.0,
    original_wltp_range_km INT DEFAULT 0,
    fast_charging_kw INT DEFAULT 0,
    drivetrain VARCHAR(30) DEFAULT 'AWD',
    
    exterior_color VARCHAR(30),
    location_city VARCHAR(60) NOT NULL,
    status ENUM('AVAILABLE', 'RESERVED', 'SOLD') DEFAULT 'AVAILABLE',
    is_battery_verified BOOLEAN DEFAULT TRUE,
    thumbnail_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_seller FOREIGN KEY (seller_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 3. Comprehensive Health Reports Table (EV Telematics + ICE Mechanical)
-- ------------------------------------------------------------------------------
CREATE TABLE health_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL UNIQUE,
    certificate_code VARCHAR(32) NOT NULL UNIQUE,
    report_type ENUM('EV_BATTERY', 'ICE_ENGINE') NOT NULL,
    overall_grade VARCHAR(20) NOT NULL,
    overall_score INT NOT NULL DEFAULT 0,
    is_certified BOOLEAN DEFAULT TRUE,
    verified_date DATE,
    verified_by_inspector VARCHAR(120),
    inspector_notes TEXT,

    -- EV Specific
    soh_percentage DECIMAL(4,1),
    usable_capacity_kwh DECIMAL(5,2),
    original_capacity_kwh DECIMAL(5,2),
    estimated_real_range_km INT,
    original_range_km INT,
    cycle_count INT,
    cell_deviation_mv INT,
    fast_charge_ratio_pct DECIMAL(4,1),
    thermal_stress_grade VARCHAR(30),
    degradation_rate_per_year DECIMAL(3,2),
    charging_health_summary TEXT,

    -- ICE (Petrol/Diesel) Specific
    engine_health_score INT,
    odometer_status ENUM('VERIFIED', 'UNVERIFIED', 'MISSING', 'PENDING_INSPECTION') DEFAULT 'MISSING',
    odometer_tampering_suspected BOOLEAN DEFAULT FALSE,
    compression_test_result VARCHAR(150),
    compression_status ENUM('VERIFIED', 'UNVERIFIED', 'MISSING', 'PENDING_INSPECTION') DEFAULT 'MISSING',
    oil_condition_grade VARCHAR(40),
    service_history_status ENUM('VERIFIED', 'UNVERIFIED', 'MISSING', 'PENDING_INSPECTION') DEFAULT 'MISSING',
    documented_service_count INT DEFAULT 0,
    obd_scan_status ENUM('VERIFIED', 'UNVERIFIED', 'MISSING', 'PENDING_INSPECTION') DEFAULT 'MISSING',
    transmission_condition VARCHAR(40),
    exhaust_emission_grade VARCHAR(40),
    cooling_system_health VARCHAR(150),
    chassis_suspension_grade VARCHAR(40),

    -- Diesel Specific
    dpf_status VARCHAR(60),
    dpf_soot_load_grams DECIMAL(5,2),
    dpf_evidence_status ENUM('VERIFIED', 'UNVERIFIED', 'MISSING', 'PENDING_INSPECTION') DEFAULT 'MISSING',
    common_rail_pressure_bar INT,
    adblue_def_status VARCHAR(60),
    glow_plug_status VARCHAR(80),

    -- Petrol Specific
    spark_plug_condition VARCHAR(60),
    catalytic_converter_o2_status VARCHAR(60),

    -- 2-Wheeler Specific
    two_wheeler_drive_type VARCHAR(40),
    two_wheeler_drive_condition VARCHAR(30),
    two_wheeler_clutch_or_belt VARCHAR(150),
    is_removable_battery BOOLEAN DEFAULT FALSE,
    battery_locker_condition VARCHAR(120),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_health_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Legacy battery_reports table kept for backward compatibility with older queries
CREATE TABLE battery_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL UNIQUE,
    certificate_code VARCHAR(32) NOT NULL UNIQUE,
    soh_percentage DECIMAL(4,1) NOT NULL,
    usable_capacity_kwh DECIMAL(5,2) NOT NULL,
    estimated_real_range_km INT NOT NULL,
    cycle_count INT NOT NULL,
    cell_deviation_mv INT NOT NULL,
    fast_charge_ratio_pct DECIMAL(4,1),
    thermal_stress_grade ENUM('EXCELLENT', 'GOOD', 'MODERATE', 'ATTENTION_NEEDED') DEFAULT 'EXCELLENT',
    degradation_rate_per_year DECIMAL(3,2),
    overall_grade VARCHAR(5) NOT NULL,
    verified_date DATE NOT NULL,
    verified_by_inspector VARCHAR(100) DEFAULT 'BatteryIQ Telematics Diagnostic Lab',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_report_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 4. Vehicle Inquiries / Test Drive Requests Table
-- ------------------------------------------------------------------------------
CREATE TABLE inquiries (
    inquiry_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    user_id INT,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(120) NOT NULL,
    customer_phone VARCHAR(20),
    message TEXT,
    preferred_date DATE,
    status ENUM('PENDING', 'CONTACTED', 'SCHEDULED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inquiry_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    CONSTRAINT fk_inquiry_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==============================================================================
-- FICTIONAL DEMO SEED DATA (Clearly marked as DEMO DATA)
-- Covers Cars, Bikes, Scooters across Petrol, Diesel, Electric; New & Used.
-- ==============================================================================

INSERT INTO users (user_id, full_name, email, password_hash, phone, role, is_verified) VALUES
(1, 'BatteryIQ Certified Dealership', 'dealer@batteryiq.demo', 'demo_hash_123', '+1 800-555-0199', 'DEALER', TRUE),
(2, 'Alex Henderson', 'alex.h@batteryiq.demo', 'demo_hash_456', '+1 555-019-8842', 'SELLER', TRUE),
(3, 'BatteryIQ Diagnostic Center', 'verifier@batteryiq.demo', 'demo_hash_789', '+1 555-019-9900', 'VERIFIER', TRUE);

-- Insert sample vehicles (DEMO DATA)
INSERT INTO vehicles (vehicle_id, seller_id, make, model, variant_trim, manufacturing_year, price, odometer_km, category, fuel_type, condition_type, body_type, transmission, engine_displacement_cc, mileage_kmpl, battery_pack_kwh, original_wltp_range_km, fast_charging_kw, drivetrain, exterior_color, location_city, status, is_battery_verified, thumbnail_url) VALUES
-- Cars
(1, 1, 'Tesla', 'Model 3', 'Long Range Dual Motor', 2022, 34800.00, 28500, 'CAR', 'ELECTRIC', 'USED', 'Sedan', 'Single-Speed', 0, 0.0, 75.0, 580, 250, 'AWD', 'Pearl White', 'San Francisco, CA', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=80'),
(2, 2, 'Porsche', 'Taycan', '4S Performance Battery Plus', 2021, 68500.00, 31200, 'CAR', 'ELECTRIC', 'USED', 'Sedan', '2-Speed Automatic', 0, 0.0, 93.4, 512, 270, 'AWD', 'Frozen Blue Metallic', 'Austin, TX', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=80'),
(3, 1, 'Rivian', 'R1S', 'Adventure Quad-Motor', 2024, 89900.00, 0, 'CAR', 'ELECTRIC', 'NEW', 'SUV', 'Quad-Drive', 0, 0.0, 135.0, 516, 220, 'AWD', 'Glacier White', 'Denver, CO', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1662581872277-0fd0bf3ae8f6?auto=format&fit=crop&w=1200&q=80'),
(4, 1, 'BMW', '3 Series', '330i M Sport', 2022, 39500.00, 29500, 'CAR', 'PETROL', 'USED', 'Sedan', '8-Speed Steptronic', 1998, 15.3, 0.0, 0, 0, 'RWD', 'Portimao Blue', 'Chicago, IL', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1200&q=80'),
(5, 2, 'Honda', 'Civic', 'Sport 1.5L Turbo', 2021, 22800.00, 38200, 'CAR', 'PETROL', 'USED', 'Sedan', 'CVT Automatic', 1498, 16.5, 0.0, 0, 0, 'FWD', 'Rallye Red', 'Dallas, TX', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=1200&q=80'),
(6, 1, 'Audi', 'Q7', '3.0 TDI Quattro V6', 2020, 41500.00, 64000, 'CAR', 'DIESEL', 'USED', 'SUV', '8-Speed Tiptronic', 2967, 13.8, 0.0, 0, 0, 'AWD', 'Daytona Gray', 'Seattle, WA', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1541348263662-e0c8de4259ba?auto=format&fit=crop&w=1200&q=80'),
(7, 1, 'Mercedes-Benz', 'GLE', '300d 4MATIC AMG Line', 2024, 78200.00, 0, 'CAR', 'DIESEL', 'NEW', 'SUV', '9G-TRONIC', 1993, 14.9, 0.0, 0, 0, 'AWD', 'Obsidian Black', 'Atlanta, GA', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=1200&q=80'),

-- Bikes
(8, 2, 'Zero', 'SR/F', 'Premium 14.4 kWh', 2022, 16400.00, 9200, 'BIKE', 'ELECTRIC', 'USED', 'Streetfighter', 'Direct Drive', 0, 0.0, 14.4, 220, 12, 'Belt', 'Daytona Red', 'San Diego, CA', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=80'),
(9, 1, 'Royal Enfield', 'Hunter 350', 'Dapper Ash Dual Tone', 2023, 4200.00, 11800, 'BIKE', 'PETROL', 'USED', 'Roadster', '5-Speed Manual', 349, 36.2, 0.0, 0, 0, 'Chain', 'Dapper Ash', 'Miami, FL', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=80'),
(10, 1, 'Yamaha', 'YZF-R7', 'Team Yamaha Blue', 2024, 9199.00, 0, 'BIKE', 'PETROL', 'NEW', 'Sport', '6-Speed Manual', 689, 23.5, 0.0, 0, 0, 'Chain', 'Icon Blue', 'Houston, TX', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1558981420-87aa92103444?auto=format&fit=crop&w=1200&q=80'),

-- Scooters
(11, 2, 'Ola', 'S1 Pro', 'Gen 2 4.0 kWh', 2023, 1850.00, 6800, 'SCOOTER', 'ELECTRIC', 'USED', 'Scooter', 'Mid-Drive', 0, 0.0, 4.0, 195, 3, 'Belt', 'Jet Black', 'Phoenix, AZ', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=1200&q=80'),
(12, 1, 'Gogoro', 'CrossOver', 'Smartscooter Adventure AWD', 2024, 2499.00, 0, 'SCOOTER', 'ELECTRIC', 'NEW', 'Scooter', 'Direct Drive', 0, 0.0, 3.4, 150, 0, 'Belt', 'Desert Sand', 'San Jose, CA', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=80'),
(13, 2, 'Honda', 'Activa', '6G Deluxe Smart Key', 2022, 1150.00, 14200, 'SCOOTER', 'PETROL', 'USED', 'Scooter', 'V-Matic CVT', 109, 52.0, 0.0, 0, 0, 'CVT', 'Pearl Blue', 'San Jose, CA', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=1200&q=80'),
(14, 1, 'Vespa', 'Primavera', '150 i-get ABS Touring', 2023, 4850.00, 4200, 'SCOOTER', 'PETROL', 'USED', 'Scooter', 'Automatic CVT', 155, 40.0, 0.0, 0, 0, 'CVT', 'Verde Relax Green', 'Sacramento, CA', 'AVAILABLE', TRUE, 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=80');

-- Insert comprehensive health reports into health_reports
INSERT INTO health_reports (vehicle_id, certificate_code, report_type, overall_grade, overall_score, is_certified, verified_date, verified_by_inspector, inspector_notes, soh_percentage, usable_capacity_kwh, original_capacity_kwh, estimated_real_range_km, original_range_km, cycle_count, cell_deviation_mv, fast_charge_ratio_pct, thermal_stress_grade, degradation_rate_per_year, charging_health_summary) VALUES
(1, 'BIQ-2024-T3LR-9721', 'EV_BATTERY', 'A+', 97, TRUE, '2024-10-15', 'BatteryIQ Certified Telematics Lab (San Francisco)', 'Extremely healthy Panasonic 2170 cell pack. Minimal degradation observed, balanced cell voltages across all 4 modules.', 97.4, 73.1, 75.0, 565, 580, 142, 9, 22.5, 'EXCELLENT', 1.15, 'CCS2 & Supercharger tested up to 248 kW.'),
(2, 'BIQ-2024-PT4S-8934', 'EV_BATTERY', 'A+', 96, TRUE, '2024-10-18', 'BatteryIQ Certified Diagnostics (Austin)', '800V high-performance pack tested. Pre-conditioning thermal cycles were well regulated by owner.', 95.8, 89.5, 93.4, 490, 512, 160, 12, 31.0, 'EXCELLENT', 1.35, '800V DC Fast Charging benchmarked at 268 kW.'),
(8, 'BIQ-2024-ZSRF-8812', 'EV_BATTERY', 'A+', 96, TRUE, '2024-10-17', 'BatteryIQ Two-Wheeler EV Specialist Center', 'Z-Force Li-Ion power pack tested under simulated dyno loads. Cell resistance low.', 96.2, 13.8, 14.4, 208, 220, 95, 8, 18.0, 'EXCELLENT', 1.45, 'Nominal AC charging; Level 2 J1772 charge tank verified.'),
(11, 'BIQ-2024-OS1P-3312', 'EV_BATTERY', 'A', 95, TRUE, '2024-10-19', 'BatteryIQ E-Scooter Diagnostic Center', '4 kWh structural battery pack shows uniform cell impedance. Thermal sensor reading stable.', 95.1, 3.8, 4.0, 178, 195, 118, 14, 0.0, 'GOOD', 1.70, 'Standard 750W home charger tested.');

-- Insert ICE reports (Petrol / Diesel) into health_reports
INSERT INTO health_reports (vehicle_id, certificate_code, report_type, overall_grade, overall_score, is_certified, verified_date, verified_by_inspector, inspector_notes, engine_health_score, odometer_status, compression_test_result, compression_status, oil_condition_grade, service_history_status, documented_service_count, obd_scan_status, transmission_condition, exhaust_emission_grade, dpf_status, dpf_soot_load_grams, dpf_evidence_status, common_rail_pressure_bar, adblue_def_status, glow_plug_status, spark_plug_condition, catalytic_converter_o2_status, two_wheeler_drive_type, two_wheeler_drive_condition, two_wheeler_clutch_or_belt) VALUES
(4, 'BIQ-2024-B330-9182', 'ICE_ENGINE', 'A+', 96, TRUE, '2024-10-20', 'BatteryIQ Certified Mechanical & Diagnostics Center', 'B48 Turbo engine in flawless mechanical order. Compression test measured evenly at 180-182 PSI.', 96, 'VERIFIED', '180-182 PSI Balanced across all 4 cylinders', 'VERIFIED', 'CLEAN', 'VERIFIED', 5, 'VERIFIED', 'SMOOTH', 'PASS_CLEAN', NULL, NULL, 'MISSING', NULL, NULL, NULL, 'CLEAN_NOMINAL', 'PASS_LAMBDA_NOMINAL', NULL, NULL, NULL),
(6, 'BIQ-2024-AQ7D-6621', 'ICE_ENGINE', 'A', 91, TRUE, '2024-10-10', 'BatteryIQ Diesel Inspection Center', 'V6 TDI engine delivers strong torque. High pressure common rail injection pressure tested at 2,000 bar. DPF soot load low at 8.2g.', 91, 'VERIFIED', '390 PSI Diesel Compression Balanced across 6 cylinders', 'VERIFIED', 'CLEAN', 'VERIFIED', 7, 'VERIFIED', 'SMOOTH', 'PASS_CLEAN', 'CLEAN (8.2g soot / 45g max)', 8.2, 'VERIFIED', 2000, 'NOMINAL (Tank 85% full)', 'ALL_PASSED', NULL, NULL, NULL, NULL, NULL),
(9, 'BIQ-2024-REH3-5519', 'ICE_ENGINE', 'A', 93, TRUE, '2024-10-12', 'BatteryIQ Motorcycle Diagnostic Team', 'J-Series engine runs quiet. Wet multiplate clutch exhibits zero slipping.', 93, 'VERIFIED', '168 PSI (Single Cylinder 349cc)', 'VERIFIED', 'CLEAN', 'VERIFIED', 3, 'VERIFIED', 'SMOOTH', 'PASS_CLEAN', NULL, NULL, 'MISSING', NULL, NULL, NULL, 'CLEAN_NOMINAL', 'PASS_LAMBDA_NOMINAL', 'CHAIN_DRIVE', 'GOOD', 'Wet multi-plate clutch lever free play: 3mm'),
(13, 'BIQ-2024-HACT-2109', 'ICE_ENGINE', 'A', 94, TRUE, '2024-10-16', 'BatteryIQ Two-Wheeler Inspection Station', '109cc Honda eSP engine operates smoothly. CVT drive belt and variator rollers inspected with minimal wear.', 94, 'VERIFIED', '162 PSI (Single Cylinder 109cc)', 'VERIFIED', 'CLEAN', 'VERIFIED', 4, 'VERIFIED', 'SMOOTH', 'PASS_CLEAN', NULL, NULL, 'MISSING', NULL, NULL, NULL, 'CLEAN_NOMINAL', 'PASS_LAMBDA_NOMINAL', 'BELT_DRIVE', 'GOOD', 'Dry centrifugal clutch shoes: 3.2mm');

-- Legacy battery_reports for backward compatibility
INSERT INTO battery_reports (vehicle_id, certificate_code, soh_percentage, usable_capacity_kwh, estimated_real_range_km, cycle_count, cell_deviation_mv, fast_charge_ratio_pct, thermal_stress_grade, degradation_rate_per_year, overall_grade, verified_date, notes) VALUES
(1, 'BIQ-2024-T3LR-9721', 97.4, 73.1, 565, 142, 9, 22.5, 'EXCELLENT', 1.15, 'A+', '2024-10-15', 'Extremely healthy Panasonic 2170 cell pack.'),
(2, 'BIQ-2024-PT4S-8934', 95.8, 89.5, 490, 160, 12, 31.0, 'EXCELLENT', 1.35, 'A+', '2024-10-18', '800V high-performance pack tested.'),
(8, 'BIQ-2024-ZSRF-8812', 96.2, 13.8, 208, 95, 8, 18.0, 'EXCELLENT', 1.45, 'A+', '2024-10-17', 'Z-Force motorcycle pack tested.'),
(11, 'BIQ-2024-OS1P-3312', 95.1, 3.8, 178, 118, 14, 0.0, 'GOOD', 1.70, 'A', '2024-10-19', 'E-scooter structural pack in reliable shape.');
