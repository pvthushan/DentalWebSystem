package com.sunrisedental.dao;
import com.sunrisedental.config.DBConnection;
import com.sunrisedental.dao.DoctorDAO;
import com.sunrisedental.dto.Doctor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DoctorDAOImpl implements DoctorDAO {

    @Override
    public boolean addDoctor(Doctor doctor) {
        String sql = "INSERT INTO doctors (doctor_name, specialization, contact_number, consultation_fee, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, doctor.getDoctorName());
            stmt.setString(2, doctor.getSpecialization());
            stmt.setString(3, doctor.getContactNumber());
            stmt.setDouble(4, doctor.getConsultationFee());
            stmt.setString(5, doctor.getStatus() != null ? doctor.getStatus() : "AVAILABLE");

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateDoctor(Doctor doctor) {
        String sql = "UPDATE doctors SET doctor_name = ?, specialization = ?, contact_number = ?, consultation_fee = ?, status = ? WHERE doctor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, doctor.getDoctorName());
            stmt.setString(2, doctor.getSpecialization());
            stmt.setString(3, doctor.getContactNumber());
            stmt.setDouble(4, doctor.getConsultationFee());
            stmt.setString(5, doctor.getStatus());
            stmt.setInt(6, doctor.getDoctorId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteDoctor(int doctorId) {
        String sql = "DELETE FROM doctors WHERE doctor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, doctorId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Doctor getDoctorById(int doctorId) {
        String sql = "SELECT * FROM doctors WHERE doctor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, doctorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return new Doctor(
                        rs.getInt("doctor_id"),
                        rs.getString("doctor_name"),
                        rs.getString("specialization"),
                        rs.getString("contact_number"),
                        rs.getDouble("consultation_fee"),
                        rs.getString("status")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Doctor> getAllDoctors() {
        List<Doctor> doctorList = new ArrayList<>();
        String sql = "SELECT * FROM doctors";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Doctor doctor = new Doctor(
                        rs.getInt("doctor_id"),
                        rs.getString("doctor_name"),
                        rs.getString("specialization"),
                        rs.getString("contact_number"),
                        rs.getDouble("consultation_fee"),
                        rs.getString("status")
                );
                doctorList.add(doctor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return doctorList;
    }
}