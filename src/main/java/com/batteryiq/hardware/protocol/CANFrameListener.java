package com.batteryiq.hardware.protocol;

/**
 * Listener callback for asynchronous CAN frame reception.
 */
public interface CANFrameListener {

    /**
     * Invoked whenever a valid CAN frame is received on the bus.
     */
    void onFrameReceived(CANFrame frame);

    /**
     * Invoked when a bus error or buffer overrun occurs.
     */
    void onBusError(String errorMessage);
}

