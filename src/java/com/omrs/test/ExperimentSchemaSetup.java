package com.omrs.test;

import com.omrs.config.DBConnection;
import java.sql.Connection;
import java.sql.Statement;

public class ExperimentSchemaSetup {
    public static void main(String[] args) {
        String[] statements = new String[] {
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS study_objective TEXT AFTER concentration",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS hypothesis TEXT AFTER study_objective",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS independent_variable VARCHAR(255) AFTER hypothesis",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS dependent_variable VARCHAR(255) AFTER independent_variable",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS controlled_variables TEXT AFTER dependent_variable",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS characterization_methods TEXT AFTER preparation_notes",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS characterization_notes TEXT AFTER characterization_methods",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS instrument_details TEXT AFTER characterization_notes",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS scan_range VARCHAR(255) AFTER instrument_details",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS calibration_reference TEXT AFTER scan_range",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS replicate_count INT AFTER calibration_reference",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS measurement_uncertainty VARCHAR(255) AFTER replicate_count",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS raw_data_required BOOLEAN DEFAULT FALSE AFTER measurement_uncertainty",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS conclusion TEXT AFTER raw_data_required",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS limitations TEXT AFTER conclusion",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS next_steps TEXT AFTER limitations",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_1_name VARCHAR(120) AFTER characterization_notes",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_1_condition VARCHAR(255) AFTER sample_1_name",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_1_notes TEXT AFTER sample_1_condition",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_2_name VARCHAR(120) AFTER sample_1_notes",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_2_condition VARCHAR(255) AFTER sample_2_name",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_2_notes TEXT AFTER sample_2_condition",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_3_name VARCHAR(120) AFTER sample_2_notes",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_3_condition VARCHAR(255) AFTER sample_3_name",
            "ALTER TABLE experiments ADD COLUMN IF NOT EXISTS sample_3_notes TEXT AFTER sample_3_condition",
            "ALTER TABLE test_data MODIFY COLUMN test_type VARCHAR(50) NOT NULL"
        };

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            for (String sql : statements) {
                stmt.executeUpdate(sql);
            }
            System.out.println("Experiment schema setup complete.");
        } catch (Exception e) {
            System.out.println("Experiment schema setup failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
