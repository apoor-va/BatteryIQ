package com.batteryiq.hardware.adapter;

import com.batteryiq.hardware.protocol.CANFrame;
import com.batteryiq.hardware.protocol.CANFrameListener;

/**
 * Direct CAN bus controller interface (e.g. SocketCAN, PCAN-Basic, CANable / slcan USB).
 * Allows passive bus monitoring and direct frame transmission without OBD-II query-response latency.
 */
public interface CANAdapter extends DiagnosticAdapter {

    /**
     * Transmit a raw CAN frame onto the bus.
     */
    boolean sendFrame(CANFrame frame);

    /**
     * Register a frame listener for incoming broadcast frames.
     */
    void registerFrameListener(CANFrameListener listener);

    /**
     * Unregister frame listener.
     */
    void unregisterFrameListener(CANFrameListener listener);

    /**
     * Configured bus bit rate (e.g. 500000 for 500 kbps high-speed CAN).
     */
    int getBitRate();

    /**
     * Configure hardware acceptance filter and mask for CAN arbitration IDs.
     */
    boolean setFilter(int filterId, int mask);
}

