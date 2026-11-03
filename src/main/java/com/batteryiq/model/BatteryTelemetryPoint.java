package com.batteryiq.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Model representing an individual time-series frame of battery telemetry readings.
 * Supports strictly nullable sensor values to prevent inserting false zeros or invented measurements
 * when diagnostic sensors are offline or unsupported by the vehicle ECU.
 */
public class BatteryTelemetryPoint implements Serializable {
    private static final long serialVersionUID = 1L;

    private long readingId;
    private int sessionId;
    private long timestampOffsetMs; // BIGINT timestamp offset in milliseconds

    // Strictly nullable sensor measurements
    private BigDecimal voltageVolts;
    private BigDecimal currentAmps;
    private BigDecimal temperatureCelsius;
    private BigDecimal socPercentage;
    private Integer cellDeltaMv;
    private BigDecimal activePowerKw;
    private BigDecimal cRate;

    private boolean hasAnomaly;
    private String anomalyDescription;

    public BatteryTelemetryPoint() {
        this.hasAnomaly = false;
    }

    public BatteryTelemetryPoint(long readingId, int sessionId, long timestampOffsetMs,
                                 BigDecimal voltageVolts, BigDecimal currentAmps,
                                 BigDecimal temperatureCelsius, BigDecimal socPercentage,
                                 Integer cellDeltaMv, BigDecimal activePowerKw, BigDecimal cRate,
                                 boolean hasAnomaly, String anomalyDescription) {
        this.readingId = readingId;
        this.sessionId = sessionId;
        this.timestampOffsetMs = timestampOffsetMs;
        this.voltageVolts = voltageVolts;
        this.currentAmps = currentAmps;
        this.temperatureCelsius = temperatureCelsius;
        this.socPercentage = socPercentage;
        this.cellDeltaMv = cellDeltaMv;
        this.activePowerKw = activePowerKw;
        this.cRate = cRate;
        this.hasAnomaly = hasAnomaly;
        this.anomalyDescription = anomalyDescription;
    }

    // Getters and Setters
    public long getReadingId() {
        return readingId;
    }

    public void setReadingId(long readingId) {
        this.readingId = readingId;
    }

    public int getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }

    public long getTimestampOffsetMs() {
        return timestampOffsetMs;
    }

    public void setTimestampOffsetMs(long timestampOffsetMs) {
        this.timestampOffsetMs = timestampOffsetMs;
    }

    public BigDecimal getVoltageVolts() {
        return voltageVolts;
    }

    public void setVoltageVolts(BigDecimal voltageVolts) {
        this.voltageVolts = voltageVolts;
    }

    public BigDecimal getCurrentAmps() {
        return currentAmps;
    }

    public void setCurrentAmps(BigDecimal currentAmps) {
        this.currentAmps = currentAmps;
    }

    public BigDecimal getTemperatureCelsius() {
        return temperatureCelsius;
    }

    public void setTemperatureCelsius(BigDecimal temperatureCelsius) {
        this.temperatureCelsius = temperatureCelsius;
    }

    public BigDecimal getSocPercentage() {
        return socPercentage;
    }

    public void setSocPercentage(BigDecimal socPercentage) {
        this.socPercentage = socPercentage;
    }

    public Integer getCellDeltaMv() {
        return cellDeltaMv;
    }

    public void setCellDeltaMv(Integer cellDeltaMv) {
        this.cellDeltaMv = cellDeltaMv;
    }

    public BigDecimal getActivePowerKw() {
        return activePowerKw;
    }

    public void setActivePowerKw(BigDecimal activePowerKw) {
        this.activePowerKw = activePowerKw;
    }

    public BigDecimal getcRate() {
        return cRate;
    }

    public void setcRate(BigDecimal cRate) {
        this.cRate = cRate;
    }

    public boolean isHasAnomaly() {
        return hasAnomaly;
    }

    public void setHasAnomaly(boolean hasAnomaly) {
        this.hasAnomaly = hasAnomaly;
    }

    public String getAnomalyDescription() {
        return anomalyDescription;
    }

    public void setAnomalyDescription(String anomalyDescription) {
        this.anomalyDescription = anomalyDescription;
    }

    // Null-Safe Availability Checkers
    public boolean isVoltageAvailable() {
        return voltageVolts != null;
    }

    public boolean isCurrentAvailable() {
        return currentAmps != null;
    }

    public boolean isTemperatureAvailable() {
        return temperatureCelsius != null;
    }

    public boolean isSocAvailable() {
        return socPercentage != null;
    }

    public boolean isCellDeltaAvailable() {
        return cellDeltaMv != null;
    }

    // Presentation Formatters
    public String getFormattedVoltage() {
        return voltageVolts != null ? voltageVolts.stripTrailingZeros().toPlainString() + " V" : "Unavailable";
    }

    public String getFormattedCurrent() {
        return currentAmps != null ? currentAmps.stripTrailingZeros().toPlainString() + " A" : "Unavailable";
    }

    public String getFormattedTemperature() {
        return temperatureCelsius != null ? temperatureCelsius.stripTrailingZeros().toPlainString() + " °C" : "Unavailable";
    }

    public String getFormattedSoc() {
        return socPercentage != null ? socPercentage.stripTrailingZeros().toPlainString() + "%" : "Unavailable";
    }

    public String getFormattedCellDelta() {
        return cellDeltaMv != null ? cellDeltaMv + " mV" : "Unavailable";
    }
}

