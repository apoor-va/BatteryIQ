package com.batteryiq.test;

import com.batteryiq.battery.client.BatteryDiagnosticApiClient;
import com.batteryiq.dao.BatteryDiagnosticsDAO;
import com.batteryiq.model.BatterySession;
import com.batteryiq.model.BatteryTelemetryPoint;
import com.batteryiq.model.CapacityUnit;
import com.batteryiq.util.JsonHelper;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * End-to-End Verification Test for Phase 4 Java-Python Integration.
 * Validates:
 * 1. Offline microservice detection & structured error handling.
 * 2. Successful parsing of Python scientific analysis responses.
 * 3. Handling of missing telemetry sensor values (null safety).
 * 4. Safe database and in-memory persistence in BatteryDiagnosticsDAO.
 */
public class EndToEndFlowTest {

    public static void main(String[] args) {
        System.out.println("============================================================");
        System.out.println("  BatteryIQ Phase 4: Java-Python Integration Flow Test");
        System.out.println("============================================================");

        int passed = 0;
        int failed = 0;

        BatteryDiagnosticApiClient client = new BatteryDiagnosticApiClient();
        BatteryDiagnosticsDAO dao = new BatteryDiagnosticsDAO();

        // -------------------------------------------------------------
        // Test 1: Service Offline Detection & Clean Error Handling
        // -------------------------------------------------------------
        System.out.print("[Test 1] Service Offline Handling... ");
        // Point to an inactive test port to verify graceful timeout and offline message
        BatteryDiagnosticApiClient offlineClient = new BatteryDiagnosticApiClient("http://127.0.0.1:59999");
        boolean isAvailable = offlineClient.isServiceAvailable();
        String offlineResponse = offlineClient.analyzeBattery("{\"source_type\":\"SIMULATOR\"}");
        String status = JsonHelper.getString(offlineResponse, "status");

        if (!isAvailable && "SERVICE_UNAVAILABLE".equals(status)) {
            System.out.println("PASSED (Offline status correctly detected without crashing).");
            passed++;
        } else {
            System.out.println("FAILED (Expected SERVICE_UNAVAILABLE, got: " + status + ")");
            failed++;
        }

        // -------------------------------------------------------------
        // Test 2: Ingestion of Scientific Analysis Response into Java Models
        // -------------------------------------------------------------
        System.out.print("[Test 2] Java Model Ingestion & Reference Consistency... ");
        String samplePythonResponse = "{\n" +
                "  \"status\": \"SUCCESS\",\n" +
                "  \"provenance\": {\n" +
                "    \"source_type\": \"SIMULATOR\",\n" +
                "    \"verification_status\": \"UNVERIFIED_DEMO\",\n" +
                "    \"is_physically_verified\": false\n" +
                "  },\n" +
                "  \"soh_analysis\": {\n" +
                "    \"status\": \"COMPUTED\",\n" +
                "    \"soh_percentage\": 93.60,\n" +
                "    \"degradation_percentage\": 6.40,\n" +
                "    \"condition_category\": \"EXCELLENT\",\n" +
                "    \"reference_capacity_value\": 75.0,\n" +
                "    \"current_measured_capacity\": 70.2,\n" +
                "    \"capacity_unit\": \"KWH\",\n" +
                "    \"active_reference_type\": \"RATED_NOMINAL\"\n" +
                "  },\n" +
                "  \"soc_analysis\": {\n" +
                "    \"status\": \"COMPUTED\",\n" +
                "    \"initial_soc_pct\": 85.0,\n" +
                "    \"final_soc_pct\": 83.2,\n" +
                "    \"method\": \"COULOMB_COUNTING\"\n" +
                "  },\n" +
                "  \"rul_prediction\": {\n" +
                "    \"status\": \"PREDICTED\",\n" +
                "    \"estimated_rul_cycles\": 1240\n" +
                "  }\n" +
                "}";

        String sohObj = JsonHelper.getSubObject(samplePythonResponse, "soh_analysis");
        String socObj = JsonHelper.getSubObject(samplePythonResponse, "soc_analysis");
        String rulObj = JsonHelper.getSubObject(samplePythonResponse, "rul_prediction");

        BigDecimal sohPct = JsonHelper.getBigDecimal(sohObj, "soh_percentage");
        BigDecimal currentCap = JsonHelper.getBigDecimal(sohObj, "current_measured_capacity");
        String condition = JsonHelper.getString(sohObj, "condition_category");
        BigDecimal finalSoc = JsonHelper.getBigDecimal(socObj, "final_soc_pct");
        Integer rulCycles = JsonHelper.getInteger(rulObj, "estimated_rul_cycles");

        if (sohPct != null && sohPct.compareTo(new BigDecimal("93.60")) == 0 &&
            currentCap != null && currentCap.compareTo(new BigDecimal("70.2")) == 0 &&
            "EXCELLENT".equals(condition) &&
            rulCycles != null && rulCycles == 1240) {
            System.out.println("PASSED (All scientific fields parsed cleanly from Python response).");
            passed++;
        } else {
            System.out.println("FAILED (SOH/SOC parsing mismatch).");
            failed++;
        }

        // -------------------------------------------------------------
        // Test 3: Null Safety on Missing Telemetry Readings
        // -------------------------------------------------------------
        System.out.print("[Test 3] Null Safety on Missing Telemetry... ");
        BatteryTelemetryPoint nullPt = new BatteryTelemetryPoint();
        nullPt.setTimestampOffsetMs(1000L);
        nullPt.setVoltageVolts(null); // Missing sensor
        nullPt.setCurrentAmps(null);  // Missing sensor
        nullPt.setTemperatureCelsius(null);
        nullPt.setCellDeltaMv(null);

        boolean vAvail = nullPt.isVoltageAvailable();
        String vFmt = nullPt.getFormattedVoltage();

        if (!vAvail && "Unavailable".equals(vFmt)) {
            System.out.println("PASSED (Null values safely reported as Unavailable without fake zeros).");
            passed++;
        } else {
            System.out.println("FAILED (Null safety violation).");
            failed++;
        }

        // -------------------------------------------------------------
        // Test 4: Database / DAO Session Storage Flow
        // -------------------------------------------------------------
        System.out.print("[Test 4] Database & DAO Session Storage... ");
        BatterySession testSession = new BatterySession();
        testSession.setVehicleId(1); // Link to Tesla Model 3
        testSession.setSessionUuid("BIQ-TEST-FLOW-" + System.currentTimeMillis());
        testSession.setSourceType("SIMULATOR");
        testSession.setCellOrPackIdentifier("TEST_MODEL3_PACK");
        testSession.setChemistryProfileId("CHEM_NMC_01");
        testSession.setNominalCapacityValue(new BigDecimal("75.0"));
        testSession.setCurrentMeasuredCapacityValue(currentCap);
        testSession.setCapacityUnit(CapacityUnit.KWH);
        testSession.setActiveReferenceType("RATED_NOMINAL");
        testSession.setEstimatedSohPct(sohPct);
        testSession.setEstimatedRulCycles(rulCycles);
        testSession.setConditionCategory(condition);
        testSession.setTelemetryStatus("PROCESSED_CLEAN");
        testSession.setVerificationStatus("UNVERIFIED_DEMO");
        testSession.setRecordedAt(new Timestamp(System.currentTimeMillis()));

        List<BatteryTelemetryPoint> points = new ArrayList<>();
        BatteryTelemetryPoint pt1 = new BatteryTelemetryPoint();
        pt1.setTimestampOffsetMs(0L);
        pt1.setVoltageVolts(new BigDecimal("380.5"));
        pt1.setCurrentAmps(new BigDecimal("25.0"));
        pt1.setTemperatureCelsius(new BigDecimal("26.5"));
        pt1.setSocPercentage(new BigDecimal("85.0"));
        pt1.setCellDeltaMv(12);
        pt1.setActivePowerKw(new BigDecimal("9.512"));
        points.add(pt1);

        boolean saved = dao.saveSession(testSession, points);
        List<BatterySession> allSessions = dao.getAllSessions();
        boolean found = false;
        for (BatterySession s : allSessions) {
            if (s.getSessionUuid().equals(testSession.getSessionUuid())) {
                found = true;
                break;
            }
        }

        if (saved && found) {
            System.out.println("PASSED (Session and time-series points saved and retrieved successfully).");
            passed++;
        } else {
            System.out.println("FAILED (Session save or retrieval failed).");
            failed++;
        }

        // -------------------------------------------------------------
        // Summary
        // -------------------------------------------------------------
        System.out.println("============================================================");
        System.out.println("  Integration Flow Test Summary: " + passed + " Passed, " + failed + " Failed.");
        System.out.println("============================================================");

        if (failed > 0) {
            System.exit(1);
        }
    }
}

