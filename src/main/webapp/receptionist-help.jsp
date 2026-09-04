<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"RECEPTIONIST".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Help Section</title>
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
        .header-bar { margin-bottom: 25px; }
        .header-bar h1 { font-size: 26px; color: #0f172a; }
        .header-bar p { font-size: 14px; color: #64748b; margin-top: 5px; }


        .help-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 25px; }
        .card-box { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; margin-bottom: 20px; }
        .card-box h3 { font-size: 18px; color: #0f172a; margin-bottom: 15px; border-bottom: 2px solid #0ea5e9; padding-bottom: 8px; }


        .guide-list { list-style: none; display: flex; flex-direction: column; gap: 12px; }
        .guide-item { font-size: 14px; color: #334155; line-height: 1.5; }
        .guide-item strong { color: #0f172a; }


        .contact-info { display: flex; flex-direction: column; gap: 10px; font-size: 14px; color: #334155; }
        .contact-info div { display: flex; align-items: center; gap: 10px; }
    </style>
</head>
<body>


<div class="sidebar">
    <h2>Sunrise Dental</h2>
    <div class="nav-menu">
        <a href="receptionist-dashboard.jsp" class="nav-btn">🏠 Dashboard</a>
        <a href="doctor-availability" class="nav-btn">👨‍⚕️ Doctor Availability</a>
        <a href="receptionist-new-appointment.jsp" class="nav-btn">➕ New Appointment</a>
        <a href="receptionist-search-appointment.jsp" class="nav-btn">🔍 Search Appointments</a>
        <a href="receptionist-calculate-bill.jsp" class="nav-btn">💳 Calculate Bill</a>
        <a href="receptionist-help.jsp" class="nav-btn active">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>


<div class="main-content">
    <div class="header-bar">
        <h1>❓ Receptionist Guidance & Support</h1>
        <p>Help, FAQs, and system instructions for Receptionists.</p>
    </div>

    <div class="help-grid">

        <div>
            <div class="card-box">
                <h3>📌 System Module Guidance</h3>
                <ul class="guide-list">
                    <li class="guide-item">
                        <strong>1. Doctor Availability:</strong> Use it to check the list of doctors at the clinic, their specialization, and consultation fees.
                    </li>
                    <li class="guide-item">
                        <strong>2. New Appointment:</strong> Enter the details of the patients you are visiting and select a date and time slot under the relevant doctor to book.
                    </li>
                    <li class="guide-item">
                        <strong>3. Search Appointments:</strong>You can view the list of all appointments (Read-Only View).
                    </li>
                    <li class="guide-item">
                        <strong>4. Calculate Bill:</strong>Select the appointment, enter the treatment performed and medication charges, and print the receipt.
                    </li>
                </ul>
            </div>

            <div class="card-box">
                <h3>❓ Frequently Asked Questions (FAQ)</h3>
                <ul class="guide-list">
                    <li class="guide-item">
                        <strong>Q: Can I cancel/delete an appointment?</strong><br>
                        A: No. Delete/Cancel Privileges are not enabled for the Receptionist Role. You will need to contact the Clinic Manager if required.
                    </li>
                    <li class="guide-item">
                        <strong>Q: How to change Doctor Availability?</strong><br>
                        A: Doctor Availability and Time Slots are controlled by the system Admin or Manager.
                    </li>
                </ul>
            </div>
        </div>


        <div>
            <div class="card-box">
                <h3>📞 Technical Support</h3>
                <div class="contact-info">
                    <p>If there is any error or problem with the system, contact the System Administrator.</p>
                    <hr style="border:none; border-top: 1px solid #e2e8f0; margin: 10px 0;">
                    <div>📧 <strong>Email:</strong> support@sunrisedental.com</div>
                    <div>📞 <strong>Hotline:</strong> +94 11 234 5678</div>
                    <div>🏢 <strong>IT Dept:</strong> Receptionist Support Desk</div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>