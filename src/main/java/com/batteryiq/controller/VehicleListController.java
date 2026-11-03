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

/**
 * Controller servlet for Vehicle Search, Category browsing, and dynamic multi-criteria filtering.
 * Covers:
 * - /vehicles (Master search & catalog)
 * - /cars (Cars only)
 * - /bikes (Bikes only)
 * - /scooters (Scooters only)
 * - /new-vehicles (Brand new vehicles)
 * - /used-vehicles (Pre-owned vehicles with verified health reports)
 * - /search (Universal search query endpoint)
 */
@WebServlet(name = "VehicleListController", urlPatterns = {
        "/vehicles",
        "/cars",
        "/bikes",
        "/scooters",
        "/new-vehicles",
        "/used-vehicles",
        "/search"
})
public class VehicleListController extends HttpServlet {
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

        String path = request.getServletPath();

        // Extract parameters from request
        String category = request.getParameter("category");
        String fuelType = request.getParameter("fuel");
        String condition = request.getParameter("condition");
        String brand = request.getParameter("brand");
        String budget = request.getParameter("budget");
        String location = request.getParameter("location");
        String query = request.getParameter("q");
        String sort = request.getParameter("sort");

        // Route-specific defaults if accessed via dedicated category or condition URLs
        String pageTitle = "Browse All Vehicles";
        String pageSubtitle = "Explore certified new and pre-owned cars, bikes, and scooters with verified health diagnostics.";

        if ("/cars".equalsIgnoreCase(path)) {
            category = Vehicle.CATEGORY_CAR;
            pageTitle = "Cars Marketplace";
            pageSubtitle = "Explore verified Petrol, Diesel, and Electric cars with BatteryIQ health certification.";
        } else if ("/bikes".equalsIgnoreCase(path)) {
            category = Vehicle.CATEGORY_BIKE;
            pageTitle = "Bikes Marketplace";
            pageSubtitle = "Explore top petrol roadsters, sports bikes, and high-performance electric motorcycles.";
        } else if ("/scooters".equalsIgnoreCase(path)) {
            category = Vehicle.CATEGORY_SCOOTER;
            pageTitle = "Scooters Marketplace";
            pageSubtitle = "Find reliable family scooters, daily commuters, and next-gen electric smartscooters.";
        } else if ("/new-vehicles".equalsIgnoreCase(path)) {
            condition = Vehicle.CONDITION_NEW;
            pageTitle = "Brand New Vehicles";
            pageSubtitle = "Factory-fresh cars, bikes, and scooters with manufacturer warranty and pre-delivery inspection.";
        } else if ("/used-vehicles".equalsIgnoreCase(path)) {
            condition = Vehicle.CONDITION_USED;
            pageTitle = "Verified Used Vehicles";
            pageSubtitle = "Pre-owned vehicles rigorously inspected for battery SoH, engine compression, and odometer truth.";
        } else if ("/search".equalsIgnoreCase(path) || (query != null && !query.trim().isEmpty())) {
            pageTitle = "Search Results";
            pageSubtitle = query != null && !query.trim().isEmpty() 
                    ? "Displaying matches for \"" + query.trim() + "\""
                    : "Filtered automotive listings";
        }

        // Fetch filtered vehicles
        List<Vehicle> vehicles = vehicleDAO.getVehicles(category, fuelType, condition, brand, budget, location, query, sort);

        // Bind attributes for JSP presentation
        request.setAttribute("vehicles", vehicles);
        request.setAttribute("resultCount", vehicles.size());
        request.setAttribute("selectedCategory", category != null ? category : "all");
        request.setAttribute("selectedFuel", fuelType != null ? fuelType : "all");
        request.setAttribute("selectedCondition", condition != null ? condition : "all");
        request.setAttribute("selectedBrand", brand != null ? brand : "all");
        request.setAttribute("selectedBudget", budget != null ? budget : "all");
        request.setAttribute("selectedLocation", location != null ? location : "");
        request.setAttribute("searchQuery", query != null ? query : "");
        request.setAttribute("selectedSort", sort != null ? sort : "default");
        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("pageSubtitle", pageSubtitle);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/vehicles.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

