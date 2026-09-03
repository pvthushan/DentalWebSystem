package com.sunrisedental.web;

import com.sunrisedental.dto.Patient;
import com.sunrisedental.factory.DAOFactory;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/patient")
public class PatientServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String contactNumber = request.getParameter("contactNumber");
        String email = request.getParameter("email");

        // Patient DTO Object එක සකස් කිරීම
        Patient patient = new Patient();
        patient.setFullName(fullName);
        patient.setAddress(address);
        patient.setContactNumber(contactNumber);
        patient.setEmail(email);

        // Save to Database via DAO
        boolean isSaved = DAOFactory.getPatientDAO().registerPatient(patient);

        if (isSaved) {
            // Patient Code එකත් එක්ක Success Message එක යැවීම
            response.sendRedirect(request.getContextPath() + "/patient-reg.jsp?msg=Patient+Registered+Successfully!+Patient+Code:+ " + patient.getPatientCode());
        } else {
            response.sendRedirect(request.getContextPath() + "/patient-reg.jsp?error=Failed+to+register+patient");
        }
    }
}