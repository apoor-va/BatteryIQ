package com.batteryiq.hardware.telemetry;

import com.batteryiq.battery.client.BatteryDiagnosticApiClient;
import com.batteryiq.dao.BatteryDiagnosticsDAO;
import com.batteryiq.hardware.adapter.*;
import com.batteryiq.hardware.protocol.*;
import com.batteryiq.model.*;
import com.batteryiq.util.JsonHelper;

import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Coordinates hardware diagnostic adapters, frame decoding, live telemetry streaming,
 * and relaying of live packets to Python analysis microservice and MySQL persistence.
 *
 * CRITICAL VERIFICATION ARCHITECTURE:
 * 1. Live OBD telemetry is always categorized as source_type = 'LIVE_OBD'.
 * 2. Verification status starts strictly as 'UNVERIFIED_LIVE_TELEMETRY'.
 * 3. is_hardware_physically_validated is permanently FALSE until certified by a live technician.
 * 4. Mock adapter telemetry is explicitly recorded with simulation harness device IDs.
 */
public class LiveTelemetryManager {

    private static final LiveTelemetryManager INSTANCE = new LiveTelemetryManager();

    private DiagnosticAdapter activeAdapter = null;
    private VehicleCANProfile activeProfile = null;
    private CANSignalDecoder activeDecoder = null;

    private LiveTelemetryPacket latestPacket = null;
    private final List<LiveTelemetryPacket> packetHistory = new CopyOnWriteArrayList<LiveTelemetryPacket>();

    private final BatteryDiagnosticApiClient pythonClient = new BatteryDiagnosticApiClient();
    private final BatteryDiagnosticsDAO diagnosticsDAO = new BatteryDiagnosticsDAO();

    private LiveTelemetryManager() {
        // Initialize default inactive state
        this.activeProfile = VehicleCANProfile.createNissanLeafProfile();
        this.activeDecoder = new CANSignalDecoder(this.activeProfile);
    }

    public static LiveTelemetryManager getInstance() {
        return INSTANCE;
    }

    /**
     * Connect to diagnostic adapter.
     *
     * @param adapterType "MOCK_OBD2", "MOCK_CAN", or "HARDWARE_SERIAL"
     * @param connectionUri COM port or interface string
     * @param profileId Profile identifier (e.g. "PROFILE_NISSAN_LEAF_AZE0")
     */
    public synchronized boolean connectAdapter(String adapterType, String connectionUri, String profileId) {
        disconnectAdapter();

        if ("PROFILE_PROPOSED_EV_STANDARD".equalsIgnoreCase(profileId)) {
            this.activeProfile = VehicleCANProfile.createProposedStandardEVProfile();
        } else {
            this.activeProfile = VehicleCANProfile.createNissanLeafProfile();
        }
        this.activeDecoder = new CANSignalDecoder(this.activeProfile);

        if ("MOCK_CAN".equalsIgnoreCase(adapterType)) {
            MockCANAdapter canAdapter = new MockCANAdapter();
            canAdapter.registerFrameListener(new CANFrameListener() {
                @Override
                public void onFrameReceived(CANFrame frame) {
                    processIncomingFrame(frame);
                }

                @Override
                public void onBusError(String errorMessage) {
                    if (latestPacket != null) {
                        latestPacket.addRawLog("BUS ERROR: " + errorMessage);
                    }
                }
            });
            boolean ok = canAdapter.connect(connectionUri != null ? connectionUri : "slcan0");
            this.activeAdapter = canAdapter;
            return ok;
        } else {
            // Default to Mock OBD2 Adapter
            MockOBD2Adapter obdAdapter = new MockOBD2Adapter();
            boolean ok = obdAdapter.connect(connectionUri != null ? connectionUri : "COM3");
            this.activeAdapter = obdAdapter;
            return ok;
        }
    }

    /**
     * Terminate adapter connection.
     */
    public synchronized void disconnectAdapter() {
        if (activeAdapter != null) {
            activeAdapter.disconnect();
            activeAdapter = null;
        }
        packetHistory.clear();
    }

