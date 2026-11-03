package com.batteryiq.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Model class representing a Vehicle listing in the BatteryIQ Automotive Marketplace.
 * Supports:
 * - Categories: CAR, BIKE, SCOOTER
 * - Fuel Types: PETROL, DIESEL, ELECTRIC
 * - Conditions: NEW, USED
 * Includes original fields for backward-compatibility with EV telematics and new fields
 * for internal combustion engines (ICE), 2-wheelers, and complete marketplace functionality.
 */
public class Vehicle implements Serializable {
    private static final long serialVersionUID = 2L;

    // Categories
    public static final String CATEGORY_CAR = "CAR";
    public static final String CATEGORY_BIKE = "BIKE";
    public static final String CATEGORY_SCOOTER = "SCOOTER";

    // Fuel Types
    public static final String FUEL_ELECTRIC = "ELECTRIC";
    public static final String FUEL_PETROL = "PETROL";
    public static final String FUEL_DIESEL = "DIESEL";

    // Conditions
    public static final String CONDITION_NEW = "NEW";
    public static final String CONDITION_USED = "USED";

    private int vehicleId;
    private Integer sellerId;
    private String make;
    private String model;
    private String variantTrim;
    private int manufacturingYear;
    private BigDecimal price;
    private int odometerKm;

    // Category, Fuel & Condition
    private String category = CATEGORY_CAR;      // CAR, BIKE, SCOOTER
    private String fuelType = FUEL_ELECTRIC;     // ELECTRIC, PETROL, DIESEL
    private String conditionType = CONDITION_USED;// NEW, USED
    private String bodyType = "Sedan";           // Sedan, SUV, Hatchback, Cruiser, Sports, Commuter, Scooter
    private String transmission = "Automatic";   // Manual, Automatic, CVT, Single-Speed

    // Engine & Performance (for Petrol / Diesel ICE)
    private int engineCc = 0;                    // Engine displacement in cc (e.g. 1498 cc, 350 cc, 125 cc)
    private double mileageKmpl = 0.0;            // Fuel economy in km/l (for Petrol/Diesel)
    private int maxPowerBhp = 0;                 // Power in BHP
    private int seatingCapacity = 5;             // 2 for Bikes/Scooters, 5-7 for Cars
    private int ownerCount = 1;                  // 0 for NEW, 1, 2+ for USED

    // EV Specific Performance
    private double batteryPackKwh;               // Battery capacity (kWh)
    private int originalWltpRangeKm;             // Certified / WLTP Range
    private int fastChargingKw;                  // DC Fast Charging peak speed (kW)
    private String drivetrain = "AWD";           // RWD, FWD, AWD, Chain, Belt

    // Listing Details
    private String exteriorColor;
    private String locationCity;
    private String rtoState = "CA";
    private String status = "AVAILABLE";         // AVAILABLE, RESERVED, SOLD
    private boolean batteryVerified = true;
    private String thumbnailUrl;
    private List<String> galleryImages;
    private List<String> features;

    // Seller / Dealer info
    private String sellerName = "BatteryIQ Certified Network";
    private String sellerPhone = "+1 800-555-BIQ1";
    private String sellerType = "CERTIFIED_DEALER";

    // Attached Comprehensive Health Report
    private VehicleHealthReport healthReport;
    // Attached Legacy Battery Report (for backward-compatibility)
    private BatteryReport batteryReport;

    public Vehicle() {
        this.galleryImages = new ArrayList<>();
        this.features = new ArrayList<>();
    }

    /**
     * Legacy constructor preserved for 100% backward compatibility.
     */
    public Vehicle(int vehicleId, String make, String model, String variantTrim, int manufacturingYear,
                   BigDecimal price, int odometerKm, double batteryPackKwh, int originalWltpRangeKm,
                   int fastChargingKw, String drivetrain, String exteriorColor, String locationCity,
                   String status, boolean batteryVerified, String thumbnailUrl) {
        this();
        this.vehicleId = vehicleId;
        this.make = make;
        this.model = model;
        this.variantTrim = variantTrim;
        this.manufacturingYear = manufacturingYear;
        this.price = price;
        this.odometerKm = odometerKm;
        this.batteryPackKwh = batteryPackKwh;
        this.originalWltpRangeKm = originalWltpRangeKm;
        this.fastChargingKw = fastChargingKw;
        this.drivetrain = drivetrain;
        this.exteriorColor = exteriorColor;
        this.locationCity = locationCity;
        this.status = status;
        this.batteryVerified = batteryVerified;
        this.thumbnailUrl = thumbnailUrl;
        this.category = CATEGORY_CAR;
        this.fuelType = FUEL_ELECTRIC;
        this.conditionType = CONDITION_USED;
    }

