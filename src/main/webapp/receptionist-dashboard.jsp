<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
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
    <title>Sunrise Dental - Receptionist Dashboard</title>
    <script>

        history.pushState(null, null, location.href);
        window.onpopstate = function () {
            history.go(1);
        };
    </script>
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
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .header-bar h1 { font-size: 26px; color: #0f172a; }
        .user-badge { font-size: 14px; color: #64748b; background: #e2e8f0; padding: 6px 14px; border-radius: 20px; }


        .welcome-card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 30px; border-left: 5px solid #0ea5e9; }
        .welcome-card h2 { font-size: 20px; color: #1e293b; margin-bottom: 8px; }
        .welcome-card p { font-size: 14px; color: #64748b; }

        .dashboard-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .action-card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; text-align: center; transition: transform 0.2s; }
        .action-card:hover { transform: translateY(-3px); }
        .action-card h3 { font-size: 18px; color: #0f172a; margin-bottom: 10px; }
        .action-card p { font-size: 13px; color: #64748b; margin-bottom: 20px; }
        .btn-action { display: inline-block; padding: 10px 20px; background-color: #0ea5e9; color: white; text-decoration: none; font-weight: bold; border-radius: 6px; font-size: 14px; }
        .btn-action:hover { background-color: #0284c7; }
    </style>
</head>
<body>


<div class="sidebar">
    <h2>Sunrise Dental</h2>
    <div class="nav-menu">
        <a href="receptionist-dashboard.jsp" class="nav-btn active">🏠 Dashboard</a>
        <a href="doctor-availability" class="nav-btn">👨‍⚕️ Doctor Availability</a>
        <a href="receptionist-new-appointment.jsp" class="nav-btn">➕ New Appointment</a>
        <a href="receptionist-search-appointment.jsp" class="nav-btn">🔍 Search Appointments</a>
        <a href="receptionist-calculate-bill.jsp" class="nav-btn">💳 Calculate Bill</a>
        <a href="receptionist-help.jsp" class="nav-btn">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>


<div class="main-content">
    <div class="header-bar">
        <h1>Receptionist Dashboard</h1>
        <div class="user-badge">Logged as: <strong><%= safeUsername %></strong> (<%= safeUserRole %>)</div>
    </div>

    <div class="welcome-card">
        <h2>Welcome to Receptionist Panel</h2>
        <p>Manage daily patient check-ins, appointment scheduling, and billing quickly.</p>
    </div>


    <div class="dashboard-grid">
        <div class="action-card">
            <h3>➕ Quick Appointment</h3>
            <p>Register new walk-in or phone-in patients and assign appointments.</p>
            <a href="receptionist-new-appointment.jsp" class="btn-action">Create Appointment</a>
        </div>

        <div class="action-card">
            <h3>👨‍⚕️ Check Doctor Availability</h3>
            <p>View current available dental specialists, consultation fees, and room status.</p>
            <a href="doctor-availability" class="btn-action">Check Availability</a>
        </div>
    </div>
</div>

</body>
</html>