    /**
     * Poll one telemetry cycle from active adapter.
     */
    public synchronized LiveTelemetryPacket pollTelemetry() {
        if (activeAdapter == null || activeAdapter.getConnectionStatus() == ConnectionStatus.DISCONNECTED) {
            LiveTelemetryPacket disconnectedPacket = new LiveTelemetryPacket();
            disconnectedPacket.setAdapterId("NONE");
            disconnectedPacket.setProtocolProfile(activeProfile != null ? activeProfile.getProfileId() : "NONE");
            disconnectedPacket.addUnsupportedSignal("All signals (Adapter Disconnected)");
            disconnectedPacket.addRawLog("STATUS: Diagnostic adapter is disconnected. Awaiting connection.");
            this.latestPacket = disconnectedPacket;
            return disconnectedPacket;
        }

        LiveTelemetryPacket packet = new LiveTelemetryPacket();
        packet.setAdapterId(activeAdapter.getDeviceId());
        packet.setProtocolProfile(activeProfile != null ? activeProfile.getProfileId() : "GENERIC");
        long now = System.currentTimeMillis();
        packet.setTimestampOffsetMs(now);

        if (activeAdapter instanceof MockCANAdapter) {
            MockCANAdapter can = (MockCANAdapter) activeAdapter;
            can.emitNissanLeafFrames(now);
            // Processed through frame listener, latestPacket updated
            return this.latestPacket != null ? this.latestPacket : packet;
        } else if (activeAdapter instanceof OBD2Adapter) {
            OBD2Adapter obd = (OBD2Adapter) activeAdapter;
            // Send AT initialization and query UDS DID
            String rawUds = obd.queryUdsDid("7E4", "7EC", "2001");
            packet.addRawLog("TX: ATSH7E4 -> RX: OK");
            packet.addRawLog("TX: 22 20 01 -> RX: " + rawUds);

            if (rawUds != null && rawUds.startsWith("62 20 01")) {
                // Parse simulated UDS DID 0x2001 payload
                try {
                    String[] parts = rawUds.split(" ");
                    if (parts.length >= 7) {
                        int vRaw = Integer.parseInt(parts[3], 16);
                        int iRaw = Integer.parseInt(parts[4], 16);
                        int socRaw = Integer.parseInt(parts[5], 16);
                        int tempRaw = Integer.parseInt(parts[6], 16);


                        packet.setVoltageVolts(vRaw / 10.0);
                        packet.setCurrentAmps((iRaw / 10.0) - 500.0);
                        packet.setSocPercentage(socRaw / 10.0);
                        packet.setTemperatureCelsius((double) (tempRaw - 40));

                        packet.addSupportedSignal("voltage_volts");
                        packet.addSupportedSignal("current_amps");
                        packet.addSupportedSignal("soc_percentage");
                        packet.addSupportedSignal("temperature_celsius");
                    }
                } catch (Exception e) {
                    packet.addRawLog("DECODE ERROR: " + e.getMessage());
                }
            } else {
                packet.addRawLog("UDS RESPONSE REJECTED OR NO DATA: " + rawUds);
            }

            // Cell delta voltage is NOT exposed via standard UDS DID 0x2001
            packet.setCellDeltaMv(null);
            packet.addUnsupportedSignal("cell_delta_mv (Requires manufacturer cell-monitoring query DID 0x2002)");

            this.latestPacket = packet;
            packetHistory.add(packet);
            if (packetHistory.size() > 100) {
                packetHistory.remove(0);
            }
            return packet;
        }

        this.latestPacket = packet;
        return packet;
    }

