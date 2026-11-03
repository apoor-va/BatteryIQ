package com.batteryiq.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model representing a BatteryIQ Telemetry Session.
 * Bridges all three telemetry data sources (Public Dataset, Simulator, and Live OBD)
 * while preserving strict provenance tagging, Ah/kWh capacity duality, and verification boundaries.
 */
public class BatterySession implements Serializable {
    private static final long serialVersionUID = 1L;

    private int sessionId;
    private Integer vehicleId; // Nullable if standalone cell or dataset test
    private String sessionUuid;
    private String sourceType; // 'PUBLIC_DATASET', 'SIMULATOR', 'LIVE_OBD'
    private String datasetName;
    private String cellOrPackIdentifier;
    private String chemistryProfileId;

    // Dual Unit Capacity Support
    private BigDecimal nominalCapacityValue;
    private BigDecimal freshBaselineCapacityValue;
    private BigDecimal currentMeasuredCapacityValue;
    private CapacityUnit capacityUnit;
    private String activeReferenceType; // 'RATED_NOMINAL', 'FRESH_BASELINE'

    // Telemetry & Analysis Summary (Strictly nullable)
    private BigDecimal initialSocPct;
    private String socEstimationMethod; // 'COULOMB_COUNTING', 'OCV_REST_LOOKUP', 'BMS_CAN_REPORTED', 'UNAVAILABLE'
    private BigDecimal estimatedSohPct;
    private Integer estimatedRulCycles;
    private String conditionCategory; // 'EXCELLENT', 'GOOD', 'MODERATE', 'POOR', 'CRITICAL', 'UNAVAILABLE'

    // Independent Verification Separation (Live data is NOT auto-verified)
    private String telemetryStatus; // 'RAW_STREAMING', 'PROCESSED_CLEAN', 'PROCESSED_WITH_ANOMALIES', 'INSUFFICIENT_TELEMETRY'
    private String verificationStatus; // 'UNVERIFIED_DEMO', 'UNVERIFIED_DATASET', 'UNVERIFIED_LIVE_TELEMETRY', 'PHYSICALLY_VERIFIED'

    private String hardwareAdapterUsed;
    private String protocolTargetProfile;
    private boolean isHardwarePhysicallyValidated;
    private Timestamp recordedAt;

    public BatterySession() {
        this.capacityUnit = CapacityUnit.KWH;
        this.activeReferenceType = "RATED_NOMINAL";
        this.socEstimationMethod = "UNAVAILABLE";
        this.conditionCategory = "UNAVAILABLE";
        this.telemetryStatus = "RAW_STREAMING";
        this.verificationStatus = "UNVERIFIED_DEMO";
    }

