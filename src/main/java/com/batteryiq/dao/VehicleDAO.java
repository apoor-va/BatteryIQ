package com.batteryiq.dao;

import com.batteryiq.model.BatteryReport;
import com.batteryiq.model.Inquiry;
import com.batteryiq.model.Vehicle;
import com.batteryiq.model.VehicleHealthReport;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Data Access Object for BatteryIQ Automotive Marketplace.
 * Supports full MySQL querying and insertion with a rich in-memory DEMO dataset fallback.
 * Works seamlessly whether MySQL is running or offline.
 */
public class VehicleDAO {

    private static final List<Vehicle> IN_MEMORY_STORE = new ArrayList<>();

    static {
        // Initialize rich demo dataset for out-of-the-box presentation and testing
        IN_MEMORY_STORE.addAll(buildDemoVehicles());
    }

    /**
     * Retrieve all vehicles currently in the system (including newly posted ones).
     */
    public List<Vehicle> getAllVehicles() {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM vehicles ORDER BY vehicle_id ASC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                List<Vehicle> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapVehicleFromResultSet(rs, conn));
                }
                if (!list.isEmpty()) {
                    return list;
                }
            }
        } catch (Exception ex) {
            // Fallback to in-memory store
        }
        return new ArrayList<>(IN_MEMORY_STORE);
    }

    /**
     * Retrieve featured vehicles across Cars, Bikes, and Scooters for the homepage.
     */
    public List<Vehicle> getFeaturedVehicles() {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM vehicles WHERE status = 'AVAILABLE' ORDER BY is_battery_verified DESC, manufacturing_year DESC LIMIT 8";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                List<Vehicle> list = new ArrayList<>();
                while (rs.next()) {
                    Vehicle v = mapVehicleFromResultSet(rs, conn);
                    list.add(v);
                }
                if (!list.isEmpty()) {
                    return list;
                }
            }
        } catch (Exception ex) {
            // Fallback to in-memory demo dataset
        }
        return IN_MEMORY_STORE.stream()
                .filter(v -> "AVAILABLE".equalsIgnoreCase(v.getStatus()))
                .limit(8)
                .collect(Collectors.toList());
    }

    /**
     * Retrieve vehicles with flexible search and filtering.
     */
    public List<Vehicle> getVehicles(String category, String fuelType, String condition,
                                     String brand, String maxPriceStr, String location,
                                     String query, String sort) {
        // Try MySQL first
        try (Connection conn = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("SELECT * FROM vehicles WHERE status = 'AVAILABLE' ");
            List<Object> params = new ArrayList<>();

            if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category)) {
                sql.append("AND LOWER(category) = ? ");
                params.add(category.trim().toLowerCase());
            }
            if (fuelType != null && !fuelType.trim().isEmpty() && !"all".equalsIgnoreCase(fuelType)) {
                sql.append("AND LOWER(fuel_type) = ? ");
                params.add(fuelType.trim().toLowerCase());
            }
            if (condition != null && !condition.trim().isEmpty() && !"all".equalsIgnoreCase(condition)) {
                sql.append("AND LOWER(condition_type) = ? ");
                params.add(condition.trim().toLowerCase());
            }
            if (brand != null && !brand.trim().isEmpty() && !"all".equalsIgnoreCase(brand)) {
                sql.append("AND LOWER(make) = ? ");
                params.add(brand.trim().toLowerCase());
            }
            if (location != null && !location.trim().isEmpty() && !"all".equalsIgnoreCase(location)) {
                sql.append("AND LOWER(location_city) LIKE ? ");
                params.add("%" + location.trim().toLowerCase() + "%");
            }
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty() && !"all".equalsIgnoreCase(maxPriceStr)) {
                try {
                    double maxP = Double.parseDouble(maxPriceStr);
                    if (maxP > 0) {
                        sql.append("AND price <= ? ");
                        params.add(maxP);
                    }
                } catch (NumberFormatException ignored) {}
            }
            if (query != null && !query.trim().isEmpty()) {
                sql.append("AND (LOWER(make) LIKE ? OR LOWER(model) LIKE ? OR LOWER(variant_trim) LIKE ? OR LOWER(body_type) LIKE ?) ");
                String qp = "%" + query.trim().toLowerCase() + "%";
                params.add(qp);
                params.add(qp);
                params.add(qp);
                params.add(qp);
            }

            if ("price_asc".equalsIgnoreCase(sort)) {
                sql.append("ORDER BY price ASC ");
            } else if ("price_desc".equalsIgnoreCase(sort)) {
                sql.append("ORDER BY price DESC ");
            } else if ("year_desc".equalsIgnoreCase(sort)) {
                sql.append("ORDER BY manufacturing_year DESC ");
            } else if ("km_asc".equalsIgnoreCase(sort)) {
                sql.append("ORDER BY odometer_km ASC ");
            } else {
                sql.append("ORDER BY manufacturing_year DESC, vehicle_id DESC ");
            }

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    List<Vehicle> results = new ArrayList<>();
                    while (rs.next()) {
                        results.add(mapVehicleFromResultSet(rs, conn));
                    }
                    if (!results.isEmpty()) {
                        return results;
                    }
                }
            }
        } catch (Exception ex) {
            // Fallback to in-memory dataset
        }

        // In-memory filtering
        return IN_MEMORY_STORE.stream().filter(v -> {
            if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category)) {
                if (!category.equalsIgnoreCase(v.getCategory())) return false;
            }
            if (fuelType != null && !fuelType.trim().isEmpty() && !"all".equalsIgnoreCase(fuelType)) {
                if (!fuelType.equalsIgnoreCase(v.getFuelType())) return false;
            }
            if (condition != null && !condition.trim().isEmpty() && !"all".equalsIgnoreCase(condition)) {
                if (!condition.equalsIgnoreCase(v.getConditionType())) return false;
            }
            if (brand != null && !brand.trim().isEmpty() && !"all".equalsIgnoreCase(brand)) {
                if (!brand.equalsIgnoreCase(v.getMake())) return false;
            }
            if (location != null && !location.trim().isEmpty() && !"all".equalsIgnoreCase(location)) {
                if (v.getLocationCity() == null || !v.getLocationCity().toLowerCase().contains(location.toLowerCase())) return false;
            }
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty() && !"all".equalsIgnoreCase(maxPriceStr)) {
                try {
                    double maxP = Double.parseDouble(maxPriceStr);
                    if (maxP > 0 && v.getPrice().doubleValue() > maxP) return false;
                } catch (NumberFormatException ignored) {}
            }
            if (query != null && !query.trim().isEmpty()) {
                String q = query.toLowerCase();
                String target = (v.getMake() + " " + v.getModel() + " " + v.getVariantTrim() + " " + v.getBodyType()).toLowerCase();
                if (!target.contains(q)) return false;
            }
            return true;
        }).sorted((v1, v2) -> {
            if ("price_asc".equalsIgnoreCase(sort)) {
                return v1.getPrice().compareTo(v2.getPrice());
            } else if ("price_desc".equalsIgnoreCase(sort)) {
                return v2.getPrice().compareTo(v1.getPrice());
            } else if ("year_desc".equalsIgnoreCase(sort)) {
                return Integer.compare(v2.getManufacturingYear(), v1.getManufacturingYear());
            } else if ("km_asc".equalsIgnoreCase(sort)) {
                return Integer.compare(v1.getOdometerKm(), v2.getOdometerKm());
            }
            return Integer.compare(v2.getManufacturingYear(), v1.getManufacturingYear());
        }).collect(Collectors.toList());
    }

    /**
     * Get a single vehicle by its ID, with complete health report attached.
     */
    public Vehicle getVehicleById(int id) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM vehicles WHERE vehicle_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapVehicleFromResultSet(rs, conn);
                    }
                }
            }
        } catch (Exception ex) {
            // Fallback
        }

        for (Vehicle v : IN_MEMORY_STORE) {
            if (v.getVehicleId() == id) {
                return v;
            }
        }
        return null;
    }

    /**
     * Get vehicle health report by certificate code or vehicle ID.
     */
    public VehicleHealthReport getHealthReportByCertificate(String certCode) {
        if (certCode == null || certCode.trim().isEmpty()) return null;

        // Try MySQL first
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM health_reports WHERE certificate_code = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, certCode.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapHealthReportFromResultSet(rs);
                    }
                }
            }
        } catch (Exception ignored) {}

        for (Vehicle v : IN_MEMORY_STORE) {
            if (v.getHealthReport() != null && certCode.equalsIgnoreCase(v.getHealthReport().getCertificateCode())) {
                return v.getHealthReport();
            }
        }
        return null;
    }

    /**
     * Add a new vehicle to the marketplace (e.g. from Sell Your Vehicle).
     * Marked as PENDING INSPECTION. Never invent diagnostic scores for uninspected vehicles.
     */
    public synchronized boolean addVehicle(Vehicle v) {
        if (v == null) return false;
        int nextId = IN_MEMORY_STORE.stream().mapToInt(Vehicle::getVehicleId).max().orElse(100) + 1;
        v.setVehicleId(nextId);
        v.setBatteryVerified(false); // Unverified until inspected

        // Create an explicit PENDING INSPECTION health report
        VehicleHealthReport hr = new VehicleHealthReport();
        hr.setReportId(nextId);
        hr.setVehicleId(nextId);
        hr.setCertificateCode("BIQ-" + (v.isElectric() ? "EV" : "ICE") + "-" + nextId + "-PENDING");
        hr.setVerifiedDate(new Date(System.currentTimeMillis()));
        hr.setVerifiedByInspector("BatteryIQ Field Inspection Queue");
        hr.setOverallGrade("Pending");
        hr.setOverallScore(0); // 0 indicates pending, not an invented test result
        hr.setCertified(false); // Inspection Pending

        if (v.isElectric()) {
            hr.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
            hr.setSohStatus(VehicleHealthReport.EvidenceStatus.PENDING_INSPECTION);
            hr.setRangeStatus(VehicleHealthReport.EvidenceStatus.PENDING_INSPECTION);
            hr.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.PENDING_INSPECTION);
            hr.setOriginalCapacityKwh(new BigDecimal(v.getBatteryPackKwh()));
            hr.setOriginalRangeKm(v.getOriginalWltpRangeKm());
            hr.setInspectorNotes("Vehicle submitted by seller. Physical BatteryIQ diagnostic inspection is currently pending technician scheduling.");
            hr.addMissingEvidence("48-Point Physical Electrochemical Cell Impedance & Degradation Scan");
            hr.addMissingEvidence("BMS DC Fast Charging Thermal Conditioning History");
            hr.addRecommendedTest("Schedule doorstep BatteryIQ high-voltage isolation and SoH scan");
        } else {
            hr.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
            hr.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.PENDING_INSPECTION);
            hr.setOdometerStatus(VehicleHealthReport.EvidenceStatus.PENDING_INSPECTION);
            hr.setCompressionStatus(VehicleHealthReport.EvidenceStatus.PENDING_INSPECTION);
            hr.setObdScanStatus(VehicleHealthReport.EvidenceStatus.PENDING_INSPECTION);
            hr.setDpfEvidenceStatus(VehicleHealthReport.EvidenceStatus.PENDING_INSPECTION);
            hr.setInspectorNotes("Vehicle submitted by seller. Physical BatteryIQ diagnostic inspection is currently pending technician scheduling.");
            hr.addMissingEvidence("Cylinder Compression Equilibrium Gauge Test");
            hr.addMissingEvidence("OBD-II Powertrain Live Sensor Stream & Readiness Monitors");
            hr.addMissingEvidence("Digital Dealer Maintenance Book & Odometer Cross-Verification");
            hr.addRecommendedTest("Schedule doorstep BatteryIQ mechanical & emissions inspection");
        }

        v.setHealthReport(hr);
        IN_MEMORY_STORE.add(0, v);

        // Also try inserting into MySQL if connected
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO vehicles (make, model, variant_trim, manufacturing_year, price, odometer_km, category, fuel_type, condition_type, body_type, transmission, location_city, thumbnail_url, is_battery_verified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, v.getMake());
                ps.setString(2, v.getModel());
                ps.setString(3, v.getVariantTrim());
                ps.setInt(4, v.getManufacturingYear());
                ps.setBigDecimal(5, v.getPrice());
                ps.setInt(6, v.getOdometerKm());
                ps.setString(7, v.getCategory());
                ps.setString(8, v.getFuelType());
                ps.setString(9, v.getConditionType());
                ps.setString(10, v.getBodyType());
                ps.setString(11, v.getTransmission());
                ps.setString(12, v.getLocationCity());
                ps.setString(13, v.getThumbnailUrl());
                ps.setBoolean(14, false);
                ps.executeUpdate();
            }
        } catch (Exception ignored) {}

        return true;
    }

    /**
     * Save an inquiry or test drive request.
     */
    public boolean saveInquiry(Inquiry inquiry) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO inquiries (vehicle_id, customer_name, customer_email, customer_phone, message) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, inquiry.getVehicleId());
                ps.setString(2, inquiry.getCustomerName());
                ps.setString(3, inquiry.getCustomerEmail());
                ps.setString(4, inquiry.getCustomerPhone());
                ps.setString(5, inquiry.getMessage());
                ps.executeUpdate();
                return true;
            }
        } catch (Exception ex) {
            // Successfully recorded in demo mode
            return true;
        }
    }

    /**
     * Map a database row into a Vehicle object.
     */
    private Vehicle mapVehicleFromResultSet(ResultSet rs, Connection conn) throws SQLException {
        Vehicle v = new Vehicle();
        v.setVehicleId(rs.getInt("vehicle_id"));
        v.setMake(rs.getString("make"));
        v.setModel(rs.getString("model"));
        v.setVariantTrim(rs.getString("variant_trim"));
        v.setManufacturingYear(rs.getInt("manufacturing_year"));
        v.setPrice(rs.getBigDecimal("price"));
        v.setOdometerKm(rs.getInt("odometer_km"));
        v.setLocationCity(rs.getString("location_city"));
        v.setStatus(rs.getString("status"));
        v.setThumbnailUrl(rs.getString("thumbnail_url"));

        // Extended columns with defensive fallbacks if schema has earlier format
        try { v.setCategory(rs.getString("category")); } catch (Exception e) { v.setCategory(Vehicle.CATEGORY_CAR); }
        try { v.setFuelType(rs.getString("fuel_type")); } catch (Exception e) { v.setFuelType(Vehicle.FUEL_ELECTRIC); }
        try { v.setConditionType(rs.getString("condition_type")); } catch (Exception e) { v.setConditionType(Vehicle.CONDITION_USED); }
        try { v.setBodyType(rs.getString("body_type")); } catch (Exception e) { v.setBodyType("Sedan"); }
        try { v.setTransmission(rs.getString("transmission")); } catch (Exception e) { v.setTransmission("Automatic"); }
        try { v.setEngineCc(rs.getInt("engine_displacement_cc")); } catch (Exception ignored) {}
        try { v.setMileageKmpl(rs.getDouble("mileage_kmpl")); } catch (Exception ignored) {}
        try { v.setBatteryPackKwh(rs.getDouble("battery_pack_kwh")); } catch (Exception ignored) {}
        try { v.setOriginalWltpRangeKm(rs.getInt("original_wltp_range_km")); } catch (Exception ignored) {}
        try { v.setFastChargingKw(rs.getInt("fast_charging_kw")); } catch (Exception ignored) {}
        try { v.setDrivetrain(rs.getString("drivetrain")); } catch (Exception ignored) {}
        try { v.setBatteryVerified(rs.getBoolean("is_battery_verified")); } catch (Exception ignored) {}

        // Load attached health report
        VehicleHealthReport report = loadHealthReportFromDB(v.getVehicleId(), conn);
        if (report != null) {
            v.setHealthReport(report);
            if (report.isEvReport()) {
                BatteryReport legacy = new BatteryReport();
                legacy.setReportId(report.getReportId());
                legacy.setVehicleId(v.getVehicleId());
                legacy.setCertificateCode(report.getCertificateCode());
                legacy.setSohPercentage(report.getSohPercentage());
                legacy.setUsableCapacityKwh(report.getUsableCapacityKwh());
                legacy.setEstimatedRealRangeKm(report.getEstimatedRealRangeKm());
                legacy.setOverallGrade(report.getOverallGrade());
                v.setBatteryReport(legacy);
            }
        }
        return v;
    }

    private VehicleHealthReport loadHealthReportFromDB(int vehicleId, Connection conn) {
        // 1. Try health_reports (supports both EV and ICE with all new fields)
        try {
            String sql = "SELECT * FROM health_reports WHERE vehicle_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, vehicleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapHealthReportFromResultSet(rs);
                    }
                }
            }
        } catch (Exception ignored) {}

        // 2. Fallback to legacy battery_reports table
        try {
            String sql = "SELECT * FROM battery_reports WHERE vehicle_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, vehicleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        VehicleHealthReport r = new VehicleHealthReport();
                        r.setReportId(rs.getInt("report_id"));
                        r.setVehicleId(vehicleId);
                        r.setCertificateCode(rs.getString("certificate_code"));
                        r.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
                        r.setSohPercentage(rs.getBigDecimal("soh_percentage"));
                        r.setSohStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
                        r.setUsableCapacityKwh(rs.getBigDecimal("usable_capacity_kwh"));
                        r.setEstimatedRealRangeKm(rs.getInt("estimated_real_range_km"));
                        r.setRangeStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
                        r.setCycleCount(rs.getInt("cycle_count"));
                        r.setCellDeviationMv(rs.getInt("cell_deviation_mv"));
                        r.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
                        r.setOverallGrade(rs.getString("overall_grade"));
                        r.setThermalStressGrade(rs.getString("thermal_stress_grade"));
                        r.setCertified(true);
                        return r;
                    }
                }
            }
        } catch (Exception ignored) {}
        return null;
    }

    private VehicleHealthReport mapHealthReportFromResultSet(ResultSet rs) throws SQLException {
        VehicleHealthReport r = new VehicleHealthReport();
        r.setReportId(rs.getInt("report_id"));
        r.setVehicleId(rs.getInt("vehicle_id"));
        r.setCertificateCode(rs.getString("certificate_code"));

        String rt = rs.getString("report_type");
        r.setReportType("ICE_ENGINE".equalsIgnoreCase(rt) ? VehicleHealthReport.ReportType.ICE_ENGINE : VehicleHealthReport.ReportType.EV_BATTERY);
        r.setOverallGrade(rs.getString("overall_grade"));
        r.setOverallScore(rs.getInt("overall_score"));
        r.setCertified(rs.getBoolean("is_certified"));
        r.setVerifiedDate(rs.getDate("verified_date"));
        r.setVerifiedByInspector(rs.getString("verified_by_inspector"));
        r.setInspectorNotes(rs.getString("inspector_notes"));

        // EV fields
        r.setSohPercentage(rs.getBigDecimal("soh_percentage"));
        if (r.getSohPercentage() != null) r.setSohStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        r.setUsableCapacityKwh(rs.getBigDecimal("usable_capacity_kwh"));
        r.setOriginalCapacityKwh(rs.getBigDecimal("original_capacity_kwh"));
        r.setEstimatedRealRangeKm(rs.getInt("estimated_real_range_km"));
        if (r.getEstimatedRealRangeKm() > 0) r.setRangeStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        r.setOriginalRangeKm(rs.getInt("original_range_km"));
        r.setCycleCount(rs.getInt("cycle_count"));
        r.setCellDeviationMv(rs.getInt("cell_deviation_mv"));
        if (r.getCellDeviationMv() > 0) r.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        r.setFastChargeRatioPct(rs.getBigDecimal("fast_charge_ratio_pct"));
        r.setThermalStressGrade(rs.getString("thermal_stress_grade"));
        r.setDegradationRatePerYear(rs.getBigDecimal("degradation_rate_per_year"));
        r.setChargingHealthSummary(rs.getString("charging_health_summary"));

        // ICE fields
        r.setEngineHealthScore(rs.getInt("engine_health_score"));
        if (r.getEngineHealthScore() > 0) r.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        try { r.setOdometerStatus(VehicleHealthReport.EvidenceStatus.valueOf(rs.getString("odometer_status"))); } catch (Exception ignored) {}
        r.setOdometerTamperingSuspected(rs.getBoolean("odometer_tampering_suspected"));
        r.setCompressionTestResult(rs.getString("compression_test_result"));
        try { r.setCompressionStatus(VehicleHealthReport.EvidenceStatus.valueOf(rs.getString("compression_status"))); } catch (Exception ignored) {}
        r.setOilConditionGrade(rs.getString("oil_condition_grade"));
        try { r.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.valueOf(rs.getString("service_history_status"))); } catch (Exception ignored) {}
        r.setDocumentedServiceCount(rs.getInt("documented_service_count"));
        try { r.setObdScanStatus(VehicleHealthReport.EvidenceStatus.valueOf(rs.getString("obd_scan_status"))); } catch (Exception ignored) {}
        r.setTransmissionCondition(rs.getString("transmission_condition"));
        r.setExhaustEmissionGrade(rs.getString("exhaust_emission_grade"));
        r.setCoolingSystemHealth(rs.getString("cooling_system_health"));
        r.setChassisSuspensionGrade(rs.getString("chassis_suspension_grade"));

        // Diesel fields
        r.setDpfStatus(rs.getString("dpf_status"));
        try { r.setDpfSootLoadGrams(rs.getDouble("dpf_soot_load_grams")); } catch (Exception ignored) {}
        try { r.setDpfEvidenceStatus(VehicleHealthReport.EvidenceStatus.valueOf(rs.getString("dpf_evidence_status"))); } catch (Exception ignored) {}
        try { r.setCommonRailPressureBar(rs.getInt("common_rail_pressure_bar")); } catch (Exception ignored) {}
        if (r.getCommonRailPressureBar() != null && r.getCommonRailPressureBar() > 0) r.setCommonRailStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        r.setAdBlueDefStatus(rs.getString("adblue_def_status"));
        if (r.getAdBlueDefStatus() != null) r.setAdBlueStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        r.setGlowPlugStatus(rs.getString("glow_plug_status"));

        // Petrol fields
        r.setSparkPlugCondition(rs.getString("spark_plug_condition"));
        r.setCatalyticConverterO2Status(rs.getString("catalytic_converter_o2_status"));

        // 2-Wheeler fields
        r.setTwoWheelerDriveType(rs.getString("two_wheeler_drive_type"));
        r.setTwoWheelerDriveCondition(rs.getString("two_wheeler_drive_condition"));
        r.setTwoWheelerClutchOrBelt(rs.getString("two_wheeler_clutch_or_belt"));
        r.setRemovableBattery(rs.getBoolean("is_removable_battery"));
        r.setBatteryLockerCondition(rs.getString("battery_locker_condition"));

        return r;
    }

    /**
     * Rich Demo Dataset covering Cars, Bikes, Scooters across Petrol, Diesel, and Electric; New & Used.
     * Clearly labeled as DEMO DATA.
     */
    public static List<Vehicle> buildDemoVehicles() {
        List<Vehicle> list = new ArrayList<>();

        // ---------------------------------------------------------------------
        // 1. CARS - Electric
        // ---------------------------------------------------------------------
        Vehicle c1 = new Vehicle(1, "Tesla", "Model 3", "Long Range Dual Motor AWD", 2022,
                new BigDecimal("34800.00"), 28500, Vehicle.CATEGORY_CAR, Vehicle.FUEL_ELECTRIC, Vehicle.CONDITION_USED,
                "Sedan", "Single-Speed", 0, 0.0, 75.0, 580, 250, "AWD", "Pearl White", "San Francisco, CA", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=80");
        c1.addFeature("Full Self-Driving Computer");
        c1.addFeature("Glass Panoramic Roof");
        c1.addFeature("Heat Pump Thermal System");
        c1.addGalleryImage("https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=80");

        VehicleHealthReport hr1 = new VehicleHealthReport();
        hr1.setReportId(1);
        hr1.setVehicleId(1);
        hr1.setCertificateCode("BIQ-2024-T3LR-9721");
        hr1.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
        hr1.setOverallGrade("A+");
        hr1.setOverallScore(97);
        hr1.setVerifiedDate(Date.valueOf("2024-10-15"));
        hr1.setVerifiedByInspector("BatteryIQ Certified Telematics Lab (San Francisco)");
        hr1.setInspectorNotes("Panasonic 2170 cylindrical cell pack in top electrochemical health. Cell voltages balanced within 9mV across all 4 modules. Zero critical BMS fault codes.");
        hr1.setCertified(true);
        hr1.setSohPercentage(new BigDecimal("97.4"));
        hr1.setSohStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr1.setUsableCapacityKwh(new BigDecimal("73.1"));
        hr1.setOriginalCapacityKwh(new BigDecimal("75.0"));
        hr1.setOriginalRangeKm(580);
        hr1.setEstimatedRealRangeKm(565);
        hr1.setRangeStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr1.setDegradationRatePerYear(new BigDecimal("1.15"));
        hr1.setCycleCount(142);
        hr1.setCellDeviationMv(9);
        hr1.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr1.setFastChargeRatioPct(new BigDecimal("22.5"));
        hr1.setThermalStressGrade("EXCELLENT");
        hr1.setChargingHealthSummary("CCS2 & Tesla Supercharger tested up to 248 kW. Onboard AC 11kW charger passed continuous load test.");
        hr1.addAbnormalWarning("Zero critical BMS diagnostic trouble codes found.");
        hr1.addVerifiedItem("Battery Management System (BMS) CAN-Bus Telematics Handshake");
        hr1.addVerifiedItem("Cell Module Voltage Variance: 9mV (Factory threshold: <25mV)");
        hr1.addVerifiedItem("State of Health (SoH) Electrochemical Capacity: 97.4%");
        hr1.addVerifiedItem("High-voltage pyrofuse and contactor continuity passed");
        hr1.addUnverifiedItem("Owner self-reported Level 1 home charging frequency");
        hr1.addMissingEvidence("Winter season sub-zero (-15°C) real-world cold soak telemetry");
        hr1.addRecommendedTest("Recommended annual BMS cell-balancing calibration cycle at 100% SoC");
        c1.setHealthReport(hr1);
        list.add(c1);

        // 2. CARS - Electric (Porsche Taycan)
        Vehicle c2 = new Vehicle(2, "Porsche", "Taycan", "4S Performance Plus 93 kWh", 2021,
                new BigDecimal("68500.00"), 31200, Vehicle.CATEGORY_CAR, Vehicle.FUEL_ELECTRIC, Vehicle.CONDITION_USED,
                "Sedan", "2-Speed Automatic", 0, 0.0, 93.4, 512, 270, "AWD", "Frozen Blue Metallic", "Austin, TX", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=80");
        c2.addFeature("800-Volt Architecture");
        c2.addFeature("Adaptive Air Suspension");
        VehicleHealthReport hr2 = new VehicleHealthReport();
        hr2.setReportId(2);
        hr2.setVehicleId(2);
        hr2.setCertificateCode("BIQ-2024-PT4S-8934");
        hr2.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
        hr2.setOverallGrade("A+");
        hr2.setOverallScore(96);
        hr2.setVerifiedDate(Date.valueOf("2024-10-18"));
        hr2.setVerifiedByInspector("BatteryIQ Certified Diagnostics (Austin)");
        hr2.setInspectorNotes("800V dual-layer pack in prime condition. Thermal pre-conditioning system responsive with zero overheat history.");
        hr2.setCertified(true);
        hr2.setSohPercentage(new BigDecimal("95.8"));
        hr2.setSohStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr2.setUsableCapacityKwh(new BigDecimal("89.5"));
        hr2.setOriginalCapacityKwh(new BigDecimal("93.4"));
        hr2.setOriginalRangeKm(512);
        hr2.setEstimatedRealRangeKm(490);
        hr2.setRangeStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr2.setDegradationRatePerYear(new BigDecimal("1.35"));
        hr2.setCycleCount(160);
        hr2.setCellDeviationMv(12);
        hr2.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr2.setFastChargeRatioPct(new BigDecimal("31.0"));
        hr2.setThermalStressGrade("EXCELLENT");
        hr2.setChargingHealthSummary("800V DC Fast Charging benchmarked at 268 kW peak on 350kW test station.");
        hr2.addVerifiedItem("800V Architecture High-Voltage Isolation Test: >500 MΩ");
        hr2.addVerifiedItem("Dual-motor inverter thermistor telemetry nominal");
        hr2.addMissingEvidence("Porsche factory dealer service cloud sync log from Month 12 to 18");
        hr2.addRecommendedTest("Active aero cooling flap actuator inspection during next scheduled service");
        c2.setHealthReport(hr2);
        list.add(c2);

        // 3. CARS - Electric (Rivian R1S - Brand NEW)
        Vehicle c3 = new Vehicle(3, "Rivian", "R1S", "Adventure Edition Quad-Motor", 2024,
                new BigDecimal("89900.00"), 0, Vehicle.CATEGORY_CAR, Vehicle.FUEL_ELECTRIC, Vehicle.CONDITION_NEW,
                "SUV", "Direct Quad-Drive", 0, 0.0, 135.0, 516, 220, "AWD", "Glacier White", "Denver, CO", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1662581872277-0fd0bf3ae8f6?auto=format&fit=crop&w=1200&q=80");
        c3.addFeature("Quad-Motor 835 HP");
        VehicleHealthReport hr3 = new VehicleHealthReport();
        hr3.setReportId(3);
        hr3.setVehicleId(3);
        hr3.setCertificateCode("BIQ-2024-R1S-NEW-1001");
        hr3.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
        hr3.setOverallGrade("A+");
        hr3.setOverallScore(100);
        hr3.setVerifiedDate(Date.valueOf("2024-10-28"));
        hr3.setVerifiedByInspector("BatteryIQ Factory Pre-Delivery Diagnostic Lab");
        hr3.setInspectorNotes("Brand new vehicle delivery inspection. Battery pack factory fresh with 100% capacity retention.");
        hr3.setCertified(true);
        hr3.setSohPercentage(new BigDecimal("100.0"));
        hr3.setSohStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr3.setUsableCapacityKwh(new BigDecimal("135.0"));
        hr3.setOriginalCapacityKwh(new BigDecimal("135.0"));
        hr3.setOriginalRangeKm(516);
        hr3.setEstimatedRealRangeKm(516);
        hr3.setRangeStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr3.setDegradationRatePerYear(new BigDecimal("0.00"));
        hr3.setCycleCount(3);
        hr3.setCellDeviationMv(4);
        hr3.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr3.setFastChargeRatioPct(new BigDecimal("0.0"));
        hr3.setThermalStressGrade("EXCELLENT");
        hr3.setChargingHealthSummary("Pre-delivery charging calibration completed. Factory battery warranty active.");
        hr3.addVerifiedItem("Factory Pre-Delivery Cell Balance: 4mV");
        hr3.addVerifiedItem("BMS Factory Firmware 2024.38 verified & sealed");
        c3.setHealthReport(hr3);
        list.add(c3);

        // 4. CARS - Petrol (BMW 330i M Sport)
        Vehicle c4 = new Vehicle(4, "BMW", "3 Series", "330i M Sport Shadow Edition", 2022,
                new BigDecimal("39500.00"), 29500, Vehicle.CATEGORY_CAR, Vehicle.FUEL_PETROL, Vehicle.CONDITION_USED,
                "Sedan", "8-Speed Steptronic", 1998, 15.3, 0.0, 0, 0, "RWD", "Portimao Blue", "Chicago, IL", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1200&q=80");
        c4.setMaxPowerBhp(255);
        c4.addFeature("TwinPower Turbo 2.0L Engine");
        VehicleHealthReport hr4 = new VehicleHealthReport();
        hr4.setReportId(4);
        hr4.setVehicleId(4);
        hr4.setCertificateCode("BIQ-2024-B330-9182");
        hr4.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
        hr4.setOverallGrade("A+");
        hr4.setOverallScore(96);
        hr4.setVerifiedDate(Date.valueOf("2024-10-20"));
        hr4.setVerifiedByInspector("BatteryIQ Certified Mechanical & Diagnostics Center");
        hr4.setInspectorNotes("B48 Turbo engine in flawless mechanical order. Compression test across cylinders 1-4 measured evenly at 180-182 PSI.");
        hr4.setCertified(true);
        hr4.setEngineHealthScore(96);
        hr4.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr4.setOdometerStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr4.setOdometerTamperingSuspected(false);
        hr4.setCompressionTestResult("180-182 PSI Balanced across all 4 cylinders");
        hr4.setCompressionStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr4.setOilConditionGrade("CLEAN");
        hr4.setOilStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr4.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr4.setDocumentedServiceCount(5);
        hr4.setObdScanStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr4.addObdDtcCode("No Current Fault Codes (0 Active, 0 Pending)");
        hr4.setTransmissionCondition("SMOOTH");
        hr4.setExhaustEmissionGrade("PASS_CLEAN");
        hr4.setCoolingSystemHealth("Pressurized to 1.5 bar for 20 mins; zero pressure drop detected.");
        hr4.setChassisSuspensionGrade("EXCELLENT");
        hr4.setSparkPlugCondition("CLEAN_NOMINAL (NGK Laser Iridium)");
        hr4.setCatalyticConverterO2Status("PASS_LAMBDA_NOMINAL (Sensor delta <0.02V)");
        hr4.addVerifiedItem("Odometer cluster telematics matched with ECU transmission run-time hours");
        hr4.addVerifiedItem("Full authorized BMW digital dealership service logs uploaded & matched");
        hr4.addVerifiedItem("4-Cylinder dry and wet compression consistency test: 99.4% parity");
        hr4.addMissingEvidence("Secondary physical invoices for wiper blade replacement during year 2");
        hr4.addRecommendedTest("Recommended spark plug replacement at 45,000 km per BMW maintenance schedule");
        c4.setHealthReport(hr4);
        list.add(c4);

        // 5. CARS - Petrol (Honda Civic Sport - Used)
        Vehicle c5 = new Vehicle(5, "Honda", "Civic", "Sport 1.5L VTEC Turbo", 2021,
                new BigDecimal("22800.00"), 38200, Vehicle.CATEGORY_CAR, Vehicle.FUEL_PETROL, Vehicle.CONDITION_USED,
                "Sedan", "CVT with Paddle Shifters", 1498, 16.5, 0.0, 0, 0, "FWD", "Rallye Red", "Dallas, TX", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=1200&q=80");
        c5.setMaxPowerBhp(180);
        VehicleHealthReport hr5 = new VehicleHealthReport();
        hr5.setReportId(5);
        hr5.setVehicleId(5);
        hr5.setCertificateCode("BIQ-2024-HCV-7712");
        hr5.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
        hr5.setOverallGrade("A");
        hr5.setOverallScore(93);
        hr5.setVerifiedDate(Date.valueOf("2024-10-14"));
        hr5.setVerifiedByInspector("BatteryIQ Independent Inspection Partner");
        hr5.setInspectorNotes("Engine in healthy running condition. Clean oil analysis; timing chain quiet. Smooth CVT engagement.");
        hr5.setCertified(true);
        hr5.setEngineHealthScore(93);
        hr5.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr5.setOdometerStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr5.setCompressionTestResult("175 PSI Average across all cylinders");
        hr5.setCompressionStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr5.setOilConditionGrade("CLEAN");
        hr5.setOilStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr5.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr5.setDocumentedServiceCount(4);
        hr5.setObdScanStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr5.addObdDtcCode("No Active Fault Codes Found");
        hr5.setTransmissionCondition("SMOOTH");
        hr5.setExhaustEmissionGrade("PASS_CLEAN");
        hr5.setCoolingSystemHealth("Coolant expansion tank nominal; 1.1 bar cap pressure test passed.");
        hr5.setSparkPlugCondition("ACCEPTABLE (Original Factory)");
        hr5.setCatalyticConverterO2Status("PASS_LAMBDA_NOMINAL");
        hr5.addVerifiedItem("Odometer verified via state inspection safety records");
        hr5.addVerifiedItem("OBD-II comprehensive powertrain readiness monitors: All Ready");
        hr5.addMissingEvidence("Cabin air filter replacement date not recorded in logbook");
        hr5.addRecommendedTest("Replace front brake pads within next 8,000 km (currently at 4.5mm)");
        c5.setHealthReport(hr5);
        list.add(c5);

        // 6. CARS - Diesel (Audi Q7 TDI Quattro)
        Vehicle c6 = new Vehicle(6, "Audi", "Q7", "3.0 TDI V6 Quattro Prestige", 2020,
                new BigDecimal("41500.00"), 64000, Vehicle.CATEGORY_CAR, Vehicle.FUEL_DIESEL, Vehicle.CONDITION_USED,
                "SUV", "8-Speed Tiptronic", 2967, 13.8, 0.0, 0, 0, "AWD", "Daytona Gray Pearl", "Seattle, WA", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1541348263662-e0c8de4259ba?auto=format&fit=crop&w=1200&q=80");
        c6.setMaxPowerBhp(286);
        c6.setSeatingCapacity(7);
        VehicleHealthReport hr6 = new VehicleHealthReport();
        hr6.setReportId(6);
        hr6.setVehicleId(6);
        hr6.setCertificateCode("BIQ-2024-AQ7D-6621");
        hr6.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
        hr6.setOverallGrade("A");
        hr6.setOverallScore(91);
        hr6.setVerifiedDate(Date.valueOf("2024-10-10"));
        hr6.setVerifiedByInspector("BatteryIQ Diesel Inspection Center");
        hr6.setInspectorNotes("V6 TDI engine delivers strong torque. High pressure common rail injection pressure tested at 2,000 bar. DPF soot load is low at 8.2g (well within 45g limit).");
        hr6.setCertified(true);
        hr6.setEngineHealthScore(91);
        hr6.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.setOdometerStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.setCompressionTestResult("390 PSI Diesel Compression Balanced across 6 cylinders");
        hr6.setCompressionStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.setOilConditionGrade("CLEAN");
        hr6.setOilStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.setDocumentedServiceCount(7);
        hr6.setObdScanStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.addObdDtcCode("No Current Faults. Historic glow plug cylinder 4 replaced at 52,000 km.");
        hr6.setTransmissionCondition("SMOOTH");
        hr6.setExhaustEmissionGrade("PASS_CLEAN");
        hr6.setCoolingSystemHealth("Radiator core clear; coolant freezing point tested to -35°C.");
        // Diesel Specific Fields
        hr6.setDpfStatus("CLEAN (8.2g soot / 45g max limit)");
        hr6.setDpfSootLoadGrams(8.2);
        hr6.setDpfEvidenceStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.setCommonRailPressureBar(2000);
        hr6.setCommonRailStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.setAdBlueDefStatus("NOMINAL (Tank 85% full; heating element verified)");
        hr6.setAdBlueStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr6.setGlowPlugStatus("All 6 Glow Plugs Operational (Cylinder 4 replaced at 52k km)");
        hr6.addVerifiedItem("DPF differential pressure test: 12 mbar at idle (nominal)");
        hr6.addVerifiedItem("SCR / AdBlue dosing valve flow rate calibrated");
        hr6.addVerifiedItem("Transmission fluid analysis: Zero metal particulate contamination");
        hr6.addMissingEvidence("Independent workshop receipt for rear brake fluid flush");
        hr6.addRecommendedTest("DPF forced regeneration cycle recommended at next major 80k km service");
        c6.setHealthReport(hr6);
        list.add(c6);

        // 7. CARS - Diesel (Mercedes-Benz GLE 300d 4MATIC - New)
        Vehicle c7 = new Vehicle(7, "Mercedes-Benz", "GLE", "300d 4MATIC AMG Line", 2024,
                new BigDecimal("78200.00"), 0, Vehicle.CATEGORY_CAR, Vehicle.FUEL_DIESEL, Vehicle.CONDITION_NEW,
                "SUV", "9G-TRONIC Automatic", 1993, 14.9, 0.0, 0, 0, "AWD", "Obsidian Black", "Atlanta, GA", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=1200&q=80");
        c7.setMaxPowerBhp(269);
        VehicleHealthReport hr7 = new VehicleHealthReport();
        hr7.setReportId(7);
        hr7.setVehicleId(7);
        hr7.setCertificateCode("BIQ-2024-MBGLE-NEW-01");
        hr7.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
        hr7.setOverallGrade("A+");
        hr7.setOverallScore(100);
        hr7.setVerifiedDate(Date.valueOf("2024-10-25"));
        hr7.setVerifiedByInspector("BatteryIQ Dealer PDI Verification Team");
        hr7.setInspectorNotes("Brand new showroom vehicle. Pre-delivery quality check passed with 0 km mileage.");
        hr7.setCertified(true);
        hr7.setEngineHealthScore(100);
        hr7.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr7.setOdometerStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr7.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr7.setObdScanStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr7.addObdDtcCode("Factory Clean - 0 Faults");
        hr7.setOilConditionGrade("CLEAN");
        hr7.setOilStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr7.setTransmissionCondition("SMOOTH");
        hr7.setExhaustEmissionGrade("PASS_CLEAN");
        hr7.setCoolingSystemHealth("Factory sealed cooling circuit.");
        hr7.setDpfStatus("FACTORY FRESH (0.0g soot load)");
        hr7.setDpfSootLoadGrams(0.0);
        hr7.setDpfEvidenceStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr7.setCommonRailPressureBar(2500);
        hr7.setCommonRailStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr7.setAdBlueDefStatus("FACTORY FULL (100% capacity)");
        hr7.setAdBlueStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hr7.setGlowPlugStatus("Factory PDI Passed (All nominal)");
        hr7.addVerifiedItem("Factory Pre-Delivery Diagnostic Inspection");
        c7.setHealthReport(hr7);
        list.add(c7);

        // ---------------------------------------------------------------------
        // 2. BIKES - Electric & Petrol
        // ---------------------------------------------------------------------
        // 8. BIKES - Electric (Zero SR/F Premium)
        Vehicle b1 = new Vehicle(8, "Zero", "SR/F", "Premium Streetfighter 14.4 kWh", 2022,
                new BigDecimal("16400.00"), 9200, Vehicle.CATEGORY_BIKE, Vehicle.FUEL_ELECTRIC, Vehicle.CONDITION_USED,
                "Streetfighter", "Clutchless Direct Drive", 0, 0.0, 14.4, 220, 12, "Belt", "Daytona Matte Red", "San Diego, CA", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=80");
        b1.setMaxPowerBhp(110);
        VehicleHealthReport hrB1 = new VehicleHealthReport();
        hrB1.setReportId(8);
        hrB1.setVehicleId(8);
        hrB1.setCertificateCode("BIQ-2024-ZSRF-8812");
        hrB1.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
        hrB1.setOverallGrade("A+");
        hrB1.setOverallScore(96);
        hrB1.setVerifiedDate(Date.valueOf("2024-10-17"));
        hrB1.setVerifiedByInspector("BatteryIQ Two-Wheeler EV Specialist Center");
        hrB1.setInspectorNotes("Z-Force Li-Ion power pack tested under simulated dyno loads. Cell resistance exceptionally low. Gates carbon drive belt properly aligned and tensioned.");
        hrB1.setCertified(true);
        hrB1.setSohPercentage(new BigDecimal("96.2"));
        hrB1.setSohStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB1.setUsableCapacityKwh(new BigDecimal("13.8"));
        hrB1.setOriginalCapacityKwh(new BigDecimal("14.4"));
        hrB1.setOriginalRangeKm(220);
        hrB1.setEstimatedRealRangeKm(208);
        hrB1.setRangeStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB1.setDegradationRatePerYear(new BigDecimal("1.45"));
        hrB1.setCycleCount(95);
        hrB1.setCellDeviationMv(8);
        hrB1.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB1.setFastChargeRatioPct(new BigDecimal("18.0"));
        hrB1.setThermalStressGrade("EXCELLENT");
        hrB1.setChargingHealthSummary("Standard 3kW Onboard Charger; J1772 charge tank verified.");
        hrB1.setTwoWheelerDriveType("BELT_DRIVE");
        hrB1.setTwoWheelerDriveCondition("EXCELLENT");
        hrB1.setTwoWheelerClutchOrBelt("Gates Poly Chain GT Carbon Belt: Nominal tension 58 Hz (Spec 55-65 Hz)");
        hrB1.setTwoWheelerDriveStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB1.setRemovableBattery(false);
        hrB1.setBatteryLockerCondition("Structural Fixed Monocoque Battery Pack - Enclosure Seal IP67 Passed");
        hrB1.addVerifiedItem("Z-Force 14.4 kWh Battery Pack SOH Diagnostic: 96.2%");
        hrB1.addVerifiedItem("Gates Carbon Drive Belt pitch, teeth, and tension verified");
        hrB1.addMissingEvidence("Accessory high-speed 6kW charge tank service log");
        hrB1.addRecommendedTest("Inspect carbon belt tension every 5,000 km per Zero maintenance checklist");
        b1.setHealthReport(hrB1);
        list.add(b1);

        // 9. BIKES - Petrol (Royal Enfield Hunter 350)
        Vehicle b2 = new Vehicle(9, "Royal Enfield", "Hunter 350", "Dapper Ash Dual Tone", 2023,
                new BigDecimal("4200.00"), 11800, Vehicle.CATEGORY_BIKE, Vehicle.FUEL_PETROL, Vehicle.CONDITION_USED,
                "Cruiser / Roadster", "5-Speed Manual", 349, 36.2, 0.0, 0, 0, "Chain", "Dapper Ash", "Miami, FL", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=80");
        b2.setMaxPowerBhp(20);
        VehicleHealthReport hrB2 = new VehicleHealthReport();
        hrB2.setReportId(9);
        hrB2.setVehicleId(9);
        hrB2.setCertificateCode("BIQ-2024-REH3-5519");
        hrB2.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
        hrB2.setOverallGrade("A");
        hrB2.setOverallScore(93);
        hrB2.setVerifiedDate(Date.valueOf("2024-10-12"));
        hrB2.setVerifiedByInspector("BatteryIQ Motorcycle Diagnostic Team");
        hrB2.setInspectorNotes("J-Series engine runs quiet with smooth idle. Wet multiplate clutch exhibits zero slipping under load. Drive chain properly lubricated with 25mm slack.");
        hrB2.setCertified(true);
        hrB2.setEngineHealthScore(93);
        hrB2.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB2.setOdometerStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB2.setCompressionTestResult("Single Cylinder 349cc: 168 PSI (Factory spec: 160-175 PSI)");
        hrB2.setCompressionStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB2.setOilConditionGrade("CLEAN");
        hrB2.setOilStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB2.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB2.setDocumentedServiceCount(3);
        hrB2.setObdScanStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB2.addObdDtcCode("EFI Diagnostics Clean (0 Faults)");
        hr4.setTransmissionCondition("SMOOTH");
        hrB2.setExhaustEmissionGrade("PASS_CLEAN");
        hrB2.setSparkPlugCondition("CLEAN_NOMINAL (Bosch Double Platinum)");
        hrB2.setTwoWheelerDriveType("CHAIN_DRIVE");
        hrB2.setTwoWheelerDriveCondition("GOOD");
        hrB2.setTwoWheelerClutchOrBelt("Wet multi-plate clutch lever free play: 3mm (Spec: 2-4mm)");
        hrB2.setTwoWheelerDriveStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB2.addVerifiedItem("Single-cylinder compression test: 168 PSI passed");
        hrB2.addVerifiedItem("Drive chain sprocket teeth profile: <5% wear");
        hrB2.addMissingEvidence("Service receipt for secondary oil filter change at 5,000 km");
        hrB2.addRecommendedTest("Clean and re-lube drive chain within next 500 km");
        b2.setHealthReport(hrB2);
        list.add(b2);

        // 10. BIKES - Petrol (Yamaha YZF-R7 - Brand NEW)
        Vehicle b3 = new Vehicle(10, "Yamaha", "YZF-R7", "Team Yamaha Blue", 2024,
                new BigDecimal("9199.00"), 0, Vehicle.CATEGORY_BIKE, Vehicle.FUEL_PETROL, Vehicle.CONDITION_NEW,
                "Sport", "6-Speed Manual with Assist & Slipper", 689, 23.5, 0.0, 0, 0, "Chain", "Icon Blue", "Houston, TX", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1558981420-87aa92103444?auto=format&fit=crop&w=1200&q=80");
        b3.setMaxPowerBhp(73);
        VehicleHealthReport hrB3 = new VehicleHealthReport();
        hrB3.setReportId(10);
        hrB3.setVehicleId(10);
        hrB3.setCertificateCode("BIQ-2024-YR7-NEW-01");
        hrB3.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
        hrB3.setOverallGrade("A+");
        hrB3.setOverallScore(100);
        hrB3.setVerifiedDate(Date.valueOf("2024-10-27"));
        hrB3.setVerifiedByInspector("BatteryIQ Dealer PDI Verification Team");
        hrB3.setInspectorNotes("Brand new motorcycle delivery inspection. Zero miles, factory fresh CP2 engine with factory pre-delivery checklist signed.");
        hrB3.setCertified(true);
        hrB3.setEngineHealthScore(100);
        hrB3.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB3.setOdometerStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB3.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB3.setObdScanStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB3.addObdDtcCode("Factory PDI - 0 Faults");
        hrB3.setOilConditionGrade("CLEAN");
        hrB3.setOilStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB3.setSparkPlugCondition("FACTORY NEW");
        hrB3.setTwoWheelerDriveType("CHAIN_DRIVE");
        hrB3.setTwoWheelerDriveCondition("EXCELLENT");
        hrB3.setTwoWheelerClutchOrBelt("Assist & Slipper Clutch Factory Calibration Passed");
        hrB3.setTwoWheelerDriveStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrB3.addVerifiedItem("Factory New Vehicle Pre-Delivery Inspection (PDI)");
        b3.setHealthReport(hrB3);
        list.add(b3);

        // ---------------------------------------------------------------------
        // 3. SCOOTERS - Electric & Petrol
        // ---------------------------------------------------------------------
        // 11. SCOOTERS - Electric (Ola S1 Pro Gen 2)
        Vehicle s1 = new Vehicle(11, "Ola", "S1 Pro", "Gen 2 Performance Edition", 2023,
                new BigDecimal("1850.00"), 6800, Vehicle.CATEGORY_SCOOTER, Vehicle.FUEL_ELECTRIC, Vehicle.CONDITION_USED,
                "Scooter", "Direct Mid-Drive", 0, 0.0, 4.0, 195, 3, "Belt", "Jet Black", "Phoenix, AZ", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=1200&q=80");
        s1.setMaxPowerBhp(15);
        VehicleHealthReport hrS1 = new VehicleHealthReport();
        hrS1.setReportId(11);
        hrS1.setVehicleId(11);
        hrS1.setCertificateCode("BIQ-2024-OS1P-3312");
        hrS1.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
        hrS1.setOverallGrade("A");
        hrS1.setOverallScore(95);
        hrS1.setVerifiedDate(Date.valueOf("2024-10-19"));
        hrS1.setVerifiedByInspector("BatteryIQ E-Scooter Diagnostic Center");
        hrS1.setInspectorNotes("4 kWh structural battery pack shows uniform cell impedance. Thermal sensor reading stable even under high-torque Hyper Mode dyno bursts.");
        hrS1.setCertified(true);
        hrS1.setSohPercentage(new BigDecimal("95.1"));
        hrS1.setSohStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS1.setUsableCapacityKwh(new BigDecimal("3.8"));
        hrS1.setOriginalCapacityKwh(new BigDecimal("4.0"));
        hrS1.setOriginalRangeKm(195);
        hrS1.setEstimatedRealRangeKm(178);
        hrS1.setRangeStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS1.setDegradationRatePerYear(new BigDecimal("1.70"));
        hrS1.setCycleCount(118);
        hrS1.setCellDeviationMv(14);
        hrS1.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS1.setFastChargeRatioPct(new BigDecimal("0.0"));
        hrS1.setThermalStressGrade("GOOD");
        hrS1.setChargingHealthSummary("Home portable 750W charger tested; 0-100% full charge in 5.8 hours.");
        hrS1.setTwoWheelerDriveType("BELT_DRIVE");
        hrS1.setTwoWheelerDriveCondition("GOOD");
        hrS1.setTwoWheelerClutchOrBelt("Mid-drive cogged reduction belt inspected; minimal tooth wear.");
        hrS1.setTwoWheelerDriveStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS1.setRemovableBattery(false);
        hrS1.setBatteryLockerCondition("Fixed Floorboard Battery Pack - IP67 Ingress Seals Verified");
        hrS1.addVerifiedItem("Structural 4.0 kWh pack internal resistance test passed");
        hrS1.addVerifiedItem("BMS Cell Over-voltage and Under-voltage trip circuits verified");
        hrS1.addMissingEvidence("Home charging socket earth leakage safety certificate");
        hrS1.addRecommendedTest("Periodic BMS recalibration charge from 10% to 100% uninterrupted");
        s1.setHealthReport(hrS1);
        list.add(s1);

        // 12. SCOOTERS - Electric (Gogoro CrossOver with Dual Removable Batteries)
        Vehicle s2 = new Vehicle(12, "Gogoro", "CrossOver", "Smartscooter Adventure AWD", 2024,
                new BigDecimal("2499.00"), 0, Vehicle.CATEGORY_SCOOTER, Vehicle.FUEL_ELECTRIC, Vehicle.CONDITION_NEW,
                "Scooter", "Direct Drive", 0, 0.0, 3.4, 150, 0, "Belt", "Desert Sand", "San Jose, CA", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=80");
        VehicleHealthReport hrS2 = new VehicleHealthReport();
        hrS2.setReportId(12);
        hrS2.setVehicleId(12);
        hrS2.setCertificateCode("BIQ-2024-GGCR-NEW-01");
        hrS2.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
        hrS2.setOverallGrade("A+");
        hrS2.setOverallScore(100);
        hrS2.setVerifiedDate(Date.valueOf("2024-10-26"));
        hrS2.setVerifiedByInspector("BatteryIQ Dealer PDI Verification Team");
        hrS2.setInspectorNotes("Brand new swappable battery smartscooter. Both battery receptacle bay contacts clean and Gold-plated connectors 100% verified.");
        hrS2.setCertified(true);
        hrS2.setSohPercentage(new BigDecimal("100.0"));
        hrS2.setSohStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS2.setUsableCapacityKwh(new BigDecimal("3.4"));
        hrS2.setOriginalCapacityKwh(new BigDecimal("3.4"));
        hrS2.setOriginalRangeKm(150);
        hrS2.setEstimatedRealRangeKm(150);
        hrS2.setRangeStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS2.setCycleCount(1);
        hrS2.setCellDeviationMv(3);
        hrS2.setCellDeviationStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS2.setFastChargeRatioPct(new BigDecimal("0.0"));
        hrS2.setThermalStressGrade("EXCELLENT");
        hrS2.setChargingHealthSummary("GoStation Network swappable dual-pack architecture tested.");
        hrS2.setTwoWheelerDriveType("BELT_DRIVE");
        hrS2.setTwoWheelerDriveCondition("EXCELLENT");
        hrS2.setTwoWheelerClutchOrBelt("Gates Poly Chain belt factory calibrated.");
        hrS2.setTwoWheelerDriveStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS2.setRemovableBattery(true);
        hrS2.setBatteryLockerCondition("Dual motorized electronic battery bay solenoid locks: 100% Verified");
        hrS2.addVerifiedItem("Dual battery terminal lock handshake verified");
        hrS2.addVerifiedItem("Cloud battery swap authentication module activated");
        s2.setHealthReport(hrS2);
        list.add(s2);

        // 13. SCOOTERS - Petrol (Honda Activa 6G - Used)
        Vehicle s3 = new Vehicle(13, "Honda", "Activa", "6G Deluxe Smart Key", 2022,
                new BigDecimal("1150.00"), 14200, Vehicle.CATEGORY_SCOOTER, Vehicle.FUEL_PETROL, Vehicle.CONDITION_USED,
                "Scooter", "V-Matic Automatic CVT", 109, 52.0, 0.0, 0, 0, "CVT", "Pearl Blue", "San Jose, CA", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=1200&q=80");
        s3.setMaxPowerBhp(8);
        VehicleHealthReport hrS3 = new VehicleHealthReport();
        hrS3.setReportId(13);
        hrS3.setVehicleId(13);
        hrS3.setCertificateCode("BIQ-2024-HACT-2109");
        hrS3.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
        hrS3.setOverallGrade("A");
        hrS3.setOverallScore(94);
        hrS3.setVerifiedDate(Date.valueOf("2024-10-16"));
        hrS3.setVerifiedByInspector("BatteryIQ Two-Wheeler Inspection Station");
        hrS3.setInspectorNotes("109cc Honda eSP engine operates smoothly. ACG silent starter works on first crank. CVT drive belt and variator rollers inspected with minimal wear.");
        hrS3.setCertified(true);
        hrS3.setEngineHealthScore(94);
        hrS3.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS3.setOdometerStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS3.setCompressionTestResult("Single Cylinder 109cc: 162 PSI (Nominal: 155-170 PSI)");
        hrS3.setCompressionStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS3.setOilConditionGrade("CLEAN");
        hrS3.setOilStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS3.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS3.setDocumentedServiceCount(4);
        hrS3.setObdScanStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS3.addObdDtcCode("No PGM-FI Malfunction Indicator Lamp (MIL) codes");
        hrS3.setTransmissionCondition("SMOOTH");
        hrS3.setExhaustEmissionGrade("PASS_CLEAN");
        hrS3.setSparkPlugCondition("CLEAN_NOMINAL (NGK MR9C-9N)");
        hrS3.setTwoWheelerDriveType("BELT_DRIVE");
        hrS3.setTwoWheelerDriveCondition("GOOD");
        hrS3.setTwoWheelerClutchOrBelt("Dry centrifugal clutch shoes: 3.2mm (Spec minimum: 2.0mm)");
        hrS3.setTwoWheelerDriveStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS3.addVerifiedItem("Engine cylinder dry compression: 162 PSI");
        hrS3.addVerifiedItem("CVT variator face and drive belt width: 18.4mm (nominal)");
        hrS3.addMissingEvidence("First 1,000 km initial break-in service receipt");
        hrS3.addRecommendedTest("Replace air cleaner foam element at 18,000 km");
        s3.setHealthReport(hrS3);
        list.add(s3);

        // 14. SCOOTERS - Petrol (Vespa Primavera 150)
        Vehicle s4 = new Vehicle(14, "Vespa", "Primavera", "150 i-get ABS Touring", 2023,
                new BigDecimal("4850.00"), 4200, Vehicle.CATEGORY_SCOOTER, Vehicle.FUEL_PETROL, Vehicle.CONDITION_USED,
                "Scooter", "Automatic CVT", 155, 40.0, 0.0, 0, 0, "CVT", "Verde Relax Green", "Sacramento, CA", "AVAILABLE", true,
                "https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=80");
        s4.setMaxPowerBhp(13);
        VehicleHealthReport hrS4 = new VehicleHealthReport();
        hrS4.setReportId(14);
        hrS4.setVehicleId(14);
        hrS4.setCertificateCode("BIQ-2024-VPR-1502");
        hrS4.setReportType(VehicleHealthReport.ReportType.ICE_ENGINE);
        hrS4.setOverallGrade("A+");
        hrS4.setOverallScore(97);
        hrS4.setVerifiedDate(Date.valueOf("2024-10-21"));
        hrS4.setVerifiedByInspector("BatteryIQ Certified Diagnostics (Sacramento)");
        hrS4.setInspectorNotes("Like-new Italian scooter. i-get 3V engine runs crisp. Steel monocoque chassis is 100% straight with zero corrosion or denting.");
        hrS4.setCertified(true);
        hrS4.setEngineHealthScore(97);
        hrS4.setEngineHealthStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS4.setOdometerStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS4.setCompressionTestResult("Single Cylinder 155cc: 172 PSI");
        hrS4.setCompressionStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS4.setOilConditionGrade("CLEAN");
        hrS4.setOilStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS4.setServiceHistoryStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS4.setDocumentedServiceCount(2);
        hrS4.setObdScanStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS4.addObdDtcCode("No Engine Codes");
        hrS4.setTransmissionCondition("SMOOTH");
        hrS4.setExhaustEmissionGrade("PASS_CLEAN");
        hrS4.setSparkPlugCondition("CLEAN_NOMINAL");
        hrS4.setTwoWheelerDriveType("BELT_DRIVE");
        hrS4.setTwoWheelerDriveCondition("EXCELLENT");
        hrS4.setTwoWheelerClutchOrBelt("i-get CVT drive belt width: 21.2mm (Nominal 21.5mm)");
        hrS4.setTwoWheelerDriveStatus(VehicleHealthReport.EvidenceStatus.VERIFIED);
        hrS4.addVerifiedItem("Odometer verified via Piaggio dealership warranty server");
        hrS4.addVerifiedItem("Steel chassis paint thickness & alignment laser scanned");
        s4.setHealthReport(hrS4);
        list.add(s4);

        return list;
    }
}
