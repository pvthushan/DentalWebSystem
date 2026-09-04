//package com.sunrisedental.web;
//
//import com.sunrisedental.config.DBConnection;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.*;
//import java.io.IOException;
//import java.sql.*;
//
//@WebServlet("/appointment-servlet")
//public class AppointmentServlet extends HttpServlet {
//
//    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//        String action = request.getParameter("action");
//
//        if ("createAppointment".equals(action)) {
//            String patientName = request.getParameter("patientName");
//            String address = request.getParameter("address");
//            String idType = request.getParameter("idType");
//            String identificationNumber = request.getParameter("identificationNumber");
//            String contactNumber = request.getParameter("contactNumber");
//            String doctorId = request.getParameter("doctorId");
//            String appointmentDate = request.getParameter("appointmentDate");
//            String appointmentTime = request.getParameter("appointmentTime");
//
//            try (Connection conn = DBConnection.getConnection()) {
//                conn.setAutoCommit(false); // Transaction ආරම්භ කරයි
//
//                // 1. patients වගුවට දත්ත ඇතුළත් කිරීම
//                String patientSql = "INSERT INTO patients (patient_code, full_name, address, id_type, identification_number, contact_number) VALUES (?, ?, ?, ?, ?, ?)";
//                PreparedStatement psPatient = conn.prepareStatement(patientSql, Statement.RETURN_GENERATED_KEYS);
//
//                String generatedPatientCode = "PAT-" + System.currentTimeMillis();
//                psPatient.setString(1, generatedPatientCode);
//                psPatient.setString(2, patientName);
//                psPatient.setString(3, address);
//                psPatient.setString(4, idType);
//                psPatient.setString(5, identificationNumber);
//                psPatient.setString(6, contactNumber);
//                psPatient.executeUpdate();
//
//                ResultSet rsKeys = psPatient.getGeneratedKeys();
//                int patientId = 0;
//                if (rsKeys.next()) {
//                    patientId = rsKeys.getInt(1);
//                }
//
//                // 2. Unique Appointment Number එකක් සෑදීම
//                String apptNumber = "APT-" + (1000 + (int)(Math.random() * 9000));
//
//                // 3. appointments වගුවට දත්ත ඇතුළත් කිරීම
//                String apptSql = "INSERT INTO appointments (appointment_number, patient_id, doctor_id, appointment_date, appointment_time) VALUES (?, ?, ?, ?, ?)";
//                PreparedStatement psAppt = conn.prepareStatement(apptSql);
//                psAppt.setString(1, apptNumber);
//                psAppt.setInt(2, patientId);
//                psAppt.setString(3, doctorId);
//                psAppt.setString(4, appointmentDate);
//                psAppt.setString(5, appointmentTime);
//                psAppt.executeUpdate();
//
//                conn.commit();
//                response.sendRedirect("manager-new-appointment.jsp?msg=Appointment+Created+Successfully:+ " + apptNumber);
//
//            } catch (Exception e) {
//                e.printStackTrace();
//                response.sendRedirect("manager-new-appointment.jsp?error=Failed+to+create+appointment");
//            }
//        }
//        else if ("cancelAppointment".equals(action)) {
//            String appointmentId = request.getParameter("appointmentId");
//
//            try (Connection conn = DBConnection.getConnection()) {
//                // Appointments වගුවෙන් අදාළ appointment එක ඉවත් කිරීම
//                String sql = "DELETE FROM appointments WHERE appointment_number = ?";
//                PreparedStatement ps = conn.prepareStatement(sql);
//                ps.setString(1, appointmentId);
//                ps.executeUpdate();
//
//                response.sendRedirect("manager-search-appointment.jsp?msg=Appointment+Cancelled+Successfully");
//
//            } catch (Exception e) {
//                e.printStackTrace();
//                response.sendRedirect("manager-search-appointment.jsp?error=Failed+to+cancel+appointment");
//
//            }
//
//        }
//    }
//}

package com.sunrisedental.web;

import com.sunrisedental.config.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/appointment-servlet")
public class AppointmentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : "";

        if ("createAppointment".equals(action)) {
            String patientName = request.getParameter("patientName");
            String address = request.getParameter("address");
            String idType = request.getParameter("idType");
            String identificationNumber = request.getParameter("identificationNumber");
            String contactNumber = request.getParameter("contactNumber");
            String doctorId = request.getParameter("doctorId");
            String appointmentDate = request.getParameter("appointmentDate");
            String appointmentTime = request.getParameter("appointmentTime");

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);


                String patientSql = "INSERT INTO patients (patient_code, full_name, address, id_type, identification_number, contact_number) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement psPatient = conn.prepareStatement(patientSql, Statement.RETURN_GENERATED_KEYS);

                String generatedPatientCode = "PAT-" + System.currentTimeMillis();
                psPatient.setString(1, generatedPatientCode);
                psPatient.setString(2, patientName);
                psPatient.setString(3, address);
                psPatient.setString(4, idType);
                psPatient.setString(5, identificationNumber);
                psPatient.setString(6, contactNumber);
                psPatient.executeUpdate();

                ResultSet rsKeys = psPatient.getGeneratedKeys();
                int patientId = 0;
                if (rsKeys.next()) {
                    patientId = rsKeys.getInt(1);
                }


                String apptNumber = "APT-" + (1000 + (int)(Math.random() * 9000));


                String apptSql = "INSERT INTO appointments (appointment_number, patient_id, doctor_id, appointment_date, appointment_time) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement psAppt = conn.prepareStatement(apptSql);
                psAppt.setString(1, apptNumber);
                psAppt.setInt(2, patientId);
                psAppt.setString(3, doctorId);
                psAppt.setString(4, appointmentDate);
                psAppt.setString(5, appointmentTime);
                psAppt.executeUpdate();

                conn.commit();


                if ("RECEPTIONIST".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("receptionist-new-appointment.jsp?msg=Appointment+Created+Successfully:+ " + apptNumber);
                } else if ("CLINIC_MANAGER".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("manager-new-appointment.jsp?msg=Appointment+Created+Successfully:+ " + apptNumber);
                } else {
                    response.sendRedirect("login.jsp");
                }

            } catch (Exception e) {
                e.printStackTrace();

                if ("RECEPTIONIST".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("receptionist-new-appointment.jsp?error=Failed+to+create+appointment");
                } else {
                    response.sendRedirect("manager-new-appointment.jsp?error=Failed+to+create+appointment");
                }
            }
        }
        else if ("cancelAppointment".equals(action)) {
            String appointmentId = request.getParameter("appointmentId");

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "DELETE FROM appointments WHERE appointment_number = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, appointmentId);
                ps.executeUpdate();

                if ("RECEPTIONIST".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("receptionist-search-appointment.jsp?msg=Appointment+Cancelled+Successfully");
                } else {
                    response.sendRedirect("manager-search-appointment.jsp?msg=Appointment+Cancelled+Successfully");
                }

            } catch (Exception e) {
                e.printStackTrace();
                if ("RECEPTIONIST".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("receptionist-search-appointment.jsp?error=Failed+to+cancel+appointment");
                } else {
                    response.sendRedirect("manager-search-appointment.jsp?error=Failed+to+cancel+appointment");
                }
            }
        }
    }
}