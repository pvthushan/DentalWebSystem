<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"CLINIC_MANAGER".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    String safeUsername = (user.getUsername() != null) ? user.getUsername().replaceAll("[<>]", "") : "Manager";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Help Section</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }


        .sidebar { width: 250px; background-color: #2c3e50; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #1abc9c; margin-bottom: 30px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #ecf0f1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #1abc9c; color: white; }
        .btn-logout-sidebar { background-color: #e74c3c; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }


        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { margin-bottom: 25px; }
        .header-bar h1 { font-size: 26px; color: #2c3e50; }
        .header-bar p { font-size: 14px; color: #7f8c8d; margin-top: 5px; }


        .help-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 25px; }
        .card-box { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; margin-bottom: 20px; }
        .card-box h3 { font-size: 18px; color: #2c3e50; margin-bottom: 15px; border-bottom: 2px solid #1abc9c; padding-bottom: 8px; }


        .guide-list { list-style: none; display: flex; flex-direction: column; gap: 12px; }
        .guide-item { font-size: 14px; color: #34495e; line-height: 1.5; }
        .guide-item strong { color: #2c3e50; }


        .contact-info { display: flex; flex-direction: column; gap: 10px; font-size: 14px; color: #34495e; }
        .contact-info div { display: flex; align-items: center; gap: 10px; }
    </style>
</head>
<body>


<div class="sidebar">
    <h2>Sunrise Dental</h2>
    <div class="nav-menu">
        <a href="manager-dashboard.jsp" class="nav-btn">🏠 Dashboard</a>
        <a href="manager-doctor-availability.jsp" class="nav-btn">👨‍⚕️ Doctor Availability</a>
        <a href="manager-new-appointment.jsp" class="nav-btn">➕ New Appointment</a>
        <a href="manager-search-appointment.jsp" class="nav-btn">🔍 Search Appointments</a>
        <a href="manager-calculate-bill.jsp" class="nav-btn">💳 Calculate Bill</a>
        <a href="manager-income-report.jsp" class="nav-btn">📊 Financial Reports</a>
        <a href="manager-help.jsp" class="nav-btn active">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>


<div class="main-content">
    <div class="header-bar">
        <h1>❓ Manager Guidance & Support</h1>
        <p>Help, FAQs, and system instructions for Clinic Managers. Logged in as: <strong><%= safeUsername %></strong></p>
    </div>

    <div class="help-grid">

        <div>
            <div class="card-box">
                <h3>📌 System Module Instructions</h3>
                <ul class="guide-list">
                    <li class="guide-item">
                        <strong>1. Doctor Availability:</strong> Use it to check the list of doctors in service and consultation fees in real-time.
                    </li>
                    <li class="guide-item">
                        <strong>2. New Appointment:</strong> Enter the details of the patients who are coming and reserve a date and time with the relevant doctor.
                    </li>
                    <li class="guide-item">
                        <strong>3. Search Appointments:</strong> You can view the list of all appointments. If you want to cancel <i>Cancel Appointment</i> Use the button.
                    </li>
                    <li class="guide-item">
                        <strong>4. Calculate Bill:</strong> Select the appointment, enter the treatment performed and medication charges, and print the final receipt.
                    </li>
                </ul>
            </div>

            <div class="card-box">
                <h3>❓ Frequently Asked Questions (FAQ)</h3>
                <ul class="guide-list">
                    <li class="guide-item">
                        <strong>Q: Can I edit the details of an appointment?</strong><br>
                        A: No. The editing feature is disabled as only daily walk-in appointments are maintained.
                    </li>
                    <li class="guide-item">
                        <strong>Q: How to change Treatment and Pricing?</strong><br>
                        A: Pricing and Treatment types are changed by the System Admin.
                    </li>
                </ul>
            </div>
        </div>


        <div>
            <div class="card-box">
                <h3>📞 Technical Support</h3>
                <div class="contact-info">
                    <p>If there is an error or technical problem with the system, contact the System Administrator.</p>
                    <hr style="border:none; border-top: 1px solid #e2e8f0; margin: 10px 0;">
                    <div>📧 <strong>Email:</strong> support@sunrisedental.com</div>
                    <div>📞 <strong>Hotline:</strong> +94 11 234 5678</div>
                    <div>🏢 <strong>IT Office:</strong> Room 402, Admin Building</div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>