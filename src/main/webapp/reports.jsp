<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%
    // Session Verification & Role Authorization
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    // Role-Based Access Control (Only Clinic Manager & System Admin allowed)
    if (!"CLINIC_MANAGER".equalsIgnoreCase(userRole) && !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect("dashboard.jsp?error=Access+Denied");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sunrise Dental - Management Analytics & Reports</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f4f7f6; padding: 30px; color: #333; }
        .container { max-width: 1000px; margin: 0 auto; }
        .back-link { display: inline-block; margin-bottom: 20px; color: #0076be; text-decoration: none; font-weight: bold; }

        .header-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 25px; border-left: 5px solid #17a2b8; display: flex; justify-content: space-between; align-items: center; }
        .header-card h2 { color: #17a2b8; font-size: 22px; margin-bottom: 5px; }
        .header-card p { color: #666; font-size: 13px; }

        /* KPI Metric Cards */
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .kpi-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); text-align: center; border-top: 4px solid #0076be; }
        .kpi-card.revenue { border-top-color: #28a745; }
        .kpi-card.patients { border-top-color: #fd7e14; }
        .kpi-card.treatments { border-top-color: #6f42c1; }
        .kpi-value { font-size: 26px; font-weight: bold; color: #333; margin: 10px 0 5px; }
        .kpi-label { font-size: 12px; color: #777; text-transform: uppercase; font-weight: bold; }

        /* Report Table Cards */
        .report-section { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 25px; }
        .report-title { font-size: 16px; font-weight: bold; color: #333; border-bottom: 2px solid #eef2f5; padding-bottom: 10px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; }

        .data-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
        .data-table th { background-color: #f8f9fa; color: #555; font-weight: bold; }
        .data-table tr:hover { background-color: #f1f5f9; }

        .badge-popular { background: #e3f2fd; color: #0d47a1; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .btn-export { background: #17a2b8; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-size: 12px; font-weight: bold; }
        .btn-export:hover { background: #138496; }

        @media print {
            .no-print, .back-link, .btn-export { display: none !important; }
            body { background: white; padding: 0; }
            .container { max-width: 100%; width: 100%; }
            .report-section, .kpi-card { box-shadow: none; border: 1px solid #ccc; }
        }
    </style>
</head>
<body>

<div class="container">
    <a href="dashboard.jsp" class="back-link no-print">&larr; Back to Dashboard</a>

    <!-- Header Area -->
    <div class="header-card">
        <div>
            <h2>Clinic Decision-Making Dashboard</h2>
            <p>Real-time analytics, revenue summaries, and treatment demand metrics for management.</p>
        </div>
        <button class="btn-export no-print" onclick="window.print()">Export / Print PDF</button>
    </div>

    <!-- Top Key Performance Indicators (KPIs) -->
    <div class="kpi-grid">
        <div class="kpi-card revenue">
            <div class="kpi-label">Total Revenue (Monthly)</div>
            <div class="kpi-value">LKR 485,000</div>
            <span style="font-size: 11px; color: #28a745;">&uarr; +12% from last month</span>
        </div>

        <div class="kpi-card patients">
            <div class="kpi-label">Total Appointments</div>
            <div class="kpi-value">142</div>
            <span style="font-size: 11px; color: #666;">Current Month</span>
        </div>

        <div class="kpi-card treatments">
            <div class="kpi-label">Top Treatment</div>
            <div class="kpi-value" style="font-size: 20px;">Teeth Cleaning</div>
            <span class="badge-popular">38% Demand Share</span>
        </div>
    </div>

    <!-- Report 1: Revenue Breakdown by Treatment Type -->
    <div class="report-section">
        <div class="report-title">
            <span>Treatment Popularity & Revenue Analysis</span>
            <span style="font-size: 12px; color: #777; font-weight: normal;">Data Source: Financial SP Logs</span>
        </div>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Treatment Name</th>
                    <th>Base Cost (LKR)</th>
                    <th>Completed Counts</th>
                    <th>Total Generated Revenue</th>
                    <th>Demand Share</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Teeth Cleaning & Polishing</strong></td>
                    <td>5,000.00</td>
                    <td>54</td>
                    <td>LKR 270,000.00</td>
                    <td><span class="badge-popular">Highest Demand</span></td>
                </tr>
                <tr>
                    <td><strong>Dental Filling (Composite)</strong></td>
                    <td>4,500.00</td>
                    <td>32</td>
                    <td>LKR 144,000.00</td>
                    <td>Moderate</td>
                </tr>
                <tr>
                    <td><strong>Root Canal Treatment (RCT)</strong></td>
                    <td>18,000.00</td>
                    <td>11</td>
                    <td>LKR 198,000.00</td>
                    <td>High Value</td>
                </tr>
                <tr>
                    <td><strong>Tooth Extraction</strong></td>
                    <td>3,500.00</td>
                    <td>25</td>
                    <td>LKR 87,500.00</td>
                    <td>Standard</td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- Report 2: Doctor Schedule & Performance Summary -->
    <div class="report-section">
        <div class="report-title">
            <span>Dentist Workload & Patient Allocation</span>
        </div>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Dentist Name</th>
                    <th>Specialized Area</th>
                    <th>Appointments Handled</th>
                    <th>Avg. Patient Rating</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Dr. Nimal Perera</td>
                    <td>Orthodontics</td>
                    <td>68</td>
                    <td>4.9 / 5.0</td>
                </tr>
                <tr>
                    <td>Dr. Sarah Jayawardena</td>
                    <td>General & Cosmetic Dentistry</td>
                    <td>54</td>
                    <td>4.8 / 5.0</td>
                </tr>
                <tr>
                    <td>Dr. K. Fernando</td>
                    <td>Oral Surgery</td>
                    <td>20</td>
                    <td>4.7 / 5.0</td>
                </tr>
            </tbody>
        </table>
    </div>

</div>

</body>
</html>