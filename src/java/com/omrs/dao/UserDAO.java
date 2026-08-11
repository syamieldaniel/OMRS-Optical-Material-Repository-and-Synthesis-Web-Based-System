package com.omrs.dao;

import com.omrs.config.DBConnection;
import com.omrs.model.User;
import com.omrs.util.PasswordUtil;
import java.sql.*;
import java.util.*;

public class UserDAO {
    private static volatile boolean profilePictureColumnChecked = false;
    private static volatile boolean studentTypeSchemaChecked = false;
    private static volatile boolean passwordResetSchemaChecked = false;
    
    // ==================== LOGIN & USER RETRIEVAL ====================
    
    public User login(String username, String password) {
        ensureProfilePictureColumn();
        String sql = "SELECT * FROM users WHERE username=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String storedPassword = rs.getString("password");
                if (PasswordUtil.verify(password, storedPassword)) {
                    User user = mapUser(rs);
                    if (!PasswordUtil.isHashed(storedPassword)) {
                        updatePassword(user.getUserId(), password);
                    }
                    return user;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
    
    public User getUserById(int userId) {
        ensureProfilePictureColumn();
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
    
    public User getUserByUsername(String username) {
        ensureProfilePictureColumn();
        String sql = "SELECT * FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public User getUserByUsernameAndEmail(String username, String email) {
        ensureProfilePictureColumn();
        String sql = "SELECT * FROM users WHERE username = ? AND email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
    
    // ==================== REGISTRATION ====================
    
    public boolean register(User user, String supervisorId, String studentId) throws Exception {
        ensureStudentTypeSchema();
        ensureProfilePictureColumn();
        String status = "STUDENT".equals(user.getRole()) && "FYP".equals(user.getStudentType()) ? "PENDING" : "APPROVED";
        String sql = "INSERT INTO users (username, password, email, full_name, role, status) VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getUsername());
            ps.setString(2, PasswordUtil.hash(user.getPassword()));
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getRole());
            ps.setString(6, status);
            int affected = ps.executeUpdate();
            
            if (affected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int userId = rs.getInt(1);
                    user.setUserId(userId);
                    user.setStatus(status);
                    
                    if ("STUDENT".equals(user.getRole())) {
                        registerStudentTable(conn, userId, supervisorId, studentId, user.getStudentType());
                    } else if ("SUPERVISOR".equals(user.getRole())) {
                        registerSupervisor(conn, userId);
                    }
                    conn.commit();
                    return true;
                }
            }
            conn.rollback();
            return false;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) {}
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ex) {}
            }
        }
    }
    
    public boolean register(User user, String supervisorId) throws Exception {
        return register(user, supervisorId, null);
    }
    
    private void registerStudentTable(Connection conn, int userId, String supervisorId, String studentId, String studentType) throws Exception {
        String sql = "INSERT INTO students (student_id, user_id, student_type, supervisor_id) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        String finalStudentId = (studentId != null && !studentId.trim().isEmpty()) ? studentId : "S" + userId;
        String finalStudentType = "FYP".equals(studentType) ? "FYP" : "NORMAL";
        ps.setString(1, finalStudentId);
        ps.setInt(2, userId);
        ps.setString(3, finalStudentType);
        if ("FYP".equals(finalStudentType)) {
            ps.setString(4, supervisorId);
        } else {
            ps.setNull(4, Types.VARCHAR);
        }
        ps.executeUpdate();
    }
    
    private void registerSupervisor(Connection conn, int userId) throws Exception {
        String sql = "INSERT INTO supervisors (supervisor_id, user_id) VALUES (?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, "SV" + userId);
        ps.setInt(2, userId);
        ps.executeUpdate();
    }
    
    // ==================== STUDENT METHODS ====================
    
    public String getStudentId(int userId) {
        ensureStudentTypeSchema();
        String sql = "SELECT student_id FROM students WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("student_id");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public String getStudentType(int userId) {
        ensureStudentTypeSchema();
        String sql = "SELECT student_type FROM students WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String studentType = rs.getString("student_type");
                return studentType != null && !studentType.trim().isEmpty() ? studentType : "NORMAL";
            }
        } catch (Exception e) { e.printStackTrace(); }
        return "NORMAL";
    }
    
    public List<User> getPendingStudents(String supervisorId) {
        List<User> students = new ArrayList<>();
        String sql = "SELECT u.*, s.student_id FROM users u " +
                     "JOIN students s ON u.user_id = s.user_id " +
                     "WHERE s.supervisor_id = ? AND u.status = 'PENDING' " +
                     "ORDER BY u.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = mapUser(rs);
                u.setStudentId(rs.getString("student_id"));
                try { u.setStudentType(rs.getString("student_type")); } catch (SQLException ignored) {}
                students.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return students;
    }
    
    public List<User> getApprovedStudents(String supervisorId) {
        List<User> students = new ArrayList<>();
        String sql = "SELECT u.*, s.student_id FROM users u " +
                     "JOIN students s ON u.user_id = s.user_id " +
                     "WHERE s.supervisor_id = ? AND u.status = 'APPROVED' " +
                     "ORDER BY u.full_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = mapUser(rs);
                u.setStudentId(rs.getString("student_id"));
                try { u.setStudentType(rs.getString("student_type")); } catch (SQLException ignored) {}
                students.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return students;
    }
    
    public List<User> getAllStudents(String supervisorId) {
        List<User> students = new ArrayList<>();
        String sql = "SELECT u.*, s.student_id FROM users u " +
                     "JOIN students s ON u.user_id = s.user_id " +
                     "WHERE s.supervisor_id = ? " +
                     "ORDER BY u.status DESC, u.full_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = mapUser(rs);
                u.setStudentId(rs.getString("student_id"));
                try { u.setStudentType(rs.getString("student_type")); } catch (SQLException ignored) {}
                students.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return students;
    }
    
    public User getStudentByStudentId(String studentId) {
        String sql = "SELECT u.*, s.student_id, s.supervisor_id FROM users u " +
                     "JOIN students s ON u.user_id = s.user_id " +
                     "WHERE s.student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = mapUser(rs);
                u.setStudentId(rs.getString("student_id"));
                try { u.setStudentType(rs.getString("student_type")); } catch (SQLException ignored) {}
                return u;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public User getStudentByUserIdAndSupervisor(int userId, String supervisorId) {
        String sql = "SELECT u.*, s.student_id, s.supervisor_id FROM users u " +
                     "JOIN students s ON u.user_id = s.user_id " +
                     "WHERE u.user_id = ? AND s.supervisor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, supervisorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = mapUser(rs);
                u.setStudentId(rs.getString("student_id"));
                try { u.setStudentType(rs.getString("student_type")); } catch (SQLException ignored) {}
                return u;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
    
    // ==================== SUPERVISOR METHODS ====================
    
    public String getSupervisorId(int userId) {
        String sql = "SELECT supervisor_id FROM supervisors WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("supervisor_id");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
    
    public List<Map<String, String>> getSupervisors() {
        List<Map<String, String>> supervisors = new ArrayList<>();
        String sql = "SELECT s.supervisor_id, u.username, u.full_name, u.email " +
                     "FROM users u JOIN supervisors s ON u.user_id = s.user_id " +
                     "WHERE u.status = 'APPROVED' ORDER BY u.full_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> sup = new HashMap<>();
                sup.put("id", rs.getString("supervisor_id"));
                sup.put("username", rs.getString("full_name") != null && !rs.getString("full_name").isEmpty()
                        ? rs.getString("full_name") : rs.getString("username"));
                sup.put("email", rs.getString("email"));
                supervisors.add(sup);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return supervisors;
    }
    
    public String getSupervisorName(String supervisorId) {
        String sql = "SELECT u.full_name, u.username FROM users u " +
                     "JOIN supervisors s ON u.user_id = s.user_id " +
                     "WHERE s.supervisor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String fullName = rs.getString("full_name");
                return (fullName != null && !fullName.isEmpty()) ? fullName : rs.getString("username");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }
    
    // ==================== UPDATE METHODS ====================
    
    public boolean updateUser(User user) {
        ensureProfilePictureColumn();
        String sql = "UPDATE users SET email = ?, full_name = ?, profile_picture = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getProfilePicture());
            ps.setInt(4, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateUserStatusForSupervisorStudent(int userId, String supervisorId, String status) {
        String sql = "UPDATE users u " +
                     "JOIN students s ON u.user_id = s.user_id " +
                     "SET u.status = ? " +
                     "WHERE u.user_id = ? AND s.supervisor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            ps.setString(3, supervisorId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hash(newPassword));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean resetPassword(String username, String email, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE username = ? AND email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hash(newPassword));
            ps.setString(2, username);
            ps.setString(3, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean createPasswordResetToken(int userId, String tokenHash, Timestamp expiresAt) {
        ensurePasswordResetSchema();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement invalidate = conn.prepareStatement(
                    "UPDATE password_reset_tokens SET used_at = NOW() WHERE user_id = ? AND used_at IS NULL")) {
                invalidate.setInt(1, userId);
                invalidate.executeUpdate();
            }

            try (PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)")) {
                insert.setInt(1, userId);
                insert.setString(2, tokenHash);
                insert.setTimestamp(3, expiresAt);
                insert.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {}
            }
        }
    }

    public User getUserByValidResetToken(String tokenHash) {
        ensurePasswordResetSchema();
        ensureProfilePictureColumn();
        String sql = "SELECT u.* FROM users u " +
                     "JOIN password_reset_tokens prt ON u.user_id = prt.user_id " +
                     "WHERE prt.token_hash = ? AND prt.used_at IS NULL AND prt.expires_at > NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean resetPasswordWithToken(String tokenHash, String newPassword) {
        ensurePasswordResetSchema();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            Integer userId = null;
            try (PreparedStatement find = conn.prepareStatement(
                    "SELECT user_id FROM password_reset_tokens WHERE token_hash = ? AND used_at IS NULL AND expires_at > NOW() FOR UPDATE")) {
                find.setString(1, tokenHash);
                ResultSet rs = find.executeQuery();
                if (rs.next()) {
                    userId = rs.getInt("user_id");
                }
            }

            if (userId == null) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement updateUser = conn.prepareStatement(
                    "UPDATE users SET password = ? WHERE user_id = ?")) {
                updateUser.setString(1, PasswordUtil.hash(newPassword));
                updateUser.setInt(2, userId);
                updateUser.executeUpdate();
            }

            try (PreparedStatement useToken = conn.prepareStatement(
                    "UPDATE password_reset_tokens SET used_at = NOW() WHERE token_hash = ?")) {
                useToken.setString(1, tokenHash);
                useToken.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {}
            }
        }
    }
    
    // ==================== STATISTICS ====================
    
    public int countPendingStudents(String supervisorId) {
        String sql = "SELECT COUNT(*) FROM users u " +
                     "JOIN students s ON u.user_id = s.user_id " +
                     "WHERE s.supervisor_id = ? AND u.status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
    
    public int countApprovedStudents(String supervisorId) {
        String sql = "SELECT COUNT(*) FROM users u " +
                     "JOIN students s ON u.user_id = s.user_id " +
                     "WHERE s.supervisor_id = ? AND u.status = 'APPROVED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
    
    // ==================== VALIDATION ====================
    
    public boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    public boolean isStudentIdExists(String studentId) {
        String sql = "SELECT COUNT(*) FROM students WHERE student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    // ==================== HELPER METHOD ====================
    
    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setFullName(rs.getString("full_name"));
        u.setRole(rs.getString("role"));
        u.setStatus(rs.getString("status"));
        try {
            u.setProfilePicture(rs.getString("profile_picture"));
        } catch (SQLException ignored) {}
        try {
            u.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException ignored) {}
        return u;
    }
    
    public Map<String, String> getSupervisorByStudent(String studentId) {
        ensureStudentTypeSchema();
        Map<String, String> supervisorInfo = new HashMap<>();
        String sql = "SELECT u.full_name, u.username, u.email, s.supervisor_id " +
                     "FROM users u " +
                     "JOIN supervisors s ON u.user_id = s.user_id " +
                     "JOIN students st ON st.supervisor_id = s.supervisor_id " +
                     "WHERE st.student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                supervisorInfo.put("name", rs.getString("full_name") != null && !rs.getString("full_name").isEmpty()
                        ? rs.getString("full_name") : rs.getString("username"));
                supervisorInfo.put("email", rs.getString("email"));
                supervisorInfo.put("supervisorId", rs.getString("supervisor_id"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return supervisorInfo;
    }

    public Integer getSupervisorUserIdByStudent(String studentId) {
        ensureStudentTypeSchema();
        String sql = "SELECT u.user_id " +
                     "FROM users u " +
                     "JOIN supervisors s ON u.user_id = s.user_id " +
                     "JOIN students st ON st.supervisor_id = s.supervisor_id " +
                     "WHERE st.student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("user_id");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    private void ensureProfilePictureColumn() {
        if (profilePictureColumnChecked) {
            return;
        }

        synchronized (UserDAO.class) {
            if (profilePictureColumnChecked) {
                return;
            }

            ensureProfilePictureColumnOnce();
            profilePictureColumnChecked = true;
        }
    }

    private void ensureStudentTypeSchema() {
        if (studentTypeSchemaChecked) {
            return;
        }

        synchronized (UserDAO.class) {
            if (studentTypeSchemaChecked) {
                return;
            }

            ensureStudentTypeSchemaOnce();
            studentTypeSchemaChecked = true;
        }
    }

    private void ensurePasswordResetSchema() {
        if (passwordResetSchemaChecked) {
            return;
        }

        synchronized (UserDAO.class) {
            if (passwordResetSchemaChecked) {
                return;
            }

            ensurePasswordResetSchemaOnce();
            passwordResetSchemaChecked = true;
        }
    }

    private void ensurePasswordResetSchemaOnce() {
        String sql = "CREATE TABLE IF NOT EXISTS password_reset_tokens (" +
                     "token_id INT AUTO_INCREMENT PRIMARY KEY, " +
                     "user_id INT NOT NULL, " +
                     "token_hash VARCHAR(64) NOT NULL UNIQUE, " +
                     "expires_at DATETIME NOT NULL, " +
                     "used_at DATETIME NULL, " +
                     "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                     "INDEX idx_password_reset_user (user_id), " +
                     "INDEX idx_password_reset_token (token_hash), " +
                     "CONSTRAINT fk_password_reset_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE" +
                     ")";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            st.executeUpdate(sql);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void ensureStudentTypeSchemaOnce() {
        try (Connection conn = DBConnection.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            try (ResultSet columns = metaData.getColumns(null, null, "students", "student_type")) {
                if (!columns.next()) {
                    try (Statement st = conn.createStatement()) {
                        st.executeUpdate("ALTER TABLE students ADD COLUMN student_type ENUM('NORMAL','FYP') DEFAULT 'NORMAL' AFTER user_id");
                    }
                }
            }

            try (Statement st = conn.createStatement()) {
                st.executeUpdate("ALTER TABLE students MODIFY supervisor_id VARCHAR(20) NULL");
                st.executeUpdate("UPDATE students SET student_type = 'FYP' WHERE supervisor_id IS NOT NULL AND (student_type IS NULL OR student_type = 'NORMAL')");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void ensureProfilePictureColumnOnce() {
        try (Connection conn = DBConnection.getConnection();
             ResultSet columns = conn.getMetaData().getColumns(null, null, "users", "profile_picture")) {
            if (columns.next()) {
                return;
            }

            try (Statement st = conn.createStatement()) {
                st.executeUpdate("ALTER TABLE users ADD COLUMN profile_picture VARCHAR(500) NULL");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
