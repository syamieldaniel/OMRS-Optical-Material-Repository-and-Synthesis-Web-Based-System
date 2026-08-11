package com.omrs.dao;

import com.omrs.config.DBConnection;
import com.omrs.model.Experiment;
import com.omrs.model.RepositoryComment;
import com.omrs.model.TestData;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

/**
 * Data Access Object for Repository operations.
 * Provides methods to search, browse, and retrieve approved experiments
 * similar to refractiveindex.info functionality.
 */
public class RepositoryDAO {
    
    /**
     * Get all approved experiments for the public repository
     */
    public List<Experiment> getAllApproved() {
        List<Experiment> list = new ArrayList<>();
        String sql = "SELECT e.*, u.username as student_name, u.full_name as student_full_name " +
                     "FROM experiments e " +
                     "JOIN students s ON e.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "LEFT JOIN supervisors sv ON s.supervisor_id = sv.supervisor_id " +
                     "WHERE e.status = 'APPROVED' " +
                     "ORDER BY e.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Experiment e = mapExperiment(rs);
                e.setStudentName(rs.getString("student_full_name") != null ? 
                    rs.getString("student_full_name") : rs.getString("student_name"));
                list.add(e);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    /**
     * Search experiments with multiple filters
     * @param keyword Search term for title and notes
     * @param materialType Filter by material type
     * @param dateFrom Start date filter
     * @param dateTo End date filter
     * @param testType Filter by test data type (SEM, UV, FTIR)
     */
    public List<Experiment> search(String keyword, String materialType, 
                                   String dateFrom, String dateTo, String testType) {
        List<Experiment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DISTINCT e.*, u.username as student_name, u.full_name as student_full_name ");
        sql.append("FROM experiments e ");
        sql.append("JOIN students s ON e.student_id = s.student_id ");
        sql.append("JOIN users u ON s.user_id = u.user_id ");
        
        if (testType != null && !testType.isEmpty()) {
            sql.append("JOIN test_data td ON e.experiment_id = td.experiment_id ");
        }
        
        sql.append("WHERE e.status = 'APPROVED' ");
        
        List<Object> params = new ArrayList<>();
        
        // Keyword search in title and preparation notes
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(e.title) LIKE ? OR LOWER(e.preparation_notes) LIKE ? OR LOWER(e.concentration) LIKE ?) ");
            String searchTerm = "%" + keyword.toLowerCase().trim() + "%";
            params.add(searchTerm);
            params.add(searchTerm);
            params.add(searchTerm);
        }
        
        // Material type filter
        if (materialType != null && !materialType.isEmpty()) {
            sql.append("AND e.material_type = ? ");
            params.add(materialType);
        }
        
        // Date range filter
        if (dateFrom != null && !dateFrom.isEmpty()) {
            sql.append("AND e.experiment_date >= ? ");
            params.add(Date.valueOf(dateFrom));
        }
        if (dateTo != null && !dateTo.isEmpty()) {
            sql.append("AND e.experiment_date <= ? ");
            params.add(Date.valueOf(dateTo));
        }
        
        // Test type filter
        if (testType != null && !testType.isEmpty()) {
            sql.append("AND td.test_type = ? ");
            params.add(testType);
        }
        
