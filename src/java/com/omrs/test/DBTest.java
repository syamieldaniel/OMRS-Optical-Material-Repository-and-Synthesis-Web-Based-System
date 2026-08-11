package com.omrs.test;

import com.omrs.config.DBConnection;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;

public class DBTest {
    public static void main(String[] args) {
        try {
            System.out.println("Testing database connection...");
            Connection conn = DBConnection.getConnection();
            if (conn != null) {
                System.out.println("Database connection successful!");

                // Check if learning_materials table exists
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SHOW TABLES LIKE 'learning_materials'");
                if (rs.next()) {
                    System.out.println("learning_materials table exists!");
                } else {
                    System.out.println("learning_materials table does NOT exist!");
                }

                rs.close();
                stmt.close();
                conn.close();
            } else {
                System.out.println("Database connection failed - connection is null");
            }
        } catch (Exception e) {
            System.out.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}