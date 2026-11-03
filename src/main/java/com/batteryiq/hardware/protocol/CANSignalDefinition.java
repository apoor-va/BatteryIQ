package com.batteryiq.hardware.protocol;

/**
 * Defines a physical battery telemetry signal encoded inside a CAN message payload.
 * Conforms to standard DBC (CAN database) serialization specification.
 *
 * Enforces strict physical bounds checking: readings outside physically plausible
 * ranges are rejected as invalid rather than emitting corrupted numbers.
 */
public class CANSignalDefinition {

    private final String signalName;
    private final String targetTelemetryField;
    private final int startBit;
    private final int bitLength;
    private final boolean isBigEndian;
    private final boolean isSigned;
    private final double scaleFactor;
    private final double offset;
    private final String unit;
    private final Double minPhysical;
    private final Double maxPhysical;

    public CANSignalDefinition(String signalName, String targetTelemetryField, int startBit, int bitLength,
                               boolean isBigEndian, boolean isSigned, double scaleFactor, double offset,
                               String unit, Double minPhysical, Double maxPhysical) {
        this.signalName = signalName;
        this.targetTelemetryField = targetTelemetryField;
        this.startBit = startBit;
        this.bitLength = bitLength;
        this.isBigEndian = isBigEndian;
        this.isSigned = isSigned;
        this.scaleFactor = scaleFactor;
        this.offset = offset;
        this.unit = unit;
        this.minPhysical = minPhysical;
        this.maxPhysical = maxPhysical;
    }

    public String getSignalName() {
        return signalName;
    }

    public String getTargetTelemetryField() {
        return targetTelemetryField;
    }

    public String getUnit() {
        return unit;
    }

    /**
     * Decode the raw CAN frame payload into the calibrated physical measurement.
     * Returns null if the frame payload is truncated or the decoded value violates physical bounds.
     */
    public Double decode(CANFrame frame) {
        if (frame == null || frame.getPayload() == null) {
            return null;
        }

        byte[] payload = frame.getPayload();
        int byteStart = startBit / 8;
        int bytesRequired = (startBit % 8 + bitLength + 7) / 8;

        if (byteStart + bytesRequired > payload.length) {
            return null; // Frame payload truncated
        }

        long rawValue = 0;
        if (isBigEndian) {
            // Motorola Big-Endian
            for (int i = 0; i < bytesRequired; i++) {
                int b = payload[byteStart + i] & 0xFF;
                rawValue = (rawValue << 8) | b;
            }
            int shift = (8 - ((startBit + bitLength) % 8)) % 8;
            rawValue = (rawValue >> shift) & ((1L << bitLength) - 1);
        } else {
            // Intel Little-Endian
            for (int i = 0; i < bytesRequired; i++) {
                long b = payload[byteStart + i] & 0xFF;
                rawValue |= (b << (i * 8));
            }
            rawValue = (rawValue >> (startBit % 8)) & ((1L << bitLength) - 1);
        }

        // Two's complement signed handling
        if (isSigned && ((rawValue & (1L << (bitLength - 1))) != 0)) {
            rawValue -= (1L << bitLength);
        }

        double physicalValue = (rawValue * scaleFactor) + offset;

        // Physical bounds verification
        if (minPhysical != null && physicalValue < minPhysical) {
            return null;
        }
        if (maxPhysical != null && physicalValue > maxPhysical) {
            return null;
        }

        return round(physicalValue, 3);
    }

    private double round(double val, int decimals) {
        double p = Math.pow(10, decimals);
        return Math.round(val * p) / p;
    }
}

