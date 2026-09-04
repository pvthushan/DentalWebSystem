package com.sunrisedental.web;

import com.sunrisedental.config.DBConnection;
import com.sunrisedental.util.SystemLogger;
import com.sunrisedental.dto.User;
import com.sunrisedental.dto.Doctor;
import com.sunrisedental.dao.DoctorDAO;
import com.sunrisedental.dao.DoctorDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin-pricing")
public class AdminPricingServlet extends HttpServlet {

    private DoctorDAO doctorDAO = new DoctorDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }


        List<Treatment> treatmentList = new ArrayList<>();
        String sql = "SELECT * FROM treatments";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Treatment t = new Treatment(
                        rs.getInt("treatment_id"),
                        rs.getString("treatment_name"),
                        rs.getDouble("treatment_cost")
                );
                treatmentList.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


        List<Doctor> doctorList = doctorDAO.getAllDoctors();

        request.setAttribute("treatmentList", treatmentList);
        request.setAttribute("doctorList", doctorList);
        request.getRequestDispatcher("admin-pricing.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        String action = request.getParameter("action");

        if ("addTreatment".equals(action)) {
            String treatmentName = request.getParameter("treatmentName");
            String treatmentCostStr = request.getParameter("treatmentCost");

            try {
                double cost = Double.parseDouble(treatmentCostStr);
                String sql = "INSERT INTO treatments (treatment_name, treatment_cost) VALUES (?, ?)";

                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, treatmentName);
                    stmt.setDouble(2, cost);
                    stmt.executeUpdate();

                    SystemLogger.logAction(user.getUsername(), "Added new treatment: " + treatmentName + " (Rs. " + cost + ")");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            response.sendRedirect("admin-pricing");
        } else if ("updateTreatmentCost".equals(action)) {
            String treatmentIdStr = request.getParameter("treatmentId");
            String newCostStr = request.getParameter("newCost");

            try {
                int treatmentId = Integer.parseInt(treatmentIdStr);
                double newCost = Double.parseDouble(newCostStr);
                String sql = "UPDATE treatments SET treatment_cost = ? WHERE treatment_id = ?";

                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setDouble(1, newCost);
                    stmt.setInt(2, treatmentId);
                    stmt.executeUpdate();

                    SystemLogger.logAction(user.getUsername(), "Updated cost for treatment ID: " + treatmentId + " to Rs. " + newCost);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            response.sendRedirect("admin-pricing");
        } else if ("updateDocFee".equals(action)) {
            String doctorIdStr = request.getParameter("doctorId");
            String newFeeStr = request.getParameter("newFee");

            try {
                int doctorId = Integer.parseInt(doctorIdStr);
                double newFee = Double.parseDouble(newFeeStr);

                Doctor doc = doctorDAO.getDoctorById(doctorId);
                if (doc != null) {
                    doc.setConsultationFee(newFee);
                    doctorDAO.updateDoctor(doc);

                    SystemLogger.logAction(user.getUsername(), "Updated consultation fee for Dr. " + doc.getDoctorName() + " to Rs. " + newFee);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            response.sendRedirect("admin-pricing");
        } else {
            response.sendRedirect("admin-pricing");
        }
    }

    public static class Treatment {
        private int id;
        private String name;
        private double cost;

        public Treatment(int id, String name, double cost) {
            this.id = id;
            this.name = name;
            this.cost = cost;
        }

        public int getId() { return id; }
        public String getName() { return name; }
        public double getCost() { return cost; }
    }
}