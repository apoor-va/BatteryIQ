<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <% String currentUri=request.getRequestURI(); String contextPath=request.getContextPath(); %>
        <!-- Demo Data Notice Ribbon -->
        <aside class="demo-banner" aria-label="Demo Data Disclaimer">
            <div class="container demo-banner-inner">
                <span class="demo-pill">DEMO DATASET</span>
                <span class="demo-text">
                    <strong>Disclaimer:</strong> This automotive marketplace and diagnostic telematics are simulated for
                    demonstration. Never present invented values as real vehicle inspections.
                </span>
                <a href="<%= contextPath %>/health-report" class="demo-banner-link">View Sample Health Report &rarr;</a>
            </div>
        </aside>

        <!-- Top Announcement & Quick Links Bar (CarDekho Style) -->
        <div class="top-bar">
            <div class="container top-bar-content">
                <div class="top-bar-left">
                    <span>Trusted Automotive Marketplace &bull; 100% Verified Vehicle Health</span>
                </div>
                <div class="top-bar-right">
                    <span class="top-bar-location">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="2">
                            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                            <circle cx="12" cy="10" r="3"></circle>
                        </svg>
                        Location: <strong>All Cities</strong>
                    </span>
                    <a href="<%= contextPath %>/dashboard" class="top-bar-link">Executive Dashboard</a>
                    <a href="<%= contextPath %>/battery-analytics" class="top-bar-link">Battery Analytics</a>
                    <a href="<%= contextPath %>/sell" class="top-bar-link">Sell Vehicle</a>
                    <a href="<%= contextPath %>/health-report" class="top-bar-link">Verify Health</a>
                    <a href="<%= contextPath %>/battery-lab" class="top-bar-link">Battery Lab ⚡</a>
                    <a href="<%= contextPath %>/compare" class="top-bar-link">Compare</a>
                </div>
            </div>
        </div>

        <!-- Main Site Header -->
        <header class="site-header">
            <div class="container">
                <nav class="nav-wrap" aria-label="Main Navigation">
                    <a href="<%= contextPath %>/" class="brand-logo" id="nav-brand-logo">
                        <div class="brand-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="2" y="7" width="16" height="12" rx="2"></rect>
                                <path d="M22 11v4"></path>
                                <path d="m9 11-2 4h4l-2 4" stroke="#00d2ff" stroke-width="2.5"></path>
                            </svg>
                        </div>
                        Battery<span>IQ</span>
                        <span class="brand-tagline">Automotive &bull; Health Verified</span>
                    </a>

                    <!-- Global Quick Search in Nav -->
                    <form action="<%= contextPath %>/search" method="get" class="nav-search-form">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2">
                            <circle cx="11" cy="11" r="8"></circle>
                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                        </svg>
                        <input type="text" name="q" placeholder="Search Cars, Bikes, Scooters, Brands..."
                            aria-label="Search vehicles">
                        <button type="submit" aria-label="Search">Search</button>
                    </form>

                    <ul class="nav-links">
                        <li><a href="<%= contextPath %>/" class="nav-item <%= (currentUri.endsWith(" /") ||
                                currentUri.endsWith("/index.jsp") || currentUri.endsWith("/home")) ? "active" : ""
                                %>">Home</a></li>
                        <li class="has-dropdown">
                            <a href="<%= contextPath %>/vehicles" class="nav-item <%= (currentUri.contains("/vehicles") || currentUri.contains("/cars") || currentUri.contains("/bikes") || currentUri.contains("/scooters")) ? "active" : "" %>">
                                Vehicles <span class="arrow-down">&#9662;</span>
                            </a>
                            <div class="nav-dropdown">
                                <a href="<%= contextPath %>/cars" class="dropdown-item">
                                    <span class="drop-icon">🚗</span>
                                    <div><strong>Cars</strong><small>Sedans, SUVs, Hatchbacks</small></div>
                                </a>
                                <a href="<%= contextPath %>/bikes" class="dropdown-item">
                                    <span class="drop-icon">🏍️</span>
                                    <div><strong>Bikes</strong><small>Sport, Roadsters, Cruisers</small></div>
                                </a>
                                <a href="<%= contextPath %>/scooters" class="dropdown-item">
                                    <span class="drop-icon">🛵</span>
                                    <div><strong>Scooters</strong><small>EV Smartscooters, Petrol</small></div>
                                </a>
                                <div class="dropdown-divider"></div>
                                <a href="<%= contextPath %>/new-vehicles" class="dropdown-item">
                                    <span class="drop-icon">✨</span>
                                    <div><strong>New Vehicles</strong><small>Factory fresh with warranty</small></div>
                                </a>
                                <a href="<%= contextPath %>/used-vehicles" class="dropdown-item">
                                    <span class="drop-icon">🔍</span>
                                    <div><strong>Used Vehicles</strong><small>Pre-owned &amp; Health Verified</small>
                                    </div>
                                </a>
                            </div>
                        </li>
                        <li><a href="<%= contextPath %>/new-vehicles" class="nav-item <%= currentUri.contains("/new-vehicles") ? "active" : "" %>">New</a></li>
                        <li><a href="<%= contextPath %>/used-vehicles" class="nav-item <%= currentUri.contains("/used-vehicles") ? "active" : "" %>">Used</a></li>
                        <li><a href="<%= contextPath %>/compare" class="nav-item <%= currentUri.contains("/compare") ? "active" : "" %>">Compare</a></li>
                        <li>
                            <a href="<%= contextPath %>/dashboard" class="nav-item <%= currentUri.contains("/dashboard") ? "active" : "" %>">
                                Dashboard
                            </a>
                        </li>
                        <li>
                            <a href="<%= contextPath %>/battery-analytics" class="nav-item <%= currentUri.contains("/battery-analytics") ? "active" : "" %>">
                                Analytics
                            </a>
                        </li>
                        <li>
                            <a href="<%= contextPath %>/health-report" class="nav-item <%= currentUri.contains("/health-report") ? "active" : "" %>">
                                Health Report
                            </a>
                        </li>
                        <li>
                            <a href="<%= contextPath %>/battery-lab"
                                class="nav-item highlight-nav <%= currentUri.contains("/battery-lab") ? "active" : "" %>">
                                <span class="health-pulse-dot"></span> Battery Lab ⚡
                            </a>
                        </li>
                    </ul>

                    <div class="nav-actions">
                        <a href="<%= contextPath %>/sell" class="btn btn-sell-cta" id="nav-btn-sell">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2.5">
                                <line x1="12" y1="5" x2="12" y2="19"></line>
                                <line x1="5" y1="12" x2="19" y2="12"></line>
                            </svg>
                            Sell Vehicle
                        </a>
                    </div>
                </nav>
            </div>
        </header>