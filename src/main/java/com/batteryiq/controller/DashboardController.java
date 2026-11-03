package com.batteryiq.controller;

import com.batteryiq.battery.client.BatteryDiagnosticApiClient;
import com.batteryiq.dao.BatteryDiagnosticsDAO;
import com.batteryiq.dao.VehicleDAO;
import com.batteryiq.model.BatterySession;
import com.batteryiq.model.Vehicle;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

/**
 * Main BatteryIQ Executive Dashboard Controller (/dashboard).
 * Aggregates real database statistics across the vehicle marketplace,
 * battery telemetry sessions, risk distribution, and certified health reports.
 */
@WebServlet(name = "DashboardController", urlPatterns = {"/dashboard"})
public class DashboardController extends HttpServlet {
    private static final long serialVersionUID = 8L;

    private VehicleDAO vehicleDAO;
    private BatteryDiagnosticsDAO diagnosticsDAO;
    private BatteryDiagnosticApiClient apiClient;

    @Override
    public void init() throws ServletException {
        super.init();
        this.vehicleDAO = new VehicleDAO();
        this.diagnosticsDAO = new BatteryDiagnosticsDAO();
        this.apiClient = new BatteryDiagnosticApiClient();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Vehicles statistics
        List<Vehicle> allVehicles = vehicleDAO.getAllVehicles();
        if (allVehicles == null) allVehicles = new ArrayList<Vehicle>();

        int totalVehicles = allVehicles.size();
        int totalEVs = 0;
        List<Vehicle> evList = new ArrayList<Vehicle>();

        for (Vehicle v : allVehicles) {
            if ("Electric".equalsIgnoreCase(v.getFuelType())) {
                totalEVs++;
                evList.add(v);
            }
        }

        // 2. Battery telemetry sessions statistics
        List<BatterySession> allSessions = diagnosticsDAO.getAllSessions();
        if (allSessions == null) allSessions = new ArrayList<BatterySession>();
        int totalSessions = allSessions.size();

        int lowRiskCount = 0;      // SOH >= 80%
        int moderateRiskCount = 0; // SOH 70% - 79.9%
        int criticalRiskCount = 0; // SOH < 70%

        int publicDatasetCount = 0;
        int simulatorCount = 0;
        int liveObdCount = 0;

        for (BatterySession s : allSessions) {
            BigDecimal soh = s.getEstimatedSohPct();
            if (soh != null) {
                double val = soh.doubleValue();
                if (val >= 80.0) {
                    lowRiskCount++;
                } else if (val >= 70.0) {
                    moderateRiskCount++;
                } else {
                    criticalRiskCount++;
                }
            } else {
                moderateRiskCount++;
            }

            if (s.isPublicDataset()) publicDatasetCount++;
            else if (s.isLiveObd()) liveObdCount++;
            else simulatorCount++;
        }

        // 3. Service health check
        boolean pythonOnline = apiClient.isServiceAvailable();

        // 4. Pass attributes to JSP
        request.setAttribute("totalVehicles", totalVehicles);
        request.setAttribute("totalEVs", totalEVs);
        request.setAttribute("totalSessions", totalSessions);
        request.setAttribute("totalHealthReports", totalVehicles); // Each vehicle in inventory has certified health audit
        request.setAttribute("lowRiskCount", lowRiskCount);
        request.setAttribute("moderateRiskCount", moderateRiskCount);
        request.setAttribute("criticalRiskCount", criticalRiskCount);
        request.setAttribute("publicDatasetCount", publicDatasetCount);
        request.setAttribute("simulatorCount", simulatorCount);
        request.setAttribute("liveObdCount", liveObdCount);
        request.setAttribute("pythonOnline", pythonOnline);
        request.setAttribute("recentSessions", allSessions.size() > 8 ? allSessions.subList(0, 8) : allSessions);
        request.setAttribute("electricVehicles", evList);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/dashboard.jsp");
        dispatcher.forward(request, response);
    }
}

