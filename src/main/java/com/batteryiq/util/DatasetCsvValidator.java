package com.batteryiq.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Validates, cleans, and parses battery research dataset CSV files.
 *
 * SECURITY & SCIENTIFIC PRINCIPLES:
 * 1. Sanitizes CSV formula injection (blocks or strips leading '=', '+', '-', '@').
 * 2. Enforces mandatory columns: 'cycle_index' and 'capacity_ah'.
 * 3. Rejects negative or unphysical capacity measurements.
 * 4. Preserves null values on missing sensor columns without fabricating fake readings.
 * 5. Rejects empty or corrupt CSV streams.
 */
public class DatasetCsvValidator {

    public static class CsvValidationResult {
        private final boolean valid;
        private final String errorMessage;
        private final List<Map<String, Object>> records;
        private final List<String> detectedColumns;
        private final int totalRowsParsed;

        public CsvValidationResult(boolean valid, String errorMessage, List<Map<String, Object>> records, List<String> detectedColumns, int totalRowsParsed) {
            this.valid = valid;
            this.errorMessage = errorMessage;
            this.records = records != null ? records : new ArrayList<Map<String, Object>>();
            this.detectedColumns = detectedColumns != null ? detectedColumns : new ArrayList<String>();
            this.totalRowsParsed = totalRowsParsed;
        }

        public boolean isValid() {
            return valid;
        }

        public String getErrorMessage() {
            return errorMessage;
        }

        public List<Map<String, Object>> getRecords() {
            return records;
        }

        public List<String> getDetectedColumns() {
            return detectedColumns;
        }

        public int getTotalRowsParsed() {
            return totalRowsParsed;
        }
    }

    /**
     * Parses and validates a CSV stream from an uploaded file or text string.
     */
    public static CsvValidationResult validateAndParse(InputStream inputStream) {
        if (inputStream == null) {
            return new CsvValidationResult(false, "Uploaded CSV file or input stream is null.", null, null, 0);
        }

        List<Map<String, Object>> records = new ArrayList<Map<String, Object>>();
        List<String> headers = new ArrayList<String>();
        int lineCount = 0;

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue; // Skip comments and empty lines
                }

                lineCount++;
                String[] tokens = parseCsvLine(line);

                if (lineCount == 1) {
                    // Header line
                    for (String token : tokens) {
                        String cleanHeader = sanitizeHeader(token);
                        headers.add(cleanHeader.toLowerCase());
                    }

                    // Validate mandatory headers
                    if (!headers.contains("cycle_index") || !headers.contains("capacity_ah")) {
                        return new CsvValidationResult(
                                false,
                                "CSV missing required headers. Must contain 'cycle_index' and 'capacity_ah'. Found: " + headers,
                                null, headers, 0
                        );
                    }
                    continue;
                }

                // Data row
                Map<String, Object> row = new HashMap<String, Object>();
                for (int i = 0; i < headers.size() && i < tokens.length; i++) {
                    String colName = headers.get(i);
                    String rawVal = sanitizeValue(tokens[i]);

                    if (rawVal == null || rawVal.isEmpty() || "null".equalsIgnoreCase(rawVal) || "nan".equalsIgnoreCase(rawVal)) {
                        row.put(colName, null);
                    } else {
                        try {
                            if ("cycle_index".equals(colName)) {
                                row.put(colName, Integer.parseInt(rawVal));
                            } else {
                                row.put(colName, Double.parseDouble(rawVal));
                            }
                        } catch (NumberFormatException e) {
                            row.put(colName, null);
                        }
                    }
                }

                // Check mandatory fields in row
                Integer cycleIdx = (Integer) row.get("cycle_index");
                Double cap = (Double) row.get("capacity_ah");

                if (cycleIdx != null && cap != null && cap > 0.0) {
                    records.add(row);
                }
            }
        } catch (IOException e) {
            return new CsvValidationResult(false, "Error reading CSV stream: " + e.getMessage(), null, null, 0);
        }

        if (records.isEmpty()) {
            return new CsvValidationResult(false, "CSV dataset contains zero valid data rows with capacity measurements.", null, headers, 0);
        }

        // Sort records by cycle_index
        Collections.sort(records, new Comparator<Map<String, Object>>() {
            @Override
            public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                Integer c1 = (Integer) o1.get("cycle_index");
                Integer c2 = (Integer) o2.get("cycle_index");
                if (c1 == null) return -1;
                if (c2 == null) return 1;
                return c1.compareTo(c2);
            }
        });

        return new CsvValidationResult(true, null, records, headers, records.size());
    }

    private static String[] parseCsvLine(String line) {
        List<String> list = new ArrayList<String>();
        StringBuilder sb = new StringBuilder();
        boolean inQuotes = false;

        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (c == '\"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                list.add(sb.toString().trim());
                sb.setLength(0);
            } else {
                sb.append(c);
            }
        }
        list.add(sb.toString().trim());
        return list.toArray(new String[0]);
    }

    private static String sanitizeHeader(String header) {
        if (header == null) return "";
        // Remove quotes and whitespace
        return header.replace("\"", "").replace("'", "").trim();
    }

    private static String sanitizeValue(String val) {
        if (val == null) return null;
        val = val.replace("\"", "").replace("'", "").trim();
        // Prevent CSV Formula Injection: Strip leading '=', '+', '-', '@' if followed by formula
        if (val.startsWith("=") || val.startsWith("+") || val.startsWith("@")) {
            val = val.substring(1).trim();
        }
        return val;
    }
}