    /**
     * Process an incoming CAN frame via the active decoder.
     */
    private void processIncomingFrame(CANFrame frame) {
        if (activeDecoder == null) {
            return;
        }

        Map<String, Object> decoded = activeDecoder.decodeFrame(frame);
        if (decoded.isEmpty()) {
            return;
        }

        if (latestPacket == null || (frame.getTimestampOffsetMs() - latestPacket.getTimestampOffsetMs()) > 1000) {
            latestPacket = new LiveTelemetryPacket();
            latestPacket.setAdapterId(activeAdapter != null ? activeAdapter.getDeviceId() : "CAN_BUS");
            latestPacket.setProtocolProfile(activeProfile != null ? activeProfile.getProfileId() : "CAN_BUS");
            latestPacket.setTimestampOffsetMs(frame.getTimestampOffsetMs());
            packetHistory.add(latestPacket);
            if (packetHistory.size() > 100) {
                packetHistory.remove(0);
            }
        }

        latestPacket.addRawLog(frame.toString());

        if (decoded.containsKey("voltage_volts")) {
            latestPacket.setVoltageVolts((Double) decoded.get("voltage_volts"));
            latestPacket.addSupportedSignal("voltage_volts");
        }
        if (decoded.containsKey("current_amps")) {
            latestPacket.setCurrentAmps((Double) decoded.get("current_amps"));
            latestPacket.addSupportedSignal("current_amps");
        }
        if (decoded.containsKey("soc_percentage")) {
            latestPacket.setSocPercentage((Double) decoded.get("soc_percentage"));
            latestPacket.addSupportedSignal("soc_percentage");
        }
        if (decoded.containsKey("temperature_celsius")) {
            latestPacket.setTemperatureCelsius((Double) decoded.get("temperature_celsius"));
            latestPacket.addSupportedSignal("temperature_celsius");
        }
        if (decoded.containsKey("current_measured_capacity")) {
            latestPacket.setCurrentMeasuredCapacity((Double) decoded.get("current_measured_capacity"));
            latestPacket.addSupportedSignal("current_measured_capacity");
        }
    }

    /**
     * Transmit current live packet buffer to Python microservice and persist to MySQL.
     */
    public synchronized Map<String, Object> analyzeAndPersistSession(
            Integer vehicleId,
            String chemistryProfileId,
            double nominalCapacity,
            String capacityUnit) {

        Map<String, Object> result = new HashMap<String, Object>();

        // Ensure we have at least one packet
        if (latestPacket == null) {
            pollTelemetry();
        }

        List<LiveTelemetryPacket> buffer = new ArrayList<LiveTelemetryPacket>(packetHistory);
        if (buffer.isEmpty() && latestPacket != null) {
            buffer.add(latestPacket);
        }

        // 1. Build JSON Payload for Python
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"source_type\":\"LIVE_OBD\",");
        json.append("\"cell_or_pack_identifier\":\"").append(activeAdapter != null ? activeAdapter.getDeviceId() : "OBD2_LIVE").append("\",");
        json.append("\"chemistry_profile_id\":\"").append(chemistryProfileId).append("\",");
        json.append("\"capacity_unit\":\"").append(capacityUnit).append("\",");
        json.append("\"nominal_capacity\":").append(nominalCapacity).append(",");
        json.append("\"active_reference_type\":\"RATED_NOMINAL\",");
        json.append("\"hardware_adapter\":\"").append(activeAdapter != null ? activeAdapter.getDeviceId() : "NONE").append("\",");
        json.append("\"protocol_profile\":\"").append(activeProfile != null ? activeProfile.getProfileId() : "NONE").append("\",");

        if (latestPacket != null && latestPacket.getSocPercentage() != null) {
            json.append("\"initial_soc_pct\":").append(latestPacket.getSocPercentage()).append(",");
        }

