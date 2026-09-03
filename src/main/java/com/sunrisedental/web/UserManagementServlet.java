package com.sunrisedental.web;

import com.sunrisedental.config.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/admin-user")
public class UserManagementServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("saveUser".equals(action)) {
            String userIdStr = request.getParameter("userId");
            String fullName = request.getParameter("fullName");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String userRole = request.getParameter("userRole");

            // Role නමට අදාළ role_id එක ලබා ගැනීම (ඔබේ roles වගුවට අනුව)
            int roleId = 3; // Default Receptionist
            if ("CLINIC_MANAGER".equalsIgnoreCase(userRole)) {
                roleId = 2;
            } else if ("SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
                roleId = 1;
            }

            try (Connection conn = DBConnection.getConnection()) {
                int userId = Integer.parseInt(userIdStr);

                if (userId == 0) {
                    // නව User කෙනෙක් ඇතුළත් කිරීම (Insert)
                    String sql = "INSERT INTO users (username, password_hash, full_name, role_id, is_active) VALUES (?, ?, ?, ?, TRUE)";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setString(1, username);
                    stmt.setString(2, password); // නිෂ්පාදනයේදී Hash කිරීම කළ යුතුය
                    stmt.setString(3, fullName);
                    stmt.setInt(4, roleId);
                    stmt.executeUpdate();
                } else {
                    // පවතින User කෙනෙකුගේ තොරතුරු යාවත්කාලීන කිරීම (Update)
                    String sql;
                    PreparedStatement stmt;
                    if (password != null && !password.trim().isEmpty()) {
                        sql = "UPDATE users SET full_name = ?, username = ?, password_hash = ?, role_id = ? WHERE user_id = ?";
                        stmt = conn.prepareStatement(sql);
                        stmt.setString(1, fullName);
                        stmt.setString(2, username);
                        stmt.setString(3, password);
                        stmt.setInt(4, roleId);
                        stmt.setInt(5, userId);
                    } else {
                        sql = "UPDATE users SET full_name = ?, username = ?, role_id = ? WHERE user_id = ?";
                        stmt = conn.prepareStatement(sql);
                        stmt.setString(1, fullName);
                        stmt.setString(2, username);
                        stmt.setInt(3, roleId);
                        stmt.setInt(4, userId);
                    }
                    stmt.executeUpdate();
                }

                response.sendRedirect("admin-staff.jsp?msg=User+Saved+Successfully");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin-staff.jsp?error=Failed+to+save+user");
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "DELETE FROM users WHERE user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(idStr));
                stmt.executeUpdate();

                response.sendRedirect("admin-staff.jsp?msg=User+Deleted+Successfully");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin-staff.jsp?error=Failed+to+delete+user");
            }
        }
    }
}