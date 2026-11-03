<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.batteryiq.model.Vehicle" %>
            <%@ page import="com.batteryiq.model.VehicleHealthReport" %>
                <%@ page import="com.batteryiq.model.VehicleHealthReport.EvidenceStatus" %>
                    <%@ page import="com.batteryiq.dao.VehicleDAO" %>
                        <%!
public String renderStatusBadge(EvidenceStatus status, String verifiedText) {
    if (status == null) { status = EvidenceStatus.UNVERIFIED; }
    switch (status) {
        case VERIFIED:
            return "<span class=\"evidence-status-pill verified\"><svg width=\"12\" height=\"12\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"3\"><polyline points=\"20 6 9 17 4 12\"></polyline></svg> " + verifiedText + "</span>";
        case UNVERIFIED:
            return "<span class=\"evidence-status-pill unverified\"><svg width=\"12\" height=\"12\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2.5\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><line x1=\"12\" y1=\"16\" x2=\"12\" y2=\"12\"></line><line x1=\"12\" y1=\"8\" x2=\"12.01\" y2=\"8\"></line></svg> Seller Reported (Unverified)</span>";
        case MISSING:
            return "<span class=\"evidence-status-pill missing\"><svg width=\"12\" height=\"12\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2.5\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><line x1=\"15\" y1=\"9\" x2=\"9\" y2=\"15\"></line><line x1=\"9\" y1=\"9\" x2=\"15\" y2=\"15\"></line></svg> Evidence Missing / Not Tested</span>";
        case PENDING_INSPECTION:
        default:
            return "<span class=\"evidence-status-pill pending\"><svg width=\"12\" height=\"12\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2.5\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><polyline points=\"12 6 12 12 16 14\"></polyline></svg> Inspection Pending</span>";
    }
}
%>
                            <% Vehicle vehicle=(Vehicle) request.getAttribute("vehicle"); VehicleHealthReport
                                report=(VehicleHealthReport) request.getAttribute("report");
                                @SuppressWarnings("unchecked") List<Vehicle> allVehicles = (List<Vehicle>)
                                    request.getAttribute("allVehicles");

                                    if (allVehicles == null) {
                                    VehicleDAO vDao = new VehicleDAO();
                                    allVehicles = vDao.getAllVehicles();
                                    }

                                    if (vehicle == null && allVehicles != null && !allVehicles.isEmpty()) {
                                    vehicle = allVehicles.get(0);
                                    if (vehicle != null) {
                                    report = vehicle.getHealthReport();
                                    }
                                    }

                                    boolean isPending = (report == null || report.isPendingInspection() ||
                                    (report.getOverallGrade() != null &&
                                    report.getOverallGrade().equalsIgnoreCase("Pending")));
                                    boolean isEv = (vehicle != null && vehicle.isElectric()) || (report != null &&
                                    report.isEvReport());
                                    boolean isDiesel = (vehicle != null && vehicle.getFuelType() != null &&
                                    vehicle.getFuelType().equalsIgnoreCase("DIESEL"));
                                    boolean isPetrol = (vehicle != null && vehicle.getFuelType() != null &&
                                    vehicle.getFuelType().equalsIgnoreCase("PETROL"));
                                    boolean isTwoWheeler = (vehicle != null && (vehicle.isBike() ||
                                    vehicle.isScooter()));
                                    %>
                                    <!DOCTYPE html>
                                    <html lang="en">

                                    <head>
                                        <meta charset="UTF-8">
                                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                        <title>BatteryIQ Certified Vehicle Health Report - <%= vehicle !=null ?
                                                vehicle.getDisplayName() : "Diagnostics" %>
                                        </title>
                                        <meta name="description"
                                            content="Official BatteryIQ Health Report with verified State of Health (SoH), engine compression, and transparent evidence audit.">
                                        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
                                        <link rel="icon"
                                            href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📋</text></svg>">
                                    </head>

                                    <body class="report-body">

                                        <%@ include file="/includes/header.jsp" %>

                                            <main class="page-container">
                                                <!-- Certificate Quick Switcher Bar -->
                                                <div class="report-lookup-strip no-print">
                                                    <div class="container lookup-strip-inner">
                                                        <div class="lookup-strip-title">
                                                            <span class="report-live-dot"></span>
                                                            <span>BatteryIQ Telematics Diagnostic Center</span>
                                                        </div>
                                                        <form action="<%= request.getContextPath() %>/health-report"
                                                            method="get" class="lookup-form">
                                                            <label for="report-cert-input">Select Vehicle to View Health
                                                                Report:</label>
                                                            <select id="report-cert-input"
                                                                onchange="window.location.href='<%= request.getContextPath() %>/health-report?id=' + this.value">
                                                                <% if (allVehicles !=null) { for (Vehicle v :
                                                                    allVehicles) { boolean isSelected=(vehicle !=null &&
                                                                    vehicle.getVehicleId()==v.getVehicleId());
                                                                    VehicleHealthReport vr=v.getHealthReport(); String
                                                                    summaryTag="Pending Inspection" ; if (vr !=null &&
                                                                    !vr.isPendingInspection() &&
                                                                    !"Pending".equalsIgnoreCase(vr.getOverallGrade())) {
                                                                    if (v.isElectric()) {
                                                                    summaryTag=vr.getSohPercentage() + "% SoH &bull; " +
                                                                    vr.getOverallGrade(); } else {
                                                                    summaryTag=vr.getEngineHealthScore()
                                                                    + "/100 Engine &bull; " + vr.getOverallGrade(); } }
                                                                    %>
                                                                    <option value="<%= v.getVehicleId() %>"
                                                                        <%=isSelected ? "selected" : "" %>>
                                                                        [<%= v.getCategory() %> &bull; <%=
                                                                                v.getFuelType() %>] <%=
                                                                                    v.getDisplayName() %> (<%=
                                                                                        summaryTag %>)
                                                                    </option>
                                                                    <% } } %>
                                                            </select>
                                                        </form>
                                                        <button type="button" class="btn btn-outline btn-sm"
                                                            onclick="window.print()">
                                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                                stroke="currentColor" stroke-width="2">
                                                                <polyline points="6 9 6 2 18 2 18 9"></polyline>
                                                                <path
                                                                    d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2">
                                                                </path>
                                                                <rect x="6" y="14" width="12" height="8"></rect>
                                                            </svg>
                                                            Print Certificate
                                                        </button>
                                                    </div>
                                                </div>

                                                <div class="container report-document-wrapper">
                                                    <!-- Simulated Demo Notice Alert Inside Report -->
                                                    <div class="report-demo-alert">
                                                        <div class="alert-icon">⚠️</div>
                                                        <div class="alert-text">
                                                            <strong>DEMO DATASET &bull; SYNTHETIC DIAGNOSTIC
                                                                TELEMETRY:</strong>
                                                            This vehicle health report is part of the BatteryIQ
                                                            demonstration catalog. BatteryIQ strictly prohibits
                                                            presenting simulated values as real physical measurements.
                                                            Where diagnostic tests have not been executed on physical
                                                            hardware, statuses are transparently flagged as <em>Seller
                                                                Reported (Unverified)</em>, <em>Missing</em>, or
                                                            <em>Inspection Pending</em>.
                                                        </div>
                                                    </div>

                                                    <!-- The Official Certificate Container -->
                                                    <div class="official-certificate-sheet">
                                                        <!-- Certificate Top Header -->
                                                        <div class="cert-header">
                                                            <div class="cert-logo-block">
                                                                <div class="cert-logo-icon">🔋</div>
                                                                <div>
                                                                    <h2 class="cert-brand-title">Battery<span>IQ</span>
                                                                    </h2>
                                                                    <span class="cert-brand-sub">Certified Automotive
                                                                        Health &amp; Diagnostics Lab</span>
                                                                </div>
                                                            </div>

                                                            <div class="cert-stamp-block">
                                                                <% if (!isPending) { %>
                                                                    <div class="cert-grade-seal seal-<%= (report.getOverallGrade() != null) ? report.getOverallGrade().replace("+", "plus").toLowerCase() : "a" %>">
                                                                        <span class="seal-grade">
                                                                            <%= report.getOverallGrade() !=null ?
                                                                                report.getOverallGrade() : "A" %>
                                                                        </span>
                                                                        <span class="seal-text">CERTIFIED</span>
                                                                    </div>
                                                                    <div class="cert-code-group">
                                                                        <span class="code-label">Certificate ID:</span>
                                                                        <span class="code-val">
                                                                            <%= report.getCertificateCode() !=null ?
                                                                                report.getCertificateCode()
                                                                                : "BIQ-CERT-0000" %>
                                                                        </span>
                                                                        <span class="code-date">Inspected: <%=
                                                                                report.getVerifiedDate() !=null ?
                                                                                report.getVerifiedDate() : "Verified" %>
                                                                        </span>
                                                                    </div>
                                                                    <% } else { %>
                                                                        <div class="cert-grade-seal seal-pending">
                                                                            <span class="seal-grade">PENDING</span>
                                                                            <span class="seal-text">UNINSPECTED</span>
                                                                        </div>
                                                                        <div class="cert-code-group">
                                                                            <span class="code-label">Certificate
                                                                                Status:</span>
                                                                            <span
                                                                                class="code-val">BIQ-PENDING-REG</span>
                                                                            <span class="code-date">Awaiting Lab
                                                                                Diagnostic</span>
                                                                        </div>
                                                                        <% } %>
                                                            </div>
                                                        </div>

                                                        <!-- Vehicle Identification Banner -->
                                                        <div class="cert-vehicle-banner">
                                                            <div class="cert-v-img">
                                                                <img src="<%= vehicle != null ? vehicle.getThumbnailUrl() : "" %>"
                                                                    alt="Vehicle image">
                                                            </div>
                                                            <div class="cert-v-details">
                                                                <div class="v-category-chips">
                                                                    <span class="v-chip">
                                                                        <%= vehicle !=null ? vehicle.getCategory()
                                                                            : "CAR" %>
                                                                    </span>
                                                                    <span
                                                                        class="v-chip <%= vehicle != null ? vehicle.getFuelType().toLowerCase() : "" %>">
                                                                        <%= vehicle !=null ? vehicle.getFuelType()
                                                                            : "ELECTRIC" %>
                                                                    </span>
                                                                    <span class="v-chip">
                                                                        <%= vehicle !=null ? vehicle.getConditionType()
                                                                            : "USED" %>
                                                                    </span>
                                                                </div>
                                                                <h1 class="v-title">
                                                                    <%= vehicle !=null ? vehicle.getDisplayName()
                                                                        : "Vehicle" %>
                                                                </h1>
                                                                <p class="v-trim">
                                                                    <%= vehicle !=null ? vehicle.getVariantTrim() : ""
                                                                        %> &bull; Location: <%= vehicle !=null ?
                                                                            vehicle.getLocationCity() : "" %>
                                                                </p>
                                                                <div class="v-specs-summary">
                                                                    <span>Odometer: <strong>
                                                                            <%= vehicle !=null ?
                                                                                vehicle.getFormattedOdometer() : "0 km"
                                                                                %>
                                                                        </strong></span>
                                                                    <span>Transmission: <strong>
                                                                            <%= vehicle !=null ?
                                                                                vehicle.getTransmission() : "" %>
                                                                        </strong></span>
                                                                    <span>Inspector: <strong>
                                                                            <%= (report !=null && !isPending &&
                                                                                report.getVerifiedByInspector() !=null)
                                                                                ? report.getVerifiedByInspector()
                                                                                : "Awaiting Inspector Assignment" %>
                                                                        </strong></span>
                                                                </div>
                                                            </div>
                                                            <div class="cert-score-box">
                                                                <% if (!isPending) { %>
                                                                    <div class="score-circle">
                                                                        <span class="score-val">
                                                                            <%= report.getOverallScore() %>
                                                                        </span>
                                                                        <span class="score-max">/100</span>
                                                                    </div>
                                                                    <div class="score-caption">Overall Trust Score</div>
                                                                    <% } else { %>
                                                                        <div class="score-circle pending">
                                                                            <span class="score-val">--</span>
                                                                            <span class="score-max">/100</span>
                                                                        </div>
                                                                        <div class="score-caption">Score Pending</div>
                                                                        <% } %>
                                                            </div>
                                                        </div>

                                                        <!-- ============================================================= -->
                                                        <!-- SCENARIO 1: INSPECTION PENDING (NO INVENTED DATA)              -->
                                                        <!-- ============================================================= -->
                                                        <% if (isPending) { %>
                                                            <div class="pending-inspection-container">
                                                                <div class="pending-inspection-header">
                                                                    <span class="pending-badge">
                                                                        <svg width="14" height="14" viewBox="0 0 24 24"
                                                                            fill="none" stroke="currentColor"
                                                                            stroke-width="2.5">
                                                                            <circle cx="12" cy="12" r="10"></circle>
                                                                            <polyline points="12 6 12 12 16 14">
                                                                            </polyline>
                                                                        </svg>
                                                                        Lab Inspection Pending
                                                                    </span>
                                                                    <h2 class="pending-title">No Physical Inspection
                                                                        Completed Yet</h2>
                                                                    <p class="pending-desc">
                                                                        This vehicle is actively listed in the
                                                                        marketplace, but has not yet undergone
                                                                        BatteryIQ's certified hardware diagnostic
                                                                        protocol.
                                                                        <strong>BatteryIQ policy strictly forbids
                                                                            inventing diagnostic metrics</strong>.
                                                                        Diagnostic telemetry cards and overall health
                                                                        scores are only published once physical
                                                                        inspection evidence is gathered.
                                                                    </p>
                                                                </div>

                                                                <h4
                                                                    style="font-size: 1.05rem; font-weight: 800; color: var(--dark-900); margin-bottom: 1rem;">
                                                                    Required Inspections For This <%= vehicle !=null ?
                                                                        (vehicle.getFuelType() + " " +
                                                                        vehicle.getCategory()) : "Vehicle" %>:
                                                                </h4>

                                                                <div class="pending-tests-grid">
                                                                    <% if (isEv) { %>
                                                                        <div class="pending-test-card">
                                                                            <div class="pending-test-num">1</div>
                                                                            <div class="pending-test-info">
                                                                                <h5>High-Voltage Battery SoH &amp;
                                                                                    Capacity Test</h5>
                                                                                <p>Electrochemical Coulometric test
                                                                                    measuring usable kWh retention
                                                                                    against original factory
                                                                                    specification.</p>
                                                                            </div>
                                                                        </div>
                                                                        <div class="pending-test-card">
                                                                            <div class="pending-test-num">2</div>
                                                                            <div class="pending-test-info">
                                                                                <h5>BMS CAN-Bus Cell Voltage Delta</h5>
                                                                                <p>Module level millivolt variance
                                                                                    inspection under a simulated 100A
                                                                                    peak discharge load.</p>
                                                                            </div>
                                                                        </div>
                                                                        <div class="pending-test-card">
                                                                            <div class="pending-test-num">3</div>
                                                                            <div class="pending-test-info">
                                                                                <h5>Thermal Conditioning &amp;
                                                                                    Fast-Charge Cycle</h5>
                                                                                <p>Active liquid coolant flow audit and
                                                                                    DC high-rate charge dissipation
                                                                                    profiling.</p>
                                                                            </div>
                                                                        </div>
                                                                        <div class="pending-test-card">
                                                                            <div class="pending-test-num">4</div>
                                                                            <div class="pending-test-info">
                                                                                <h5>Dynamometer Range Certification</h5>
                                                                                <p>Calibrated highway and urban energy
                                                                                    consumption per 100 km at standard
                                                                                    ambient temperatures.</p>
                                                                            </div>
                                                                        </div>
                                                                        <% if (isTwoWheeler) { %>
                                                                            <div class="pending-test-card">
                                                                                <div class="pending-test-num">5</div>
                                                                                <div class="pending-test-info">
                                                                                    <h5>2-Wheeler Swappable Lock &amp;
                                                                                        Drive Belt/Chain</h5>
                                                                                    <p>Chassis battery locking
                                                                                        mechanism, IP67 terminal seal,
                                                                                        and drive belt/chain tension
                                                                                        audit.</p>
                                                                                </div>
                                                                            </div>
                                                                            <% } %>
                                                                                <% } else if (isDiesel) { %>
                                                                                    <div class="pending-test-card">
                                                                                        <div class="pending-test-num">1
                                                                                        </div>
                                                                                        <div class="pending-test-info">
                                                                                            <h5>DPF Soot Load &amp;
                                                                                                Regeneration
                                                                                                Differential</h5>
                                                                                            <p>Exhaust particulate
                                                                                                filter backpressure
                                                                                                transducer audit and ash
                                                                                                accumulation measurement
                                                                                                (grams).</p>
                                                                                        </div>
                                                                                    </div>
                                                                                    <div class="pending-test-card">
                                                                                        <div class="pending-test-num">2
                                                                                        </div>
                                                                                        <div class="pending-test-info">
                                                                                            <h5>Common-Rail Fuel Rail
                                                                                                Pressure Test</h5>
                                                                                            <p>High-pressure fuel
                                                                                                injection rail delivery
                                                                                                test across varying RPM
                                                                                                bands (up to 2000+ bar).
                                                                                            </p>
                                                                                        </div>
                                                                                    </div>
                                                                                    <div class="pending-test-card">
                                                                                        <div class="pending-test-num">3
                                                                                        </div>
                                                                                        <div class="pending-test-info">
                                                                                            <h5>DEF / AdBlue &amp; SCR
                                                                                                NOx Catalyst
                                                                                                Verification</h5>
                                                                                            <p>Selective Catalytic
                                                                                                Reduction urea dosing
                                                                                                health and downstream
                                                                                                NOx sensor calibration
                                                                                                scan.</p>
                                                                                        </div>
                                                                                    </div>
                                                                                    <div class="pending-test-card">
                                                                                        <div class="pending-test-num">4
                                                                                        </div>
                                                                                        <div class="pending-test-info">
                                                                                            <h5>Cylinder Compression
                                                                                                &amp; Glow Plug
                                                                                                Resistance</h5>
                                                                                            <p>High-compression
                                                                                                cold-cranking barometric
                                                                                                pressure parity across
                                                                                                all combustion chambers.
                                                                                            </p>
                                                                                        </div>
                                                                                    </div>
                                                                                    <div class="pending-test-card">
                                                                                        <div class="pending-test-num">5
                                                                                        </div>
                                                                                        <div class="pending-test-info">
                                                                                            <h5>ECU Odometer &amp;
                                                                                                Service Registry
                                                                                                Cross-Check</h5>
                                                                                            <p>Cross-referencing
                                                                                                transmission and ABS
                                                                                                module operating hours
                                                                                                against cluster mileage.
                                                                                            </p>
                                                                                        </div>
                                                                                    </div>
                                                                                    <% } else { %>
                                                                                        <div class="pending-test-card">
                                                                                            <div
                                                                                                class="pending-test-num">
                                                                                                1</div>
                                                                                            <div
                                                                                                class="pending-test-info">
                                                                                                <h5>Combustion Chamber
                                                                                                    Compression Test
                                                                                                </h5>
                                                                                                <p>Physical barometric
                                                                                                    pressure test
                                                                                                    measuring ring seal
                                                                                                    and intake/exhaust
                                                                                                    valve seating.</p>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="pending-test-card">
                                                                                            <div
                                                                                                class="pending-test-num">
                                                                                                2</div>
                                                                                            <div
                                                                                                class="pending-test-info">
                                                                                                <h5>Spark Plugs &amp;
                                                                                                    Catalytic Converter
                                                                                                    O2 Lambda</h5>
                                                                                                <p>Ignition coil spark
                                                                                                    discharge, fuel trim
                                                                                                    percentages, and
                                                                                                    exhaust gas oxygen
                                                                                                    sensor response
                                                                                                    rate.</p>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="pending-test-card">
                                                                                            <div
                                                                                                class="pending-test-num">
                                                                                                3</div>
                                                                                            <div
                                                                                                class="pending-test-info">
                                                                                                <h5>ECU Odometer Tamper
                                                                                                    Verification</h5>
                                                                                                <p>Deep scan of engine
                                                                                                    operating hours
                                                                                                    stored inside EEPROM
                                                                                                    memory versus
                                                                                                    instrument cluster
                                                                                                    display.</p>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="pending-test-card">
                                                                                            <div
                                                                                                class="pending-test-num">
                                                                                                4</div>
                                                                                            <div
                                                                                                class="pending-test-info">
                                                                                                <h5>Full OBD-II
                                                                                                    Diagnostic Trouble
                                                                                                    Code Scan</h5>
                                                                                                <p>CAN-bus query of
                                                                                                    Powertrain (P),
                                                                                                    Chassis (C), Body
                                                                                                    (B), and Network (U)
                                                                                                    diagnostic error
                                                                                                    codes.</p>
                                                                                            </div>
                                                                                        </div>
                                                                                        <% if (isTwoWheeler) { %>
                                                                                            <div
                                                                                                class="pending-test-card">
                                                                                                <div
                                                                                                    class="pending-test-num">
                                                                                                    5</div>
                                                                                                <div
                                                                                                    class="pending-test-info">
                                                                                                    <h5>Drive Chain /
                                                                                                        Belt &amp; Wet
                                                                                                        Clutch / CVT
                                                                                                        Check</h5>
                                                                                                    <p>Inspection of
                                                                                                        drive sprocket
                                                                                                        pitch wear,
                                                                                                        chain link
                                                                                                        binding, and
                                                                                                        friction plate
                                                                                                        engagement under
                                                                                                        load.</p>
                                                                                                </div>
                                                                                            </div>
                                                                                            <% } %>
                                                                                                <% } %>
                                                                </div>

                                                                <div class="pending-cta-row">
                                                                    <a href="<%= request.getContextPath() %>/sell"
                                                                        class="btn btn-primary">
                                                                        Schedule Official BatteryIQ Inspection
                                                                    </a>
                                                                    <a href="<%= request.getContextPath() %>/vehicle?id=<%= vehicle != null ? vehicle.getVehicleId() : 1 %>"
                                                                        class="btn btn-outline">
                                                                        View Vehicle Listing &amp; Photos
                                                                    </a>
                                                                </div>
                                                            </div>

                                                            <!-- ============================================================= -->
                                                            <!-- SCENARIO 2: ELECTRIC VEHICLE (EV) VERIFIED / AUDITED REPORT   -->
                                                            <!-- ============================================================= -->
                                                            <% } else if (isEv) { %>
                                                                <div class="report-section-container ev-report-theme">
                                                                    <div class="report-section-title-bar">
                                                                        <h3>⚡ Electric Vehicle Battery State of Health
                                                                            (SoH) Diagnostics</h3>
                                                                        <span class="theme-tag">EV Diagnostic
                                                                            Suite</span>
                                                                    </div>

                                                                    <!-- 4 Core Battery Telemetry Cards -->
                                                                    <div class="telemetry-grid">
                                                                        <!-- Metric 1: Battery SoH -->
                                                                        <div class="telemetry-card highlight-card">
                                                                            <div class="t-card-header">
                                                                                <span class="t-icon">🔋</span>
                                                                                <h4>State of Health (SoH)</h4>
                                                                            </div>
                                                                            <div class="t-huge-stat">
                                                                                <%= report.getSohPercentage() %><span
                                                                                        class="unit">%</span>
                                                                            </div>
                                                                            <div class="t-progress-bar">
                                                                                <div class="t-progress-fill"
                                                                                    style="width: <%= report.getSohPercentage() %>%;">
                                                                                </div>
                                                                            </div>
                                                                            <p class="t-desc">
                                                                                Electrochemical retention capacity.
                                                                                Tested against factory
                                                                                <strong>
                                                                                    <%= report.getOriginalCapacityKwh()
                                                                                        !=null ?
                                                                                        report.getOriginalCapacityKwh()
                                                                                        + " kWh" : "pack" %>
                                                                                </strong>.
                                                                                Usable remaining: <strong>
                                                                                    <%= report.getUsableCapacityKwh() %>
                                                                                        kWh
                                                                                </strong>.
                                                                            </p>
                                                                            <%= renderStatusBadge(report.getSohStatus(), "Verified Lab Telemetry"
                                                                                ) %>
                                                                        </div>

                                                                        <!-- Metric 2: Battery Degradation Rate -->
                                                                        <div class="telemetry-card">
                                                                            <div class="t-card-header">
                                                                                <span class="t-icon">📉</span>
                                                                                <h4>Annual Degradation</h4>
                                                                            </div>
                                                                            <div class="t-huge-stat">
                                                                                <%= report.getDegradationRatePerYear()
                                                                                    %><span class="unit">%/yr</span>
                                                                            </div>
                                                                            <div class="degrade-meter">
                                                                                <span class="degrade-benchmark">Industry
                                                                                    Average: ~1.9%/yr</span>
                                                                            </div>
                                                                            <p class="t-desc">
                                                                                Observed cycle count: <strong>
                                                                                    <%= report.getCycleCount() %> cycles
                                                                                </strong>. Degradation rate conforms to
                                                                                healthy cell longevity models.
                                                                            </p>
                                                                            <%= renderStatusBadge(report.getSohStatus(), "Verified Cycle Log"
                                                                                ) %>
                                                                        </div>

                                                                        <!-- Metric 3: Reported vs Real-World Range -->
                                                                        <div class="telemetry-card">
                                                                            <div class="t-card-header">
                                                                                <span class="t-icon">🛣️</span>
                                                                                <h4>Tested Real-World Range</h4>
                                                                            </div>
                                                                            <div class="t-huge-stat">
                                                                                <%= report.getEstimatedRealRangeKm() %>
                                                                                    <span class="unit">km</span>
                                                                            </div>
                                                                            <div class="range-compare-row">
                                                                                <span>Certified WLTP: <strong>
                                                                                        <%= report.getOriginalRangeKm()
                                                                                            %> km
                                                                                    </strong></span>
                                                                                <span class="delta-pct">Retention: <%=
                                                                                        Math.round(((double)report.getEstimatedRealRangeKm()
                                                                                        / (report.getOriginalRangeKm()>
                                                                                        0 ? report.getOriginalRangeKm()
                                                                                        : 1)) * 100) %>%</span>
                                                                            </div>
                                                                            <p class="t-desc">
                                                                                Real-world highway &amp; urban simulated
                                                                                load test at 22°C ambient temperature.
                                                                            </p>
                                                                            <%= renderStatusBadge(report.getRangeStatus(), "Dynamometer Tested"
                                                                                ) %>
                                                                        </div>

                                                                        <!-- Metric 4: Cell Voltage Deviation -->
                                                                        <div class="telemetry-card">
                                                                            <div class="t-card-header">
                                                                                <span class="t-icon">⚡</span>
                                                                                <h4>Cell Module Voltage Delta</h4>
                                                                            </div>
                                                                            <div class="t-huge-stat">
                                                                                <%= report.getCellDeviationMv() %><span
                                                                                        class="unit">mV</span>
                                                                            </div>
                                                                            <div class="delta-meter">
                                                                                <span
                                                                                    class="status-chip <%= report.getCellDeviationMv() < 20 ? "excellent" : "good" %>">
                                                                                    <%= report.getCellDeviationMv() < 20
                                                                                        ? "Optimal Module Balance"
                                                                                        : "Normal Delta" %>
                                                                                </span>
                                                                            </div>
                                                                            <p class="t-desc">
                                                                                Maximum voltage disparity across all
                                                                                cell strings under 100A load. Rejection
                                                                                limit: &gt;25 mV.
                                                                            </p>
                                                                            <%= renderStatusBadge(report.getCellDeviationStatus(), "BMS CAN-Bus Verified"
                                                                                ) %>
                                                                        </div>
                                                                    </div>

                                                                    <!-- Charging & Thermal Health Information -->
                                                                    <div class="report-box">
                                                                        <h4 class="box-title">Charging Behavior &amp;
                                                                            Thermal Management</h4>
                                                                        <div class="charging-info-grid">
                                                                            <div class="charge-item">
                                                                                <span class="c-label">DC Fast Charge
                                                                                    Exposure:</span>
                                                                                <span class="c-val"><strong>
                                                                                        <%= report.getFastChargeRatioPct()
                                                                                            %>%
                                                                                    </strong> of total energy
                                                                                    intake</span>
                                                                                <small class="c-note">Lower fast charge
                                                                                    frequency preserves lithium
                                                                                    electrode structure.</small>
                                                                            </div>
                                                                            <div class="charge-item">
                                                                                <span class="c-label">Thermal Stress
                                                                                    Grade:</span>
                                                                                <span class="c-val"><strong
                                                                                        class="text-emerald">
                                                                                        <%= report.getThermalStressGrade()
                                                                                            !=null ?
                                                                                            report.getThermalStressGrade()
                                                                                            : "NOMINAL" %>
                                                                                    </strong></span>
                                                                                <small class="c-note">Active liquid
                                                                                    conditioning kept pack temps within
                                                                                    21°C - 34°C.</small>
                                                                            </div>
                                                                            <div class="charge-item">
                                                                                <span class="c-label">Onboard AC
                                                                                    Charger:</span>
                                                                                <span class="c-val">
                                                                                    <%= report.getChargingHealthSummary()
                                                                                        !=null ?
                                                                                        report.getChargingHealthSummary()
                                                                                        : "Tested and operational" %>
                                                                                </span>
                                                                                <small class="c-note">Inverter
                                                                                    efficiency and phase parity
                                                                                    verified.</small>
                                                                            </div>
                                                                        </div>
                                                                    </div>

                                                                    <!-- Two-Wheeler Specific Checks (For Electric Bikes and Scooters Only) -->
                                                                    <% if (isTwoWheeler) { %>
                                                                        <div class="report-box two-wheeler-box">
                                                                            <h4 class="box-title">🛵 2-Wheeler Electric
                                                                                Inspection Points</h4>
                                                                            <div class="two-wheeler-grid">
                                                                                <div class="tw-check-item">
                                                                                    <span class="tw-lbl">Final Drive
                                                                                        &amp; Belt/Chain:</span>
                                                                                    <strong>
                                                                                        <%= report.getTwoWheelerDriveType()
                                                                                            !=null ?
                                                                                            report.getTwoWheelerDriveType()
                                                                                            : "Drive System" %>
                                                                                            (<%= report.getTwoWheelerDriveCondition()
                                                                                                !=null ?
                                                                                                report.getTwoWheelerDriveCondition()
                                                                                                : "VERIFIED" %>)
                                                                                    </strong>
                                                                                    <p>
                                                                                        <%= report.getTwoWheelerClutchOrBelt()
                                                                                            !=null ?
                                                                                            report.getTwoWheelerClutchOrBelt()
                                                                                            : "Drive tension and sprocket alignment checked."
                                                                                            %>
                                                                                    </p>
                                                                                    <%= renderStatusBadge(report.getTwoWheelerDriveStatus(), "Physical Drive Audit"
                                                                                        ) %>
                                                                                </div>
                                                                                <div class="tw-check-item">
                                                                                    <span class="tw-lbl">Battery
                                                                                        Architecture &amp; Locking
                                                                                        Mechanism:</span>
                                                                                    <strong>
                                                                                        <%= report.isRemovableBattery()
                                                                                            ? "Swappable Battery System"
                                                                                            : "Fixed Structural Pack" %>
                                                                                    </strong>
                                                                                    <p>
                                                                                        <%= report.getBatteryLockerCondition()
                                                                                            !=null ?
                                                                                            report.getBatteryLockerCondition()
                                                                                            : "Battery tray seals and IP67 weather connectors verified."
                                                                                            %>
                                                                                    </p>
                                                                                    <%= renderStatusBadge(report.getSohStatus(), "Chassis Enclosure Check"
                                                                                        ) %>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                        <% } %>

                                                                            <!-- Abnormal Warning Indicators -->
                                                                            <div class="report-box warnings-box">
                                                                                <h4 class="box-title">Abnormal Warning
                                                                                    Indicators &amp; BMS History</h4>
                                                                                <% if (report.getAbnormalWarnings()
                                                                                    !=null &&
                                                                                    !report.getAbnormalWarnings().isEmpty())
                                                                                    { %>
                                                                                    <ul class="warning-list">
                                                                                        <% for (String w :
                                                                                            report.getAbnormalWarnings())
                                                                                            { %>
                                                                                            <li class="warning-item">
                                                                                                <svg width="16"
                                                                                                    height="16"
                                                                                                    viewBox="0 0 24 24"
                                                                                                    fill="none"
                                                                                                    stroke="#10b981"
                                                                                                    stroke-width="2.5">
                                                                                                    <polyline
                                                                                                        points="20 6 9 17 4 12">
                                                                                                    </polyline>
                                                                                                </svg>
                                                                                                <span>
                                                                                                    <%= w %>
                                                                                                </span>
                                                                                            </li>
                                                                                            <% } %>
                                                                                    </ul>
                                                                                    <% } else { %>
                                                                                        <div class="clean-status">
                                                                                            <svg width="20" height="20"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="#10b981"
                                                                                                stroke-width="2.5">
                                                                                                <circle cx="12" cy="12"
                                                                                                    r="10"></circle>
                                                                                                <polyline
                                                                                                    points="12 6 12 12 16 14">
                                                                                                </polyline>
                                                                                            </svg>
                                                                                            <span>Zero critical BMS
                                                                                                faults, isolation
                                                                                                alerts, or abnormal cell
                                                                                                temperatures logged in
                                                                                                vehicle history.</span>
                                                                                        </div>
                                                                                        <% } %>
                                                                            </div>
                                                                </div>

                                                                <!-- ============================================================= -->
                                                                <!-- SCENARIO 3: INTERNAL COMBUSTION ENGINE (PETROL & DIESEL)      -->
                                                                <!-- ============================================================= -->
                                                                <% } else { %>
                                                                    <div
                                                                        class="report-section-container ice-report-theme">
                                                                        <div class="report-section-title-bar">
                                                                            <h3>
                                                                                <%= isDiesel
                                                                                    ? "🛢️ Diesel Engine &amp; Exhaust Aftertreatment Diagnostics"
                                                                                    : "⛽ Petrol Engine Mechanical &amp; Compression Diagnostics"
                                                                                    %>
                                                                            </h3>
                                                                            <span class="theme-tag <%= isDiesel ? "diesel" : "ice" %>"><%= isDiesel
                                                                                    ? "Diesel Diagnostic Suite"
                                                                                    : "Petrol Diagnostic Suite" %>
                                                                            </span>
                                                                        </div>

                                                                        <!-- 4 Core Engine Telemetry Cards -->
                                                                        <div class="telemetry-grid">
                                                                            <!-- Metric 1: Engine Health Score -->
                                                                            <div
                                                                                class="telemetry-card highlight-card ice">
                                                                                <div class="t-card-header">
                                                                                    <span class="t-icon">⚙️</span>
                                                                                    <h4>Engine Health Score</h4>
                                                                                </div>
                                                                                <div class="t-huge-stat">
                                                                                    <%= report.getEngineHealthScore() %>
                                                                                        <span class="unit">/100</span>
                                                                                </div>
                                                                                <div class="t-progress-bar">
                                                                                    <div class="t-progress-fill ice"
                                                                                        style="width: <%= report.getEngineHealthScore() %>%;">
                                                                                    </div>
                                                                                </div>
                                                                                <p class="t-desc">
                                                                                    Composite index derived from
                                                                                    cylinder compression, vacuum
                                                                                    stability, acoustic sensor profiles,
                                                                                    and sensor tolerances.
                                                                                </p>
                                                                                <%= renderStatusBadge(report.getEngineHealthStatus(), "Verified Mechanical Audit"
                                                                                    ) %>
                                                                            </div>

                                                                            <!-- Metric 2: Cylinder Compression -->
                                                                            <div class="telemetry-card">
                                                                                <div class="t-card-header">
                                                                                    <span class="t-icon">🔬</span>
                                                                                    <h4>Cylinder Compression</h4>
                                                                                </div>
                                                                                <div class="t-stat-label">Pressure
                                                                                    Equilibrium</div>
                                                                                <div class="t-medium-stat">
                                                                                    <%= report.getCompressionTestResult()
                                                                                        !=null ?
                                                                                        report.getCompressionTestResult()
                                                                                        : "Equilibrium within 3% tolerance"
                                                                                        %>
                                                                                </div>
                                                                                <p class="t-desc">
                                                                                    Consistent compression across
                                                                                    cylinders confirms tight ring seals
                                                                                    and nominal intake/exhaust valve
                                                                                    seating.
                                                                                </p>
                                                                                <%= renderStatusBadge(report.getCompressionStatus(), "Pressure Gauge Certified"
                                                                                    ) %>
                                                                            </div>

                                                                            <!-- Metric 3: Odometer Reading & Tamper Verification -->
                                                                            <div class="telemetry-card">
                                                                                <div class="t-card-header">
                                                                                    <span class="t-icon">⏱️</span>
                                                                                    <h4>Odometer Verification</h4>
                                                                                </div>
                                                                                <div class="t-stat-label">Odometer
                                                                                    Status</div>
                                                                                <div class="t-medium-stat text-emerald">
                                                                                    <%= report.isOdometerTamperingSuspected()
                                                                                        ? "SUSPICIOUS"
                                                                                        : "VERIFIED AUTHENTIC" %>
                                                                                </div>
                                                                                <p class="t-desc">
                                                                                    Cluster reading <strong>
                                                                                        <%= vehicle !=null ?
                                                                                            vehicle.getFormattedOdometer()
                                                                                            : "0 km" %>
                                                                                    </strong> verified against ECU
                                                                                    engine operating hours and digital
                                                                                    log history.
                                                                                </p>
                                                                                <%= renderStatusBadge(report.getOdometerStatus(), "Cross-ECU Verified"
                                                                                    ) %>
                                                                            </div>

                                                                            <!-- Metric 4: Service History Audit -->
                                                                            <div class="telemetry-card">
                                                                                <div class="t-card-header">
                                                                                    <span class="t-icon">📖</span>
                                                                                    <h4>Service History Audit</h4>
                                                                                </div>
                                                                                <div class="t-stat-label">Documented
                                                                                    Service Events</div>
                                                                                <div class="t-huge-stat">
                                                                                    <%= report.getDocumentedServiceCount()
                                                                                        %><span class="unit">
                                                                                            Logs</span>
                                                                                </div>
                                                                                <p class="t-desc">
                                                                                    Status: <strong>
                                                                                        <%= report.getServiceHistoryStatus()
                                                                                            !=null ?
                                                                                            report.getServiceHistoryStatus()
                                                                                            : "Documented" %>
                                                                                    </strong>. Records verified from
                                                                                    authorized dealer service networks.
                                                                                </p>
                                                                                <%= renderStatusBadge(report.getOdometerStatus(), "Digital Dealer Records"
                                                                                    ) %>
                                                                            </div>
                                                                        </div>

                                                                        <!-- DIESEL-SPECIFIC TELEMATICS (Only shown if vehicle is Diesel) -->
                                                                        <% if (isDiesel) { %>
                                                                            <div class="report-box diesel-box">
                                                                                <h4 class="box-title">🛢️ Diesel
                                                                                    Injection &amp; Exhaust
                                                                                    Aftertreatment System</h4>
                                                                                <div class="diesel-grid">
                                                                                    <div class="diesel-item">
                                                                                        <span class="c-label">DPF Status
                                                                                            &amp; Soot:</span>
                                                                                        <span class="c-val"><strong>
                                                                                                <%= report.getDpfStatus()
                                                                                                    !=null ?
                                                                                                    report.getDpfStatus()
                                                                                                    : "NORMAL" %>
                                                                                            </strong> (<%=
                                                                                                report.getDpfSootLoadGrams()
                                                                                                %>g)</span>
                                                                                        <small class="c-note">Soot
                                                                                            accumulation well below
                                                                                            regeneration threshold (max
                                                                                            45g).</small>
                                                                                        <%= renderStatusBadge(report.getDpfEvidenceStatus(), "DPF Pressure Differential"
                                                                                            ) %>
                                                                                    </div>
                                                                                    <div class="diesel-item">
                                                                                        <span class="c-label">Common
                                                                                            Rail Pressure:</span>
                                                                                        <span class="c-val"><strong>
                                                                                                <%= (report.getCommonRailPressureBar() > 0 ? report.getCommonRailPressureBar() + " Bar" : "1800 Bar") %>
                                                                                            </strong></span>
                                                                                        <small class="c-note">High
                                                                                            pressure pump delivery and
                                                                                            injector return leak
                                                                                            nominal.</small>
                                                                                        <%= renderStatusBadge(report.getCommonRailStatus(), "Rail Transducer Scan"
                                                                                            ) %>
                                                                                    </div>
                                                                                    <div class="diesel-item">
                                                                                        <span class="c-label">DEF /
                                                                                            AdBlue Fluid:</span>
                                                                                        <span class="c-val"><strong
                                                                                                class="text-emerald">
                                                                                                <%= report.getAdBlueDefStatus()
                                                                                                    !=null ?
                                                                                                    report.getAdBlueDefStatus()
                                                                                                    : "FULL / OPERATIONAL"
                                                                                                    %>
                                                                                            </strong></span>
                                                                                        <small class="c-note">SCR NOx
                                                                                            catalyst reduction
                                                                                            efficiency within legal
                                                                                            limits.</small>
                                                                                        <%= renderStatusBadge(report.getAdBlueStatus(), "Urea Level Sensor"
                                                                                            ) %>
                                                                                    </div>
                                                                                    <div class="diesel-item">
                                                                                        <span class="c-label">Glow Plug
                                                                                            Pre-Heat:</span>
                                                                                        <span class="c-val"><strong>
                                                                                                <%= report.getGlowPlugStatus()
                                                                                                    !=null ?
                                                                                                    report.getGlowPlugStatus()
                                                                                                    : "OPTIMAL" %>
                                                                                            </strong></span>
                                                                                        <small
                                                                                            class="c-note">Pre-heating
                                                                                            resistance balanced across
                                                                                            all cylinders.</small>
                                                                                        <%= renderStatusBadge(report.getCommonRailStatus(), "Resistance Relay Test"
                                                                                            ) %>
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                            <% } %>

                                                                                <!-- PETROL-SPECIFIC TELEMATICS (Only shown if vehicle is Petrol) -->
                                                                                <% if (isPetrol) { %>
                                                                                    <div class="report-box petrol-box">
                                                                                        <h4 class="box-title">⛽ Petrol
                                                                                            Ignition &amp; Emissions
                                                                                            Subsystems</h4>
                                                                                        <div class="petrol-grid">
                                                                                            <div class="mech-item">
                                                                                                <span
                                                                                                    class="m-label">Spark
                                                                                                    Plug &amp; Ignition
                                                                                                    Coils:</span>
                                                                                                <span
                                                                                                    class="m-val"><strong>
                                                                                                        <%= report.getSparkPlugCondition()
                                                                                                            !=null ?
                                                                                                            report.getSparkPlugCondition()
                                                                                                            : "EXCELLENT"
                                                                                                            %>
                                                                                                    </strong></span>
                                                                                                <small>Electrode gap
                                                                                                    nominal; uniform
                                                                                                    secondary ignition
                                                                                                    coil firing
                                                                                                    voltage.</small>
                                                                                                <%= renderStatusBadge(report.getEngineHealthStatus(), "Ignition Scope Test"
                                                                                                    ) %>
                                                                                            </div>
                                                                                            <div class="mech-item">
                                                                                                <span
                                                                                                    class="m-label">Catalytic
                                                                                                    Converter &amp; O2
                                                                                                    Lambda:</span>
                                                                                                <span
                                                                                                    class="m-val text-emerald"><strong>
                                                                                                        <%= report.getCatalyticConverterO2Status()
                                                                                                            !=null ?
                                                                                                            report.getCatalyticConverterO2Status()
                                                                                                            : "OPTIMAL (99.2% Conversion)"
                                                                                                            %>
                                                                                                    </strong></span>
                                                                                                <small>Upstream/downstream
                                                                                                    oxygen sensor delta
                                                                                                    indicates active
                                                                                                    catalytic
                                                                                                    honeycomb.</small>
                                                                                                <%= renderStatusBadge(report.getEngineHealthStatus(), "Exhaust Gas Lambda Scan"
                                                                                                    ) %>
                                                                                            </div>
                                                                                        </div>
                                                                                    </div>
                                                                                    <% } %>

                                                                                        <!-- Mechanical Inspection Findings -->
                                                                                        <div class="report-box">
                                                                                            <h4 class="box-title">
                                                                                                Mechanical &amp;
                                                                                                Environmental Fluid
                                                                                                Audit</h4>
                                                                                            <div
                                                                                                class="mechanical-findings-grid">
                                                                                                <div class="mech-item">
                                                                                                    <span
                                                                                                        class="m-label">Engine
                                                                                                        Oil
                                                                                                        Condition:</span>
                                                                                                    <span
                                                                                                        class="m-val text-emerald"><strong>
                                                                                                            <%= report.getOilConditionGrade()
                                                                                                                !=null ?
                                                                                                                report.getOilConditionGrade()
                                                                                                                : "GOOD"
                                                                                                                %>
                                                                                                        </strong></span>
                                                                                                    <small>Viscosity
                                                                                                        nominal; zero
                                                                                                        metal
                                                                                                        particulate or
                                                                                                        coolant
                                                                                                        dilution.</small>
                                                                                                    <%= renderStatusBadge(report.getOilStatus(), "Oil Spectrometry"
                                                                                                        ) %>
                                                                                                </div>
                                                                                                <div class="mech-item">
                                                                                                    <span
                                                                                                        class="m-label">Transmission
                                                                                                        /
                                                                                                        Gearbox:</span>
                                                                                                    <span
                                                                                                        class="m-val"><strong>
                                                                                                            <%= report.getTransmissionCondition()
                                                                                                                !=null ?
                                                                                                                report.getTransmissionCondition()
                                                                                                                : "SMOOTH"
                                                                                                                %>
                                                                                                        </strong></span>
                                                                                                    <small>Fluid clarity
                                                                                                        verified; zero
                                                                                                        clutch slip or
                                                                                                        gear hunting
                                                                                                        observed.</small>
                                                                                                </div>
                                                                                                <div class="mech-item">
                                                                                                    <span
                                                                                                        class="m-label">Cooling
                                                                                                        System
                                                                                                        Pressure:</span>
                                                                                                    <span class="m-val">
                                                                                                        <%= report.getCoolingSystemHealth()
                                                                                                            !=null ?
                                                                                                            report.getCoolingSystemHealth()
                                                                                                            : "Nominal pressure retention"
                                                                                                            %>
                                                                                                    </span>
                                                                                                    <small>Radiator cap
                                                                                                        and expansion
                                                                                                        tank held 1.1
                                                                                                        bar static
                                                                                                        pressure.</small>
                                                                                                </div>
                                                                                            </div>
                                                                                        </div>

                                                                                        <!-- Two-Wheeler Petrol Specific Points -->
                                                                                        <% if (isTwoWheeler) { %>
                                                                                            <div
                                                                                                class="report-box two-wheeler-box">
                                                                                                <h4 class="box-title">
                                                                                                    🏍️ 2-Wheeler Engine
                                                                                                    &amp; Final Drive
                                                                                                    Audit</h4>
                                                                                                <div
                                                                                                    class="two-wheeler-grid">
                                                                                                    <div
                                                                                                        class="tw-check-item">
                                                                                                        <span
                                                                                                            class="tw-lbl">Final
                                                                                                            Drive:</span>
                                                                                                        <strong>
                                                                                                            <%= report.getTwoWheelerDriveType()
                                                                                                                !=null ?
                                                                                                                report.getTwoWheelerDriveType()
                                                                                                                : "Chain Drive"
                                                                                                                %>
                                                                                                                (<%= report.getTwoWheelerDriveCondition()
                                                                                                                    !=null
                                                                                                                    ?
                                                                                                                    report.getTwoWheelerDriveCondition()
                                                                                                                    : "GOOD"
                                                                                                                    %>)
                                                                                                        </strong>
                                                                                                        <p>Drive chain
                                                                                                            pitch,
                                                                                                            sprocket
                                                                                                            teeth
                                                                                                            profile, and
                                                                                                            slack
                                                                                                            tension
                                                                                                            inspected
                                                                                                            under load.
                                                                                                        </p>
                                                                                                        <%= renderStatusBadge(report.getTwoWheelerDriveStatus(), "Drive Tension Test"
                                                                                                            ) %>
                                                                                                    </div>
                                                                                                    <div
                                                                                                        class="tw-check-item">
                                                                                                        <span
                                                                                                            class="tw-lbl">Clutch
                                                                                                            / CVT
                                                                                                            System:</span>
                                                                                                        <strong>
                                                                                                            <%= report.getTwoWheelerClutchOrBelt()
                                                                                                                !=null ?
                                                                                                                report.getTwoWheelerClutchOrBelt()
                                                                                                                : "Wet Multiplate Clutch / CVT Nominal"
                                                                                                                %>
                                                                                                        </strong>
                                                                                                        <p>Clutch bite
                                                                                                            point,
                                                                                                            free-play
                                                                                                            cable
                                                                                                            tension, and
                                                                                                            plate
                                                                                                            engagement
                                                                                                            tested.</p>
                                                                                                        <%= renderStatusBadge(report.getTwoWheelerDriveStatus(), "Clutch Bite Inspection"
                                                                                                            ) %>
                                                                                                    </div>
                                                                                                </div>
                                                                                            </div>
                                                                                            <% } %>

                                                                                                <!-- Diagnostic Fault Codes (OBD-II DTCs) -->
                                                                                                <div
                                                                                                    class="report-box warnings-box">
                                                                                                    <h4
                                                                                                        class="box-title">
                                                                                                        Diagnostic
                                                                                                        Trouble Codes
                                                                                                        (OBD-II DTC
                                                                                                        Scan)</h4>
                                                                                                    <div class="obd-status-bar"
                                                                                                        style="margin-bottom: 0.8rem;">
                                                                                                        <span>Scan
                                                                                                            Status:
                                                                                                            <strong
                                                                                                                class="text-emerald">
                                                                                                                <%= report.getObdScanStatus()
                                                                                                                    !=null
                                                                                                                    ?
                                                                                                                    report.getObdScanStatus()
                                                                                                                    : "SCAN COMPLETE - CLEAN"
                                                                                                                    %>
                                                                                                            </strong></span>
                                                                                                        <%= renderStatusBadge(report.getObdScanStatus(), "OBD-II Port Scan"
                                                                                                            ) %>
                                                                                                    </div>
                                                                                                    <ul
                                                                                                        class="warning-list">
                                                                                                        <% if
                                                                                                            (report.getObdDtcCodes()
                                                                                                            !=null &&
                                                                                                            !report.getObdDtcCodes().isEmpty())
                                                                                                            { %>
                                                                                                            <% for
                                                                                                                (String
                                                                                                                dtc :
                                                                                                                report.getObdDtcCodes())
                                                                                                                { %>
                                                                                                                <li
                                                                                                                    class="warning-item">
                                                                                                                    <svg width="16"
                                                                                                                        height="16"
                                                                                                                        viewBox="0 0 24 24"
                                                                                                                        fill="none"
                                                                                                                        stroke="#10b981"
                                                                                                                        stroke-width="2.5">
                                                                                                                        <polyline
                                                                                                                            points="20 6 9 17 4 12">
                                                                                                                        </polyline>
                                                                                                                    </svg>
                                                                                                                    <span>
                                                                                                                        <%= dtc
                                                                                                                            %>
                                                                                                                    </span>
                                                                                                                </li>
                                                                                                                <% } %>
                                                                                                                    <% } else
                                                                                                                        {
                                                                                                                        %>
                                                                                                                        <li
                                                                                                                            class="warning-item">
                                                                                                                            <svg width="16"
                                                                                                                                height="16"
                                                                                                                                viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="#10b981"
                                                                                                                                stroke-width="2.5">
                                                                                                                                <polyline
                                                                                                                                    points="20 6 9 17 4 12">
                                                                                                                                </polyline>
                                                                                                                            </svg>
                                                                                                                            <span>No
                                                                                                                                Active,
                                                                                                                                Pending,
                                                                                                                                or
                                                                                                                                Historic
                                                                                                                                Fault
                                                                                                                                Codes
                                                                                                                                stored
                                                                                                                                in
                                                                                                                                ECU
                                                                                                                                memory.</span>
                                                                                                                        </li>
                                                                                                                        <% }
                                                                                                                            %>
                                                                                                    </ul>
                                                                                                </div>
                                                                    </div>
                                                                    <% } %>

                                                                        <!-- ============================================================= -->
                                                                        <!-- C. TRANSPARENCY AUDIT: VERIFIED VS UNVERIFIED VS MISSING       -->
                                                                        <!-- ============================================================= -->
                                                                        <div class="evidence-audit-section">
                                                                            <h3 class="evidence-main-title">
                                                                                🔍 BatteryIQ Evidence &amp; Verification
                                                                                Transparency Audit
                                                                            </h3>
                                                                            <p class="evidence-subtext">
                                                                                BatteryIQ never conceals missing or
                                                                                unverified information. Below is the
                                                                                itemized breakdown of what was
                                                                                physically verified by technicians, what
                                                                                was self-reported by the seller, and
                                                                                what evidence is absent:
                                                                            </p>

                                                                            <div class="evidence-columns-grid">
                                                                                <!-- 1. Verified Evidence -->
                                                                                <div class="evidence-col verified-col">
                                                                                    <div class="e-header">
                                                                                        <span
                                                                                            class="e-badge-icon verified">✓</span>
                                                                                        <div>
                                                                                            <h4>Physically Verified</h4>
                                                                                            <small>Confirmed with lab
                                                                                                test hardware</small>
                                                                                        </div>
                                                                                    </div>
                                                                                    <ul class="evidence-list">
                                                                                        <% if (!isPending && report
                                                                                            !=null &&
                                                                                            report.getVerifiedItems()
                                                                                            !=null &&
                                                                                            !report.getVerifiedItems().isEmpty())
                                                                                            { %>
                                                                                            <% for (String vi :
                                                                                                report.getVerifiedItems())
                                                                                                { %>
                                                                                                <li
                                                                                                    class="e-item verified-item">
                                                                                                    <svg width="14"
                                                                                                        height="14"
                                                                                                        viewBox="0 0 24 24"
                                                                                                        fill="none"
                                                                                                        stroke="#10b981"
                                                                                                        stroke-width="3">
                                                                                                        <polyline
                                                                                                            points="20 6 9 17 4 12">
                                                                                                        </polyline>
                                                                                                    </svg>
                                                                                                    <span>
                                                                                                        <%= vi %>
                                                                                                    </span>
                                                                                                </li>
                                                                                                <% } %>
                                                                                                    <% } else { %>
                                                                                                        <li
                                                                                                            class="e-item empty-item">
                                                                                                            No physical
                                                                                                            tests
                                                                                                            completed
                                                                                                            yet.
                                                                                                            Telemetry
                                                                                                            pending lab
                                                                                                            inspection.
                                                                                                        </li>
                                                                                                        <% } %>
                                                                                    </ul>
                                                                                </div>

                                                                                <!-- 2. Unverified Evidence -->
                                                                                <div
                                                                                    class="evidence-col unverified-col">
                                                                                    <div class="e-header">
                                                                                        <span
                                                                                            class="e-badge-icon unverified">?</span>
                                                                                        <div>
                                                                                            <h4>Unverified Items</h4>
                                                                                            <small>Seller reported
                                                                                                without physical
                                                                                                proof</small>
                                                                                        </div>
                                                                                    </div>
                                                                                    <ul class="evidence-list">
                                                                                        <% if (report !=null &&
                                                                                            report.getUnverifiedItems()
                                                                                            !=null &&
                                                                                            !report.getUnverifiedItems().isEmpty())
                                                                                            { %>
                                                                                            <% for (String ui :
                                                                                                report.getUnverifiedItems())
                                                                                                { %>
                                                                                                <li
                                                                                                    class="e-item unverified-item">
                                                                                                    <svg width="14"
                                                                                                        height="14"
                                                                                                        viewBox="0 0 24 24"
                                                                                                        fill="none"
                                                                                                        stroke="#f59e0b"
                                                                                                        stroke-width="3">
                                                                                                        <circle cx="12"
                                                                                                            cy="12"
                                                                                                            r="10">
                                                                                                        </circle>
                                                                                                        <line x1="12"
                                                                                                            y1="16"
                                                                                                            x2="12"
                                                                                                            y2="12">
                                                                                                        </line>
                                                                                                        <line x1="12"
                                                                                                            y1="8"
                                                                                                            x2="12.01"
                                                                                                            y2="8">
                                                                                                        </line>
                                                                                                    </svg>
                                                                                                    <span>
                                                                                                        <%= ui %>
                                                                                                    </span>
                                                                                                </li>
                                                                                                <% } %>
                                                                                                    <% } else if
                                                                                                        (isPending) { %>
                                                                                                        <li
                                                                                                            class="e-item unverified-item">
                                                                                                            <svg width="14"
                                                                                                                height="14"
                                                                                                                viewBox="0 0 24 24"
                                                                                                                fill="none"
                                                                                                                stroke="#f59e0b"
                                                                                                                stroke-width="3">
                                                                                                                <circle
                                                                                                                    cx="12"
                                                                                                                    cy="12"
                                                                                                                    r="10">
                                                                                                                </circle>
                                                                                                                <line
                                                                                                                    x1="12"
                                                                                                                    y1="16"
                                                                                                                    x2="12"
                                                                                                                    y2="12">
                                                                                                                </line>
                                                                                                                <line
                                                                                                                    x1="12"
                                                                                                                    y1="8"
                                                                                                                    x2="12.01"
                                                                                                                    y2="8">
                                                                                                                </line>
                                                                                                            </svg>
                                                                                                            <span>Seller-declared
                                                                                                                listing
                                                                                                                details
                                                                                                                and
                                                                                                                odometer
                                                                                                                reading.</span>
                                                                                                        </li>
                                                                                                        <% } else { %>
                                                                                                            <li
                                                                                                                class="e-item empty-item">
                                                                                                                Zero
                                                                                                                unverified
                                                                                                                claims.
                                                                                                                All
                                                                                                                listed
                                                                                                                metrics
                                                                                                                backed
                                                                                                                by test
                                                                                                                logs.
                                                                                                            </li>
                                                                                                            <% } %>
                                                                                    </ul>
                                                                                </div>

                                                                                <!-- 3. Missing Evidence -->
                                                                                <div class="evidence-col missing-col">
                                                                                    <div class="e-header">
                                                                                        <span
                                                                                            class="e-badge-icon missing">✕</span>
                                                                                        <div>
                                                                                            <h4>Missing Evidence</h4>
                                                                                            <small>Unprovided logs or
                                                                                                unavailable
                                                                                                tests</small>
                                                                                        </div>
                                                                                    </div>
                                                                                    <ul class="evidence-list">
                                                                                        <% if (report !=null &&
                                                                                            report.getMissingEvidence()
                                                                                            !=null &&
                                                                                            !report.getMissingEvidence().isEmpty())
                                                                                            { %>
                                                                                            <% for (String mi :
                                                                                                report.getMissingEvidence())
                                                                                                { %>
                                                                                                <li
                                                                                                    class="e-item missing-item">
                                                                                                    <svg width="14"
                                                                                                        height="14"
                                                                                                        viewBox="0 0 24 24"
                                                                                                        fill="none"
                                                                                                        stroke="#ef4444"
                                                                                                        stroke-width="3">
                                                                                                        <circle cx="12"
                                                                                                            cy="12"
                                                                                                            r="10">
                                                                                                        </circle>
                                                                                                        <line x1="15"
                                                                                                            y1="9"
                                                                                                            x2="9"
                                                                                                            y2="15">
                                                                                                        </line>
                                                                                                        <line x1="9"
                                                                                                            y1="9"
                                                                                                            x2="15"
                                                                                                            y2="15">
                                                                                                        </line>
                                                                                                    </svg>
                                                                                                    <span>
                                                                                                        <%= mi %>
                                                                                                    </span>
                                                                                                </li>
                                                                                                <% } %>
                                                                                                    <% } else if
                                                                                                        (isPending) { %>
                                                                                                        <li
                                                                                                            class="e-item missing-item">
                                                                                                            <svg width="14"
                                                                                                                height="14"
                                                                                                                viewBox="0 0 24 24"
                                                                                                                fill="none"
                                                                                                                stroke="#ef4444"
                                                                                                                stroke-width="3">
                                                                                                                <circle
                                                                                                                    cx="12"
                                                                                                                    cy="12"
                                                                                                                    r="10">
                                                                                                                </circle>
                                                                                                                <line
                                                                                                                    x1="15"
                                                                                                                    y1="9"
                                                                                                                    x2="9"
                                                                                                                    y2="15">
                                                                                                                </line>
                                                                                                                <line
                                                                                                                    x1="9"
                                                                                                                    y1="9"
                                                                                                                    x2="15"
                                                                                                                    y2="15">
                                                                                                                </line>
                                                                                                            </svg>
                                                                                                            <span>Certified
                                                                                                                Physical
                                                                                                                Hardware
                                                                                                                Lab
                                                                                                                Inspection
                                                                                                                Not Yet
                                                                                                                Conducted.</span>
                                                                                                        </li>
                                                                                                        <% } else { %>
                                                                                                            <li
                                                                                                                class="e-item empty-item">
                                                                                                                No
                                                                                                                missing
                                                                                                                records
                                                                                                                flagged
                                                                                                                during
                                                                                                                inspection.
                                                                                                            </li>
                                                                                                            <% } %>
                                                                                    </ul>
                                                                                </div>
                                                                            </div>
                                                                        </div>

                                                                        <!-- Recommended Additional Tests -->
                                                                        <% if (report !=null &&
                                                                            report.getRecommendedTests() !=null &&
                                                                            !report.getRecommendedTests().isEmpty()) {
                                                                            %>
                                                                            <div class="recommended-tests-box">
                                                                                <h4>📋 Recommended Additional Diagnostic
                                                                                    Tests</h4>
                                                                                <p class="rec-sub">Based on vehicle age,
                                                                                    mileage, and telematics audit,
                                                                                    BatteryIQ recommends the following
                                                                                    follow-up actions:</p>
                                                                                <ul class="rec-list">
                                                                                    <% for (String test :
                                                                                        report.getRecommendedTests()) {
                                                                                        %>
                                                                                        <li>
                                                                                            <span
                                                                                                class="rec-bullet">&bull;</span>
                                                                                            <span>
                                                                                                <%= test %>
                                                                                            </span>
                                                                                        </li>
                                                                                        <% } %>
                                                                                </ul>
                                                                            </div>
                                                                            <% } %>

                                                                                <!-- Certificate Signoff & Inspector Notes -->
                                                                                <div class="cert-signoff-bar">
                                                                                    <div class="signoff-notes">
                                                                                        <strong>Inspector
                                                                                            Remarks:</strong>
                                                                                        <p>
                                                                                            <%= (report !=null &&
                                                                                                !isPending &&
                                                                                                report.getInspectorNotes()
                                                                                                !=null) ?
                                                                                                report.getInspectorNotes()
                                                                                                : "Vehicle inspection pending. Official technician sign-off will occur following the on-site physical diagnostic protocol."
                                                                                                %>
                                                                                        </p>
                                                                                    </div>
                                                                                    <div class="signoff-signature">
                                                                                        <div class="sig-line"><em>
                                                                                                <%= !isPending
                                                                                                    ? "BatteryIQ Telematics Diagnostic Lab"
                                                                                                    : "Pending Inspection Approval"
                                                                                                    %>
                                                                                            </em></div>
                                                                                        <span class="sig-title">
                                                                                            <%= !isPending
                                                                                                ? "Authorized Inspection Lead Signature"
                                                                                                : "Diagnostic Status: Awaiting Test"
                                                                                                %>
                                                                                        </span>
                                                                                    </div>
                                                                                </div>
                                                    </div>

                                                    <!-- Bottom Action Navigation -->
                                                    <div class="report-bottom-nav no-print">
                                                        <a href="<%= request.getContextPath() %>/vehicle?id=<%= vehicle != null ? vehicle.getVehicleId() : 1 %>"
                                                            class="btn btn-secondary">
                                                            &larr; Back to Vehicle Details
                                                        </a>
                                                        <a href="<%= request.getContextPath() %>/compare?id1=<%= vehicle != null ? vehicle.getVehicleId() : 1 %>"
                                                            class="btn btn-primary">
                                                            Compare With Another Vehicle
                                                        </a>
                                                        <a href="<%= request.getContextPath() %>/sell"
                                                            class="btn btn-outline">
                                                            Book Inspection for Your Vehicle
                                                        </a>
                                                    </div>
                                                </div>
                                            </main>

                                            <%@ include file="/includes/footer.jsp" %>
                                                <script src="<%= request.getContextPath() %>/js/main.js"></script>
                                    </body>

                                    </html>