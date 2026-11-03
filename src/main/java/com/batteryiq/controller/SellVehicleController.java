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
import java.math.BigDecimal;

/**
 * Controller servlet for the Sell Your Vehicle page.
 * Allows sellers to list Cars, Bikes, or Scooters across Petrol, Diesel, or Electric,
 * get an instant algorithmic valuation estimate, and book a BatteryIQ Certified Health Inspection.
 */
@WebServlet(name = "SellVehicleController", urlPatterns = {"/sell"})
public class SellVehicleController extends HttpServlet {
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
        RequestDispatcher dispatcher = request.getRequestDispatcher("/sell.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String category = request.getParameter("category");
        String fuelType = request.getParameter("fuelType");
        String conditionType = request.getParameter("conditionType");
        String make = request.getParameter("make");
        String model = request.getParameter("model");
        String variantTrim = request.getParameter("variantTrim");
        String yearStr = request.getParameter("manufacturingYear");
        String priceStr = request.getParameter("price");
        String odometerStr = request.getParameter("odometerKm");
        String locationCity = request.getParameter("locationCity");
        String sellerName = request.getParameter("sellerName");
        String sellerPhone = request.getParameter("sellerPhone");
        String requestInspection = request.getParameter("requestInspection");

        int year = 2022;
        try {
            if (yearStr != null) year = Integer.parseInt(yearStr);
        } catch (NumberFormatException ignored) {}

        BigDecimal price = new BigDecimal("25000.00");
        try {
            if (priceStr != null) price = new BigDecimal(priceStr.replaceAll("[^0-9.]", ""));
        } catch (Exception ignored) {}

        int odo = 25000;
        try {
            if (odometerStr != null) odo = Integer.parseInt(odometerStr.replaceAll("[^0-9]", ""));
        } catch (Exception ignored) {}

        // Default placeholder thumbnail matching category
        String thumb = "https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=80";
        if (Vehicle.CATEGORY_BIKE.equalsIgnoreCase(category)) {
            thumb = "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=80";
        } else if (Vehicle.CATEGORY_SCOOTER.equalsIgnoreCase(category)) {
            thumb = "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=1200&q=80";
        }

        Vehicle newListing = new Vehicle();
        newListing.setMake(make != null && !make.trim().isEmpty() ? make : "Custom");
        newListing.setModel(model != null && !model.trim().isEmpty() ? model : "Model");
        newListing.setVariantTrim(variantTrim != null ? variantTrim : "Standard Edition");
        newListing.setManufacturingYear(year);
        newListing.setPrice(price);
        newListing.setOdometerKm(odo);
        newListing.setCategory(category != null ? category : Vehicle.CATEGORY_CAR);
        newListing.setFuelType(fuelType != null ? fuelType : Vehicle.FUEL_PETROL);
        newListing.setConditionType(conditionType != null ? conditionType : Vehicle.CONDITION_USED);
        newListing.setLocationCity(locationCity != null && !locationCity.trim().isEmpty() ? locationCity : "San Francisco, CA");
        newListing.setSellerName(sellerName != null && !sellerName.trim().isEmpty() ? sellerName : "Private Seller");
        newListing.setSellerPhone(sellerPhone != null && !sellerPhone.trim().isEmpty() ? sellerPhone : "+1 555-0100");
        newListing.setThumbnailUrl(thumb);
        newListing.setStatus("AVAILABLE");

        boolean created = vehicleDAO.addVehicle(newListing);

        request.setAttribute("listingSuccess", created);
        request.setAttribute("createdVehicle", newListing);
        request.setAttribute("inspectionBooked", "on".equalsIgnoreCase(requestInspection) || "true".equalsIgnoreCase(requestInspection));

        RequestDispatcher dispatcher = request.getRequestDispatcher("/sell.jsp");
        dispatcher.forward(request, response);
    }
}

