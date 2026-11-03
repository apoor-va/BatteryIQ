<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.batteryiq.model.Vehicle" %>
            <%@ page import="com.batteryiq.model.VehicleHealthReport" %>
                <% List<Vehicle> compareList = (List<Vehicle>) request.getAttribute("compareList");
                        Vehicle v1 = (Vehicle) request.getAttribute("v1");
                        Vehicle v2 = (Vehicle) request.getAttribute("v2");
                        Vehicle v3 = (Vehicle) request.getAttribute("v3");
                        List<Vehicle> allVehicles = (List<Vehicle>) request.getAttribute("allVehicles");
                                String selectedCategory = (String) request.getAttribute("selectedCategory");
                                %>
                                <!DOCTYPE html>
                                <html lang="en">

                                <head>
                                    <meta charset="UTF-8">
                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                    <title>Vehicle Comparison - BatteryIQ Automotive Marketplace</title>
                                    <meta name="description"
                                        content="Compare Cars, Bikes, and Scooters side-by-side on specifications, prices, fuel mechanics, and certified BatteryIQ health diagnostics.">
                                    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
                                    <link rel="icon"
                                        href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>⚖️</text></svg>">
                                </head>

                                <body>

                                    <%@ include file="/includes/header.jsp" %>

                                        <main class="page-container">
                                            <!-- Page Title -->
                                            <div class="page-header-bar">
                                                <div class="container">
                                                    <nav class="breadcrumb-nav" aria-label="Breadcrumb">
                                                        <a href="<%= request.getContextPath() %>/">Home</a>
                                                        <span class="sep">&rsaquo;</span>
                                                        <span class="current">Compare Vehicles</span>
                                                    </nav>
                                                    <div class="page-title-row">
                                                        <div>
                                                            <h1 class="page-title">Vehicle Comparison Matrix</h1>
                                                            <p class="page-subtitle">Compare up to 3 vehicles
                                                                side-by-side across pricing, technical specifications,
                                                                and verified health diagnostics.</p>
                                                        </div>
                                                    </div>

                                                    <!-- Category Comparison Switcher -->
                                                    <div class="compare-cat-switcher">
                                                        <a href="<%= request.getContextPath() %>/compare?category=CAR"
                                                            class="comp-cat-btn <%= "CAR".equalsIgnoreCase(selectedCategory) ? "active" : "" %>">
                                                            🚗 Compare Cars
                                                        </a>
                                                        <a href="<%= request.getContextPath() %>/compare?category=BIKE"
                                                            class="comp-cat-btn <%= "BIKE".equalsIgnoreCase(selectedCategory) ? "active" : "" %>">
                                                            🏍️ Compare Bikes
                                                        </a>
                                                        <a href="<%= request.getContextPath() %>/compare?category=SCOOTER"
                                                            class="comp-cat-btn <%= "SCOOTER".equalsIgnoreCase(selectedCategory) ? "active" : "" %>">
                                                            🛵 Compare Scooters
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="container compare-container">
                                                <!-- Vehicle Selector Header -->
                                                <form action="<%= request.getContextPath() %>/compare" method="get"
                                                    class="compare-selector-form">
                                                    <input type="hidden" name="category"
                                                        value="<%= selectedCategory %>">
                                                    <div class="selector-grid">
                                                        <!-- Slot 1 -->
                                                        <div class="selector-slot">
                                                            <label for="sel-id1">Vehicle 1</label>
                                                            <select name="id1" id="sel-id1"
                                                                onchange="this.form.submit()">
                                                                <% for (Vehicle v : allVehicles) { %>
                                                                    <option value="<%= v.getVehicleId() %>" <%=(v1
                                                                        !=null && v1.getVehicleId()==v.getVehicleId())
                                                                        ? "selected" : "" %>>
                                                                        [<%= v.getCategory() %> - <%= v.getFuelType() %>
                                                                                ] <%= v.getDisplayName() %>
                                                                    </option>
                                                                    <% } %>
                                                            </select>
                                                        </div>

                                                        <!-- Slot 2 -->
                                                        <div class="selector-slot">
                                                            <label for="sel-id2">Vehicle 2</label>
                                                            <select name="id2" id="sel-id2"
                                                                onchange="this.form.submit()">
                                                                <% for (Vehicle v : allVehicles) { %>
                                                                    <option value="<%= v.getVehicleId() %>" <%=(v2
                                                                        !=null && v2.getVehicleId()==v.getVehicleId())
                                                                        ? "selected" : "" %>>
                                                                        [<%= v.getCategory() %> - <%= v.getFuelType() %>
                                                                                ] <%= v.getDisplayName() %>
                                                                    </option>
                                                                    <% } %>
                                                            </select>
                                                        </div>

                                                        <!-- Slot 3 (Optional) -->
                                                        <div class="selector-slot">
                                                            <label for="sel-id3">Vehicle 3 (Optional)</label>
                                                            <select name="id3" id="sel-id3"
                                                                onchange="this.form.submit()">
                                                                <option value="">-- Add 3rd Vehicle --</option>
                                                                <% for (Vehicle v : allVehicles) { %>
                                                                    <option value="<%= v.getVehicleId() %>" <%=(v3
                                                                        !=null && v3.getVehicleId()==v.getVehicleId())
                                                                        ? "selected" : "" %>>
                                                                        [<%= v.getCategory() %> - <%= v.getFuelType() %>
                                                                                ] <%= v.getDisplayName() %>
                                                                    </option>
                                                                    <% } %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </form>

                                                <!-- Side-by-Side Comparison Matrix Table -->
                                                <div class="compare-table-card">
                                                    <table class="compare-table"
                                                        aria-label="Vehicle comparison details">
                                                        <thead>
                                                            <tr>
                                                                <th class="feature-col">Vehicle Details</th>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <th class="vehicle-col">
                                                                        <div class="comp-vehicle-header">
                                                                            <div class="comp-img-wrap">
                                                                                <img src="<%= v.getThumbnailUrl() %>"
                                                                                    alt="<%= v.getDisplayName() %>">
                                                                                <span
                                                                                    class="comp-badge-fuel <%= v.getFuelType().toLowerCase() %>">
                                                                                    <%= v.getFuelType() %>
                                                                                </span>
                                                                            </div>
                                                                            <h3 class="comp-title">
                                                                                <%= v.getDisplayName() %>
                                                                            </h3>
                                                                            <div class="comp-variant">
                                                                                <%= v.getVariantTrim() %>
                                                                            </div>
                                                                            <div class="comp-price">
                                                                                <%= v.getFormattedPrice() %>
                                                                            </div>
                                                                            <div class="comp-emi">Est. <%=
                                                                                    v.getEstimatedEmi() %>
                                                                            </div>
                                                                            <div class="comp-cta-group">
                                                                                <a href="<%= request.getContextPath() %>/vehicle?id=<%= v.getVehicleId() %>"
                                                                                    class="btn btn-primary btn-sm">View
                                                                                    Details</a>
                                                                                <a href="<%= request.getContextPath() %>/health-report?id=<%= v.getVehicleId() %>"
                                                                                    class="btn btn-outline-health btn-sm">Full
                                                                                    Report</a>
                                                                            </div>
                                                                        </div>
                                                                    </th>
                                                                    <% } %>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <!-- Section: BatteryIQ Health Certification -->
                                                            <tr class="section-row">
                                                                <td colspan="<%= compareList.size() + 1 %>">
                                                                    🔋 BatteryIQ Signature Health Verification
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Overall Health Grade</td>
                                                                <% for (Vehicle v : compareList) { VehicleHealthReport
                                                                    hr=v.getHealthReport(); %>
                                                                    <td class="feature-val">
                                                                        <% if (hr !=null) { %>
                                                                            <span
                                                                                class="health-pill grade-<%= hr.getOverallGrade().replace("+", "plus").toLowerCase() %>">
                                                                                Grade <%= hr.getOverallGrade() %> (<%=
                                                                                        hr.getOverallScore() %>/100)
                                                                            </span>
                                                                            <% } else { %>
                                                                                <span class="text-muted">Not
                                                                                    Certified</span>
                                                                                <% } %>
                                                                    </td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Diagnostic Telematics</td>
                                                                <% for (Vehicle v : compareList) { VehicleHealthReport
                                                                    hr=v.getHealthReport(); %>
                                                                    <td class="feature-val">
                                                                        <% if (hr !=null) { %>
                                                                            <% if (hr.isEvReport()) { %>
                                                                                <strong>
                                                                                    <%= hr.getSohPercentage() %>% SoH
                                                                                </strong> (Retention)<br>
                                                                                <small class="text-muted">Cell Delta:
                                                                                    <%= hr.getCellDeviationMv() %> mV
                                                                                        &bull; Stress: <%=
                                                                                            hr.getThermalStressGrade()
                                                                                            %></small>
                                                                                <% } else { %>
                                                                                    <strong>
                                                                                        <%= hr.getEngineHealthScore() %>
                                                                                            /100 Engine Score
                                                                                    </strong><br>
                                                                                    <small
                                                                                        class="text-muted">Compression:
                                                                                        <%= hr.getCompressionTestResult()
                                                                                            !=null ? "Tested" : "N/A" %>
                                                                                            &bull; Oil: <%=
                                                                                                hr.getOilConditionGrade()
                                                                                                %></small>
                                                                                    <% } %>
                                                                                        <% } else { %>
                                                                                            -
                                                                                            <% } %>
                                                                    </td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Odometer Verification</td>
                                                                <% for (Vehicle v : compareList) { VehicleHealthReport
                                                                    hr=v.getHealthReport(); %>
                                                                    <td class="feature-val">
                                                                        <% if (hr !=null && hr.getOdometerStatus()
                                                                            !=null) { %>
                                                                            <span
                                                                                class="status-indicator verified">Verified
                                                                                &bull; 0 Tampering</span>
                                                                            <% } else if (v.isNewVehicle()) { %>
                                                                                <span
                                                                                    class="status-indicator verified">Brand
                                                                                    New (0 km)</span>
                                                                                <% } else { %>
                                                                                    <span
                                                                                        class="status-indicator verified">Cluster
                                                                                        Scanned</span>
                                                                                    <% } %>
                                                                    </td>
                                                                    <% } %>
                                                            </tr>

                                                            <!-- Section: Engine, Battery & Range -->
                                                            <tr class="section-row">
                                                                <td colspan="<%= compareList.size() + 1 %>">
                                                                    ⚙️ Powertrain, Performance &amp; Efficiency
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Category</td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val"><strong>
                                                                            <%= v.getCategory() %>
                                                                        </strong> (<%= v.getBodyType() %>)</td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Condition</td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val"><span
                                                                            class="badge-condition <%= v.getConditionType().toLowerCase() %>">
                                                                            <%= v.getConditionType() %>
                                                                        </span></td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Fuel Type</td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val"><strong>
                                                                            <%= v.getFuelType() %>
                                                                        </strong></td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Battery Capacity / Engine CC
                                                                </td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val">
                                                                        <% if (v.isElectric()) { %>
                                                                            ⚡ <%= v.getBatteryPackKwh() %> kWh Battery
                                                                                Pack
                                                                                <% } else { %>
                                                                                    ⚙️ <%= v.getEngineCc() %> cc Engine
                                                                                        <% } %>
                                                                    </td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Range / Fuel Economy</td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val">
                                                                        <% if (v.isElectric()) { %>
                                                                            WLTP: <%= v.getOriginalWltpRangeKm() %>
                                                                                km<br>
                                                                                <small class="text-emerald">Real-World
                                                                                    Tested: <%= v.getHealthReport()
                                                                                        !=null ?
                                                                                        v.getHealthReport().getEstimatedRealRangeKm()
                                                                                        + " km" : "N/A" %></small>
                                                                                <% } else { %>
                                                                                    <%= v.getMileageKmpl()> 0 ?
                                                                                        v.getMileageKmpl() + " km/l" :
                                                                                        "N/A" %>
                                                                                        <% } %>
                                                                    </td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Transmission / Drivetrain</td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val">
                                                                        <%= v.getTransmission() %> &bull; <%=
                                                                                v.getDrivetrain() %>
                                                                    </td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Odometer Reading</td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val">
                                                                        <%= v.getFormattedOdometer() %>
                                                                    </td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Seating Capacity</td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val">
                                                                        <%= v.getSeatingCapacity() %> Person
                                                                    </td>
                                                                    <% } %>
                                                            </tr>
                                                            <tr>
                                                                <td class="feature-label">Location</td>
                                                                <% for (Vehicle v : compareList) { %>
                                                                    <td class="feature-val">
                                                                        <%= v.getLocationCity() %>
                                                                    </td>
                                                                    <% } %>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </main>

                                        <%@ include file="/includes/footer.jsp" %>
                                            <script src="<%= request.getContextPath() %>/js/main.js"></script>
                                </body>

                                </html>