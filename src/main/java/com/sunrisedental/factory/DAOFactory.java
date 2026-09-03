package com.sunrisedental.factory;

import com.sunrisedental.dao.*;

public class DAOFactory {
    public static AppointmentDAO getAppointmentDAO() {
        return new AppointmentDAOImpl();
    }

    public static PatientDAO getPatientDAO() {
        return new PatientDAOImpl();
    }

    public static UserDAO getUserDAO() {
        return new UserDAOImpl();
    }
}