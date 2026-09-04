package com.sunrisedental.web;

import com.sunrisedental.config.DBConnection;
import com.sunrisedental.dto.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/report-export")
public class ReportExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        String type = request.getParameter("type");

        if ("excel".equalsIgnoreCase(type)) {
            exportToCSV(response);
        } else if ("pdf".equalsIgnoreCase(type)) {
            exportToPDF(response);
        } else {
            response.sendRedirect("admin-reports");
        }
    }

    private void exportToCSV(HttpServletResponse response) throws IOException {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"Financial_Income_Report.csv\"");

        try (PrintWriter writer = response.getWriter();
             Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT patient_name, treatment_provided, doctor_name, bill_date, consultation_fee, treatment_fee, sub_total FROM bills")) {


            writer.println("Patient Name,Treatment Type,Doctor Name,Date,Consultation Fee,Treatment Fee,Sub-Total");

            double grandTotal = 0.0;
            while (rs.next()) {
                String patient = rs.getString("patient_name");
                String treatment = rs.getString("treatment_provided");
                String doctor = rs.getString("doctor_name");
                String date = rs.getString("bill_date");
                double cFee = rs.getDouble("consultation_fee");
                double tFee = rs.getDouble("treatment_fee");
                double subTotal = rs.getDouble("sub_total");
                grandTotal += subTotal;

                writer.printf("\"%s\",\"%s\",\"%s\",%s,%.2f,%.2f,%.2f\n",
                        patient, treatment, doctor, date, cFee, tFee, subTotal);
            }
            writer.printf(",,,,,Grand Total Revenue:,%.2f\n", grandTotal);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void exportToPDF(HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter writer = response.getWriter();
             Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT patient_name, treatment_provided, doctor_name, bill_date, consultation_fee, treatment_fee, sub_total FROM bills")) {

            writer.println("<!DOCTYPE html>");
            writer.println("<html><head><title>Financial Income Report</title>");
            writer.println("<style>");
            writer.println("body { font-family: Arial, sans-serif; padding: 20px; color: #333; }");
            writer.println("h2 { text-align: center; color: #0f172a; margin-bottom: 20px; }");
            writer.println("table { width: 100%; border-collapse: collapse; margin-top: 10px; }");
            writer.println("th, td { border: 1px solid #cbd5e1; padding: 10px; text-align: left; font-size: 13px; }");
            writer.println("th { background-color: #334155; color: white; }");
            writer.println(".total-row { font-weight: bold; background-color: #f8fafc; }");
            writer.println("@media print { body { padding: 0; } }");
            writer.println("</style></head><body>");
            writer.println("<h2>Sunrise Dental - Financial Income Report</h2>");
            writer.println("<table>");
            writer.println("<thead><tr><th>Patient Name</th><th>Treatment Type</th><th>Doctor Name</th><th>Date</th><th>Consultation Fee</th><th>Treatment Fee</th><th>Sub-Total</th></tr></thead>");
            writer.println("<tbody>");

            double grandTotal = 0.0;
            while (rs.next()) {
                double subTotal = rs.getDouble("sub_total");
                grandTotal += subTotal;
                writer.println("<tr>");
                writer.println("<td>" + rs.getString("patient_name") + "</td>");
                writer.println("<td>" + rs.getString("treatment_provided") + "</td>");
                writer.println("<td>" + rs.getString("doctor_name") + "</td>");
                writer.println("<td>" + rs.getString("bill_date") + "</td>");
                writer.println("<td>Rs. " + String.format("%,.2f", rs.getDouble("consultation_fee")) + "</td>");
                writer.println("<td>Rs. " + String.format("%,.2f", rs.getDouble("treatment_fee")) + "</td>");
                writer.println("<td><strong>Rs. " + String.format("%,.2f", subTotal) + "</strong></td>");
                writer.println("</tr>");
            }

            writer.println("<tr class=\"total-row\"><td colspan=\"6\" style=\"text-align: right;\">Grand Total Revenue:</td><td style=\"color: #d97706;\">Rs. " + String.format("%,.2f", grandTotal) + "</td></tr>");
            writer.println("</tbody></table>");
            writer.println("<script>window.onload = function() { window.print(); }</script>");
            writer.println("</body></html>");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}