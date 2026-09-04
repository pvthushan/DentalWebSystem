package com.sunrisedental.dao;

import com.sunrisedental.config.DBConnection;
import com.sunrisedental.dto.User;
import java.sql.*;

public class UserDAOImpl implements UserDAO {

    @Override
    public User authenticate(String username, String password) {
        String sql = "SELECT u.user_id, u.username, u.full_name, u.email, r.role_name " +
                "FROM users u " +
                "JOIN roles r ON u.role_id = r.role_id " +
                "WHERE u.username = ? AND u.password_hash = ? AND u.is_active = TRUE";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setString(2, password);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRoleName(rs.getString("role_name"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}