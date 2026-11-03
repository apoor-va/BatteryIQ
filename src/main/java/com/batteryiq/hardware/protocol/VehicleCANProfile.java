package com.batteryiq.hardware.protocol;

import java.util.*;

/**
 * Encapsulates a documented vehicle-specific CAN bus decoding profile.
 *
 * CRITICAL ENGINEERING PRINCIPLE:
 * BatteryIQ strictly prohibits inventing proprietary CAN arbitration IDs or arbitrary scaling factors.
 * All profiles must cite their experimental or published reverse-engineering source,
 * and must be marked as UNVALIDATED until verified with physical oscilloscopes/bus-loggers
 * and manufacturer workshop diagnostic equipment.
 */
public class VehicleCANProfile {

    private final String profileId;
    private final String vehicleMakeModel;
    private final String documentationSource;
    private final boolean isPhysicallyValidated;
    private final Map<Integer, List<CANSignalDefinition>> messageMap;

    public VehicleCANProfile(String profileId, String vehicleMakeModel, String documentationSource, boolean isPhysicallyValidated) {
        this.profileId = profileId;
        this.vehicleMakeModel = vehicleMakeModel;
        this.documentationSource = documentationSource;
        this.isPhysicallyValidated = isPhysicallyValidated;
        this.messageMap = new HashMap<Integer, List<CANSignalDefinition>>();
    }

    public void addSignal(int arbitrationId, CANSignalDefinition signal) {
        if (!messageMap.containsKey(arbitrationId)) {
            messageMap.put(arbitrationId, new ArrayList<CANSignalDefinition>());
        }
        messageMap.get(arbitrationId).add(signal);
    }

    public List<CANSignalDefinition> getSignalsForMessage(int arbitrationId) {
        return messageMap.get(arbitrationId);
    }

    public Set<Integer> getSubscribedMessageIds() {
        return messageMap.keySet();
    }

    public String getProfileId() {
        return profileId;
    }

    public String getVehicleMakeModel() {
        return vehicleMakeModel;
    }

    public String getDocumentationSource() {
        return documentationSource;
    }

    public boolean isPhysicallyValidated() {
        return isPhysicallyValidated;
    }

    // -------------------------------------------------------------------------
    // Pre-Configured Documented Reference Profiles
    // -------------------------------------------------------------------------

    /**
     * Documented reference profile for Nissan Leaf (AZE0 generation).
     * Source: OpenDBC / MyLeaf community documentation.
     * Status: PROPOSED REFERENCE TARGET (Requires validation on physical test vehicle).
     */
    public static VehicleCANProfile createNissanLeafProfile() {
        VehicleCANProfile profile = new VehicleCANProfile(
                "PROFILE_NISSAN_LEAF_AZE0",
                "Nissan Leaf (AZE0 / 24-30 kWh)",
                "Documented OpenDBC community CAN matrix for Nissan EV-CAN bus.",
                false // Unvalidated on current test bench
        );

        // Frame 0x1DB: Battery Pack Voltage (0.5V/bit) and Current (0.5A/bit signed)
        profile.addSignal(0x1DB, new CANSignalDefinition(
                "Pack_Voltage", "voltage_volts",
                16, 10, true, false, 0.5, 0.0, "V", 200.0, 450.0
        ));
        profile.addSignal(0x1DB, new CANSignalDefinition(
                "Pack_Current", "current_amps",
                0, 11, true, true, 0.5, 0.0, "A", -350.0, 350.0
        ));

        // Frame 0x5BC: State of Charge (0.1%/bit) and Available Usable Capacity
        profile.addSignal(0x5BC, new CANSignalDefinition(
                "Battery_SOC", "soc_percentage",
                0, 10, true, false, 0.1, 0.0, "%", 0.0, 100.0
        ));
        profile.addSignal(0x5BC, new CANSignalDefinition(
                "Usable_Capacity", "current_measured_capacity",
                16, 10, true, false, 0.1, 0.0, "Ah", 0.0, 100.0
        ));

        // Frame 0x55B: Pack Module Temperature (0.5°C/bit, offset -40°C)
        profile.addSignal(0x55B, new CANSignalDefinition(
                "Battery_Temperature", "temperature_celsius",
                0, 8, true, true, 0.5, -40.0, "°C", -30.0, 75.0
        ));

        return profile;
    }

    /**
     * Generic EV Proposed Target Profile for development and mock testing.
     */
    public static VehicleCANProfile createProposedStandardEVProfile() {
        VehicleCANProfile profile = new VehicleCANProfile(
                "PROFILE_PROPOSED_EV_STANDARD",
                "Generic EV BMS Broadcast Profile (Proposed Standard)",
                "Proposed multi-vendor BMS diagnostic broadcast mapping.",
                false
        );

        // Frame 0x100: Standard Voltage (0.1V/bit) & Current (0.1A signed)
        profile.addSignal(0x100, new CANSignalDefinition(
                "Pack_Voltage", "voltage_volts",
                0, 16, true, false, 0.1, 0.0, "V", 200.0, 900.0
        ));
        profile.addSignal(0x100, new CANSignalDefinition(
                "Pack_Current", "current_amps",
                16, 16, true, true, 0.1, 0.0, "A", -500.0, 500.0
        ));

        // Frame 0x101: SOC (0.1%) & Cell Delta (1 mV/bit)
        profile.addSignal(0x101, new CANSignalDefinition(
                "State_Of_Charge", "soc_percentage",
                0, 16, true, false, 0.1, 0.0, "%", 0.0, 100.0
        ));
        profile.addSignal(0x101, new CANSignalDefinition(
                "Cell_Delta_Voltage", "cell_delta_mv",
                16, 16, true, false, 1.0, 0.0, "mV", 0.0, 250.0
        ));

        // Frame 0x102: Temperature (0.1°C, offset -40)
        profile.addSignal(0x102, new CANSignalDefinition(
                "Pack_Temperature", "temperature_celsius",
                0, 16, true, false, 0.1, -40.0, "°C", -40.0, 85.0
        ));

        return profile;
    }
}

