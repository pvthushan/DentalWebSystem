<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
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
    <title>Sunrise Dental - Treatment & Pricing Configuration</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }

        /* Left Sidebar Layout */
        .sidebar { width: 250px; background-color: #1e293b; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #f59e0b; margin-bottom: 30px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #cbd5e1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #f59e0b; color: #0f172a; }
        .btn-logout-sidebar { background-color: #ef4444; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }

        /* Main Content Layout */
        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { margin-bottom: 20px; }
        .header-bar h1 { font-size: 24px; color: #0f172a; margin-bottom: 5px; }
        .header-bar p { font-size: 14px; color: #64748b; }

        /* Card Container */
        .card-box { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 30px; }
        .card-box h3 { font-size: 18px; color: #0f172a; margin-bottom: 15px; }

        /* Form Controls */
        .form-grid { display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 15px; align-items: end; }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group label { font-size: 13px; font-weight: bold; color: #334155; }
        .input-text, .input-price { padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; width: 100%; }

        /* Buttons */
        .btn-add { background-color: #10b981; color: white; border: none; padding: 10px 18px; border-radius: 6px; font-weight: bold; cursor: pointer; font-size: 14px; transition: 0.2s; }
        .btn-add:hover { background-color: #059669; }
        .btn-update { background-color: #eab308; color: #0f172a; border: none; padding: 7px 14px; border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 13px; }
        .btn-update:hover { background-color: #ca8a04; }

        /* Table Styling */
        table { width: 100%; border-collapse: collapse; text-align: left; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-top: 10px; }
        th { background-color: #334155; color: white; padding: 12px 16px; font-size: 14px; font-weight: 600; }
        td { padding: 12px 16px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #334155; vertical-align: middle; }
    </style>
</head>
<body>

    <!-- Left Sidebar Menu -->
    <div class="sidebar">
        <h2>🛡️ Admin Panel</h2>
        <div class="nav-menu">
            <a href="admin-dashboard.jsp" class="nav-btn">🏠 Admin Home</a>
            <a href="admin-staff.jsp" class="nav-btn">👥 Staff Management</a>
            <a href="admin-logs.jsp" class="nav-btn">📜 System Logs</a>
            <a href="admin-pricing.jsp" class="nav-btn active">⚙️ Treatment & Pricing</a>
            <a href="admin-reports.jsp" class="nav-btn">📊 Reports</a>
            <a href="admin-help.jsp" class="nav-btn">❓ Help Section</a>
        </div>
        <a href="auth?action=logout" class="btn-logout-sidebar">Logout Admin</a>
    </div>

    <!-- Main Content Area -->
    <div class="main-content">
        <div class="header-bar">
            <h1>⚙️ Consultation Fee & Treatment Pricing</h1>
            <p>Configure doctor-wise consultation fees, add new dental treatments, and update pricing.</p>
        </div>

        <!-- NEW SECTION: Add New Treatment Type -->
        <div class="card-box">
            <h3>➕ Add New Treatment Type</h3>
            <form action="admin-pricing" method="POST">
                <input type="hidden" name="action" value="addTreatment">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Treatment Name</label>
                        <input type="text" class="input-text" name="treatmentName" placeholder="e.g. Teeth Whitening / Scaling" required>
                    </div>
                    <div class="form-group">
                        <label>Initial Price (Rs.)</label>
                        <input type="number" step="0.01" class="input-price" name="treatmentCost" placeholder="e.g. 5000.00" required>
                    </div>
                    <div>
                        <button type="submit" class="btn-add">+ Add Treatment</button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Section 1: Doctor Consultation Fees -->
        <div class="card-box">
            <h3>👨‍⚕️ Doctor Consultation Fees</h3>
            <table>
                <thead>
                    <tr>
                        <th>Doctor ID</th>
                        <th>Doctor Name</th>
                        <th>Specialization</th>
                        <th>Current Fee (Rs.)</th>
                        <th>New Fee (Rs.)</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <form action="admin-pricing" method="POST">
                            <input type="hidden" name="action" value="updateDocFee">
                            <input type="hidden" name="doctorId" value="DOC-01">
                            <td>DOC-01</td>
                            <td>Dr. Anura Perera</td>
                            <td>Dental Surgeon</td>
                            <td>2,500.00</td>
                            <td>
                                <input type="number" step="0.01" class="input-price" name="newFee" placeholder="Enter fee" required>
                            </td>
                            <td>
                                <button type="submit" class="btn-update">Update Fee</button>
                            </td>
                        </form>
                    </tr>
                    <tr>
                        <form action="admin-pricing" method="POST">
                            <input type="hidden" name="action" value="updateDocFee">
                            <input type="hidden" name="doctorId" value="DOC-02">
                            <td>DOC-02</td>
                            <td>Dr. K. N. Gunawardena</td>
                            <td>Orthodontist</td>
                            <td>3,500.00</td>
                            <td>
                                <input type="number" step="0.01" class="input-price" name="newFee" placeholder="Enter fee" required>
                            </td>
                            <td>
                                <button type="submit" class="btn-update">Update Fee</button>
                            </td>
                        </form>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- Section 2: Existing Treatment Types & Costs -->
        <div class="card-box">
            <h3>🦷 Treatment Type & Costs</h3>
            <table>
                <thead>
                    <tr>
                        <th>Treatment Code</th>
                        <th>Treatment Name</th>
                        <th>Current Cost (Rs.)</th>
                        <th>New Cost (Rs.)</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <form action="admin-pricing" method="POST">
                            <input type="hidden" name="action" value="updateTreatmentCost">
                            <input type="hidden" name="treatmentId" value="TRT-001">
                            <td>TRT-001</td>
                            <td>Composite Dental Filling</td>
                            <td>4,500.00</td>
                            <td>
                                <input type="number" step="0.01" class="input-price" name="newCost" placeholder="Enter cost" required>
                            </td>
                            <td>
                                <button type="submit" class="btn-update">Update Cost</button>
                            </td>
                        </form>
                    </tr>
                    <tr>
                        <form action="admin-pricing" method="POST">
                            <input type="hidden" name="action" value="updateTreatmentCost">
                            <input type="hidden" name="treatmentId" value="TRT-002">
                            <td>TRT-002</td>
                            <td>Root Canal Treatment (RCT)</td>
                            <td>18,000.00</td>
                            <td>
                                <input type="number" step="0.01" class="input-price" name="newCost" placeholder="Enter cost" required>
                            </td>
                            <td>
                                <button type="submit" class="btn-update">Update Cost</button>
                            </td>
                        </form>
                    </tr>
                    <tr>
                        <form action="admin-pricing" method="POST">
                            <input type="hidden" name="action" value="updateTreatmentCost">
                            <input type="hidden" name="treatmentId" value="TRT-003">
                            <td>TRT-003</td>
                            <td>Tooth Extraction</td>
                            <td>3,000.00</td>
                            <td>
                                <input type="number" step="0.01" class="input-price" name="newCost" placeholder="Enter cost" required>
                            </td>
                            <td>
                                <button type="submit" class="btn-update">Update Cost</button>
                            </td>
                        </form>
                    </tr>
                </tbody>
            </table>
        </div>

    </div>

</body>
</html>