        sql.append("ORDER BY e.created_at DESC");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Date) {
                    ps.setDate(i + 1, (Date) param);
                }
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Experiment e = mapExperiment(rs);
                e.setStudentName(rs.getString("student_full_name") != null ? 
                    rs.getString("student_full_name") : rs.getString("student_name"));
                list.add(e);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    /**
     * Get experiments grouped by material type for category browsing
     */
    public Map<String, List<Experiment>> getGroupedByMaterial() {
        Map<String, List<Experiment>> grouped = new HashMap<>();
        List<Experiment> all = getAllApproved();
        
        for (Experiment e : all) {
            String material = e.getMaterialType();
            if (!grouped.containsKey(material)) {
                grouped.put(material, new ArrayList<>());
            }
            grouped.get(material).add(e);
        }
        return grouped;
    }
    
    /**
     * Get all unique material types in the repository
     */
    public List<String> getMaterialTypes() {
        List<String> types = new ArrayList<>();
        String sql = "SELECT DISTINCT material_type FROM experiments WHERE status = 'APPROVED' ORDER BY material_type";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                types.add(rs.getString("material_type"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return types;
    }
    
    /**
     * Get experiments by material type
     */
    public List<Experiment> getByMaterialType(String materialType) {
        List<Experiment> list = new ArrayList<>();
        String sql = "SELECT e.*, u.username as student_name, u.full_name as student_full_name " +
                     "FROM experiments e " +
                     "JOIN students s ON e.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "WHERE e.status = 'APPROVED' AND e.material_type = ? " +
                     "ORDER BY e.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, materialType);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Experiment e = mapExperiment(rs);
                e.setStudentName(rs.getString("student_full_name") != null ? 
                    rs.getString("student_full_name") : rs.getString("student_name"));
                list.add(e);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    /**
     * Get experiment details by ID (only approved)
     */
    public Experiment getApprovedById(String experimentId) {
        String sql = "SELECT e.*, u.username as student_name, u.full_name as student_full_name, " +
                     "u.email as student_email, " +
                     "su.full_name as supervisor_name " +
                     "FROM experiments e " +
                     "JOIN students s ON e.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "LEFT JOIN supervisors sv ON s.supervisor_id = sv.supervisor_id " +
                     "LEFT JOIN users su ON sv.user_id = su.user_id " +
                     "WHERE e.experiment_id = ? AND e.status = 'APPROVED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, experimentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Experiment e = mapExperiment(rs);
                e.setStudentName(rs.getString("student_full_name") != null ? 
                    rs.getString("student_full_name") : rs.getString("student_name"));
                e.setTestFiles(getTestData(experimentId));
                return e;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
    
    /**
     * Get repository statistics
     */
    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            // Total approved experiments
            PreparedStatement ps1 = conn.prepareStatement(
                "SELECT COUNT(*) as total FROM experiments WHERE status = 'APPROVED'");
            ResultSet rs1 = ps1.executeQuery();
            if (rs1.next()) stats.put("totalExperiments", rs1.getInt("total"));
            
            // Total materials count
            PreparedStatement ps2 = conn.prepareStatement(
                "SELECT COUNT(DISTINCT material_type) as total FROM experiments WHERE status = 'APPROVED'");
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) stats.put("totalMaterials", rs2.getInt("total"));
            
            // Total test data files
            PreparedStatement ps3 = conn.prepareStatement(
                "SELECT COUNT(*) as total FROM test_data td " +
                "JOIN experiments e ON td.experiment_id = e.experiment_id " +
                "WHERE e.status = 'APPROVED'");
            ResultSet rs3 = ps3.executeQuery();
            if (rs3.next()) stats.put("totalTestData", rs3.getInt("total"));
            
            // Count by material type
            PreparedStatement ps4 = conn.prepareStatement(
                "SELECT material_type, COUNT(*) as count FROM experiments " +
                "WHERE status = 'APPROVED' GROUP BY material_type ORDER BY count DESC");
            ResultSet rs4 = ps4.executeQuery();
            Map<String, Integer> materialCounts = new HashMap<>();
            while (rs4.next()) {
                materialCounts.put(rs4.getString("material_type"), rs4.getInt("count"));
            }
            stats.put("materialCounts", materialCounts);
            
            // Count by test type
            PreparedStatement ps5 = conn.prepareStatement(
                "SELECT td.test_type, COUNT(*) as count FROM test_data td " +
                "JOIN experiments e ON td.experiment_id = e.experiment_id " +
                "WHERE e.status = 'APPROVED' GROUP BY td.test_type");
            ResultSet rs5 = ps5.executeQuery();
            Map<String, Integer> testTypeCounts = new HashMap<>();
            while (rs5.next()) {
                testTypeCounts.put(rs5.getString("test_type"), rs5.getInt("count"));
            }
            stats.put("testTypeCounts", testTypeCounts);
            
            // Recent experiments (last 5)
            PreparedStatement ps6 = conn.prepareStatement(
                "SELECT e.*, u.full_name as student_name FROM experiments e " +
                "JOIN students s ON e.student_id = s.student_id " +
                "JOIN users u ON s.user_id = u.user_id " +
                "WHERE e.status = 'APPROVED' ORDER BY e.created_at DESC LIMIT 5");
            ResultSet rs6 = ps6.executeQuery();
            List<Experiment> recent = new ArrayList<>();
            while (rs6.next()) {
                Experiment exp = mapExperiment(rs6);
                exp.setStudentName(rs6.getString("student_name"));
                recent.add(exp);
            }
            stats.put("recentExperiments", recent);
            
        } catch (Exception e) { 
            System.err.println("RepositoryDAO.getStatistics() error: " + e.getMessage());
            e.printStackTrace(System.err);
        }
        
        return stats;
    }
    
    /**
     * Get test data for an experiment
     */
    public List<TestData> getTestData(String expId) {
        List<TestData> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM test_data WHERE experiment_id = ?")) {
            ps.setString(1, expId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TestData t = new TestData();
                t.setTestDataId(rs.getString("test_data_id"));
                t.setExperimentId(rs.getString("experiment_id"));
                t.setTestType(rs.getString("test_type"));
                t.setFileName(rs.getString("file_name"));
                t.setFilePath(rs.getString("file_path"));
                t.setFileSize(rs.getString("file_size"));
                list.add(t);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    /**
     * Get paginated results
     */
    public List<Experiment> getApprovedPaginated(int page, int pageSize) {
        List<Experiment> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT e.*, u.username as student_name, u.full_name as student_full_name " +
                     "FROM experiments e " +
                     "JOIN students s ON e.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "WHERE e.status = 'APPROVED' " +
                     "ORDER BY e.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, offset);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Experiment e = mapExperiment(rs);
                e.setStudentName(rs.getString("student_full_name") != null ? 
                    rs.getString("student_full_name") : rs.getString("student_name"));
                list.add(e);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    /**
     * Get total count of approved experiments
     */
    public int getTotalApprovedCount() {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COUNT(*) as total FROM experiments WHERE status = 'APPROVED'")) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
    
    /**
     * Map ResultSet to Experiment object
     */
    private Experiment mapExperiment(ResultSet rs) throws SQLException {
        Experiment e = new Experiment();
        e.setExperimentId(rs.getString("experiment_id"));
        e.setStudentId(rs.getString("student_id"));
        e.setTitle(rs.getString("title"));
        e.setExperimentDate(rs.getDate("experiment_date"));
        e.setMaterialType(rs.getString("material_type"));
        e.setConcentration(rs.getString("concentration"));
        e.setStudyObjective(rs.getString("study_objective"));
        e.setHypothesis(getStringIfPresent(rs, "hypothesis"));
        e.setIndependentVariable(getStringIfPresent(rs, "independent_variable"));
        e.setDependentVariable(getStringIfPresent(rs, "dependent_variable"));
        e.setControlledVariables(getStringIfPresent(rs, "controlled_variables"));
        e.setPreparationNotes(rs.getString("preparation_notes"));
        e.setCharacterizationMethods(rs.getString("characterization_methods"));
        e.setCharacterizationNotes(rs.getString("characterization_notes"));
        e.setInstrumentDetails(getStringIfPresent(rs, "instrument_details"));
        e.setScanRange(getStringIfPresent(rs, "scan_range"));
        e.setCalibrationReference(getStringIfPresent(rs, "calibration_reference"));
        e.setReplicateCount(getIntegerIfPresent(rs, "replicate_count"));
        e.setMeasurementUncertainty(getStringIfPresent(rs, "measurement_uncertainty"));
        e.setRawDataRequired(getBooleanIfPresent(rs, "raw_data_required"));
        e.setConclusion(getStringIfPresent(rs, "conclusion"));
        e.setLimitations(getStringIfPresent(rs, "limitations"));
        e.setNextSteps(getStringIfPresent(rs, "next_steps"));
        e.setSampleOneName(rs.getString("sample_1_name"));
        e.setSampleOneCondition(rs.getString("sample_1_condition"));
        e.setSampleOneNotes(rs.getString("sample_1_notes"));
        e.setSampleTwoName(rs.getString("sample_2_name"));
        e.setSampleTwoCondition(rs.getString("sample_2_condition"));
        e.setSampleTwoNotes(rs.getString("sample_2_notes"));
        e.setSampleThreeName(rs.getString("sample_3_name"));
        e.setSampleThreeCondition(rs.getString("sample_3_condition"));
        e.setSampleThreeNotes(rs.getString("sample_3_notes"));
        e.setStatus(rs.getString("status"));
        e.setFeedback(rs.getString("feedback"));
        return e;
    }

    private String getStringIfPresent(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) return null;
        return rs.getString(columnName);
    }

    private Integer getIntegerIfPresent(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) return null;
        int value = rs.getInt(columnName);
        return rs.wasNull() ? null : value;
    }

    private Boolean getBooleanIfPresent(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) return null;
        boolean value = rs.getBoolean(columnName);
        return rs.wasNull() ? null : value;
    }

    private boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData meta = rs.getMetaData();
        for (int i = 1; i <= meta.getColumnCount(); i++) {
            if (columnName.equalsIgnoreCase(meta.getColumnLabel(i))) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Get a specific test data file by ID
     */
    public TestData getTestDataById(String testDataId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM test_data WHERE test_data_id = ?")) {
            ps.setString(1, testDataId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                TestData t = new TestData();
                t.setTestDataId(rs.getString("test_data_id"));
                t.setExperimentId(rs.getString("experiment_id"));
                t.setTestType(rs.getString("test_type"));
                t.setFileName(rs.getString("file_name"));
                t.setFilePath(rs.getString("file_path"));
                t.setFileSize(rs.getString("file_size"));
                return t;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Get all comments for an approved repository experiment.
     */
    public List<RepositoryComment> getComments(String experimentId) {
        ensureRepositoryCommentsTable();
        List<RepositoryComment> comments = new ArrayList<>();
        String sql = "SELECT rc.*, u.username, u.full_name, u.role " +
                     "FROM repository_comments rc " +
                     "JOIN users u ON rc.user_id = u.user_id " +
                     "JOIN experiments e ON rc.experiment_id = e.experiment_id " +
                     "WHERE rc.experiment_id = ? AND e.status = 'APPROVED' " +
                     "ORDER BY rc.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, experimentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RepositoryComment comment = new RepositoryComment();
                comment.setCommentId(rs.getString("comment_id"));
                comment.setExperimentId(rs.getString("experiment_id"));
                comment.setUserId(rs.getInt("user_id"));
                String fullName = rs.getString("full_name");
                comment.setUserName(fullName != null && !fullName.trim().isEmpty()
                    ? fullName : rs.getString("username"));
                comment.setUserRole(rs.getString("role"));
                comment.setCommentText(rs.getString("comment_text"));
                comment.setCreatedAt(rs.getTimestamp("created_at"));
                comments.add(comment);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return comments;
    }

    public Map<String, Integer> getCommentCounts(List<Experiment> experiments) {
        ensureRepositoryCommentsTable();
        Map<String, Integer> counts = new HashMap<>();
        if (experiments == null || experiments.isEmpty()) return counts;

        StringBuilder sql = new StringBuilder("SELECT experiment_id, COUNT(*) AS count FROM repository_comments WHERE experiment_id IN (");
        for (int i = 0; i < experiments.size(); i++) {
            if (i > 0) sql.append(",");
            sql.append("?");
            counts.put(experiments.get(i).getExperimentId(), 0);
        }
        sql.append(") GROUP BY experiment_id");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < experiments.size(); i++) {
                ps.setString(i + 1, experiments.get(i).getExperimentId());
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                counts.put(rs.getString("experiment_id"), rs.getInt("count"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return counts;
    }

    /**
     * Add a comment to an approved repository experiment.
     */
    public boolean addComment(String experimentId, int userId, String commentText) {
        ensureRepositoryCommentsTable();
        String sql = "INSERT INTO repository_comments (comment_id, experiment_id, user_id, comment_text) " +
                     "SELECT ?, e.experiment_id, ?, ? FROM experiments e " +
                     "WHERE e.experiment_id = ? AND e.status = 'APPROVED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, generateCommentId());
            ps.setInt(2, userId);
            ps.setString(3, commentText);
            ps.setString(4, experimentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean deleteComment(String commentId, int userId, boolean moderator) {
        ensureRepositoryCommentsTable();
        String sql = moderator
                ? "DELETE FROM repository_comments WHERE comment_id = ?"
                : "DELETE FROM repository_comments WHERE comment_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, commentId);
            if (!moderator) {
                ps.setInt(2, userId);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public Integer getExperimentOwnerUserId(String experimentId) {
        String sql = "SELECT u.user_id FROM experiments e " +
                     "JOIN students s ON e.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "WHERE e.experiment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, experimentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("user_id");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    private String generateCommentId() {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(
                "SELECT MAX(CAST(SUBSTRING(comment_id, 4) AS UNSIGNED)) as max_id FROM repository_comments");
            if (rs.next()) {
                return String.format("RC-%03d", rs.getInt("max_id") + 1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return "RC-" + System.currentTimeMillis();
    }

    private void ensureRepositoryCommentsTable() {
        String sql = "CREATE TABLE IF NOT EXISTS repository_comments (" +
                     "comment_id VARCHAR(20) PRIMARY KEY, " +
                     "experiment_id VARCHAR(20) NOT NULL, " +
                     "user_id INT NOT NULL, " +
                     "comment_text TEXT NOT NULL, " +
                     "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                     "FOREIGN KEY (experiment_id) REFERENCES experiments(experiment_id) ON DELETE CASCADE, " +
                     "FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE" +
                     ")";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            st.executeUpdate(sql);
        } catch (Exception e) { e.printStackTrace(); }
    }
}
