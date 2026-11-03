package com.batteryiq.controller;

import com.batteryiq.battery.client.BatteryDiagnosticApiClient;
import com.batteryiq.dao.BatteryDiagnosticsDAO;
import com.batteryiq.hardware.adapter.*;
import com.batteryiq.hardware.protocol.VehicleCANProfile;
import com.batteryiq.hardware.telemetry.LiveTelemetryManager;
import com.batteryiq.hardware.telemetry.LiveTelemetryPacket;
import com.batteryiq.model.BatterySession;
import com.batteryiq.model.BatteryTelemetryPoint;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

/**
 * REST API Proxy Controller mapping /api/battery/* for asynchronous frontend requests.
 * Safely relays requests to the Python microservice and provides Hardware Abstraction Layer (HAL) endpoints.
 */
@WebServlet(name = "BatteryApiController", urlPatterns = {"/api/battery/*"})
public class BatteryApiController extends HttpServlet {
    private static final long serialVersionUID = 4L;

    private BatteryDiagnosticApiClient apiClient;
    private BatteryDiagnosticsDAO diagnosticsDAO;
    private LiveTelemetryManager telemetryManager;

    @Override
    public void init() throws ServletException {
        super.init();
        this.apiClient = new BatteryDiagnosticApiClient();
        this.diagnosticsDAO = new BatteryDiagnosticsDAO();
        this.telemetryManager = LiveTelemetryManager.getInstance();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        String pathInfo = request.getPathInfo();

        if (pathInfo == null || "/status".equalsIgnoreCase(pathInfo)) {
            // Service health status
            boolean available = apiClient.isServiceAvailable();
            String healthJson = apiClient.getHealth();
            if (available) {
                out.print(healthJson);
            } else {
                response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
                out.print("{\"status\":\"OFFLINE\",\"message\":\"Python Scientific Service on Port 5001 is offline.\"}");
            }
            return;
        }

        if ("/chemistry".equalsIgnoreCase(pathInfo)) {
            String profilesJson = apiClient.getChemistryProfiles();
            out.print(profilesJson);
            return;
        }

        // Hardware Abstraction Layer - Adapter & Telemetry Status
        if ("/hardware/status".equalsIgnoreCase(pathInfo)) {
            DiagnosticAdapter adapter = telemetryManager.getActiveAdapter();
            VehicleCANProfile profile = telemetryManager.getActiveProfile();
            LiveTelemetryPacket latest = telemetryManager.getLatestPacket();

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"status\":\"SUCCESS\",");
            sb.append("\"is_connected\":").append(adapter != null && adapter.getConnectionStatus() != ConnectionStatus.DISCONNECTED).append(",");
            sb.append("\"connection_status\":\"").append(adapter != null ? adapter.getConnectionStatus().name() : "DISCONNECTED").append("\",");
            sb.append("\"connection_label\":\"").append(adapter != null ? adapter.getConnectionStatus().getLabel() : "Disconnected").append("\",");
            sb.append("\"device_id\":\"").append(adapter != null ? adapter.getDeviceId() : "No Adapter Connected").append("\",");
            sb.append("\"vin\":").append(adapter != null && adapter.getVehicleVin() != null ? "\"" + adapter.getVehicleVin() + "\"" : "null").append(",");
            sb.append("\"is_streaming\":").append(adapter != null && adapter.isStreaming()).append(",");
            sb.append("\"last_error\":").append(adapter != null && adapter.getLastError() != null ? "\"" + adapter.getLastError() + "\"" : "null").append(",");

            // Target Profile Info
            sb.append("\"profile_id\":\"").append(profile != null ? profile.getProfileId() : "NONE").append("\",");
            sb.append("\"vehicle_model\":\"").append(profile != null ? profile.getVehicleMakeModel() : "None").append("\",");
            sb.append("\"doc_source\":\"").append(profile != null ? profile.getDocumentationSource() : "None").append("\",");

            // Strict Verification Architecture
            sb.append("\"source_type\":\"LIVE_OBD\",");
            sb.append("\"verification_status\":\"UNVERIFIED_LIVE_TELEMETRY\",");
            sb.append("\"is_hardware_physically_validated\":false,");
            sb.append("\"academic_notice\":\"PROPOSED HARDWARE ADAPTER TARGET. Awaiting physical connection to a compatible EV and certified technician physical inspection.\",");

            // Latest Packet Telemetry
            if (latest != null) {
                sb.append("\"latest_packet\":{");
                sb.append("\"timestamp_ms\":").append(latest.getTimestampOffsetMs()).append(",");
                sb.append("\"voltage_volts\":").append(latest.getVoltageVolts() != null ? latest.getVoltageVolts() : "null").append(",");
                sb.append("\"current_amps\":").append(latest.getCurrentAmps() != null ? latest.getCurrentAmps() : "null").append(",");
                sb.append("\"temperature_celsius\":").append(latest.getTemperatureCelsius() != null ? latest.getTemperatureCelsius() : "null").append(",");
                sb.append("\"soc_percentage\":").append(latest.getSocPercentage() != null ? latest.getSocPercentage() : "null").append(",");
                sb.append("\"current_measured_capacity\":").append(latest.getCurrentMeasuredCapacity() != null ? latest.getCurrentMeasuredCapacity() : "null").append(",");
                sb.append("\"cell_delta_mv\":").append(latest.getCellDeltaMv() != null ? latest.getCellDeltaMv() : "null").append(",");
                sb.append("\"active_power_kw\":").append(latest.getActivePowerKw() != null ? latest.getActivePowerKw() : "null").append(",");

                sb.append("\"supported_signals\":[");
                List<String> supp = latest.getSupportedSignals();
                for (int i = 0; i < supp.size(); i++) {
                    if (i > 0) sb.append(",");
                    sb.append("\"").append(supp.get(i)).append("\"");
                }
                sb.append("],");

                sb.append("\"unsupported_signals\":[");
                List<String> unsupp = latest.getUnsupportedSignals();
                for (int i = 0; i < unsupp.size(); i++) {
                    if (i > 0) sb.append(",");
                    sb.append("\"").append(unsupp.get(i)).append("\"");
                }
                sb.append("],");

                sb.append("\"raw_logs\":[");
                List<String> logs = latest.getRawLog();
                for (int i = 0; i < logs.size(); i++) {
                    if (i > 0) sb.append(",");
                    sb.append("\"").append(logs.get(i).replace("\"", "\\\"")).append("\"");
                }
                sb.append("]");
                sb.append("}");
            } else {
                sb.append("\"latest_packet\":null");
            }

            sb.append("}");
            out.print(sb.toString());
            return;
        }

