package com.batteryiq.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;

/**
 * Model class representing an EV Battery Health Verification Diagnostic Report.
 */
public class BatteryReport implements Serializable {
    private static final long serialVersionUID = 1L;

    private int reportId;
    private int vehicleId;
    private String certificateCode;
    private BigDecimal sohPercentage;      // State of Health e.g. 97.4
    private BigDecimal usableCapacityKwh;
    private int estimatedRealRangeKm;
    private int cycleCount;
    private int cellDeviationMv;          // Max voltage delta across modules (mV)
    private BigDecimal fastChargeRatioPct;
    private String thermalStressGrade;    // EXCELLENT, GOOD, MODERATE, ATTENTION_NEEDED
    private BigDecimal degradationRatePerYear;
    private String overallGrade;          // A+, A, B+, B, C
    private Date verifiedDate;
    private String verifiedByInspector;
    private String notes;

    public BatteryReport() {
    }

    public BatteryReport(int reportId, int vehicleId, String certificateCode, BigDecimal sohPercentage,
                         BigDecimal usableCapacityKwh, int estimatedRealRangeKm, int cycleCount,
                         int cellDeviationMv, BigDecimal fastChargeRatioPct, String thermalStressGrade,
                         BigDecimal degradationRatePerYear, String overallGrade, Date verifiedDate,
                         String verifiedByInspector, String notes) {
        this.reportId = reportId;
        this.vehicleId = vehicleId;
        this.certificateCode = certificateCode;
        this.sohPercentage = sohPercentage;
        this.usableCapacityKwh = usableCapacityKwh;
        this.estimatedRealRangeKm = estimatedRealRangeKm;
        this.cycleCount = cycleCount;
        this.cellDeviationMv = cellDeviationMv;
        this.fastChargeRatioPct = fastChargeRatioPct;
        this.thermalStressGrade = thermalStressGrade;
        this.degradationRatePerYear = degradationRatePerYear;
        this.overallGrade = overallGrade;
        this.verifiedDate = verifiedDate;
        this.verifiedByInspector = verifiedByInspector;
        this.notes = notes;
    }

    // Getters and Setters
    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public String getCertificateCode() {
        return certificateCode;
    }

    public void setCertificateCode(String certificateCode) {
        this.certificateCode = certificateCode;
    }

    public BigDecimal getSohPercentage() {
        return sohPercentage;
    }

    public void setSohPercentage(BigDecimal sohPercentage) {
        this.sohPercentage = sohPercentage;
    }

    public BigDecimal getUsableCapacityKwh() {
        return usableCapacityKwh;
    }

    public void setUsableCapacityKwh(BigDecimal usableCapacityKwh) {
        this.usableCapacityKwh = usableCapacityKwh;
    }

    public int getEstimatedRealRangeKm() {
        return estimatedRealRangeKm;
    }

    public void setEstimatedRealRangeKm(int estimatedRealRangeKm) {
        this.estimatedRealRangeKm = estimatedRealRangeKm;
    }

    public int getCycleCount() {
        return cycleCount;
    }

    public void setCycleCount(int cycleCount) {
        this.cycleCount = cycleCount;
    }

    public int getCellDeviationMv() {
        return cellDeviationMv;
    }

    public void setCellDeviationMv(int cellDeviationMv) {
        this.cellDeviationMv = cellDeviationMv;
    }

    public BigDecimal getFastChargeRatioPct() {
        return fastChargeRatioPct;
    }

    public void setFastChargeRatioPct(BigDecimal fastChargeRatioPct) {
        this.fastChargeRatioPct = fastChargeRatioPct;
    }

    public String getThermalStressGrade() {
        return thermalStressGrade;
    }

    public void setThermalStressGrade(String thermalStressGrade) {
        this.thermalStressGrade = thermalStressGrade;
    }

    public BigDecimal getDegradationRatePerYear() {
        return degradationRatePerYear;
    }

    public void setDegradationRatePerYear(BigDecimal degradationRatePerYear) {
        this.degradationRatePerYear = degradationRatePerYear;
    }

    public String getOverallGrade() {
        return overallGrade;
    }

    public void setOverallGrade(String overallGrade) {
        this.overallGrade = overallGrade;
    }

    public Date getVerifiedDate() {
        return verifiedDate;
    }

    public void setVerifiedDate(Date verifiedDate) {
        this.verifiedDate = verifiedDate;
    }

    public String getVerifiedByInspector() {
        return verifiedByInspector;
    }

    public void setVerifiedByInspector(String verifiedByInspector) {
        this.verifiedByInspector = verifiedByInspector;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    /**
     * Converts this legacy BatteryReport into a full VehicleHealthReport.
     */
    public VehicleHealthReport toVehicleHealthReport() {
        VehicleHealthReport r = new VehicleHealthReport();
        r.setReportId(this.reportId);
        r.setVehicleId(this.vehicleId);
        r.setCertificateCode(this.certificateCode);
        r.setReportType(VehicleHealthReport.ReportType.EV_BATTERY);
        r.setSohPercentage(this.sohPercentage);
        r.setUsableCapacityKwh(this.usableCapacityKwh);
        r.setEstimatedRealRangeKm(this.estimatedRealRangeKm);
        r.setCycleCount(this.cycleCount);
        r.setCellDeviationMv(this.cellDeviationMv);
        r.setFastChargeRatioPct(this.fastChargeRatioPct);
        r.setThermalStressGrade(this.thermalStressGrade);
        r.setDegradationRatePerYear(this.degradationRatePerYear);
        r.setOverallGrade(this.overallGrade);
        r.setVerifiedDate(this.verifiedDate);
        r.setVerifiedByInspector(this.verifiedByInspector);
        r.setInspectorNotes(this.notes);
        r.setCertified(true);
        if (this.sohPercentage != null) {
            r.setOverallScore(this.sohPercentage.intValue());
        }
        r.addVerifiedItem("Battery Management System (BMS) Telematics Handshake");
        r.addVerifiedItem("Electrochemical Cell Deviation Delta (" + this.cellDeviationMv + " mV)");
        r.addVerifiedItem("State of Health (SoH) Diagnostics");
        r.addVerifiedItem("DC Fast Charging Exposure History (" + this.fastChargeRatioPct + "%)");
        r.addVerifiedItem("Thermal Dissipation & Coolant Flow Rate");
        r.addRecommendedTest("Sub-zero cold climate range validation test");
        return r;
    }
}
