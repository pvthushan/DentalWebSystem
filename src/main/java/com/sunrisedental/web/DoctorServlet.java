package com.sunrisedental.web;

import com.sunrisedental.dao.DoctorDAO;
import com.sunrisedental.dao.DoctorDAOImpl;
import com.sunrisedental.dto.Doctor;
import com.sunrisedental.dto.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/doctor-servlet")
public class DoctorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DoctorDAO doctorDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        doctorDAO = new DoctorDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (user == null || (!"SYSTEM_ADMIN".equalsIgnoreCase(userRole) && !"CLINIC_MANAGER".equalsIgnoreCase(userRole))) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "edit":
                String idStr = request.getParameter("id");
                if (idStr != null) {
                    try {
                        int doctorId = Integer.parseInt(idStr);
                        Doctor doctor = doctorDAO.getDoctorById(doctorId);
                        request.setAttribute("doctor", doctor);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
                List<Doctor> doctorList = doctorDAO.getAllDoctors();
                request.setAttribute("doctorList", doctorList);
                request.getRequestDispatcher("admin-staff.jsp").forward(request, response);
                break;

            case "delete":
                String delIdStr = request.getParameter("id");
                if (delIdStr != null) {
                    try {
                        int doctorId = Integer.parseInt(delIdStr);
                        doctorDAO.deleteDoctor(doctorId);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
                response.sendRedirect("doctor-servlet?action=list");
                break;

            case "list":
            default:
                List<Doctor> doctors = doctorDAO.getAllDoctors();
                request.setAttribute("doctorList", doctors);
                request.getRequestDispatcher("admin-staff.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (user == null || (!"SYSTEM_ADMIN".equalsIgnoreCase(userRole) && !"CLINIC_MANAGER".equalsIgnoreCase(userRole))) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("saveDoctor".equals(action)) {
            String doctorIdStr = request.getParameter("doctorId");
            String doctorName = request.getParameter("doctorName");
            String specialization = request.getParameter("specialization");
            String contactNumber = request.getParameter("contactNumber");
            String consultationFeeStr = request.getParameter("consultationFee");
            String status = request.getParameter("status");

            try {
                double consultationFee = Double.parseDouble(consultationFeeStr);
                Doctor doctor = new Doctor();
                doctor.setDoctorName(doctorName);
                doctor.setSpecialization(specialization);
                doctor.setContactNumber(contactNumber);
                doctor.setConsultationFee(consultationFee);
                doctor.setStatus(status != null && !status.isEmpty() ? status : "AVAILABLE");

                if (doctorIdStr != null && !doctorIdStr.trim().isEmpty() && !doctorIdStr.equals("0")) {
                    int doctorId = Integer.parseInt(doctorIdStr);
                    doctor.setDoctorId(doctorId);
                    doctorDAO.updateDoctor(doctor);
                } else {
                    doctorDAO.addDoctor(doctor);
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }

            response.sendRedirect("doctor-servlet?action=list");
        } else {
            response.sendRedirect("doctor-servlet?action=list");
        }
    }
}