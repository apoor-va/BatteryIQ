package com.batteryiq.controller;

import com.batteryiq.dao.VehicleDAO;
import com.batteryiq.model.Inquiry;
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
 * Controller servlet for Individual Vehicle Details page.
 * Displays comprehensive specifications, image gallery, seller details,
 * integrated BatteryIQ health summary, loan EMI estimator, and test-drive inquiry form.
 */
@WebServlet(name = "VehicleDetailController", urlPatterns = {"/vehicle"})
public class VehicleDetailController extends HttpServlet {
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
        int vehicleId = 1;
        if (idStr != null) {
            try {
                vehicleId = Integer.parseInt(idStr);
            } catch (NumberFormatException ignored) {}
        }

        Vehicle vehicle = vehicleDAO.getVehicleById(vehicleId);
        if (vehicle == null) {
            // Default to vehicle 1 if not found
            vehicle = vehicleDAO.getVehicleById(1);
        }

        request.setAttribute("vehicle", vehicle);

        // Fetch similar vehicles from the same category
        if (vehicle != null) {
            final int currentId = vehicle.getVehicleId();
            List<Vehicle> similar = vehicleDAO.getVehicles(vehicle.getCategory(), null, null, null, null, null, null, null)
                    .stream()
                    .filter(v -> v.getVehicleId() != currentId)
                    .limit(3)
                    .collect(Collectors.toList());
            request.setAttribute("similarVehicles", similar);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/vehicle-details.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Handle Test Drive or Inquiry submission
        String vehicleIdStr = request.getParameter("vehicleId");
        String customerName = request.getParameter("customerName");
        String customerEmail = request.getParameter("customerEmail");
        String customerPhone = request.getParameter("customerPhone");
        String message = request.getParameter("message");
        String inquiryType = request.getParameter("inquiryType");

        int vId = 1;
        try {
            if (vehicleIdStr != null) vId = Integer.parseInt(vehicleIdStr);
        } catch (NumberFormatException ignored) {}

        Inquiry inquiry = new Inquiry(vId, customerName, customerEmail, customerPhone, message, inquiryType != null ? inquiryType : "TEST_DRIVE");
        vehicleDAO.saveInquiry(inquiry);

        request.setAttribute("inquirySuccess", true);
        doGet(request, response);
    }
}
