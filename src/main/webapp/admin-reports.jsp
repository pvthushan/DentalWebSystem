<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Financial Income Report</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }

        /* Left Sidebar Layout */
        .sidebar { width: 250px; background-color: #1e293b; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #f59e0b; margin-bottom: 30px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #cbd5e1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #f59e0b; color: #0f172a; }
        .btn-logout-sidebar { background-color: #ef4444; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }

        /* Main Content Layout */
        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .header-bar h1 { font-size: 24px; color: #0f172a; }
        .btn-group { display: flex; gap: 10px; }
        .btn-export { padding: 9px 16px; border-radius: 6px; border: none; font-weight: bold; cursor: pointer; color: white; text-decoration: none; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; }
        .btn-excel { background-color: #10b981; }
        .btn-pdf { background-color: #ef4444; }

        /* KPI Cards */
        .kpi-container { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 30px; margin-top: 20px; }
        .kpi-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); border-top: 4px solid #10b981; }
        .kpi-card h4 { color: #64748b; font-size: 13px; text-transform: uppercase; margin-bottom: 8px; }
        .kpi-card .value { font-size: 26px; font-weight: bold; color: #0f172a; }

        /* Table Styling */
        table { width: 100%; border-collapse: collapse; text-align: left; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        th { background-color: #334155; color: white; padding: 12px 16px; font-size: 14px; }
        td { padding: 12px 16px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #334155; }
        .total-row { background-color: #f8fafc; font-weight: bold; }
    </style>
</head>
<body>

    <!-- Left Sidebar Menu -->
    <div class="sidebar">
        <h2>🛡️ Admin Panel</h2>
        <div class="nav-menu">
            <a href="admin-dashboard.jsp" class="nav-btn">🏠 Admin Home</a>
            <a href="admin-staff.jsp" class="nav-btn">👥 Staff Management</a>
            <a href="admin-logs.jsp" class="nav-btn">📜 System Logs</a>
            <a href="admin-pricing.jsp" class="nav-btn">⚙️ Treatment & Pricing</a>
            <a href="admin-reports.jsp" class="nav-btn active">📊 Reports</a>
            <a href="admin-help.jsp" class="nav-btn">❓ Help Section</a>
        </div>
        <a href="auth?action=logout" class="btn-logout-sidebar">Logout Admin</a>
    </div>

    <!-- Main Content Area -->
    <div class="main-content">
        <div class="header-bar">
            <div>
                <h1>💰 Financial Income Report</h1>
                <p style="color:#64748b; font-size:14px; margin-top:4px;">Detailed breakdown of dental clinic revenue based on completed appointments & treatments.</p>
            </div>
            <div class="btn-group">
                <a href="report-export?type=excel" class="btn-export btn-excel">📊 Export Excel</a>
                <a href="report-export?type=pdf" class="btn-export btn-pdf">📄 Download PDF</a>
            </div>
        </div>

        <!-- KPI Summary Cards -->
        <div class="kpi-container">
            <div class="kpi-card">
                <h4>Total Completed Appointments</h4>
                <div class="value">12</div>
            </div>
            <div class="kpi-card">
                <h4>Gross Revenue</h4>
                <div class="value">Rs. 85,500.00</div>
            </div>
        </div>

        <!-- Details Data Table -->
        <table>
            <thead>
                <tr>
                    <th>Patient Name</th>
                    <th>Treatment Type</th>
                    <th>Doctor Name</th>
                    <th>Date</th>
                    <th>Consultation Fee</th>
                    <th>Treatment Fee</th>
                    <th>Sub-Total</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Kavindu Silva</td>
                    <td>Composite Filling</td>
                    <td>Dr. Anura Perera</td>
                    <td>2026-09-03</td>
                    <td>Rs. 2,500.00</td>
                    <td>Rs. 4,500.00</td>
                    <td><strong>Rs. 7,000.00</strong></td>
                </tr>
                <tr>
                    <td>Nipuni Perera</td>
                    <td>Root Canal Treatment</td>
                    <td>Dr. K. N. Gunawardena</td>
                    <td>2026-09-03</td>
                    <td>Rs. 3,500.00</td>
                    <td>Rs. 18,000.00</td>
                    <td><strong>Rs. 21,500.00</strong></td>
                </tr>
                <tr class="total-row">
                    <td colspan="6" style="text-align: right;">Grand Total Revenue:</td>
                    <td style="color: #d97706; font-size: 16px;">Rs. 28,500.00</td>
                </tr>
            </tbody>
        </table>
    </div>

</body>
</html>