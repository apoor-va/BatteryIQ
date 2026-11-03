package com.batteryiq.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

/**
 * Model class representing a BatteryIQ Vehicle Health Report.
 * Supports:
 * 1. Electric Vehicles (Cars, Bikes, Scooters): Battery SoH, Degradation, Cell Voltage Delta, Range, Charging, BMS Warnings.
 * 2. Petrol Vehicles (Cars, Bikes, Scooters): Engine health score, Compression, Odometer, OBD-II DTCs, Spark/O2 sensors.
 * 3. Diesel Vehicles (Cars): Engine health score, DPF soot load & status, Common-Rail injection, AdBlue/DEF, Glow plugs.
 * 4. 2-Wheelers (Bikes & Scooters): Chain/belt drive, CVT/clutch wear, swappable battery lock terminals.
 *
 * Enforces strict diagnostic evidence status: VERIFIED, UNVERIFIED, MISSING, and PENDING.
 */
public class VehicleHealthReport implements Serializable {
    private static final long serialVersionUID = 3L;

    public enum ReportType {
        EV_BATTERY,
        ICE_ENGINE
    }

    public enum EvidenceStatus {
        VERIFIED,
        UNVERIFIED,
        MISSING,
        PENDING_INSPECTION
    }

    // Common Core Fields
    private int reportId;
    private int vehicleId;
    private String certificateCode;
    private ReportType reportType;
    private String overallGrade;            // A+, A, B+, B, C, Pending
    private int overallScore;               // 0 to 100
    private Date verifiedDate;
    private String verifiedByInspector;
    private String inspectorNotes;
    private boolean isCertified;            // false = PENDING INSPECTION

    // -------------------------------------------------------------------------
    // 1. Electric Vehicle (EV) Telematics & Battery Health Metrics
    // -------------------------------------------------------------------------
    private BigDecimal sohPercentage;          // State of Health e.g. 96.5%
    private EvidenceStatus sohStatus = EvidenceStatus.MISSING;
    private BigDecimal usableCapacityKwh;      // Usable battery capacity (kWh)
    private BigDecimal originalCapacityKwh;    // Original factory battery capacity (kWh)
    private int originalRangeKm;               // Original manufacturer rated range (WLTP)
    private int estimatedRealRangeKm;          // Real-world tested range
    private EvidenceStatus rangeStatus = EvidenceStatus.MISSING;
    private BigDecimal degradationRatePerYear; // Annual degradation rate e.g. 1.2%
    private int cycleCount;                    // Full charging cycles
    private int cellDeviationMv;              // Max voltage delta between cell modules (mV)
    private EvidenceStatus cellDeviationStatus = EvidenceStatus.MISSING;
    private BigDecimal fastChargeRatioPct;     // DC fast charge usage ratio (%)
    private String thermalStressGrade;        // EXCELLENT, GOOD, MODERATE, ATTENTION_NEEDED
    private String chargingHealthSummary;      // Charging port, onboard charger, thermal management
    private List<String> abnormalWarnings;     // List of abnormal flags or warnings

    // -------------------------------------------------------------------------
    // 2. Petrol & Diesel (ICE) Common Mechanical Metrics
    // -------------------------------------------------------------------------
    private int engineHealthScore;             // Engine condition score 0-100
    private EvidenceStatus engineHealthStatus = EvidenceStatus.MISSING;
    private EvidenceStatus odometerStatus = EvidenceStatus.MISSING;
    private boolean odometerTamperingSuspected;
    private String compressionTestResult;      // e.g. "175 PSI - Balanced across all cylinders"
    private EvidenceStatus compressionStatus = EvidenceStatus.MISSING;
    private String oilConditionGrade;          // CLEAN, ACCEPTABLE, DEGRADED, CONTAMINATED
    private EvidenceStatus oilStatus = EvidenceStatus.MISSING;
    private EvidenceStatus serviceHistoryStatus = EvidenceStatus.MISSING;
    private int documentedServiceCount;
    private List<String> obdDtcCodes;          // Diagnostic Trouble Codes
    private EvidenceStatus obdScanStatus = EvidenceStatus.MISSING;
    private String transmissionCondition;      // SMOOTH, SLIGHT_SLIP, ATTENTION_NEEDED
    private String exhaustEmissionGrade;       // PASS_CLEAN, PASS_BORDERLINE, FAIL
    private String coolingSystemHealth;        // Radiator, coolant level, pressure test
    private String chassisSuspensionGrade;     // Structural integrity, rust check, bushes

