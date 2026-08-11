package com.omrs.dao;

import com.omrs.config.DBConnection;
import com.omrs.model.LearningMaterial;
import com.omrs.model.LearningQuiz;
import com.omrs.model.LearningQuizAttempt;
import com.omrs.model.LearningQuizQuestion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class LearningDAO {

    public List<LearningMaterial> getAllMaterials() {
        List<LearningMaterial> materials = new ArrayList<>();
        String sql = "SELECT lm.*, u.username, u.full_name FROM learning_materials lm " +
                     "JOIN users u ON lm.uploaded_by = u.user_id ORDER BY lm.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                materials.add(mapMaterial(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return materials;
    }

    public List<LearningMaterial> getMaterialsByAuthor(int userId) {
        List<LearningMaterial> materials = new ArrayList<>();
        String sql = "SELECT lm.*, u.username, u.full_name FROM learning_materials lm " +
                     "JOIN users u ON lm.uploaded_by = u.user_id WHERE lm.uploaded_by=? ORDER BY lm.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                materials.add(mapMaterial(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return materials;
    }

    public LearningMaterial getMaterialById(String materialId) {
        String sql = "SELECT lm.*, u.username, u.full_name FROM learning_materials lm " +
                     "JOIN users u ON lm.uploaded_by = u.user_id WHERE lm.material_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, materialId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapMaterial(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean createMaterial(LearningMaterial material) {
        String sql = "INSERT INTO learning_materials " +
                     "(material_id, title, category, description, content, external_link, file_name, file_path, uploaded_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, material.getMaterialId());
            ps.setString(2, material.getTitle());
            ps.setString(3, material.getCategory());
            ps.setString(4, material.getDescription());
            ps.setString(5, material.getContent());
            ps.setString(6, material.getExternalLink());
            ps.setString(7, material.getFileName());
            ps.setString(8, material.getFilePath());
            ps.setInt(9, material.getUploadedByUserId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean deleteMaterial(String materialId, int userId) {
        String sql = "DELETE FROM learning_materials WHERE material_id=? AND uploaded_by=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, materialId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public List<LearningQuiz> getAllQuizzes() {
        List<LearningQuiz> quizzes = new ArrayList<>();
        String sql = "SELECT q.*, u.username, u.full_name, " +
                     "(SELECT COUNT(*) FROM learning_quiz_questions qq WHERE qq.quiz_id=q.quiz_id) AS question_count, " +
                     "(SELECT COUNT(*) FROM learning_quiz_attempts qa WHERE qa.quiz_id=q.quiz_id) AS total_attempts " +
                     "FROM learning_quizzes q " +
                     "JOIN users u ON q.uploaded_by = u.user_id ORDER BY q.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                quizzes.add(mapQuiz(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return quizzes;
    }

    public List<LearningQuiz> getQuizzesByAuthor(int userId) {
        List<LearningQuiz> quizzes = new ArrayList<>();
        String sql = "SELECT q.*, u.username, u.full_name, " +
                     "(SELECT COUNT(*) FROM learning_quiz_questions qq WHERE qq.quiz_id=q.quiz_id) AS question_count, " +
                     "(SELECT COUNT(*) FROM learning_quiz_attempts qa WHERE qa.quiz_id=q.quiz_id) AS total_attempts " +
                     "FROM learning_quizzes q " +
                     "JOIN users u ON q.uploaded_by = u.user_id WHERE q.uploaded_by=? ORDER BY q.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                quizzes.add(mapQuiz(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return quizzes;
    }

    public LearningQuiz getQuizById(String quizId) {
        String sql = "SELECT q.*, u.username, u.full_name, " +
                     "(SELECT COUNT(*) FROM learning_quiz_questions qq WHERE qq.quiz_id=q.quiz_id) AS question_count, " +
                     "(SELECT COUNT(*) FROM learning_quiz_attempts qa WHERE qa.quiz_id=q.quiz_id) AS total_attempts " +
                     "FROM learning_quizzes q " +
                     "JOIN users u ON q.uploaded_by = u.user_id WHERE q.quiz_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quizId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                LearningQuiz quiz = mapQuiz(rs);
                quiz.setQuestions(getQuizQuestions(quizId));
                return quiz;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public List<LearningQuizQuestion> getQuizQuestions(String quizId) {
        List<LearningQuizQuestion> questions = new ArrayList<>();
        String sql = "SELECT * FROM learning_quiz_questions WHERE quiz_id=? ORDER BY question_order";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quizId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                questions.add(mapQuestion(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return questions;
    }

    public boolean createQuiz(LearningQuiz quiz) {
        String quizSql = "INSERT INTO learning_quizzes (quiz_id, title, category, description, uploaded_by) VALUES (?, ?, ?, ?, ?)";
        String questionSql = "INSERT INTO learning_quiz_questions " +
                             "(question_id, quiz_id, question_order, question_text, option_a, option_b, option_c, option_d, correct_option, explanation) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement quizPs = conn.prepareStatement(quizSql)) {
                quizPs.setString(1, quiz.getQuizId());
                quizPs.setString(2, quiz.getTitle());
                quizPs.setString(3, quiz.getCategory());
                quizPs.setString(4, quiz.getDescription());
                quizPs.setInt(5, quiz.getUploadedByUserId());
                quizPs.executeUpdate();
            }

            try (PreparedStatement questionPs = conn.prepareStatement(questionSql)) {
                for (LearningQuizQuestion question : quiz.getQuestions()) {
                    questionPs.setString(1, question.getQuestionId());
                    questionPs.setString(2, quiz.getQuizId());
                    questionPs.setInt(3, question.getQuestionOrder());
                    questionPs.setString(4, question.getQuestionText());
                    questionPs.setString(5, question.getOptionA());
                    questionPs.setString(6, question.getOptionB());
                    questionPs.setString(7, question.getOptionC());
                    questionPs.setString(8, question.getOptionD());
                    questionPs.setString(9, question.getCorrectOption());
                    questionPs.setString(10, question.getExplanation());
                    questionPs.addBatch();
                }
                questionPs.executeBatch();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    public boolean deleteQuiz(String quizId, int userId) {
        String sql = "DELETE FROM learning_quizzes WHERE quiz_id=? AND uploaded_by=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quizId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean saveQuizAttempt(LearningQuizAttempt attempt) {
        String sql = "INSERT INTO learning_quiz_attempts (attempt_id, quiz_id, user_id, score, total_questions) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, attempt.getAttemptId());
            ps.setString(2, attempt.getQuizId());
            ps.setInt(3, attempt.getUserId());
            ps.setInt(4, attempt.getScore());
            ps.setInt(5, attempt.getTotalQuestions());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public LearningQuizAttempt getLatestAttempt(String quizId, int userId) {
        String sql = "SELECT qa.*, u.username FROM learning_quiz_attempts qa " +
                     "JOIN users u ON qa.user_id = u.user_id " +
                     "WHERE qa.quiz_id=? AND qa.user_id=? ORDER BY qa.submitted_at DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quizId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapAttempt(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public List<LearningQuizAttempt> getAttemptsForQuiz(String quizId) {
        List<LearningQuizAttempt> attempts = new ArrayList<>();
        String sql = "SELECT qa.*, u.username FROM learning_quiz_attempts qa " +
                     "JOIN users u ON qa.user_id = u.user_id WHERE qa.quiz_id=? ORDER BY qa.submitted_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quizId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                attempts.add(mapAttempt(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return attempts;
    }

    public String generateMaterialId() {
        return generateId("learning_materials", "material_id", "LM-", 3);
    }

    public String generateQuizId() {
        return generateId("learning_quizzes", "quiz_id", "LQ-", 3);
    }

    public String generateQuestionId() {
        return generateId("learning_quiz_questions", "question_id", "QQ-", 4);
    }

    public String generateAttemptId() {
        return generateId("learning_quiz_attempts", "attempt_id", "QA-", 4);
    }

    private String generateId(String tableName, String columnName, String prefix, int digits) {
        String sql = "SELECT MAX(CAST(SUBSTRING(" + columnName + ", " + (prefix.length() + 1) + ") AS UNSIGNED)) AS max_id FROM " + tableName;
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                int maxId = rs.getInt("max_id");
                return String.format(prefix + "%0" + digits + "d", maxId + 1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return String.format(prefix + "%0" + digits + "d", 1);
    }

    private LearningMaterial mapMaterial(ResultSet rs) throws SQLException {
        LearningMaterial material = new LearningMaterial();
        material.setMaterialId(rs.getString("material_id"));
        material.setTitle(rs.getString("title"));
        material.setCategory(rs.getString("category"));
        material.setDescription(rs.getString("description"));
        material.setContent(rs.getString("content"));
        material.setExternalLink(rs.getString("external_link"));
        material.setFileName(rs.getString("file_name"));
        material.setFilePath(rs.getString("file_path"));
        material.setUploadedByUserId(rs.getInt("uploaded_by"));
        String fullName = rs.getString("full_name");
        material.setUploadedByName(fullName != null && !fullName.isEmpty() ? fullName : rs.getString("username"));
        material.setCreatedAt(rs.getTimestamp("created_at"));
        material.setUpdatedAt(rs.getTimestamp("updated_at"));
        return material;
    }

    private LearningQuiz mapQuiz(ResultSet rs) throws SQLException {
        LearningQuiz quiz = new LearningQuiz();
        quiz.setQuizId(rs.getString("quiz_id"));
        quiz.setTitle(rs.getString("title"));
        quiz.setCategory(rs.getString("category"));
        quiz.setDescription(rs.getString("description"));
        quiz.setUploadedByUserId(rs.getInt("uploaded_by"));
        String fullName = rs.getString("full_name");
        quiz.setUploadedByName(fullName != null && !fullName.isEmpty() ? fullName : rs.getString("username"));
        quiz.setQuestionCount(rs.getInt("question_count"));
        quiz.setTotalAttempts(rs.getInt("total_attempts"));
        quiz.setCreatedAt(rs.getTimestamp("created_at"));
        return quiz;
    }

    private LearningQuizQuestion mapQuestion(ResultSet rs) throws SQLException {
        LearningQuizQuestion question = new LearningQuizQuestion();
        question.setQuestionId(rs.getString("question_id"));
        question.setQuizId(rs.getString("quiz_id"));
        question.setQuestionOrder(rs.getInt("question_order"));
        question.setQuestionText(rs.getString("question_text"));
        question.setOptionA(rs.getString("option_a"));
        question.setOptionB(rs.getString("option_b"));
        question.setOptionC(rs.getString("option_c"));
        question.setOptionD(rs.getString("option_d"));
        question.setCorrectOption(rs.getString("correct_option"));
        question.setExplanation(rs.getString("explanation"));
        return question;
    }

    private LearningQuizAttempt mapAttempt(ResultSet rs) throws SQLException {
        LearningQuizAttempt attempt = new LearningQuizAttempt();
        attempt.setAttemptId(rs.getString("attempt_id"));
        attempt.setQuizId(rs.getString("quiz_id"));
        attempt.setUserId(rs.getInt("user_id"));
        attempt.setUsername(rs.getString("username"));
        attempt.setScore(rs.getInt("score"));
        attempt.setTotalQuestions(rs.getInt("total_questions"));
        attempt.setSubmittedAt(rs.getTimestamp("submitted_at"));
        return attempt;
    }
}