    // Extended Full Constructor
    public Vehicle(int vehicleId, String make, String model, String variantTrim, int manufacturingYear,
                   BigDecimal price, int odometerKm, String category, String fuelType, String conditionType,
                   String bodyType, String transmission, int engineCc, double mileageKmpl,
                   double batteryPackKwh, int originalWltpRangeKm, int fastChargingKw, String drivetrain,
                   String exteriorColor, String locationCity, String status, boolean batteryVerified,
                   String thumbnailUrl) {
        this();
        this.vehicleId = vehicleId;
        this.make = make;
        this.model = model;
        this.variantTrim = variantTrim;
        this.manufacturingYear = manufacturingYear;
        this.price = price;
        this.odometerKm = odometerKm;
        this.category = category;
        this.fuelType = fuelType;
        this.conditionType = conditionType;
        this.bodyType = bodyType;
        this.transmission = transmission;
        this.engineCc = engineCc;
        this.mileageKmpl = mileageKmpl;
        this.batteryPackKwh = batteryPackKwh;
        this.originalWltpRangeKm = originalWltpRangeKm;
        this.fastChargingKw = fastChargingKw;
        this.drivetrain = drivetrain;
        this.exteriorColor = exteriorColor;
        this.locationCity = locationCity;
        this.status = status;
        this.batteryVerified = batteryVerified;
        this.thumbnailUrl = thumbnailUrl;
        if (CATEGORY_BIKE.equalsIgnoreCase(category) || CATEGORY_SCOOTER.equalsIgnoreCase(category)) {
            this.seatingCapacity = 2;
        }
        if (CONDITION_NEW.equalsIgnoreCase(conditionType)) {
            this.ownerCount = 0;
            this.odometerKm = 0;
        }
    }

    // Getters and Setters
    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public Integer getSellerId() {
        return sellerId;
    }

    public void setSellerId(Integer sellerId) {
        this.sellerId = sellerId;
    }

    public String getMake() {
        return make;
    }