    // -------------------------------------------------------------------------
    // 3. Diesel-Specific Diagnostic Metrics
    // -------------------------------------------------------------------------
    private String dpfStatus;                  // CLEAN, REGENERATION_RECOMMENDED, CLOGGED, N/A
    private Double dpfSootLoadGrams;           // e.g. 8.2 grams (max limit usually 45g)
    private EvidenceStatus dpfEvidenceStatus = EvidenceStatus.MISSING;
    private Integer commonRailPressureBar;     // e.g. 2000 bar injection pressure
    private EvidenceStatus commonRailStatus = EvidenceStatus.MISSING;
    private String adBlueDefStatus;            // NOMINAL, LOW, FAULT, N/A
    private EvidenceStatus adBlueStatus = EvidenceStatus.MISSING;
    private String glowPlugStatus;             // ALL_PASSED, CYLINDER_FAULTY, N/A

    // -------------------------------------------------------------------------
    // 4. Petrol-Specific Diagnostic Metrics
    // -------------------------------------------------------------------------
    private String sparkPlugCondition;         // CLEAN_NOMINAL, WORN_REPLACE_SOON
    private String catalyticConverterO2Status;// PASS_LAMBDA_NOMINAL, SLUGGISH_HEATER

    // -------------------------------------------------------------------------
    // 5. 2-Wheeler (Bikes & Scooters) Specific Checks
    // -------------------------------------------------------------------------
    private String twoWheelerDriveType;        // CHAIN_DRIVE, BELT_DRIVE, HUB_MOTOR, SHAFT_DRIVE
    private String twoWheelerDriveCondition;   // EXCELLENT, GOOD, WORN
    private String twoWheelerClutchOrBelt;     // e.g. "Wet multiplate clutch healthy" or "CVT belt nominal"
    private EvidenceStatus twoWheelerDriveStatus = EvidenceStatus.MISSING;
    private boolean isRemovableBattery;        // For e-scooters with swappable batteries
    private String batteryLockerCondition;     // For e-scooters: connector & lock condition
    private String motorType;                  // Mid-Drive Motor with Reduction, Hub Motor
    private String batteryEnclosureProtection;// IP67 Water & Dust Ingress Tested

    // -------------------------------------------------------------------------
    // 6. Evidence, Transparency & Recommended Next Tests
    // -------------------------------------------------------------------------
    private List<String> verifiedItems;        // What has been physically verified
    private List<String> unverifiedItems;      // Customer reported or unconfirmed by lab
    private List<String> missingEvidence;      // Missing documents, logs, or unperformed tests
    private List<String> recommendedTests;     // Recommended additional diagnostic actions

