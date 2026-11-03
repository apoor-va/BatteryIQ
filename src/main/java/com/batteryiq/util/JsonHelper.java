package com.batteryiq.util;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Lightweight, zero-dependency JSON helper for Java 8.
 * Safely extracts fields and serializes objects for communication with the Python microservice.
 */
public class JsonHelper {

    /**
     * Extracts a string property value from a JSON string by key.
     */
    public static String getString(String json, String key) {
        if (json == null || key == null) return null;
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    /**
     * Extracts a numeric/double property value from a JSON string by key.
     */
    public static BigDecimal getBigDecimal(String json, String key) {
        if (json == null || key == null) return null;
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(-?[0-9]+(?:\\.[0-9]+)?)");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            try {
                return new BigDecimal(matcher.group(1));
            } catch (Exception ignored) {}
        }
        return null;
    }

    /**
     * Extracts an integer property value from a JSON string by key.
     */
    public static Integer getInteger(String json, String key) {
        BigDecimal val = getBigDecimal(json, key);
        return val != null ? val.intValue() : null;
    }

    /**
     * Extracts a long property value from a JSON string by key.
     */
    public static Long getLong(String json, String key) {
        BigDecimal val = getBigDecimal(json, key);
        return val != null ? val.longValue() : null;
    }


    /**
     * Extracts a boolean property value from a JSON string by key.
     */
    public static Boolean getBoolean(String json, String key) {
        if (json == null || key == null) return null;
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(true|false)");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return Boolean.parseBoolean(matcher.group(1));
        }
        return null;
    }

    /**
     * Checks if a JSON string contains a specific key.
     */
    public static boolean hasKey(String json, String key) {
        if (json == null || key == null) return false;
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:");
        return pattern.matcher(json).find();
    }

    /**
     * Extracts a nested JSON sub-object as string by key.
     */
    public static String getSubObject(String json, String key) {
        if (json == null || key == null) return null;
        int keyIndex = json.indexOf("\"" + key + "\"");
        if (keyIndex == -1) return null;
        int colonIndex = json.indexOf(":", keyIndex);
        if (colonIndex == -1) return null;
        int openBrace = json.indexOf("{", colonIndex);
        if (openBrace == -1) return null;

        int depth = 0;
        int closeBrace = -1;
        for (int i = openBrace; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '{') depth++;
            else if (c == '}') {
                depth--;
                if (depth == 0) {
                    closeBrace = i;
                    break;
                }
            }
        }
        if (closeBrace != -1) {
            return json.substring(openBrace, closeBrace + 1);
        }
        return null;
    }

    /**
     * Escapes special characters for JSON string values.
     */
    public static String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if ((ch >= '\u0000' && ch <= '\u001F') || (ch >= '\u007F' && ch <= '\u009F')) {
                        String ss = Integer.toHexString(ch);
                        sb.append("\\u");
                        for (int k = 0; k < 4 - ss.length(); k++) sb.append('0');
                        sb.append(ss.toUpperCase());
                    } else {
                        sb.append(ch);
                    }
            }
        }
        return sb.toString();
    }
}

