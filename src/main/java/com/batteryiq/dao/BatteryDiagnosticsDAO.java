package com.batteryiq.dao;

import com.batteryiq.model.BatteryChemistryProfile;
import com.batteryiq.model.BatterySession;
import com.batteryiq.model.BatteryTelemetryPoint;
import com.batteryiq.model.CapacityUnit;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Data Access Object for Battery Intelligence telemetry sessions and time-series points.
 * Interacts with MySQL when available, and provides thread-safe in-memory caching as fallback.
 * Strictly non-destructive: Never drops, truncates, or deletes marketplace data.
 */
public class BatteryDiagnosticsDAO {

    // Thread-safe in-memory cache for fallback when MySQL is offline
    private static final List<BatterySession> IN_MEMORY_SESSIONS = new CopyOnWriteArrayList<>();
    private static final Map<Integer, List<BatteryTelemetryPoint>> IN_MEMORY_READINGS = new ConcurrentHashMap<>();
    private static final AtomicInteger ID_GENERATOR = new AtomicInteger(100);

    static {
        // Seed initial benchmark sessions in-memory for instant demonstration
        initDemoSessions();
    }

    private static void initDemoSessions() {
        BatterySession demoSession1 = new BatterySession();
        demoSession1.setSessionId(1);
        demoSession1.setVehicleId(1); // Linked to Tesla Model 3
        demoSession1.setSessionUuid("BIQ-SESS-NASA-B0005-BENCH");
        demoSession1.setSourceType("PUBLIC_DATASET");
        demoSession1.setDatasetName("NASA Ames Prognostics Center of Excellence (PCoE)");
        demoSession1.setCellOrPackIdentifier("NASA_18650_Cell_B0005");
        demoSession1.setChemistryProfileId("CHEM_NASA_18650");
        demoSession1.setNominalCapacityValue(new BigDecimal("2.000"));
        demoSession1.setFreshBaselineCapacityValue(new BigDecimal("1.856"));
        demoSession1.setCurrentMeasuredCapacityValue(new BigDecimal("1.520"));
        demoSession1.setCapacityUnit(CapacityUnit.AH);
        demoSession1.setActiveReferenceType("FRESH_BASELINE");
        demoSession1.setInitialSocPct(new BigDecimal("100.0"));
        demoSession1.setSocEstimationMethod("COULOMB_COUNTING");
        demoSession1.setEstimatedSohPct(new BigDecimal("81.9"));
        demoSession1.setEstimatedRulCycles(48);
        demoSession1.setConditionCategory("MODERATE");
        demoSession1.setTelemetryStatus("PROCESSED_CLEAN");
        demoSession1.setVerificationStatus("UNVERIFIED_DATASET");
        demoSession1.setRecordedAt(new Timestamp(System.currentTimeMillis() - 86400000L));

        IN_MEMORY_SESSIONS.add(demoSession1);
    }

