<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%@ page import="com.sunrisedental.dto.Appointment" %>
<%@ page import="com.sunrisedental.factory.DAOFactory" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    String status = request.getParameter("status");
    String apptIdStr = request.getParameter("apptId");
    String feeStr = request.getParameter("fee");

    Appointment apptData = null;
    double consultationFee = 1500.00;

    if ("success".equals(status) && apptIdStr != null) {
        int apptId = Integer.parseInt(apptIdStr);
        consultationFee = Double.parseDouble(feeStr);
        // Fetch appointment details using Appointment ID logic or number
        // For demonstration, fetching current state
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Billing & Receipt</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f4f7f6; padding: 30px; }
        .container { max-width: 650px; margin: 0 auto; }
        .back-link { display: inline-block; margin-bottom: 20px; color: #0076be; text-decoration: none; font-weight: bold; }

        .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 25px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 13px; font-weight: bold; margin-bottom: 5px; color: #333; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; }
        .btn-submit { background: #28a745; color: white; border: none; padding: 12px; font-size: 15px; font-weight: bold; border-radius: 4px; width: 100%; cursor: pointer; }
        .btn-submit:hover { background: #218838; }

        /* Receipt Box Styling */
        .receipt-card { background: white; padding: 30px; border-radius: 8px; border: 1px solid #ddd; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .receipt-header { text-align: center; border-bottom: 2px dashed #bbb; padding-bottom: 15px; margin-bottom: 20px; }
        .receipt-header h2 { color: #0076be; font-size: 22px; margin-bottom: 5px; }
        .receipt-header p { font-size: 12px; color: #666; }

        .invoice-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .invoice-table th, .invoice-table td { padding: 10px; text-align: left; font-size: 14px; border-bottom: 1px solid #eee; }
        .invoice-table th { background: #f8f9fa; color: #555; }
        .total-row td { font-weight: bold; font-size: 16px; color: #0076be; border-top: 2px solid #333; }

        .btn-print { background: #0076be; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold; width: 100%; margin-top: 15px; font-size: 14px; }
        .btn-print:hover { background: #005a93; }

        /* Print Media Query: Hides unnecessary UI elements when printing */
        @media print {
            body { background: white; padding: 0; }
            .no-print, .back-link, .card { display: none !important; }
            .container { max-width: 100%; width: 100%; margin: 0; }
            .receipt-card { border: none; box-shadow: none; padding: 0; }
        }
    </style>
</head>
<body>

<div class="container">
    <a href="dashboard.jsp" class="back-link no-print">&larr; Back to Dashboard</a>

    <!-- Billing Process Form -->
    <div class="card no-print">
        <h2>Process Patient Billing</h2>
        <p style="font-size: 13px; color: #666; margin-bottom: 15px;">Calculate final treatment fees via Database Stored Procedure.</p>

        <% String error = request.getParameter("error"); %>
        <% if (error != null) { %>
            <div style="color: red; margin-bottom: 15px; font-size: 13px;"><%= error %></div>
        <% } %>

        <form action="process-billing" method="POST" onsubmit="return confirmBilling()">
            <div class="form-group">
                <label for="appointmentId">Appointment Database ID:</label>
                <input type="number" id="appointmentId" name="appointmentId" placeholder="e.g. 1" required>
            </div>

            <div class="form-group">
                <label for="consultationFee">Consultation Fee (LKR):</label>
                <input type="number" step="0.01" id="consultationFee" name="consultationFee" value="1500.00" required>
            </div>

            <button type="submit" class="btn-submit">Calculate & Generate Bill</button>
        </form>
    </div>

    <!-- Official Printable Receipt (Visible upon successful calculation) -->
    <% if ("success".equals(status)) { %>
    <div class="receipt-card" id="printableReceipt">
        <div class="receipt-header">
            <h2>SUNRISE DENTAL CLINIC</h2>
            <p>No 123, Galle Road, Colombo 03 | Tel: +94 11 234 5678</p>
            <p style="margin-top: 5px;"><strong>OFFICIAL PAYMENT RECEIPT</strong></p>
        </div>

        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 15px;">
            <div>
                <p><strong>Appointment ID:</strong> #<%= apptIdStr %></p>
                <p><strong>Issued By Staff:</strong> <%= user.getFullName() %></p>
            </div>
            <div style="text-align: right;">
                <p><strong>Date:</strong> <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date()) %></p>
                <p><strong>Payment Status:</strong> <span style="color: green; font-weight: bold;">PAID</span></p>
            </div>
        </div>

        <table class="invoice-table">
            <thead>
                <tr>
                    <th>Description</th>
                    <th style="text-align: right;">Amount (LKR)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Doctor Consultation Fee</td>
                    <td style="text-align: right;"><%= String.format("%.2f", consultationFee) %></td>
                </tr>
                <tr>
                    <td>Treatment Charges (Base Fee)</td>
                    <td style="text-align: right;">Calculated via SP</td>
                </tr>
                <tr class="total-row">
                    <td>Total Paid Amount</td>
                    <td style="text-align: right;">Processed via Database</td>
                </tr>
            </tbody>
        </table>

        <p style="text-align: center; font-size: 11px; color: #777; margin-top: 20px;">
            Thank you for choosing Sunrise Dental Clinic. Get well soon!
        </p>

        <button class="btn-print no-print" onclick="window.print()">Print Official Receipt</button>
    </div>
    <% } %>

</div>

<script>
    function confirmBilling() {
        return confirm("Are you sure you want to process billing for this appointment? This action will execute the MySQL Stored Procedure and finalize payment.");
    }
</script>

</body>
</html>