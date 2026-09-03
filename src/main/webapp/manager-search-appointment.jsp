<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.sunrisedental.config.DBConnection" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"CLINIC_MANAGER".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    String searchQuery = request.getParameter("searchQuery");
    String filterDate = request.getParameter("filterDate");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Search Appointments</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }
        .sidebar { width: 250px; background-color: #2c3e50; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #1abc9c; margin-bottom: 30px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #ecf0f1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; }
        .nav-btn:hover, .nav-btn.active { background-color: #1abc9c; color: white; }
        .btn-logout-sidebar { background-color: #e74c3c; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }
        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .header-bar h1 { font-size: 24px; color: #2c3e50; }
        .user-badge { font-size: 13px; color: #7f8c8d; }
        .search-box-container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); margin-bottom: 20px; border: 1px solid #e2e8f0; }
        .search-grid { display: grid; grid-template-columns: 2fr 1fr auto; gap: 15px; align-items: center; }
        .search-input { padding: 10px 15px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; width: 100%; }
        .btn-search { background-color: #1abc9c; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; }
        table { width: 100%; border-collapse: collapse; text-align: left; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        th { background-color: #2c3e50; color: white; padding: 14px 16px; font-size: 14px; font-weight: 600; }
        td { padding: 14px 16px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #34495e; vertical-align: middle; }
        tr:hover { background-color: #f8fafc; }
        .btn-cancel { background-color: #e74c3c; color: white; border: none; padding: 7px 14px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 13px; }
        .btn-cancel:hover { background-color: #c0392b; }
        .status-badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; background-color: #d1fae5; color: #065f46; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Sunrise Dental</h2>
    <div class="nav-menu">
        <a href="manager-dashboard.jsp" class="nav-btn">🏠 Dashboard</a>
        <a href="manager-new-appointment.jsp" class="nav-btn">➕ New Appointment</a>
        <a href="manager-search-appointment.jsp" class="nav-btn active">🔍 Search Appointments</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <h1>🔍 Search Appointments</h1>
        <div class="user-badge">User: <strong><%= user.getUsername() %></strong></div>
    </div>

    <div class="search-box-container">
        <form action="manager-search-appointment.jsp" method="GET" class="search-grid">
            <input type="text" name="searchQuery" class="search-input" value="<%= searchQuery != null ? searchQuery : "" %>" placeholder="Search by Patient Name or Contact No...">
            <input type="date" name="filterDate" class="search-input" value="<%= filterDate != null ? filterDate : "" %>">
            <button type="submit" class="btn-search">Search</button>
        </form>
    </div>

    <table>
        <thead>
        <tr>
            <th>Appt ID</th>
            <th>Patient Name</th>
            <th>Contact</th>
            <th>Doctor ID</th>
            <th>Date & Time</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
        </thead>
        <tbody>
        <%
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT a.appointment_number, p.full_name, p.contact_number, a.doctor_id, a.appointment_date, a.appointment_time " +
                        "FROM appointments a JOIN patients p ON a.patient_id = p.patient_id WHERE 1=1";

                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                    sql += " AND (p.full_name LIKE ? OR p.contact_number LIKE ?)";
                }
                if (filterDate != null && !filterDate.trim().isEmpty()) {
                    sql += " AND a.appointment_date = ?";
                }

                PreparedStatement stmt = conn.prepareStatement(sql);
                int paramIndex = 1;
                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                    stmt.setString(paramIndex++, "%" + searchQuery + "%");
                    stmt.setString(paramIndex++, "%" + searchQuery + "%");
                }
                if (filterDate != null && !filterDate.trim().isEmpty()) {
                    stmt.setString(paramIndex++, filterDate);
                }

                ResultSet rs = stmt.executeQuery();
                boolean hasData = false;
                while (rs.next()) {
                    hasData = true;
        %>
        <tr>
            <td><strong><%= rs.getString("appointment_number") %></strong></td>
            <td><%= rs.getString("full_name") %></td>
            <td><%= rs.getString("contact_number") %></td>
            <td><%= rs.getString("doctor_id") %></td>
            <td><%= rs.getString("appointment_date") %> <%= rs.getString("appointment_time") %></td>
            <td><span class="status-badge">CONFIRMED</span></td>
            <td>
                <form action="appointment-servlet" method="POST" onsubmit="return confirm('Are you sure you want to delete this appointment?');" style="margin:0;">
                    <input type="hidden" name="action" value="cancelAppointment">
                    <input type="hidden" name="appointmentId" value="<%= rs.getString("appointment_number") %>">
                    <button type="submit" class="btn-cancel">Cancel</button>
                </form>
            </td>
        </tr>
        <%
            }
            if (!hasData) {
        %>
        <tr>
            <td colspan="7" style="text-align: center; color: #7f8c8d; padding: 20px;">No appointments found.</td>
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

</body>
</html>