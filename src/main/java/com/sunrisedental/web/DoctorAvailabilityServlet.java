package com.sunrisedental.web;

import com.sunrisedental.dto.User;
import com.sunrisedental.dto.Doctor;
import com.sunrisedental.dao.DoctorDAO;
import com.sunrisedental.dao.DoctorDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/doctor-availability")
public class DoctorAvailabilityServlet extends HttpServlet {

    private DoctorDAO doctorDAO = new DoctorDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (user == null || !"RECEPTIONIST".equalsIgnoreCase(userRole)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        List<Doctor> doctorList = doctorDAO.getAllDoctors();
        request.setAttribute("doctorList", doctorList);
        request.getRequestDispatcher("receptionist-doctor-availability.jsp").forward(request, response);
    }
}