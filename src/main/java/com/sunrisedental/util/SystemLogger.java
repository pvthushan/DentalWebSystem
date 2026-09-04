package com.sunrisedental.util;

import com.sunrisedental.config.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class SystemLogger {
    public static void logAction(String performedBy, String description) {
        String sql = "INSERT INTO system_logs (performed_by, action_description) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, performedBy);
            stmt.setString(2, description);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}