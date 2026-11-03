<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String fContext = request.getContextPath();
%>
<footer class="site-footer">
    <div class="container">
        <!-- Main Footer Links Grid -->
        <div class="footer-grid">
            <div class="footer-col brand-col">
                <a href="<%= fContext %>/" class="brand-logo footer-logo">
                    <div class="brand-icon">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                            <rect x="2" y="7" width="16" height="12" rx="2"></rect>
                            <path d="M22 11v4"></path>
                            <path d="m9 11-2 4h4l-2 4" stroke="#00d2ff" stroke-width="2.5"></path>
                        </svg>
                    </div>
                    Battery<span>IQ</span>
                </a>
                <p class="footer-tagline">
                    The complete automotive marketplace inspired by modern vehicle commerce, pioneering transparent, certified Vehicle Health Reports for Electric, Petrol, and Diesel cars, bikes, and scooters.
                </p>
                <div class="footer-badges">
                    <span class="trust-badge">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        EV Battery SoH Certified
                    </span>
                    <span class="trust-badge">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        ICE Engine Compression Verified
                    </span>
                </div>
            </div>

            <div class="footer-col">
                <h4 class="footer-title">Categories</h4>
                <ul class="footer-links">
                    <li><a href="<%= fContext %>/cars">Cars Marketplace</a></li>
                    <li><a href="<%= fContext %>/bikes">Bikes &amp; Motorcycles</a></li>
                    <li><a href="<%= fContext %>/scooters">Scooters &amp; Mopeds</a></li>
                    <li><a href="<%= fContext %>/new-vehicles">Brand New Vehicles</a></li>
                    <li><a href="<%= fContext %>/used-vehicles">Verified Used Vehicles</a></li>
                    <li><a href="<%= fContext %>/vehicles?fuel=ELECTRIC">Electric Vehicles (EV)</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4 class="footer-title">Marketplace Tools</h4>
                <ul class="footer-links">
                    <li><a href="<%= fContext %>/vehicles">Search &amp; Filter Inventory</a></li>
                    <li><a href="<%= fContext %>/compare">Vehicle Comparison Tool</a></li>
                    <li><a href="<%= fContext %>/sell">Sell Your Vehicle</a></li>
                    <li><a href="<%= fContext %>/health-report">BatteryIQ Health Reports</a></li>
                    <li><a href="<%= fContext %>/vehicles?fuel=PETROL">Petrol Vehicles</a></li>
                    <li><a href="<%= fContext %>/vehicles?fuel=DIESEL">Diesel Vehicles</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4 class="footer-title">Health Certification</h4>
                <p class="footer-subtext">Check the verified status of any vehicle before you buy or sell.</p>
                <form action="<%= fContext %>/health-report" method="get" class="footer-cert-search">
                    <input type="text" name="cert" placeholder="Certificate Code (e.g. BIQ-2024...)" required>
                    <button type="submit" class="btn btn-secondary btn-sm">Lookup Report</button>
                </form>
                <div class="cert-demo-hint">
                    <small>Sample Demo Code: <code>BIQ-2024-T3LR-9721</code></small>
                </div>
            </div>
        </div>

        <div class="footer-divider"></div>

        <!-- Demo Data Disclaimer & Copyright -->
        <div class="footer-bottom">
            <div class="footer-disclaimer">
                <strong>Demonstration &amp; Academic Notice:</strong> All vehicle listings, technical specifications, battery telemetry, and mechanical diagnostic scores presented on this site are synthetic demonstration data (DEMO DATA). No real inspection records or warranties are created.
            </div>
            <div class="footer-copyright">
                &copy; 2026 BatteryIQ Automotive Inc. Built with Java Servlets, JSP, MySQL, and Tomcat 9.
            </div>
        </div>
    </div>
</footer>

