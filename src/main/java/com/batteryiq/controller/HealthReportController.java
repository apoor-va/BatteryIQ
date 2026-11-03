package com.batteryiq.controller;

import com.batteryiq.dao.VehicleDAO;
import com.batteryiq.model.Vehicle;
import com.batteryiq.model.VehicleHealthReport;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Controller servlet for BatteryIQ's signature Vehicle Health Report page.
 * Provides deep telematics for Electric Vehicles (Battery SoH, Cell Balance, Degradation, Charging speeds)
 * and comprehensive mechanical diagnostics for Petrol & Diesel ICE vehicles (Engine compression,
 * Odometer integrity, Service history, OBD-II DTC codes, Emissions).
 * Includes specific checks for Bikes & Scooters (chain/belt drive, clutch, swappable battery locks).
 * Distinguishes Verified, Unverified, and Missing evidence.
 */
@WebServlet(name = "HealthReportController", urlPatterns = {"/health-report"})
public class HealthReportController extends HttpServlet {
    private static final long serialVersionUID = 2L;

    private VehicleDAO vehicleDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.vehicleDAO = new VehicleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String certCode = request.getParameter("cert");

        Vehicle vehicle = null;
        VehicleHealthReport report = null;

        List<Vehicle> allVehicles = vehicleDAO.getAllVehicles();
        request.setAttribute("allVehicles", allVehicles);

        if (certCode != null && !certCode.trim().isEmpty()) {
            report = vehicleDAO.getHealthReportByCertificate(certCode.trim());
            if (report != null) {
                vehicle = vehicleDAO.getVehicleById(report.getVehicleId());
            }
        }

        if (vehicle == null) {
            int vehicleId = 1; // Default to vehicle 1 (Tesla Model 3) or first vehicle
            if (idStr != null) {
                try {
                    vehicleId = Integer.parseInt(idStr);
                } catch (NumberFormatException ignored) {}
            } else if (allVehicles != null && !allVehicles.isEmpty()) {
                vehicleId = allVehicles.get(0).getVehicleId();
            }
            vehicle = vehicleDAO.getVehicleById(vehicleId);
            if (vehicle != null) {
                report = vehicle.getHealthReport();
            }
        }

        request.setAttribute("vehicle", vehicle);
        request.setAttribute("report", report);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/health-report.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

