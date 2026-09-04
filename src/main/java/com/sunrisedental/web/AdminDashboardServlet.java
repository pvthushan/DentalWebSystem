package com.sunrisedental.web;

import com.sunrisedental.config.DBConnection;
import com.sunrisedental.dto.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/admin-dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        int activeStaffCount = 0;
        int totalAppointments = 0;
        double todaysIncome = 0.0;

        try (Connection conn = DBConnection.getConnection()) {


            String staffSql = "SELECT COUNT(*) FROM users WHERE is_active = 1";
            try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(staffSql)) {
                if (rs.next()) {
                    activeStaffCount = rs.getInt(1);
                }
            }


            String apptSql = "SELECT COUNT(*) FROM appointments";
            try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(apptSql)) {
                if (rs.next()) {
                    totalAppointments = rs.getInt(1);
                }
            }


            String incomeSql = "SELECT SUM(sub_total) FROM bills";
            try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(incomeSql)) {
                if (rs.next()) {
                    todaysIncome = rs.getDouble(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }


        request.setAttribute("activeStaff", activeStaffCount);
        request.setAttribute("totalAppointments", totalAppointments);
        request.setAttribute("todaysIncome", todaysIncome);

        request.getRequestDispatcher("admin-dashboard.jsp").forward(request, response);
    }
}