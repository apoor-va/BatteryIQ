package com.batteryiq.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;

/**
 * Model representing Machine Learning RUL Model Evaluation Metrics and Academic Limitation Disclosures.
 * Enforces transparency by tracking cell-level train/test separation (zero data leakage)
 * and presenting MAE, RMSE, and R2 performance scores against unseen holdout experimental cells.
 */
public class MLModelMetrics implements Serializable {
    private static final long serialVersionUID = 1L;

    private int modelId;
    private String modelName;
    private String algorithmType;
    private String trainCells; // e.g. 'NASA_B0005, NASA_B0006'
    private String testCells;  // e.g. 'NASA_B0007, NASA_B0018' (Independent holdout test)
    private Date trainingDate;
    private BigDecimal maeCycles;
    private BigDecimal rmseCycles;
    private BigDecimal r2Score;
    private BigDecimal eolThresholdPct;
    private String academicDisclosureNotice;
    private boolean isActive;

    public MLModelMetrics() {
        this.eolThresholdPct = new BigDecimal("70.0");
        this.isActive = true;
    }

    public MLModelMetrics(int modelId, String modelName, String algorithmType, String trainCells,
                          String testCells, Date trainingDate, BigDecimal maeCycles, BigDecimal rmseCycles,
                          BigDecimal r2Score, BigDecimal eolThresholdPct, String academicDisclosureNotice,
                          boolean isActive) {
        this.modelId = modelId;
        this.modelName = modelName;
        this.algorithmType = algorithmType;
        this.trainCells = trainCells;
        this.testCells = testCells;
        this.trainingDate = trainingDate;
        this.maeCycles = maeCycles;
        this.rmseCycles = rmseCycles;
        this.r2Score = r2Score;
        this.eolThresholdPct = eolThresholdPct;
        this.academicDisclosureNotice = academicDisclosureNotice;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getModelId() {
        return modelId;
    }

    public void setModelId(int modelId) {
        this.modelId = modelId;
    }

    public String getModelName() {
        return modelName;
    }

    public void setModelName(String modelName) {
        this.modelName = modelName;
    }

    public String getAlgorithmType() {
        return algorithmType;
    }

    public void setAlgorithmType(String algorithmType) {
        this.algorithmType = algorithmType;
    }

    public String getTrainCells() {
        return trainCells;
    }

    public void setTrainCells(String trainCells) {
        this.trainCells = trainCells;
    }

    public String getTestCells() {
        return testCells;
    }

    public void setTestCells(String testCells) {
        this.testCells = testCells;
    }

    public Date getTrainingDate() {
        return trainingDate;
    }

    public void setTrainingDate(Date trainingDate) {
        this.trainingDate = trainingDate;
    }

    public BigDecimal getMaeCycles() {
        return maeCycles;
    }

    public void setMaeCycles(BigDecimal maeCycles) {
        this.maeCycles = maeCycles;
    }

    public BigDecimal getRmseCycles() {
        return rmseCycles;
    }

    public void setRmseCycles(BigDecimal rmseCycles) {
        this.rmseCycles = rmseCycles;
    }

    public BigDecimal getR2Score() {
        return r2Score;
    }

    public void setR2Score(BigDecimal r2Score) {
        this.r2Score = r2Score;
    }

    public BigDecimal getEolThresholdPct() {
        return eolThresholdPct;
    }

    public void setEolThresholdPct(BigDecimal eolThresholdPct) {
        this.eolThresholdPct = eolThresholdPct;
    }

    public String getAcademicDisclosureNotice() {
        return academicDisclosureNotice;
    }

    public void setAcademicDisclosureNotice(String academicDisclosureNotice) {
        this.academicDisclosureNotice = academicDisclosureNotice;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}

