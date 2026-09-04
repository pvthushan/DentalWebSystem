package com.sunrisedental.dao;

import com.sunrisedental.config.DBConnection;
import com.sunrisedental.dto.Patient;
import java.sql.*;

public class PatientDAOImpl implements PatientDAO {

    @Override
    public boolean registerPatient(Patient patient) {

        String countSql = "SELECT COALESCE(MAX(patient_id), 0) + 1 AS next_id FROM patients";
        String insertSql = "INSERT INTO patients (patient_code, full_name, address, contact_number, email) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(countSql)) {

            int nextId = 1000;
            if (rs.next()) {
                nextId += rs.getInt("next_id");
            }


            String generatedCode = "PAT-" + nextId;
            patient.setPatientCode(generatedCode);


            try (PreparedStatement prepStmt = conn.prepareStatement(insertSql)) {
                prepStmt.setString(1, patient.getPatientCode());
                prepStmt.setString(2, patient.getFullName());
                prepStmt.setString(3, patient.getAddress());
                prepStmt.setString(4, patient.getContactNumber());
                prepStmt.setString(5, patient.getEmail());

                return prepStmt.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Patient getPatientByCode(String code) {
        String sql = "SELECT * FROM patients WHERE patient_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, code);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Patient patient = new Patient();
                patient.setPatientId(rs.getInt("patient_id"));
                patient.setPatientCode(rs.getString("patient_code"));
                patient.setFullName(rs.getString("full_name"));
                patient.setAddress(rs.getString("address"));
                patient.setContactNumber(rs.getString("contact_number"));
                patient.setEmail(rs.getString("email"));
                return patient;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}