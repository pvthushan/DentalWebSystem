<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null || user.getFullName() == null || user.getFullName().trim().isEmpty()) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || userRole.trim().isEmpty()) {
        userRole = "GUEST";
    }
    String safeUserRole = userRole.replaceAll("[<>]", "");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sunrise Dental - Staff User Guide & Help</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f4f7f6; padding: 30px; color: #333; }
        .container { max-width: 900px; margin: 0 auto; }
        .back-link { display: inline-block; margin-bottom: 20px; color: #0076be; text-decoration: none; font-weight: bold; }

        .header-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 25px; border-left: 5px solid #0076be; }
        .header-card h2 { color: #0076be; font-size: 24px; margin-bottom: 5px; }
        .header-card p { color: #666; font-size: 14px; }


        .section-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 25px; }
        .section-title { font-size: 18px; color: #333; border-bottom: 2px solid #eef2f5; padding-bottom: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .role-badge { background: #ffc107; color: #333; font-size: 11px; padding: 3px 8px; border-radius: 10px; font-weight: bold; text-transform: uppercase; }


        .step-list { list-style: none; counter-reset: step-counter; }
        .step-list li { position: relative; padding-left: 45px; margin-bottom: 20px; font-size: 14px; line-height: 1.6; }
        .step-list li::before {
            counter-increment: step-counter;
            content: counter(step-counter);
            position: absolute;
            left: 0;
            top: 0;
            width: 30px;
            height: 30px;
            background-color: #0076be;
            color: white;
            border-radius: 50%;
            text-align: center;
            line-height: 30px;
            font-weight: bold;
            font-size: 13px;
        }
        .step-title { font-weight: bold; color: #0076be; display: block; margin-bottom: 3px; }


        .faq-item { border: 1px solid #e2e8f0; border-radius: 6px; margin-bottom: 10px; overflow: hidden; }
        .faq-question { background: #f8fafc; padding: 15px; font-weight: bold; font-size: 14px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; }
        .faq-question:hover { background: #edf2f7; }
        .faq-answer { padding: 15px; font-size: 13px; color: #555; display: none; background: white; border-top: 1px solid #e2e8f0; line-height: 1.5; }

        .note-box { background: #eef9ff; border-left: 4px solid #0076be; padding: 15px; font-size: 13px; color: #005a93; border-radius: 4px; margin-top: 15px; }
    </style>
</head>
<body>

<div class="container">
    <a href="dashboard.jsp" class="back-link">&larr; Back to Dashboard</a>

    <div class="header-card">
        <h2>Staff Onboarding & System User Guide</h2>
        <p>Welcome to Sunrise Dental Management System. Step-by-step instructions for operational tasks.</p>
    </div>


    <% if ("RECEPTIONIST".equalsIgnoreCase(safeUserRole) || "SYSTEM_ADMIN".equalsIgnoreCase(safeUserRole)) { %>
    <div class="section-card">
        <div class="section-title">
            Receptionist Workflow Guide <span class="role-badge">Receptionist</span>
        </div>
        <ol class="step-list">
            <li>
                <span class="step-title">Patient & Appointment Registration</span>
                Navigate to <strong>"Register Appointment"</strong> from the dashboard. Enter the patient's full name, contact number, select the assigned dentist, and choose the treatment type. Submit the form to auto-generate a unique Appointment Number (e.g., APT-1700000000).
            </li>
            <li>
                <span class="step-title">Search & Verify Records</span>
                To verify an appointment or view details, open <strong>"Search & Display"</strong>. Type the Appointment Number into the search bar. Real-time patient and schedule information will be fetched via AJAX.
            </li>
            <li>
                <span class="step-title">Billing & Official Receipt Generation</span>
                Once treatment is completed, go to <strong>"Billing & Receipts"</strong>. Input the Appointment ID along with the doctor's consultation fee. The system triggers a MySQL Stored Procedure to calculate total costs and produces a printable payment receipt.
            </li>
        </ol>
    </div>
    <% } %>


    <% if ("DENTIST".equalsIgnoreCase(safeUserRole) || "SYSTEM_ADMIN".equalsIgnoreCase(safeUserRole)) { %>
    <div class="section-card">
        <div class="section-title">
            Dentist Operational Guide <span class="role-badge">Dentist</span>
        </div>
        <ol class="step-list">
            <li>
                <span class="step-title">Daily Appointment Schedule</span>
                Access <strong>"Patient Treatments"</strong> on your dashboard to view all appointments assigned to you for the current day.
            </li>
            <li>
                <span class="step-title">Patient Treatment Review</span>
                Search using the patient's Appointment Number to review medical records, assigned treatment types, and specific patient notes prior to starting the clinical procedure.
            </li>
        </ol>
    </div>
    <% } %>


    <% if ("CLINIC_MANAGER".equalsIgnoreCase(safeUserRole) || "SYSTEM_ADMIN".equalsIgnoreCase(safeUserRole)) { %>
    <div class="section-card">
        <div class="section-title">
            Management & Reporting Guide <span class="role-badge">Manager / Admin</span>
        </div>
        <ol class="step-list">
            <li>
                <span class="step-title">Business Intelligence & Analytics</span>
                Open <strong>"Analytics & Reports"</strong> to monitor revenue summaries, identify popular dental treatments, and analyze peak appointment times.
            </li>
            <li>
                <span class="step-title">System Auditing (Admin Only)</span>
                System Administrators can access <strong>"System Audit Logs"</strong> to monitor user access logs, session activities, and system security events.
            </li>
        </ol>
    </div>
    <% } %>


    <div class="section-card">
        <div class="section-title">Frequently Asked Questions (FAQ)</div>

        <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
                Q1: How do I handle an urgent appointment cancellation? <span>+</span>
            </div>
            <div class="faq-answer">
                Search for the appointment in "Search & Display" using the Appointment Number. Update the status through the system dashboard or inform the System Administrator to modify database records.
            </div>
        </div>

        <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
                Q2: What happens if I forget my login session? <span>+</span>
            </div>
            <div class="faq-answer">
                The system enforces session security. Inactive sessions expire automatically after 30 minutes, redirecting you safely to the login page.
            </div>
        </div>

        <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
                Q3: Can I reprint a payment receipt? <span>+</span>
            </div>
            <div class="faq-answer">
                Yes. Re-enter the Appointment ID under "Billing & Receipts" to trigger the calculated view and click "Print Official Receipt".
            </div>
        </div>

        <div class="note-box">
            <strong>Need Further Assistance?</strong> Contact the IT Helpdesk at <code>support@sunrisedental.com</code> or reach out directly to the System Administrator.
        </div>
    </div>
</div>

<script>

    function toggleFaq(element) {
        if (!element) return;
        const answer = element.nextElementSibling;
        const icon = element.querySelector('span');
        if (!answer || !icon) return;

        if (answer.style.display === "block") {
            answer.style.display = "none";
            icon.innerText = "+";
        } else {
            answer.style.display = "block";
            icon.innerText = "-";
        }
    }
</script>

</body>
</html>