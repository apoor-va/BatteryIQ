package com.batteryiq.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility for establishing connections to the MySQL database.
 */
public class DBConnection {
    // Default connection settings (can be customized via environment variables or web.xml context-param)
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/batteryiq_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    static {
        try {
            // Load MySQL Connector Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("[BatteryIQ DB] MySQL JDBC Driver not found in classpath. Demo mode fallback available.");
        }
    }

    /**
     * Gets a connection to the MySQL database.
     * Checks JVM system properties first, then OS environment variables, then defaults.
     * @return active Connection instance
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        String dbUrl = System.getProperty("BATTERYIQ_DB_URL", System.getenv("BATTERYIQ_DB_URL") != null ? System.getenv("BATTERYIQ_DB_URL") : DEFAULT_URL);
        String dbUser = System.getProperty("BATTERYIQ_DB_USER", System.getenv("BATTERYIQ_DB_USER") != null ? System.getenv("BATTERYIQ_DB_USER") : DEFAULT_USER);
        String dbPass = System.getProperty("BATTERYIQ_DB_PASS", System.getenv("BATTERYIQ_DB_PASS") != null ? System.getenv("BATTERYIQ_DB_PASS") : DEFAULT_PASSWORD);
        return DriverManager.getConnection(dbUrl, dbUser, dbPass);
    }

    /**
     * Helper to safely close a connection.
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ignored) {
            }
        }
    }
}
