package com.sunrisedental.dto;

import java.io.Serializable;

public class Doctor implements Serializable {
    private static final long serialVersionUID = 1L;

    private int doctorId;
    private String doctorName;
    private String specialization;
    private String contactNumber;
    private double consultationFee;
    private String status;

    public Doctor() {}

    public Doctor(int doctorId, String doctorName, String specialization, String contactNumber, double consultationFee, String status) {
        this.doctorId = doctorId;
        this.doctorName = doctorName;
        this.specialization = specialization;
        this.contactNumber = contactNumber;
        this.consultationFee = consultationFee;
        this.status = status;
    }

    public int getDoctorId() { return doctorId; }
    public void setDoctorId(int doctorId) { this.doctorId = doctorId; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public double getConsultationFee() { return consultationFee; }
    public void setConsultationFee(double consultationFee) { this.consultationFee = consultationFee; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}