<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }


    String adminName = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
            ? user.getFullName()
            : "System Administrator";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Admin Help & Documentation</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }

        .sidebar { width: 250px; background-color: #1e293b; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #f59e0b; margin-bottom: 30px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #cbd5e1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #f59e0b; color: #0f172a; }
        .btn-logout-sidebar { background-color: #ef4444; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }

        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 15px; }
        .header-bar h1 { font-size: 24px; color: #0f172a; }
        .admin-badge { font-size: 13px; color: #64748b; }

        .help-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .help-card h3 { color: #0f172a; font-size: 18px; margin-bottom: 10px; border-bottom: 2px solid #f1f5f9; padding-bottom: 8px; }
        .help-card ul { margin-left: 20px; color: #334155; font-size: 14px; line-height: 1.8; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>🛡️ Admin Panel</h2>
    <div class="nav-menu">
        <a href="admin-dashboard" class="nav-btn active">🏠 Admin Home</a>
        <a href="admin-staff.jsp" class="nav-btn">👥 Staff Management</a>
        <a href="admin-logs.jsp" class="nav-btn">📜 System Logs</a>
        <a href="admin-pricing" class="nav-btn">⚙️ Treatment & Pricing</a>
        <a href="admin-reports" class="nav-btn">📊 Reports</a>
        <a href="admin-help.jsp" class="nav-btn">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout Admin</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <h1>❓ System Administrator Guidance & Help</h1>
        <div class="admin-badge">Logged in as: <strong><%= adminName %></strong></div>
    </div>

    <div class="help-card">
        <h3>👥 Staff & Doctor Management Guide</h3>
        <ul>
            <li><strong>Add New User:</strong> Fill in Full Name, Username, Password, and select the appropriate Role (Manager or Receptionist).</li>
            <li><strong>Manage Doctors:</strong> Switch to the "Manage Doctors" tab to add doctors along with their specializations and consultation fees.</li>
            <li><strong>Edit / Delete:</strong> Click "Edit" to load user details into the form or "Delete" to permanently remove access.</li>
        </ul>
    </div>

    <div class="help-card">
        <h3>⚙️ Treatment & Pricing Management</h3>
        <ul>
            <li><strong>Consultation Fees:</strong> Update individual doctor fees dynamically. Changes reflect immediately across new appointments.</li>
            <li><strong>Treatment Costs:</strong> Update base fees for procedures such as Root Canal, Extractions, and Fillings.</li>
        </ul>
    </div>

    <div class="help-card">
        <h3>📊 Financial Reports & System Audit Logs</h3>
        <ul>
            <li><strong>Audit Logs:</strong> Monitor login history, user creation, and fee updates with precise timestamps.</li>
            <li><strong>Exporting Data:</strong> Use the "Export Excel" or "Download PDF" buttons on the Reports page to generate financial summaries.</li>
        </ul>
    </div>
</div>

</body>
</html>