<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.batteryiq.model.Vehicle" %>
        <% Boolean listingSuccess=(Boolean) request.getAttribute("listingSuccess"); Vehicle createdVehicle=(Vehicle)
            request.getAttribute("createdVehicle"); Boolean inspectionBooked=(Boolean)
            request.getAttribute("inspectionBooked"); %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Sell Your Vehicle - BatteryIQ Automotive Marketplace</title>
                <meta name="description"
                    content="Sell your Car, Bike, or Scooter with certified BatteryIQ Health Inspection. Get the highest value with transparent diagnostics.">
                <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
                <link rel="icon"
                    href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>💰</text></svg>">
            </head>

            <body>

                <%@ include file="/includes/header.jsp" %>

                    <main class="page-container">
                        <!-- Hero Banner for Sell Page -->
                        <div class="sell-hero-banner">
                            <div class="container sell-hero-inner">
                                <div class="sell-hero-text">
                                    <span class="hero-tag">Highest Resale Value Guarantee</span>
                                    <h1 class="page-title">Sell Your Car, Bike or Scooter with 100% Trust</h1>
                                    <p class="page-subtitle">
                                        List your vehicle for free and opt for an authentic BatteryIQ Certified Health
                                        Inspection.
                                        Vehicles with verified battery SoH or engine compression reports sell <strong>3x
                                            faster</strong> at an average <strong>18% higher price</strong>!
                                    </p>
                                    <div class="sell-perks">
                                        <div class="perk-item">
                                            <span class="perk-icon">⚡</span>
                                            <span>EV Battery SoH Diagnostics</span>
                                        </div>
                                        <div class="perk-item">
                                            <span class="perk-icon">⚙️</span>
                                            <span>Engine Compression &amp; OBD Scan</span>
                                        </div>
                                        <div class="perk-item">
                                            <span class="perk-icon">🛡️</span>
                                            <span>Doorstep Certified Inspection</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Instant Valuation Estimator Widget -->
                                <div class="estimator-card">
                                    <h3>Instant Valuation Estimator</h3>
                                    <p class="estimator-sub">Estimate your vehicle's expected marketplace value</p>
                                    <div class="estimator-inputs">
                                        <div class="form-group-sm">
                                            <label>Category</label>
                                            <select id="est-category" onchange="calculateValuation()">
                                                <option value="CAR">Car</option>
                                                <option value="BIKE">Bike</option>
                                                <option value="SCOOTER">Scooter</option>
                                            </select>
                                        </div>
                                        <div class="form-group-sm">
                                            <label>Year</label>
                                            <select id="est-year" onchange="calculateValuation()">
                                                <option value="2024">2024 (Brand New)</option>
                                                <option value="2023">2023</option>
                                                <option value="2022" selected>2022</option>
                                                <option value="2021">2021</option>
                                                <option value="2020">2020</option>
                                            </select>
                                        </div>
                                        <div class="form-group-sm">
                                            <label>Odometer (KM)</label>
                                            <input type="number" id="est-km" value="25000" step="5000"
                                                oninput="calculateValuation()">
                                        </div>
                                    </div>

                                    <div class="valuation-result-box">
                                        <span class="val-label">Estimated Resale Range:</span>
                                        <div class="val-number" id="est-range">$28,000 - $34,500</div>
                                        <small class="val-hint">+15% premium with BatteryIQ Grade A+ Health
                                            Certification</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="container sell-form-wrapper">
                            <% if (Boolean.TRUE.equals(listingSuccess) && createdVehicle !=null) { %>
                                <!-- Success State Card -->
                                <div class="sell-success-card">
                                    <div class="success-icon">🎉</div>
                                    <h2>Vehicle Listed Successfully!</h2>
                                    <p>Your listing for <strong>
                                            <%= createdVehicle.getDisplayName() %>
                                        </strong> has been published to the BatteryIQ marketplace.</p>

                                    <% if (Boolean.TRUE.equals(inspectionBooked)) { %>
                                        <div class="booked-inspection-pill">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981"
                                                stroke-width="2.5">
                                                <polyline points="20 6 9 17 4 12"></polyline>
                                            </svg>
                                            <strong>BatteryIQ Doorstep Inspection Scheduled:</strong> Our diagnostic
                                            technician will contact you to conduct the physical scan and issue your
                                            certified digital certificate.
                                        </div>
                                        <% } %>

                                            <div class="success-actions">
                                                <a href="<%= request.getContextPath() %>/vehicle?id=<%= createdVehicle.getVehicleId() %>"
                                                    class="btn btn-primary">
                                                    View Your Listing
                                                </a>
                                                <a href="<%= request.getContextPath() %>/health-report?id=<%= createdVehicle.getVehicleId() %>"
                                                    class="btn btn-secondary">
                                                    View Preliminary Health Certificate
                                                </a>
                                                <a href="<%= request.getContextPath() %>/sell" class="btn btn-outline">
                                                    List Another Vehicle
                                                </a>
                                            </div>
                                </div>
                                <% } else { %>
                                    <!-- Interactive Listing Form -->
                                    <div class="sell-card-main">
                                        <div class="sell-card-header">
                                            <h2>List Your Vehicle for Sale</h2>
                                            <p>Fill out the details below. All listings are clearly marked as
                                                <strong>DEMO DATA</strong> in accordance with demonstration rules.</p>
                                        </div>

                                        <form action="<%= request.getContextPath() %>/sell" method="post"
                                            class="sell-form" id="main-sell-form">
                                            <!-- Step 1: Category & Fuel -->
                                            <div class="form-section">
                                                <h3 class="form-section-title">1. Category, Fuel &amp; Condition</h3>
                                                <div class="form-row-3">
                                                    <div class="form-group">
                                                        <label for="sell-cat">Vehicle Category *</label>
                                                        <select name="category" id="sell-cat" required
                                                            onchange="updateModelSuggestions()">
                                                            <option value="CAR">Car</option>
                                                            <option value="BIKE">Bike</option>
                                                            <option value="SCOOTER">Scooter</option>
                                                        </select>
                                                    </div>

                                                    <div class="form-group">
                                                        <label for="sell-fuel">Fuel Type *</label>
                                                        <select name="fuelType" id="sell-fuel" required>
                                                            <option value="ELECTRIC">Electric (EV)</option>
                                                            <option value="PETROL">Petrol</option>
                                                            <option value="DIESEL">Diesel</option>
                                                        </select>
                                                    </div>

                                                    <div class="form-group">
                                                        <label for="sell-cond">Condition *</label>
                                                        <select name="conditionType" id="sell-cond" required>
                                                            <option value="USED">Used / Pre-Owned</option>
                                                            <option value="NEW">Brand New (Unregistered)</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Step 2: Make, Model & Year -->
                                            <div class="form-section">
                                                <h3 class="form-section-title">2. Vehicle Information</h3>
                                                <div class="form-row-3">
                                                    <div class="form-group">
                                                        <label for="sell-make">Brand / Manufacturer *</label>
                                                        <input type="text" name="make" id="sell-make" required
                                                            placeholder="e.g. Tesla, Honda, BMW, Ola">
                                                    </div>

                                                    <div class="form-group">
                                                        <label for="sell-model">Model Name *</label>
                                                        <input type="text" name="model" id="sell-model" required
                                                            placeholder="e.g. Model 3, Civic, Hunter 350, S1 Pro">
                                                    </div>

                                                    <div class="form-group">
                                                        <label for="sell-trim">Variant / Trim (Optional)</label>
                                                        <input type="text" name="variantTrim" id="sell-trim"
                                                            placeholder="e.g. Long Range AWD, M Sport, Deluxe">
                                                    </div>
                                                </div>

                                                <div class="form-row-3">
                                                    <div class="form-group">
                                                        <label for="sell-year">Manufacturing Year *</label>
                                                        <select name="manufacturingYear" id="sell-year" required>
                                                            <option value="2024">2024</option>
                                                            <option value="2023">2023</option>
                                                            <option value="2022" selected>2022</option>
                                                            <option value="2021">2021</option>
                                                            <option value="2020">2020</option>
                                                            <option value="2019">2019</option>
                                                        </select>
                                                    </div>

                                                    <div class="form-group">
                                                        <label for="sell-odo">Odometer Reading (KM) *</label>
                                                        <input type="number" name="odometerKm" id="sell-odo" required
                                                            value="20000" min="0">
                                                    </div>

                                                    <div class="form-group">
                                                        <label for="sell-price">Asking Price ($) *</label>
                                                        <input type="number" name="price" id="sell-price" required
                                                            value="28000" min="500">
                                                    </div>
                                                </div>

                                                <div class="form-row-2">
                                                    <div class="form-group">
                                                        <label for="sell-city">Vehicle Location (City, State) *</label>
                                                        <input type="text" name="locationCity" id="sell-city" required
                                                            placeholder="e.g. San Francisco, CA">
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Step 3: BatteryIQ Health Verification Opt-In (The Differentiating Feature) -->
                                            <div class="form-section inspection-optin-section">
                                                <h3 class="form-section-title">3. BatteryIQ Health Verification</h3>
                                                <div class="inspection-optin-box">
                                                    <label class="checkbox-container">
                                                        <input type="checkbox" name="requestInspection"
                                                            id="request-inspection-cb" checked>
                                                        <span class="custom-checkbox"></span>
                                                        <div class="checkbox-text">
                                                            <strong>Schedule a Doorstep BatteryIQ Certified Diagnostic
                                                                Inspection (Recommended)</strong>
                                                            <p>
                                                                Our certified technician will scan battery SoH, cell
                                                                balance (for EVs), or perform cylinder compression and
                                                                OBD-II scans (for Petrol/Diesel).
                                                                A verified certificate is published to your listing,
                                                                eliminating buyer doubts.
                                                            </p>
                                                        </div>
                                                    </label>
                                                </div>
                                            </div>

                                            <!-- Step 4: Seller Contact Details -->
                                            <div class="form-section">
                                                <h3 class="form-section-title">4. Seller Details</h3>
                                                <div class="form-row-2">
                                                    <div class="form-group">
                                                        <label for="seller-name">Your Full Name *</label>
                                                        <input type="text" name="sellerName" id="seller-name" required
                                                            placeholder="e.g. Alex Morgan">
                                                    </div>

                                                    <div class="form-group">
                                                        <label for="seller-phone">Mobile Phone *</label>
                                                        <input type="tel" name="sellerPhone" id="seller-phone" required
                                                            placeholder="+1 555-019-3321">
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="form-submit-row">
                                                <button type="submit" class="btn btn-primary btn-lg">
                                                    Post Vehicle for Sale &rarr;
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                    <% } %>
                        </div>
                    </main>

                    <%@ include file="/includes/footer.jsp" %>
                        <script src="<%= request.getContextPath() %>/js/main.js"></script>
                        <script>
                            function calculateValuation() {
                                const cat = document.getElementById('est-category').value;
                                const year = parseInt(document.getElementById('est-year').value);
                                const km = parseInt(document.getElementById('est-km').value) || 20000;
                                const rangeEl = document.getElementById('est-range');

                                let base = 35000;
                                if (cat === 'BIKE') base = 6000;
                                if (cat === 'SCOOTER') base = 2500;

                                const ageDiff = (2024 - year) * 0.10;
                                const kmDiff = (km / 10000) * 0.03;
                                const factor = Math.max(0.4, 1 - ageDiff - kmDiff);

                                const low = Math.round(base * factor * 0.9);
                                const high = Math.round(base * factor * 1.15);

                                rangeEl.innerText = '$' + low.toLocaleString() + ' - $' + high.toLocaleString();
                            }
                        </script>
            </body>

            </html>