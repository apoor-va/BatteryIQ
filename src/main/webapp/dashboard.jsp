<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.batteryiq.model.BatterySession" %>
        <%@ page import="com.batteryiq.model.Vehicle" %>
            <%@ page import="java.util.List" %>
                <%@ page import="java.math.BigDecimal" %>

                    <% Integer totalVehicles=(Integer) request.getAttribute("totalVehicles"); Integer totalEVs=(Integer)
                        request.getAttribute("totalEVs"); Integer totalSessions=(Integer)
                        request.getAttribute("totalSessions"); Integer totalHealthReports=(Integer)
                        request.getAttribute("totalHealthReports"); Integer lowRiskCount=(Integer)
                        request.getAttribute("lowRiskCount"); Integer moderateRiskCount=(Integer)
                        request.getAttribute("moderateRiskCount"); Integer criticalRiskCount=(Integer)
                        request.getAttribute("criticalRiskCount"); Integer publicDatasetCount=(Integer)
                        request.getAttribute("publicDatasetCount"); Integer simulatorCount=(Integer)
                        request.getAttribute("simulatorCount"); Integer liveObdCount=(Integer)
                        request.getAttribute("liveObdCount"); Boolean pythonOnline=(Boolean)
                        request.getAttribute("pythonOnline"); List<BatterySession> recentSessions = (List
                        <BatterySession>) request.getAttribute("recentSessions");
                            List<Vehicle> electricVehicles = (List<Vehicle>) request.getAttribute("electricVehicles");

                                    if (totalVehicles == null) totalVehicles = 0;
                                    if (totalEVs == null) totalEVs = 0;
                                    if (totalSessions == null) totalSessions = 0;
                                    if (totalHealthReports == null) totalHealthReports = 0;
                                    if (lowRiskCount == null) lowRiskCount = 0;
                                    if (moderateRiskCount == null) moderateRiskCount = 0;
                                    if (criticalRiskCount == null) criticalRiskCount = 0;
                                    if (publicDatasetCount == null) publicDatasetCount = 0;
                                    if (simulatorCount == null) simulatorCount = 0;
                                    if (liveObdCount == null) liveObdCount = 0;
                                    if (pythonOnline == null) pythonOnline = false;

                                    int totalRiskAudited = lowRiskCount + moderateRiskCount + criticalRiskCount;
                                    double lowRiskPct = totalRiskAudited > 0 ? (lowRiskCount * 100.0 / totalRiskAudited)
                                    : 70.0;
                                    double modRiskPct = totalRiskAudited > 0 ? (moderateRiskCount * 100.0 /
                                    totalRiskAudited) : 20.0;
                                    double critRiskPct = totalRiskAudited > 0 ? (criticalRiskCount * 100.0 /
                                    totalRiskAudited) : 10.0;
                                    %>

                                    <!DOCTYPE html>
                                    <html lang="en">

                                    <head>
                                        <meta charset="UTF-8">
                                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                        <title>BatteryIQ Executive Dashboard - Fleet Health &amp; Battery Intelligence
                                        </title>
                                        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
                                        <style>
                                            .dashboard-hero {
                                                background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
                                                color: #ffffff;
                                                padding: 3rem 0 2rem;
                                                border-bottom: 1px solid #334155;
                                            }

                                            .dash-stat-grid {
                                                display: grid;
                                                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                                                gap: 1.25rem;
                                                margin-top: -1.75rem;
                                                position: relative;
                                                z-index: 10;
                                            }

                                            .dash-card {
                                                background: #ffffff;
                                                border-radius: var(--radius-lg, 12px);
                                                padding: 1.4rem;
                                                box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.08);
                                                border: 1px solid #e2e8f0;
                                                display: flex;
                                                align-items: center;
                                                gap: 1.1rem;
                                                transition: transform 0.2s ease, box-shadow 0.2s ease;
                                            }

                                            .dash-card:hover {
                                                transform: translateY(-3px);
                                                box-shadow: 0 14px 30px -5px rgba(15, 23, 42, 0.12);
                                            }

                                            .dash-icon-box {
                                                width: 52px;
                                                height: 52px;
                                                border-radius: 12px;
                                                display: flex;
                                                align-items: center;
                                                justify-content: center;
                                                font-size: 1.6rem;
                                                flex-shrink: 0;
                                            }

                                            .dash-icon-blue {
                                                background: #eff6ff;
                                                color: #2563eb;
                                            }

                                            .dash-icon-emerald {
                                                background: #ecfdf5;
                                                color: #059669;
                                            }

                                            .dash-icon-amber {
                                                background: #fffbeb;
                                                color: #d97706;
                                            }

                                            .dash-icon-purple {
                                                background: #faf5ff;
                                                color: #9333ea;
                                            }

                                            .dash-stat-val {
                                                font-family: var(--font-heading, inherit);
                                                font-size: 1.85rem;
                                                font-weight: 800;
                                                color: #0f172a;
                                                line-height: 1.1;
                                            }

                                            .dash-stat-lbl {
                                                font-size: 0.82rem;
                                                font-weight: 600;
                                                color: #64748b;
                                                text-transform: uppercase;
                                                letter-spacing: 0.03em;
                                                margin-top: 0.25rem;
                                            }

                                            .dash-sections-grid {
                                                display: grid;
                                                grid-template-columns: 2fr 1fr;
                                                gap: 1.5rem;
                                                margin-top: 2rem;
                                            }

                                            @media (max-width: 992px) {
                                                .dash-sections-grid {
                                                    grid-template-columns: 1fr;
                                                }
                                            }

                                            .dash-box {
                                                background: #ffffff;
                                                border: 1px solid #e2e8f0;
                                                border-radius: 12px;
                                                padding: 1.5rem;
                                                box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04);
                                                margin-bottom: 1.5rem;
                                            }

                                            .dash-box-title {
                                                font-size: 1.1rem;
                                                font-weight: 800;
                                                color: #0f172a;
                                                margin-bottom: 1.25rem;
                                                display: flex;
                                                justify-content: space-between;
                                                align-items: center;
                                            }

                                            .risk-bar-container {
                                                display: flex;
                                                height: 18px;
                                                border-radius: 9999px;
                                                overflow: hidden;
                                                margin: 1rem 0;
                                                background: #f1f5f9;
                                            }

                                            .risk-seg-low {
                                                background: #10b981;
                                            }

                                            .risk-seg-mod {
                                                background: #f59e0b;
                                            }

                                            .risk-seg-crit {
                                                background: #ef4444;
                                            }

                                            .risk-legend-row {
                                                display: flex;
                                                justify-content: space-between;
                                                gap: 0.5rem;
                                                margin-top: 0.75rem;
                                                font-size: 0.82rem;
                                            }

                                            .risk-leg-item {
                                                display: flex;
                                                align-items: center;
                                                gap: 0.4rem;
                                            }

                                            .risk-dot {
                                                width: 10px;
                                                height: 10px;
                                                border-radius: 50%;
                                                display: inline-block;
                                            }

                                            .quick-launch-grid {
                                                display: grid;
                                                grid-template-columns: 1fr 1fr;
                                                gap: 0.85rem;
                                            }

                                            .quick-launch-btn {
                                                display: flex;
                                                align-items: center;
                                                gap: 0.75rem;
                                                background: #f8fafc;
                                                border: 1px solid #e2e8f0;
                                                border-radius: 8px;
                                                padding: 0.85rem 1rem;
                                                color: #0f172a;
                                                text-decoration: none;
                                                font-weight: 700;
                                                font-size: 0.88rem;
                                                transition: all 0.2s ease;
                                            }

                                            .quick-launch-btn:hover {
                                                background: #f1f5f9;
                                                border-color: #cbd5e1;
                                                transform: translateY(-2px);
                                            }

                                            .quick-launch-btn .ql-icon {
                                                font-size: 1.3rem;
                                            }

                                            .data-source-pill {
                                                font-size: 0.72rem;
                                                font-weight: 700;
                                                padding: 0.2rem 0.55rem;
                                                border-radius: 9999px;
                                                text-transform: uppercase;
                                            }

                                            .data-source-pill.public_dataset {
                                                background: #e0f2fe;
                                                color: #0369a1;
                                            }

                                            .data-source-pill.simulator {
                                                background: #f3e8ff;
                                                color: #7e22ce;
                                            }

                                            .data-source-pill.live_obd {
                                                background: #fef3c7;
                                                color: #b45309;
                                            }
                                        </style>
                                    </head>

                                    <body class="bg-slate-50">

                                        <%@ include file="/includes/header.jsp" %>

                                            <!-- Hero Banner -->
                                            <section class="dashboard-hero">
                                                <div class="container">
                                                    <div
                                                        style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                                                        <div>
                                                            <span
                                                                style="background: rgba(2, 132, 199, 0.25); color: #38bdf8; font-size: 0.78rem; font-weight: 700; padding: 0.3rem 0.75rem; border-radius: 9999px; text-transform: uppercase; letter-spacing: 0.05em;">
                                                                Automotive Intelligence &bull; Verified Health Suite
                                                            </span>
                                                            <h1
                                                                style="font-size: 2.2rem; font-weight: 900; margin: 0.6rem 0 0.3rem; letter-spacing: -0.02em;">
                                                                BatteryIQ Executive Fleet Dashboard
                                                            </h1>
                                                            <p
                                                                style="color: #94a3b8; font-size: 0.92rem; max-width: 650px; margin: 0;">
                                                                Continuous battery health tracking, empirical laboratory
                                                                degradation benchmarking, real-time CAN/OBD diagnostic
                                                                telemetry, and certified marketplace inspection reports.
                                                            </p>
                                                        </div>
                                                        <div>
                                                            <div
                                                                style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; padding: 0.6rem 1rem; text-align: right;">
                                                                <span
                                                                    style="font-size: 0.75rem; color: #94a3b8; text-transform: uppercase;">Scientific
                                                                    Python Engine</span>
                                                                <div
                                                                    style="display: flex; align-items: center; gap: 0.4rem; justify-content: flex-end; margin-top: 0.2rem;">
                                                                    <span
                                                                        style="width: 8px; height: 8px; border-radius: 50%; background: <%= pythonOnline ? "
                                                                        #10b981" : "#ef4444" %>; display:
                                                                        inline-block;"></span>
                                                                    <strong
                                                                        style="font-size: 0.88rem; color: <%= pythonOnline ? "
                                                                        #34d399" : "#f87171" %>;">
                                                                        <%= pythonOnline ? "PORT 5001 ONLINE"
                                                                            : "SERVICE OFFLINE" %>
                                                                    </strong>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </section>

                                            <!-- Main Content Container -->
                                            <main class="container" style="padding-bottom: 3.5rem;">

                                                <!-- 4 Top Stat Cards -->
                                                <div class="dash-stat-grid">
                                                    <div class="dash-card">
                                                        <div class="dash-icon-box dash-icon-blue">🚗</div>
                                                        <div>
                                                            <div class="dash-stat-val">
                                                                <%= totalVehicles %>
                                                            </div>
                                                            <div class="dash-stat-lbl">Registered Vehicles</div>
                                                        </div>
                                                    </div>
                                                    <div class="dash-card">
                                                        <div class="dash-icon-box dash-icon-emerald">⚡</div>
                                                        <div>
                                                            <div class="dash-stat-val">
                                                                <%= totalEVs %>
                                                            </div>
                                                            <div class="dash-stat-lbl">Electric Vehicles</div>
                                                        </div>
                                                    </div>
                                                    <div class="dash-card">
                                                        <div class="dash-icon-box dash-icon-amber">🔬</div>
                                                        <div>
                                                            <div class="dash-stat-val">
                                                                <%= totalSessions %>
                                                            </div>
                                                            <div class="dash-stat-lbl">Battery Lab Analyses</div>
                                                        </div>
                                                    </div>
                                                    <div class="dash-card">
                                                        <div class="dash-icon-box dash-icon-purple">🛡️</div>
                                                        <div>
                                                            <div class="dash-stat-val">
                                                                <%= totalHealthReports %>
                                                            </div>
                                                            <div class="dash-stat-lbl">Certified Health Audits</div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- 2 Column Section Grid -->
                                                <div class="dash-sections-grid">

                                                    <!-- Left Column: Recent Analyses Table & EV Fleet -->
                                                    <div>
                                                        <!-- Recent Battery Analyses -->
                                                        <div class="dash-box">
                                                            <div class="dash-box-title">
                                                                <span>📋 Recent Battery Telemetry &amp; Diagnostic
                                                                    Records</span>
                                                                <a href="<%= request.getContextPath() %>/battery-lab"
                                                                    style="font-size: 0.82rem; color: #0284c7; text-decoration: none; font-weight: 700;">
                                                                    Open Diagnostic Lab &rarr;
                                                                </a>
                                                            </div>

                                                            <% if (recentSessions !=null && !recentSessions.isEmpty()) {
                                                                %>
                                                                <div style="overflow-x: auto;">
                                                                    <table class="session-table"
                                                                        style="width: 100%; font-size: 0.82rem;">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>Session UUID</th>
                                                                                <th>Target Identifier</th>
                                                                                <th>Chemistry</th>
                                                                                <th>SOH (%)</th>
                                                                                <th>Source Mode</th>
                                                                                <th>Verification Status</th>
                                                                                <th>Action</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <% for (BatterySession s : recentSessions) {
                                                                                String srcClass=s.getSourceType() !=null
                                                                                ? s.getSourceType().toLowerCase()
                                                                                : "simulator" ; %>
                                                                                <tr>
                                                                                    <td><strong>
                                                                                            <%= s.getSessionUuid() %>
                                                                                        </strong></td>
                                                                                    <td>
                                                                                        <%= s.getCellOrPackIdentifier()
                                                                                            %>
                                                                                    </td>
                                                                                    <td><code><%= s.getChemistryProfileId() %></code>
                                                                                    </td>
                                                                                    <td>
                                                                                        <strong
                                                                                            style="color: <%= (s.getEstimatedSohPct() != null && s.getEstimatedSohPct().doubleValue() < 70) ? "
                                                                                            #ef4444" : "#10b981" %>;">
                                                                                            <%= s.getEstimatedSohPct()
                                                                                                !=null ?
                                                                                                s.getEstimatedSohPct()
                                                                                                + "%" : "--" %>
                                                                                        </strong>
                                                                                    </td>
                                                                                    <td>
                                                                                        <span
                                                                                            class="data-source-pill <%= srcClass %>">
                                                                                            <%= s.getSourceType() %>
                                                                                        </span>
                                                                                    </td>
                                                                                    <td>
                                                                                        <span
                                                                                            class="evidence-status-pill <%= s.isPhysicallyVerified() ? "
                                                                                            verified" : (s.isLiveObd()
                                                                                            ? "unverified" : "pending" )
                                                                                            %>" style="font-size:
                                                                                            0.72rem; padding: 0.15rem
                                                                                            0.5rem;">
                                                                                            <%= s.getVerificationStatus()
                                                                                                %>
                                                                                        </span>
                                                                                    </td>
                                                                                    <td>
                                                                                        <a href="<%= request.getContextPath() %>/battery-lab?session_id=<%= s.getSessionId() %>"
                                                                                            class="btn btn-outline"
                                                                                            style="padding: 0.2rem 0.5rem; font-size: 0.72rem;">
                                                                                            Inspect
                                                                                        </a>
                                                                                    </td>
                                                                                </tr>
                                                                                <% } %>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                                <% } else { %>
                                                                    <div
                                                                        style="text-align: center; padding: 2rem; color: #94a3b8;">
                                                                        <p>No battery analysis sessions recorded yet.
                                                                        </p>
                                                                        <a href="<%= request.getContextPath() %>/battery-lab"
                                                                            class="btn btn-primary"
                                                                            style="margin-top: 0.5rem;">Run First
                                                                            Analysis</a>
                                                                    </div>
                                                                    <% } %>
                                                        </div>

                                                        <!-- Electric Vehicle Inventory Showcase -->
                                                        <div class="dash-box">
                                                            <div class="dash-box-title">
                                                                <span>⚡ Electric Vehicle Inventory &bull; Real-Time
                                                                    Battery Health Status</span>
                                                                <a href="<%= request.getContextPath() %>/vehicles?fuel=Electric"
                                                                    style="font-size: 0.82rem; color: #0284c7; text-decoration: none; font-weight: 700;">
                                                                    View All EVs &rarr;
                                                                </a>
                                                            </div>
                                                            <% if (electricVehicles !=null &&
                                                                !electricVehicles.isEmpty()) { %>
                                                                <div
                                                                    style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1rem;">
                                                                    <% for (Vehicle ev : electricVehicles) { %>
                                                                        <div
                                                                            style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 1rem; display: flex; flex-direction: column; justify-content: space-between;">
                                                                            <div>
                                                                                <div
                                                                                    style="display: flex; justify-content: space-between; align-items: flex-start;">
                                                                                    <h5
                                                                                        style="margin: 0; font-size: 0.95rem; font-weight: 800; color: #0f172a;">
                                                                                        <%= ev.getDisplayName() %>
                                                                                    </h5>
                                                                                    <span
                                                                                        style="font-size: 0.72rem; background: #dcfce7; color: #15803d; font-weight: 700; padding: 0.15rem 0.45rem; border-radius: 4px;">EV</span>
                                                                                </div>
                                                                                <div
                                                                                    style="font-size: 0.8rem; color: #64748b; margin-top: 0.3rem;">
                                                                                    <span>
                                                                                        <%= ev.getManufacturingYear() %>
                                                                                    </span> &bull; <span>
                                                                                        <%= ev.getFormattedOdometer() %>
                                                                                    </span> &bull; <span>
                                                                                        <%= ev.getTransmission() %>
                                                                                    </span>
                                                                                </div>
                                                                                <div
                                                                                    style="margin-top: 0.75rem; padding-top: 0.6rem; border-top: 1px dashed #cbd5e1; font-size: 0.8rem;">
                                                                                    <span>Health Grade: <strong
                                                                                            style="color: #059669;">
                                                                                            <%= ev.getHealthReport()
                                                                                                !=null ?
                                                                                                ev.getHealthReport().getOverallGrade()
                                                                                                : (ev.getBatteryReport()
                                                                                                !=null ?
                                                                                                ev.getBatteryReport().getOverallGrade()
                                                                                                : "A" ) %>
                                                                                        </strong></span> &bull;
                                                                                    <span>Score: <strong>
                                                                                            <%= ev.getHealthReport()
                                                                                                !=null ?
                                                                                                String.valueOf(ev.getHealthReport().getOverallScore())
                                                                                                : (ev.getBatteryReport()
                                                                                                !=null ?
                                                                                                String.valueOf((int)ev.getBatteryReport().getSohPercentage().doubleValue())
                                                                                                : "95" ) %>/100
                                                                                        </strong></span>
                                                                                </div>
                                                                            </div>
                                                                            <div
                                                                                style="margin-top: 0.85rem; display: flex; gap: 0.5rem;">
                                                                                <a href="<%= request.getContextPath() %>/vehicle?id=<%= ev.getVehicleId() %>"
                                                                                    class="btn btn-outline"
                                                                                    style="flex: 1; padding: 0.3rem 0.5rem; font-size: 0.75rem; text-align: center;">Details</a>
                                                                                <a href="<%= request.getContextPath() %>/health-report?id=<%= ev.getVehicleId() %>"
                                                                                    class="btn btn-primary"
                                                                                    style="flex: 1; padding: 0.3rem 0.5rem; font-size: 0.75rem; text-align: center;">Health
                                                                                    Audit</a>
                                                                            </div>
                                                                        </div>
                                                                        <% } %>
                                                                </div>
                                                                <% } else { %>
                                                                    <p style="color: #64748b; font-size: 0.88rem;">No EV
                                                                        records available in database.</p>
                                                                    <% } %>
                                                        </div>
                                                    </div>

                                                    <!-- Right Column: Risk Distribution & Quick Action Launchpad -->
                                                    <div>
                                                        <!-- Risk Distribution Box -->
                                                        <div class="dash-box">
                                                            <h4 class="dash-box-title">
                                                                <span>📊 Battery Risk Distribution</span>
                                                            </h4>
                                                            <p
                                                                style="font-size: 0.82rem; color: #64748b; margin-top: -0.5rem; line-height: 1.4;">
                                                                Empirical battery health grading across evaluated fleet
                                                                telemetry and dataset sessions.
                                                            </p>

                                                            <!-- Segmented Progress Bar -->
                                                            <div class="risk-bar-container">
                                                                <div class="risk-seg-low"
                                                                    style="width: <%= String.format(java.util.Locale.US, "
                                                                    %.1f", lowRiskPct) %>%;" title="Low Risk: <%=
                                                                        lowRiskCount %>"></div>
                                                                <div class="risk-seg-mod"
                                                                    style="width: <%= String.format(java.util.Locale.US, "
                                                                    %.1f", modRiskPct) %>%;" title="Moderate Risk: <%=
                                                                        moderateRiskCount %>"></div>
                                                                <div class="risk-seg-crit"
                                                                    style="width: <%= String.format(java.util.Locale.US, "
                                                                    %.1f", critRiskPct) %>%;" title="Critical Risk: <%=
                                                                        criticalRiskCount %>"></div>
                                                            </div>

                                                            <div class="risk-legend-row">
                                                                <div class="risk-leg-item">
                                                                    <span class="risk-dot"
                                                                        style="background: #10b981;"></span>
                                                                    <span>Low Risk (&ge;80%): <strong>
                                                                            <%= lowRiskCount %>
                                                                        </strong></span>
                                                                </div>
                                                                <div class="risk-leg-item">
                                                                    <span class="risk-dot"
                                                                        style="background: #f59e0b;"></span>
                                                                    <span>Moderate: <strong>
                                                                            <%= moderateRiskCount %>
                                                                        </strong></span>
                                                                </div>
                                                                <div class="risk-leg-item">
                                                                    <span class="risk-dot"
                                                                        style="background: #ef4444;"></span>
                                                                    <span>Critical: <strong>
                                                                            <%= criticalRiskCount %>
                                                                        </strong></span>
                                                                </div>
                                                            </div>

                                                            <div
                                                                style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 0.85rem; margin-top: 1.25rem;">
                                                                <span
                                                                    style="font-size: 0.75rem; font-weight: 700; color: #475569; text-transform: uppercase;">Telemetry
                                                                    Origins Breakdown:</span>
                                                                <div
                                                                    style="display: flex; justify-content: space-between; font-size: 0.8rem; margin-top: 0.4rem; color: #334155;">
                                                                    <span>Public Datasets: <strong>
                                                                            <%= publicDatasetCount %>
                                                                        </strong></span>
                                                                    <span>Simulator: <strong>
                                                                            <%= simulatorCount %>
                                                                        </strong></span>
                                                                    <span>Live OBD: <strong>
                                                                            <%= liveObdCount %>
                                                                        </strong></span>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <!-- Quick Launchpad -->
                                                        <div class="dash-box">
                                                            <h4 class="dash-box-title">
                                                                <span>⚡ Platform Quick Actions</span>
                                                            </h4>
                                                            <div class="quick-launch-grid">
                                                                <a href="<%= request.getContextPath() %>/battery-lab"
                                                                    class="quick-launch-btn">
                                                                    <span class="ql-icon">🔬</span>
                                                                    <div>
                                                                        <div>Battery Lab</div>
                                                                        <small
                                                                            style="color: #64748b; font-weight: 400;">Diagnostic
                                                                            Suite</small>
                                                                    </div>
                                                                </a>
                                                                <a href="<%= request.getContextPath() %>/battery-analytics"
                                                                    class="quick-launch-btn">
                                                                    <span class="ql-icon">📈</span>
                                                                    <div>
                                                                        <div>Analytics</div>
                                                                        <small
                                                                            style="color: #64748b; font-weight: 400;">Degradation
                                                                            &amp; Compare</small>
                                                                    </div>
                                                                </a>
                                                                <a href="<%= request.getContextPath() %>/health-report"
                                                                    class="quick-launch-btn">
                                                                    <span class="ql-icon">🛡️</span>
                                                                    <div>
                                                                        <div>Health Reports</div>
                                                                        <small
                                                                            style="color: #64748b; font-weight: 400;">Certified
                                                                            Audits</small>
                                                                    </div>
                                                                </a>
                                                                <a href="<%= request.getContextPath() %>/vehicles"
                                                                    class="quick-launch-btn">
                                                                    <span class="ql-icon">🚗</span>
                                                                    <div>
                                                                        <div>Marketplace</div>
                                                                        <small
                                                                            style="color: #64748b; font-weight: 400;">Browse
                                                                            14 Vehicles</small>
                                                                    </div>
                                                                </a>
                                                            </div>
                                                        </div>

                                                        <!-- Academic Disclosure Box -->
                                                        <div
                                                            style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 1rem; font-size: 0.78rem; color: #64748b; line-height: 1.5;">
                                                            <strong style="color: #334155;">ENGINEERING COMPLIANCE
                                                                DISCLOSURE:</strong><br>
                                                            BatteryIQ operates under strict scientific transparency.
                                                            Degradation models trained on NASA Ames PCoE 18650 bench
                                                            cells reflect constant laboratory discharge at 24°C chamber.
                                                            Live OBD connections remain strictly
                                                            <code>UNVERIFIED_LIVE_TELEMETRY</code> until certified by
                                                            hands-on physical inspection.
                                                        </div>
                                                    </div>
                                                </div>

                                            </main>

                                            <%@ include file="/includes/footer.jsp" %>

                                    </body>

                                    </html>