    public VehicleHealthReport() {
        this.abnormalWarnings = new ArrayList<>();
        this.obdDtcCodes = new ArrayList<>();
        this.verifiedItems = new ArrayList<>();
        this.unverifiedItems = new ArrayList<>();
        this.missingEvidence = new ArrayList<>();
        this.recommendedTests = new ArrayList<>();
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

    public ReportType getReportType() {
        return reportType;
    }

    public void setReportType(ReportType reportType) {
        this.reportType = reportType;
    }

    public String getOverallGrade() {
        return overallGrade != null ? overallGrade : "Pending";
    }

    public void setOverallGrade(String overallGrade) {
        this.overallGrade = overallGrade;
    }

    public int getOverallScore() {
        return overallScore;
    }

    public void setOverallScore(int overallScore) {
        this.overallScore = overallScore;
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

    public String getInspectorNotes() {
        return inspectorNotes;
    }

    public void setInspectorNotes(String inspectorNotes) {
        this.inspectorNotes = inspectorNotes;
    }

    public boolean isCertified() {
        return isCertified;
    }

    public void setCertified(boolean certified) {
        isCertified = certified;
    }

    public boolean isPendingInspection() {
        return !isCertified || "Pending".equalsIgnoreCase(overallGrade);
    }

    // EV Getters/Setters
    public BigDecimal getSohPercentage() {
        return sohPercentage;
    }

    public void setSohPercentage(BigDecimal sohPercentage) {
        this.sohPercentage = sohPercentage;
    }

    public EvidenceStatus getSohStatus() {
        return sohStatus;
    }

    public void setSohStatus(EvidenceStatus sohStatus) {
        this.sohStatus = sohStatus;
    }

    public BigDecimal getUsableCapacityKwh() {
        return usableCapacityKwh;
    }

    public void setUsableCapacityKwh(BigDecimal usableCapacityKwh) {
        this.usableCapacityKwh = usableCapacityKwh;
    }

    public BigDecimal getOriginalCapacityKwh() {
        return originalCapacityKwh;
    }

    public void setOriginalCapacityKwh(BigDecimal originalCapacityKwh) {
        this.originalCapacityKwh = originalCapacityKwh;
    }

    public int getOriginalRangeKm() {
        return originalRangeKm;
    }

    public void setOriginalRangeKm(int originalRangeKm) {
        this.originalRangeKm = originalRangeKm;
    }

    public int getEstimatedRealRangeKm() {
        return estimatedRealRangeKm;
    }

    public void setEstimatedRealRangeKm(int estimatedRealRangeKm) {
        this.estimatedRealRangeKm = estimatedRealRangeKm;
    }

    public EvidenceStatus getRangeStatus() {
        return rangeStatus;
    }

    public void setRangeStatus(EvidenceStatus rangeStatus) {
        this.rangeStatus = rangeStatus;
    }

    public BigDecimal getDegradationRatePerYear() {
        return degradationRatePerYear;
    }

    public void setDegradationRatePerYear(BigDecimal degradationRatePerYear) {
        this.degradationRatePerYear = degradationRatePerYear;
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

    public EvidenceStatus getCellDeviationStatus() {
        return cellDeviationStatus;
    }

    public void setCellDeviationStatus(EvidenceStatus cellDeviationStatus) {
        this.cellDeviationStatus = cellDeviationStatus;
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

    public String getChargingHealthSummary() {
        return chargingHealthSummary;
    }

    public void setChargingHealthSummary(String chargingHealthSummary) {
        this.chargingHealthSummary = chargingHealthSummary;
    }

    public List<String> getAbnormalWarnings() {
        return abnormalWarnings;
    }

    public void setAbnormalWarnings(List<String> abnormalWarnings) {
        this.abnormalWarnings = abnormalWarnings;
    }

    public void addAbnormalWarning(String warning) {
        if (this.abnormalWarnings == null) this.abnormalWarnings = new ArrayList<>();
        this.abnormalWarnings.add(warning);
    }

    // ICE Common Getters/Setters
    public int getEngineHealthScore() {
        return engineHealthScore;
    }

    public void setEngineHealthScore(int engineHealthScore) {
        this.engineHealthScore = engineHealthScore;
    }

    public EvidenceStatus getEngineHealthStatus() {
        return engineHealthStatus;
    }

    public void setEngineHealthStatus(EvidenceStatus engineHealthStatus) {
        this.engineHealthStatus = engineHealthStatus;
    }

    public EvidenceStatus getOdometerStatus() {
        return odometerStatus;
    }

    public void setOdometerStatus(EvidenceStatus odometerStatus) {
        this.odometerStatus = odometerStatus;
    }

    public boolean isOdometerTamperingSuspected() {
        return odometerTamperingSuspected;
    }

    public void setOdometerTamperingSuspected(boolean odometerTamperingSuspected) {
        this.odometerTamperingSuspected = odometerTamperingSuspected;
    }

    public String getCompressionTestResult() {
        return compressionTestResult;
    }

    public void setCompressionTestResult(String compressionTestResult) {
        this.compressionTestResult = compressionTestResult;
    }

    public EvidenceStatus getCompressionStatus() {
        return compressionStatus;
    }

    public void setCompressionStatus(EvidenceStatus compressionStatus) {
        this.compressionStatus = compressionStatus;
    }

    public String getOilConditionGrade() {
        return oilConditionGrade;
    }

    public void setOilConditionGrade(String oilConditionGrade) {
        this.oilConditionGrade = oilConditionGrade;
    }

    public EvidenceStatus getOilStatus() {
        return oilStatus;
    }

    public void setOilStatus(EvidenceStatus oilStatus) {
        this.oilStatus = oilStatus;
    }

    public EvidenceStatus getServiceHistoryStatus() {
        return serviceHistoryStatus;
    }

    public void setServiceHistoryStatus(EvidenceStatus serviceHistoryStatus) {
        this.serviceHistoryStatus = serviceHistoryStatus;
    }

    public int getDocumentedServiceCount() {
        return documentedServiceCount;
    }

    public void setDocumentedServiceCount(int documentedServiceCount) {
        this.documentedServiceCount = documentedServiceCount;
    }

    public List<String> getObdDtcCodes() {
        return obdDtcCodes;
    }

    public void setObdDtcCodes(List<String> obdDtcCodes) {
        this.obdDtcCodes = obdDtcCodes;
    }

    public void addObdDtcCode(String dtc) {
        if (this.obdDtcCodes == null) this.obdDtcCodes = new ArrayList<>();
        this.obdDtcCodes.add(dtc);
    }

    public EvidenceStatus getObdScanStatus() {
        return obdScanStatus;
    }

    public void setObdScanStatus(EvidenceStatus obdScanStatus) {
        this.obdScanStatus = obdScanStatus;
    }

    public String getTransmissionCondition() {
        return transmissionCondition;
    }

    public void setTransmissionCondition(String transmissionCondition) {
        this.transmissionCondition = transmissionCondition;
    }

    public String getExhaustEmissionGrade() {
        return exhaustEmissionGrade;
    }

    public void setExhaustEmissionGrade(String exhaustEmissionGrade) {
        this.exhaustEmissionGrade = exhaustEmissionGrade;
    }

    public String getCoolingSystemHealth() {
        return coolingSystemHealth;
    }

    public void setCoolingSystemHealth(String coolingSystemHealth) {
        this.coolingSystemHealth = coolingSystemHealth;
    }

    public String getChassisSuspensionGrade() {
        return chassisSuspensionGrade;
    }

    public void setChassisSuspensionGrade(String chassisSuspensionGrade) {
        this.chassisSuspensionGrade = chassisSuspensionGrade;
    }

    // Diesel-Specific Getters/Setters
    public String getDpfStatus() {
        return dpfStatus;
    }

    public void setDpfStatus(String dpfStatus) {
        this.dpfStatus = dpfStatus;
    }

    public Double getDpfSootLoadGrams() {
        return dpfSootLoadGrams;
    }

    public void setDpfSootLoadGrams(Double dpfSootLoadGrams) {
        this.dpfSootLoadGrams = dpfSootLoadGrams;
    }

    public EvidenceStatus getDpfEvidenceStatus() {
        return dpfEvidenceStatus;
    }

    public void setDpfEvidenceStatus(EvidenceStatus dpfEvidenceStatus) {
        this.dpfEvidenceStatus = dpfEvidenceStatus;
    }

    public Integer getCommonRailPressureBar() {
        return commonRailPressureBar;
    }

    public void setCommonRailPressureBar(Integer commonRailPressureBar) {
        this.commonRailPressureBar = commonRailPressureBar;
    }

    public EvidenceStatus getCommonRailStatus() {
        return commonRailStatus;
    }

    public void setCommonRailStatus(EvidenceStatus commonRailStatus) {
        this.commonRailStatus = commonRailStatus;
    }

    public String getAdBlueDefStatus() {
        return adBlueDefStatus;
    }

    public void setAdBlueDefStatus(String adBlueDefStatus) {
        this.adBlueDefStatus = adBlueDefStatus;
    }

    public EvidenceStatus getAdBlueStatus() {
        return adBlueStatus;
    }

    public void setAdBlueStatus(EvidenceStatus adBlueStatus) {
        this.adBlueStatus = adBlueStatus;
    }

    public String getGlowPlugStatus() {
        return glowPlugStatus;
    }

    public void setGlowPlugStatus(String glowPlugStatus) {
        this.glowPlugStatus = glowPlugStatus;
    }

    // Petrol-Specific Getters/Setters
    public String getSparkPlugCondition() {
        return sparkPlugCondition;
    }

    public void setSparkPlugCondition(String sparkPlugCondition) {
        this.sparkPlugCondition = sparkPlugCondition;
    }

    public String getCatalyticConverterO2Status() {
        return catalyticConverterO2Status;
    }

    public void setCatalyticConverterO2Status(String catalyticConverterO2Status) {
        this.catalyticConverterO2Status = catalyticConverterO2Status;
    }

    // 2-Wheeler Getters/Setters
    public String getTwoWheelerDriveType() {
        return twoWheelerDriveType;
    }

    public void setTwoWheelerDriveType(String twoWheelerDriveType) {
        this.twoWheelerDriveType = twoWheelerDriveType;
    }

    public String getTwoWheelerDriveCondition() {
        return twoWheelerDriveCondition;
    }

    public void setTwoWheelerDriveCondition(String twoWheelerDriveCondition) {
        this.twoWheelerDriveCondition = twoWheelerDriveCondition;
    }

    public String getTwoWheelerClutchOrBelt() {
        return twoWheelerClutchOrBelt;
    }

    public void setTwoWheelerClutchOrBelt(String twoWheelerClutchOrBelt) {
        this.twoWheelerClutchOrBelt = twoWheelerClutchOrBelt;
    }

    public EvidenceStatus getTwoWheelerDriveStatus() {
        return twoWheelerDriveStatus;
    }

    public void setTwoWheelerDriveStatus(EvidenceStatus twoWheelerDriveStatus) {
        this.twoWheelerDriveStatus = twoWheelerDriveStatus;
    }

    public boolean isRemovableBattery() {
        return isRemovableBattery;
    }

    public void setRemovableBattery(boolean removableBattery) {
        isRemovableBattery = removableBattery;
    }

    public String getBatteryLockerCondition() {
        return batteryLockerCondition;
    }

    public void setBatteryLockerCondition(String batteryLockerCondition) {
        this.batteryLockerCondition = batteryLockerCondition;
    }

    public String getMotorType() {
        return motorType;
    }

    public void setMotorType(String motorType) {
        this.motorType = motorType;
    }

    public String getBatteryEnclosureProtection() {
        return batteryEnclosureProtection;
    }

    public void setBatteryEnclosureProtection(String batteryEnclosureProtection) {
        this.batteryEnclosureProtection = batteryEnclosureProtection;
    }

    // Evidence & Transparency Getters/Setters
    public List<String> getVerifiedItems() {
        return verifiedItems;
    }

    public void setVerifiedItems(List<String> verifiedItems) {
        this.verifiedItems = verifiedItems;
    }

    public void addVerifiedItem(String item) {
        if (this.verifiedItems == null) this.verifiedItems = new ArrayList<>();
        this.verifiedItems.add(item);
    }

    public List<String> getUnverifiedItems() {
        return unverifiedItems;
    }

    public void setUnverifiedItems(List<String> unverifiedItems) {
        this.unverifiedItems = unverifiedItems;
    }

    public void addUnverifiedItem(String item) {
        if (this.unverifiedItems == null) this.unverifiedItems = new ArrayList<>();
        this.unverifiedItems.add(item);
    }

    public List<String> getMissingEvidence() {
        return missingEvidence;
    }

    public void setMissingEvidence(List<String> missingEvidence) {
        this.missingEvidence = missingEvidence;
    }

    public void addMissingEvidence(String item) {
        if (this.missingEvidence == null) this.missingEvidence = new ArrayList<>();
        this.missingEvidence.add(item);
    }

    public List<String> getRecommendedTests() {
        return recommendedTests;
    }

    public void setRecommendedTests(List<String> recommendedTests) {
        this.recommendedTests = recommendedTests;
    }

    public void addRecommendedTest(String item) {
        if (this.recommendedTests == null) this.recommendedTests = new ArrayList<>();
        this.recommendedTests.add(item);
    }

    public boolean isEvReport() {
        return reportType == ReportType.EV_BATTERY;
    }

    public boolean isIceReport() {
        return reportType == ReportType.ICE_ENGINE;
    }
}
