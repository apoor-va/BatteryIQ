package com.batteryiq.hardware.adapter;

import java.util.*;

/**
 * Mock OBD-II / ELM327 Diagnostic Adapter for Software Testing and Verification.
 *
 * CRITICAL TRANSPARENCY NOTICE:
 * This class is strictly a software test harness. Telemetry produced by this mock adapter
 * is explicitly labeled as UNVERIFIED_DEMO and must NEVER be presented as authentic physical
 * vehicle telematics.
 */
public class MockOBD2Adapter implements OBD2Adapter {

    private ConnectionStatus status = ConnectionStatus.DISCONNECTED;
    private String deviceId = "MOCK_ELM327_v1.5_SOFTWARE_HARNESS";
    private String vehicleVin = null;
    private String lastError = null;
    private boolean isStreaming = false;

    // Simulation Fault Injection Flags
    private boolean simulateTimeout = false;
    private boolean simulateBusError = false;
    private boolean simulateMissingSignals = false;

    // Simulated Vehicle Telemetry State
    private double currentVoltage = 384.5;
    private double currentAmps = 14.2;
    private double currentTemp = 28.0;
    private double currentSoc = 78.5;

    @Override
    public boolean connect(String connectionUri) {
        this.status = ConnectionStatus.CONNECTING;

        if (simulateTimeout) {
            this.status = ConnectionStatus.TIMEOUT;
            this.lastError = "Connection attempt timed out. No response from adapter.";
            return false;
        }

        if (simulateBusError) {
            this.status = ConnectionStatus.ERROR;
            this.lastError = "Hardware handshake failed: BUS BUSY / CAN ERROR.";
            return false;
        }

        // Successful simulated connection
        this.status = ConnectionStatus.CONNECTED;
        this.deviceId = "MOCK_ELM327_v1.5 (Port: " + (connectionUri != null ? connectionUri : "COM3") + ")";
        this.vehicleVin = "1N4AZ0CP8DC309182"; // Documented sample Nissan Leaf VIN format
        this.lastError = null;
        return true;
    }

    @Override
    public void disconnect() {
        this.status = ConnectionStatus.DISCONNECTED;
        this.isStreaming = false;
        this.lastError = null;
    }

    @Override
    public ConnectionStatus getConnectionStatus() {
        return status;
    }

    @Override
    public String getDeviceId() {
        return deviceId;
    }

    @Override
    public String getVehicleVin() {
        return vehicleVin;
    }

    @Override
    public String getLastError() {
        return lastError;
    }

    @Override
    public boolean isStreaming() {
        return isStreaming;
    }

    public void setStreaming(boolean streaming) {
        this.isStreaming = streaming;
        if (streaming && status == ConnectionStatus.CONNECTED) {
            this.status = ConnectionStatus.STREAMING;
        } else if (!streaming && status == ConnectionStatus.STREAMING) {
            this.status = ConnectionStatus.CONNECTED;
        }
    }

    @Override
    public boolean setProtocol(String protocolCommand) {
        if (status == ConnectionStatus.DISCONNECTED) {
            return false;
        }
        return "ATSP6".equalsIgnoreCase(protocolCommand) || "ATSPA6".equalsIgnoreCase(protocolCommand);
    }