    // Getters and Setters
    public int getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }

    public Integer getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(Integer vehicleId) {
        this.vehicleId = vehicleId;
    }

    public String getSessionUuid() {
        return sessionUuid;
    }

    public void setSessionUuid(String sessionUuid) {
        this.sessionUuid = sessionUuid;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public String getDatasetName() {
        return datasetName;
    }

    public void setDatasetName(String datasetName) {
        this.datasetName = datasetName;
    }

    public String getCellOrPackIdentifier() {
        return cellOrPackIdentifier;
    }

    public void setCellOrPackIdentifier(String cellOrPackIdentifier) {
        this.cellOrPackIdentifier = cellOrPackIdentifier;
    }

    public String getChemistryProfileId() {
        return chemistryProfileId;
    }

    public void setChemistryProfileId(String chemistryProfileId) {
        this.chemistryProfileId = chemistryProfileId;
    }

    public BigDecimal getNominalCapacityValue() {
        return nominalCapacityValue;
    }

    public void setNominalCapacityValue(BigDecimal nominalCapacityValue) {
        this.nominalCapacityValue = nominalCapacityValue;
    }

    public BigDecimal getFreshBaselineCapacityValue() {
        return freshBaselineCapacityValue;
    }

    public void setFreshBaselineCapacityValue(BigDecimal freshBaselineCapacityValue) {
        this.freshBaselineCapacityValue = freshBaselineCapacityValue;
    }

    public BigDecimal getCurrentMeasuredCapacityValue() {
        return currentMeasuredCapacityValue;
    }

    public void setCurrentMeasuredCapacityValue(BigDecimal currentMeasuredCapacityValue) {
        this.currentMeasuredCapacityValue = currentMeasuredCapacityValue;
    }

    public CapacityUnit getCapacityUnit() {
        return capacityUnit != null ? capacityUnit : CapacityUnit.KWH;
    }

    public void setCapacityUnit(CapacityUnit capacityUnit) {
        this.capacityUnit = capacityUnit;
    }

    public String getActiveReferenceType() {
        return activeReferenceType;
    }

    public void setActiveReferenceType(String activeReferenceType) {
        this.activeReferenceType = activeReferenceType;
    }

    public BigDecimal getInitialSocPct() {
        return initialSocPct;
    }

    public void setInitialSocPct(BigDecimal initialSocPct) {
        this.initialSocPct = initialSocPct;
    }

    public String getSocEstimationMethod() {
        return socEstimationMethod;
    }

    public void setSocEstimationMethod(String socEstimationMethod) {
        this.socEstimationMethod = socEstimationMethod;
    }

    public BigDecimal getEstimatedSohPct() {
        return estimatedSohPct;
    }

    public void setEstimatedSohPct(BigDecimal estimatedSohPct) {
        this.estimatedSohPct = estimatedSohPct;
    }

    public Integer getEstimatedRulCycles() {
        return estimatedRulCycles;
    }

    public void setEstimatedRulCycles(Integer estimatedRulCycles) {
        this.estimatedRulCycles = estimatedRulCycles;
    }

    public String getConditionCategory() {
        return conditionCategory;
    }

    public void setConditionCategory(String conditionCategory) {
        this.conditionCategory = conditionCategory;
    }

    public String getTelemetryStatus() {
        return telemetryStatus;
    }

    public void setTelemetryStatus(String telemetryStatus) {
        this.telemetryStatus = telemetryStatus;
    }

    public String getVerificationStatus() {
        return verificationStatus;
    }

    public void setVerificationStatus(String verificationStatus) {
        this.verificationStatus = verificationStatus;
    }

    public String getHardwareAdapterUsed() {
        return hardwareAdapterUsed;
    }

    public void setHardwareAdapterUsed(String hardwareAdapterUsed) {
        this.hardwareAdapterUsed = hardwareAdapterUsed;
    }

    public String getProtocolTargetProfile() {
        return protocolTargetProfile;
    }

    public void setProtocolTargetProfile(String protocolTargetProfile) {
        this.protocolTargetProfile = protocolTargetProfile;
    }

    public boolean isHardwarePhysicallyValidated() {
        return isHardwarePhysicallyValidated;
    }

    public void setHardwarePhysicallyValidated(boolean hardwarePhysicallyValidated) {
        isHardwarePhysicallyValidated = hardwarePhysicallyValidated;
    }

    public Timestamp getRecordedAt() {
        return recordedAt;
    }

    public void setRecordedAt(Timestamp recordedAt) {
        this.recordedAt = recordedAt;
    }

    // Helper Presentation Methods
    public String getFormattedNominalCapacity() {
        if (nominalCapacityValue == null) return "N/A";
        return nominalCapacityValue.stripTrailingZeros().toPlainString() + " " + getCapacityUnit().getSymbol();
    }

    public String getFormattedCurrentCapacity() {
        if (currentMeasuredCapacityValue == null) return "Pending Evaluation";
        return currentMeasuredCapacityValue.stripTrailingZeros().toPlainString() + " " + getCapacityUnit().getSymbol();
    }

    public boolean isPublicDataset() {
        return "PUBLIC_DATASET".equalsIgnoreCase(sourceType);
    }

    public boolean isSimulator() {
        return "SIMULATOR".equalsIgnoreCase(sourceType);
    }

    public boolean isLiveObd() {
        return "LIVE_OBD".equalsIgnoreCase(sourceType);
    }

    public boolean isPhysicallyVerified() {
        return "PHYSICALLY_VERIFIED".equalsIgnoreCase(verificationStatus);
    }
}