        // Hardware Polling endpoint
        if ("/hardware/poll".equalsIgnoreCase(pathInfo)) {
            LiveTelemetryPacket packet = telemetryManager.pollTelemetry();
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"status\":\"SUCCESS\",");
            sb.append("\"voltage_volts\":").append(packet.getVoltageVolts() != null ? packet.getVoltageVolts() : "null").append(",");
            sb.append("\"current_amps\":").append(packet.getCurrentAmps() != null ? packet.getCurrentAmps() : "null").append(",");
            sb.append("\"soc_percentage\":").append(packet.getSocPercentage() != null ? packet.getSocPercentage() : "null").append(",");
            sb.append("\"temperature_celsius\":").append(packet.getTemperatureCelsius() != null ? packet.getTemperatureCelsius() : "null").append(",");
            sb.append("\"active_power_kw\":").append(packet.getActivePowerKw() != null ? packet.getActivePowerKw() : "null");
            sb.append("}");
            out.print(sb.toString());
            return;
        }

        if ("/session".equalsIgnoreCase(pathInfo)) {
            String sIdStr = request.getParameter("id");
            if (sIdStr != null) {
                try {
                    int sId = Integer.parseInt(sIdStr);
                    BatterySession s = diagnosticsDAO.getSessionById(sId);
                    List<BatteryTelemetryPoint> points = diagnosticsDAO.getReadingsForSession(sId);

                    StringBuilder sb = new StringBuilder("{");
                    sb.append("\"session_id\":").append(s != null ? s.getSessionId() : sId).append(",");
                    sb.append("\"uuid\":\"").append(s != null ? s.getSessionUuid() : "").append("\",");
                    sb.append("\"readings\":[");
                    for (int i = 0; i < points.size(); i++) {
                        BatteryTelemetryPoint p = points.get(i);
                        if (i > 0) sb.append(",");
                        sb.append("{")
                                .append("\"t\":").append(p.getTimestampOffsetMs()).append(",")
                                .append("\"v\":").append(p.getVoltageVolts()).append(",")
                                .append("\"i\":").append(p.getCurrentAmps()).append(",")
                                .append("\"temp\":").append(p.getTemperatureCelsius()).append(",")
                                .append("\"soc\":").append(p.getSocPercentage()).append(",")
                                .append("\"delta\":").append(p.getCellDeltaMv())
                                .append("}");
                    }
                    sb.append("]}");
                    out.print(sb.toString());
                    return;
                } catch (NumberFormatException ignored) {}
            }
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid session id\"}");
            return;
        }

        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        out.print("{\"error\":\"Endpoint not found\"}");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        String pathInfo = request.getPathInfo();

        if ("/hardware/connect".equalsIgnoreCase(pathInfo)) {
            String adapterType = request.getParameter("adapter_type");
            String uri = request.getParameter("uri");
            String profileId = request.getParameter("profile_id");

            if (adapterType == null || adapterType.isEmpty()) {
                adapterType = "MOCK_OBD2";
            }
            if (profileId == null || profileId.isEmpty()) {
                profileId = "PROFILE_NISSAN_LEAF_AZE0";
            }

            boolean ok = telemetryManager.connectAdapter(adapterType, uri, profileId);
            DiagnosticAdapter adapter = telemetryManager.getActiveAdapter();

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"status\":\"").append(ok ? "SUCCESS" : "ERROR").append("\",");
            sb.append("\"is_connected\":").append(ok).append(",");
            sb.append("\"connection_status\":\"").append(adapter != null ? adapter.getConnectionStatus().name() : "DISCONNECTED").append("\",");
            sb.append("\"device_id\":\"").append(adapter != null ? adapter.getDeviceId() : "").append("\",");
            sb.append("\"vin\":").append(adapter != null && adapter.getVehicleVin() != null ? "\"" + adapter.getVehicleVin() + "\"" : "null").append(",");
            sb.append("\"last_error\":").append(adapter != null && adapter.getLastError() != null ? "\"" + adapter.getLastError() + "\"" : "null");
            sb.append("}");
            out.print(sb.toString());
            return;
        }

        if ("/hardware/disconnect".equalsIgnoreCase(pathInfo)) {
            telemetryManager.disconnectAdapter();
            out.print("{\"status\":\"SUCCESS\",\"message\":\"Adapter disconnected.\",\"connection_status\":\"DISCONNECTED\"}");
            return;
        }

        if ("/hardware/fault".equalsIgnoreCase(pathInfo)) {
            String faultType = request.getParameter("fault_type");
            DiagnosticAdapter adapter = telemetryManager.getActiveAdapter();
            if (adapter instanceof MockOBD2Adapter) {
                MockOBD2Adapter obd = (MockOBD2Adapter) adapter;
                if ("TIMEOUT".equalsIgnoreCase(faultType)) {
                    obd.setSimulateTimeout(true);
                } else if ("BUS_ERROR".equalsIgnoreCase(faultType)) {
                    obd.setSimulateBusError(true);
                } else if ("MISSING_SIGNALS".equalsIgnoreCase(faultType)) {
                    obd.setSimulateMissingSignals(true);
                } else if ("RESET".equalsIgnoreCase(faultType)) {
                    obd.setSimulateTimeout(false);
                    obd.setSimulateBusError(false);
                    obd.setSimulateMissingSignals(false);
                }
            } else if (adapter instanceof MockCANAdapter) {
                MockCANAdapter can = (MockCANAdapter) adapter;
                if ("BUS_ERROR".equalsIgnoreCase(faultType)) {
                    can.setSimulateError(true);
                } else if ("MISSING_SIGNALS".equalsIgnoreCase(faultType)) {
                    can.setSimulateMissingSignals(true);
                } else if ("RESET".equalsIgnoreCase(faultType)) {
                    can.setSimulateError(false);
                    can.setSimulateMissingSignals(false);
                }
            }
            out.print("{\"status\":\"SUCCESS\",\"fault_applied\":\"" + faultType + "\"}");
            return;
        }

        if ("/hardware/analyze".equalsIgnoreCase(pathInfo)) {
            String chemId = request.getParameter("chemistry_profile_id");
            if (chemId == null || chemId.isEmpty()) chemId = "CHEM_NMC_01";
            String unit = request.getParameter("capacity_unit");
            if (unit == null || unit.isEmpty()) unit = "KWH";
            double nomCap = 75.0;
            String nomCapStr = request.getParameter("nominal_capacity");
            if (nomCapStr != null) {
                try { nomCap = Double.parseDouble(nomCapStr); } catch (Exception ignored) {}
            }

            Integer vehicleId = null;
            String vIdStr = request.getParameter("vehicle_id");
            if (vIdStr != null && !vIdStr.isEmpty()) {
                try { vehicleId = Integer.parseInt(vIdStr); } catch (Exception ignored) {}
            }

            Map<String, Object> res = telemetryManager.analyzeAndPersistSession(vehicleId, chemId, nomCap, unit);
            BatterySession session = (BatterySession) res.get("session");

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"status\":\"SUCCESS\",");
            sb.append("\"session_id\":").append(session != null ? session.getSessionId() : 0).append(",");
            sb.append("\"session_uuid\":\"").append(session != null ? session.getSessionUuid() : "").append("\",");
            sb.append("\"soh_pct\":").append(session != null ? session.getEstimatedSohPct() : "null").append(",");
            sb.append("\"condition\":\"").append(session != null ? session.getConditionCategory() : "UNAVAILABLE").append("\",");
            sb.append("\"source_type\":\"LIVE_OBD\",");
            sb.append("\"verification_status\":\"UNVERIFIED_LIVE_TELEMETRY\"");
            sb.append("}");
            out.print(sb.toString());
            return;
        }

        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        out.print("{\"error\":\"Endpoint not found\"}");
    }
}
