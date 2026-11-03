package com.batteryiq.controller;

import com.batteryiq.dao.VehicleDAO;
import com.batteryiq.model.Vehicle;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Controller servlet for the BatteryIQ Automotive Marketplace homepage.
 * Inspired by modern platforms like CarDekho, with original BatteryIQ branding and design.
 * Provides featured listings across Cars, Bikes, Scooters (Petrol, Diesel, Electric; New & Used)
 * and highlights BatteryIQ's signature Vehicle Health Reports.
 */
@WebServlet(name = "HomeController", urlPatterns = {"/home", ""})
public class HomeController extends HttpServlet {
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

        // Retrieve featured vehicles
        List<Vehicle> featuredVehicles = vehicleDAO.getFeaturedVehicles();
        request.setAttribute("featuredVehicles", featuredVehicles);

        // Category subsets for homepage quick showcases
        List<Vehicle> popularCars = vehicleDAO.getVehicles("CAR", null, null, null, null, null, null, null);
        request.setAttribute("popularCars", popularCars.stream().limit(4).collect(Collectors.toList()));

        List<Vehicle> popularBikes = vehicleDAO.getVehicles("BIKE", null, null, null, null, null, null, null);
        request.setAttribute("popularBikes", popularBikes.stream().limit(4).collect(Collectors.toList()));

        List<Vehicle> popularScooters = vehicleDAO.getVehicles("SCOOTER", null, null, null, null, null, null, null);
        request.setAttribute("popularScooters", popularScooters.stream().limit(4).collect(Collectors.toList()));

        List<Vehicle> newVehicles = vehicleDAO.getVehicles(null, null, "NEW", null, null, null, null, null);
        request.setAttribute("newVehicles", newVehicles.stream().limit(4).collect(Collectors.toList()));

        List<Vehicle> usedVehicles = vehicleDAO.getVehicles(null, null, "USED", null, null, null, null, null);
        request.setAttribute("usedVehicles", usedVehicles.stream().limit(4).collect(Collectors.toList()));

        // Marketplace Platform statistics
        request.setAttribute("totalVerifiedVehicles", "3,850+");
        request.setAttribute("totalInspectionsConducted", "12,400+");
        request.setAttribute("evAverageSoh", "96.4%");
        request.setAttribute("iceEnginePassRate", "94.2%");

        // Forward to homepage JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher("/index.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
