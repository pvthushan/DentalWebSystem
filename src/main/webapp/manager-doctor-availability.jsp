<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
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
    <title>Sunrise Dental - Doctor Availability</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }

        /* Left Sidebar Layout */
        .sidebar { width: 250px; background-color: #2c3e50; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #1abc9c; margin-bottom: 30px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #ecf0f1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #1abc9c; color: white; }
        .btn-logout-sidebar { background-color: #e74c3c; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }

        /* Main Content Layout */
        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .header-bar h1 { font-size: 24px; color: #2c3e50; display: flex; align-items: center; gap: 10px; }
        .user-badge { font-size: 13px; color: #7f8c8d; }

        /* Filter Search Bar */
        .search-box-container { background: white; padding: 15px 20px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); margin-bottom: 20px; display: flex; align-items: center; gap: 15px; border: 1px solid #e2e8f0; }
        .search-label { font-size: 14px; font-weight: bold; color: #34495e; display: flex; align-items: center; gap: 5px; }
        .search-input { flex: 1; padding: 10px 15px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; }
        .search-input:focus { border-color: #1abc9c; }

        /* Table Styling */
        table { width: 100%; border-collapse: collapse; text-align: left; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        th { background-color: #1abc9c; color: white; padding: 14px 18px; font-size: 14px; font-weight: 600; }
        td { padding: 14px 18px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #2c3e50; vertical-align: middle; }
        tr:hover { background-color: #f8fafc; }

        /* Status Badges */
        .status-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; border: 1px solid transparent; }
        .status-available { color: #27ae60; border-color: #27ae60; background-color: #e8f8f5; }
        .status-unavailable { color: #e74c3c; border-color: #e74c3c; background-color: #fadbd8; }
    </style>
</head>
<body>

    <!-- Left Sidebar Menu -->
    <div class="sidebar">
        <h2>Sunrise Dental</h2>
        <div class="nav-menu">
            <a href="manager-dashboard.jsp" class="nav-btn">🏠 Dashboard</a>
            <a href="manager-doctor-availability.jsp" class="nav-btn active">👨‍⚕️ Doctor Availability</a>
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
            <h1>👨‍⚕️ Doctor Availability Status</h1>
            <div class="user-badge">User: <strong><%= user.getUsername() %></strong></div>
        </div>

        <!-- Filter Search Bar Section -->
        <div class="search-box-container">
            <span class="search-label">🔍 Filter Doctors:</span>
            <input type="text" id="doctorSearch" class="search-input" onkeyup="filterDoctors()" placeholder="Search by Doctor Name or Specialization (Dental Surgeon, Orthodontist...)...">
        </div>

        <!-- Doctors Table -->
        <table id="doctorsTable">
            <thead>
                <tr>
                    <th>Doctor ID</th>
                    <th>Doctor Name</th>
                    <th>Specialization</th>
                    <th>Consultation Fee</th>
                    <th>Current Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>DOC-01</strong></td>
                    <td>Dr. Anura Perera</td>
                    <td>Dental Surgeon</td>
                    <td>Rs. 2,500.00</td>
                    <td><span class="status-badge status-available">AVAILABLE</span></td>
                </tr>
                <tr>
                    <td><strong>DOC-02</strong></td>
                    <td>Dr. K. N. Gunawardena</td>
                    <td>Orthodontist</td>
                    <td>Rs. 3,500.00</td>
                    <td><span class="status-badge status-available">AVAILABLE</span></td>
                </tr>
                <tr>
                    <td><strong>DOC-03</strong></td>
                    <td>Dr. S. M. Pathirana</td>
                    <td>Pediatric Dentist</td>
                    <td>Rs. 3,000.00</td>
                    <td><span class="status-badge status-unavailable">UNAVAILABLE</span></td>
                </tr>
                <tr>
                    <td><strong>DOC-04</strong></td>
                    <td>Dr. N. L. Wickramasinghe</td>
                    <td>Periodontist</td>
                    <td>Rs. 4,000.00</td>
                    <td><span class="status-badge status-available">AVAILABLE</span></td>
                </tr>
            </tbody>
        </table>
    </div>

    <script>
        // Real-time JavaScript Filter Function
        function filterDoctors() {
            let input = document.getElementById("doctorSearch").value.toUpperCase();
            let table = document.getElementById("doctorsTable");
            let tr = table.getElementsByTagName("tr");

            for (let i = 1; i < tr.length; i++) {
                let nameTd = tr[i].getElementsByTagName("td")[1];
                let specTd = tr[i].getElementsByTagName("td")[2];
                if (nameTd || specTd) {
                    let nameText = nameTd.textContent || nameTd.innerText;
                    let specText = specTd.textContent || specTd.innerText;
                    if (nameText.toUpperCase().indexOf(input) > -1 || specText.toUpperCase().indexOf(input) > -1) {
                        tr[i].style.display = "";
                    } else {
                        tr[i].style.display = "none";
                    }
                }
            }
        }
    </script>

</body>
</html>