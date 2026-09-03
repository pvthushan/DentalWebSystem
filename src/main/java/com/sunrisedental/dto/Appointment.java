package com.sunrisedental.dto;

public class Appointment {
    private int appointmentId;
    private String appointmentNumber;
    private int patientId;
    private String patientName;
    private String contactNumber;
    private int dentistUserId;
    private String dentistName;
    private int treatmentId;
    private String treatmentName;
    private String appointmentDatetime;
    private String status;

    public Appointment() {}

    // Getters & Setters
    public int getAppointmentId() { return appointmentId; }
    public void setAppointmentId(int appointmentId) { this.appointmentId = appointmentId; }
    public String getAppointmentNumber() { return appointmentNumber; }
    public void setAppointmentNumber(String appointmentNumber) { this.appointmentNumber = appointmentNumber; }
    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }
    public int getDentistUserId() { return dentistUserId; }
    public void setDentistUserId(int dentistUserId) { this.dentistUserId = dentistUserId; }
    public String getDentistName() { return dentistName; }
    public void setDentistName(String dentistName) { this.dentistName = dentistName; }
    public int getTreatmentId() { return treatmentId; }
    public void setTreatmentId(int treatmentId) { this.treatmentId = treatmentId; }
    public String getTreatmentName() { return treatmentName; }
    public void setTreatmentName(String treatmentName) { this.treatmentName = treatmentName; }
    public String getAppointmentDatetime() { return appointmentDatetime; }
    public void setAppointmentDatetime(String appointmentDatetime) { this.appointmentDatetime = appointmentDatetime; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}