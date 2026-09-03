<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.sunrisedental.config.DBConnection" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"CLINIC_MANAGER".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Calculate Bill</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }
        .sidebar { width: 250px; background-color: #2c3e50; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #1abc9c; margin-bottom: 30px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #ecf0f1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; }
        .nav-btn:hover, .nav-btn.active { background-color: #1abc9c; color: white; }
        .btn-logout-sidebar { background-color: #e74c3c; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }
        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .header-bar h1 { font-size: 24px; color: #2c3e50; }
        .bill-container { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; }
        .card-box { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; }
        .card-box h3 { font-size: 18px; color: #2c3e50; margin-bottom: 15px; border-bottom: 2px solid #1abc9c; padding-bottom: 8px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #34495e; margin-bottom: 5px; }
        .form-control { width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; }
        .receipt-box { background: #fafafa; border: 1px dashed #cbd5e1; padding: 20px; border-radius: 6px; font-family: 'Courier New', Courier, monospace; }
        .receipt-header { text-align: center; margin-bottom: 15px; border-bottom: 1px dashed #aaa; padding-bottom: 10px; }
        .receipt-row { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px; }
        .receipt-total { border-top: 1px dashed #aaa; padding-top: 10px; font-weight: bold; font-size: 16px; margin-top: 10px; }
        .btn-calc { width: 100%; background-color: #1abc9c; color: white; border: none; padding: 10px; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 10px; }
        .btn-print { width: 100%; background-color: #3498db; color: white; border: none; padding: 12px; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 15px; font-size: 15px; }

        /* Print Styles - Receipt Only */
        @media print {
            body * {
                visibility: hidden;
            }
            #receiptArea, #receiptArea * {
                visibility: visible;
            }
            #receiptArea {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                border: none !important;
                background: white !important;
            }
            .btn-print {
                display: none !important;
            }
        }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Sunrise Dental</h2>
    <div class="nav-menu">
        <a href="manager-dashboard.jsp" class="nav-btn">🏠 Dashboard</a>
        <a href="manager-calculate-bill.jsp" class="nav-btn active">💳 Calculate Bill</a>
        <a href="manager-income-report.jsp" class="nav-btn">📊 Financial Reports</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <h1>💳 Calculate & Print Patient Bill</h1>
    </div>

    <div class="bill-container">
        <!-- Bill Form with Servlet Action -->
        <div class="card-box">
            <h3>Bill Details Form</h3>
            <form action="bill-servlet" method="POST">
                <input type="hidden" name="action" value="saveBill">
                <input type="hidden" name="appointmentNumber" id="hiddenApptNum">
                <input type="hidden" name="patientName" id="hiddenPatientName">
                <input type="hidden" name="doctorName" id="hiddenDoctorName">
                <input type="hidden" name="treatmentName" id="hiddenTreatmentName">
                <input type="hidden" name="consultationFee" id="hiddenDocFee">
                <input type="hidden" name="treatmentFee" id="hiddenTrtFee">
                <input type="hidden" name="otherFee" id="hiddenOtherFee">

                <div class="form-group">
                    <label>Appointment ID / Patient:</label>
                    <select class="form-control" id="apptSelect" onchange="updateDetails()" required>
                        <option value="">-- Select Confirmed Appointment --</option>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT a.appointment_number, p.full_name, a.doctor_id FROM appointments a JOIN patients p ON a.patient_id = p.patient_id";
                                PreparedStatement stmt = conn.prepareStatement(sql);
                                ResultSet rs = stmt.executeQuery();

                                while (rs.next()) {
                                    String apptNum = rs.getString("appointment_number");
                                    String patientName = rs.getString("full_name");
                                    String doctorId = rs.getString("doctor_id");
                                    double docFee = "DOC-02".equals(doctorId) ? 3500.00 : ("DOC-04".equals(doctorId) ? 4000.00 : 2500.00);
                        %>
                        <option value="<%= apptNum %>" data-patient="<%= patientName %>" data-doctor-name="Dr. <%= doctorId %>" data-doctor="<%= docFee %>">
                            <%= apptNum %> - <%= patientName %> (Doctor: <%= doctorId %>)
                        </option>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Treatment Given:</label>
                    <select class="form-control" id="treatmentSelect" onchange="updateDetails()" required>
                        <option value="0" data-name="None (Consultation Only)">None (Consultation Only)</option>
                        <option value="4500" data-name="Composite Dental Filling">Composite Dental Filling (Rs. 4,500)</option>
                        <option value="18000" data-name="Root Canal Treatment">Root Canal Treatment (Rs. 18,000)</option>
                        <option value="3000" data-name="Tooth Extraction">Tooth Extraction (Rs. 3,000)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Additional Expenses / Medicine (Rs.):</label>
                    <input type="number" id="otherFee" class="form-control" value="0.00" step="0.01" oninput="updateDetails()">
                </div>

                <button type="submit" class="btn-calc">Calculate Total & Save to Database</button>
            </form>
        </div>

        <!-- Receipt Preview Section -->
        <div class="card-box">
            <h3>Receipt Preview</h3>
            <div class="receipt-box" id="receiptArea">
                <div class="receipt-header">
                    <h2>SUNRISE DENTAL CARE</h2>
                    <p>No 123, Main Street, Colombo</p>
                </div>
                <div class="receipt-row"><span>Appt ID:</span> <span id="recAppt">-</span></div>
                <div class="receipt-row"><span>Patient:</span> <span id="recPatient">-</span></div>
                <div class="receipt-row"><span>Doctor:</span> <span id="recDoctor">-</span></div>
                <hr style="border:none; border-top: 1px dashed #aaa; margin: 10px 0;">
                <div class="receipt-row"><span>Consultation Fee:</span> <span id="recDocFee">Rs. 0.00</span></div>
                <div class="receipt-row"><span>Treatment Fee:</span> <span id="recTrtFee">Rs. 0.00</span></div>
                <div class="receipt-row"><span>Other Fees:</span> <span id="recOtherFee">Rs. 0.00</span></div>
                <div class="receipt-row receipt-total"><span>Total Amount:</span> <span id="recTotal">Rs. 0.00</span></div>
            </div>
            <button type="button" class="btn-print" onclick="window.print()">🖨️ Print Bill / Receipt</button>
        </div>
    </div>
</div>

<script>
    function updateDetails() {
        let appt = document.getElementById("apptSelect");
        let treatment = document.getElementById("treatmentSelect");

        let apptVal = appt.value;
        let patientName = appt.options[appt.selectedIndex].getAttribute("data-patient") || "";
        let doctorName = appt.options[appt.selectedIndex].getAttribute("data-doctor-name") || "";
        let docFee = parseFloat(appt.options[appt.selectedIndex].getAttribute("data-doctor") || 0);

        let treatmentName = treatment.options[treatment.selectedIndex].getAttribute("data-name") || "";
        let trtFee = parseFloat(treatment.value || 0);
        let otherFee = parseFloat(document.getElementById("otherFee").value || 0);

        let total = docFee + trtFee + otherFee;

        document.getElementById("hiddenApptNum").value = apptVal;
        document.getElementById("hiddenPatientName").value = patientName;
        document.getElementById("hiddenDoctorName").value = doctorName;
        document.getElementById("hiddenTreatmentName").value = treatmentName;
        document.getElementById("hiddenDocFee").value = docFee;
        document.getElementById("hiddenTrtFee").value = trtFee;
        document.getElementById("hiddenOtherFee").value = otherFee;

        document.getElementById("recAppt").innerText = apptVal || "-";
        document.getElementById("recPatient").innerText = patientName || "-";
        document.getElementById("recDoctor").innerText = doctorName || "-";
        document.getElementById("recDocFee").innerText = "Rs. " + docFee.toFixed(2);
        document.getElementById("recTrtFee").innerText = "Rs. " + trtFee.toFixed(2);
        document.getElementById("recOtherFee").innerText = "Rs. " + otherFee.toFixed(2);
        document.getElementById("recTotal").innerText = "Rs. " + total.toFixed(2);
    }
</script>
</body>
</html>