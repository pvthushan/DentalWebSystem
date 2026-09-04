package com.sunrisedental.web;

import com.sunrisedental.config.DBConnection;
import com.sunrisedental.dto.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/receptionist-search-appointment")
public class AppointmentSearchServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : "";


        if (user == null || !"RECEPTIONIST".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        String query = request.getParameter("query");
        String date = request.getParameter("date");

        List<Map<String, String>> appointmentList = new ArrayList<>();


        StringBuilder sql = new StringBuilder(
                "SELECT a.appointment_number, COALESCE(p.full_name, 'Unknown Patient') AS full_name, " +
                        "COALESCE(p.contact_number, 'N/A') AS contact_number, a.doctor_id, a.appointment_date, a.appointment_time " +
                        "FROM appointments a LEFT JOIN patients p ON a.patient_id = p.patient_id WHERE 1=1"
        );

        if (query != null && !query.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.contact_number LIKE ? OR a.appointment_number LIKE ?)");
        }
        if (date != null && !date.trim().isEmpty()) {
            sql.append(" AND a.appointment_date = ?");
        }
        sql.append(" ORDER BY a.appointment_date DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (query != null && !query.trim().isEmpty()) {
                String searchVal = "%" + query.trim() + "%";
                ps.setString(paramIndex++, searchVal);
                ps.setString(paramIndex++, searchVal);
                ps.setString(paramIndex++, searchVal);
            }
            if (date != null && !date.trim().isEmpty()) {
                ps.setString(paramIndex++, date.trim());
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> appt = new HashMap<>();
                appt.put("appointmentNumber", rs.getString("appointment_number"));
                appt.put("patientName", rs.getString("full_name"));
                appt.put("contactNumber", rs.getString("contact_number"));
                appt.put("doctorId", rs.getString("doctor_id"));
                appt.put("date", rs.getString("appointment_date"));
                appt.put("time", rs.getString("appointment_time"));
                appointmentList.add(appt);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("appointmentList", appointmentList);

        request.getRequestDispatcher("receptionist-search-appointment-view.jsp").forward(request, response);
    }
}