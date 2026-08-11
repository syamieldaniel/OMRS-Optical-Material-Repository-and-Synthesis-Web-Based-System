package com.omrs.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/omrs_db?connectTimeout=5000&socketTimeout=10000";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "";
    
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(
                setting("OMRS_DB_URL", "omrs.db.url", DEFAULT_URL),
                setting("OMRS_DB_USER", "omrs.db.user", DEFAULT_USER),
                setting("OMRS_DB_PASSWORD", "omrs.db.password", DEFAULT_PASS));
    }

    private static String setting(String envName, String propertyName, String defaultValue) {
        String value = System.getenv(envName);
        if (value == null || value.trim().isEmpty()) {
            value = System.getProperty(propertyName);
        }
        return value == null ? defaultValue : value;
    }
} 
