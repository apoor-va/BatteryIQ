package com.batteryiq.hardware.adapter;

/**
 * Diagnostic connection lifecycle statuses for OBD-II and CAN interfaces.
 */
public enum ConnectionStatus {
    DISCONNECTED("Disconnected", "No diagnostic adapter connected."),
    CONNECTING("Connecting", "Negotiating physical and protocol handshake."),
    CONNECTED("Connected", "Adapter online. Awaiting diagnostic polling command."),
    STREAMING("Streaming", "Receiving live telemetry frames from vehicle BMS."),
    TIMEOUT("Timeout", "ECU/BMS response timed out. Check vehicle ignition or bus connection."),
    ERROR("Communication Error", "Adapter or bus error encountered (e.g. NO DATA, BUS BUSY).");

    private final String label;
    private final String description;

    ConnectionStatus(String label, String description) {
        this.label = label;
        this.description = description;
    }

    public String getLabel() {
        return label;
    }

    public String getDescription() {
        return description;
    }
}

