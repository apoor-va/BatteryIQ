package com.batteryiq.hardware.telemetry;

import java.util.*;

/**
 * Standardized Common Live Telemetry Packet.
 * Aggregates decoded signals from OBD-II or CAN bus interfaces.
 *
 * NULL-SAFETY PRINCIPLE:
 * If a sensor signal is not broadcast by the vehicle BMS or cannot be read by the adapter,
 * its field remains strictly NULL. Never inject fabricated zero readings.
 */
public class LiveTelemetryPacket {

    private long timestampOffsetMs;
    private Double voltageVolts;
    private Double currentAmps;
    private Double temperatureCelsius;
    private Double socPercentage;
    private Double currentMeasuredCapacity;
    private String capacityUnit = "KWH";
    private Integer cellDeltaMv;
    private Double activePowerKw;
    private Double cRate;

    private String adapterId;
    private String protocolProfile;
    private final List<String> supportedSignals = new ArrayList<String>();
    private final List<String> unsupportedSignals = new ArrayList<String>();
    private final List<String> rawLog = new ArrayList<String>();

    public LiveTelemetryPacket() {
        this.timestampOffsetMs = System.currentTimeMillis();
    }

    public long getTimestampOffsetMs() {
        return timestampOffsetMs;
    }

    public void setTimestampOffsetMs(long timestampOffsetMs) {
        this.timestampOffsetMs = timestampOffsetMs;
    }

    public Double getVoltageVolts() {
        return voltageVolts;
    }

    public void setVoltageVolts(Double voltageVolts) {
        this.voltageVolts = voltageVolts;
        recalculatePower();
    }

    public Double getCurrentAmps() {
        return currentAmps;
    }

    public void setCurrentAmps(Double currentAmps) {
        this.currentAmps = currentAmps;
        recalculatePower();
    }

    public Double getTemperatureCelsius() {
        return temperatureCelsius;
    }

    public void setTemperatureCelsius(Double temperatureCelsius) {
        this.temperatureCelsius = temperatureCelsius;
    }

    public Double getSocPercentage() {
        return socPercentage;
    }

    public void setSocPercentage(Double socPercentage) {
        this.socPercentage = socPercentage;
    }

    public Double getCurrentMeasuredCapacity() {
        return currentMeasuredCapacity;
    }

    public void setCurrentMeasuredCapacity(Double currentMeasuredCapacity) {
        this.currentMeasuredCapacity = currentMeasuredCapacity;
    }

    public String getCapacityUnit() {
        return capacityUnit;
    }

    public void setCapacityUnit(String capacityUnit) {
        this.capacityUnit = capacityUnit;
    }

    public Integer getCellDeltaMv() {
        return cellDeltaMv;
    }

    public void setCellDeltaMv(Integer cellDeltaMv) {
        this.cellDeltaMv = cellDeltaMv;
    }

    public Double getActivePowerKw() {
        return activePowerKw;
    }

    public Double getcRate() {
        return cRate;
    }

    public void setcRate(Double cRate) {
        this.cRate = cRate;
    }

    public String getAdapterId() {
        return adapterId;
    }

    public void setAdapterId(String adapterId) {
        this.adapterId = adapterId;
    }

    public String getProtocolProfile() {
        return protocolProfile;
    }

    public void setProtocolProfile(String protocolProfile) {
        this.protocolProfile = protocolProfile;
    }

    public List<String> getSupportedSignals() {
        return Collections.unmodifiableList(supportedSignals);
    }

    public void addSupportedSignal(String sig) {
        if (!supportedSignals.contains(sig)) {
            supportedSignals.add(sig);
        }
    }

    public List<String> getUnsupportedSignals() {
        return Collections.unmodifiableList(unsupportedSignals);
    }

    public void addUnsupportedSignal(String sig) {
        if (!unsupportedSignals.contains(sig)) {
            unsupportedSignals.add(sig);
        }
    }

    public List<String> getRawLog() {
        return Collections.unmodifiableList(rawLog);
    }

    public void addRawLog(String entry) {
        rawLog.add(entry);
    }

    private void recalculatePower() {
        if (voltageVolts != null && currentAmps != null) {
            this.activePowerKw = Math.round((voltageVolts * currentAmps / 1000.0) * 100.0) / 100.0;
        } else {
            this.activePowerKw = null;
        }
    }
}