    public void setMake(String make) {
        this.make = make;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getVariantTrim() {
        return variantTrim;
    }

    public void setVariantTrim(String variantTrim) {
        this.variantTrim = variantTrim;
    }

    public int getManufacturingYear() {
        return manufacturingYear;
    }

    public void setManufacturingYear(int manufacturingYear) {
        this.manufacturingYear = manufacturingYear;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getOdometerKm() {
        return odometerKm;
    }

    public void setOdometerKm(int odometerKm) {
        this.odometerKm = odometerKm;
    }

    public double getBatteryPackKwh() {
        return batteryPackKwh;
    }

    public void setBatteryPackKwh(double batteryPackKwh) {
        this.batteryPackKwh = batteryPackKwh;
    }

    public int getOriginalWltpRangeKm() {
        return originalWltpRangeKm;
    }

    public void setOriginalWltpRangeKm(int originalWltpRangeKm) {
        this.originalWltpRangeKm = originalWltpRangeKm;
    }

    public int getFastChargingKw() {
        return fastChargingKw;
    }

    public void setFastChargingKw(int fastChargingKw) {
        this.fastChargingKw = fastChargingKw;
    }

    public String getDrivetrain() {
        return drivetrain;
    }

    public void setDrivetrain(String drivetrain) {
        this.drivetrain = drivetrain;
    }

    public String getExteriorColor() {
        return exteriorColor;
    }

    public void setExteriorColor(String exteriorColor) {
        this.exteriorColor = exteriorColor;
    }

    public String getLocationCity() {
        return locationCity;
    }

    public void setLocationCity(String locationCity) {
        this.locationCity = locationCity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isBatteryVerified() {
        return batteryVerified;
    }

    public void setBatteryVerified(boolean batteryVerified) {
        this.batteryVerified = batteryVerified;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getFuelType() {
        return fuelType;
    }

    public void setFuelType(String fuelType) {
        this.fuelType = fuelType;
    }

    public String getConditionType() {
        return conditionType;
    }

    public void setConditionType(String conditionType) {
        this.conditionType = conditionType;
    }

    public String getBodyType() {
        return bodyType;
    }

    public void setBodyType(String bodyType) {
        this.bodyType = bodyType;
    }

    public String getTransmission() {
        return transmission;
    }

    public void setTransmission(String transmission) {
        this.transmission = transmission;
    }

    public int getEngineCc() {
        return engineCc;
    }

    public void setEngineCc(int engineCc) {
        this.engineCc = engineCc;
    }

    public double getMileageKmpl() {
        return mileageKmpl;
    }

    public void setMileageKmpl(double mileageKmpl) {
        this.mileageKmpl = mileageKmpl;
    }

    public int getMaxPowerBhp() {
        return maxPowerBhp;
    }

    public void setMaxPowerBhp(int maxPowerBhp) {
        this.maxPowerBhp = maxPowerBhp;
    }

    public int getSeatingCapacity() {
        return seatingCapacity;
    }

    public void setSeatingCapacity(int seatingCapacity) {
        this.seatingCapacity = seatingCapacity;
    }

    public int getOwnerCount() {
        return ownerCount;
    }

    public void setOwnerCount(int ownerCount) {
        this.ownerCount = ownerCount;
    }

    public String getRtoState() {
        return rtoState;
    }

    public void setRtoState(String rtoState) {
        this.rtoState = rtoState;
    }

    public List<String> getGalleryImages() {
        return galleryImages;
    }

    public void setGalleryImages(List<String> galleryImages) {
        this.galleryImages = galleryImages;
    }

    public void addGalleryImage(String url) {
        if (this.galleryImages == null) this.galleryImages = new ArrayList<>();
        this.galleryImages.add(url);
    }

    public List<String> getFeatures() {
        return features;
    }

    public void setFeatures(List<String> features) {
        this.features = features;
    }

    public void addFeature(String feat) {
        if (this.features == null) this.features = new ArrayList<>();
        this.features.add(feat);
    }

    public String getSellerName() {
        return sellerName;
    }

    public void setSellerName(String sellerName) {
        this.sellerName = sellerName;
    }

    public String getSellerPhone() {
        return sellerPhone;
    }

    public void setSellerPhone(String sellerPhone) {
        this.sellerPhone = sellerPhone;
    }

    public String getSellerType() {
        return sellerType;
    }

    public void setSellerType(String sellerType) {
        this.sellerType = sellerType;
    }

    public VehicleHealthReport getHealthReport() {
        return healthReport;
    }

    public void setHealthReport(VehicleHealthReport healthReport) {
        this.healthReport = healthReport;
    }

    public BatteryReport getBatteryReport() {
        return batteryReport;
    }

    public void setBatteryReport(BatteryReport batteryReport) {
        this.batteryReport = batteryReport;
        if (batteryReport != null && this.healthReport == null) {
            this.healthReport = batteryReport.toVehicleHealthReport();
        }
    }

    public String getDisplayName() {
        return manufacturingYear + " " + make + " " + model;
    }

    public boolean isElectric() {
        return FUEL_ELECTRIC.equalsIgnoreCase(fuelType);
    }

    public boolean isCar() {
        return CATEGORY_CAR.equalsIgnoreCase(category);
    }

    public boolean isBike() {
        return CATEGORY_BIKE.equalsIgnoreCase(category);
    }

    public boolean isScooter() {
        return CATEGORY_SCOOTER.equalsIgnoreCase(category);
    }

    public boolean isNewVehicle() {
        return CONDITION_NEW.equalsIgnoreCase(conditionType);
    }

    public boolean isUsedVehicle() {
        return CONDITION_USED.equalsIgnoreCase(conditionType);
    }

    public String getFormattedPrice() {
        if (price == null) return "$0";
        return "$" + NumberFormat.getNumberInstance(Locale.US).format(price.longValue());
    }

    public String getFormattedOdometer() {
        if (isNewVehicle() || odometerKm <= 0) return "Brand New (0 km)";
        return NumberFormat.getNumberInstance(Locale.US).format(odometerKm) + " km";
    }

    public String getEstimatedEmi() {
        if (price == null) return "$0";
        // Approx 60 months at 6.5% interest
        double p = price.doubleValue();
        double monthlyRate = 0.065 / 12;
        int months = 60;
        double emi = (p * monthlyRate * Math.pow(1 + monthlyRate, months)) / (Math.pow(1 + monthlyRate, months) - 1);
        return "$" + Math.round(emi) + "/mo";
    }
}
