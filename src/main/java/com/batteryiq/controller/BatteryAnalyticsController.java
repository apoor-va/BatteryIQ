package com.batteryiq.controller;

import com.batteryiq.dao.BatteryDiagnosticsDAO;
import com.batteryiq.model.BatterySession;
import com.batteryiq.model.BatteryTelemetryPoint;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

/**
 * Controller for Battery Intelligence Analytics & Multi-Battery Comparison (/battery-analytics).
 * Visualizes SOH degradation curves, thermal distribution, chemistry breakdown,
 * and performs side-by-side comparison with scientific reference consistency warnings.
 */
@WebServlet(name = "BatteryAnalyticsController", urlPatterns = {"/battery-analytics"})
public class BatteryAnalyticsController extends HttpServlet {
    private static final long serialVersionUID = 9L;

    private BatteryDiagnosticsDAO diagnosticsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.diagnosticsDAO = new BatteryDiagnosticsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<BatterySession> allSessions = diagnosticsDAO.getAllSessions();
        if (allSessions == null) allSessions = new ArrayList<BatterySession>();

        // 1. Chemistry Distribution
        Map<String, Integer> chemCounts = new LinkedHashMap<String, Integer>();
        chemCounts.put("CHEM_NMC_01", 0);
        chemCounts.put("CHEM_LFP_01", 0);
        chemCounts.put("CHEM_NCA_01", 0);
        chemCounts.put("CHEM_NASA_18650", 0);

        for (BatterySession s : allSessions) {
            String cId = s.getChemistryProfileId();
            if (cId != null && chemCounts.containsKey(cId)) {
                chemCounts.put(cId, chemCounts.get(cId) + 1);
            }
        }

        // 2. Risk Distribution
        int lowRisk = 0, modRisk = 0, critRisk = 0;
        for (BatterySession s : allSessions) {
            BigDecimal soh = s.getEstimatedSohPct();
            double val = soh != null ? soh.doubleValue() : 75.0;
            if (val >= 80.0) lowRisk++;
            else if (val >= 70.0) modRisk++;
            else critRisk++;
        }

        // 3. Multi-Session Comparison
        String id1Str = request.getParameter("compare_1");
        String id2Str = request.getParameter("compare_2");
        BatterySession comp1 = null;
        BatterySession comp2 = null;
        List<BatteryTelemetryPoint> pts1 = null;
        List<BatteryTelemetryPoint> pts2 = null;

        if (id1Str != null && !id1Str.isEmpty()) {
            try {
                int id1 = Integer.parseInt(id1Str);
                comp1 = diagnosticsDAO.getSessionById(id1);
                if (comp1 != null) pts1 = diagnosticsDAO.getReadingsForSession(id1);
            } catch (NumberFormatException ignored) {}
        }
        if (id2Str != null && !id2Str.isEmpty()) {
            try {
                int id2 = Integer.parseInt(id2Str);
                comp2 = diagnosticsDAO.getSessionById(id2);
                if (comp2 != null) pts2 = diagnosticsDAO.getReadingsForSession(id2);
            } catch (NumberFormatException ignored) {}
        }

        // Default comparison if not specified
        if (comp1 == null && allSessions.size() > 0) {
            comp1 = allSessions.get(0);
            pts1 = diagnosticsDAO.getReadingsForSession(comp1.getSessionId());
        }
        if (comp2 == null && allSessions.size() > 1) {
            comp2 = allSessions.get(1);
            pts2 = diagnosticsDAO.getReadingsForSession(comp2.getSessionId());
        }

        // Check reference consistency warning
        boolean comparisonWarning = false;
        String comparisonWarningReason = null;
        if (comp1 != null && comp2 != null) {
            boolean sameUnit = comp1.getCapacityUnit() == comp2.getCapacityUnit();
            boolean sameChem = Objects.equals(comp1.getChemistryProfileId(), comp2.getChemistryProfileId());
            boolean sameSource = Objects.equals(comp1.getSourceType(), comp2.getSourceType());

            if (!sameUnit) {
                comparisonWarning = true;
                comparisonWarningReason = "Inconsistent Capacity Units: Comparing laboratory cell (" + comp1.getCapacityUnit() +
                        ") with EV battery pack (" + comp2.getCapacityUnit() + "). Direct metric comparisons are physically asymmetrical.";
            } else if (!sameChem) {
                comparisonWarning = true;
                comparisonWarningReason = "Disparate Battery Chemistries: Comparing " + comp1.getChemistryProfileId() +
                        " with " + comp2.getChemistryProfileId() + ". Longevity and EOL thresholds (80% vs 70%) differ fundamentally.";
            } else if (!sameSource) {
                comparisonWarning = true;
                comparisonWarningReason = "Heterogeneous Data Sources: Comparing " + comp1.getSourceType() +
                        " with " + comp2.getSourceType() + ". Experimental laboratory bench test conditions differ from automotive telemetry.";
            }
        }

        request.setAttribute("allSessions", allSessions);
        request.setAttribute("chemCounts", chemCounts);
        request.setAttribute("lowRiskCount", lowRisk);
        request.setAttribute("moderateRiskCount", modRisk);
        request.setAttribute("criticalRiskCount", critRisk);
        request.setAttribute("comp1", comp1);
        request.setAttribute("comp2", comp2);
        request.setAttribute("pts1", pts1 != null ? pts1 : new ArrayList<BatteryTelemetryPoint>());
        request.setAttribute("pts2", pts2 != null ? pts2 : new ArrayList<BatteryTelemetryPoint>());
        request.setAttribute("comparisonWarning", comparisonWarning);
        request.setAttribute("comparisonWarningReason", comparisonWarningReason);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/battery-analytics.jsp");
        dispatcher.forward(request, response);
    }
}

