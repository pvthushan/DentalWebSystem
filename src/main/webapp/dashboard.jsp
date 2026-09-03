<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    // Session Validation Check
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }
    String userRole = (String) session.getAttribute("userRole");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sunrise Dental - Main Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f4f7f6; display: flex; flex-direction: column; min-height: 100vh; }

        /* Navigation Header */
        .navbar { background-color: #0076be; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .navbar h1 { font-size: 20px; font-weight: 600; }
        .user-info { display: flex; align-items: center; gap: 15px; font-size: 14px; }
        .badge { background-color: #ffc107; color: #333; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 11px; text-transform: uppercase; }
        .btn-logout { background-color: #dc3545; color: white; border: none; padding: 8px 15px; border-radius: 4px; text-decoration: none; font-size: 13px; font-weight: bold; transition: 0.3s; }
        .btn-logout:hover { background-color: #bd2130; }

        /* Container Layout */
        .container { padding: 40px 30px; flex: 1; max-width: 1200px; margin: 0 auto; width: 100%; }
        .welcome-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 30px; border-left: 5px solid #0076be; }
        .welcome-card h2 { color: #333; font-size: 22px; margin-bottom: 5px; }
        .welcome-card p { color: #666; font-size: 14px; }

        /* Dashboard Grid Cards */
        .grid-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); transition: transform 0.2s, box-shadow 0.2s; text-decoration: none; color: inherit; display: flex; flex-direction: column; justify-content: space-between; border-top: 4px solid #28a745; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .card.patient-card { border-top-color: #007bff; }
        .card.admin-card { border-top-color: #6f42c1; }
        .card.billing-card { border-top-color: #fd7e14; }
        .card.report-card { border-top-color: #17a2b8; }
        .card.help-card { border-top-color: #6c757d; }

        .card h3 { font-size: 18px; color: #333; margin-bottom: 10px; }
        .card p { font-size: 13px; color: #666; line-height: 1.4; margin-bottom: 15px; }
        .card .action-link { font-size: 13px; font-weight: bold; color: #0076be; align-self: flex-start; }

        /* Footer */
        .footer { text-align: center; padding: 15px; background: #eef2f5; color: #777; font-size: 12px; margin-top: auto; }
    </style>
</head>
<body>

    <!-- Top Navigation Bar -->
    <div class="navbar">
        <h1>Sunrise Dental Management System</h1>
        <div class="user-info">
            <span>Welcome, <strong><%= user.getFullName() %></strong></span>
            <span class="badge"><%= userRole %></span>
            <a href="auth?action=logout" class="btn-logout">Logout</a>
        </div>
    </div>

    <!-- Main Content Area -->
    <div class="container">
        <div class="welcome-card">
            <h2>System Control Panel</h2>
            <p>Access authorized clinic management modules based on your designated role permissions.</p>
        </div>

        <div class="grid-container">

            <%-- ALL ROLES CAN SEE HELP SECTION --%>
            <a href="help.jsp" class="card help-card">
                <div>
                    <h3>User Guide & Help</h3>
                    <p>Step-by-step documentation and support manual for clinic staff.</p>
                </div>
                <span class="action-link">Open Help &rarr;</span>
            </a>

            <%-- RECEPTIONIST, CLINIC MANAGER & ADMIN MODULES --%>
            <% if ("RECEPTIONIST".equalsIgnoreCase(userRole) || "SYSTEM_ADMIN".equalsIgnoreCase(userRole) || "CLINIC_MANAGER".equalsIgnoreCase(userRole)) { %>

                <%-- NEW: PATIENT REGISTRATION CARD --%>
                <a href="patient-reg.jsp" class="card patient-card">
                    <div>
                        <h3>Register Patient</h3>
                        <p>Register new clinic patients and generate unique Patient Codes automatically.</p>
                    </div>
                    <span class="action-link">New Patient &rarr;</span>
                </a>

                <a href="appointment-reg.jsp" class="card">
                    <div>
                        <h3>Register Appointment</h3>
                        <p>Enroll existing patients and schedule treatment time slots with available dentists.</p>
                    </div>
                    <span class="action-link">New Appointment &rarr;</span>
                </a>

                <a href="search-appointment.jsp" class="card">
                    <div>
                        <h3>Search & Display</h3>
                        <p>Lookup treatment records and appointment details using appointment numbers.</p>
                    </div>
                    <span class="action-link">Search Records &rarr;</span>
                </a>

                <a href="billing.jsp" class="card billing-card">
                    <div>
                        <h3>Billing & Receipts</h3>
                        <p>Calculate total treatment costs, apply consultation fees, and issue printed bills.</p>
                    </div>
                    <span class="action-link">Process Billing &rarr;</span>
                </a>
            <% } %>

            <%-- DENTIST MODULES --%>
            <% if ("DENTIST".equalsIgnoreCase(userRole) || "SYSTEM_ADMIN".equalsIgnoreCase(userRole)) { %>
                <a href="search-appointment.jsp" class="card">
                    <div>
                        <h3>Patient Treatments</h3>
                        <p>View assigned patient appointments, medical history, and treatment plans.</p>
                    </div>
                    <span class="action-link">View Schedule &rarr;</span>
                </a>
            <% } %>

            <%-- CLINIC MANAGER & SYSTEM ADMIN MODULES --%>
            <% if ("CLINIC_MANAGER".equalsIgnoreCase(userRole) || "SYSTEM_ADMIN".equalsIgnoreCase(userRole)) { %>
                <a href="reports.jsp" class="card report-card">
                    <div>
                        <h3>Analytics & Reports</h3>
                        <p>Revenue statements, treatment popularity metrics, and decision-making dashboards.</p>
                    </div>
                    <span class="action-link">View Reports &rarr;</span>
                </a>
            <% } %>

            <%-- SYSTEM ADMIN EXCLUSIVE MODULES --%>
            <% if ("SYSTEM_ADMIN".equalsIgnoreCase(userRole)) { %>
                <a href="admin-logs.jsp" class="card admin-card">
                    <div>
                        <h3>System Audit Logs</h3>
                        <p>Monitor system usage, audit trail records, user account security, and active sessions.</p>
                    </div>
                    <span class="action-link">Manage System &rarr;</span>
                </a>
            <% } %>

        </div>
    </div>

    <div class="footer">
        &copy; 2026 Sunrise Dental Clinic - All Rights Reserved. Enterprise Architecture Standard v1.0
    </div>

</body>
</html>