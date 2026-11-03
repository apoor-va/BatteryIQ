package com.batteryiq.hardware.adapter;

import java.util.Map;

/**
 * Base Hardware Abstraction Layer (HAL) interface for EV diagnostic adapters.
 * Separates low-level physical bus communication from scientific calculations.
 */
public interface DiagnosticAdapter {

    /**
     * Connect to the diagnostic interface (e.g. COM port, Bluetooth MAC, SocketCAN interface).
     */
    boolean connect(String connectionUri);

    /**
     * Terminate the connection safely.
     */
    void disconnect();

    /**
     * Current lifecycle connection state.
     */
    ConnectionStatus getConnectionStatus();

    /**
     * Hardware device signature (e.g. "ELM327 v1.5", "STN1110 v4.2", "CANable USB-CAN v2.0").
     */
    String getDeviceId();

    /**
     * Vehicle Identification Number (VIN) where authorized and exposed via Mode 09 PID 02.
     * Returns null if unsupported or unread.
     */
    String getVehicleVin();

    /**
     * Send an AT or diagnostic command string and return the raw response.
     */
    String sendCommand(String command);

    /**
     * Last diagnostic error message, if any.
     */
    String getLastError();

    /**
     * Indicates whether live telemetry is actively streaming.
     */
    boolean isStreaming();

    /**
     * Detailed status metadata map for UI presentation and auditing.
     */
    Map<String, Object> getDiagnosticMetadata();
}

