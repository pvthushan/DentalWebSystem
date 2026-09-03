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
    <title>Sunrise Dental - Staff Management</title>
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
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .header-bar h1 { font-size: 24px; color: #0f172a; }
        .tab-menu { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid #cbd5e1; }
        .tab-btn { padding: 10px 20px; font-weight: bold; background: none; border: none; cursor: pointer; font-size: 15px; color: #64748b; }
        .tab-btn.active { color: #0076be; border-bottom: 3px solid #0076be; }
        .card-box { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 25px; }
        .card-box h3 { font-size: 18px; color: #0f172a; margin-bottom: 15px; }
        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; }
        .form-group { display: flex; flex-direction: column; gap: 5px; }
        .form-group label { font-size: 13px; font-weight: bold; color: #334155; }
        .form-group input, .form-group select { padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; }
        .btn-submit { background-color: #10b981; color: white; padding: 10px 20px; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 15px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        th { background-color: #334155; color: white; text-align: left; padding: 12px; font-size: 14px; }
        td { padding: 12px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #334155; }
        .btn-edit { background-color: #3b82f6; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 12px; font-weight: bold; }
        .btn-delete { background-color: #ef4444; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 12px; font-weight: bold; text-decoration: none; display: inline-block; }
        .status-active { color: #10b981; font-weight: bold; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>🛡️ Admin Panel</h2>
    <div class="nav-menu">
        <a href="admin-dashboard.jsp" class="nav-btn">🏠 Admin Home</a>
        <a href="admin-staff.jsp" class="nav-btn active">👥 Staff Management</a>
        <a href="admin-reports.jsp" class="nav-btn">📊 Reports</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout Admin</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <h1>👥 Staff & User Management</h1>
    </div>

    <div class="tab-menu">
        <button class="tab-btn active" onclick="switchTab('staffTab', this)">Manage Staff Users</button>
    </div>

    <!-- STAFF MANAGEMENT TAB -->
    <div id="staffTab" class="tab-content active">
        <div class="card-box">
            <h3>➕ Add / Update System User</h3>
            <form action="admin-user" method="POST">
                <input type="hidden" name="action" value="saveUser">
                <input type="hidden" id="userId" name="userId" value="0">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" id="fullName" name="fullName" placeholder="e.g. Nimal Perera" required>
                    </div>
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" id="username" name="username" placeholder="e.g. nimal_recept" required>
                    </div>
                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" id="password" name="password" placeholder="Leave empty to keep existing">
                    </div>
                    <div class="form-group">
                        <label>Role</label>
                        <select id="userRole" name="userRole" required>
                            <option value="RECEPTIONIST">Receptionist</option>
                            <option value="CLINIC_MANAGER">Clinic Manager</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn-submit">Register / Save Staff</button>
            </form>
        </div>

        <!-- Dynamic Users Table -->
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Full Name</th>
                <th>Username</th>
                <th>Role</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT u.user_id, u.full_name, u.username, r.role_name FROM users u JOIN roles r ON u.role_id = r.role_id";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    ResultSet rs = stmt.executeQuery();

                    while (rs.next()) {
                        int uId = rs.getInt("user_id");
                        String fName = rs.getString("full_name");
                        String uName = rs.getString("username");
                        String rName = rs.getString("role_name");
            %>
            <tr>
                <td><%= uId %></td>
                <td><%= fName %></td>
                <td><%= uName %></td>
                <td><strong><%= rName %></strong></td>
                <td><span class="status-active">✓ Active</span></td>
                <td>
                    <button class="btn-edit" onclick="editStaff(<%= uId %>, '<%= fName %>', '<%= uName %>', '<%= rName %>')">Edit</button>
                    <a href="admin-user?action=delete&id=<%= uId %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this user?');">Delete</a>
                </td>
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

<script>
    function switchTab(tabId, btn) {
        document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.getElementById(tabId).classList.add('active');
        btn.classList.add('active');
    }

    function editStaff(id, name, username, role) {
        document.getElementById('userId').value = id;
        document.getElementById('fullName').value = name;
        document.getElementById('username').value = username;
        document.getElementById('userRole').value = role;
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
</script>
</body>
</html>