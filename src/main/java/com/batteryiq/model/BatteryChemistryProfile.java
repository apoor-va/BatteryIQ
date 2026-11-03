package com.batteryiq.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Model representing scientifically parameterized electrochemical battery chemistry profiles.
 * Encapsulates chemistry-specific properties (LFP, NMC, NCA, LCO) to eliminate hardcoded universal assumptions.
 */
public class BatteryChemistryProfile implements Serializable {
    private static final long serialVersionUID = 1L;

    private String profileId;
    private String chemistryName;
    private BigDecimal nominalCellVoltage;
    private BigDecimal cutoffVoltage;
    private BigDecimal maxChargeVoltage;
    private BigDecimal coulombicEfficiency;
    private BigDecimal thermalWarningTempCelsius;
    private BigDecimal thermalCriticalTempCelsius;
    private BigDecimal eolSohThresholdPct;
    private String ocvLookupTableJson;
    private String profileNotes;

    public BatteryChemistryProfile() {
    }

    public BatteryChemistryProfile(String profileId, String chemistryName, BigDecimal nominalCellVoltage,
                                   BigDecimal cutoffVoltage, BigDecimal maxChargeVoltage,
                                   BigDecimal coulombicEfficiency, BigDecimal thermalWarningTempCelsius,
                                   BigDecimal thermalCriticalTempCelsius, BigDecimal eolSohThresholdPct,
                                   String ocvLookupTableJson, String profileNotes) {
        this.profileId = profileId;
        this.chemistryName = chemistryName;
        this.nominalCellVoltage = nominalCellVoltage;
        this.cutoffVoltage = cutoffVoltage;
        this.maxChargeVoltage = maxChargeVoltage;
        this.coulombicEfficiency = coulombicEfficiency;
        this.thermalWarningTempCelsius = thermalWarningTempCelsius;
        this.thermalCriticalTempCelsius = thermalCriticalTempCelsius;
        this.eolSohThresholdPct = eolSohThresholdPct;
        this.ocvLookupTableJson = ocvLookupTableJson;
        this.profileNotes = profileNotes;
    }

    public String getProfileId() {
        return profileId;
    }

    public void setProfileId(String profileId) {
        this.profileId = profileId;
    }

    public String getChemistryName() {
        return chemistryName;
    }

    public void setChemistryName(String chemistryName) {
        this.chemistryName = chemistryName;
    }

    public BigDecimal getNominalCellVoltage() {
        return nominalCellVoltage;
    }

    public void setNominalCellVoltage(BigDecimal nominalCellVoltage) {
        this.nominalCellVoltage = nominalCellVoltage;
    }

    public BigDecimal getCutoffVoltage() {
        return cutoffVoltage;
    }

    public void setCutoffVoltage(BigDecimal cutoffVoltage) {
        this.cutoffVoltage = cutoffVoltage;
    }

    public BigDecimal getMaxChargeVoltage() {
        return maxChargeVoltage;
    }

    public void setMaxChargeVoltage(BigDecimal maxChargeVoltage) {
        this.maxChargeVoltage = maxChargeVoltage;
    }

    public BigDecimal getCoulombicEfficiency() {
        return coulombicEfficiency;
    }

    public void setCoulombicEfficiency(BigDecimal coulombicEfficiency) {
        this.coulombicEfficiency = coulombicEfficiency;
    }

    public BigDecimal getThermalWarningTempCelsius() {
        return thermalWarningTempCelsius;
    }

    public void setThermalWarningTempCelsius(BigDecimal thermalWarningTempCelsius) {
        this.thermalWarningTempCelsius = thermalWarningTempCelsius;
    }

    public BigDecimal getThermalCriticalTempCelsius() {
        return thermalCriticalTempCelsius;
    }

    public void setThermalCriticalTempCelsius(BigDecimal thermalCriticalTempCelsius) {
        this.thermalCriticalTempCelsius = thermalCriticalTempCelsius;
    }

    public BigDecimal getEolSohThresholdPct() {
        return eolSohThresholdPct;
    }

    public void setEolSohThresholdPct(BigDecimal eolSohThresholdPct) {
        this.eolSohThresholdPct = eolSohThresholdPct;
    }

    public String getOcvLookupTableJson() {
        return ocvLookupTableJson;
    }

    public void setOcvLookupTableJson(String ocvLookupTableJson) {
        this.ocvLookupTableJson = ocvLookupTableJson;
    }

    public String getProfileNotes() {
        return profileNotes;
    }

    public void setProfileNotes(String profileNotes) {
        this.profileNotes = profileNotes;
    }
}

