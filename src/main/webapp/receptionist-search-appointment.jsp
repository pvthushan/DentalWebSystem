<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.sunrisedental.config.DBConnection" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"RECEPTIONIST".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    String query = request.getParameter("query");
    String date = request.getParameter("date");

    String safeUsername = (user.getUsername() != null) ? user.getUsername().replaceAll("[<>]", "") : "Receptionist";
    String safeQuery = (query != null) ? query.trim().replaceAll("[<>]", "") : "";
    String safeDate = (date != null) ? date.trim().replaceAll("[<>]", "") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Search Appointments</title>
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
        .header-bar { margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; }
        .header-bar h1 { font-size: 26px; color: #0f172a; }
        .header-bar p { font-size: 14px; color: #64748b; margin-top: 5px; }
        .user-badge { font-size: 13px; color: #64748b; }

        .card-box { background: white; padding: 20px 25px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; margin-bottom: 25px; }
        .search-grid { display: grid; grid-template-columns: 1fr 1fr auto; gap: 15px; align-items: end; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 6px; }
        .form-control { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; }
        .form-control:focus { border-color: #0ea5e9; }
        .btn-search { background-color: #0ea5e9; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; height: 42px; }
        .btn-search:hover { background-color: #0284c7; }

        .card-table { background: white; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); overflow: hidden; border: 1px solid #e2e8f0; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { background-color: #0f172a; color: white; padding: 14px 18px; font-size: 14px; font-weight: 600; }
        td { padding: 14px 18px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #334155; }
        tr:hover { background-color: #f8fafc; }

        .badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-confirmed { background-color: #dcfce7; color: #166534; }
    </style>
    <script>
        function validateSearchForm() {
            let queryInput = document.getElementById("queryInput");
            let query = queryInput.value.trim();

            if (query.length > 0 && query.length < 2) {
                alert("Search query must be at least 2 characters long if provided.");
                queryInput.focus();
                return false;
            }

            if (query.length > 50) {
                alert("Search query is too long. Maximum 50 characters allowed.");
                queryInput.focus();
                return false;
            }

            return true;
        }
    </script>
</head>
<body>

<div class="sidebar">
    <h2>Sunrise Dental</h2>
    <div class="nav-menu">
        <a href="receptionist-dashboard.jsp" class="nav-btn">🏠 Dashboard</a>
        <a href="doctor-availability" class="nav-btn">👨‍⚕️ Doctor Availability</a>
        <a href="receptionist-new-appointment.jsp" class="nav-btn">➕ New Appointment</a>
        <a href="receptionist-search-appointment.jsp" class="nav-btn active">🔍 Search Appointments</a>
        <a href="receptionist-calculate-bill.jsp" class="nav-btn">💳 Calculate Bill</a>
        <a href="receptionist-help.jsp" class="nav-btn">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <div>
            <h1>🔍 Search Patient Appointments</h1>
            <p>View scheduled appointments and check booking status (Read-Only View).</p>
        </div>
        <div class="user-badge">User: <strong><%= safeUsername %></strong> (<%= userRole %>)</div>
    </div>

    <div class="card-box">
        <form action="receptionist-search-appointment.jsp" method="GET" class="search-grid" onsubmit="return validateSearchForm()">
            <div class="form-group">
                <label>Patient Name or Phone Number</label>
                <input type="text" id="queryInput" name="query" class="form-control" value="<%= safeQuery %>" placeholder="Search by name or phone..." maxlength="50">
            </div>
            <div class="form-group">
                <label>Appointment Date</label>
                <input type="date" name="date" class="form-control" value="<%= safeDate %>">
            </div>
            <button type="submit" class="btn-search">Search</button>
        </form>
    </div>

    <div class="card-table">
        <table>
            <thead>
            <tr>
                <th>Appt Number</th>
                <th>Patient Name</th>
                <th>Contact No</th>
                <th>Doctor ID</th>
                <th>Date & Time</th>
                <th>Status</th>
            </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT a.appointment_number, p.full_name, p.contact_number, a.doctor_id, a.appointment_date, a.appointment_time " +
                            "FROM appointments a JOIN patients p ON a.patient_id = p.patient_id WHERE 1=1";

                    if (!safeQuery.isEmpty()) {
                        sql += " AND (p.full_name LIKE ? OR p.contact_number LIKE ?)";
                    }
                    if (!safeDate.isEmpty()) {
                        sql += " AND a.appointment_date = ?";
                    }
                    sql += " ORDER BY a.appointment_date DESC";

                    PreparedStatement stmt = conn.prepareStatement(sql);
                    int paramIndex = 1;
                    if (!safeQuery.isEmpty()) {
                        stmt.setString(paramIndex++, "%" + safeQuery + "%");
                        stmt.setString(paramIndex++, "%" + safeQuery + "%");
                    }
                    if (!safeDate.isEmpty()) {
                        stmt.setString(paramIndex++, safeDate);
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
                <td><%= rs.getString("appointment_date") %> (<%= rs.getString("appointment_time") %>)</td>
                <td><span class="badge badge-confirmed">Confirmed</span></td>
            </tr>
            <%
                }
                if (!hasData) {
            %>
            <tr>
                <td colspan="6" style="text-align: center; color: #64748b; padding: 25px;">No appointments found in the database.</td>
            </tr>
            <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            %>
            <tr>
                <td colspan="6" style="text-align: center; color: #e74c3c; padding: 25px;">Error loading data from database.</td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>