package com.sunrisedental.dao;

import com.sunrisedental.dto.Doctor;
import java.util.List;

public interface DoctorDAO {
    boolean addDoctor(Doctor doctor);
    boolean updateDoctor(Doctor doctor);
    boolean deleteDoctor(int doctorId);
    Doctor getDoctorById(int doctorId);
    List<Doctor> getAllDoctors();
}