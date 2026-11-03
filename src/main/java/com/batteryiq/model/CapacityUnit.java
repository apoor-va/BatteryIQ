package com.batteryiq.model;

/**
 * Enumeration representing battery capacity measurement units.
 * Supports Ampere-hours (Ah) for single laboratory bench cells and
 * kilowatt-hours (kWh) for complete electric vehicle traction packs.
 */
public enum CapacityUnit {
    AH("Ah", "Ampere-hours (Laboratory Cells / Small Modules)"),
    KWH("kWh", "Kilowatt-hours (EV Traction Battery Packs)");

    private final String symbol;
    private final String description;

    CapacityUnit(String symbol, String description) {
        this.symbol = symbol;
        this.description = description;
    }

    public String getSymbol() {
        return symbol;
    }

    public String getDescription() {
        return description;
    }

    public static CapacityUnit fromString(String text) {
        if (text == null || text.trim().isEmpty()) {
            return KWH;
        }
        for (CapacityUnit unit : CapacityUnit.values()) {
            if (unit.name().equalsIgnoreCase(text.trim()) || unit.symbol.equalsIgnoreCase(text.trim())) {
                return unit;
            }
        }
        return KWH;
    }
}

