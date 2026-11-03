package com.batteryiq.test;

import com.batteryiq.hardware.adapter.*;
import com.batteryiq.hardware.protocol.*;
import com.batteryiq.hardware.telemetry.*;
import com.batteryiq.model.BatterySession;
import com.batteryiq.model.BatteryTelemetryPoint;

import java.util.List;
import java.util.Map;

/**
 * Phase 6 Test Suite: Hardware Abstraction Layer (HAL) & Live Telemetry Architecture.
 * Verifies adapter connection lifecycle, AT/UDS queries, CAN decoding, fault injection,
 * and strict verification status boundaries.
 */
public class HardwareAbstractionLayerTest {

    public static void main(String[] args) {
        System.out.println("============================================================");
        System.out.println("  BatteryIQ Phase 6: Hardware Abstraction Layer (HAL) Test");
        System.out.println("============================================================");

        int passed = 0;
        int failed = 0;

        // Test 1: Mock OBD-II Adapter Handshake & AT Protocol Configuration
        try {
            System.out.print("[Test 1] Mock OBD-II Handshake & AT Commands... ");
            MockOBD2Adapter obd = new MockOBD2Adapter();
            assertCondition(obd.getConnectionStatus() == ConnectionStatus.DISCONNECTED, "Initial status should be DISCONNECTED");

            boolean connected = obd.connect("COM3");
            assertCondition(connected, "Connection to COM3 should succeed");
            assertCondition(obd.getConnectionStatus() == ConnectionStatus.CONNECTED, "Status should be CONNECTED");

            String atz = obd.sendCommand("ATZ");
            assertCondition("ELM327 v1.5".equals(atz), "ATZ should return ELM327 v1.5, got: " + atz);

            String ate0 = obd.sendCommand("ATE0");
            assertCondition("OK".equals(ate0), "ATE0 should return OK");

            String atsp6 = obd.sendCommand("ATSP6");
            assertCondition("OK".equals(atsp6), "ATSP6 should return OK");

            String vin = obd.sendCommand("0902");
            assertCondition(vin != null && vin.startsWith("49 02"), "Mode 09 PID 02 should return VIN payload");

            obd.disconnect();
            assertCondition(obd.getConnectionStatus() == ConnectionStatus.DISCONNECTED, "Status should reset to DISCONNECTED");

            System.out.println("PASSED");
            passed++;
        } catch (Throwable t) {
            System.out.println("FAILED: " + t.getMessage());
            failed++;
        }

        // Test 2: Fault Injection (Timeout, Bus Error, Missing Signals)
        try {
            System.out.print("[Test 2] Fault Injection Handling (Timeout, Bus Error)... ");
            MockOBD2Adapter obd = new MockOBD2Adapter();

            // 2a. Simulated Timeout
            obd.setSimulateTimeout(true);
            boolean connTimeout = obd.connect("COM3");
            assertCondition(!connTimeout, "Connect should fail during timeout");
            assertCondition(obd.getConnectionStatus() == ConnectionStatus.TIMEOUT, "Status should be TIMEOUT");
            obd.setSimulateTimeout(false);

            // 2b. Simulated Bus Error
            obd.setSimulateBusError(true);
            boolean connError = obd.connect("COM3");
            assertCondition(!connError, "Connect should fail during bus error");
            assertCondition(obd.getConnectionStatus() == ConnectionStatus.ERROR, "Status should be ERROR");
            obd.setSimulateBusError(false);

            // 2c. Simulated Missing Signals
            obd.connect("COM3");
            obd.setSimulateMissingSignals(true);
            String udsNoData = obd.sendCommand("222001");
            assertCondition("NO DATA".equals(udsNoData), "Missing signals should return NO DATA, got: " + udsNoData);
            obd.disconnect();

            System.out.println("PASSED");
            passed++;
        } catch (Throwable t) {
            System.out.println("FAILED: " + t.getMessage());
            failed++;
        }

        // Test 3: CAN Frame Decoding using Nissan Leaf Profile
        try {
            System.out.print("[Test 3] CAN Bus Frame Decoding & Physical Scaling... ");
            VehicleCANProfile leafProfile = VehicleCANProfile.createNissanLeafProfile();
            CANSignalDecoder decoder = new CANSignalDecoder(leafProfile);

            // 3a. Frame 0x1DB: Pack Voltage (0.5V/bit, bits 16..25) & Current (0.5A signed, bits 0..10)
            // Voltage = 380V -> raw = 760 (0x2F8). Current = 20A -> raw = 40 (0x028)
            byte[] p1 = new byte[8];
            int iRaw = (int) (20.0 / 0.5) & 0x7FF; // 40
            int vRaw = (int) (380.0 / 0.5);        // 760
            p1[0] = (byte) ((iRaw >> 3) & 0xFF);
            p1[1] = (byte) ((iRaw & 0x07) << 5);
            p1[2] = (byte) ((vRaw >> 2) & 0xFF);
            p1[3] = (byte) ((vRaw & 0x03) << 6);

            CANFrame f1 = new CANFrame(0x1DB, p1, 1000L);
            Map<String, Object> decoded1 = decoder.decodeFrame(f1);

            assertCondition(decoded1.containsKey("voltage_volts"), "Should contain voltage_volts");
            Double vDecoded = (Double) decoded1.get("voltage_volts");
            assertCondition(Math.abs(vDecoded - 380.0) < 1.0, "Decoded voltage should be ~380V, got: " + vDecoded);

            assertCondition(decoded1.containsKey("current_amps"), "Should contain current_amps");
            Double iDecoded = (Double) decoded1.get("current_amps");
            assertCondition(Math.abs(iDecoded - 20.0) < 1.0, "Decoded current should be ~20A, got: " + iDecoded);

            // 3b. Frame 0x5BC: SOC (0.1%/bit, bits 0..9) -> 82.5% = raw 825 (0x339)
            byte[] p2 = new byte[8];
            int socRaw = 825;
            p2[0] = (byte) ((socRaw >> 2) & 0xFF);
            p2[1] = (byte) ((socRaw & 0x03) << 6);
            CANFrame f2 = new CANFrame(0x5BC, p2, 1000L);
            Map<String, Object> decoded2 = decoder.decodeFrame(f2);
            assertCondition(decoded2.containsKey("soc_percentage"), "Should contain soc_percentage");
            Double socDecoded = (Double) decoded2.get("soc_percentage");
            assertCondition(Math.abs(socDecoded - 82.5) < 0.2, "Decoded SOC should be ~82.5%, got: " + socDecoded);

            System.out.println("PASSED");
            passed++;
        } catch (Throwable t) {
            System.out.println("FAILED: " + t.getMessage());
            failed++;
        }

        // Test 4: LiveTelemetryPacket Null-Safety & Unsupported Signal Accounting
        try {
            System.out.print("[Test 4] Common Telemetry Packet Null-Safety & Unsupported Signals... ");
            LiveTelemetryPacket pkt = new LiveTelemetryPacket();
            pkt.setVoltageVolts(382.4);
            pkt.setCurrentAmps(16.5);
            pkt.setSocPercentage(79.0);
            // Notice: Cell Delta is NOT reported on this packet
            pkt.setCellDeltaMv(null);
            pkt.addUnsupportedSignal("cell_delta_mv (Unsupported on standard OBD-II)");

            assertCondition(pkt.getVoltageVolts() != null, "Voltage should not be null");
            assertCondition(pkt.getCellDeltaMv() == null, "Cell delta must remain strictly null when unsupported");
            assertCondition(pkt.getActivePowerKw() != null, "Active power should be calculated from V & I");
            assertCondition(Math.abs(pkt.getActivePowerKw() - 6.31) < 0.1, "Active power should be ~6.31 kW, got: " + pkt.getActivePowerKw());
            assertCondition(pkt.getUnsupportedSignals().size() == 1, "Should record 1 unsupported signal");

            System.out.println("PASSED");
            passed++;
        } catch (Throwable t) {
            System.out.println("FAILED: " + t.getMessage());
            failed++;
        }

        // Test 5: LiveTelemetryManager Lifecycle & Verification Separation
        try {
            System.out.print("[Test 5] LiveTelemetryManager & Strict Verification Boundary... ");
            LiveTelemetryManager tm = LiveTelemetryManager.getInstance();

            // Connect Mock OBD2
            boolean ok = tm.connectAdapter("MOCK_OBD2", "COM3", "PROFILE_NISSAN_LEAF_AZE0");
            assertCondition(ok, "Adapter connect should succeed");
            assertCondition(tm.getActiveAdapter() != null, "Active adapter should not be null");

            // Poll live frame
            LiveTelemetryPacket polled = tm.pollTelemetry();
            assertCondition(polled != null, "Polled packet should not be null");
            assertCondition(polled.getVoltageVolts() != null, "Polled voltage should not be null");
            assertCondition(polled.getCurrentAmps() != null, "Polled current should not be null");
            assertCondition(polled.getSocPercentage() != null, "Polled SOC should not be null");

            // Execute analyze and persist
            Map<String, Object> sessionResult = tm.analyzeAndPersistSession(null, "CHEM_NMC_01", 75.0, "KWH");
            assertCondition("SUCCESS".equals(sessionResult.get("status")), "Session persistence should succeed");

            BatterySession session = (BatterySession) sessionResult.get("session");
            assertCondition("LIVE_OBD".equals(session.getSourceType()), "Source type must strictly be LIVE_OBD");
            assertCondition("UNVERIFIED_LIVE_TELEMETRY".equals(session.getVerificationStatus()),
                    "Verification status must strictly be UNVERIFIED_LIVE_TELEMETRY, got: " + session.getVerificationStatus());
            assertCondition(!session.isPhysicallyVerified(), "is_hardware_physically_validated must be FALSE");
            assertCondition(session.getHardwareAdapterUsed() != null, "Hardware adapter used must be recorded");

            tm.disconnectAdapter();
            assertCondition(tm.getActiveAdapter() == null, "Active adapter should be null after disconnect");

            System.out.println("PASSED");
            passed++;
        } catch (Throwable t) {
            System.out.println("FAILED: " + t.getMessage());
            failed++;
        }

        System.out.println("============================================================");
        System.out.println("  HAL Test Summary: " + passed + " Passed, " + failed + " Failed.");
        System.out.println("============================================================");

        if (failed > 0) {
            System.exit(1);
        }
    }

    private static void assertCondition(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}

