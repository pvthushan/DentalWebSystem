<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    // Clinic Manager Session Guard
    if (user == null || !"CLINIC_MANAGER".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Clinic Manager Portal</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }

        /* Left Sidebar Layout */
        .sidebar { width: 250px; background-color: #2c3e50; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #1abc9c; margin-bottom: 30px; display: flex; align-items: center; gap: 10px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #ecf0f1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #1abc9c; color: white; }
        .btn-logout-sidebar { background-color: #e74c3c; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }
        .btn-logout-sidebar:hover { background-color: #c0392b; }

        /* Main Content Layout */
        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 1px solid #e2e8f0; padding-bottom: 15px; }
        .header-bar h1 { font-size: 26px; color: #2c3e50; }
        .user-badge { font-size: 13px; color: #7f8c8d; }

        /* Dashboard Cards Grid Layout */
        .cards-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 25px; }
        .dash-card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); text-align: center; border: 1px solid #e2e8f0; }
        .dash-card h3 { font-size: 20px; color: #2c3e50; margin-bottom: 10px; }
        .dash-card p { font-size: 14px; color: #7f8c8d; margin-bottom: 20px; }
        .dash-link { display: inline-block; color: #1abc9c; font-weight: bold; text-decoration: none; font-size: 15px; }
        .dash-link:hover { text-decoration: underline; }

        /* Performance Overview Wide Card */
        .wide-card { background: #e8f8f5; padding: 30px; border-radius: 8px; border: 2px dashed #1abc9c; text-align: center; }
        .wide-card h3 { font-size: 20px; color: #2c3e50; margin-bottom: 10px; }
        .wide-card p { font-size: 14px; color: #7f8c8d; margin-bottom: 20px; }
    </style>
</head>
<body>

    <!-- Left Sidebar Menu -->
    <div class="sidebar">
        <h2>Sunrise Dental</h2>
        <div class="nav-menu">
            <a href="manager-dashboard.jsp" class="nav-btn active">🏠 Dashboard</a>
            <a href="manager-doctor-availability.jsp" class="nav-btn">👨‍⚕️ Doctor Availability</a>
            <a href="manager-new-appointment.jsp" class="nav-btn">➕ New Appointment</a>
            <a href="manager-search-appointment.jsp" class="nav-btn">🔍 Search Appointments</a>
            <a href="manager-calculate-bill.jsp" class="nav-btn">💳 Calculate Bill</a>
            <a href="manager-income-report.jsp" class="nav-btn">📊 Financial Reports</a>
            <a href="manager-help.jsp" class="nav-btn">❓ Help Section</a>
        </div>
        <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
    </div>

    <!-- Main Content Area -->
    <div class="main-content">
        <div class="header-bar">
            <h1>Clinic Management Portal</h1>
            <div class="user-badge">Role: <strong>Manager</strong> | User: <strong><%= user.getFullName() %></strong></div>
        </div>

        <!-- Dashboard Action Cards -->
        <div class="cards-grid">
            <div class="dash-card">
                <h3>Quick Appointment</h3>
                <p>Assign a doctor and book an appointment for a patient immediately.</p>
                <a href="manager-new-appointment.jsp" class="dash-link">New Booking →</a>
            </div>

            <div class="dash-card">
                <h3>Check Doctor Availability</h3>
                <p>Real-time duty status and consultation fees of clinic doctors.</p>
                <a href="manager-doctor-availability.jsp" class="dash-link">View Doctors →</a>
            </div>
        </div>

        <!-- Performance Overview Section -->
        <div class="wide-card">
            <h3>Performance Overview</h3>
            <p>View daily patient visits, treatment stats, and monthly clinic income stats.</p>
            <a href="manager-income-report.jsp" class="dash-link">Generate Reports →</a>
        </div>
    </div>

</body>
</html>