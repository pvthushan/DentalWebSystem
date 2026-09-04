<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%@ page import="com.sunrisedental.dto.Doctor" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"RECEPTIONIST".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    String safeUsername = (user.getUsername() != null) ? user.getUsername().replaceAll("[<>]", "") : "Receptionist";
    String safeUserRole = (userRole != null) ? userRole.replaceAll("[<>]", "") : "RECEPTIONIST";
    List<Doctor> doctorList = (List<Doctor>) request.getAttribute("doctorList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Doctor Availability</title>
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

        .card-table { background: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); overflow: hidden; border: 1px solid #e2e8f0; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { background-color: #0f172a; color: white; padding: 14px 18px; font-size: 14px; font-weight: 600; }
        td { padding: 14px 18px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #334155; }
        tr:hover { background-color: #f8fafc; }

        .badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-available { background-color: #dcfce7; color: #166534; }
        .badge-busy { background-color: #fee2e2; color: #991b1b; }

        .btn-book { display: inline-block; padding: 6px 12px; background-color: #0ea5e9; color: white; text-decoration: none; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .btn-book:hover { background-color: #0284c7; }
    </style>
    <script>
        function validateBooking(docId) {
            if (!docId || isNaN(docId) || docId <= 0) {
                alert("Invalid doctor selection. Please choose a valid doctor.");
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
        <a href="doctor-availability" class="nav-btn active">👨‍⚕️ Doctor Availability</a>
        <a href="receptionist-new-appointment.jsp" class="nav-btn">➕ New Appointment</a>
        <a href="receptionist-search-appointment.jsp" class="nav-btn">🔍 Search Appointments</a>
        <a href="receptionist-calculate-bill.jsp" class="nav-btn">💳 Calculate Bill</a>
        <a href="receptionist-help.jsp" class="nav-btn">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <div>
            <h1>👨‍⚕️ Doctor Availability & Schedule</h1>
            <p>Check active doctor availability and consultation fees before booking appointments.</p>
        </div>
        <div class="user-badge">User: <strong><%= safeUsername %></strong> (<%= safeUserRole %>)</div>
    </div>

    <div class="card-table">
        <table>
            <thead>
            <tr>
                <th>Doctor ID</th>
                <th>Doctor Name</th>
                <th>Specialization</th>
                <th>Consultation Fee</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <%
                if (doctorList != null && !doctorList.isEmpty()) {
                    for (Doctor doc : doctorList) {
                        String status = (doc.getStatus() != null) ? doc.getStatus().toUpperCase() : "AVAILABLE";
                        boolean isAvailable = "AVAILABLE".equals(status);
            %>
            <tr>
                <td><strong>DOC-0<%= doc.getDoctorId() %></strong></td>
                <td><%= doc.getDoctorName() %></td>
                <td><%= doc.getSpecialization() %></td>
                <td>Rs. <%= String.format("%,.2f", doc.getConsultationFee()) %></td>
                <td>
                    <% if (isAvailable) { %>
                    <span class="badge badge-available">Available</span>
                    <% } else { %>
                    <span class="badge badge-busy">On Leave</span>
                    <% } %>
                </td>
                <td>
                    <% if (isAvailable) { %>
                    <a href="receptionist-new-appointment.jsp?docId=<%= doc.getDoctorId() %>" class="btn-book" onclick="return validateBooking(<%= doc.getDoctorId() %>)">Book Now</a>
                    <% } else { %>
                    <button class="btn-book" style="background:#cbd5e1; cursor:not-allowed;" disabled>Unavailable</button>
                    <% } %>
                </td>
            </tr>
            <%
                }
            } else {
            %>
            <tr>
                <td colspan="6" style="text-align: center; color: #64748b; padding: 20px;">No registered doctors found in database.</td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>