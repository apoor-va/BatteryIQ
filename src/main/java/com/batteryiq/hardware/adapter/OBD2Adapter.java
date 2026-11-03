package com.batteryiq.hardware.adapter;

/**
 * Specialized diagnostic interface for OBD-II / ELM327 / STN communication.
 * Handles AT configuration, standard SAE J1979 PIDs, and ISO 14229 UDS diagnostic queries.
 *
 * NOTE: Standard OBD-II Mode 01 PIDs were designed for Internal Combustion Engine (ICE) emissions.
 * Standard OBD-II does NOT define traction battery pack voltage, current, cell delta, or SOH.
 * These require manufacturer-specific UDS Data Identifiers (DIDs) or direct CAN bus monitoring.
 */
public interface OBD2Adapter extends DiagnosticAdapter {

    /**
     * Set the communications protocol (e.g. "ATSP6" for ISO 15765-4 CAN 11-bit 500kbps).
     */
    boolean setProtocol(String protocolCommand);

    /**
     * Query a standard OBD-II PID (Mode + PID, e.g. mode=1, pid=0x0D for speed).
     */
    String queryStandardPid(int mode, int pid);

    /**
     * Query a manufacturer-specific Unified Diagnostic Services (UDS) DID (Mode 0x22).
     *
     * @param ecuTxId Transmitter arbitration ID (e.g. "7E0" or "7E4" for BMS)
     * @param ecuRxId Receiver arbitration ID (e.g. "7E8" or "7EC")
     * @param didHex  Data Identifier in hexadecimal (e.g. "2001" or "F190")
     * @return Raw hex response or error string (e.g. "NO DATA", "CAN ERROR")
     */
    String queryUdsDid(String ecuTxId, String ecuRxId, String didHex);

    /**
     * Query Vehicle Identification Number (VIN) via Mode 09 PID 02.
     */
    String queryVin();

    /**
     * Query whether this adapter or vehicle ECU supports standard EV battery PIDs.
     */
    boolean isEvBatteryReportingSupported();
}

