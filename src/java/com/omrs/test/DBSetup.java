package com.omrs.test;

import com.omrs.config.DBConnection;
import java.sql.Connection;
import java.sql.Statement;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class DBSetup {
    public static void main(String[] args) {
        try {
            System.out.println("Setting up database...");
            Connection conn = DBConnection.getConnection();

            // Read and execute the SQL file
            String sqlFile = "database.sql";
            executeSqlFile(conn, sqlFile);

            System.out.println("Database setup completed successfully!");
            conn.close();

        } catch (Exception e) {
            System.out.println("Database setup failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void executeSqlFile(Connection conn, String filePath) throws Exception {
        BufferedReader reader = new BufferedReader(new FileReader(filePath));
        StringBuilder sql = new StringBuilder();
        String line;

        Statement stmt = conn.createStatement();

        while ((line = reader.readLine()) != null) {
            line = line.trim();

            // Skip comments and empty lines
            if (line.startsWith("--") || line.startsWith("/*") || line.isEmpty()) {
                continue;
            }

            sql.append(line).append(" ");

            // Execute when we reach a semicolon
            if (line.endsWith(";")) {
                String sqlStatement = sql.toString().trim();
                if (!sqlStatement.isEmpty()) {
                    try {
                        System.out.println("Executing: " + sqlStatement.substring(0, Math.min(50, sqlStatement.length())) + "...");
                        stmt.execute(sqlStatement);
                    } catch (Exception e) {
                        System.out.println("Error executing: " + sqlStatement);
                        System.out.println("Error: " + e.getMessage());
                        // Continue with other statements
                    }
                }
                sql.setLength(0); // Reset for next statement
            }
        }

        stmt.close();
        reader.close();
    }
}