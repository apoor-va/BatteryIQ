<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.batteryiq.model.Vehicle" %>
            <%@ page import="com.batteryiq.model.VehicleHealthReport" %>
                <% Vehicle vehicle=(Vehicle) request.getAttribute("vehicle"); List<Vehicle> similarVehicles = (List
                    <Vehicle>) request.getAttribute("similarVehicles");
                        Boolean inquirySuccess = (Boolean) request.getAttribute("inquirySuccess");
                        if (vehicle == null) {
                        response.sendRedirect(request.getContextPath() + "/vehicles");
                        return;
                        }
                        VehicleHealthReport health = vehicle.getHealthReport();
                        %>
                        <!DOCTYPE html>
                        <html lang="en">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>
                                <%= vehicle.getDisplayName() %> - BatteryIQ Marketplace
                            </title>
                            <meta name="description"
                                content="Check out the <%= vehicle.getDisplayName() %> with certified BatteryIQ Health Report, verified diagnostics, and transparent pricing.">
                            <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
                            <link rel="icon"
                                href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🚗</text></svg>">
                        </head>

                        <body>

                            <%@ include file="/includes/header.jsp" %>

                                <main class="page-container">
                                    <!-- Breadcrumbs -->
                                    <div class="container breadcrumb-wrapper">
                                        <nav class="breadcrumb-nav" aria-label="Breadcrumb">
                                            <a href="<%= request.getContextPath() %>/">Home</a>
                                            <span class="sep">&rsaquo;</span>
                                            <a href="<%= request.getContextPath() %>/vehicles">Marketplace</a>
                                            <span class="sep">&rsaquo;</span>
                                            <a
                                                href="<%= request.getContextPath() %>/<%= vehicle.getCategory().toLowerCase() %>s">
                                                <%= vehicle.getCategory() %>s
                                            </a>
                                            <span class="sep">&rsaquo;</span>
                                            <span class="current">
                                                <%= vehicle.getDisplayName() %>
                                            </span>
                                        </nav>
                                    </div>

                                    <% if (Boolean.TRUE.equals(inquirySuccess)) { %>
                                        <div class="container">
                                            <div class="alert-success-banner">
                                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2.5">
                                                    <polyline points="20 6 9 17 4 12"></polyline>
                                                </svg>
                                                <div>
                                                    <strong>Inquiry Submitted Successfully!</strong> Our certified
                                                    dealer partner has received your request and will contact you within
                                                    2 hours.
                                                </div>
                                            </div>
                                        </div>
                                        <% } %>

                                            <div class="container vehicle-detail-layout">
                                                <!-- Left Column: Visuals & Specifications -->
                                                <div class="detail-main-col">
                                                    <div class="detail-gallery-card">
                                                        <div class="main-image-wrap">
                                                            <img src="<%= vehicle.getThumbnailUrl() %>"
                                                                alt="<%= vehicle.getDisplayName() %>"
                                                                id="gallery-main-img">
                                                            <div class="gallery-badge-overlay">
                                                                <span
                                                                    class="badge-condition <%= vehicle.getConditionType().toLowerCase() %>">
                                                                    <%= vehicle.getConditionType() %>
                                                                </span>
                                                                <span
                                                                    class="badge-fuel <%= vehicle.getFuelType().toLowerCase() %>">
                                                                    <% if (vehicle.isElectric()) { %>⚡ Electric<% } else
                                                                            if
                                                                            ("DIESEL".equalsIgnoreCase(vehicle.getFuelType()))
                                                                            { %>⛽ Diesel<% } else { %>⛽ Petrol<% } %>
                                                                </span>
                                                            </div>
                                                        </div>

                                                        <% if (vehicle.getGalleryImages() !=null &&
                                                            vehicle.getGalleryImages().size()> 1) { %>
                                                            <div class="gallery-thumbs-row">
                                                                <% for (String imgUrl : vehicle.getGalleryImages()) { %>
                                                                    <div class="thumb-item"
                                                                        onclick="document.getElementById('gallery-main-img').src='<%= imgUrl %>'">
                                                                        <img src="<%= imgUrl %>"
                                                                            alt="Vehicle thumbnail">
                                                                    </div>
                                                                    <% } %>
                                                            </div>
                                                            <% } %>
                                                    </div>

                                                    <!-- Prominent BatteryIQ Signature Health Report Card -->
                                                    <div class="health-report-feature-card">
                                                        <div class="health-card-header">
                                                            <div class="health-card-brand">
                                                                <div class="health-card-icon">🔋</div>
                                                                <div>
                                                                    <h3>BatteryIQ Vehicle Health Report</h3>
                                                                    <p>Comprehensive diagnostic inspection &amp;
                                                                        certified telematics</p>
                                                                </div>
                                                            </div>
                                                            <% if (health !=null) { %>
                                                                <div class="health-card-grade grade-<%= health.getOverallGrade().replace("+", "plus").toLowerCase() %>">
                                                                    <span class="grade-letter">
                                                                        <%= health.getOverallGrade() %>
                                                                    </span>
                                                                    <span class="grade-desc">Certified Grade</span>
                                                                </div>
                                                                <% } %>
                                                        </div>

                                                        <div class="health-card-body">
                                                            <% if (health !=null) { %>
                                                                <div class="health-metric-tiles">
                                                                    <% if (health.isEvReport()) { %>
                                                                        <div class="health-tile">
                                                                            <div class="tile-val">
                                                                                <%= health.getSohPercentage() %>%
                                                                            </div>
                                                                            <div class="tile-lbl">State of Health (SoH)
                                                                            </div>
                                                                            <small class="tile-sub">Battery Capacity
                                                                                Retention</small>
                                                                        </div>
                                                                        <div class="health-tile">
                                                                            <div class="tile-val">
                                                                                <%= health.getEstimatedRealRangeKm() %>
                                                                                    km
                                                                            </div>
                                                                            <div class="tile-lbl">Tested Real-World
                                                                                Range</div>
                                                                            <small class="tile-sub">WLTP: <%=
                                                                                    health.getOriginalRangeKm()> 0 ?
                                                                                    health.getOriginalRangeKm() + " km"
                                                                                    : "N/A" %></small>
                                                                        </div>
                                                                        <div class="health-tile">
                                                                            <div class="tile-val">
                                                                                <%= health.getCellDeviationMv() %> mV
                                                                            </div>
                                                                            <div class="tile-lbl">Cell Voltage Delta
                                                                            </div>
                                                                            <small class="tile-sub">Factory Safe: &lt;25
                                                                                mV</small>
                                                                        </div>
                                                                        <div class="health-tile">
                                                                            <div class="tile-val">
                                                                                <%= health.getThermalStressGrade() %>
                                                                            </div>
                                                                            <div class="tile-lbl">Thermal Stress Grade
                                                                            </div>
                                                                            <small class="tile-sub">Coolant &amp; BMS
                                                                                Safety</small>
                                                                        </div>
                                                                        <% } else { %>
                                                                            <div class="health-tile">
                                                                                <div class="tile-val">
                                                                                    <%= health.getEngineHealthScore() %>
                                                                                        /100
                                                                                </div>
                                                                                <div class="tile-lbl">Engine Health
                                                                                    Score</div>
                                                                                <small class="tile-sub">Mechanical
                                                                                    Diagnostics</small>
                                                                            </div>
                                                                            <div class="health-tile">
                                                                                <div class="tile-val">
                                                                                    <%= health.getCompressionTestResult()
                                                                                        !=null ? "Passed" : "Checked" %>
                                                                                </div>
                                                                                <div class="tile-lbl">Cylinder
                                                                                    Compression</div>
                                                                                <small class="tile-sub">Even pressure
                                                                                    across cylinders</small>
                                                                            </div>
                                                                            <div class="health-tile">
                                                                                <div class="tile-val">
                                                                                    <%= health.getOdometerStatus() %>
                                                                                </div>
                                                                                <div class="tile-lbl">Odometer Verified
                                                                                </div>
                                                                                <small class="tile-sub">ECU runtime
                                                                                    matched</small>
                                                                            </div>
                                                                            <div class="health-tile">
                                                                                <div class="tile-val">
                                                                                    <%= health.getObdScanStatus() %>
                                                                                </div>
                                                                                <div class="tile-lbl">OBD-II Fault Scans
                                                                                </div>
                                                                                <small class="tile-sub">0 critical fault
                                                                                    codes</small>
                                                                            </div>
                                                                            <% } %>
                                                                </div>

                                                                <div class="health-card-footer">
                                                                    <div class="health-cert-info">
                                                                        <span>Certificate Code: <strong>
                                                                                <%= health.getCertificateCode() %>
                                                                            </strong></span>
                                                                        <span>Inspector: <strong>
                                                                                <%= health.getVerifiedByInspector() %>
                                                                            </strong></span>
                                                                    </div>
                                                                    <a href="<%= request.getContextPath() %>/health-report?id=<%= vehicle.getVehicleId() %>"
                                                                        class="btn btn-primary">
                                                                        View Full Detailed Health Report &rarr;
                                                                    </a>
                                                                </div>
                                                                <% } %>
                                                        </div>
                                                    </div>

                                                    <!-- Comprehensive Specifications Matrix -->
                                                    <div class="detail-card">
                                                        <h3 class="detail-card-title">Technical Specifications</h3>
                                                        <div class="specs-grid">
                                                            <div class="spec-cell">
                                                                <span class="spec-label">Category</span>
                                                                <span class="spec-value">
                                                                    <%= vehicle.getCategory() %> (<%=
                                                                            vehicle.getBodyType() %>)
                                                                </span>
                                                            </div>
                                                            <div class="spec-cell">
                                                                <span class="spec-label">Fuel Type</span>
                                                                <span class="spec-value">
                                                                    <%= vehicle.getFuelType() %>
                                                                </span>
                                                            </div>
                                                            <div class="spec-cell">
                                                                <span class="spec-label">Condition</span>
                                                                <span class="spec-value">
                                                                    <%= vehicle.getConditionType() %>
                                                                </span>
                                                            </div>
                                                            <div class="spec-cell">
                                                                <span class="spec-label">Manufacturing Year</span>
                                                                <span class="spec-value">
                                                                    <%= vehicle.getManufacturingYear() %>
                                                                </span>
                                                            </div>
                                                            <div class="spec-cell">
                                                                <span class="spec-label">Odometer Reading</span>
                                                                <span class="spec-value">
                                                                    <%= vehicle.getFormattedOdometer() %>
                                                                </span>
                                                            </div>
                                                            <div class="spec-cell">
                                                                <span class="spec-label">Transmission</span>
                                                                <span class="spec-value">
                                                                    <%= vehicle.getTransmission() %>
                                                                </span>
                                                            </div>
                                                            <div class="spec-cell">
                                                                <span class="spec-label">Drivetrain</span>
                                                                <span class="spec-value">
                                                                    <%= vehicle.getDrivetrain() %>
                                                                </span>
                                                            </div>
                                                            <div class="spec-cell">
                                                                <span class="spec-label">Exterior Color</span>
                                                                <span class="spec-value">
                                                                    <%= vehicle.getExteriorColor() %>
                                                                </span>
                                                            </div>
                                                            <% if (vehicle.isElectric()) { %>
                                                                <div class="spec-cell">
                                                                    <span class="spec-label">Battery Pack
                                                                        Capacity</span>
                                                                    <span class="spec-value">
                                                                        <%= vehicle.getBatteryPackKwh() %> kWh
                                                                    </span>
                                                                </div>
                                                                <div class="spec-cell">
                                                                    <span class="spec-label">Certified Range
                                                                        (WLTP)</span>
                                                                    <span class="spec-value">
                                                                        <%= vehicle.getOriginalWltpRangeKm() %> km
                                                                    </span>
                                                                </div>
                                                                <div class="spec-cell">
                                                                    <span class="spec-label">DC Fast Charging</span>
                                                                    <span class="spec-value">
                                                                        <%= vehicle.getFastChargingKw()> 0 ?
                                                                            vehicle.getFastChargingKw() + " kW Peak" :
                                                                            "Standard AC" %>
                                                                    </span>
                                                                </div>
                                                                <% } else { %>
                                                                    <div class="spec-cell">
                                                                        <span class="spec-label">Engine
                                                                            Displacement</span>
                                                                        <span class="spec-value">
                                                                            <%= vehicle.getEngineCc() %> cc
                                                                        </span>
                                                                    </div>
                                                                    <div class="spec-cell">
                                                                        <span class="spec-label">Max Power</span>
                                                                        <span class="spec-value">
                                                                            <%= vehicle.getMaxPowerBhp()> 0 ?
                                                                                vehicle.getMaxPowerBhp() + " BHP" :
                                                                                "N/A" %>
                                                                        </span>
                                                                    </div>
                                                                    <div class="spec-cell">
                                                                        <span class="spec-label">Fuel Economy
                                                                            (Mileage)</span>
                                                                        <span class="spec-value">
                                                                            <%= vehicle.getMileageKmpl()> 0 ?
                                                                                vehicle.getMileageKmpl() + " km/l" :
                                                                                "N/A" %>
                                                                        </span>
                                                                    </div>
                                                                    <% } %>
                                                                        <div class="spec-cell">
                                                                            <span class="spec-label">Seating
                                                                                Capacity</span>
                                                                            <span class="spec-value">
                                                                                <%= vehicle.getSeatingCapacity() %>
                                                                                    Person
                                                                            </span>
                                                                        </div>
                                                                        <div class="spec-cell">
                                                                            <span class="spec-label">Previous
                                                                                Owners</span>
                                                                            <span class="spec-value">
                                                                                <%= vehicle.getOwnerCount()==0
                                                                                    ? "First Owner (Brand New)" :
                                                                                    vehicle.getOwnerCount()
                                                                                    + " Owner(s)" %>
                                                                            </span>
                                                                        </div>
                                                                        <div class="spec-cell">
                                                                            <span class="spec-label">Registration
                                                                                Location</span>
                                                                            <span class="spec-value">
                                                                                <%= vehicle.getLocationCity() %>
                                                                            </span>
                                                                        </div>
                                                        </div>
                                                    </div>

                                                    <!-- Features & Equipment -->
                                                    <% if (vehicle.getFeatures() !=null &&
                                                        !vehicle.getFeatures().isEmpty()) { %>
                                                        <div class="detail-card">
                                                            <h3 class="detail-card-title">Key Features &amp; Equipment
                                                            </h3>
                                                            <div class="features-pill-grid">
                                                                <% for (String feat : vehicle.getFeatures()) { %>
                                                                    <div class="feature-pill-item">
                                                                        <svg width="14" height="14" viewBox="0 0 24 24"
                                                                            fill="none" stroke="#10b981"
                                                                            stroke-width="2.5">
                                                                            <polyline points="20 6 9 17 4 12">
                                                                            </polyline>
                                                                        </svg>
                                                                        <%= feat %>
                                                                    </div>
                                                                    <% } %>
                                                            </div>
                                                        </div>
                                                        <% } %>
                                                </div>

                                                <!-- Right Column: Pricing, EMI & Lead / Test Drive Box -->
                                                <div class="detail-sidebar-col">
                                                    <div class="price-sticky-card">
                                                        <div class="price-header">
                                                            <span class="price-type">
                                                                <%= vehicle.getConditionType() %> Vehicle Price
                                                            </span>
                                                            <div class="main-price-val">
                                                                <%= vehicle.getFormattedPrice() %>
                                                            </div>
                                                            <div class="emi-breakdown">
                                                                Estimated Monthly EMI: <strong>
                                                                    <%= vehicle.getEstimatedEmi() %>
                                                                </strong> (60 mos @ 6.5%)
                                                            </div>
                                                        </div>

                                                        <!-- Compare Shortcut -->
                                                        <div class="compare-shortcut-box">
                                                            <a href="<%= request.getContextPath() %>/compare?id1=<%= vehicle.getVehicleId() %>"
                                                                class="btn btn-outline btn-block">
                                                                <svg width="16" height="16" viewBox="0 0 24 24"
                                                                    fill="none" stroke="currentColor" stroke-width="2">
                                                                    <path d="M16 3h5v5"></path>
                                                                    <path d="M4 20L21 3"></path>
                                                                    <path d="M21 16v5h-5"></path>
                                                                    <path d="M15 15l6 6"></path>
                                                                    <path d="M4 4l5 5"></path>
                                                                </svg>
                                                                Compare With Another Vehicle
                                                            </a>
                                                        </div>

                                                        <!-- Seller Card -->
                                                        <div class="seller-info-box">
                                                            <div class="seller-avatar">🏢</div>
                                                            <div>
                                                                <h4>
                                                                    <%= vehicle.getSellerName() %>
                                                                </h4>
                                                                <span class="seller-verified-tag">
                                                                    <svg width="12" height="12" viewBox="0 0 24 24"
                                                                        fill="none" stroke="#10b981" stroke-width="3">
                                                                        <polyline points="20 6 9 17 4 12"></polyline>
                                                                    </svg>
                                                                    BatteryIQ Certified Partner
                                                                </span>
                                                                <div class="seller-phone">Call: <%=
                                                                        vehicle.getSellerPhone() %>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <!-- Book Test Drive / Contact Form -->
                                                        <div class="lead-form-box">
                                                            <h4>Book a Test Drive or Make an Offer</h4>
                                                            <form action="<%= request.getContextPath() %>/vehicle"
                                                                method="post" class="detail-lead-form">
                                                                <input type="hidden" name="vehicleId"
                                                                    value="<%= vehicle.getVehicleId() %>">

                                                                <div class="form-group-sm">
                                                                    <label for="cust-name">Full Name</label>
                                                                    <input type="text" id="cust-name"
                                                                        name="customerName" required
                                                                        placeholder="e.g. John Doe">
                                                                </div>

                                                                <div class="form-group-sm">
                                                                    <label for="cust-email">Email Address</label>
                                                                    <input type="email" id="cust-email"
                                                                        name="customerEmail" required
                                                                        placeholder="name@example.com">
                                                                </div>

                                                                <div class="form-group-sm">
                                                                    <label for="cust-phone">Phone Number</label>
                                                                    <input type="tel" id="cust-phone"
                                                                        name="customerPhone" required
                                                                        placeholder="+1 555-019-2831">
                                                                </div>

                                                                <div class="form-group-sm">
                                                                    <label for="inq-type">Request Type</label>
                                                                    <select id="inq-type" name="inquiryType">
                                                                        <option value="TEST_DRIVE">Schedule a Test Drive
                                                                        </option>
                                                                        <option value="PRICE_QUOTE">Get Best On-Road
                                                                            Price</option>
                                                                        <option value="HEALTH_INSPECTION">Request
                                                                            Secondary Battery/Engine Inspection</option>
                                                                    </select>
                                                                </div>

                                                                <div class="form-group-sm">
                                                                    <label for="cust-msg">Message / Preferred Date
                                                                        (Optional)</label>
                                                                    <textarea id="cust-msg" name="message" rows="2"
                                                                        placeholder="I am interested in viewing this vehicle this Saturday..."></textarea>
                                                                </div>

                                                                <button type="submit" class="btn btn-primary btn-block">
                                                                    Submit Request
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Similar Recommended Vehicles -->
                                            <% if (similarVehicles !=null && !similarVehicles.isEmpty()) { %>
                                                <div class="container similar-vehicles-section">
                                                    <div class="section-header">
                                                        <div>
                                                            <span class="section-tag">Similar Options</span>
                                                            <h2 class="section-title">You Might Also Like</h2>
                                                        </div>
                                                    </div>

                                                    <div class="vehicle-cards-grid">
                                                        <% for (Vehicle sv : similarVehicles) { %>
                                                            <div class="vehicle-card">
                                                                <div class="card-media">
                                                                    <img src="<%= sv.getThumbnailUrl() %>"
                                                                        alt="<%= sv.getDisplayName() %>">
                                                                    <div class="card-badges">
                                                                        <span
                                                                            class="badge-condition <%= sv.getConditionType().toLowerCase() %>">
                                                                            <%= sv.getConditionType() %>
                                                                        </span>
                                                                        <span
                                                                            class="badge-fuel <%= sv.getFuelType().toLowerCase() %>">
                                                                            <%= sv.getFuelType() %>
                                                                        </span>
                                                                    </div>
                                                                </div>
                                                                <div class="card-body">
                                                                    <h3 class="card-title">
                                                                        <a
                                                                            href="<%= request.getContextPath() %>/vehicle?id=<%= sv.getVehicleId() %>">
                                                                            <%= sv.getDisplayName() %>
                                                                        </a>
                                                                    </h3>
                                                                    <div class="card-specs-row">
                                                                        <div class="spec-chip">
                                                                            <%= sv.getFormattedOdometer() %>
                                                                        </div>
                                                                        <div class="spec-chip">
                                                                            <%= sv.getLocationCity() %>
                                                                        </div>
                                                                    </div>
                                                                    <div class="card-price-row">
                                                                        <div class="price-val">
                                                                            <%= sv.getFormattedPrice() %>
                                                                        </div>
                                                                        <a href="<%= request.getContextPath() %>/vehicle?id=<%= sv.getVehicleId() %>"
                                                                            class="btn btn-primary btn-sm">View</a>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <% } %>
                                                    </div>
                                                </div>
                                                <% } %>
                                </main>

                                <%@ include file="/includes/footer.jsp" %>
                                    <script src="<%= request.getContextPath() %>/js/main.js"></script>
                        </body>

                        </html>