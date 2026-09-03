package com.sunrisedental.dao;

import com.sunrisedental.dto.Appointment;

public interface AppointmentDAO {
    boolean createAppointment(Appointment appt);
    Appointment getAppointmentByNumber(String apptNumber);
    boolean processBilling(int apptId, double consultationFee, int issuedBy);
}
