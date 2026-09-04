<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.sunrisedental.config.DBConnection" %>
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
    <title>Sunrise Dental - System Activity Logs</title>
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
        .header-bar { margin-bottom: 20px; }
        .header-bar h1 { font-size: 24px; color: #0f172a; margin-bottom: 5px; }
        .header-bar p { font-size: 14px; color: #64748b; }

        .table-card { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); overflow: hidden; margin-top: 20px; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { background-color: #334155; color: white; padding: 14px 18px; font-size: 14px; font-weight: 600; }
        td { padding: 12px 18px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #334155; }
        tr:hover { background-color: #f8fafc; }

        .user-badge { background-color: #e2e8f0; color: #0f172a; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; font-family: monospace; }
        .timestamp { color: #64748b; font-size: 13px; font-family: monospace; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>🛡️ Admin Panel</h2>
    <div class="nav-menu">
        <a href="admin-dashboard" class="nav-btn">🏠 Admin Home</a>
        <a href="admin-staff.jsp" class="nav-btn">👥 Staff Management</a>
        <a href="admin-logs.jsp" class="nav-btn active">📜 System Logs</a>
        <a href="admin-pricing" class="nav-btn">⚙️ Treatment & Pricing</a>
        <a href="admin-reports" class="nav-btn">📊 Reports</a>
        <a href="admin-help.jsp" class="nav-btn">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout Admin</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <h1>📜 System Activity Logs</h1>
        <p>Tracking all important actions performed within the Sunrise Dental Management System.</p>
    </div>

    <div class="table-card">
        <table>
            <thead>
            <tr>
                <th>Time Stamp</th>
                <th>Performed By</th>
                <th>Action Description</th>
            </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection();
                     Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT timestamp, performed_by, action_description FROM system_logs ORDER BY log_id DESC")) {

                    boolean hasLogs = false;
                    while (rs.next()) {
                        hasLogs = true;
                        String timestamp = rs.getString("timestamp");
                        String performedBy = rs.getString("performed_by");
                        String description = rs.getString("action_description");
            %>
            <tr>
                <td class="timestamp"><%= timestamp %></td>
                <td><span class="user-badge"><%= performedBy %></span></td>
                <td><%= description %></td>
            </tr>
            <%
                }
                if (!hasLogs) {
            %>
            <tr>
                <td colspan="3" style="text-align: center; color: #64748b; padding: 20px;">No system activity logs found.</td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>