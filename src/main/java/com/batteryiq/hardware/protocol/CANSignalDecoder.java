package com.batteryiq.hardware.protocol;

import java.util.*;

/**
 * Decodes raw CANFrame payloads using a specified VehicleCANProfile.
 * Produces mapped key-value pairs corresponding to BatteryIQ telemetry fields.
 */
public class CANSignalDecoder {

    private final VehicleCANProfile profile;

    public CANSignalDecoder(VehicleCANProfile profile) {
        if (profile == null) {
            throw new IllegalArgumentException("VehicleCANProfile cannot be null.");
        }
        this.profile = profile;
    }

    public VehicleCANProfile getProfile() {
        return profile;
    }

    /**
     * Decode signals present in a single CANFrame.
     *
     * @param frame Raw received CAN frame
     * @return Map of target telemetry field name to decoded physical value.
     */
    public Map<String, Object> decodeFrame(CANFrame frame) {
        Map<String, Object> decoded = new HashMap<String, Object>();
        if (frame == null) {
            return decoded;
        }

        List<CANSignalDefinition> signals = profile.getSignalsForMessage(frame.getArbitrationId());
        if (signals == null || signals.isEmpty()) {
            return decoded; // Unsubscribed or unmapped arbitration ID
        }

        for (CANSignalDefinition sig : signals) {
            Double val = sig.decode(frame);
            if (val != null) {
                decoded.put(sig.getTargetTelemetryField(), val);
            }
        }

        return decoded;
    }
}

