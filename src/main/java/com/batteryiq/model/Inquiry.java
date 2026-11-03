package com.batteryiq.model;

import java.io.Serializable;
import java.sql.Date;

/**
 * Model class representing inquiries, test drives, and health inspection bookings.
 */
public class Inquiry implements Serializable {
    private static final long serialVersionUID = 1L;

    private int inquiryId;
    private int vehicleId;
    private Integer userId;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String message;
    private Date preferredDate;
    private String inquiryType; // TEST_DRIVE, PRICE_QUOTE, INSPECTION_REQUEST
    private String status;      // PENDING, CONTACTED, COMPLETED

    public Inquiry() {
    }

    public Inquiry(int vehicleId, String customerName, String customerEmail, String customerPhone, String message, String inquiryType) {
        this.vehicleId = vehicleId;
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerPhone = customerPhone;
        this.message = message;
        this.inquiryType = inquiryType;
        this.status = "PENDING";
    }

    public int getInquiryId() {
        return inquiryId;
    }

    public void setInquiryId(int inquiryId) {
        this.inquiryId = inquiryId;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Date getPreferredDate() {
        return preferredDate;
    }

    public void setPreferredDate(Date preferredDate) {
        this.preferredDate = preferredDate;
    }

    public String getInquiryType() {
        return inquiryType;
    }

    public void setInquiryType(String inquiryType) {
        this.inquiryType = inquiryType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}