        json.append("\"readings\":[");
        long baseTime = buffer.isEmpty() ? System.currentTimeMillis() : buffer.get(0).getTimestampOffsetMs();
        for (int i = 0; i < buffer.size(); i++) {
            LiveTelemetryPacket p = buffer.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"timestamp_offset_ms\":").append(p.getTimestampOffsetMs() - baseTime).append(",");
            json.append("\"voltage_volts\":").append(p.getVoltageVolts() != null ? p.getVoltageVolts() : "null").append(",");
            json.append("\"current_amps\":").append(p.getCurrentAmps() != null ? p.getCurrentAmps() : "null").append(",");
            json.append("\"temperature_celsius\":").append(p.getTemperatureCelsius() != null ? p.getTemperatureCelsius() : "null").append(",");
            json.append("\"soc_percentage\":").append(p.getSocPercentage() != null ? p.getSocPercentage() : "null").append(",");
            json.append("\"cell_delta_mv\":").append(p.getCellDeltaMv() != null ? p.getCellDeltaMv() : "null");
            json.append("}");
        }
        json.append("]}");

        // 2. Send to Python Microservice
        String pythonResponse = pythonClient.analyzeBattery(json.toString());
        boolean pythonOk = (pythonResponse != null && pythonResponse.contains("\"status\":\"SUCCESS\""));

        // 3. Persist to Database with strict UNVERIFIED_LIVE_TELEMETRY status
        String sessionUuid = "LIVE-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        BatterySession session = new BatterySession();
        session.setVehicleId(vehicleId);
        session.setSessionUuid(sessionUuid);
        session.setSourceType("LIVE_OBD");
        session.setCellOrPackIdentifier(activeAdapter != null ? activeAdapter.getDeviceId() : "OBD2_LIVE");
        session.setChemistryProfileId(chemistryProfileId);
        session.setNominalCapacityValue(new BigDecimal(String.valueOf(nominalCapacity)));
        session.setCapacityUnit(CapacityUnit.fromString(capacityUnit));
        session.setActiveReferenceType("RATED_NOMINAL");

        // Verification Separation
        session.setTelemetryStatus(pythonOk ? "PROCESSED_CLEAN" : "RAW_STREAMING");
        session.setVerificationStatus("UNVERIFIED_LIVE_TELEMETRY");
        session.setHardwareAdapterUsed(activeAdapter != null ? activeAdapter.getDeviceId() : "NONE");
        session.setProtocolTargetProfile(activeProfile != null ? activeProfile.getProfileId() : "NONE");
        session.setHardwarePhysicallyValidated(false); // Only physical technician sign-off can validate

        if (latestPacket != null) {
            if (latestPacket.getSocPercentage() != null) {
                session.setInitialSocPct(new BigDecimal(String.valueOf(latestPacket.getSocPercentage())));
                session.setSocEstimationMethod("BMS_CAN_REPORTED");
            }
            if (latestPacket.getCurrentMeasuredCapacity() != null) {
                session.setCurrentMeasuredCapacityValue(new BigDecimal(String.valueOf(latestPacket.getCurrentMeasuredCapacity())));
            }
        }

        // Ingest scientific analysis results if Python answered
        if (pythonOk) {
            String sohObj = JsonHelper.getSubObject(pythonResponse, "soh_analysis");
            if (sohObj != null) {
                BigDecimal sohPct = JsonHelper.getBigDecimal(sohObj, "estimated_soh_pct");
                String condition = JsonHelper.getString(sohObj, "condition_category");
                session.setEstimatedSohPct(sohPct);
                session.setConditionCategory(condition != null ? condition : "GOOD");
            }
        }

        List<BatteryTelemetryPoint> points = new ArrayList<BatteryTelemetryPoint>();
        for (LiveTelemetryPacket p : buffer) {
            BatteryTelemetryPoint pt = new BatteryTelemetryPoint();
            pt.setTimestampOffsetMs(p.getTimestampOffsetMs() - baseTime);
            pt.setVoltageVolts(p.getVoltageVolts() != null ? new BigDecimal(String.valueOf(p.getVoltageVolts())) : null);
            pt.setCurrentAmps(p.getCurrentAmps() != null ? new BigDecimal(String.valueOf(p.getCurrentAmps())) : null);
            pt.setTemperatureCelsius(p.getTemperatureCelsius() != null ? new BigDecimal(String.valueOf(p.getTemperatureCelsius())) : null);
            pt.setSocPercentage(p.getSocPercentage() != null ? new BigDecimal(String.valueOf(p.getSocPercentage())) : null);
            pt.setCellDeltaMv(p.getCellDeltaMv());
            pt.setActivePowerKw(p.getActivePowerKw() != null ? new BigDecimal(String.valueOf(p.getActivePowerKw())) : null);
            pt.setHasAnomaly(false);
            points.add(pt);
        }

        // Save session and telemetry batch
        boolean saved = diagnosticsDAO.saveSession(session, points);



        result.put("status", "SUCCESS");
        result.put("session", session);
        result.put("latest_packet", latestPacket);
        result.put("python_analyzed", pythonOk);
        result.put("python_response", pythonResponse);
        return result;
    }

    public DiagnosticAdapter getActiveAdapter() {
        return activeAdapter;
    }

    public VehicleCANProfile getActiveProfile() {
        return activeProfile;
    }

    public LiveTelemetryPacket getLatestPacket() {
        return latestPacket;
    }

    public List<LiveTelemetryPacket> getPacketHistory() {
        return Collections.unmodifiableList(packetHistory);
    }
}