    /**
     * Saves a battery telemetry session and its associated time-series readings.
     * Attempts MySQL persistence first; if MySQL is unavailable, stores in thread-safe memory.
     */
    public boolean saveSession(BatterySession session, List<BatteryTelemetryPoint> readings) {
        if (session == null) return false;

        if (session.getSessionUuid() == null || session.getSessionUuid().isEmpty()) {
            session.setSessionUuid("BIQ-SESS-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        if (session.getRecordedAt() == null) {
            session.setRecordedAt(new Timestamp(System.currentTimeMillis()));
        }

        Connection conn = null;
        PreparedStatement psSession = null;
        PreparedStatement psReading = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String insertSessionSql = "INSERT INTO battery_telemetry_sessions (" +
                    "vehicle_id, session_uuid, source_type, dataset_name, cell_or_pack_identifier, chemistry_profile_id, " +
                    "nominal_capacity_value, fresh_baseline_capacity_value, current_measured_capacity_value, capacity_unit, active_reference_type, " +
                    "initial_soc_pct, soc_estimation_method, estimated_soh_pct, estimated_rul_cycles, condition_category, " +
                    "telemetry_status, verification_status, hardware_adapter_used, protocol_target_profile, is_hardware_physically_validated, recorded_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            psSession = conn.prepareStatement(insertSessionSql, Statement.RETURN_GENERATED_KEYS);
            if (session.getVehicleId() != null && session.getVehicleId() > 0) {
                psSession.setInt(1, session.getVehicleId());
            } else {
                psSession.setNull(1, Types.INTEGER);
            }
            psSession.setString(2, session.getSessionUuid());
            psSession.setString(3, session.getSourceType());
            psSession.setString(4, session.getDatasetName());
            psSession.setString(5, session.getCellOrPackIdentifier());
            psSession.setString(6, session.getChemistryProfileId());
            psSession.setBigDecimal(7, session.getNominalCapacityValue());
            psSession.setBigDecimal(8, session.getFreshBaselineCapacityValue());
            psSession.setBigDecimal(9, session.getCurrentMeasuredCapacityValue());
            psSession.setString(10, session.getCapacityUnit() != null ? session.getCapacityUnit().name() : "KWH");
            psSession.setString(11, session.getActiveReferenceType());
            psSession.setBigDecimal(12, session.getInitialSocPct());
            psSession.setString(13, session.getSocEstimationMethod());
            psSession.setBigDecimal(14, session.getEstimatedSohPct());
            if (session.getEstimatedRulCycles() != null) {
                psSession.setInt(15, session.getEstimatedRulCycles());
            } else {
                psSession.setNull(15, Types.INTEGER);
            }
            psSession.setString(16, session.getConditionCategory());
            psSession.setString(17, session.getTelemetryStatus());
            psSession.setString(18, session.getVerificationStatus());
            psSession.setString(19, session.getHardwareAdapterUsed());
            psSession.setString(20, session.getProtocolTargetProfile());
            psSession.setBoolean(21, session.isHardwarePhysicallyValidated());
            psSession.setTimestamp(22, session.getRecordedAt());

            psSession.executeUpdate();
            rs = psSession.getGeneratedKeys();

            int generatedSessionId = -1;
            if (rs.next()) {
                generatedSessionId = rs.getInt(1);
                session.setSessionId(generatedSessionId);
            }

            // Insert time-series readings in batch if present
            if (generatedSessionId > 0 && readings != null && !readings.isEmpty()) {
                String insertReadingSql = "INSERT INTO battery_timeseries_readings (" +
                        "session_id, timestamp_offset_ms, voltage_volts, current_amps, temperature_celsius, " +
                        "soc_percentage, cell_delta_mv, active_power_kw, c_rate, has_anomaly, anomaly_description) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                psReading = conn.prepareStatement(insertReadingSql);
                for (BatteryTelemetryPoint p : readings) {
                    p.setSessionId(generatedSessionId);
                    psReading.setInt(1, generatedSessionId);
                    psReading.setLong(2, p.getTimestampOffsetMs());
                    psReading.setBigDecimal(3, p.getVoltageVolts());
                    psReading.setBigDecimal(4, p.getCurrentAmps());
                    psReading.setBigDecimal(5, p.getTemperatureCelsius());
                    psReading.setBigDecimal(6, p.getSocPercentage());
                    if (p.getCellDeltaMv() != null) {
                        psReading.setInt(7, p.getCellDeltaMv());
                    } else {
                        psReading.setNull(7, Types.INTEGER);
                    }
                    psReading.setBigDecimal(8, p.getActivePowerKw());
                    psReading.setBigDecimal(9, p.getcRate());
                    psReading.setBoolean(10, p.isHasAnomaly());
                    psReading.setString(11, p.getAnomalyDescription());
                    psReading.addBatch();
                }
                psReading.executeBatch();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            // Rollback if active connection
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            // Fallback to thread-safe in-memory cache
            return saveSessionInMemory(session, readings);
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (psSession != null) try { psSession.close(); } catch (SQLException ignored) {}
            if (psReading != null) try { psReading.close(); } catch (SQLException ignored) {}
            DBConnection.closeConnection(conn);
        }
    }

    private boolean saveSessionInMemory(BatterySession session, List<BatteryTelemetryPoint> readings) {
        int id = ID_GENERATOR.incrementAndGet();
        session.setSessionId(id);
        IN_MEMORY_SESSIONS.add(0, session);
        if (readings != null) {
            for (BatteryTelemetryPoint p : readings) {
                p.setSessionId(id);
            }
            IN_MEMORY_READINGS.put(id, new ArrayList<>(readings));
        }
        return true;
    }

    /**
     * Retrieves all recorded battery telemetry sessions (recent first).
     */
    public List<BatterySession> getAllSessions() {
        List<BatterySession> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM battery_telemetry_sessions ORDER BY session_id DESC LIMIT 50";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapSessionFromResultSet(rs));
            }
        } catch (Exception e) {
            // Return in-memory list
            return new ArrayList<>(IN_MEMORY_SESSIONS);
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
            DBConnection.closeConnection(conn);
        }

