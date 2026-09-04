package com.sunrisedental.web;

import com.sunrisedental.config.DBConnection;
import com.sunrisedental.dto.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin-reports")
public class AdminReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        List<ReportItem> reportList = new ArrayList<>();
        int totalAppointments = 0;
        double grossRevenue = 0.0;

        String sql = "SELECT patient_name, treatment_provided, doctor_name, bill_date, consultation_fee, treatment_fee, sub_total FROM bills";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                totalAppointments++;
                double subTotal = rs.getDouble("sub_total");
                grossRevenue += subTotal;

                ReportItem item = new ReportItem(
                        rs.getString("patient_name"),
                        rs.getString("treatment_provided"),
                        rs.getString("doctor_name"),
                        rs.getString("bill_date"),
                        rs.getDouble("consultation_fee"),
                        rs.getDouble("treatment_fee"),
                        subTotal
                );
                reportList.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("reportList", reportList);
        request.setAttribute("totalAppointments", totalAppointments);
        request.setAttribute("grossRevenue", grossRevenue);
        request.getRequestDispatcher("admin-reports.jsp").forward(request, response);
    }

    public static class ReportItem {
        private String patientName, treatmentName, doctorName, date;
        private double consultationFee, treatmentFee, subTotal;

        public ReportItem(String p, String t, String d, String date, double cf, double tf, double st) {
            this.patientName = p; this.treatmentName = t; this.doctorName = d; this.date = date;
            this.consultationFee = cf; this.treatmentFee = tf; this.subTotal = st;
        }

        public String getPatientName() { return patientName; }
        public String getTreatmentName() { return treatmentName; }
        public String getDoctorName() { return doctorName; }
        public String getDate() { return date; }
        public double getConsultationFee() { return consultationFee; }
        public double getTreatmentFee() { return treatmentFee; }
        public double getSubTotal() { return subTotal; }
    }
}