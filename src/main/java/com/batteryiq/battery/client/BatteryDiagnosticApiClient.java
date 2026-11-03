package com.batteryiq.battery.client;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * Reusable HTTP client for communicating with the Python Scientific Intelligence Microservice.
 * Communicates with Python running on port 5001 via standard Java 8 HttpURLConnection.
 * 
 * Strict Architectural Rule:
 * Never calculates SOC, SOH, degradation, or RUL independently in Java.
 * If Python is unavailable, returns a structured service-unavailable error response.
 */
public class BatteryDiagnosticApiClient {

    private static final String DEFAULT_PYTHON_SERVICE_URL = "http://127.0.0.1:5001";
    private static final int CONNECT_TIMEOUT_MS = 3000;
    private static final int READ_TIMEOUT_MS = 5000;

    private final String baseUrl;

    public BatteryDiagnosticApiClient() {
        String envUrl = System.getenv("BATTERYIQ_PYTHON_SERVICE_URL");
        this.baseUrl = (envUrl != null && !envUrl.trim().isEmpty()) ? envUrl.trim() : DEFAULT_PYTHON_SERVICE_URL;
    }

    public BatteryDiagnosticApiClient(String baseUrl) {
        this.baseUrl = baseUrl != null ? baseUrl : DEFAULT_PYTHON_SERVICE_URL;
    }

    /**
     * Checks if the Python scientific microservice is online.
     * @return true if service responds HTTP 200 on /health
     */
    public boolean isServiceAvailable() {
        try {
            HttpURLConnection conn = createConnection("/health", "GET");
            conn.setConnectTimeout(1500);
            conn.setReadTimeout(1500);
            int code = conn.getResponseCode();
            conn.disconnect();
            return code == 200;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Queries the Python health endpoint.
     */
    public String getHealth() {
        return executeGet("/health");
    }

    /**
     * Retrieves all configured battery chemistry profiles from Python.
     */
    public String getChemistryProfiles() {
        return executeGet("/api/chemistry/profiles");
    }

    /**
     * Sends telemetry and analysis requests to the unified Python analysis endpoint.
     * @param jsonPayload JSON containing telemetry readings and configuration
     * @return JSON response from Python
     */
    public String analyzeBattery(String jsonPayload) {
        return executePost("/api/battery/analyze", jsonPayload);
    }

    /**
     * Requests discrete Coulomb Counting calculation from Python.
     */
    public String calculateSoc(String jsonPayload) {
        return executePost("/api/soc/calculate", jsonPayload);
    }

    /**
     * Requests capacity-based SOH and degradation analysis from Python.
     */
    public String analyzeSoh(String jsonPayload) {
        return executePost("/api/soh/analyze", jsonPayload);
    }

    /**
     * Requests chemistry-specific anomaly detection scan from Python.
     */
    public String detectAnomalies(String jsonPayload) {
        return executePost("/api/anomaly/detect", jsonPayload);
    }

    /**
     * Requests cycle-based RUL prediction from Python.
     */
    public String predictRul(String jsonPayload) {
        return executePost("/api/rul/predict", jsonPayload);
    }

    // -------------------------------------------------------------------------
    // Internal HTTP Transport Helpers (Java 8 Compatible)
    // -------------------------------------------------------------------------
    private String executeGet(String endpoint) {
        HttpURLConnection conn = null;
        try {
            conn = createConnection(endpoint, "GET");
            int responseCode = conn.getResponseCode();
            return readResponse(conn, responseCode);
        } catch (Exception e) {
            return buildServiceUnavailableResponse(e.getMessage());
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    private String executePost(String endpoint, String jsonPayload) {
        HttpURLConnection conn = null;
        try {
            conn = createConnection(endpoint, "POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

            byte[] input = (jsonPayload != null ? jsonPayload : "{}").getBytes(StandardCharsets.UTF_8);
            conn.setFixedLengthStreamingMode(input.length);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(input, 0, input.length);
                os.flush();
            }

            int responseCode = conn.getResponseCode();
            return readResponse(conn, responseCode);
        } catch (Exception e) {
            return buildServiceUnavailableResponse(e.getMessage());
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    private HttpURLConnection createConnection(String endpoint, String method) throws Exception {
        URL url = new URL(baseUrl + endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod(method);
        conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
        conn.setReadTimeout(READ_TIMEOUT_MS);
        conn.setRequestProperty("Accept", "application/json");
        conn.setRequestProperty("User-Agent", "BatteryIQ-JavaEnterpriseClient/1.0");
        return conn;
    }

    private String readResponse(HttpURLConnection conn, int responseCode) throws Exception {
        BufferedReader reader;
        if (responseCode >= 200 && responseCode < 400) {
            reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
        } else {
            if (conn.getErrorStream() != null) {
                reader = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
            } else {
                return buildServiceErrorResponse(responseCode, "HTTP Error " + responseCode);
            }
        }

        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();
        return response.toString();
    }

    private String buildServiceUnavailableResponse(String details) {
        return "{\n" +
                "  \"status\": \"SERVICE_UNAVAILABLE\",\n" +
                "  \"service\": \"Python Scientific Intelligence Microservice\",\n" +
                "  \"port\": 5001,\n" +
                "  \"is_python_online\": false,\n" +
                "  \"message\": \"Python Scientific Intelligence Service (Port 5001) is currently offline. Scientific analytics, Coulomb counting, SOH analysis, and ML RUL predictions are paused.\",\n" +
                "  \"instruction\": \"Please start the Python service using start_python_service.bat or run 'python app.py' inside the python/ directory.\",\n" +
                "  \"error_details\": \"" + (details != null ? details.replace("\"", "\\\"") : "Connection refused") + "\"\n" +
                "}";
    }

    private String buildServiceErrorResponse(int code, String message) {
        return "{\n" +
                "  \"status\": \"HTTP_ERROR_" + code + "\",\n" +
                "  \"message\": \"" + (message != null ? message.replace("\"", "\\\"") : "Error") + "\"\n" +
                "}";
    }
}

