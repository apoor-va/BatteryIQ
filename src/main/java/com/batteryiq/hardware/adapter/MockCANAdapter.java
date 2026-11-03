package com.batteryiq.hardware.adapter;

import com.batteryiq.hardware.protocol.CANFrame;
import com.batteryiq.hardware.protocol.CANFrameListener;

import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Mock CAN Bus Adapter for Software Testing and Protocol Verification.
 * Simulates low-latency CAN frame streaming conforming to documented vehicle profiles.
 *
 * CRITICAL NOTICE: Strictly a software emulation tool. Not physically attached to a real CAN bus.
 */
public class MockCANAdapter implements CANAdapter {

    private ConnectionStatus status = ConnectionStatus.DISCONNECTED;
    private String deviceId = "MOCK_CANABLE_SLCAN_USB";
    private int bitRate = 500000;
    private String lastError = null;
    private boolean isStreaming = false;
    private final List<CANFrameListener> listeners = new CopyOnWriteArrayList<CANFrameListener>();

    // Simulated Telemetry Parameters
    private double voltage = 392.4;
    private double current = 22.8;
    private double soc = 81.2;
    private double temperature = 27.5;
    private int cellDeltaMv = 14;

    private boolean simulateError = false;
    private boolean simulateMissingSignals = false;

    @Override
    public boolean connect(String connectionUri) {
        this.status = ConnectionStatus.CONNECTING;
        if (simulateError) {
            this.status = ConnectionStatus.ERROR;
            this.lastError = "CAN controller initialization failed: Bitrate mismatch or transceiver fault.";
            return false;
        }

        this.status = ConnectionStatus.CONNECTED;
        this.deviceId = "MOCK_CANABLE_v2.0 (Interface: " + (connectionUri != null ? connectionUri : "slcan0") + ")";
        this.lastError = null;
        return true;
    }

    @Override
    public void disconnect() {
        this.status = ConnectionStatus.DISCONNECTED;
        this.isStreaming = false;
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
        return null; // Direct CAN bus monitoring does not broadcast VIN unless explicitly queried
    }

    @Override
    public String sendCommand(String command) {
        return "OK";
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
    public boolean sendFrame(CANFrame frame) {
        if (status != ConnectionStatus.CONNECTED && status != ConnectionStatus.STREAMING) {
            return false;
        }
        return true;
    }

    @Override
    public void registerFrameListener(CANFrameListener listener) {
        if (listener != null && !listeners.contains(listener)) {
            listeners.add(listener);
        }
    }

    @Override
    public void unregisterFrameListener(CANFrameListener listener) {
        listeners.remove(listener);
    }

    @Override
    public int getBitRate() {
        return bitRate;
    }

    @Override
    public boolean setFilter(int filterId, int mask) {
        return true;
    }

    /**
     * Emit simulated Nissan Leaf CAN frames to registered listeners.
     */
    public void emitNissanLeafFrames(long timestampMs) {
        if (simulateError) {
            for (CANFrameListener l : listeners) {
                l.onBusError("Arbitration lost on CAN ID 0x1DB.");
            }
            return;
        }

        // Frame 0x1DB: Voltage (0.5V/bit, bits 16..25) & Current (0.5A signed, bits 0..10)
        int vRaw = (int) (voltage / 0.5);
        int iRaw = (int) (current / 0.5) & 0x7FF;
        byte[] p1 = new byte[8];
        p1[0] = (byte) ((iRaw >> 3) & 0xFF);
        p1[1] = (byte) ((iRaw & 0x07) << 5);
        p1[2] = (byte) ((vRaw >> 2) & 0xFF);
        p1[3] = (byte) ((vRaw & 0x03) << 6);
        CANFrame f1 = new CANFrame(0x1DB, p1, timestampMs);

        // Frame 0x5BC: SOC (0.1%/bit, bits 0..9) & Capacity
        int socRaw = (int) (soc / 0.1);
        byte[] p2 = new byte[8];
        p2[0] = (byte) ((socRaw >> 2) & 0xFF);
        p2[1] = (byte) ((socRaw & 0x03) << 6);
        CANFrame f2 = new CANFrame(0x5BC, p2, timestampMs);

        // Frame 0x55B: Temperature (0.5°C/bit, offset -40, bits 0..7)
        int tRaw = (int) ((temperature + 40.0) / 0.5);
        byte[] p3 = new byte[8];
        p3[0] = (byte) (tRaw & 0xFF);
        CANFrame f3 = new CANFrame(0x55B, p3, timestampMs);

        for (CANFrameListener l : listeners) {
            l.onFrameReceived(f1);
            l.onFrameReceived(f2);
            if (!simulateMissingSignals) {
                l.onFrameReceived(f3);
            }
        }
    }

    public void setSimulateError(boolean simulateError) {
        this.simulateError = simulateError;
    }

    public void setSimulateMissingSignals(boolean simulateMissingSignals) {
        this.simulateMissingSignals = simulateMissingSignals;
    }

    public void setTelemetry(double voltage, double current, double soc, double temp, int cellDelta) {
        this.voltage = voltage;
        this.current = current;
        this.soc = soc;
        this.temperature = temp;
        this.cellDeltaMv = cellDelta;
    }

    @Override
    public Map<String, Object> getDiagnosticMetadata() {
        Map<String, Object> meta = new HashMap<String, Object>();
        meta.put("adapter_type", "MOCK_CAN");
        meta.put("device_id", deviceId);
        meta.put("status", status.name());
        meta.put("status_label", status.getLabel());
        meta.put("bit_rate", bitRate);
        meta.put("is_streaming", isStreaming);
        meta.put("listeners_count", listeners.size());
        meta.put("hardware_verified", false);
        meta.put("simulation_harness", true);
        return meta;
    }
}

