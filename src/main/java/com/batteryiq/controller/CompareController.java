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
import java.util.ArrayList;
import java.util.List;

/**
 * Controller servlet for Vehicle Comparison page.
 * Compares 2 or 3 vehicles side-by-side across specifications, pricing,
 * fuel mechanics, and BatteryIQ health scores.
 */
@WebServlet(name = "CompareController", urlPatterns = {"/compare"})
public class CompareController extends HttpServlet {
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

        String id1Str = request.getParameter("id1");
        String id2Str = request.getParameter("id2");
        String id3Str = request.getParameter("id3");
        String category = request.getParameter("category");

        // Defaults for first-time visitors: compare two popular cars or based on category
        int id1 = 1; // Tesla Model 3
        int id2 = 4; // BMW 330i (EV vs Petrol comparison)
        int id3 = -1;

        if (id1Str != null) {
            try { id1 = Integer.parseInt(id1Str); } catch (NumberFormatException ignored) {}
        }
        if (id2Str != null) {
            try { id2 = Integer.parseInt(id2Str); } catch (NumberFormatException ignored) {}
        }
        if (id3Str != null && !id3Str.trim().isEmpty()) {
            try { id3 = Integer.parseInt(id3Str); } catch (NumberFormatException ignored) {}
        }

        // If category changed, pick two vehicles from that category
        if (category != null && !category.trim().isEmpty() && id1Str == null && id2Str == null) {
            if ("BIKE".equalsIgnoreCase(category)) {
                id1 = 8; // Zero SR/F
                id2 = 9; // Royal Enfield
            } else if ("SCOOTER".equalsIgnoreCase(category)) {
                id1 = 11; // Ola S1 Pro
                id2 = 13; // Honda Activa 6G
            }
        }

        Vehicle v1 = vehicleDAO.getVehicleById(id1);
        Vehicle v2 = vehicleDAO.getVehicleById(id2);
        Vehicle v3 = (id3 > 0) ? vehicleDAO.getVehicleById(id3) : null;

        List<Vehicle> compareList = new ArrayList<>();
        if (v1 != null) compareList.add(v1);
        if (v2 != null) compareList.add(v2);
        if (v3 != null) compareList.add(v3);

        // Fetch all vehicles for the dropdown selectors
        List<Vehicle> allVehicles = vehicleDAO.getVehicles(null, null, null, null, null, null, null, null);

        request.setAttribute("compareList", compareList);
        request.setAttribute("v1", v1);
        request.setAttribute("v2", v2);
        request.setAttribute("v3", v3);
        request.setAttribute("allVehicles", allVehicles);
        request.setAttribute("selectedCategory", category != null ? category : (v1 != null ? v1.getCategory() : "CAR"));

        RequestDispatcher dispatcher = request.getRequestDispatcher("/compare.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

