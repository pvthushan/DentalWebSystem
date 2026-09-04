package com.sunrisedental.dao;

import com.sunrisedental.dto.Patient;
import java.util.List;

public interface PatientDAO {
    boolean registerPatient(Patient patient);
    Patient getPatientByCode(String code);
}

