<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.batteryiq.model.Vehicle" %>
            <%@ page import="com.batteryiq.dao.VehicleDAO" %>
                <% // Ensure featured vehicles are available even if accessed directly via index.jsp instead of servlet
                    List<Vehicle> featuredVehicles = (List<Vehicle>) request.getAttribute("featuredVehicles");
                        if (featuredVehicles == null || featuredVehicles.isEmpty()) {
                        VehicleDAO vDao = new VehicleDAO();
                        featuredVehicles = vDao.getFeaturedVehicles();
                        }
                        List<Vehicle> popularCars = (List<Vehicle>) request.getAttribute("popularCars");
                                if (popularCars == null) {
                                popularCars = new VehicleDAO().getVehicles("CAR", null, null, null, null, null, null,
                                null);
                                }
                                List<Vehicle> popularBikes = (List<Vehicle>) request.getAttribute("popularBikes");
                                        if (popularBikes == null) {
                                        popularBikes = new VehicleDAO().getVehicles("BIKE", null, null, null, null,
                                        null, null, null);
                                        }
                                        List<Vehicle> popularScooters = (List<Vehicle>)
                                                request.getAttribute("popularScooters");
                                                if (popularScooters == null) {
                                                popularScooters = new VehicleDAO().getVehicles("SCOOTER", null, null,
                                                null, null, null, null, null);
                                                }
                                                %>
                                                <!DOCTYPE html>
                                                <html lang="en">

                                                <head>
                                                    <meta charset="UTF-8">
                                                    <meta name="viewport"
                                                        content="width=device-width, initial-scale=1.0">
                                                    <title>BatteryIQ - Complete Automotive Marketplace &amp; Vehicle
                                                        Health Reports</title>
                                                    <meta name="description"
                                                        content="Discover Cars, Bikes, and Scooters across Petrol, Diesel, and Electric. Certified with BatteryIQ Vehicle Health Reports and verified inspection diagnostics.">

                                                    <!-- Stylesheets -->
                                                    <link rel="stylesheet"
                                                        href="<%= request.getContextPath() %>/css/style.css">

                                                    <!-- Favicon -->
                                                    <link rel="icon"
                                                        href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🚗</text></svg>">
                                                </head>

                                                <body>

                                                    <!-- Include Header -->
                                                    <%@ include file="/includes/header.jsp" %>

                                                        <!-- Hero Section with CarDekho-style Search Widget -->
                                                        <main>
                                                            <section class="hero-section" id="hero">
                                                                <div class="container">
                                                                    <div class="hero-grid">
                                                                        <div class="hero-content">
                                                                            <div class="hero-tag">
                                                                                <span class="hero-tag-pulse"></span>
                                                                                Next-Gen Automotive Marketplace
                                                                            </div>
                                                                            <h1 class="hero-title">
                                                                                Find Your Right Vehicle with <span
                                                                                    class="highlight">Verified Health
                                                                                    Trust</span>
                                                                            </h1>
                                                                            <p class="hero-subtitle">
                                                                                Browse verified Cars, Bikes, and
                                                                                Scooters across Petrol, Diesel, and
                                                                                Electric.
                                                                                Every vehicle backed by transparent
                                                                                Battery State of Health (SoH) or Engine
                                                                                Diagnostics.
                                                                            </p>

                                                                            <!-- Quick Category Pills -->
                                                                            <div class="category-pills-row">
                                                                                <a href="<%= request.getContextPath() %>/cars"
                                                                                    class="category-pill active">
                                                                                    <span class="pill-icon">🚗</span>
                                                                                    Cars
                                                                                </a>
                                                                                <a href="<%= request.getContextPath() %>/bikes"
                                                                                    class="category-pill">
                                                                                    <span class="pill-icon">🏍️</span>
                                                                                    Bikes
                                                                                </a>
                                                                                <a href="<%= request.getContextPath() %>/scooters"
                                                                                    class="category-pill">
                                                                                    <span class="pill-icon">🛵</span>
                                                                                    Scooters
                                                                                </a>
                                                                                <a href="<%= request.getContextPath() %>/vehicles?fuel=ELECTRIC"
                                                                                    class="category-pill ev-pill">
                                                                                    <span class="pill-icon">⚡</span>
                                                                                    Electric
                                                                                </a>
                                                                                <a href="<%= request.getContextPath() %>/new-vehicles"
                                                                                    class="category-pill">
                                                                                    <span class="pill-icon">✨</span> New
                                                                                </a>
                                                                                <a href="<%= request.getContextPath() %>/used-vehicles"
                                                                                    class="category-pill">
                                                                                    <span class="pill-icon">🔍</span>
                                                                                    Used
                                                                                </a>
                                                                            </div>

                                                                            <!-- Marketplace Search Box (CarDekho-Inspired Multi-Tab Filter) -->
                                                                            <div class="search-box-card">
                                                                                <div class="search-box-tabs"
                                                                                    role="tablist">
                                                                                    <button class="s-tab active"
                                                                                        data-condition="all"
                                                                                        type="button">All
                                                                                        Vehicles</button>
                                                                                    <button class="s-tab"
                                                                                        data-condition="NEW"
                                                                                        type="button">Brand New</button>
                                                                                    <button class="s-tab"
                                                                                        data-condition="USED"
                                                                                        type="button">Certified
                                                                                        Used</button>
                                                                                </div>

                                                                                <form
                                                                                    action="<%= request.getContextPath() %>/vehicles"
                                                                                    method="get"
                                                                                    class="search-form-grid">
                                                                                    <input type="hidden"
                                                                                        name="condition"
                                                                                        id="hidden-condition"
                                                                                        value="all">

                                                                                    <div class="form-group">
                                                                                        <label
                                                                                            for="home-category">Category</label>
                                                                                        <select name="category"
                                                                                            id="home-category">
                                                                                            <option value="all">All
                                                                                                Categories (Cars, Bikes,
                                                                                                Scooters)</option>
                                                                                            <option value="CAR">Cars
                                                                                            </option>
                                                                                            <option value="BIKE">Bikes
                                                                                            </option>
                                                                                            <option value="SCOOTER">
                                                                                                Scooters</option>
                                                                                        </select>
                                                                                    </div>

                                                                                    <div class="form-group">
                                                                                        <label for="home-fuel">Fuel
                                                                                            Type</label>
                                                                                        <select name="fuel"
                                                                                            id="home-fuel">
                                                                                            <option value="all">All Fuel
                                                                                                Types</option>
                                                                                            <option value="ELECTRIC">
                                                                                                Electric (EV)</option>
                                                                                            <option value="PETROL">
                                                                                                Petrol</option>
                                                                                            <option value="DIESEL">
                                                                                                Diesel</option>
                                                                                        </select>
                                                                                    </div>

                                                                                    <div class="form-group">
                                                                                        <label
                                                                                            for="home-brand">Brand</label>
                                                                                        <select name="brand"
                                                                                            id="home-brand">
                                                                                            <option value="all">All
                                                                                                Brands</option>
                                                                                            <option value="Tesla">Tesla
                                                                                            </option>
                                                                                            <option value="BMW">BMW
                                                                                            </option>
                                                                                            <option value="Audi">Audi
                                                                                            </option>
                                                                                            <option value="Porsche">
                                                                                                Porsche</option>
                                                                                            <option value="Honda">Honda
                                                                                            </option>
                                                                                            <option value="Yamaha">
                                                                                                Yamaha</option>
                                                                                            <option
                                                                                                value="Royal Enfield">
                                                                                                Royal Enfield</option>
                                                                                            <option value="Ola">Ola
                                                                                            </option>
                                                                                            <option value="Gogoro">
                                                                                                Gogoro</option>
                                                                                            <option value="Vespa">Vespa
                                                                                            </option>
                                                                                        </select>
                                                                                    </div>

                                                                                    <div class="form-group">
                                                                                        <label for="home-budget">Max
                                                                                            Budget</label>
                                                                                        <select name="budget"
                                                                                            id="home-budget">
                                                                                            <option value="all">Any
                                                                                                Budget</option>
                                                                                            <option value="5000">Under
                                                                                                $5,000 (Bikes &amp;
                                                                                                Scooters)</option>
                                                                                            <option value="15000">Under
                                                                                                $15,000</option>
                                                                                            <option value="30000">Under
                                                                                                $30,000</option>
                                                                                            <option value="50000">Under
                                                                                                $50,000</option>
                                                                                            <option value="80000">Under
                                                                                                $80,000</option>
                                                                                        </select>
                                                                                    </div>

                                                                                    <div
                                                                                        class="form-group submit-group">
                                                                                        <button type="submit"
                                                                                            class="btn btn-primary btn-search-submit">
                                                                                            <svg width="18" height="18"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <circle cx="11" cy="11"
                                                                                                    r="8"></circle>
                                                                                                <line x1="21" y1="21"
                                                                                                    x2="16.65"
                                                                                                    y2="16.65"></line>
                                                                                            </svg>
                                                                                            Search
                                                                                        </button>
                                                                                    </div>
                                                                                </form>
                                                                            </div>
                                                                        </div>

                                                                        <!-- Hero Visual Showcase -->
                                                                        <div class="hero-visual">
                                                                            <div class="hero-image-card">
                                                                                <img src="https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=80"
                                                                                    alt="BatteryIQ Certified Vehicle">
                                                                                <div class="hero-health-overlay">
                                                                                    <div class="health-gauge">
                                                                                        <div class="gauge-value">97.4%
                                                                                        </div>
                                                                                        <div class="gauge-label">Battery
                                                                                            SoH</div>
                                                                                    </div>
                                                                                    <div class="health-meta">
                                                                                        <div
                                                                                            class="health-status-badge verified">
                                                                                            <svg width="14" height="14"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <polyline
                                                                                                    points="20 6 9 17 4 12">
                                                                                                </polyline>
                                                                                            </svg>
                                                                                            Verified Diagnostic
                                                                                        </div>
                                                                                        <div class="health-title">Cell
                                                                                            Voltage Delta: 9 mV</div>
                                                                                        <div class="health-subtitle">
                                                                                            Real-World Range: 565 km
                                                                                            &bull; Grade A+</div>
                                                                                    </div>
                                                                                </div>
                                                                            </div>

                                                                            <!-- Stats Row Below Visual -->
                                                                            <div class="hero-stat-pills">
                                                                                <div class="stat-box">
                                                                                    <div class="stat-number">3,850+
                                                                                    </div>
                                                                                    <div class="stat-label">Verified
                                                                                        Listings</div>
                                                                                </div>
                                                                                <div class="stat-box">
                                                                                    <div class="stat-number">100%</div>
                                                                                    <div class="stat-label">Health
                                                                                        Transparent</div>
                                                                                </div>
                                                                                <div class="stat-box">
                                                                                    <div class="stat-number">3
                                                                                        Categories</div>
                                                                                    <div class="stat-label">Cars, Bikes,
                                                                                        Scooters</div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </section>

                                                            <!-- Categories Section -->
                                                            <section class="section categories-section">
                                                                <div class="container">
                                                                    <div class="section-header">
                                                                        <div>
                                                                            <span class="section-tag">Explore Vehicle
                                                                                Categories</span>
                                                                            <h2 class="section-title">Find By Vehicle
                                                                                Type</h2>
                                                                        </div>
                                                                        <a href="<%= request.getContextPath() %>/vehicles"
                                                                            class="view-all-link">Browse All Inventory
                                                                            &rarr;</a>
                                                                    </div>

                                                                    <div class="category-grid">
                                                                        <a href="<%= request.getContextPath() %>/cars"
                                                                            class="category-card">
                                                                            <div class="cat-img-wrap">
                                                                                <img src="https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=600&q=80"
                                                                                    alt="Cars">
                                                                                <span class="cat-badge">Cars</span>
                                                                            </div>
                                                                            <div class="cat-content">
                                                                                <h3>Cars</h3>
                                                                                <p>Sedans, SUVs, Hatchbacks &bull;
                                                                                    Electric, Petrol &amp; Diesel</p>
                                                                                <span class="cat-explore-btn">Explore
                                                                                    Cars &rarr;</span>
                                                                            </div>
                                                                        </a>

                                                                        <a href="<%= request.getContextPath() %>/bikes"
                                                                            class="category-card">
                                                                            <div class="cat-img-wrap">
                                                                                <img src="https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80"
                                                                                    alt="Bikes">
                                                                                <span class="cat-badge">Bikes</span>
                                                                            </div>
                                                                            <div class="cat-content">
                                                                                <h3>Bikes</h3>
                                                                                <p>Sport, Cruisers &amp; Electric
                                                                                    Streetfighters &bull; Chain &amp;
                                                                                    Belt drive</p>
                                                                                <span class="cat-explore-btn">Explore
                                                                                    Bikes &rarr;</span>
                                                                            </div>
                                                                        </a>

                                                                        <a href="<%= request.getContextPath() %>/scooters"
                                                                            class="category-card">
                                                                            <div class="cat-img-wrap">
                                                                                <img src="https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=600&q=80"
                                                                                    alt="Scooters">
                                                                                <span class="cat-badge">Scooters</span>
                                                                            </div>
                                                                            <div class="cat-content">
                                                                                <h3>Scooters</h3>
                                                                                <p>Smartscooters &amp; Petrol Commuters
                                                                                    &bull; Swappable batteries &amp; CVT
                                                                                </p>
                                                                                <span class="cat-explore-btn">Explore
                                                                                    Scooters &rarr;</span>
                                                                            </div>
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </section>

                                                            <!-- Signature Differentiator: BatteryIQ Vehicle Health Reports Spotlight -->
                                                            <section class="section health-feature-spotlight">
                                                                <div class="container">
                                                                    <div class="spotlight-box">
                                                                        <div class="spotlight-content">
                                                                            <span class="spotlight-badge">BatteryIQ
                                                                                Exclusive Differentiating
                                                                                Technology</span>
                                                                            <h2>Never Buy a Blind Spot. Know the Exact
                                                                                Vehicle Health.</h2>
                                                                            <p>
                                                                                Unlike traditional automotive platforms
                                                                                that only list mileage and photos,
                                                                                BatteryIQ is built on verifiable
                                                                                technical health. We provide separate
                                                                                diagnostic telemetry tailored to each
                                                                                fuel and vehicle type:
                                                                            </p>

                                                                            <div class="spotlight-comparisons">
                                                                                <div class="spotlight-item ev-spot">
                                                                                    <div class="spotlight-item-header">
                                                                                        <span
                                                                                            class="spotlight-icon">⚡</span>
                                                                                        <h4>For Electric Vehicles (Cars,
                                                                                            Bikes, Scooters)</h4>
                                                                                    </div>
                                                                                    <ul>
                                                                                        <li><strong>Battery State of
                                                                                                Health (SoH %):</strong>
                                                                                            True electrochemical
                                                                                            retention vs factory
                                                                                            capacity.</li>
                                                                                        <li><strong>Degradation
                                                                                                Rate:</strong>
                                                                                            Year-over-year battery wear
                                                                                            &amp; life expectancy.</li>
                                                                                        <li><strong>Real-World
                                                                                                Range:</strong> Lab
                                                                                            tested range vs certified
                                                                                            marketing WLTP.</li>
                                                                                        <li><strong>BMS Telematics &amp;
                                                                                                Warnings:</strong>
                                                                                            Abnormal cell voltage delta
                                                                                            &amp; thermal stress.</li>
                                                                                        <li><strong>Evidence
                                                                                                Transparency:</strong>
                                                                                            Clearly distinguishes
                                                                                            verified tests from missing
                                                                                            logs.</li>
                                                                                    </ul>
                                                                                </div>

                                                                                <div class="spotlight-item ice-spot">
                                                                                    <div class="spotlight-item-header">
                                                                                        <span
                                                                                            class="spotlight-icon">⛽</span>
                                                                                        <h4>For Petrol &amp; Diesel
                                                                                            Vehicles</h4>
                                                                                    </div>
                                                                                    <ul>
                                                                                        <li><strong>Engine Inspection
                                                                                                Score:</strong> Cylinder
                                                                                            compression tests &amp; oil
                                                                                            condition.</li>
                                                                                        <li><strong>Odometer
                                                                                                Verification:</strong>
                                                                                            Cluster check against ECU
                                                                                            engine runtime &amp; tamper
                                                                                            check.</li>
                                                                                        <li><strong>Service History
                                                                                                Audit:</strong> Verified
                                                                                            authorized dealer records vs
                                                                                            unverified claims.</li>
                                                                                        <li><strong>Diagnostic Trouble
                                                                                                Codes:</strong> Active,
                                                                                            pending, or historic OBD-II
                                                                                            fault codes.</li>
                                                                                        <li><strong>Two-Wheeler
                                                                                                Checks:</strong> Clutch
                                                                                            lever free play, CVT belt
                                                                                            wear, and drive chain slack.
                                                                                        </li>
                                                                                    </ul>
                                                                                </div>
                                                                            </div>

                                                                            <div class="spotlight-actions">
                                                                                <a href="<%= request.getContextPath() %>/health-report"
                                                                                    class="btn btn-primary">
                                                                                    View Interactive Health Report Demo
                                                                                </a>
                                                                                <a href="<%= request.getContextPath() %>/sell"
                                                                                    class="btn btn-secondary">
                                                                                    Book Health Inspection for Your
                                                                                    Vehicle
                                                                                </a>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </section>

                                                            <!-- Featured Vehicles Showcase (Cars, Bikes, Scooters across Petrol, Diesel, Electric) -->
                                                            <section class="section featured-inventory-section"
                                                                id="featured-inventory">
                                                                <div class="container">
                                                                    <div class="section-header">
                                                                        <div>
                                                                            <span class="section-tag">Hand-Picked
                                                                                Listings</span>
                                                                            <h2 class="section-title">Featured Certified
                                                                                Vehicles</h2>
                                                                            <p class="section-desc">Each vehicle
                                                                                features a BatteryIQ Health Grade and
                                                                                transparent inspection telemetry.</p>
                                                                        </div>

                                                                        <!-- Category Filter Tabs -->
                                                                        <div class="inventory-tabs">
                                                                            <button class="inv-tab active"
                                                                                data-filter="all">All</button>
                                                                            <button class="inv-tab"
                                                                                data-filter="CAR">Cars</button>
                                                                            <button class="inv-tab"
                                                                                data-filter="BIKE">Bikes</button>
                                                                            <button class="inv-tab"
                                                                                data-filter="SCOOTER">Scooters</button>
                                                                            <button class="inv-tab"
                                                                                data-filter="ELECTRIC">EVs</button>
                                                                        </div>
                                                                    </div>

                                                                    <div class="vehicle-cards-grid">
                                                                        <% for (Vehicle v : featuredVehicles) { %>
                                                                            <div class="vehicle-card"
                                                                                data-category="<%= v.getCategory() %>"
                                                                                data-fuel="<%= v.getFuelType() %>"
                                                                                data-condition="<%= v.getConditionType() %>">
                                                                                <div class="card-media">
                                                                                    <img src="<%= v.getThumbnailUrl() %>"
                                                                                        alt="<%= v.getDisplayName() %>"
                                                                                        loading="lazy">
                                                                                    <div class="card-badges">
                                                                                        <span
                                                                                            class="badge-condition <%= v.getConditionType().toLowerCase() %>">
                                                                                            <%= v.getConditionType() %>
                                                                                        </span>
                                                                                        <span
                                                                                            class="badge-fuel <%= v.getFuelType().toLowerCase() %>">
                                                                                            <% if
                                                                                                ("ELECTRIC".equalsIgnoreCase(v.getFuelType()))
                                                                                                { %>⚡ EV<% } else if
                                                                                                    ("DIESEL".equalsIgnoreCase(v.getFuelType()))
                                                                                                    { %>⛽ Diesel<% }
                                                                                                        else { %>⛽
                                                                                                        Petrol<% } %>
                                                                                        </span>
                                                                                    </div>

                                                                                    <!-- Signature Health Grade Badge -->
                                                                                    <% if (v.getHealthReport() !=null) {
                                                                                        %>
                                                                                        <div class="health-grade-badge grade-<%= v.getHealthReport().getOverallGrade().replace("+", "plus").toLowerCase() %>">
                                                                                            <div class="grade-symbol">
                                                                                                <%= v.getHealthReport().getOverallGrade()
                                                                                                    %>
                                                                                            </div>
                                                                                            <div class="grade-text">
                                                                                                <% if (v.isElectric()) {
                                                                                                    %>
                                                                                                    <%= v.getHealthReport().getSohPercentage()
                                                                                                        %>% SoH
                                                                                                        <% } else { %>
                                                                                                            <%= v.getHealthReport().getEngineHealthScore()
                                                                                                                %>/100
                                                                                                                Engine
                                                                                                                <% } %>
                                                                                            </div>
                                                                                        </div>
                                                                                        <% } %>
                                                                                </div>

                                                                                <div class="card-body">
                                                                                    <div class="card-category-tag">
                                                                                        <%= v.getCategory() %> &bull;
                                                                                            <%= v.getBodyType() %>
                                                                                    </div>
                                                                                    <h3 class="card-title">
                                                                                        <a
                                                                                            href="<%= request.getContextPath() %>/vehicle?id=<%= v.getVehicleId() %>">
                                                                                            <%= v.getDisplayName() %>
                                                                                        </a>
                                                                                    </h3>
                                                                                    <div class="card-variant">
                                                                                        <%= v.getVariantTrim() %>
                                                                                    </div>

                                                                                    <div class="card-specs-row">
                                                                                        <div class="spec-chip">
                                                                                            <svg width="13" height="13"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2">
                                                                                                <circle cx="12" cy="12"
                                                                                                    r="10"></circle>
                                                                                                <polyline
                                                                                                    points="12 6 12 12 16 14">
                                                                                                </polyline>
                                                                                            </svg>
                                                                                            <%= v.getFormattedOdometer()
                                                                                                %>
                                                                                        </div>
                                                                                        <div class="spec-chip">
                                                                                            <% if (v.isElectric()) { %>
                                                                                                ⚡ <%=
                                                                                                    v.getBatteryPackKwh()
                                                                                                    %> kWh Pack
                                                                                                    <% } else { %>
                                                                                                        ⚙️ <%=
                                                                                                            v.getEngineCc()
                                                                                                            %> cc Engine
                                                                                                            <% } %>
                                                                                        </div>
                                                                                        <div class="spec-chip">
                                                                                            📍 <%= v.getLocationCity()
                                                                                                %>
                                                                                        </div>
                                                                                    </div>

                                                                                    <div class="card-price-row">
                                                                                        <div class="price-block">
                                                                                            <div class="price-val">
                                                                                                <%= v.getFormattedPrice()
                                                                                                    %>
                                                                                            </div>
                                                                                            <div class="price-emi">Est.
                                                                                                <%= v.getEstimatedEmi()
                                                                                                    %>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="card-actions-block">
                                                                                            <a href="<%= request.getContextPath() %>/health-report?id=<%= v.getVehicleId() %>"
                                                                                                class="btn btn-outline-health"
                                                                                                title="View Full Health Report">
                                                                                                Health Report
                                                                                            </a>
                                                                                            <a href="<%= request.getContextPath() %>/vehicle?id=<%= v.getVehicleId() %>"
                                                                                                class="btn btn-primary btn-sm">
                                                                                                View Details
                                                                                            </a>
                                                                                        </div>
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                            <% } %>
                                                                    </div>

                                                                    <div class="section-footer-cta">
                                                                        <a href="<%= request.getContextPath() %>/vehicles"
                                                                            class="btn btn-secondary btn-lg">
                                                                            Explore All <%= featuredVehicles.size() %>+
                                                                                Vehicles in Stock &rarr;
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </section>

                                                            <!-- Brand Showcase -->
                                                            <section class="section brands-section">
                                                                <div class="container">
                                                                    <div class="section-header text-center">
                                                                        <span class="section-tag">Trusted
                                                                            Manufacturers</span>
                                                                        <h2 class="section-title">Popular Automotive
                                                                            Brands</h2>
                                                                        <p class="section-desc">Explore verified
                                                                            listings from leading manufacturers across
                                                                            Cars, Bikes, and Scooters.</p>
                                                                    </div>

                                                                    <div class="brands-grid">
                                                                        <a href="<%= request.getContextPath() %>/vehicles?brand=Tesla"
                                                                            class="brand-item">
                                                                            <div class="brand-badge-letter">T</div>
                                                                            <div class="brand-name">Tesla</div>
                                                                            <div class="brand-meta">Electric Cars</div>
                                                                        </a>
                                                                        <a href="<%= request.getContextPath() %>/vehicles?brand=BMW"
                                                                            class="brand-item">
                                                                            <div class="brand-badge-letter">B</div>
                                                                            <div class="brand-name">BMW</div>
                                                                            <div class="brand-meta">Petrol &amp;
                                                                                Electric</div>
                                                                        </a>
                                                                        <a href="<%= request.getContextPath() %>/vehicles?brand=Porsche"
                                                                            class="brand-item">
                                                                            <div class="brand-badge-letter">P</div>
                                                                            <div class="brand-name">Porsche</div>
                                                                            <div class="brand-meta">Sports Cars &amp;
                                                                                EVs</div>
                                                                        </a>
                                                                        <a href="<%= request.getContextPath() %>/vehicles?brand=Audi"
                                                                            class="brand-item">
                                                                            <div class="brand-badge-letter">A</div>
                                                                            <div class="brand-name">Audi</div>
                                                                            <div class="brand-meta">Diesel &amp; EVs
                                                                            </div>
                                                                        </a>
                                                                        <a href="<%= request.getContextPath() %>/vehicles?brand=Honda"
                                                                            class="brand-item">
                                                                            <div class="brand-badge-letter">H</div>
                                                                            <div class="brand-name">Honda</div>
                                                                            <div class="brand-meta">Cars &amp; Scooters
                                                                            </div>
                                                                        </a>
                                                                        <a href="<%= request.getContextPath() %>/vehicles?brand=Zero"
                                                                            class="brand-item">
                                                                            <div class="brand-badge-letter">Z</div>
                                                                            <div class="brand-name">Zero</div>
                                                                            <div class="brand-meta">Electric Bikes</div>
                                                                        </a>
                                                                        <a href="<%= request.getContextPath() %>/vehicles?brand=Royal+Enfield"
                                                                            class="brand-item">
                                                                            <div class="brand-badge-letter">RE</div>
                                                                            <div class="brand-name">Royal Enfield</div>
                                                                            <div class="brand-meta">Cruiser Bikes</div>
                                                                        </a>
                                                                        <a href="<%= request.getContextPath() %>/vehicles?brand=Ola"
                                                                            class="brand-item">
                                                                            <div class="brand-badge-letter">O</div>
                                                                            <div class="brand-name">Ola</div>
                                                                            <div class="brand-meta">Electric Scooters
                                                                            </div>
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </section>

                                                            <!-- Quick Comparison & Sell CTA Banner -->
                                                            <section class="section action-banner-section">
                                                                <div class="container">
                                                                    <div class="action-banners-grid">
                                                                        <div class="action-banner-card compare-card">
                                                                            <div class="action-banner-content">
                                                                                <span class="mini-tag">Side-by-Side
                                                                                    Analysis</span>
                                                                                <h3>Confused Between Two Vehicles?</h3>
                                                                                <p>Compare Cars, Bikes, or Scooters
                                                                                    side-by-side. See specs, real-world
                                                                                    fuel economy or range, and health
                                                                                    scores.</p>
                                                                                <a href="<%= request.getContextPath() %>/compare"
                                                                                    class="btn btn-outline-white">Compare
                                                                                    Now &rarr;</a>
                                                                            </div>
                                                                        </div>

                                                                        <div class="action-banner-card sell-card">
                                                                            <div class="action-banner-content">
                                                                                <span class="mini-tag">Sell With 100%
                                                                                    Trust</span>
                                                                                <h3>Want to Sell Your Car, Bike or
                                                                                    Scooter?</h3>
                                                                                <p>Get an instant valuation estimate and
                                                                                    book a certified BatteryIQ Health
                                                                                    Inspection for a faster,
                                                                                    higher-value sale.</p>
                                                                                <a href="<%= request.getContextPath() %>/sell"
                                                                                    class="btn btn-primary">Sell Your
                                                                                    Vehicle &rarr;</a>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </section>
                                                        </main>

                                                        <!-- Include Footer -->
                                                        <%@ include file="/includes/footer.jsp" %>

                                                            <!-- JavaScript -->
                                                            <script
                                                                src="<%= request.getContextPath() %>/js/main.js"></script>
                                                </body>

                                                </html>