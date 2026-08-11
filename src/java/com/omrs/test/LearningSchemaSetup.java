package com.omrs.test;

import com.omrs.config.DBConnection;
import java.sql.Connection;
import java.sql.Statement;

public class LearningSchemaSetup {
    public static void main(String[] args) {
        String[] statements = new String[] {
            "CREATE TABLE IF NOT EXISTS learning_materials (" +
                "material_id VARCHAR(20) PRIMARY KEY," +
                "title VARCHAR(255) NOT NULL," +
                "category VARCHAR(100)," +
                "description TEXT," +
                "content TEXT," +
                "external_link VARCHAR(500)," +
                "file_name VARCHAR(255)," +
                "file_path VARCHAR(500)," +
                "uploaded_by INT NOT NULL," +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP," +
                "FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE CASCADE" +
            ")",
            "CREATE TABLE IF NOT EXISTS learning_quizzes (" +
                "quiz_id VARCHAR(20) PRIMARY KEY," +
                "title VARCHAR(255) NOT NULL," +
                "category VARCHAR(100)," +
                "description TEXT," +
                "uploaded_by INT NOT NULL," +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE CASCADE" +
            ")",
            "CREATE TABLE IF NOT EXISTS learning_quiz_questions (" +
                "question_id VARCHAR(20) PRIMARY KEY," +
                "quiz_id VARCHAR(20) NOT NULL," +
                "question_order INT NOT NULL," +
                "question_text TEXT NOT NULL," +
                "option_a VARCHAR(255) NOT NULL," +
                "option_b VARCHAR(255) NOT NULL," +
                "option_c VARCHAR(255) NOT NULL," +
                "option_d VARCHAR(255) NOT NULL," +
                "correct_option CHAR(1) NOT NULL," +
                "explanation TEXT," +
                "FOREIGN KEY (quiz_id) REFERENCES learning_quizzes(quiz_id) ON DELETE CASCADE" +
            ")",
            "CREATE TABLE IF NOT EXISTS learning_quiz_attempts (" +
                "attempt_id VARCHAR(20) PRIMARY KEY," +
                "quiz_id VARCHAR(20) NOT NULL," +
                "user_id INT NOT NULL," +
                "score INT NOT NULL," +
                "total_questions INT NOT NULL," +
                "submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "FOREIGN KEY (quiz_id) REFERENCES learning_quizzes(quiz_id) ON DELETE CASCADE," +
                "FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE" +
            ")",
            "INSERT IGNORE INTO learning_materials " +
                "(material_id, title, category, description, content, external_link, file_name, file_path, uploaded_by) VALUES " +
                "('LM-001', 'Introduction to Nanophysics', 'Nanophysics Fundamentals', " +
                "'A starter overview of nanoscale phenomena, confinement, and material behavior.', " +
                "'Nanophysics studies how matter behaves when dimensions shrink to the nanoscale. At this scale, quantum confinement, surface effects, and tunneling become important. Use this lesson as a starting point before moving to optical and electronic applications.', " +
                "'https://en.wikipedia.org/wiki/Nanophysics', NULL, NULL, 1)",
            "INSERT IGNORE INTO learning_materials " +
                "(material_id, title, category, description, content, external_link, file_name, file_path, uploaded_by) VALUES " +
                "('LM-002', 'Optical Properties of Nanoparticles', 'Optical Properties', " +
                "'Key ideas behind absorption, scattering, and plasmonic response.', " +
                "'Nanoparticles interact with light differently from bulk materials. Particle size, composition, and surrounding medium can shift optical absorption and scattering. Noble metal nanoparticles are especially important because of localized surface plasmon resonance.', " +
                "NULL, NULL, NULL, 1)",
            "INSERT IGNORE INTO learning_quizzes (quiz_id, title, category, description, uploaded_by) VALUES " +
                "('LQ-001', 'Nanophysics Basics Quiz', 'Nanophysics Fundamentals', 'Quick revision quiz on nanoscale concepts.', 1)",
            "INSERT IGNORE INTO learning_quiz_questions " +
                "(question_id, quiz_id, question_order, question_text, option_a, option_b, option_c, option_d, correct_option, explanation) VALUES " +
                "('LQ-001-Q1', 'LQ-001', 1, 'Why do materials at the nanoscale often behave differently from bulk materials?', " +
                "'Because gravity becomes stronger', 'Because quantum and surface effects become significant', 'Because they stop interacting with light', 'Because atoms disappear', 'B', " +
                "'At the nanoscale, quantum confinement and high surface-to-volume ratio strongly affect behavior.')",
            "INSERT IGNORE INTO learning_quiz_questions " +
                "(question_id, quiz_id, question_order, question_text, option_a, option_b, option_c, option_d, correct_option, explanation) VALUES " +
                "('LQ-001-Q2', 'LQ-001', 2, 'Which property is commonly associated with gold nanoparticles?', " +
                "'Localized surface plasmon resonance', 'Superconductivity at room temperature', 'Permanent magnetism in all cases', 'Infinite thermal conductivity', 'A', " +
                "'Gold nanoparticles are well known for plasmonic optical behavior.')",
            "INSERT IGNORE INTO learning_quiz_questions " +
                "(question_id, quiz_id, question_order, question_text, option_a, option_b, option_c, option_d, correct_option, explanation) VALUES " +
                "('LQ-001-Q3', 'LQ-001', 3, 'What happens to surface-to-volume ratio as particle size decreases?', " +
                "'It decreases', 'It stays constant', 'It increases', 'It becomes zero', 'C', " +
                "'Smaller particles expose proportionally more surface area relative to their volume.')"
        };

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            for (String sql : statements) {
                stmt.executeUpdate(sql);
            }
            System.out.println("Learning schema setup complete.");
        } catch (Exception e) {
            System.out.println("Learning schema setup failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
