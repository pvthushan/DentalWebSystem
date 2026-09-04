<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%@ page import="com.sunrisedental.dto.Doctor" %>
<%@ page import="java.util.List" %>
<%@ page import="com.sunrisedental.config.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.*" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    String userRole = (String) session.getAttribute("userRole");

    if (user == null || !"SYSTEM_ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    String safeUsername = (user.getUsername() != null) ? user.getUsername().replaceAll("[<>]", "") : "Admin";
    List<User> staffList = (List<User>) request.getAttribute("staffList");
    User editStaff = (User) request.getAttribute("staffUser");
    Doctor editDoctor = (Doctor) request.getAttribute("doctor");
    List<Doctor> doctorList = (List<Doctor>) request.getAttribute("doctorList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Staff Management</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; min-height: 100vh; background-color: #f4f7f6; }

        .sidebar { width: 250px; background-color: #1e293b; color: white; display: flex; flex-direction: column; padding: 20px 15px; }
        .sidebar h2 { font-size: 20px; color: #f59e0b; margin-bottom: 30px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; flex: 1; }
        .nav-btn { display: block; padding: 12px 15px; color: #cbd5e1; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .nav-btn:hover, .nav-btn.active { background-color: #f59e0b; color: #0f172a; }
        .btn-logout-sidebar { background-color: #ef4444; color: white; text-align: center; padding: 10px; border-radius: 6px; text-decoration: none; font-weight: bold; margin-top: auto; }

        .main-content { flex: 1; padding: 30px 40px; }
        .header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .header-bar h1 { font-size: 24px; color: #0f172a; }

        .tab-menu { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid #cbd5e1; }
        .tab-btn { padding: 10px 20px; font-weight: bold; background: none; border: none; cursor: pointer; font-size: 15px; color: #64748b; }
        .tab-btn.active { color: #0076be; border-bottom: 3px solid #0076be; }

        .card-box { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 25px; }
        .card-box h3 { font-size: 18px; color: #0f172a; margin-bottom: 15px; display: flex; align-items: center; gap: 8px; }

        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; }
        .form-group { display: flex; flex-direction: column; gap: 5px; }
        .form-group label { font-size: 13px; font-weight: bold; color: #334155; }
        .form-group input, .form-group select { padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; }

        .btn-submit { background-color: #10b981; color: white; padding: 10px 20px; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top: 15px; }
        .btn-submit:hover { background-color: #059669; }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        th { background-color: #334155; color: white; text-align: left; padding: 12px; font-size: 14px; }
        td { padding: 12px; font-size: 14px; border-bottom: 1px solid #e2e8f0; color: #334155; }

        .btn-edit { background-color: #3b82f6; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 12px; font-weight: bold; text-decoration: none; margin-right: 5px; }
        .btn-delete { background-color: #ef4444; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 12px; font-weight: bold; text-decoration: none; }
        .status-active { color: #10b981; font-weight: bold; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>🛡️ Admin Panel</h2>
    <div class="nav-menu">
        <a href="admin-dashboard" class="nav-btn">🏠 Admin Home</a>
        <a href="admin-staff.jsp" class="nav-btn active">👥 Staff Management</a>
        <a href="admin-logs.jsp" class="nav-btn">📜 System Logs</a>
        <a href="admin-pricing" class="nav-btn">⚙️ Treatment & Pricing</a>
        <a href="admin-reports" class="nav-btn">📊 Reports</a>
        <a href="admin-help.jsp" class="nav-btn">❓ Help Section</a>
    </div>
    <a href="auth?action=logout" class="btn-logout-sidebar">Logout Admin</a>
</div>

<div class="main-content">
    <div class="header-bar">
        <h1>👥 Staff & Doctor Management</h1>
    </div>

    <div class="tab-menu">
        <button class="tab-btn active" onclick="switchTab('staffTab', this)">Manage Staff Users</button>
        <button class="tab-btn" onclick="switchTab('doctorTab', this)">Manage Doctors</button>
    </div>


    <div id="staffTab" class="tab-content active">
        <div class="card-box">
            <h3><%= (editStaff != null) ? "✏️ Edit Staff User" : "➕ Add / Update System User" %></h3>
            <form action="admin-user" method="POST">
                <input type="hidden" name="action" value="saveUser">
                <input type="hidden" id="userId" name="userId" value="<%= (editStaff != null) ? editStaff.getUserId() : "0" %>">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" id="fullName" name="fullName" value="<%= (editStaff != null) ? editStaff.getFullName() : "" %>" placeholder="e.g. Nimal Perera" required>
                    </div>
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" id="username" name="username" value="<%= (editStaff != null) ? editStaff.getUsername() : "" %>" placeholder="e.g. nimal_recept" required>
                    </div>
                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" id="password" name="password" placeholder="Leave empty to keep existing password">
                    </div>
                    <div class="form-group">
                        <label>Role</label>
                        <div id="roleContainer">
                            <select id="userRole" name="userRole" required class="form-control">
                                <option value="RECEPTIONIST">Receptionist</option>
                                <option value="CLINIC_MANAGER">Clinic Manager</option>
                                <option value="SYSTEM_ADMIN">System Admin</option>
                            </select>
                        </div>
                    </div>
                </div>
                <button type="submit" class="btn-submit"><%= (editStaff != null) ? "Update Staff User" : "Register / Save Staff" %></button>
                <% if (editStaff != null) { %>
                <a href="admin-user?action=list" style="margin-left: 10px; color: #64748b; text-decoration: none; font-weight: bold;">Cancel</a>
                <% } %>
            </form>
        </div>

        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Full Name</th>
                <th>Username</th>
                <th>Role</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT u.user_id, u.full_name, u.username, r.role_name FROM users u JOIN roles r ON u.role_id = r.role_id";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    ResultSet rs = stmt.executeQuery();

                    while (rs.next()) {
                        int uId = rs.getInt("user_id");
                        String fName = rs.getString("full_name");
                        String uName = rs.getString("username");
                        String rName = rs.getString("role_name");
            %>
            <tr>
                <td><%= uId %></td>
                <td><%= fName %></td>
                <td><%= uName %></td>
                <td><strong><%= rName %></strong></td>
                <td><span class="status-active">✓ Active</span></td>
                <td>
                    <button class="btn-edit" onclick="editStaff(<%= uId %>, '<%= fName %>', '<%= uName %>', '<%= rName %>')">Edit</button>
                    <a href="admin-user?action=delete&id=<%= uId %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this user?');">Delete</a>
                </td>
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


    <div id="doctorTab" class="tab-content">
        <div class="card-box">
            <h3 id="doctorFormTitle">➕ Add New Doctor</h3>
            <form action="doctor-servlet" method="POST">
                <input type="hidden" name="action" value="saveDoctor">
                <input type="hidden" id="doctorId" name="doctorId" value="0">

                <div class="form-grid">
                    <div class="form-group">
                        <label>Doctor Name</label>
                        <input type="text" id="doctorName" name="doctorName" placeholder="e.g. Dr. Kasun Silva" required>
                    </div>
                    <div class="form-group">
                        <label>Specialization</label>
                        <input type="text" id="specialization" name="specialization" placeholder="e.g. Orthodontics / General Dentistry" required>
                    </div>
                    <div class="form-group">
                        <label>Contact Number</label>
                        <input type="text" id="contactNumber" name="contactNumber" placeholder="e.g. 0771234567" required>
                    </div>
                    <div class="form-group">
                        <label>Consultation Fee (Rs.)</label>
                        <input type="number" step="0.01" id="consultationFee" name="consultationFee" placeholder="e.g. 2500.00" required>
                    </div>
                </div>
                <button type="submit" id="docSubmitBtn" class="btn-submit">Register / Save Doctor</button>
                <button type="button" id="docCancelBtn" onclick="resetDoctorForm()" style="display:none; margin-left: 10px; background: #64748b; color: white; padding: 10px 20px; border: none; border-radius: 6px; font-weight: bold; cursor: pointer;">Cancel</button>
            </form>
        </div>

        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Doctor Name</th>
                <th>Specialization</th>
                <th>Contact</th>
                <th>Consultation Fee</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String docSql = "SELECT * FROM doctors";
                    PreparedStatement docStmt = conn.prepareStatement(docSql);
                    ResultSet docRs = docStmt.executeQuery();
                    boolean hasDoctors = false;

                    while (docRs.next()) {
                        hasDoctors = true;
                        int dId = docRs.getInt("doctor_id");
                        String dName = docRs.getString("doctor_name");
                        String dSpec = docRs.getString("specialization");
                        String dContact = docRs.getString("contact_number");
                        double dFee = docRs.getDouble("consultation_fee");
            %>
            <tr>
                <td><strong>DOC-0<%= dId %></strong></td>
                <td><%= dName %></td>
                <td><%= dSpec %></td>
                <td><%= dContact %></td>
                <td>Rs. <%= String.format("%.2f", dFee) %></td>
                <td>
                    <button type="button" class="btn-edit" onclick="editDoctor(<%= dId %>, '<%= dName %>', '<%= dSpec %>', '<%= dContact %>', <%= dFee %>)">Edit</button>
                    <a href="doctor-servlet?action=delete&id=<%= dId %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this doctor?');">Delete</a>
                </td>
            </tr>
            <%
                }
                if (!hasDoctors) {
            %>
            <tr>
                <td colspan="6" style="text-align: center; color: #64748b; padding: 20px;">No registered doctors found.</td>
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

</div>

<script>
    function switchTab(tabId, btn) {
        document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.getElementById(tabId).classList.add('active');
        btn.classList.add('active');
    }

    function editStaff(id, name, username, role) {
        document.getElementById('userId').value = id;
        document.getElementById('fullName').value = name;
        document.getElementById('username').value = username;

        let roleContainer = document.getElementById('roleContainer');

        if (role === 'SYSTEM_ADMIN') {
            roleContainer.innerHTML = `
            <input type="text" value="System Admin" class="form-control" disabled style="background-color: #e2e8f0; cursor: not-allowed;">
            <input type="hidden" name="userRole" value="SYSTEM_ADMIN">
        `;
        } else {
            roleContainer.innerHTML = `
            <select id="userRole" name="userRole" required class="form-control">
                <option value="RECEPTIONIST">Receptionist</option>
                <option value="CLINIC_MANAGER">Clinic Manager</option>
            </select>
        `;
            document.getElementById('userRole').value = role;
        }

        document.querySelector('#staffTab .card-box h3').innerText = "✏️ Edit Staff User";

        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function editDoctor(id, name, specialization, contact, fee) {
        document.getElementById('doctorId').value = id;
        document.getElementById('doctorName').value = name;
        document.getElementById('specialization').value = specialization;
        document.getElementById('contactNumber').value = contact;
        document.getElementById('consultationFee').value = fee;

        document.getElementById('doctorFormTitle').innerText = "✏️ Edit Doctor Details";
        document.getElementById('docSubmitBtn').innerText = "Update Doctor";
        document.getElementById('docCancelBtn').style.display = "inline-block";

        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function resetDoctorForm() {
        document.getElementById('doctorId').value = "0";
        document.getElementById('doctorName').value = "";
        document.getElementById('specialization').value = "";
        document.getElementById('contactNumber').value = "";
        document.getElementById('consultationFee').value = "";

        document.getElementById('doctorFormTitle').innerText = "➕ Add New Doctor";
        document.getElementById('docSubmitBtn').innerText = "Register / Save Doctor";
        document.getElementById('docCancelBtn').style.display = "none";
    }
</script>
</body>
</html>