<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    // Admin Session Guard
    if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    // Dynamic Variables (In production, load these values via Servlet Request Attributes)
    int activeStaffCount = request.getAttribute("activeStaff") != null ? (Integer) request.getAttribute("activeStaff") : 4;
    int totalAppointments = request.getAttribute("totalAppointments") != null ? (Integer) request.getAttribute("totalAppointments") : 12;
    double todaysIncome = request.getAttribute("todaysIncome") != null ? (Double) request.getAttribute("todaysIncome") : 25000.00;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Admin Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }

        /* Left Sidebar Layout */
        .sidebar { width: 250px; background-color: #1e293b; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #f59e0b; margin-bottom: 30px; display: flex; align-items: center; gap: 10px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #cbd5e1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #f59e0b; color: #0f172a; }
        .btn-logout-sidebar { background-color: #ef4444; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }
        .btn-logout-sidebar:hover { background-color: #dc2626; }

        /* Main Content Layout */
        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 1px solid #e2e8f0; padding-bottom: 15px; }
        .header-bar h1 { font-size: 24px; color: #0f172a; }
        .admin-badge { font-size: 13px; color: #64748b; }

        /* KPI Stat Cards */
        .kpi-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
        .kpi-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); text-align: center; border-top: 4px solid #f59e0b; }
        .kpi-card.income-card { border-top-color: #10b981; }
        .kpi-card h4 { color: #64748b; font-size: 14px; text-transform: uppercase; margin-bottom: 10px; }
        .kpi-card .value { font-size: 28px; font-weight: bold; color: #0f172a; }

        /* Quick Actions Section */
        .action-section { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .action-section h3 { font-size: 18px; color: #0f172a; margin-bottom: 10px; }
        .action-section p { font-size: 14px; color: #64748b; margin-bottom: 20px; }
        .action-btn-group { display: flex; gap: 15px; }
        .btn-action { display: inline-block; padding: 10px 20px; border-radius: 6px; text-decoration: none; font-weight: bold; font-size: 14px; color: white; background-color: #334155; transition: 0.2s; }
        .btn-action.btn-yellow { background-color: #eab308; color: #0f172a; }
        .btn-action:hover { opacity: 0.9; }
    </style>
</head>
<body>

    <!-- Left Sidebar Menu -->
    <div class="sidebar">
        <h2>🛡️ Admin Panel</h2>
        <div class="nav-menu">
            <a href="admin-dashboard.jsp" class="nav-btn active">🏠 Admin Home</a>
            <a href="admin-staff.jsp" class="nav-btn">👥 Staff Management</a>
            <a href="admin-logs.jsp" class="nav-btn">📜 System Logs</a>
            <a href="admin-pricing.jsp" class="nav-btn">⚙️ Treatment & Pricing</a>
            <a href="admin-reports.jsp" class="nav-btn">📊 Reports</a>
            <a href="admin-help.jsp" class="nav-btn">❓ Help Section</a>
        </div>
        <a href="auth?action=logout" class="btn-logout-sidebar">Logout Admin</a>
    </div>

    <!-- Main Content Area -->
    <div class="main-content">
        <div class="header-bar">
            <h1>Welcome, System Administrator</h1>
            <div class="admin-badge">Admin: <strong><%= user.getFullName() %></strong></div>
        </div>

        <!-- Top KPI Cards -->
        <div class="kpi-container">
            <div class="kpi-card">
                <h4>Active Staff</h4>
                <div class="value"><%= activeStaffCount %></div>
            </div>
            <div class="kpi-card">
                <h4>Total Appointments</h4>
                <div class="value"><%= totalAppointments %></div>
            </div>
            <div class="kpi-card income-card">
                <h4>Today's Income</h4>
                <div class="value">Rs. <%= String.format("%.2f", todaysIncome) %></div>
            </div>
        </div>

        <!-- Admin Quick Actions -->
        <div class="action-section">
            <h3>Admin Quick Actions</h3>
            <p>Configure clinic settings, manage medical/reception staff, and update treatment fees from here.</p>
            <div class="action-btn-group">
                <a href="admin-staff.jsp" class="btn-action">Add New Staff Member</a>
                <a href="admin-pricing.jsp" class="btn-action btn-yellow">+ Configure Fees</a>
            </div>
        </div>
    </div>

</body>
</html>