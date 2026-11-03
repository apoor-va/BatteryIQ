package com.batteryiq.hardware.protocol;

import java.util.Arrays;

/**
 * Encapsulates a raw Controller Area Network (CAN) bus frame.
 * Captures arbitration ID, payload bytes, and accurate microsecond/millisecond timestamps.
 */
public class CANFrame {

    private final int arbitrationId;
    private final int dlc;
    private final byte[] payload;
    private final long timestampOffsetMs;
    private final boolean isExtended;

    public CANFrame(int arbitrationId, byte[] payload, long timestampOffsetMs) {
        this(arbitrationId, payload, timestampOffsetMs, false);
    }

    public CANFrame(int arbitrationId, byte[] payload, long timestampOffsetMs, boolean isExtended) {
        this.arbitrationId = arbitrationId;
        this.dlc = (payload != null) ? payload.length : 0;
        this.payload = (payload != null) ? Arrays.copyOf(payload, payload.length) : new byte[0];
        this.timestampOffsetMs = timestampOffsetMs;
        this.isExtended = isExtended;
    }

    public int getArbitrationId() {
        return arbitrationId;
    }

    public String getHexArbitrationId() {
        return String.format("0x%03X", arbitrationId);
    }

    public int getDlc() {
        return dlc;
    }

    public byte[] getPayload() {
        return Arrays.copyOf(payload, payload.length);
    }

    public long getTimestampOffsetMs() {
        return timestampOffsetMs;
    }

    public boolean isExtended() {
        return isExtended;
    }

    /**
     * Read unsigned byte at specified index (0 to 255).
     */
    public int getByteUnsigned(int index) {
        if (index < 0 || index >= payload.length) {
            return 0;
        }
        return payload[index] & 0xFF;
    }

    /**
     * Read 16-bit unsigned integer in Big-Endian (Motorola) byte order.
     */
    public int getUint16BigEndian(int startByte) {
        int b0 = getByteUnsigned(startByte);
        int b1 = getByteUnsigned(startByte + 1);
        return (b0 << 8) | b1;
    }

    /**
     * Read 16-bit signed integer in Big-Endian (Motorola) byte order.
     */
    public short getInt16BigEndian(int startByte) {
        return (short) getUint16BigEndian(startByte);
    }

    /**
     * Format payload as uppercase hex string.
     */
    public String getPayloadHex() {
        StringBuilder sb = new StringBuilder();
        for (byte b : payload) {
            sb.append(String.format("%02X ", b));
        }
        return sb.toString().trim();
    }

    @Override
    public String toString() {
        return String.format("[%d ms] %s (DLC=%d): %s", timestampOffsetMs, getHexArbitrationId(), dlc, getPayloadHex());
    }
}

