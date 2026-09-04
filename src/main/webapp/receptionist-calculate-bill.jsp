<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.sunrisedental.config.DBConnection" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"RECEPTIONIST".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    String safeUsername = (user.getUsername() != null) ? user.getUsername().replaceAll("[<>]", "") : "Receptionist";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Calculate & Print Bill</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }

        .sidebar { width: 250px; background-color: #1e293b; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #0ea5e9; margin-bottom: 30px; font-weight: bold; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #cbd5e1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #0ea5e9; color: white; }
        .btn-logout-sidebar { background-color: #ef4444; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }

        .main-content { flex: 1; padding: 35px 40px; }
        .header-bar { margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; }
        .header-bar h1 { font-size: 26px; color: #0f172a; }
        .user-badge { font-size: 13px; color: #64748b; }

        .bill-container { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; }
        .card-box { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; }
        .card-box h3 { font-size: 18px; color: #0f172a; margin-bottom: 15px; border-bottom: 2px solid #0ea5e9; padding-bottom: 8px; }

        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 6px; }
        .form-control { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; }
        .form-control:focus { border-color: #0ea5e9; }

        .receipt-box { background: #f8fafc; border: 1px dashed #cbd5e1; padding: 20px; border-radius: 6px; font-family: 'Courier New', Courier, monospace; }
        .receipt-header { text-align: center; margin-bottom: 15px; border-bottom: 1px dashed #94a3b8; padding-bottom: 10px; }
        .receipt-row { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px; }
        .receipt-total { border-top: 1px dashed #94a3b8; padding-top: 10px; font-weight: bold; font-size: 16px; margin-top: 10px; color: #0f172a; }

        .btn-calc { width: 100%; background-color: #0ea5e9; color: white; border: none; padding: 12px; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 10px; font-size: 15px; }
        .btn-calc:hover { background-color: #0284c7; }
        .btn-print { width: 100%; background-color: #0284c7; color: white; border: none; padding: 12px; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 15px; font-size: 15px; }
        .btn-print:hover { background-color: #0369a1; }

        @media print {
            .sidebar, .header-bar, .card-box:first-child, .btn-print { display: none !important; }
            body { background: white; }
            .main-content { padding: 0; }
            .bill-container { grid-template-columns: 1fr; }
            .receipt-box { border: none; }
        }
    </style>
    <script>
        function updateDetails() {
            let appt = document.getElementById("apptSelect");
            let treatment = document.getElementById("treatmentSelect");

            let apptVal = appt.value;
            let patientName = appt.selectedIndex !== -1 && appt.options[appt.selectedIndex] ? (appt.options[appt.selectedIndex].getAttribute("data-patient") || "") : "";
            let doctorName = appt.selectedIndex !== -1 && appt.options[appt.selectedIndex] ? (appt.options[appt.selectedIndex].getAttribute("data-doctor-name") || "") : "";
            let docFee = appt.selectedIndex !== -1 && appt.options[appt.selectedIndex] ? parseFloat(appt.options[appt.selectedIndex].getAttribute("data-doctor") || 0) : 0;

            let treatmentName = treatment.selectedIndex !== -1 && treatment.options[treatment.selectedIndex] ? (treatment.options[treatment.selectedIndex].getAttribute("data-name") || "") : "";
            let trtFee = parseFloat(treatment.value || 0);
            let otherFeeVal = parseFloat(document.getElementById("otherFee").value);
            let otherFee = (isNaN(otherFeeVal) || otherFeeVal < 0) ? 0 : otherFeeVal;

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

        function validateBillingForm() {
            let apptSelect = document.getElementById("apptSelect");
            let otherFeeInput = document.getElementById("otherFee");

            if (!apptSelect.value || apptSelect.value === "") {
                alert("Please select a confirmed appointment.");
                apptSelect.focus();
                return false;
            }

            let otherFee = parseFloat(otherFeeInput.value);
            if (isNaN(otherFee) || otherFee < 0) {
                alert("Additional expenses / medicine fee cannot be negative.");
                otherFeeInput.value = "0.00";
                otherFeeInput.focus();
                return false;
            }

            return true;
        }
    </script>
</head>
<body>

<div class="sidebar">
    <h2>Sunrise Dental</h2>
    <div class="nav-menu">
        <a href="receptionist-dashboard.jsp" class="nav-btn">🏠 Dashboard</a>
        <a href="doctor-availability" class="nav-btn">👨‍⚕️ Doctor Availability</a>
        <a href="receptionist-new-appointment.jsp" class="nav-btn">➕ New Appointment</a>
        <a href="receptionist-search-appointment.jsp" class="nav-btn">🔍 Search Appointments</a>
        <a href="receptionist-calculate-bill.jsp" class="nav-btn active">💳 Calculate Bill</a>
        <a href="receptionist-help.jsp" class="nav-btn">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <h1>💳 Calculate & Print Patient Bill</h1>
        <div class="user-badge">User: <strong><%= safeUsername %></strong></div>
    </div>

    <div class="bill-container">

        <div class="card-box">
            <h3>Bill Details Form</h3>
            <form action="bill-servlet" method="POST" onsubmit="return validateBillingForm()">
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
                                String sql = "SELECT a.appointment_number, p.full_name, a.doctor_id, " +
                                        "COALESCE(d.doctor_name, a.doctor_id) AS doctor_name, " +
                                        "COALESCE(d.consultation_fee, 2500.00) AS consultation_fee " +
                                        "FROM appointments a " +
                                        "JOIN patients p ON a.patient_id = p.patient_id " +
                                        "LEFT JOIN doctors d ON CAST(REPLACE(a.doctor_id, 'DOC-', '') AS UNSIGNED) = d.doctor_id";

                                PreparedStatement stmt = conn.prepareStatement(sql);
                                ResultSet rs = stmt.executeQuery();

                                while (rs.next()) {
                                    String apptNum = rs.getString("appointment_number");
                                    String patientName = rs.getString("full_name");
                                    String doctorId = rs.getString("doctor_id");
                                    String doctorName = rs.getString("doctor_name");
                                    double docFee = rs.getDouble("consultation_fee");
                        %>
                        <option value="<%= apptNum %>" data-patient="<%= patientName %>" data-doctor-name="<%= doctorName %>" data-doctor="<%= docFee %>">
                            <%= apptNum %> - <%= patientName %> (<%= doctorName %> - Rs. <%= String.format("%,.2f", docFee) %>)
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
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String tSql = "SELECT treatment_name, treatment_cost FROM treatments";
                                PreparedStatement tStmt = conn.prepareStatement(tSql);
                                ResultSet tRs = tStmt.executeQuery();

                                while (tRs.next()) {
                                    String tName = tRs.getString("treatment_name");
                                    double tCost = tRs.getDouble("treatment_cost");
                        %>
                        <option value="<%= tCost %>" data-name="<%= tName %>">
                            <%= tName %> (Rs. <%= String.format("%,.2f", tCost) %>)
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
                    <label>Additional Expenses / Medicine (Rs.):</label>
                    <input type="number" id="otherFee" class="form-control" value="0.00" min="0" step="0.01" oninput="updateDetails()" required>
                </div>

                <button type="submit" class="btn-calc">Calculate Total & Save to Bill</button>
            </form>
        </div>

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

</body>
</html>