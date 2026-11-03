<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="java.math.BigDecimal" %>
            <%@ page import="com.batteryiq.model.BatterySession" %>
                <%@ page import="com.batteryiq.model.BatteryTelemetryPoint" %>
                    <%@ page import="com.batteryiq.model.Vehicle" %>
                        <%@ page import="com.batteryiq.model.CapacityUnit" %>
                            <% Boolean pythonOnline=(Boolean) request.getAttribute("pythonOnline"); if
                                (pythonOnline==null) pythonOnline=false; @SuppressWarnings("unchecked")
                                List<BatterySession> sessionHistory = (List<BatterySession>)
                                    request.getAttribute("sessionHistory");

                                    @SuppressWarnings("unchecked")
                                    List<Vehicle> allVehicles = (List<Vehicle>) request.getAttribute("allVehicles");

                                            BatterySession selectedSession = (BatterySession)
                                            request.getAttribute("selectedSession");

                                            @SuppressWarnings("unchecked")
                                            List<BatteryTelemetryPoint> readings = (List<BatteryTelemetryPoint>)
                                                    request.getAttribute("readings");

                                                    String errorMessage = (String) request.getAttribute("errorMessage");
                                                    Boolean analysisSuccess = (Boolean)
                                                    request.getAttribute("analysisSuccess");

                                                    // Default current metrics for display
                                                    BigDecimal currentVoltage = null;
                                                    BigDecimal currentAmps = null;
                                                    BigDecimal currentTemp = null;
                                                    BigDecimal currentSoc = null;
                                                    Integer currentCellDelta = null;

                                                    if (readings != null && !readings.isEmpty()) {
                                                    BatteryTelemetryPoint lastPt = readings.get(readings.size() - 1);
                                                    currentVoltage = lastPt.getVoltageVolts();
                                                    currentAmps = lastPt.getCurrentAmps();
                                                    currentTemp = lastPt.getTemperatureCelsius();
                                                    currentSoc = lastPt.getSocPercentage();
                                                    currentCellDelta = lastPt.getCellDeltaMv();
                                                    }
                                                    %>
                                                    <!DOCTYPE html>
                                                    <html lang="en">

                                                    <head>
                                                        <meta charset="UTF-8">
                                                        <meta name="viewport"
                                                            content="width=device-width, initial-scale=1.0">
                                                        <title>BatteryIQ Intelligence Lab – AI EV Battery Diagnostic
                                                            &amp; Degradation Prediction</title>
                                                        <meta name="description"
                                                            content="AI-powered EV battery diagnostic, verification, and RUL degradation prediction platform. Supporting public research datasets, dynamic simulator, and future OBD-II/CAN scanner integration.">
                                                        <link rel="stylesheet"
                                                            href="<%= request.getContextPath() %>/css/style.css">
                                                        <link rel="icon"
                                                            href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>⚡</text></svg>">
                                                    </head>

                                                    <body class="report-body">

                                                        <%@ include file="/includes/header.jsp" %>

                                                            <main class="page-container">
                                                                <!-- Service Status & Mode Ribbon -->
                                                                <div class="report-lookup-strip no-print">
                                                                    <div class="container lookup-strip-inner">
                                                                        <div class="lookup-strip-title">
                                                                            <span class="<%= pythonOnline ? "report-live-dot" : "report-offline-dot" %>"></span>
                                                                            <span><strong>Python Scientific Intelligence
                                                                                    Microservice:</strong>
                                                                                <% if (pythonOnline) { %>
                                                                                    <span
                                                                                        class="status-online-tag">ONLINE
                                                                                        (Port 5001 &bull; Active WSGI
                                                                                        Engine)</span>
                                                                                    <% } else { %>
                                                                                        <span
                                                                                            class="status-offline-tag">OFFLINE
                                                                                            (Port 5001 &bull; Run
                                                                                            start_python_service.bat)</span>
                                                                                        <% } %>
                                                                            </span>
                                                                        </div>
                                                                        <div class="lookup-actions">
                                                                            <button type="button"
                                                                                class="btn btn-outline btn-sm"
                                                                                onclick="window.print()">
                                                                                <svg width="14" height="14"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor"
                                                                                    stroke-width="2">
                                                                                    <polyline
                                                                                        points="6 9 6 2 18 2 18 9">
                                                                                    </polyline>
                                                                                    <path
                                                                                        d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2">
                                                                                    </path>
                                                                                    <rect x="6" y="14" width="12"
                                                                                        height="8"></rect>
                                                                                </svg>
                                                                                Print Diagnostic Report
                                                                            </button>
                                                                        </div>
                                                                    </div>
                                                                </div>

                                                                <div class="container report-document-wrapper">

                                                                    <% if (!pythonOnline) { %>
                                                                        <div class="service-alert-offline">
                                                                            <div class="alert-icon">⚠️</div>
                                                                            <div class="alert-content">
                                                                                <h4>Python Scientific Intelligence
                                                                                    Service Disconnected</h4>
                                                                                <p>
                                                                                    In accordance with BatteryIQ's
                                                                                    strict design principles,
                                                                                    <strong>all scientific calculations,
                                                                                        Coulomb counting, SOH capacity
                                                                                        ratios, and ML RUL predictions
                                                                                        are computed exclusively in
                                                                                        Python</strong>.
                                                                                    Java does not invent fake or
                                                                                    divergent estimates when the
                                                                                    scientific engine is offline.
                                                                                </p>
                                                                                <p class="offline-step">
                                                                                    <strong>To activate the diagnostic
                                                                                        engine:</strong> Run
                                                                                    <code>start_python_service.bat</code>
                                                                                    in the project directory or run
                                                                                    <code>python python/app.py</code> in
                                                                                    your terminal.
                                                                                </p>
                                                                            </div>
                                                                        </div>
                                                                        <% } %>

                                                                            <% if (errorMessage !=null) { %>
                                                                                <div class="report-demo-alert"
                                                                                    style="background: #fef2f2; border-color: #fecaca; color: #991b1b;">
                                                                                    <div class="alert-icon">❌</div>
                                                                                    <div class="alert-text">
                                                                                        <strong>Analysis Error:</strong>
                                                                                        <%= errorMessage %>
                                                                                    </div>
                                                                                </div>
                                                                                <% } %>

                                                                                    <!-- Main Diagnostic Lab Console -->
                                                                                    <div
                                                                                        class="official-certificate-sheet">
                                                                                        <div class="lab-header-banner">
                                                                                            <div>
                                                                                                <span
                                                                                                    class="theme-tag">AI
                                                                                                    Battery Intelligence
                                                                                                    &amp; Prediction
                                                                                                    Lab</span>
                                                                                                <h1
                                                                                                    class="lab-main-title">
                                                                                                    EV Battery Health
                                                                                                    Diagnostic &amp;
                                                                                                    Degradation Suite
                                                                                                </h1>
                                                                                                <p class="lab-subtitle">
                                                                                                    Electro-thermal
                                                                                                    modeling,
                                                                                                    time-accurate
                                                                                                    Coulomb counting,
                                                                                                    chemistry-specific
                                                                                                    threshold auditing,
                                                                                                    and cycle-based
                                                                                                    Remaining Useful
                                                                                                    Life (RUL)
                                                                                                    estimation.
                                                                                                </p>
                                                                                            </div>
                                                                                            <div class="lab-stat-box">
                                                                                                <span
                                                                                                    class="stat-lbl">Active
                                                                                                    Telemetry
                                                                                                    Engine</span>
                                                                                                <span class="stat-val">
                                                                                                    <%= pythonOnline
                                                                                                        ? "Flask / Waitress WSGI"
                                                                                                        : "Awaiting Service"
                                                                                                        %>
                                                                                                </span>
                                                                                                <span
                                                                                                    class="stat-sub">Strict
                                                                                                    Single Source of
                                                                                                    Truth</span>
                                                                                            </div>
                                                                                        </div>

                                                                                        <!-- Three Data Source Selector Tabs -->
                                                                                        <div
                                                                                            class="lab-source-nav no-print">
                                                                                            <button type="button"
                                                                                                class="source-tab-btn active"
                                                                                                id="btn-tab-sim"
                                                                                                onclick="switchSourceTab('SIMULATOR')">
                                                                                                <span
                                                                                                    class="tab-icon">⚡</span>
                                                                                                <div>
                                                                                                    <strong>Interactive
                                                                                                        Battery
                                                                                                        Simulator</strong>
                                                                                                    <small>Dual-polarization
                                                                                                        equivalent
                                                                                                        circuit
                                                                                                        model</small>
                                                                                                </div>
                                                                                            </button>
                                                                                            <button type="button"
                                                                                                class="source-tab-btn"
                                                                                                id="btn-tab-dataset"
                                                                                                onclick="switchSourceTab('PUBLIC_DATASET')">
                                                                                                <span
                                                                                                    class="tab-icon">🔬</span>
                                                                                                <div>
                                                                                                    <strong>Public
                                                                                                        Research
                                                                                                        Datasets</strong>
                                                                                                    <small>NASA Ames
                                                                                                        PCoE &amp; CALCE
                                                                                                        benchmark
                                                                                                        cells</small>
                                                                                                </div>
                                                                                            </button>
                                                                                            <button type="button"
                                                                                                class="source-tab-btn"
                                                                                                id="btn-tab-obd"
                                                                                                onclick="switchSourceTab('LIVE_OBD')">
                                                                                                <span
                                                                                                    class="tab-icon">🔌</span>
                                                                                                <div>
                                                                                                    <strong>Live OBD-II
                                                                                                        / CAN
                                                                                                        Port</strong>
                                                                                                    <small>Hardware
                                                                                                        abstraction
                                                                                                        pre-flight
                                                                                                        console</small>
                                                                                                </div>
                                                                                            </button>
                                                                                        </div>

                                                                                        <!-- Simulation & Analysis Control Form -->
                                                                                        <form
                                                                                            action="<%= request.getContextPath() %>/battery-lab"
                                                                                            method="post"
                                                                                            class="lab-control-panel no-print"
                                                                                            id="battery-analysis-form">
                                                                                            <input type="hidden"
                                                                                                name="source_type"
                                                                                                id="hidden_source_type"
                                                                                                value="SIMULATOR">

                                                                                            <div class="control-grid">
                                                                                                <!-- Column 1: Chemistry Profile -->
                                                                                                <div
                                                                                                    class="control-group">
                                                                                                    <label
                                                                                                        for="chem_select">Battery
                                                                                                        Chemistry
                                                                                                        Profile:</label>
                                                                                                    <select
                                                                                                        name="chemistry_profile_id"
                                                                                                        id="chem_select"
                                                                                                        class="form-select"
                                                                                                        onchange="handleChemistryChange(this.value)">
                                                                                                        <option
                                                                                                            value="CHEM_NMC_01"
                                                                                                            selected>
                                                                                                            Lithium
                                                                                                            Nickel
                                                                                                            Manganese
                                                                                                            Cobalt (NMC
                                                                                                            622/811) [EV
                                                                                                            Standard]
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="CHEM_LFP_01">
                                                                                                            Lithium Iron
                                                                                                            Phosphate
                                                                                                            (LiFePO4 /
                                                                                                            LFP) [Flat
                                                                                                            OCV Plateau]
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="CHEM_NCA_01">
                                                                                                            Lithium
                                                                                                            Nickel
                                                                                                            Cobalt
                                                                                                            Aluminum
                                                                                                            (NCA 2170)
                                                                                                            [High
                                                                                                            Density]
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="CHEM_NASA_18650">
                                                                                                            NASA PCoE
                                                                                                            Benchmark
                                                                                                            Cell (LiCoO2
                                                                                                            / 18650)
                                                                                                            [Lab Bench
                                                                                                            Test]
                                                                                                        </option>
                                                                                                    </select>
                                                                                                    <small
                                                                                                        class="field-hint"
                                                                                                        id="chem_hint">Nominal:
                                                                                                        3.7V, Cutoff:
                                                                                                        3.0V, Max: 4.2V.
                                                                                                        Automotive
                                                                                                        standard.</small>
                                                                                                </div>

                                                                                                <!-- Column 2: Capacity & Units -->
                                                                                                <div
                                                                                                    class="control-group">
                                                                                                    <label
                                                                                                        for="unit_select">Capacity
                                                                                                        Unit &amp;
                                                                                                        Reference
                                                                                                        Baseline:</label>
                                                                                                    <div
                                                                                                        class="dual-input-row">
                                                                                                        <select
                                                                                                            name="capacity_unit"
                                                                                                            id="unit_select"
                                                                                                            class="form-select"
                                                                                                            style="max-width: 130px;">
                                                                                                            <option
                                                                                                                value="KWH"
                                                                                                                selected>
                                                                                                                kWh
                                                                                                                (Pack)
                                                                                                            </option>
                                                                                                            <option
                                                                                                                value="AH">
                                                                                                                Ah
                                                                                                                (Cell)
                                                                                                            </option>
                                                                                                        </select>
                                                                                                        <select
                                                                                                            name="active_reference_type"
                                                                                                            id="ref_select"
                                                                                                            class="form-select">
                                                                                                            <option
                                                                                                                value="RATED_NOMINAL"
                                                                                                                selected>
                                                                                                                Rated
                                                                                                                Nominal
                                                                                                                Nameplate
                                                                                                            </option>
                                                                                                            <option
                                                                                                                value="FRESH_BASELINE">
                                                                                                                Fresh
                                                                                                                Measured
                                                                                                                Baseline
                                                                                                                (Cycle
                                                                                                                1)
                                                                                                            </option>
                                                                                                        </select>
                                                                                                    </div>
                                                                                                    <small
                                                                                                        class="field-hint">Reference
                                                                                                        baseline is held
                                                                                                        consistent
                                                                                                        across SOH and
                                                                                                        RUL
                                                                                                        evaluation.</small>
                                                                                                </div>

                                                                                                <!-- Column 3: Presets & Scenarios -->
                                                                                                <div
                                                                                                    class="control-group">
                                                                                                    <label
                                                                                                        for="preset_select">Test
                                                                                                        Profile &amp;
                                                                                                        Operational
                                                                                                        Scenario:</label>
                                                                                                    <select
                                                                                                        name="preset_scenario"
                                                                                                        id="preset_select"
                                                                                                        class="form-select">
                                                                                                        <option
                                                                                                            value="NORMAL_DRIVE"
                                                                                                            selected>
                                                                                                            Normal
                                                                                                            Highway
                                                                                                            &amp;
                                                                                                            Commute
                                                                                                            Discharge
                                                                                                            (25A load)
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="DC_FAST_CHARGE">
                                                                                                            High-Rate DC
                                                                                                            Fast Charge
                                                                                                            Session
                                                                                                            (-120A,
                                                                                                            thermal
                                                                                                            gradient)
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="THERMAL_ANOMALY">
                                                                                                            Thermal
                                                                                                            Stress
                                                                                                            Condition
                                                                                                            (&gt;45°C
                                                                                                            overheat
                                                                                                            warning)
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="CELL_IMBALANCE">
                                                                                                            Cell Voltage
                                                                                                            Divergence
                                                                                                            Fault
                                                                                                            (&gt;50 mV
                                                                                                            delta)
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="NASA_PCOE_B0005_CYCLE">
                                                                                                            NASA PCoE
                                                                                                            Experimental
                                                                                                            Aging Cycle
                                                                                                            (2A bench
                                                                                                            discharge)
                                                                                                        </option>
                                                                                                    </select>
                                                                                                    <small
                                                                                                        class="field-hint">Simulates
                                                                                                        physical V, I,
                                                                                                        T, and
                                                                                                        cell-delta
                                                                                                        response
                                                                                                        curves.</small>
                                                                                                </div>
                                                                                            </div>

                                                                                            <!-- Custom Capacity Inputs (Collapsible) -->
                                                                                            <div
                                                                                                class="control-secondary-row">
                                                                                                <div
                                                                                                    class="sec-input-item">
                                                                                                    <label
                                                                                                        for="nom_cap_input">Nominal
                                                                                                        Rated
                                                                                                        Capacity:</label>
                                                                                                    <input type="number"
                                                                                                        step="0.1"
                                                                                                        name="nominal_capacity"
                                                                                                        id="nom_cap_input"
                                                                                                        value="75.0"
                                                                                                        class="form-input">
                                                                                                </div>
                                                                                                <div
                                                                                                    class="sec-input-item">
                                                                                                    <label
                                                                                                        for="curr_cap_input">Current
                                                                                                        Measured Usable
                                                                                                        Capacity:</label>
                                                                                                    <input type="number"
                                                                                                        step="0.1"
                                                                                                        name="current_measured_capacity"
                                                                                                        id="curr_cap_input"
                                                                                                        value="70.2"
                                                                                                        class="form-input">
                                                                                                </div>
                                                                                                <div
                                                                                                    class="sec-input-item">
                                                                                                    <label
                                                                                                        for="init_soc_input">Initial
                                                                                                        SOC (%):</label>
                                                                                                    <input type="number"
                                                                                                        step="1" min="0"
                                                                                                        max="100"
                                                                                                        name="initial_soc_pct"
                                                                                                        id="init_soc_input"
                                                                                                        value="85"
                                                                                                        class="form-input">
                                                                                                </div>
                                                                                                <div
                                                                                                    class="sec-input-item">
                                                                                                    <label
                                                                                                        for="veh_select">Link
                                                                                                        to Marketplace
                                                                                                        Vehicle
                                                                                                        (Optional):</label>
                                                                                                    <select
                                                                                                        name="vehicle_id"
                                                                                                        id="veh_select"
                                                                                                        class="form-select">
                                                                                                        <option
                                                                                                            value="">--
                                                                                                            None
                                                                                                            (Standalone
                                                                                                            Test) --
                                                                                                        </option>
                                                                                                        <% if
                                                                                                            (allVehicles
                                                                                                            !=null) {
                                                                                                            for (Vehicle
                                                                                                            v :
                                                                                                            allVehicles)
                                                                                                            { %>
                                                                                                            <option
                                                                                                                value="<%= v.getVehicleId() %>">
                                                                                                                <%= v.getDisplayName()
                                                                                                                    %> (
                                                                                                                    <%= v.getCategory()
                                                                                                                        %>
                                                                                                                        &bull;
                                                                                                                        <%= v.getFuelType()
                                                                                                                            %>
                                                                                                                            )
                                                                                                            </option>
                                                                                                            <% } } %>
                                                                                                    </select>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="sec-input-item sec-btn-item">
                                                                                                    <button
                                                                                                        type="submit"
                                                                                                        class="btn btn-primary btn-run-analysis"
                                                                                                        <%=!pythonOnline
                                                                                                        ? "disabled"
                                                                                                        : "" %>>
                                                                                                        <svg width="16"
                                                                                                            height="16"
                                                                                                            viewBox="0 0 24 24"
                                                                                                            fill="none"
                                                                                                            stroke="currentColor"
                                                                                                            stroke-width="2.5">
                                                                                                            <polygon
                                                                                                                points="5 3 19 12 5 21 5 3">
                                                                                                            </polygon>
                                                                                                        </svg>
                                                                                                        Run Battery
                                                                                                        Intelligence
                                                                                                        Analysis
                                                                                                    </button>
                                                                                                </div>
                                                                                            </div>
                                                                                        </form>

                                                                                        <!-- Live OBD / CAN Port Hardware Abstraction Console -->
                                                                                        <div class="live-hardware-console"
                                                                                            id="obd-warning-panel"
                                                                                            style="display: none;">
                                                                                            <div
                                                                                                class="live-console-header">
                                                                                                <div>
                                                                                                    <div
                                                                                                        style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.35rem;">
                                                                                                        <h3
                                                                                                            style="margin: 0; font-size: 1.15rem; font-weight: 800; color: #0f172a;">
                                                                                                            🔌 Live EV
                                                                                                            Telematics
                                                                                                            &amp; CAN
                                                                                                            Bus Hardware
                                                                                                            Abstraction
                                                                                                            Console
                                                                                                        </h3>
                                                                                                        <span
                                                                                                            class="live-adapter-badge disconnected"
                                                                                                            id="hw-status-badge">
                                                                                                            <span
                                                                                                                class="status-dot"></span>
                                                                                                            <span
                                                                                                                id="hw-status-text">DISCONNECTED</span>
                                                                                                        </span>
                                                                                                    </div>
                                                                                                    <p
                                                                                                        style="margin: 0; font-size: 0.82rem; color: #64748b;">
                                                                                                        Modular
                                                                                                        Diagnostic
                                                                                                        Adapter Layer
                                                                                                        supporting SAE
                                                                                                        J1979 OBD-II,
                                                                                                        ISO 14229 UDS,
                                                                                                        and direct CAN
                                                                                                        broadcast
                                                                                                        frames.
                                                                                                    </p>
                                                                                                </div>
                                                                                                <div>
                                                                                                    <span
                                                                                                        class="evidence-status-pill unverified"
                                                                                                        style="font-weight: 700;">
                                                                                                        UNVERIFIED_LIVE_TELEMETRY
                                                                                                    </span>
                                                                                                </div>
                                                                                            </div>

                                                                                            <!-- Hardware Connection Controls -->
                                                                                            <div
                                                                                                class="live-controls-row">
                                                                                                <div
                                                                                                    style="display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
                                                                                                    <label
                                                                                                        style="font-size: 0.8rem; font-weight: 700; color: #334155;">Adapter
                                                                                                        Type:</label>
                                                                                                    <select
                                                                                                        id="hw-adapter-type"
                                                                                                        class="form-select"
                                                                                                        style="font-size: 0.82rem; padding: 0.35rem 0.6rem; min-width: 170px;">
                                                                                                        <option
                                                                                                            value="MOCK_OBD2"
                                                                                                            selected>
                                                                                                            Mock OBD-II
                                                                                                            (ELM327 /
                                                                                                            UDS Harness)
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="MOCK_CAN">
                                                                                                            Mock CAN Bus
                                                                                                            (CANable /
                                                                                                            slcan0)
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="PHYSICAL_SERIAL">
                                                                                                            Physical
                                                                                                            Serial Port
                                                                                                            (COM / USB)
                                                                                                        </option>
                                                                                                    </select>

                                                                                                    <label
                                                                                                        style="font-size: 0.8rem; font-weight: 700; color: #334155; margin-left: 0.5rem;">Target
                                                                                                        CAN
                                                                                                        Profile:</label>
                                                                                                    <select
                                                                                                        id="hw-profile-id"
                                                                                                        class="form-select"
                                                                                                        style="font-size: 0.82rem; padding: 0.35rem 0.6rem; min-width: 190px;">
                                                                                                        <option
                                                                                                            value="PROFILE_NISSAN_LEAF_AZE0"
                                                                                                            selected>
                                                                                                            Nissan Leaf
                                                                                                            AZE0
                                                                                                            (OpenDBC
                                                                                                            Reference)
                                                                                                        </option>
                                                                                                        <option
                                                                                                            value="PROFILE_PROPOSED_EV_STANDARD">
                                                                                                            Generic EV
                                                                                                            BMS
                                                                                                            Broadcast
                                                                                                            Profile
                                                                                                        </option>
                                                                                                    </select>

                                                                                                    <button
                                                                                                        type="button"
                                                                                                        class="btn btn-primary"
                                                                                                        onclick="connectHardwareAdapter()"
                                                                                                        id="btn-hw-connect"
                                                                                                        style="font-size: 0.82rem; padding: 0.4rem 0.9rem;">
                                                                                                        Connect Adapter
                                                                                                    </button>
                                                                                                    <button
                                                                                                        type="button"
                                                                                                        class="btn btn-outline"
                                                                                                        onclick="disconnectHardwareAdapter()"
                                                                                                        id="btn-hw-disconnect"
                                                                                                        style="font-size: 0.82rem; padding: 0.4rem 0.9rem; display: none;">
                                                                                                        Disconnect
                                                                                                    </button>
                                                                                                    <button
                                                                                                        type="button"
                                                                                                        class="btn btn-secondary"
                                                                                                        onclick="pollHardwareTelemetry()"
                                                                                                        id="btn-hw-poll"
                                                                                                        style="font-size: 0.82rem; padding: 0.4rem 0.9rem; display: none;">
                                                                                                        ⚡ Poll BMS
                                                                                                        Telemetry
                                                                                                    </button>
                                                                                                </div>
                                                                                            </div>

                                                                                            <!-- Fault Injection & Testing Row -->
                                                                                            <div
                                                                                                style="background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 6px; padding: 0.6rem 0.85rem; margin-bottom: 1.25rem; display: flex; align-items: center; gap: 0.75rem; flex-wrap: wrap;">
                                                                                                <span
                                                                                                    style="font-size: 0.75rem; font-weight: 700; color: #475569; text-transform: uppercase;">
                                                                                                    🧪 Simulation &amp;
                                                                                                    Fault Injection
                                                                                                    Harness:
                                                                                                </span>
                                                                                                <button type="button"
                                                                                                    class="btn btn-sm btn-outline"
                                                                                                    onclick="applyHardwareFault('TIMEOUT')"
                                                                                                    style="font-size: 0.75rem; padding: 0.2rem 0.5rem;">
                                                                                                    Simulate ECU Timeout
                                                                                                </button>
                                                                                                <button type="button"
                                                                                                    class="btn btn-sm btn-outline"
                                                                                                    onclick="applyHardwareFault('BUS_ERROR')"
                                                                                                    style="font-size: 0.75rem; padding: 0.2rem 0.5rem;">
                                                                                                    Simulate Bus Error
                                                                                                </button>
                                                                                                <button type="button"
                                                                                                    class="btn btn-sm btn-outline"
                                                                                                    onclick="applyHardwareFault('MISSING_SIGNALS')"
                                                                                                    style="font-size: 0.75rem; padding: 0.2rem 0.5rem;">
                                                                                                    Simulate Missing
                                                                                                    Signals
                                                                                                </button>
                                                                                                <button type="button"
                                                                                                    class="btn btn-sm btn-outline"
                                                                                                    onclick="applyHardwareFault('RESET')"
                                                                                                    style="font-size: 0.75rem; padding: 0.2rem 0.5rem; color: #16a34a;">
                                                                                                    Reset / Clear Faults
                                                                                                </button>
                                                                                                <span id="fault-notice"
                                                                                                    style="font-size: 0.75rem; color: #0284c7; font-weight: 600;"></span>
                                                                                            </div>

                                                                                            <!-- Live Telemetry Gauges -->
                                                                                            <div
                                                                                                class="live-telemetry-gauges">
                                                                                                <div
                                                                                                    class="live-gauge-tile">
                                                                                                    <div
                                                                                                        class="live-gauge-lbl">
                                                                                                        Pack Voltage
                                                                                                    </div>
                                                                                                    <div class="live-gauge-val"
                                                                                                        id="g-voltage">
                                                                                                        --<span
                                                                                                            class="unit">V</span>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="live-gauge-tile">
                                                                                                    <div
                                                                                                        class="live-gauge-lbl">
                                                                                                        Pack Current
                                                                                                    </div>
                                                                                                    <div class="live-gauge-val"
                                                                                                        id="g-current">
                                                                                                        --<span
                                                                                                            class="unit">A</span>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="live-gauge-tile">
                                                                                                    <div
                                                                                                        class="live-gauge-lbl">
                                                                                                        State of Charge
                                                                                                    </div>
                                                                                                    <div class="live-gauge-val"
                                                                                                        id="g-soc">
                                                                                                        --<span
                                                                                                            class="unit">%</span>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="live-gauge-tile">
                                                                                                    <div
                                                                                                        class="live-gauge-lbl">
                                                                                                        Temperature
                                                                                                    </div>
                                                                                                    <div class="live-gauge-val"
                                                                                                        id="g-temp">
                                                                                                        --<span
                                                                                                            class="unit">°C</span>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="live-gauge-tile">
                                                                                                    <div
                                                                                                        class="live-gauge-lbl">
                                                                                                        Active Power
                                                                                                    </div>
                                                                                                    <div class="live-gauge-val"
                                                                                                        id="g-power">
                                                                                                        --<span
                                                                                                            class="unit">kW</span>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="live-gauge-tile">
                                                                                                    <div
                                                                                                        class="live-gauge-lbl">
                                                                                                        Cell Delta</div>
                                                                                                    <div class="live-gauge-val"
                                                                                                        id="g-delta"
                                                                                                        style="color: #94a3b8;">
                                                                                                        N/A</div>
                                                                                                </div>
                                                                                            </div>

                                                                                            <!-- Signals Breakdown: Supported vs Unsupported -->
                                                                                            <div
                                                                                                class="live-signals-box">
                                                                                                <div
                                                                                                    class="signals-subcolumn">
                                                                                                    <h5
                                                                                                        style="color: #15803d;">
                                                                                                        <span>✔</span>
                                                                                                        Supported BMS
                                                                                                        Telemetry
                                                                                                        Signals
                                                                                                    </h5>
                                                                                                    <div class="signal-chip-list"
                                                                                                        id="list-supported-signals">
                                                                                                        <div
                                                                                                            class="signal-chip supported">
                                                                                                            <span>●</span>
                                                                                                            Pack Voltage
                                                                                                            (V) &bull;
                                                                                                            Mode 22 UDS
                                                                                                            / CAN 0x1DB
                                                                                                        </div>
                                                                                                        <div
                                                                                                            class="signal-chip supported">
                                                                                                            <span>●</span>
                                                                                                            Traction
                                                                                                            Current (A)
                                                                                                            &bull; Mode
                                                                                                            22 UDS / CAN
                                                                                                            0x1DB
                                                                                                        </div>
                                                                                                        <div
                                                                                                            class="signal-chip supported">
                                                                                                            <span>●</span>
                                                                                                            State of
                                                                                                            Charge (%)
                                                                                                            &bull; CAN
                                                                                                            0x5BC / UDS
                                                                                                            DID 0x2001
                                                                                                        </div>
                                                                                                        <div
                                                                                                            class="signal-chip supported">
                                                                                                            <span>●</span>
                                                                                                            Module
                                                                                                            Temperature
                                                                                                            (°C) &bull;
                                                                                                            CAN 0x55B
                                                                                                        </div>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="signals-subcolumn">
                                                                                                    <h5
                                                                                                        style="color: #b45309;">
                                                                                                        <span>⚠</span>
                                                                                                        Missing or
                                                                                                        Unsupported
                                                                                                        Telemetry
                                                                                                        Signals
                                                                                                    </h5>
                                                                                                    <div class="signal-chip-list"
                                                                                                        id="list-unsupported-signals">
                                                                                                        <div
                                                                                                            class="signal-chip unsupported">
                                                                                                            <span>○</span>
                                                                                                            Cell Delta
                                                                                                            Voltage (mV)
                                                                                                            &bull; Not
                                                                                                            in standard
                                                                                                            OBD-II PID
                                                                                                        </div>
                                                                                                        <div
                                                                                                            class="signal-chip unsupported">
                                                                                                            <span>○</span>
                                                                                                            Internal
                                                                                                            Cell
                                                                                                            Resistance
                                                                                                            &bull;
                                                                                                            Computed
                                                                                                            offline in
                                                                                                            Python
                                                                                                        </div>
                                                                                                        <div
                                                                                                            class="signal-chip unsupported">
                                                                                                            <span>○</span>
                                                                                                            Vehicle
                                                                                                            Identification
                                                                                                            Number
                                                                                                            &bull;
                                                                                                            Requires
                                                                                                            Mode 09 auth
                                                                                                        </div>
                                                                                                    </div>
                                                                                                </div>
                                                                                            </div>

                                                                                            <!-- Raw CAN Frames & Diagnostic Command Exchange Log -->
                                                                                            <div
                                                                                                style="margin-bottom: 1rem;">
                                                                                                <div
                                                                                                    style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.35rem;">
                                                                                                    <label
                                                                                                        style="font-size: 0.78rem; font-weight: 700; color: #475569; text-transform: uppercase;">
                                                                                                        💻 Raw
                                                                                                        Diagnostic
                                                                                                        Traffic Terminal
                                                                                                        (AT Commands
                                                                                                        &amp; CAN
                                                                                                        Frames):
                                                                                                    </label>
                                                                                                    <span
                                                                                                        style="font-size: 0.72rem; color: #64748b;">Awaiting
                                                                                                        connection...</span>
                                                                                                </div>
                                                                                                <div class="terminal-stream-box"
                                                                                                    id="raw-terminal-log">
                                                                                                    [HAL] Diagnostic
                                                                                                    Hardware Abstraction
                                                                                                    Layer initialized.
                                                                                                    [HAL] Ready to
                                                                                                    attach OBD-II or CAN
                                                                                                    bus interface.
                                                                                                    [NOTICE] Standard
                                                                                                    OBD-II does not
                                                                                                    expose EV battery
                                                                                                    health; non-standard
                                                                                                    UDS DIDs or CAN
                                                                                                    matrix required.
                                                                                                </div>
                                                                                            </div>

                                                                                            <!-- Mandatory Engineering Transparency Notice -->
                                                                                            <div
                                                                                                style="background: #eff6ff; border-left: 4px solid #3b82f6; padding: 0.75rem 1rem; border-radius: 4px; font-size: 0.8rem; color: #1e40af; line-height: 1.45;">
                                                                                                <strong>PHYSICAL
                                                                                                    VERIFICATION
                                                                                                    PROTOCOL:</strong>
                                                                                                Live OBD-II/CAN data
                                                                                                streams are classified
                                                                                                strictly as
                                                                                                <code>UNVERIFIED_LIVE_TELEMETRY</code>.
                                                                                                In strict adherence to
                                                                                                automotive diagnostic
                                                                                                safety standards,
                                                                                                real-world certification
                                                                                                and
                                                                                                <code>PHYSICALLY_VERIFIED</code>
                                                                                                status
                                                                                                require an authorized
                                                                                                technician's hands-on
                                                                                                inspection of physical
                                                                                                contactors, pack
                                                                                                isolation resistance,
                                                                                                and physical hardware
                                                                                                sign-off.
                                                                                            </div>
                                                                                        </div>


                                                                                        <!-- Provenance & Source Watermark Banner -->
                                                                                        <% if (selectedSession !=null) {
                                                                                            %>
                                                                                            <div class="provenance-watermark-bar <%= selectedSession.isPublicDataset() ? "dataset" : (selectedSession.isLiveObd() ? "live" : "simulator") %>">
                                                                                                <div class="prov-badge">
                                                                                                    <% if
                                                                                                        (selectedSession.isPublicDataset())
                                                                                                        { %>
                                                                                                        <span
                                                                                                            class="prov-tag dataset">PUBLIC
                                                                                                            RESEARCH
                                                                                                            DATASET
                                                                                                            ANALYSIS</span>
                                                                                                        <% } else if
                                                                                                            (selectedSession.isLiveObd())
                                                                                                            { %>
                                                                                                            <span
                                                                                                                class="prov-tag live">LIVE
                                                                                                                VEHICLE
                                                                                                                TELEMETRY
                                                                                                                &bull;
                                                                                                                UNVERIFIED</span>
                                                                                                            <% } else {
                                                                                                                %>
                                                                                                                <span
                                                                                                                    class="prov-tag simulator">DEMO
                                                                                                                    DATA
                                                                                                                    &bull;
                                                                                                                    SIMULATED
                                                                                                                    BATTERY
                                                                                                                    READINGS</span>
                                                                                                                <% } %>
                                                                                                </div>
                                                                                                <div class="prov-text">
                                                                                                    <% if
                                                                                                        (selectedSession.isPublicDataset())
                                                                                                        { %>
                                                                                                        <strong>LABORATORY
                                                                                                            CELL
                                                                                                            EXPERIMENT:</strong>
                                                                                                        NASA Ames
                                                                                                        Prognostics
                                                                                                        Center of
                                                                                                        Excellence
                                                                                                        (PCoE) aging
                                                                                                        benchmark.
                                                                                                        Controlled
                                                                                                        laboratory bench
                                                                                                        cell, not a full
                                                                                                        commercial EV
                                                                                                        pack.
                                                                                                        <% } else if
                                                                                                            (selectedSession.isLiveObd())
                                                                                                            { %>
                                                                                                            <strong>HARDWARE
                                                                                                                STREAM
                                                                                                                RECEIVED:</strong>
                                                                                                            Real-time
                                                                                                            telematics
                                                                                                            packet
                                                                                                            stream. Live
                                                                                                            reception
                                                                                                            does NOT
                                                                                                            constitute
                                                                                                            an
                                                                                                            independent
                                                                                                            physical
                                                                                                            verification.
                                                                                                            <% } else {
                                                                                                                %>
                                                                                                                <strong>SYNTHETIC
                                                                                                                    TELEMETRY:</strong>
                                                                                                                Generated
                                                                                                                via
                                                                                                                dual-polarization
                                                                                                                equivalent
                                                                                                                circuit
                                                                                                                model
                                                                                                                (ECM)
                                                                                                                for
                                                                                                                system
                                                                                                                demonstration.
                                                                                                                Never
                                                                                                                present
                                                                                                                as real
                                                                                                                vehicle
                                                                                                                inspections.
                                                                                                                <% } %>
                                                                                                </div>
                                                                                            </div>
                                                                                            <% } %>

                                                                                                <!-- ============================================================= -->
                                                                                                <!-- RESULTS SECTION: SOH, DEGRADATION, SOC, AND TELEMETRY CARDS    -->
                                                                                                <!-- ============================================================= -->
                                                                                                <% if (selectedSession
                                                                                                    !=null) { %>
                                                                                                    <div class="telemetry-grid"
                                                                                                        style="margin-top: 1.5rem;">
                                                                                                        <!-- Card 1: State of Health (SOH) -->
                                                                                                        <div
                                                                                                            class="telemetry-card highlight-card">
                                                                                                            <div
                                                                                                                class="t-card-header">
                                                                                                                <span
                                                                                                                    class="t-icon">🔋</span>
                                                                                                                <h4>State
                                                                                                                    of
                                                                                                                    Health
                                                                                                                    (SOH)
                                                                                                                </h4>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="t-huge-stat">
                                                                                                                <%= selectedSession.getEstimatedSohPct()
                                                                                                                    !=null
                                                                                                                    ?
                                                                                                                    selectedSession.getEstimatedSohPct()
                                                                                                                    : "--"
                                                                                                                    %>
                                                                                                                    <span
                                                                                                                        class="unit">%</span>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="t-progress-bar">
                                                                                                                <div class="t-progress-fill"
                                                                                                                    style="width: <%= selectedSession.getEstimatedSohPct() != null ? selectedSession.getEstimatedSohPct() : 0 %>%;">
                                                                                                                </div>
                                                                                                            </div>
                                                                                                            <p
                                                                                                                class="t-desc">
                                                                                                                Condition:
                                                                                                                <strong>
                                                                                                                    <%= selectedSession.getConditionCategory()
                                                                                                                        !=null
                                                                                                                        ?
                                                                                                                        selectedSession.getConditionCategory()
                                                                                                                        : "UNAVAILABLE"
                                                                                                                        %>
                                                                                                                </strong>.<br>
                                                                                                                Reference
                                                                                                                Capacity:
                                                                                                                <strong>
                                                                                                                    <%= selectedSession.getFormattedNominalCapacity()
                                                                                                                        %>
                                                                                                                </strong>
                                                                                                                (<%= selectedSession.getActiveReferenceType()
                                                                                                                    %>
                                                                                                                    ).<br>
                                                                                                                    Current
                                                                                                                    Usable:
                                                                                                                    <strong>
                                                                                                                        <%= selectedSession.getFormattedCurrentCapacity()
                                                                                                                            %>
                                                                                                                    </strong>.
                                                                                                            </p>
                                                                                                            <span
                                                                                                                class="evidence-status-pill <%= selectedSession.isPhysicallyVerified() ? "verified" : (selectedSession.isLiveObd() ? "unverified" : (selectedSession.isPublicDataset() ? "unverified" : "pending")) %>">
                                                                                                                <%= selectedSession.getVerificationStatus()
                                                                                                                    %>
                                                                                                            </span>
                                                                                                        </div>

                                                                                                        <!-- Card 2: Capacity Degradation -->
                                                                                                        <div
                                                                                                            class="telemetry-card">
                                                                                                            <div
                                                                                                                class="t-card-header">
                                                                                                                <span
                                                                                                                    class="t-icon">📉</span>
                                                                                                                <h4>Capacity
                                                                                                                    Degradation
                                                                                                                </h4>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="t-huge-stat">
                                                                                                                <%= selectedSession.getEstimatedSohPct()
                                                                                                                    !=null
                                                                                                                    ?
                                                                                                                    (new
                                                                                                                    BigDecimal("100.0").subtract(selectedSession.getEstimatedSohPct()))
                                                                                                                    : "--"
                                                                                                                    %>
                                                                                                                    <span
                                                                                                                        class="unit">%</span>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="degrade-meter">
                                                                                                                <span
                                                                                                                    class="degrade-benchmark">Chemistry:
                                                                                                                    <%= selectedSession.getChemistryProfileId()
                                                                                                                        %>
                                                                                                                </span>
                                                                                                            </div>
                                                                                                            <p
                                                                                                                class="t-desc">
                                                                                                                Total
                                                                                                                capacity
                                                                                                                loss
                                                                                                                observed
                                                                                                                relative
                                                                                                                to
                                                                                                                selected
                                                                                                                reference
                                                                                                                baseline.
                                                                                                                Usable
                                                                                                                capacity
                                                                                                                retention
                                                                                                                conforms
                                                                                                                to
                                                                                                                electrochemical
                                                                                                                longevity
                                                                                                                curve.
                                                                                                            </p>
                                                                                                            <span
                                                                                                                class="evidence-status-pill unverified">
                                                                                                                Algorithmic
                                                                                                                Fade
                                                                                                                Audit
                                                                                                            </span>
                                                                                                        </div>

                                                                                                        <!-- Card 3: State of Charge (SOC) -->
                                                                                                        <div
                                                                                                            class="telemetry-card">
                                                                                                            <div
                                                                                                                class="t-card-header">
                                                                                                                <span
                                                                                                                    class="t-icon">⚡</span>
                                                                                                                <h4>State
                                                                                                                    of
                                                                                                                    Charge
                                                                                                                    (SOC)
                                                                                                                </h4>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="t-huge-stat">
                                                                                                                <%= currentSoc
                                                                                                                    !=null
                                                                                                                    ?
                                                                                                                    currentSoc
                                                                                                                    :
                                                                                                                    (selectedSession.getInitialSocPct()
                                                                                                                    !=null
                                                                                                                    ?
                                                                                                                    selectedSession.getInitialSocPct()
                                                                                                                    : "--"
                                                                                                                    ) %>
                                                                                                                    <span
                                                                                                                        class="unit">%</span>
                                                                                                            </div>
                                                                                                            <p
                                                                                                                class="t-desc">
                                                                                                                Method:
                                                                                                                <strong>
                                                                                                                    <%= selectedSession.getSocEstimationMethod()
                                                                                                                        %>
                                                                                                                </strong>.<br>
                                                                                                                Initial
                                                                                                                Anchor:
                                                                                                                <strong>
                                                                                                                    <%= selectedSession.getInitialSocPct()
                                                                                                                        !=null
                                                                                                                        ?
                                                                                                                        selectedSession.getInitialSocPct()
                                                                                                                        + "%"
                                                                                                                        : "Unavailable"
                                                                                                                        %>
                                                                                                                </strong>.<br>
                                                                                                                Time-integrated
                                                                                                                using
                                                                                                                discrete
                                                                                                                Coulomb
                                                                                                                counting
                                                                                                                with
                                                                                                                chemistry-specific
                                                                                                                charging
                                                                                                                efficiency.
                                                                                                            </p>
                                                                                                            <span
                                                                                                                class="evidence-status-pill verified">
                                                                                                                Discrete
                                                                                                                Coulomb
                                                                                                                Integration
                                                                                                            </span>
                                                                                                        </div>

                                                                                                        <!-- Card 4: Remaining Useful Life (RUL) -->
                                                                                                        <div
                                                                                                            class="telemetry-card">
                                                                                                            <div
                                                                                                                class="t-card-header">
                                                                                                                <span
                                                                                                                    class="t-icon">⏱️</span>
                                                                                                                <h4>Remaining
                                                                                                                    Useful
                                                                                                                    Life
                                                                                                                    (RUL)
                                                                                                                </h4>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="t-huge-stat">
                                                                                                                <%= selectedSession.getEstimatedRulCycles()
                                                                                                                    !=null
                                                                                                                    ?
                                                                                                                    selectedSession.getEstimatedRulCycles()
                                                                                                                    : "--"
                                                                                                                    %>
                                                                                                                    <span
                                                                                                                        class="unit">
                                                                                                                        cycles</span>
                                                                                                            </div>
                                                                                                            <p
                                                                                                                class="t-desc">
                                                                                                                Estimated
                                                                                                                cycles
                                                                                                                remaining
                                                                                                                before
                                                                                                                reaching
                                                                                                                EOL
                                                                                                                capacity
                                                                                                                threshold
                                                                                                                (70.0% /
                                                                                                                80.0%).<br>
                                                                                                                Forecast
                                                                                                                derived
                                                                                                                from
                                                                                                                cycle-separated
                                                                                                                exponential
                                                                                                                degradation
                                                                                                                regression.
                                                                                                            </p>
                                                                                                            <span
                                                                                                                class="evidence-status-pill unverified">
                                                                                                                Single-Cell
                                                                                                                Academic
                                                                                                                Model
                                                                                                            </span>
                                                                                                        </div>
                                                                                                    </div>

                                                                                                    <!-- Live Telemetry Sensor Metrics Strip -->
                                                                                                    <div class="report-box"
                                                                                                        style="margin-top: 1rem;">
                                                                                                        <h4
                                                                                                            class="box-title">
                                                                                                            Instantaneous
                                                                                                            Sensor
                                                                                                            Readings
                                                                                                            (Null-Safe
                                                                                                            Telemetry
                                                                                                            Audit)</h4>
                                                                                                        <div
                                                                                                            class="charging-info-grid">
                                                                                                            <div
                                                                                                                class="charge-item">
                                                                                                                <span
                                                                                                                    class="c-label">Pack
                                                                                                                    /
                                                                                                                    Cell
                                                                                                                    Voltage:</span>
                                                                                                                <span
                                                                                                                    class="c-val"><strong>
                                                                                                                        <%= currentVoltage
                                                                                                                            !=null
                                                                                                                            ?
                                                                                                                            currentVoltage
                                                                                                                            + " V"
                                                                                                                            : "Unavailable / Sensor Not Reported"
                                                                                                                            %>
                                                                                                                    </strong></span>
                                                                                                                <small
                                                                                                                    class="c-note">Terminal
                                                                                                                    voltage
                                                                                                                    under
                                                                                                                    active
                                                                                                                    load/charge.</small>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="charge-item">
                                                                                                                <span
                                                                                                                    class="c-label">Current
                                                                                                                    Flow:</span>
                                                                                                                <span
                                                                                                                    class="c-val"><strong>
                                                                                                                        <%= currentAmps != null ? currentAmps + " A (" + (currentAmps.doubleValue() > 0 ? "Discharge" : "Charge") + ")" : "Unavailable / Sensor Not Reported" %>
                                                                                                                    </strong></span>
                                                                                                                <small
                                                                                                                    class="c-note">Positive
                                                                                                                    =
                                                                                                                    Discharge,
                                                                                                                    Negative
                                                                                                                    =
                                                                                                                    Charge.</small>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="charge-item">
                                                                                                                <span
                                                                                                                    class="c-label">Battery
                                                                                                                    Temperature:</span>
                                                                                                                <span
                                                                                                                    class="c-val"><strong
                                                                                                                        class="<%= (currentTemp != null && currentTemp.doubleValue() > 45) ? "text-amber" : "text-emerald" %>">
                                                                                                                        <%= currentTemp
                                                                                                                            !=null
                                                                                                                            ?
                                                                                                                            currentTemp
                                                                                                                            + " °C"
                                                                                                                            : "Unavailable / Sensor Not Reported"
                                                                                                                            %>
                                                                                                                    </strong></span>
                                                                                                                <small
                                                                                                                    class="c-note">Chemistry
                                                                                                                    thermal
                                                                                                                    warning:
                                                                                                                    45°C
                                                                                                                    -
                                                                                                                    50°C.</small>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="charge-item">
                                                                                                                <span
                                                                                                                    class="c-label">Module
                                                                                                                    Cell
                                                                                                                    Delta:</span>
                                                                                                                <span
                                                                                                                    class="c-val"><strong
                                                                                                                        class="<%= (currentCellDelta != null && currentCellDelta > 40) ? "text-amber" : "text-emerald" %>">
                                                                                                                        <%= currentCellDelta
                                                                                                                            !=null
                                                                                                                            ?
                                                                                                                            currentCellDelta
                                                                                                                            + " mV"
                                                                                                                            : "Unavailable / Sensor Not Reported"
                                                                                                                            %>
                                                                                                                    </strong></span>
                                                                                                                <small
                                                                                                                    class="c-note">Rejection
                                                                                                                    limit
                                                                                                                    &gt;50
                                                                                                                    mV
                                                                                                                    balance
                                                                                                                    delta.</small>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="charge-item">
                                                                                                                <span
                                                                                                                    class="c-label">Data
                                                                                                                    Origin:</span>
                                                                                                                <span
                                                                                                                    class="c-val"><strong>
                                                                                                                        <%= selectedSession.getSourceType()
                                                                                                                            %>
                                                                                                                    </strong></span>
                                                                                                                <small
                                                                                                                    class="c-note">
                                                                                                                    <%= selectedSession.getCellOrPackIdentifier()
                                                                                                                        %>
                                                                                                                </small>
                                                                                                            </div>
                                                                                                            <div
                                                                                                                class="charge-item">
                                                                                                                <span
                                                                                                                    class="c-label">Verification
                                                                                                                    Status:</span>
                                                                                                                <span
                                                                                                                    class="c-val"><strong>
                                                                                                                        <%= selectedSession.getVerificationStatus()
                                                                                                                            %>
                                                                                                                    </strong></span>
                                                                                                                <small
                                                                                                                    class="c-note">Physical
                                                                                                                    sign-off:
                                                                                                                    <%= selectedSession.isPhysicallyVerified()
                                                                                                                        ? "VERIFIED"
                                                                                                                        : "UNVERIFIED"
                                                                                                                        %>
                                                                                                                </small>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                    </div>

                                                                                                    <!-- Interactive Canvas Charts for Returned Data (No Fake Points) -->
                                                                                                    <% if (readings
                                                                                                        !=null &&
                                                                                                        !readings.isEmpty())
                                                                                                        { %>
                                                                                                        <div class="report-box"
                                                                                                            style="margin-top: 1rem;">
                                                                                                            <h4
                                                                                                                class="box-title">
                                                                                                                📈
                                                                                                                Real-Time
                                                                                                                Battery
                                                                                                                Telemetry
                                                                                                                Visualizations
                                                                                                                (Actual
                                                                                                                Returned
                                                                                                                Data)
                                                                                                            </h4>
                                                                                                            <div
                                                                                                                class="charts-dashboard-grid">
                                                                                                                <div
                                                                                                                    class="chart-tile">
                                                                                                                    <h5>Voltage
                                                                                                                        (V)
                                                                                                                        &amp;
                                                                                                                        Current
                                                                                                                        (A)
                                                                                                                        vs.
                                                                                                                        Time
                                                                                                                    </h5>
                                                                                                                    <canvas
                                                                                                                        id="chart-voltage-current"
                                                                                                                        width="480"
                                                                                                                        height="200"
                                                                                                                        class="battery-canvas"></canvas>
                                                                                                                </div>
                                                                                                                <div
                                                                                                                    class="chart-tile">
                                                                                                                    <h5>Temperature
                                                                                                                        (°C)
                                                                                                                        &amp;
                                                                                                                        Cell
                                                                                                                        Delta
                                                                                                                        (mV)
                                                                                                                        vs.
                                                                                                                        Time
                                                                                                                    </h5>
                                                                                                                    <canvas
                                                                                                                        id="chart-temp-delta"
                                                                                                                        width="480"
                                                                                                                        height="200"
                                                                                                                        class="battery-canvas"></canvas>
                                                                                                                </div>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                        <% } %>

                                                                                                            <!-- Academic ML RUL Limitation Warning -->
                                                                                                            <div class="report-demo-alert"
                                                                                                                style="margin-top: 1.5rem;">
                                                                                                                <div
                                                                                                                    class="alert-icon">
                                                                                                                    ⚠️
                                                                                                                </div>
                                                                                                                <div
                                                                                                                    class="alert-text">
                                                                                                                    <strong>ACADEMIC
                                                                                                                        ML
                                                                                                                        MODEL
                                                                                                                        LIMITATION
                                                                                                                        NOTICE:</strong>
                                                                                                                    RUL
                                                                                                                    prediction
                                                                                                                    models
                                                                                                                    are
                                                                                                                    trained
                                                                                                                    on
                                                                                                                    NASA
                                                                                                                    Ames
                                                                                                                    PCoE
                                                                                                                    experimental
                                                                                                                    18650
                                                                                                                    LiCoO2
                                                                                                                    single-cell
                                                                                                                    laboratory
                                                                                                                    data
                                                                                                                    cycled
                                                                                                                    under
                                                                                                                    static
                                                                                                                    2A
                                                                                                                    discharge
                                                                                                                    at
                                                                                                                    24°C
                                                                                                                    chamber.
                                                                                                                    <strong>This
                                                                                                                        model
                                                                                                                        is
                                                                                                                        NOT
                                                                                                                        validated
                                                                                                                        for
                                                                                                                        commercial
                                                                                                                        multi-cell
                                                                                                                        EV
                                                                                                                        battery
                                                                                                                        packs,
                                                                                                                        complex
                                                                                                                        vehicle
                                                                                                                        thermal
                                                                                                                        loops,
                                                                                                                        or
                                                                                                                        dynamic
                                                                                                                        regenerative
                                                                                                                        road
                                                                                                                        cycles.</strong>
                                                                                                                    Predictions
                                                                                                                    represent
                                                                                                                    academic
                                                                                                                    bench
                                                                                                                    estimations,
                                                                                                                    not
                                                                                                                    commercial
                                                                                                                    vehicle
                                                                                                                    warranty
                                                                                                                    guarantees.
                                                                                                                </div>
                                                                                                            </div>
                                                                                                            <% } %>

                                                                                                                <!-- Recent Analysis Session History Table -->
                                                                                                                <div class="report-box"
                                                                                                                    style="margin-top: 1.5rem;">
                                                                                                                    <h4
                                                                                                                        class="box-title">
                                                                                                                        📋
                                                                                                                        Battery
                                                                                                                        Intelligence
                                                                                                                        Analysis
                                                                                                                        Session
                                                                                                                        History
                                                                                                                    </h4>
                                                                                                                    <% if
                                                                                                                        (sessionHistory
                                                                                                                        !=null
                                                                                                                        &&
                                                                                                                        !sessionHistory.isEmpty())
                                                                                                                        {
                                                                                                                        %>
                                                                                                                        <div
                                                                                                                            class="session-history-table-wrapper">
                                                                                                                            <table
                                                                                                                                class="session-table">
                                                                                                                                <thead>
                                                                                                                                    <tr>
                                                                                                                                        <th>Session
                                                                                                                                            UUID
                                                                                                                                        </th>
                                                                                                                                        <th>Source
                                                                                                                                            Mode
                                                                                                                                        </th>
                                                                                                                                        <th>Chemistry
                                                                                                                                        </th>
                                                                                                                                        <th>Reference
                                                                                                                                            Cap
                                                                                                                                        </th>
                                                                                                                                        <th>Current
                                                                                                                                            Cap
                                                                                                                                        </th>
                                                                                                                                        <th>SOH
                                                                                                                                            (%)
                                                                                                                                        </th>
                                                                                                                                        <th>RUL
                                                                                                                                            (Cycles)
                                                                                                                                        </th>
                                                                                                                                        <th>Status
                                                                                                                                        </th>
                                                                                                                                        <th>Action
                                                                                                                                        </th>
                                                                                                                                    </tr>
                                                                                                                                </thead>
                                                                                                                                <tbody>
                                                                                                                                    <% for
                                                                                                                                        (BatterySession
                                                                                                                                        s
                                                                                                                                        :
                                                                                                                                        sessionHistory)
                                                                                                                                        {
                                                                                                                                        %>
                                                                                                                                        <tr>
                                                                                                                                            <td><strong>
                                                                                                                                                    <%= s.getSessionUuid()
                                                                                                                                                        %>
                                                                                                                                                </strong>
                                                                                                                                            </td>
                                                                                                                                            <td><span
                                                                                                                                                    class="v-chip <%= s.getSourceType().toLowerCase() %>">
                                                                                                                                                    <%= s.getSourceType()
                                                                                                                                                        %>
                                                                                                                                                </span>
                                                                                                                                            </td>
                                                                                                                                            <td>
                                                                                                                                                <%= s.getChemistryProfileId()
                                                                                                                                                    %>
                                                                                                                                            </td>
                                                                                                                                            <td>
                                                                                                                                                <%= s.getFormattedNominalCapacity()
                                                                                                                                                    %>
                                                                                                                                            </td>
                                                                                                                                            <td>
                                                                                                                                                <%= s.getFormattedCurrentCapacity()
                                                                                                                                                    %>
                                                                                                                                            </td>
                                                                                                                                            <td><strong>
                                                                                                                                                    <%= s.getEstimatedSohPct()
                                                                                                                                                        !=null
                                                                                                                                                        ?
                                                                                                                                                        s.getEstimatedSohPct()
                                                                                                                                                        + "%"
                                                                                                                                                        : "--"
                                                                                                                                                        %>
                                                                                                                                                </strong>
                                                                                                                                            </td>
                                                                                                                                            <td>
                                                                                                                                                <%= s.getEstimatedRulCycles()
                                                                                                                                                    !=null
                                                                                                                                                    ?
                                                                                                                                                    s.getEstimatedRulCycles()
                                                                                                                                                    : "--"
                                                                                                                                                    %>
                                                                                                                                            </td>
                                                                                                                                            <td><span
                                                                                                                                                    class="evidence-status-pill <%= s.isPhysicallyVerified() ? "verified" : "unverified" %>">
                                                                                                                                                    <%= s.getVerificationStatus()
                                                                                                                                                        %>
                                                                                                                                                </span>
                                                                                                                                            </td>
                                                                                                                                            <td>
                                                                                                                                                <a href="<%= request.getContextPath() %>/battery-lab?session_id=<%= s.getSessionId() %>"
                                                                                                                                                    class="btn btn-outline btn-sm">
                                                                                                                                                    Inspect
                                                                                                                                                </a>
                                                                                                                                            </td>
                                                                                                                                        </tr>
                                                                                                                                        <% }
                                                                                                                                            %>
                                                                                                                                </tbody>
                                                                                                                            </table>
                                                                                                                        </div>
                                                                                                                        <% } else
                                                                                                                            {
                                                                                                                            %>
                                                                                                                            <p
                                                                                                                                style="color: var(--text-muted); font-size: 0.85rem;">
                                                                                                                                No
                                                                                                                                battery
                                                                                                                                intelligence
                                                                                                                                sessions
                                                                                                                                recorded
                                                                                                                                yet.
                                                                                                                                Run
                                                                                                                                an
                                                                                                                                analysis
                                                                                                                                above.
                                                                                                                            </p>
                                                                                                                            <% }
                                                                                                                                %>
                                                                                                                </div>

                                                                                    </div>

                                                                                    <!-- Bottom Navigation -->
                                                                                    <div
                                                                                        class="report-bottom-nav no-print">
                                                                                        <a href="<%= request.getContextPath() %>/health-report"
                                                                                            class="btn btn-secondary">
                                                                                            &larr; View Vehicle Health
                                                                                            Reports
                                                                                        </a>
                                                                                        <a href="<%= request.getContextPath() %>/vehicles"
                                                                                            class="btn btn-outline">
                                                                                            Browse Verified Marketplace
                                                                                        </a>
                                                                                    </div>
                                                                </div>
                                                            </main>

                                                            <%@ include file="/includes/footer.jsp" %>

                                                                <!-- Client-Side Dynamic Source Tab Switcher & Chart Renderer -->
                                                                <script>
                                                                    function switchSourceTab(source) {
                                                                        document.getElementById('hidden_source_type').value = source;
                                                                        document.querySelectorAll('.source-tab-btn').forEach(b => b.classList.remove('active'));

                                                                        const obdPanel = document.getElementById('obd-warning-panel');
                                                                        const unitSelect = document.getElementById('unit_select');
                                                                        const chemSelect = document.getElementById('chem_select');
                                                                        const nomCapInput = document.getElementById('nom_cap_input');
                                                                        const currCapInput = document.getElementById('curr_cap_input');

                                                                        if (source === 'PUBLIC_DATASET') {
                                                                            document.getElementById('btn-tab-dataset').classList.add('active');
                                                                            obdPanel.style.display = 'none';
                                                                            unitSelect.value = 'AH';
                                                                            chemSelect.value = 'CHEM_NASA_18650';
                                                                            nomCapInput.value = '2.0';
                                                                            currCapInput.value = '1.74';
                                                                            handleChemistryChange('CHEM_NASA_18650');
                                                                        } else if (source === 'LIVE_OBD') {
                                                                            document.getElementById('btn-tab-obd').classList.add('active');
                                                                            obdPanel.style.display = 'block';
                                                                            unitSelect.value = 'KWH';
                                                                            chemSelect.value = 'CHEM_NMC_01';
                                                                            nomCapInput.value = '75.0';
                                                                            currCapInput.value = '71.5';
                                                                            handleChemistryChange('CHEM_NMC_01');
                                                                            pollHardwareTelemetry();
                                                                        } else {
                                                                            document.getElementById('btn-tab-sim').classList.add('active');
                                                                            obdPanel.style.display = 'none';
                                                                            unitSelect.value = 'KWH';
                                                                            chemSelect.value = 'CHEM_NMC_01';
                                                                            nomCapInput.value = '75.0';
                                                                            currCapInput.value = '70.2';
                                                                            handleChemistryChange('CHEM_NMC_01');
                                                                        }
                                                                    }

                                                                    function handleChemistryChange(chemId) {
                                                                        const hint = document.getElementById('chem_hint');
                                                                        if (chemId === 'CHEM_LFP_01') {
                                                                            hint.textContent = 'Nominal: 3.2V, Cutoff: 2.5V, Max: 3.65V. Flat OCV plateau limits resting OCV accuracy between 20-80% SOC.';
                                                                        } else if (chemId === 'CHEM_NASA_18650') {
                                                                            hint.textContent = 'NASA PCoE 18650 benchmark cell: 2.0 Ah, 2.7V cutoff, 4.2V max. Academic laboratory test protocol.';
                                                                        } else if (chemId === 'CHEM_NCA_01') {
                                                                            hint.textContent = 'Nominal: 3.65V, Cutoff: 3.0V, Max: 4.2V. High energy density passenger EV chemistry.';
                                                                        } else {
                                                                            hint.textContent = 'Nominal: 3.7V, Cutoff: 3.0V, Max: 4.2V. Automotive standard NMC chemistry.';
                                                                        }
                                                                    }

                                                                    // ---------------------------------------------------------------------
                                                                    // Hardware Diagnostic Adapter Client Controls
                                                                    // ---------------------------------------------------------------------
                                                                    function connectHardwareAdapter() {
                                                                        const adapterType = document.getElementById('hw-adapter-type').value;
                                                                        const profileId = document.getElementById('hw-profile-id').value;
                                                                        const uri = adapterType === 'MOCK_CAN' ? 'slcan0' : 'COM3';

                                                                        const logBox = document.getElementById('raw-terminal-log');
                                                                        logBox.innerHTML += '\n[CONNECTING] Negotiating connection with ' + adapterType + ' on ' + uri + '...';

                                                                        fetch('<%= request.getContextPath() %>/api/battery/hardware/connect', {
                                                                            method: 'POST',
                                                                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                                                            body: 'adapter_type=' + encodeURIComponent(adapterType) + '&profile_id=' + encodeURIComponent(profileId) + '&uri=' + encodeURIComponent(uri)
                                                                        })
                                                                            .then(res => res.json())
                                                                            .then(data => {
                                                                                if (data.is_connected) {
                                                                                    updateHardwareUI(data);
                                                                                    logBox.innerHTML += '\n[CONNECTED] Handshake complete: ' + data.device_id + '. VIN: ' + (data.vin || 'Unread / Mode 09 unauthenticated');
                                                                                    pollHardwareTelemetry();
                                                                                } else {
                                                                                    document.getElementById('hw-status-badge').className = 'live-adapter-badge error';
                                                                                    document.getElementById('hw-status-text').textContent = 'ERROR';
                                                                                    logBox.innerHTML += '\n[ERROR] Connection failed: ' + (data.last_error || 'No response');
                                                                                }
                                                                                logBox.scrollTop = logBox.scrollHeight;
                                                                            })
                                                                            .catch(err => {
                                                                                logBox.innerHTML += '\n[NETWORK ERROR] Could not reach BatteryIQ API: ' + err;
                                                                            });
                                                                    }

                                                                    function disconnectHardwareAdapter() {
                                                                        const logBox = document.getElementById('raw-terminal-log');
                                                                        logBox.innerHTML += '\n[DISCONNECT] Terminating adapter connection...';

                                                                        fetch('<%= request.getContextPath() %>/api/battery/hardware/disconnect', { method: 'POST' })
                                                                            .then(res => res.json())
                                                                            .then(() => {
                                                                                document.getElementById('hw-status-badge').className = 'live-adapter-badge disconnected';
                                                                                document.getElementById('hw-status-text').textContent = 'DISCONNECTED';
                                                                                document.getElementById('btn-hw-connect').style.display = 'inline-block';
                                                                                document.getElementById('btn-hw-disconnect').style.display = 'none';
                                                                                document.getElementById('btn-hw-poll').style.display = 'none';
                                                                                logBox.innerHTML += '\n[HAL] Adapter offline. Awaiting physical or mock interface.';
                                                                                logBox.scrollTop = logBox.scrollHeight;
                                                                            });
                                                                    }

                                                                    function pollHardwareTelemetry() {
                                                                        fetch('<%= request.getContextPath() %>/api/battery/hardware/status')
                                                                            .then(res => res.json())
                                                                            .then(data => {
                                                                                updateHardwareUI(data);
                                                                            });
                                                                    }

                                                                    function updateHardwareUI(data) {
                                                                        const badge = document.getElementById('hw-status-badge');
                                                                        const statusText = document.getElementById('hw-status-text');
                                                                        const connBtn = document.getElementById('btn-hw-connect');
                                                                        const disconnBtn = document.getElementById('btn-hw-disconnect');
                                                                        const pollBtn = document.getElementById('btn-hw-poll');
                                                                        const logBox = document.getElementById('raw-terminal-log');

                                                                        const status = (data.connection_status || 'DISCONNECTED').toLowerCase();
                                                                        badge.className = 'live-adapter-badge ' + status;
                                                                        statusText.textContent = data.connection_status || 'DISCONNECTED';

                                                                        if (data.is_connected) {
                                                                            connBtn.style.display = 'none';
                                                                            disconnBtn.style.display = 'inline-block';
                                                                            pollBtn.style.display = 'inline-block';
                                                                        } else {
                                                                            connBtn.style.display = 'inline-block';
                                                                            disconnBtn.style.display = 'none';
                                                                            pollBtn.style.display = 'none';
                                                                        }

                                                                        if (data.latest_packet) {
                                                                            const lp = data.latest_packet;
                                                                            document.getElementById('g-voltage').innerHTML = (lp.voltage_volts !== null ? lp.voltage_volts : '--') + '<span class="unit">V</span>';
                                                                            document.getElementById('g-current').innerHTML = (lp.current_amps !== null ? lp.current_amps : '--') + '<span class="unit">A</span>';
                                                                            document.getElementById('g-soc').innerHTML = (lp.soc_percentage !== null ? lp.soc_percentage : '--') + '<span class="unit">%</span>';
                                                                            document.getElementById('g-temp').innerHTML = (lp.temperature_celsius !== null ? lp.temperature_celsius : '--') + '<span class="unit">°C</span>';
                                                                            document.getElementById('g-power').innerHTML = (lp.active_power_kw !== null ? lp.active_power_kw : '--') + '<span class="unit">kW</span>';
                                                                            document.getElementById('g-delta').innerHTML = (lp.cell_delta_mv !== null ? lp.cell_delta_mv + '<span class="unit">mV</span>' : '<span style="color:#94a3b8">N/A</span>');

                                                                            if (lp.raw_logs && lp.raw_logs.length > 0) {
                                                                                lp.raw_logs.forEach(function (l) {
                                                                                    logBox.innerHTML += '\n' + l;
                                                                                });
                                                                                logBox.scrollTop = logBox.scrollHeight;
                                                                            }
                                                                        }
                                                                    }

                                                                    function applyHardwareFault(fault) {
                                                                        const logBox = document.getElementById('raw-terminal-log');
                                                                        const notice = document.getElementById('fault-notice');
                                                                        notice.textContent = 'Simulated fault: ' + fault;

                                                                        fetch('<%= request.getContextPath() %>/api/battery/hardware/fault', {
                                                                            method: 'POST',
                                                                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                                                            body: 'fault_type=' + encodeURIComponent(fault)
                                                                        })
                                                                            .then(res => res.json())
                                                                            .then(() => {
                                                                                logBox.innerHTML += '\n[FAULT HARNESS] Injected fault condition: ' + fault;
                                                                                pollHardwareTelemetry();
                                                                                setTimeout(() => { notice.textContent = ''; }, 4000);
                                                                            });
                                                                    }


                                                                    // Render Canvas Charts from Real Returned Readings (No invented points)
                                                                    document.addEventListener('DOMContentLoaded', function () {
            <% if (readings != null && !readings.isEmpty()) { %>
                                                                            renderTelemetryCharts();
            <% } %>
        });

                                                                    function renderTelemetryCharts() {
                                                                        const readingsData = [
                <% for (int i = 0; i < readings.size(); i++) {
                    BatteryTelemetryPoint p = readings.get(i); %>
                                                                            {
                                                                                t: <%= p.getTimestampOffsetMs() %>,
                                                                                v: <%= p.getVoltageVolts() != null ? p.getVoltageVolts() : "null" %>,
                                                                                i: <%= p.getCurrentAmps() != null ? p.getCurrentAmps() : "null" %>,
                                                                                temp: <%= p.getTemperatureCelsius() != null ? p.getTemperatureCelsius() : "null" %>,
                                                                                delta: <%= p.getCellDeltaMv() != null ? p.getCellDeltaMv() : "null" %>
                    } <%= (i < readings.size() - 1) ? "," : "" %>
                <% } %>
            ];

                                                                        // Chart 1: Voltage & Current
                                                                        drawCanvasChart('chart-voltage-current', readingsData, 'v', 'i', 'Voltage (V)', 'Current (A)', '#0284c7', '#f59e0b');
                                                                        // Chart 2: Temp & Delta
                                                                        drawCanvasChart('chart-temp-delta', readingsData, 'temp', 'delta', 'Temperature (°C)', 'Cell Delta (mV)', '#10b981', '#ef4444');
                                                                    }

                                                                    function drawCanvasChart(canvasId, data, key1, key2, label1, label2, color1, color2) {
                                                                        const canvas = document.getElementById(canvasId);
                                                                        if (!canvas) return;
                                                                        const ctx = canvas.getContext('2d');
                                                                        const w = canvas.width;
                                                                        const h = canvas.height;
                                                                        const padding = 35;

                                                                        ctx.clearRect(0, 0, w, h);
                                                                        ctx.fillStyle = '#ffffff';
                                                                        ctx.fillRect(0, 0, w, h);

                                                                        // Draw grid lines
                                                                        ctx.strokeStyle = '#e2e8f0';
                                                                        ctx.lineWidth = 1;
                                                                        for (let y = padding; y <= h - padding; y += 30) {
                                                                            ctx.beginPath();
                                                                            ctx.moveTo(padding, y);
                                                                            ctx.lineTo(w - padding, y);
                                                                            ctx.stroke();
                                                                        }

                                                                        // Extract valid points for series 1
                                                                        const pts1 = data.filter(d => d[key1] !== null);
                                                                        if (pts1.length > 1) {
                                                                            const minVal = Math.min(...pts1.map(d => d[key1]));
                                                                            const maxVal = Math.max(...pts1.map(d => d[key1]));
                                                                            const range = (maxVal - minVal) || 1;

                                                                            ctx.strokeStyle = color1;
                                                                            ctx.lineWidth = 2.5;
                                                                            ctx.beginPath();
                                                                            pts1.forEach((pt, idx) => {
                                                                                const x = padding + (idx / (pts1.length - 1)) * (w - 2 * padding);
                                                                                const y = h - padding - ((pt[key1] - minVal) / range) * (h - 2 * padding);
                                                                                if (idx === 0) ctx.moveTo(x, y);
                                                                                else ctx.lineTo(x, y);
                                                                            });
                                                                            ctx.stroke();
                                                                        }

                                                                        // Legend
                                                                        ctx.font = '10px sans-serif';
                                                                        ctx.fillStyle = color1;
                                                                        ctx.fillRect(padding, 12, 10, 10);
                                                                        ctx.fillText(label1, padding + 15, 20);

                                                                        ctx.fillStyle = color2;
                                                                        ctx.fillRect(padding + 120, 12, 10, 10);
                                                                        ctx.fillText(label2, padding + 135, 20);
                                                                    }
                                                                </script>
                                                    </body>

                                                    </html>