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
    String safeUserRole = (userRole != null) ? userRole.replaceAll("[<>]", "") : "RECEPTIONIST";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - New Appointment</title>
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
        .header-bar p { font-size: 14px; color: #64748b; margin-top: 5px; }
        .user-badge { font-size: 13px; color: #64748b; }

        .card-box { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; max-width: 900px; }
        .card-box h3 { font-size: 18px; color: #0f172a; margin-bottom: 20px; border-bottom: 2px solid #0ea5e9; padding-bottom: 8px; }

        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group.full-width { grid-column: span 2; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 6px; }
        .form-control { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; }
        .form-control:focus { border-color: #0ea5e9; }

        .btn-submit { background-color: #0ea5e9; color: white; border: none; padding: 12px 24px; border-radius: 6px; font-weight: bold; cursor: pointer; font-size: 15px; width: 100%; margin-top: 10px; }
        .btn-submit:hover { background-color: #0284c7; }
    </style>
    <script>
        function updateIdPlaceholder() {
            var select = document.getElementById("idType");
            var input = document.getElementById("identificationNumber");
            var selectedValue = select.value;

            if (selectedValue === "NIC") {
                input.placeholder = "Enter NIC Number (e.g., 991234567V or 200012345678)";
            } else if (selectedValue === "PASSPORT") {
                input.placeholder = "Enter Passport Number (e.g., N1234567)";
            } else if (selectedValue === "DRIVING_LICENSE") {
                input.placeholder = "Enter Driving License Number (e.g., B1234567)";
            } else {
                input.placeholder = "Enter ID Number";
            }
        }

        function validateAppointmentForm() {
            let patientName = document.getElementById("patientName").value.trim();
            let address = document.getElementById("address").value.trim();
            let idType = document.getElementById("idType").value;
            let idNumber = document.getElementById("identificationNumber").value.trim();
            let contactNumber = document.getElementById("contactNumber").value.trim();
            let doctorId = document.getElementById("doctorId").value;
            let appointmentDate = document.getElementById("appointmentDate").value;
            let appointmentTime = document.getElementById("appointmentTime").value;

            if (patientName.length < 3) {
                alert("Patient Name must be at least 3 characters long.");
                document.getElementById("patientName").focus();
                return false;
            }

            if (address.length < 5) {
                alert("Please provide a valid address (at least 5 characters).");
                document.getElementById("address").focus();
                return false;
            }

            if (!idType || idType === "") {
                alert("Please select an Identification Type.");
                document.getElementById("idType").focus();
                return false;
            }

            if (idNumber === "") {
                alert("Identification Number cannot be empty.");
                document.getElementById("identificationNumber").focus();
                return false;
            }

            if (idType === "NIC") {
                let nicRegex = /^([0-9]{9}[vVxX]|[0-9]{12})$/;
                if (!nicRegex.test(idNumber)) {
                    alert("Please enter a valid NIC format (e.g., 991234567V or 12-digit number).");
                    document.getElementById("identificationNumber").focus();
                    return false;
                }
            }

            let phoneRegex = /^[0-9]{10}$/;
            if (!phoneRegex.test(contactNumber)) {
                alert("Please enter a valid 10-digit contact number (numbers only).");
                document.getElementById("contactNumber").focus();
                return false;
            }

            if (!doctorId || doctorId === "") {
                alert("Please select a doctor.");
                document.getElementById("doctorId").focus();
                return false;
            }

            if (!appointmentDate) {
                alert("Please select an appointment date.");
                document.getElementById("appointmentDate").focus();
                return false;
            }

            let selectedDate = new Date(appointmentDate);
            let today = new Date();
            today.setHours(0, 0, 0, 0);

            if (selectedDate < today) {
                alert("Appointment date cannot be in the past.");
                document.getElementById("appointmentDate").focus();
                return false;
            }

            if (!appointmentTime) {
                alert("Please select an appointment time.");
                document.getElementById("appointmentTime").focus();
                return false;
            }

            let isConfirmed = confirm("Do you want to confirm this appointment?");
            if (!isConfirmed) {
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
        <a href="receptionist-new-appointment.jsp" class="nav-btn active">➕ New Appointment</a>
        <a href="receptionist-search-appointment.jsp" class="nav-btn">🔍 Search Appointments</a>
        <a href="receptionist-calculate-bill.jsp" class="nav-btn">💳 Calculate Bill</a>
        <a href="receptionist-help.jsp" class="nav-btn">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <div>
            <h1>➕ Create New Appointment</h1>
            <p>Enter patient and appointment details to schedule a doctor consultation.</p>
        </div>
        <div class="user-badge">User: <strong><%= safeUsername %></strong> (<%= safeUserRole %>)</div>
    </div>

    <div class="card-box">
        <h3>Patient & Appointment Form</h3>
        <form action="appointment-servlet" method="POST" onsubmit="return validateAppointmentForm()">
            <input type="hidden" name="action" value="createAppointment">

            <div class="form-grid">
                <div class="form-group">
                    <label>Patient Full Name *</label>
                    <input type="text" id="patientName" name="patientName" class="form-control" placeholder="e.g. Nimal Perera" required minlength="3" maxlength="100">
                </div>

                <div class="form-group">
                    <label>Address *</label>
                    <input type="text" id="address" name="address" class="form-control" placeholder="e.g. No. 12, Main Street, Colombo" required minlength="5" maxlength="255">
                </div>

                <div class="form-group">
                    <label>Identification Type *</label>
                    <select name="idType" id="idType" class="form-control" onchange="updateIdPlaceholder()" required>
                        <option value="" disabled selected>Select ID Type</option>
                        <option value="NIC">National Identity Card (NIC)</option>
                        <option value="PASSPORT">Passport</option>
                        <option value="DRIVING_LICENSE">Driving License</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Identification Number *</label>
                    <input type="text" name="identificationNumber" id="identificationNumber" class="form-control" placeholder="Select ID Type first" required maxlength="30">
                </div>

                <div class="form-group">
                    <label>Contact Number *</label>
                    <input type="tel" id="contactNumber" name="contactNumber" class="form-control" placeholder="e.g. 0771234567" required pattern="[0-9]{10}" maxlength="10">
                </div>

                <div class="form-group">
                    <label>Select Doctor *</label>
                    <select name="doctorId" id="doctorId" class="form-control" required>
                        <option value="" disabled selected>Select Doctor</option>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String docSql = "SELECT doctor_id, doctor_name, specialization FROM doctors";
                                PreparedStatement docStmt = conn.prepareStatement(docSql);
                                ResultSet docRs = docStmt.executeQuery();

                                while (docRs.next()) {
                                    String docId = docRs.getString("doctor_id");
                                    String docName = docRs.getString("doctor_name");
                                    String specialization = docRs.getString("specialization");
                        %>
                        <option value="<%= docId %>"><%= docName %> (<%= specialization %>)</option>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Appointment Date *</label>
                    <input type="date" id="appointmentDate" name="appointmentDate" class="form-control" required>
                </div>

                <div class="form-group">
                    <label>Appointment Time *</label>
                    <input type="time" id="appointmentTime" name="appointmentTime" class="form-control" required>
                </div>
            </div>

            <button type="submit" class="btn-submit">Confirm & Register Appointment</button>
        </form>
    </div>
</div>

</body>
</html>