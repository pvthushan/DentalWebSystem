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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Financial Income Report</title>
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
        .header-bar { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 25px; }
        .header-title h1 { font-size: 26px; color: #2c3e50; }
        .metrics-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px; }
        .metric-card { background: white; padding: 20px 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); border-top: 4px solid #1abc9c; }
        .metric-card.revenue { border-top-color: #e67e22; }
        .metric-label { font-size: 12px; font-weight: bold; color: #95a5a6; text-transform: uppercase; }
        .metric-value { font-size: 28px; font-weight: bold; color: #2c3e50; margin-top: 8px; }
        table { width: 100%; border-collapse: collapse; text-align: left; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        th { background-color: #34495e; color: white; padding: 14px 18px; font-size: 14px; }
        td { padding: 14px 18px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #2c3e50; }
        .table-footer { font-weight: bold; background-color: #f8fafc; }
        .text-right { text-align: right; }
        .grand-total-value { color: #e67e22; font-size: 16px; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Sunrise Dental</h2>
    <div class="nav-menu">
        <a href="manager-dashboard.jsp" class="nav-btn">🏠 Dashboard</a>
        <a href="manager-calculate-bill.jsp" class="nav-btn">💳 Calculate Bill</a>
        <a href="manager-income-report.jsp" class="nav-btn active">📊 Financial Reports</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <div class="header-title">
            <h1>💰 Financial Income Report</h1>
            <p>Detailed breakdown of clinic revenue based on completed bills.</p>
        </div>
        <button style="background:#e74c3c; color:white; border:none; padding:10px 16px; border-radius:6px; cursor:pointer;" onclick="window.print();">📄 Download PDF</button>
    </div>

    <%
        int totalBills = 0;
        double grandTotalRevenue = 0.0;
    %>

    <!-- Metrics Cards Section -->
    <div class="metrics-grid">
        <div class="metric-card">
            <div class="metric-label">TOTAL BILLED APPOINTMENTS</div>
            <div class="metric-value" id="totalCount">0</div>
        </div>
        <div class="metric-card revenue">
            <div class="metric-label">GROSS REVENUE</div>
            <div class="metric-value" id="grossRevenue">Rs. 0.00</div>
        </div>
    </div>

    <!-- Detailed Breakdown Table -->
    <table>
        <thead>
        <tr>
            <th>Patient Name</th>
            <th>Doctor Name</th>
            <th>Treatment Provided</th>
            <th>Date</th>
            <th>Consultation (Rs.)</th>
            <th>Additional / Medicine (Rs.)</th>
            <th>Sub-Total (Rs.)</th>
        </tr>
        </thead>
        <tbody>
        <%
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT * FROM bills ORDER BY bill_date DESC";
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    totalBills++;
                    double subTotal = rs.getDouble("sub_total");
                    grandTotalRevenue += subTotal;
        %>
        <tr>
            <td><%= rs.getString("patient_name") %></td>
            <td><%= rs.getString("doctor_name") %></td>
            <td><%= rs.getString("treatment_provided") %></td>
            <td><%= rs.getString("bill_date") %></td>
            <td><%= String.format("%.2f", rs.getDouble("consultation_fee") + rs.getDouble("treatment_fee")) %></td>
            <td><%= String.format("%.2f", rs.getDouble("other_fee")) %></td>
            <td><strong>Rs. <%= String.format("%.2f", subTotal) %></strong></td>
        </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        <tr class="table-footer">
            <td colspan="6" class="text-right">Grand Total Revenue:</td>
            <td class="grand-total-value">Rs. <%= String.format("%.2f", grandTotalRevenue) %></td>
        </tr>
        </tbody>
    </table>
</div>

<script>
    // Metrics dynamic update
    document.getElementById("totalCount").innerText = "<%= totalBills %>";
    document.getElementById("grossRevenue").innerText = "Rs. <%= String.format("%.2f", grandTotalRevenue) %>";
</script>

</body>
</html>