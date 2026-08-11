package com.omrs.dao;

import com.omrs.config.DBConnection;
import com.omrs.model.Logbook;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LogbookDAO {
    
    public List<Logbook> getByStudentAndMonth(String studentId, String month) {
        List<Logbook> list = new ArrayList<>();
        String sql = "SELECT * FROM logbooks WHERE student_id=? AND month=? ORDER BY week ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, month);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }
    
    public Logbook getByStudentMonthWeek(String studentId, String month, int week) {
        String sql = "SELECT l.*, u.full_name as student_name FROM logbooks l " +
                     "JOIN students s ON l.student_id=s.student_id " +
                     "JOIN users u ON s.user_id=u.user_id " +
                     "WHERE l.student_id=? AND l.month=? AND l.week=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, month);
            ps.setInt(3, week);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Logbook logbook = map(rs);
                logbook.setStudentName(rs.getString("student_name"));
                return logbook;
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return null;
    }
    
    public Logbook getById(String id) {
        String sql = "SELECT l.*, u.full_name as student_name FROM logbooks l " +
                     "JOIN students s ON l.student_id=s.student_id " +
                     "JOIN users u ON s.user_id=u.user_id WHERE l.logbook_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Logbook logbook = map(rs);
                logbook.setStudentName(rs.getString("student_name"));
                return logbook;
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return null;
    }
    
    public boolean createOrUpdate(Logbook logbook) {
        // Check if entry exists
        String checkSql = "SELECT logbook_id FROM logbooks WHERE student_id=? AND month=? AND week=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setString(1, logbook.getStudentId());
            checkPs.setString(2, logbook.getMonth());
            checkPs.setInt(3, logbook.getWeek());
            ResultSet rs = checkPs.executeQuery();
            
            if (rs.next()) {
                // Update existing
                return update(logbook);
            } else {
                // Create new
                return create(logbook);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return false;
    }
    
    public boolean create(Logbook logbook) {
        String sql = "INSERT INTO logbooks (logbook_id, student_id, month, week, activities) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, generateId());
            ps.setString(2, logbook.getStudentId());
            ps.setString(3, logbook.getMonth());
            ps.setInt(4, logbook.getWeek());
            ps.setString(5, logbook.getActivities());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return false;
    }
    
    public boolean update(Logbook logbook) {
        String sql = "UPDATE logbooks SET activities=? WHERE student_id=? AND month=? AND week=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, logbook.getActivities());
            ps.setString(2, logbook.getStudentId());
            ps.setString(3, logbook.getMonth());
            ps.setInt(4, logbook.getWeek());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return false;
    }
    
    public boolean approve(String studentId, String month, int week, String supervisorName, String supervisorSignature) {
        String sql = "UPDATE logbooks SET supervisor_name=?, supervisor_signature=?, approved_date=NOW() " +
                     "WHERE student_id=? AND month=? AND week=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorName);
            ps.setString(2, supervisorSignature);
            ps.setString(3, studentId);
            ps.setString(4, month);
            ps.setInt(5, week);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return false;
    }
    
    public boolean addNotes(String studentId, String month, int week, String notes) {
        String sql = "UPDATE logbooks SET supervisor_notes=? WHERE student_id=? AND month=? AND week=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, notes);
            ps.setString(2, studentId);
            ps.setString(3, month);
            ps.setInt(4, week);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return false;
    }
    
    public List<Logbook> getBySupervisorAndMonth(String supervisorId, String month) {
        List<Logbook> list = new ArrayList<>();
        String sql = "SELECT l.*, u.full_name as student_name FROM logbooks l " +
                     "JOIN students s ON l.student_id=s.student_id " +
                     "JOIN users u ON s.user_id=u.user_id " +
                     "WHERE s.supervisor_id=? AND l.month=? ORDER BY l.student_id, l.week";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisorId);
            ps.setString(2, month);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Logbook logbook = map(rs);
                logbook.setStudentName(rs.getString("student_name"));
                list.add(logbook);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }
    
    public String generateId() {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery("SELECT MAX(CAST(SUBSTRING(logbook_id, 15) AS UNSIGNED)) as max_id FROM logbooks");
            if (rs.next()) {
                int maxId = rs.getInt("max_id");
                String ym = java.time.YearMonth.now().toString();
                return String.format("LB-%s-W%d", ym, maxId + 1);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return "LB-" + java.time.YearMonth.now() + "-W1";
    }
    
    private Logbook map(ResultSet rs) throws SQLException {
        Logbook logbook = new Logbook();
        logbook.setLogbookId(rs.getString("logbook_id"));
        logbook.setStudentId(rs.getString("student_id"));
        logbook.setMonth(rs.getString("month"));
        logbook.setWeek(rs.getInt("week"));
        logbook.setActivities(rs.getString("activities"));
        logbook.setSupervisorNotes(rs.getString("supervisor_notes"));
        logbook.setSupervisorSignature(rs.getString("supervisor_signature"));
        logbook.setSupervisorName(rs.getString("supervisor_name"));
        logbook.setApprovedDate(rs.getTimestamp("approved_date"));
        logbook.setCreatedAt(rs.getTimestamp("created_at"));
        logbook.setUpdatedAt(rs.getTimestamp("updated_at"));
        return logbook;
    }
}
