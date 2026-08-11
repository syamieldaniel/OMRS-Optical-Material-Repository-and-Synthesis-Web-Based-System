package com.omrs.dao;

import com.omrs.config.DBConnection;
import com.omrs.model.Notification;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {
    private static volatile boolean tableChecked = false;

    public List<Notification> getByUser(int userId) {
        ensureTable();
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id=? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                notifications.add(map(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return notifications;
    }

    public int getUnreadCount(int userId) {
        ensureTable();
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public boolean create(int userId, String title, String message, String linkUrl) {
        ensureTable();
        String sql = "INSERT INTO notifications (notification_id, user_id, title, message, link_url) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, generateId());
            ps.setInt(2, userId);
            ps.setString(3, title);
            ps.setString(4, message);
            ps.setString(5, linkUrl);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean markAsRead(String notificationId, int userId) {
        ensureTable();
        String sql = "UPDATE notifications SET is_read=TRUE, read_at=NOW() WHERE notification_id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean markAllAsRead(int userId) {
        ensureTable();
        String sql = "UPDATE notifications SET is_read=TRUE, read_at=NOW() WHERE user_id=? AND is_read=FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    private Notification map(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        notification.setNotificationId(rs.getString("notification_id"));
        notification.setUserId(rs.getInt("user_id"));
        notification.setTitle(rs.getString("title"));
        notification.setMessage(rs.getString("message"));
        notification.setLinkUrl(rs.getString("link_url"));
        notification.setRead(rs.getBoolean("is_read"));
        notification.setCreatedAt(rs.getTimestamp("created_at"));
        notification.setReadAt(rs.getTimestamp("read_at"));
        return notification;
    }

    private String generateId() {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(
                "SELECT MAX(CAST(SUBSTRING(notification_id, 4) AS UNSIGNED)) as max_id FROM notifications");
            if (rs.next()) {
                return String.format("NT-%03d", rs.getInt("max_id") + 1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return "NT-" + System.currentTimeMillis();
    }

    private void ensureTable() {
        if (tableChecked) {
            return;
        }

        synchronized (NotificationDAO.class) {
            if (tableChecked) {
                return;
            }

            ensureTableOnce();
            tableChecked = true;
        }
    }

    private void ensureTableOnce() {
        String sql = "CREATE TABLE IF NOT EXISTS notifications (" +
                     "notification_id VARCHAR(20) PRIMARY KEY, " +
                     "user_id INT NOT NULL, " +
                     "title VARCHAR(255) NOT NULL, " +
                     "message TEXT NOT NULL, " +
                     "link_url VARCHAR(500), " +
                     "is_read BOOLEAN DEFAULT FALSE, " +
                     "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                     "read_at TIMESTAMP NULL, " +
                     "FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE" +
                     ")";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            st.executeUpdate(sql);
        } catch (Exception e) { e.printStackTrace(); }
    }
}
