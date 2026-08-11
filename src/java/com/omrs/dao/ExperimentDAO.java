package com.omrs.dao;

import com.omrs.config.DBConnection;
import com.omrs.model.Experiment;
import com.omrs.model.TestData;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExperimentDAO {
    private static boolean comparisonSchemaChecked = false;
    
    public List<Experiment> getByStudent(String studentId) {
        ensureComparisonSchema();
        List<Experiment> list = new ArrayList<>();
        String sql = "SELECT * FROM experiments WHERE student_id=? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    public Experiment getById(String id) {
        ensureComparisonSchema();
        String sql = "SELECT e.*, u.username as student_name, u.full_name as student_full_name FROM experiments e " +
                     "JOIN students s ON e.student_id=s.student_id " +
                     "JOIN users u ON s.user_id=u.user_id WHERE e.experiment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Experiment e = map(rs);
                String fullName = rs.getString("student_full_name");
                e.setStudentName(fullName != null && !fullName.isEmpty() ? fullName : rs.getString("student_name"));
                e.setTestFiles(getTestData(id));
                return e;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
    
    public boolean create(Experiment e) {
        ensureComparisonSchema();
        String sql = "INSERT INTO experiments (" +
                "experiment_id, student_id, title, experiment_date, material_type, concentration, study_type, material_b_type, material_b_concentration, " +
                "comparison_metric_label, material_a_metric_value, material_b_metric_value, comparison_notes, study_objective, hypothesis, independent_variable, " +
                "dependent_variable, controlled_variables, preparation_notes, characterization_methods, characterization_notes, instrument_details, scan_range, " +
                "calibration_reference, replicate_count, measurement_uncertainty, raw_data_required, conclusion, limitations, next_steps, comparison_table_data, sample_1_name, sample_1_condition, sample_1_notes, " +
                "sample_2_name, sample_2_condition, sample_2_notes, sample_3_name, sample_3_condition, sample_3_notes, status" +
                ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, e.getExperimentId());
            ps.setString(2, e.getStudentId());
            ps.setString(3, e.getTitle());
            ps.setDate(4, e.getExperimentDate());
            ps.setString(5, e.getMaterialType());
            ps.setString(6, e.getConcentration());
            ps.setString(7, e.getStudyType());
            ps.setString(8, e.getMaterialBType());
            ps.setString(9, e.getMaterialBConcentration());
            ps.setString(10, e.getComparisonMetricLabel());
            setNullableDouble(ps, 11, e.getMaterialAMetricValue());
            setNullableDouble(ps, 12, e.getMaterialBMetricValue());
            ps.setString(13, e.getComparisonNotes());
            ps.setString(14, e.getStudyObjective());
            ps.setString(15, e.getHypothesis());
            ps.setString(16, e.getIndependentVariable());
            ps.setString(17, e.getDependentVariable());
            ps.setString(18, e.getControlledVariables());
            ps.setString(19, e.getPreparationNotes());
            ps.setString(20, e.getCharacterizationMethods());
            ps.setString(21, e.getCharacterizationNotes());
            ps.setString(22, e.getInstrumentDetails());
            ps.setString(23, e.getScanRange());
            ps.setString(24, e.getCalibrationReference());
            setNullableInteger(ps, 25, e.getReplicateCount());
            ps.setString(26, e.getMeasurementUncertainty());
            setNullableBoolean(ps, 27, e.getRawDataRequired());
            ps.setString(28, e.getConclusion());
            ps.setString(29, e.getLimitations());
            ps.setString(30, e.getNextSteps());
            ps.setString(31, e.getComparisonTableData());
            ps.setString(32, e.getSampleOneName());
            ps.setString(33, e.getSampleOneCondition());
            ps.setString(34, e.getSampleOneNotes());
            ps.setString(35, e.getSampleTwoName());
            ps.setString(36, e.getSampleTwoCondition());
            ps.setString(37, e.getSampleTwoNotes());
            ps.setString(38, e.getSampleThreeName());
            ps.setString(39, e.getSampleThreeCondition());
            ps.setString(40, e.getSampleThreeNotes());
            ps.setString(41, e.getStatus());
            return ps.executeUpdate() > 0;
        } catch (Exception ex) { ex.printStackTrace(); }
        return false;
    }
    
    public boolean update(Experiment e) {
        ensureComparisonSchema();
        String sql = "UPDATE experiments SET title=?, experiment_date=?, material_type=?, concentration=?, study_objective=?, " +
                "hypothesis=?, independent_variable=?, dependent_variable=?, controlled_variables=?, preparation_notes=?, " +
                "characterization_methods=?, characterization_notes=?, instrument_details=?, scan_range=?, calibration_reference=?, " +
                "replicate_count=?, measurement_uncertainty=?, raw_data_required=?, conclusion=?, limitations=?, next_steps=?, " +
                "sample_1_name=?, sample_1_condition=?, sample_1_notes=?, sample_2_name=?, sample_2_condition=?, sample_2_notes=?, " +
                "sample_3_name=?, sample_3_condition=?, sample_3_notes=?, study_type=?, material_b_type=?, material_b_concentration=?, " +
                "comparison_metric_label=?, material_a_metric_value=?, material_b_metric_value=?, comparison_notes=?, comparison_table_data=?, " +
                "status=?, feedback=? WHERE experiment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, e.getTitle());
            ps.setDate(2, e.getExperimentDate());
            ps.setString(3, e.getMaterialType());
            ps.setString(4, e.getConcentration());
            ps.setString(5, e.getStudyObjective());
            ps.setString(6, e.getHypothesis());
            ps.setString(7, e.getIndependentVariable());
            ps.setString(8, e.getDependentVariable());
            ps.setString(9, e.getControlledVariables());
            ps.setString(10, e.getPreparationNotes());
            ps.setString(11, e.getCharacterizationMethods());
            ps.setString(12, e.getCharacterizationNotes());
            ps.setString(13, e.getInstrumentDetails());
            ps.setString(14, e.getScanRange());
            ps.setString(15, e.getCalibrationReference());
            setNullableInteger(ps, 16, e.getReplicateCount());
            ps.setString(17, e.getMeasurementUncertainty());
            setNullableBoolean(ps, 18, e.getRawDataRequired());
            ps.setString(19, e.getConclusion());
            ps.setString(20, e.getLimitations());
            ps.setString(21, e.getNextSteps());
            ps.setString(22, e.getSampleOneName());
            ps.setString(23, e.getSampleOneCondition());
            ps.setString(24, e.getSampleOneNotes());
            ps.setString(25, e.getSampleTwoName());
            ps.setString(26, e.getSampleTwoCondition());
            ps.setString(27, e.getSampleTwoNotes());
            ps.setString(28, e.getSampleThreeName());
            ps.setString(29, e.getSampleThreeCondition());
            ps.setString(30, e.getSampleThreeNotes());
            ps.setString(31, e.getStudyType());
            ps.setString(32, e.getMaterialBType());
            ps.setString(33, e.getMaterialBConcentration());
            ps.setString(34, e.getComparisonMetricLabel());
            setNullableDouble(ps, 35, e.getMaterialAMetricValue());
            setNullableDouble(ps, 36, e.getMaterialBMetricValue());
            ps.setString(37, e.getComparisonNotes());
            ps.setString(38, e.getComparisonTableData());
            ps.setString(39, e.getStatus());
            ps.setString(40, e.getFeedback());
            ps.setString(41, e.getExperimentId());
            return ps.executeUpdate() > 0;
        } catch (Exception ex) { ex.printStackTrace(); }
        return false;
    }

    public Integer getOwnerUserId(String experimentId) {
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
    
    public boolean delete(String id) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM experiments WHERE experiment_id=?")) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    public List<Experiment> getPending(String supervisorId) {
        ensureComparisonSchema();
        List<Experiment> list = new ArrayList<>();
        String sql = "SELECT e.*, u.username as student_name, u.full_name as student_full_name FROM experiments e " +
                     "JOIN students s ON e.student_id=s.student_id " +
                     "JOIN users u ON s.user_id=u.user_id " +
                     "WHERE s.supervisor_id=? AND e.status='PENDING' ORDER BY e.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Experiment e = map(rs);
                String fullName = rs.getString("student_full_name");
                e.setStudentName(fullName != null && !fullName.isEmpty() ? fullName : rs.getString("student_name"));
                list.add(e);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    public List<Experiment> getApproved(String supervisorId) {
        ensureComparisonSchema();
        List<Experiment> list = new ArrayList<>();
        String sql = "SELECT e.*, u.username as student_name, u.full_name as student_full_name FROM experiments e " +
                     "JOIN students s ON e.student_id=s.student_id " +
                     "JOIN users u ON s.user_id=u.user_id " +
                     "WHERE s.supervisor_id=? AND e.status='APPROVED' ORDER BY e.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Experiment e = map(rs);
                String fullName = rs.getString("student_full_name");
                e.setStudentName(fullName != null && !fullName.isEmpty() ? fullName : rs.getString("student_name"));
                list.add(e);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Experiment> getBySupervisor(String supervisorId) {
        ensureComparisonSchema();
        List<Experiment> list = new ArrayList<>();
        String sql = "SELECT e.*, u.username as student_name, u.full_name as student_full_name FROM experiments e " +
                     "JOIN students s ON e.student_id=s.student_id " +
                     "JOIN users u ON s.user_id=u.user_id " +
                     "WHERE s.supervisor_id=? ORDER BY e.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Experiment e = map(rs);
                String fullName = rs.getString("student_full_name");
                e.setStudentName(fullName != null && !fullName.isEmpty() ? fullName : rs.getString("student_name"));
                list.add(e);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    public int[] getStats(String studentId) {
        ensureComparisonSchema();
        int[] stats = new int[5];
        String sql = "SELECT status, COUNT(*) as cnt FROM experiments WHERE student_id=? GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String s = rs.getString("status");
                int c = rs.getInt("cnt");
                stats[0] += c;
                if ("DRAFT".equals(s)) stats[1] = c;
                else if ("PENDING".equals(s)) stats[2] = c;
                else if ("APPROVED".equals(s)) stats[3] = c;
                else if ("REJECTED".equals(s)) stats[4] = c;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return stats;
    }
    
    public int[] getSupervisorStats(String supervisorId) {
        ensureComparisonSchema();
        int[] stats = new int[4]; // pending, approved, students, totalExperiments
        try (Connection conn = DBConnection.getConnection()) {
            // Pending count
            PreparedStatement ps1 = conn.prepareStatement(
                "SELECT COUNT(*) FROM experiments e JOIN students s ON e.student_id=s.student_id WHERE s.supervisor_id=? AND e.status='PENDING'");
            ps1.setString(1, supervisorId);
            ResultSet rs1 = ps1.executeQuery();
            if (rs1.next()) stats[0] = rs1.getInt(1);
            
            // Approved count
            PreparedStatement ps2 = conn.prepareStatement(
                "SELECT COUNT(*) FROM experiments e JOIN students s ON e.student_id=s.student_id WHERE s.supervisor_id=? AND e.status='APPROVED'");
            ps2.setString(1, supervisorId);
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) stats[1] = rs2.getInt(1);
            
            // Student count
            PreparedStatement ps3 = conn.prepareStatement(
                "SELECT COUNT(*) FROM students s JOIN users u ON s.user_id=u.user_id WHERE s.supervisor_id=? AND u.status='APPROVED'");
            ps3.setString(1, supervisorId);
            ResultSet rs3 = ps3.executeQuery();
            if (rs3.next()) stats[2] = rs3.getInt(1);
            
            // Total experiments
            PreparedStatement ps4 = conn.prepareStatement(
                "SELECT COUNT(*) FROM experiments e JOIN students s ON e.student_id=s.student_id WHERE s.supervisor_id=?");
            ps4.setString(1, supervisorId);
            ResultSet rs4 = ps4.executeQuery();
            if (rs4.next()) stats[3] = rs4.getInt(1);
            
        } catch (Exception e) { e.printStackTrace(); }
        return stats;
    }
    
    public String generateId() {
        ensureComparisonSchema();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery("SELECT MAX(CAST(SUBSTRING(experiment_id, 5) AS UNSIGNED)) as max_id FROM experiments");
            if (rs.next()) {
                int maxId = rs.getInt("max_id");
                return String.format("EXP-%03d", maxId + 1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return "EXP-001";
    }
    
    // Test Data Methods
    public List<TestData> getTestData(String expId) {
        List<TestData> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM test_data WHERE experiment_id=? ORDER BY upload_date DESC")) {
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
                t.setUploadDate(rs.getTimestamp("upload_date"));
                list.add(t);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    public boolean addTestData(TestData t) {
        ensureTestDataSchema();
        String sql = "INSERT INTO test_data (test_data_id, experiment_id, test_type, file_name, file_path, file_size) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTestDataId());
            ps.setString(2, t.getExperimentId());
            ps.setString(3, t.getTestType());
            ps.setString(4, t.getFileName());
            ps.setString(5, t.getFilePath());
            ps.setString(6, t.getFileSize());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    public boolean deleteTestData(String testDataId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM test_data WHERE test_data_id=?")) {
            ps.setString(1, testDataId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    public String generateTestDataId() {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery("SELECT MAX(CAST(SUBSTRING(test_data_id, 4) AS UNSIGNED)) as max_id FROM test_data");
            if (rs.next()) {
                int maxId = rs.getInt("max_id");
                return String.format("TD-%03d", maxId + 1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return "TD-001";
    }
    
    public boolean saveTestData(TestData testData) {
        ensureTestDataSchema();
        String sql = "INSERT INTO test_data (test_data_id, experiment_id, test_type, file_name, file_path, file_size) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, testData.getTestDataId());
            ps.setString(2, testData.getExperimentId());
            ps.setString(3, testData.getTestType());
            ps.setString(4, testData.getFileName());
            ps.setString(5, testData.getFilePath());
            ps.setString(6, testData.getFileSize());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return false;
    }

    private void ensureTestDataSchema() {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            st.executeUpdate("ALTER TABLE test_data MODIFY COLUMN test_type VARCHAR(50) NOT NULL");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private Experiment map(ResultSet rs) throws SQLException {
        Experiment e = new Experiment();
        e.setExperimentId(rs.getString("experiment_id"));
        e.setStudentId(rs.getString("student_id"));
        e.setTitle(rs.getString("title"));
        e.setExperimentDate(rs.getDate("experiment_date"));
        e.setMaterialType(rs.getString("material_type"));
        e.setConcentration(rs.getString("concentration"));
        e.setStudyType(rs.getString("study_type"));
        e.setMaterialBType(rs.getString("material_b_type"));
        e.setMaterialBConcentration(rs.getString("material_b_concentration"));
        e.setComparisonMetricLabel(rs.getString("comparison_metric_label"));
        e.setMaterialAMetricValue(getNullableDouble(rs, "material_a_metric_value"));
        e.setMaterialBMetricValue(getNullableDouble(rs, "material_b_metric_value"));
        e.setComparisonNotes(rs.getString("comparison_notes"));
        e.setComparisonTableData(rs.getString("comparison_table_data"));
        e.setStudyObjective(rs.getString("study_objective"));
        e.setHypothesis(rs.getString("hypothesis"));
        e.setIndependentVariable(rs.getString("independent_variable"));
        e.setDependentVariable(rs.getString("dependent_variable"));
        e.setControlledVariables(rs.getString("controlled_variables"));
        e.setPreparationNotes(rs.getString("preparation_notes"));
        e.setCharacterizationMethods(rs.getString("characterization_methods"));
        e.setCharacterizationNotes(rs.getString("characterization_notes"));
        e.setInstrumentDetails(rs.getString("instrument_details"));
        e.setScanRange(rs.getString("scan_range"));
        e.setCalibrationReference(rs.getString("calibration_reference"));
        e.setReplicateCount(getNullableInteger(rs, "replicate_count"));
        e.setMeasurementUncertainty(rs.getString("measurement_uncertainty"));
        e.setRawDataRequired(getNullableBoolean(rs, "raw_data_required"));
        e.setConclusion(rs.getString("conclusion"));
        e.setLimitations(rs.getString("limitations"));
        e.setNextSteps(rs.getString("next_steps"));
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
        e.setCreatedAt(rs.getTimestamp("created_at"));
        return e;
    }

    private void ensureComparisonSchema() {
        if (comparisonSchemaChecked) return;
        synchronized (ExperimentDAO.class) {
            if (comparisonSchemaChecked) return;
            try (Connection conn = DBConnection.getConnection();
                 Statement st = conn.createStatement()) {
                addColumnIfMissing(conn, st, "study_type", "VARCHAR(30) DEFAULT 'SINGLE'");
                addColumnIfMissing(conn, st, "material_b_type", "VARCHAR(100) NULL");
                addColumnIfMissing(conn, st, "material_b_concentration", "VARCHAR(50) NULL");
                addColumnIfMissing(conn, st, "comparison_metric_label", "VARCHAR(120) NULL");
                addColumnIfMissing(conn, st, "material_a_metric_value", "DOUBLE NULL");
                addColumnIfMissing(conn, st, "material_b_metric_value", "DOUBLE NULL");
                addColumnIfMissing(conn, st, "comparison_notes", "TEXT NULL");
                addColumnIfMissing(conn, st, "comparison_table_data", "TEXT NULL");
                addColumnIfMissing(conn, st, "hypothesis", "TEXT NULL");
                addColumnIfMissing(conn, st, "independent_variable", "VARCHAR(255) NULL");
                addColumnIfMissing(conn, st, "dependent_variable", "VARCHAR(255) NULL");
                addColumnIfMissing(conn, st, "controlled_variables", "TEXT NULL");
                addColumnIfMissing(conn, st, "instrument_details", "TEXT NULL");
                addColumnIfMissing(conn, st, "scan_range", "VARCHAR(255) NULL");
                addColumnIfMissing(conn, st, "calibration_reference", "TEXT NULL");
                addColumnIfMissing(conn, st, "replicate_count", "INT NULL");
                addColumnIfMissing(conn, st, "measurement_uncertainty", "VARCHAR(255) NULL");
                addColumnIfMissing(conn, st, "raw_data_required", "BOOLEAN NULL");
                addColumnIfMissing(conn, st, "conclusion", "TEXT NULL");
                addColumnIfMissing(conn, st, "limitations", "TEXT NULL");
                addColumnIfMissing(conn, st, "next_steps", "TEXT NULL");
                comparisonSchemaChecked = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void addColumnIfMissing(Connection conn, Statement st, String columnName, String definition) throws SQLException {
        DatabaseMetaData meta = conn.getMetaData();
        try (ResultSet rs = meta.getColumns(null, null, "experiments", columnName)) {
            if (!rs.next()) {
                st.executeUpdate("ALTER TABLE experiments ADD COLUMN " + columnName + " " + definition);
            }
        }
    }

    private void setNullableDouble(PreparedStatement ps, int index, Double value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.DOUBLE);
        } else {
            ps.setDouble(index, value);
        }
    }

    private void setNullableInteger(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.INTEGER);
        } else {
            ps.setInt(index, value);
        }
    }

    private void setNullableBoolean(PreparedStatement ps, int index, Boolean value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.BOOLEAN);
        } else {
            ps.setBoolean(index, value);
        }
    }

    private Double getNullableDouble(ResultSet rs, String columnName) throws SQLException {
        double value = rs.getDouble(columnName);
        return rs.wasNull() ? null : value;
    }

    private Integer getNullableInteger(ResultSet rs, String columnName) throws SQLException {
        int value = rs.getInt(columnName);
        return rs.wasNull() ? null : value;
    }

    private Boolean getNullableBoolean(ResultSet rs, String columnName) throws SQLException {
        boolean value = rs.getBoolean(columnName);
        return rs.wasNull() ? null : value;
    }
}
