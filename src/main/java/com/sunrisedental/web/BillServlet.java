package com.sunrisedental.web;

import com.sunrisedental.config.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/bill-servlet")
public class BillServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : "";

        if ("saveBill".equals(action)) {
            String apptNumber = request.getParameter("appointmentNumber");
            String patientName = request.getParameter("patientName");
            String doctorName = request.getParameter("doctorName");
            String treatmentName = request.getParameter("treatmentName");

            double consultationFee = request.getParameter("consultationFee") != null ? Double.parseDouble(request.getParameter("consultationFee")) : 0.0;
            double treatmentFee = request.getParameter("treatmentFee") != null ? Double.parseDouble(request.getParameter("treatmentFee")) : 0.0;
            double otherFee = request.getParameter("otherFee") != null && !request.getParameter("otherFee").isEmpty() ? Double.parseDouble(request.getParameter("otherFee")) : 0.0;

            double subTotal = consultationFee + treatmentFee + otherFee;

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "INSERT INTO bills (appointment_number, patient_name, doctor_name, treatment_provided, bill_date, consultation_fee, treatment_fee, other_fee, sub_total) VALUES (?, ?, ?, ?, CURDATE(), ?, ?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, apptNumber);
                stmt.setString(2, patientName);
                stmt.setString(3, doctorName);
                stmt.setString(4, treatmentName);
                stmt.setDouble(5, consultationFee);
                stmt.setDouble(6, treatmentFee);
                stmt.setDouble(7, otherFee);
                stmt.setDouble(8, subTotal);

                stmt.executeUpdate();


                if ("RECEPTIONIST".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("receptionist-calculate-bill.jsp?msg=Bill+Saved+Successfully");
                } else if ("CLINIC_MANAGER".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("manager-calculate-bill.jsp?msg=Bill+Saved+Successfully");
                } else {
                    response.sendRedirect("login.jsp");
                }

            } catch (Exception e) {
                e.printStackTrace();

                if ("RECEPTIONIST".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("receptionist-calculate-bill.jsp?error=Failed+to+save+bill");
                } else {
                    response.sendRedirect("manager-calculate-bill.jsp?error=Failed+to+save+bill");
                }
            }
        }
    }
}