        if (list.isEmpty()) {
            return new ArrayList<>(IN_MEMORY_SESSIONS);
        }
        return list;
    }

    /**
     * Retrieves a single session by its session ID.
     */
    public BatterySession getSessionById(int sessionId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM battery_telemetry_sessions WHERE session_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, sessionId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapSessionFromResultSet(rs);
            }
        } catch (Exception e) {
            for (BatterySession s : IN_MEMORY_SESSIONS) {
                if (s.getSessionId() == sessionId) {
                    return s;
                }
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
            DBConnection.closeConnection(conn);
        }

        for (BatterySession s : IN_MEMORY_SESSIONS) {
            if (s.getSessionId() == sessionId) {
                return s;
            }
        }
        return null;
    }

    /**
     * Retrieves time-series readings for a given session ID.
     */
    public List<BatteryTelemetryPoint> getReadingsForSession(int sessionId) {
        List<BatteryTelemetryPoint> points = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM battery_timeseries_readings WHERE session_id = ? ORDER BY timestamp_offset_ms ASC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, sessionId);
            rs = ps.executeQuery();

            while (rs.next()) {
                BatteryTelemetryPoint p = new BatteryTelemetryPoint();
                p.setReadingId(rs.getLong("reading_id"));
                p.setSessionId(rs.getInt("session_id"));
                p.setTimestampOffsetMs(rs.getLong("timestamp_offset_ms"));
                p.setVoltageVolts(rs.getBigDecimal("voltage_volts"));
                p.setCurrentAmps(rs.getBigDecimal("current_amps"));
                p.setTemperatureCelsius(rs.getBigDecimal("temperature_celsius"));
                p.setSocPercentage(rs.getBigDecimal("soc_percentage"));
                int delta = rs.getInt("cell_delta_mv");
                p.setCellDeltaMv(rs.wasNull() ? null : delta);
                p.setActivePowerKw(rs.getBigDecimal("active_power_kw"));
                p.setcRate(rs.getBigDecimal("c_rate"));
                p.setHasAnomaly(rs.getBoolean("has_anomaly"));
                p.setAnomalyDescription(rs.getString("anomaly_description"));
                points.add(p);
            }
        } catch (Exception e) {
            List<BatteryTelemetryPoint> mem = IN_MEMORY_READINGS.get(sessionId);
            return mem != null ? new ArrayList<>(mem) : new ArrayList<BatteryTelemetryPoint>();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
            DBConnection.closeConnection(conn);
        }

        if (points.isEmpty()) {
            List<BatteryTelemetryPoint> mem = IN_MEMORY_READINGS.get(sessionId);
            return mem != null ? new ArrayList<>(mem) : points;
        }
        return points;
    }

    private BatterySession mapSessionFromResultSet(ResultSet rs) throws SQLException {
        BatterySession s = new BatterySession();
        s.setSessionId(rs.getInt("session_id"));
        int vId = rs.getInt("vehicle_id");
        s.setVehicleId(rs.wasNull() ? null : vId);
        s.setSessionUuid(rs.getString("session_uuid"));
        s.setSourceType(rs.getString("source_type"));
        s.setDatasetName(rs.getString("dataset_name"));
        s.setCellOrPackIdentifier(rs.getString("cell_or_pack_identifier"));
        s.setChemistryProfileId(rs.getString("chemistry_profile_id"));
        s.setNominalCapacityValue(rs.getBigDecimal("nominal_capacity_value"));
        s.setFreshBaselineCapacityValue(rs.getBigDecimal("fresh_baseline_capacity_value"));
        s.setCurrentMeasuredCapacityValue(rs.getBigDecimal("current_measured_capacity_value"));
        s.setCapacityUnit(CapacityUnit.fromString(rs.getString("capacity_unit")));
        s.setActiveReferenceType(rs.getString("active_reference_type"));
        s.setInitialSocPct(rs.getBigDecimal("initial_soc_pct"));
        s.setSocEstimationMethod(rs.getString("soc_estimation_method"));
        s.setEstimatedSohPct(rs.getBigDecimal("estimated_soh_pct"));
        int rul = rs.getInt("estimated_rul_cycles");
        s.setEstimatedRulCycles(rs.wasNull() ? null : rul);
        s.setConditionCategory(rs.getString("condition_category"));
        s.setTelemetryStatus(rs.getString("telemetry_status"));
        s.setVerificationStatus(rs.getString("verification_status"));
        s.setHardwareAdapterUsed(rs.getString("hardware_adapter_used"));
        s.setProtocolTargetProfile(rs.getString("protocol_target_profile"));
        s.setHardwarePhysicallyValidated(rs.getBoolean("is_hardware_physically_validated"));
        s.setRecordedAt(rs.getTimestamp("recorded_at"));
        return s;
    }
}