    @Override
    public String sendCommand(String command) {
        if (status == ConnectionStatus.DISCONNECTED) {
            return "ERROR: ADAPTER DISCONNECTED";
        }

        if (simulateTimeout) {
            this.status = ConnectionStatus.TIMEOUT;
            this.lastError = "ECU request timed out.";
            return "TIMEOUT";
        }

        if (simulateBusError) {
            this.status = ConnectionStatus.ERROR;
            this.lastError = "Bus arbitration lost.";
            return "CAN ERROR";
        }

        String cmd = (command != null) ? command.trim().toUpperCase() : "";

        // Standard ELM327 AT Commands
        if ("ATZ".equals(cmd)) {
            return "ELM327 v1.5";
        } else if ("ATE0".equals(cmd) || "ATH1".equals(cmd) || "ATL0".equals(cmd) || "ATS0".equals(cmd)) {
            return "OK";
        } else if ("ATSP6".equals(cmd) || "ATSPA6".equals(cmd)) {
            return "OK";
        } else if ("ATDP".equals(cmd)) {
            return "ISO 15765-4 (CAN 11/500)";
        } else if ("ATRV".equals(cmd)) {
            return "12.6V"; // Auxiliary 12V battery voltage
        } else if (cmd.startsWith("ATSH")) {
            return "OK"; // Header set
        } else if ("0902".equals(cmd)) {
            return "49 02 01 31 4E 34 41 5A 30 43 50 38 44 43 33 30 39 31 38 32"; // VIN bytes in hex
        } else if (cmd.startsWith("01")) {
            // Standard Mode 01 ICE PIDs
            return handleMode01Command(cmd);
        } else if (cmd.startsWith("22")) {
            // UDS ReadDataByIdentifier
            return handleUdsCommand(cmd);
        }

        return "?";
    }

    private String handleMode01Command(String cmd) {
        // Mode 01 PID 00 (Supported PIDs)
        if ("0100".equals(cmd)) {
            return "41 00 BE 3E B8 11";
        }
        // Notice: Standard OBD-II does NOT define traction battery voltage or SOH!
        return "NO DATA";
    }

    private String handleUdsCommand(String cmd) {
        if (simulateMissingSignals) {
            return "NO DATA";
        }
        // UDS DID 0x2001 (Simulated Custom EV Battery DID)
        if ("222001".equals(cmd)) {
            int vRaw = (int) (currentVoltage * 10);
            int iRaw = (int) ((currentAmps + 500.0) * 10); // Offset 500A
            int socRaw = (int) (currentSoc * 10);
            int tempRaw = (int) (currentTemp + 40.0);
            return String.format("62 20 01 %04X %04X %04X %02X", vRaw, iRaw, socRaw, tempRaw);
        }
        return "NO DATA";
    }

    @Override
    public String queryStandardPid(int mode, int pid) {
        String cmd = String.format("%02X%02X", mode, pid);
        return sendCommand(cmd);
    }

    @Override
    public String queryUdsDid(String ecuTxId, String ecuRxId, String didHex) {
        // In ELM327, set header with AT SH, then transmit 22 DID
        sendCommand("ATSH" + ecuTxId);
        return sendCommand("22" + didHex);
    }

    @Override
    public String queryVin() {
        return vehicleVin;
    }

    @Override
    public boolean isEvBatteryReportingSupported() {
        // Honest disclosure: Standard OBD-II Mode 01 does not support traction battery reporting
        return false;
    }

    // -------------------------------------------------------------------------
    // Fault Injection and Telemetry Mutation for Testing
    // -------------------------------------------------------------------------

    public void setSimulateTimeout(boolean simulateTimeout) {
        this.simulateTimeout = simulateTimeout;
    }

    public void setSimulateBusError(boolean simulateBusError) {
        this.simulateBusError = simulateBusError;
    }

    public void setSimulateMissingSignals(boolean simulateMissingSignals) {
        this.simulateMissingSignals = simulateMissingSignals;
    }

    public void setTelemetryState(double voltage, double current, double temp, double soc) {
        this.currentVoltage = voltage;
        this.currentAmps = current;
        this.currentTemp = temp;
        this.currentSoc = soc;
    }

    @Override
    public Map<String, Object> getDiagnosticMetadata() {
        Map<String, Object> meta = new HashMap<String, Object>();
        meta.put("adapter_type", "MOCK_OBD2");
        meta.put("device_id", deviceId);
        meta.put("status", status.name());
        meta.put("status_label", status.getLabel());
        meta.put("vin", vehicleVin);
        meta.put("is_streaming", isStreaming);
        meta.put("last_error", lastError);
        meta.put("standard_obd_ev_supported", false);
        meta.put("hardware_verified", false);
        meta.put("simulation_harness", true);
        return meta;
    }
}
