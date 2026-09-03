package com.sunrisedental.dao;

import com.sunrisedental.config.DBConnection;
import com.sunrisedental.dto.Appointment;
import java.sql.*;

public class AppointmentDAOImpl implements AppointmentDAO {

    @Override
    public boolean createAppointment(Appointment appt) {
        String sql = "INSERT INTO appointments (appointment_number, patient_id, dentist_user_id, treatment_id, appointment_datetime, created_by) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, appt.getAppointmentNumber());
            stmt.setInt(2, appt.getPatientId());
            stmt.setInt(3, appt.getDentistUserId());
            stmt.setInt(4, appt.getTreatmentId());
            stmt.setString(5, appt.getAppointmentDatetime());
            stmt.setInt(6, 1); // Default creator ID

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Appointment getAppointmentByNumber(String apptNumber) {
        String sql = "SELECT a.appointment_id, a.appointment_number, p.full_name AS patient_name, p.contact_number, u.full_name AS dentist_name, t.treatment_name, a.appointment_datetime, a.status " +
                "FROM appointments a " +
                "JOIN patients p ON a.patient_id = p.patient_id " +
                "JOIN users u ON a.dentist_user_id = u.user_id " +
                "JOIN treatments t ON a.treatment_id = t.treatment_id " +
                "WHERE a.appointment_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, apptNumber);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Appointment appt = new Appointment();
                appt.setAppointmentId(rs.getInt("appointment_id"));
                appt.setAppointmentNumber(rs.getString("appointment_number"));
                appt.setPatientName(rs.getString("patient_name"));
                appt.setContactNumber(rs.getString("contact_number"));
                appt.setDentistName(rs.getString("dentist_name"));
                appt.setTreatmentName(rs.getString("treatment_name"));
                appt.setAppointmentDatetime(rs.getString("appointment_datetime"));
                appt.setStatus(rs.getString("status"));
                return appt;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean processBilling(int apptId, double consultationFee, int issuedBy) {
        // Execute MySQL Stored Procedure sp_generate_patient_bill
        String sql = "{CALL sp_generate_patient_bill(?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setInt(1, apptId);
            stmt.setDouble(2, consultationFee);
            stmt.setInt(3, issuedBy);
            stmt.registerOutParameter(4, Types.VARCHAR);
            stmt.registerOutParameter(5, Types.DECIMAL);

            stmt.execute();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}