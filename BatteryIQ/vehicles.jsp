<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.batteryiq.model.Vehicle" %>
            <% List<Vehicle> vehicles = (List<Vehicle>) request.getAttribute("vehicles");
                    int resultCount = request.getAttribute("resultCount") != null ? (Integer)
                    request.getAttribute("resultCount") : 0;
                    String selectedCategory = (String) request.getAttribute("selectedCategory");
                    String selectedFuel = (String) request.getAttribute("selectedFuel");
                    String selectedCondition = (String) request.getAttribute("selectedCondition");
                    String selectedBrand = (String) request.getAttribute("selectedBrand");
                    String selectedBudget = (String) request.getAttribute("selectedBudget");
                    String selectedLocation = (String) request.getAttribute("selectedLocation");
                    String searchQuery = (String) request.getAttribute("searchQuery");
                    String selectedSort = (String) request.getAttribute("selectedSort");
                    String pageTitle = (String) request.getAttribute("pageTitle");
                    String pageSubtitle = (String) request.getAttribute("pageSubtitle");

                    if (pageTitle == null) pageTitle = "Search & Filter Vehicles";
                    if (pageSubtitle == null) pageSubtitle = "Explore verified vehicles across Cars, Bikes, and Scooters.";
                    %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>
                            <%= pageTitle %> - BatteryIQ Marketplace
                        </title>
                        <meta name="description"
                            content="Search and filter Cars, Bikes, and Scooters by brand, budget, fuel type, and health certification on BatteryIQ.">
                        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
                        <link rel="icon"
                            href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🚗</text></svg>">
                    </head>

                    <body>

                        <%@ include file="/includes/header.jsp" %>

                            <main class="page-container">
                                <!-- Page Title & Breadcrumbs -->
                                <div class="page-header-bar">
                                    <div class="container">
                                        <nav class="breadcrumb-nav" aria-label="Breadcrumb">
                                            <a href="<%= request.getContextPath() %>/">Home</a>
                                            <span class="sep">&rsaquo;</span>
                                            <a href="<%= request.getContextPath() %>/vehicles">Marketplace</a>
                                            <% if (selectedCategory !=null && !"all".equalsIgnoreCase(selectedCategory))
                                                { %>
                                                <span class="sep">&rsaquo;</span>
                                                <span class="current">
                                                    <%= selectedCategory %>
                                                </span>
                                                <% } %>
                                        </nav>
                                        <div class="page-title-row">
                                            <div>
                                                <h1 class="page-title">
                                                    <%= pageTitle %>
                                                </h1>
                                                <p class="page-subtitle">
                                                    <%= pageSubtitle %>
                                                </p>
                                            </div>
                                            <div class="results-badge-wrap">
                                                <span class="results-badge"><strong>
                                                        <%= resultCount %>
                                                    </strong> vehicles available</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Filter & Listings Main Layout -->
                                <div class="container inventory-layout">
                                    <!-- Sidebar Filters -->
                                    <aside class="filters-sidebar" aria-label="Search and filter controls">
                                        <div class="filter-card">
                                            <div class="filter-card-header">
                                                <h3>Filters</h3>
                                                <a href="<%= request.getContextPath() %>/vehicles"
                                                    class="reset-filter-btn">Reset All</a>
                                            </div>

                                            <form action="<%= request.getContextPath() %>/vehicles" method="get"
                                                id="filter-form">
                                                <!-- Keyword Search in Filter -->
                                                <div class="filter-group">
                                                    <label class="filter-label" for="sidebar-q">Search Model /
                                                        Keyword</label>
                                                    <input type="text" name="q" id="sidebar-q" class="filter-input"
                                                        placeholder="e.g. Model 3, Taycan, Hunter..."
                                                        value="<%= searchQuery != null ? searchQuery : "" %>">
                                                </div>

                                                <!-- Vehicle Category (Cars, Bikes, Scooters) -->
                                                <div class="filter-group">
                                                    <label class="filter-label">Vehicle Category</label>
                                                    <div class="filter-radio-pills">
                                                        <label class="radio-pill <%= "all".equalsIgnoreCase(selectedCategory) || selectedCategory == null ? "active" : "" %>">
                                                            <input type="radio" name="category" value="all" <%="all"
                                                                .equalsIgnoreCase(selectedCategory) ||
                                                                selectedCategory==null ? "checked" : "" %>> All
                                                        </label>
                                                        <label class="radio-pill <%= "CAR".equalsIgnoreCase(selectedCategory) ? "active" : "" %>">
                                                            <input type="radio" name="category" value="CAR" <%="CAR"
                                                                .equalsIgnoreCase(selectedCategory) ? "checked" : "" %>>
                                                            Cars
                                                        </label>
                                                        <label class="radio-pill <%= "BIKE".equalsIgnoreCase(selectedCategory) ? "active" : "" %>">
                                                            <input type="radio" name="category" value="BIKE" <%="BIKE"
                                                                .equalsIgnoreCase(selectedCategory) ? "checked" : "" %>>
                                                            Bikes
                                                        </label>
                                                        <label class="radio-pill <%= "SCOOTER".equalsIgnoreCase(selectedCategory) ? "active" : "" %>">
                                                            <input type="radio" name="category" value="SCOOTER"
                                                                <%="SCOOTER" .equalsIgnoreCase(selectedCategory)
                                                                ? "checked" : "" %>> Scooters
                                                        </label>
                                                    </div>
                                                </div>

                                                <!-- Vehicle Condition (New, Used) -->
                                                <div class="filter-group">
                                                    <label class="filter-label">Condition</label>
                                                    <div class="filter-radio-pills">
                                                        <label class="radio-pill <%= "all".equalsIgnoreCase(selectedCondition) || selectedCondition == null ? "active" : "" %>">
                                                            <input type="radio" name="condition" value="all" <%="all"
                                                                .equalsIgnoreCase(selectedCondition) ||
                                                                selectedCondition==null ? "checked" : "" %>> Any
                                                        </label>
                                                        <label class="radio-pill <%= "NEW".equalsIgnoreCase(selectedCondition) ? "active" : "" %>">
                                                            <input type="radio" name="condition" value="NEW" <%="NEW"
                                                                .equalsIgnoreCase(selectedCondition) ? "checked" : ""
                                                                %>> New
                                                        </label>
                                                        <label class="radio-pill <%= "USED".equalsIgnoreCase(selectedCondition) ? "active" : "" %>">
                                                            <input type="radio" name="condition" value="USED" <%="USED"
                                                                .equalsIgnoreCase(selectedCondition) ? "checked" : ""
                                                                %>> Used
                                                        </label>
                                                    </div>
                                                </div>

                                                <!-- Fuel Type (Electric, Petrol, Diesel) -->
                                                <div class="filter-group">
                                                    <label class="filter-label">Fuel Type</label>
                                                    <div class="filter-radio-pills">
                                                        <label class="radio-pill <%= "all".equalsIgnoreCase(selectedFuel) || selectedFuel == null ? "active" : "" %>">
                                                            <input type="radio" name="fuel" value="all" <%="all"
                                                                .equalsIgnoreCase(selectedFuel) || selectedFuel==null
                                                                ? "checked" : "" %>> All
                                                        </label>
                                                        <label class="radio-pill <%= "ELECTRIC".equalsIgnoreCase(selectedFuel) ? "active" : "" %>">
                                                            <input type="radio" name="fuel" value="ELECTRIC"
                                                                <%="ELECTRIC" .equalsIgnoreCase(selectedFuel)
                                                                ? "checked" : "" %>> ⚡ Electric
                                                        </label>
                                                        <label class="radio-pill <%= "PETROL".equalsIgnoreCase(selectedFuel) ? "active" : "" %>">
                                                            <input type="radio" name="fuel" value="PETROL" <%="PETROL"
                                                                .equalsIgnoreCase(selectedFuel) ? "checked" : "" %>> ⛽
                                                            Petrol
                                                        </label>
                                                        <label class="radio-pill <%= "DIESEL".equalsIgnoreCase(selectedFuel) ? "active" : "" %>">
                                                            <input type="radio" name="fuel" value="DIESEL" <%="DIESEL"
                                                                .equalsIgnoreCase(selectedFuel) ? "checked" : "" %>> ⛽
                                                            Diesel
                                                        </label>
                                                    </div>
                                                </div>

                                                <!-- Brand Filter -->
                                                <div class="filter-group">
                                                    <label class="filter-label" for="sidebar-brand">Brand</label>
                                                    <select name="brand" id="sidebar-brand" class="filter-select">
                                                        <option value="all" <%="all" .equalsIgnoreCase(selectedBrand)
                                                            ? "selected" : "" %>>All Brands</option>
                                                        <option value="Tesla" <%="Tesla"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>>Tesla
                                                        </option>
                                                        <option value="Porsche" <%="Porsche"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>
                                                            >Porsche</option>
                                                        <option value="BMW" <%="BMW" .equalsIgnoreCase(selectedBrand)
                                                            ? "selected" : "" %>>BMW</option>
                                                        <option value="Audi" <%="Audi" .equalsIgnoreCase(selectedBrand)
                                                            ? "selected" : "" %>>Audi</option>
                                                        <option value="Mercedes-Benz" <%="Mercedes-Benz"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>
                                                            >Mercedes-Benz</option>
                                                        <option value="Honda" <%="Honda"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>>Honda
                                                        </option>
                                                        <option value="Rivian" <%="Rivian"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>>Rivian
                                                        </option>
                                                        <option value="Zero" <%="Zero" .equalsIgnoreCase(selectedBrand)
                                                            ? "selected" : "" %>>Zero (Electric Bikes)</option>
                                                        <option value="Royal Enfield" <%="Royal Enfield"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>>Royal
                                                            Enfield</option>
                                                        <option value="Yamaha" <%="Yamaha"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>>Yamaha
                                                        </option>
                                                        <option value="Ola" <%="Ola" .equalsIgnoreCase(selectedBrand)
                                                            ? "selected" : "" %>>Ola (Electric Scooters)</option>
                                                        <option value="Gogoro" <%="Gogoro"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>>Gogoro
                                                        </option>
                                                        <option value="Vespa" <%="Vespa"
                                                            .equalsIgnoreCase(selectedBrand) ? "selected" : "" %>>Vespa
                                                        </option>
                                                    </select>
                                                </div>

                                                <!-- Budget Filter -->
                                                <div class="filter-group">
                                                    <label class="filter-label" for="sidebar-budget">Max Budget</label>
                                                    <select name="budget" id="sidebar-budget" class="filter-select">
                                                        <option value="all" <%="all" .equalsIgnoreCase(selectedBudget)
                                                            ? "selected" : "" %>>Any Budget</option>
                                                        <option value="5000" <%="5000" .equals(selectedBudget)
                                                            ? "selected" : "" %>>Up to $5,000</option>
                                                        <option value="15000" <%="15000" .equals(selectedBudget)
                                                            ? "selected" : "" %>>Up to $15,000</option>
                                                        <option value="30000" <%="30000" .equals(selectedBudget)
                                                            ? "selected" : "" %>>Up to $30,000</option>
                                                        <option value="50000" <%="50000" .equals(selectedBudget)
                                                            ? "selected" : "" %>>Up to $50,000</option>
                                                        <option value="80000" <%="80000" .equals(selectedBudget)
                                                            ? "selected" : "" %>>Up to $80,000</option>
                                                        <option value="100000" <%="100000" .equals(selectedBudget)
                                                            ? "selected" : "" %>>Up to $100,000</option>
                                                    </select>
                                                </div>

                                                <!-- Location / City -->
                                                <div class="filter-group">
                                                    <label class="filter-label" for="sidebar-loc">City /
                                                        Location</label>
                                                    <input type="text" name="location" id="sidebar-loc"
                                                        class="filter-input"
                                                        placeholder="e.g. San Francisco, Austin, Chicago"
                                                        value="<%= selectedLocation != null ? selectedLocation : "" %>">
                                                </div>

                                                <button type="submit" class="btn btn-primary btn-block">Apply
                                                    Filters</button>
                                            </form>
                                        </div>
                                    </aside>

                                    <!-- Vehicle Listings Content -->
                                    <section class="listings-content">
                                        <!-- Sorting & View Bar -->
                                        <div class="sorting-bar">
                                            <div class="active-chips">
                                                <% if (selectedCategory !=null &&
                                                    !"all".equalsIgnoreCase(selectedCategory)) { %>
                                                    <span class="active-chip">Category: <%= selectedCategory %></span>
                                                    <% } %>
                                                        <% if (selectedFuel !=null &&
                                                            !"all".equalsIgnoreCase(selectedFuel)) { %>
                                                            <span class="active-chip">Fuel: <%= selectedFuel %></span>
                                                            <% } %>
                                                                <% if (selectedCondition !=null &&
                                                                    !"all".equalsIgnoreCase(selectedCondition)) { %>
                                                                    <span class="active-chip">Condition: <%=
                                                                            selectedCondition %></span>
                                                                    <% } %>
                                                                        <% if (selectedBrand !=null &&
                                                                            !"all".equalsIgnoreCase(selectedBrand)) { %>
                                                                            <span class="active-chip">Brand: <%=
                                                                                    selectedBrand %></span>
                                                                            <% } %>
                                            </div>

                                            <div class="sort-control">
                                                <label for="sort-select">Sort By:</label>
                                                <select id="sort-select" onchange="applySorting(this.value)">
                                                    <option value="default" <%="default" .equals(selectedSort)
                                                        ? "selected" : "" %>>Featured / Newest</option>
                                                    <option value="price_asc" <%="price_asc" .equals(selectedSort)
                                                        ? "selected" : "" %>>Price: Low to High</option>
                                                    <option value="price_desc" <%="price_desc" .equals(selectedSort)
                                                        ? "selected" : "" %>>Price: High to Low</option>
                                                    <option value="km_asc" <%="km_asc" .equals(selectedSort)
                                                        ? "selected" : "" %>>Lowest KM / Mileage</option>
                                                </select>
                                            </div>
                                        </div>

                                        <!-- Vehicles Grid -->
                                        <% if (vehicles !=null && !vehicles.isEmpty()) { %>
                                            <div class="vehicle-cards-grid">
                                                <% for (Vehicle v : vehicles) { %>
                                                    <div class="vehicle-card">
                                                        <div class="card-media">
                                                            <img src="<%= v.getThumbnailUrl() %>"
                                                                alt="<%= v.getDisplayName() %>" loading="lazy">
                                                            <div class="card-badges">
                                                                <span
                                                                    class="badge-condition <%= v.getConditionType().toLowerCase() %>">
                                                                    <%= v.getConditionType() %>
                                                                </span>
                                                                <span
                                                                    class="badge-fuel <%= v.getFuelType().toLowerCase() %>">
                                                                    <% if ("ELECTRIC".equalsIgnoreCase(v.getFuelType()))
                                                                        { %>⚡ Electric<% } else if
                                                                            ("DIESEL".equalsIgnoreCase(v.getFuelType()))
                                                                            { %>⛽ Diesel<% } else { %>⛽ Petrol<% } %>
                                                                </span>
                                                            </div>

                                                            <% if (v.getHealthReport() !=null) { %>
                                                                <div class="health-grade-badge grade-<%= v.getHealthReport().getOverallGrade().replace("+", "plus").toLowerCase() %>">
                                                                    <div class="grade-symbol">
                                                                        <%= v.getHealthReport().getOverallGrade() %>
                                                                    </div>
                                                                    <div class="grade-text">
                                                                        <% if (v.isElectric()) { %>
                                                                            <%= v.getHealthReport().getSohPercentage()
                                                                                %>% SoH
                                                                                <% } else { %>
                                                                                    <%= v.getHealthReport().getEngineHealthScore()
                                                                                        %>/100 Engine
                                                                                        <% } %>
                                                                    </div>
                                                                </div>
                                                                <% } %>
                                                        </div>

                                                        <div class="card-body">
                                                            <div class="card-category-tag">
                                                                <%= v.getCategory() %> &bull; <%= v.getBodyType() %>
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
                                                                    <svg width="12" height="12" viewBox="0 0 24 24"
                                                                        fill="none" stroke="currentColor"
                                                                        stroke-width="2">
                                                                        <circle cx="12" cy="12" r="10"></circle>
                                                                        <polyline points="12 6 12 12 16 14"></polyline>
                                                                    </svg>
                                                                    <%= v.getFormattedOdometer() %>
                                                                </div>
                                                                <div class="spec-chip">
                                                                    <% if (v.isElectric()) { %>
                                                                        ⚡ <%= v.getBatteryPackKwh() %> kWh Pack
                                                                            <% } else { %>
                                                                                ⚙️ <%= v.getEngineCc() %> cc Engine
                                                                                    <% } %>
                                                                </div>
                                                                <div class="spec-chip">
                                                                    📍 <%= v.getLocationCity() %>
                                                                </div>
                                                            </div>

                                                            <div class="card-price-row">
                                                                <div class="price-block">
                                                                    <div class="price-val">
                                                                        <%= v.getFormattedPrice() %>
                                                                    </div>
                                                                    <div class="price-emi">Est. <%= v.getEstimatedEmi()
                                                                            %>
                                                                    </div>
                                                                </div>
                                                                <div class="card-actions-block">
                                                                    <a href="<%= request.getContextPath() %>/health-report?id=<%= v.getVehicleId() %>"
                                                                        class="btn btn-outline-health">
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
                                            <% } else { %>
                                                <div class="no-results-box">
                                                    <div class="no-results-icon">🔍</div>
                                                    <h3>No Vehicles Found</h3>
                                                    <p>We couldn't find any vehicles matching your filter criteria. Try
                                                        broadening your budget or selecting all categories.</p>
                                                    <a href="<%= request.getContextPath() %>/vehicles"
                                                        class="btn btn-primary">Reset Filters</a>
                                                </div>
                                                <% } %>
                                    </section>
                                </div>
                            </main>

                            <%@ include file="/includes/footer.jsp" %>
                                <script src="<%= request.getContextPath() %>/js/main.js"></script>
                                <script>
                                    function applySorting(sortVal) {
                                        const url = new URL(window.location.href);
                                        url.searchParams.set('sort', sortVal);
                                        window.location.href = url.toString();
                                    }
                                </script>
                    </body>

                    </html>