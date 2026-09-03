<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental Clinic - Login</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #eef2f5; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .login-card { background: #ffffff; width: 380px; padding: 40px 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .brand-header { text-align: center; margin-bottom: 25px; }
        .brand-header h2 { color: #0076be; font-size: 24px; }
        .brand-header p { color: #666; font-size: 13px; margin-top: 5px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #333; margin-bottom: 6px; }
        .form-group input { width: 100%; padding: 10px 12px; border: 1px solid #ccc; border-radius: 5px; font-size: 14px; outline: none; }
        .form-group input:focus { border-color: #0076be; }
        .btn-login { width: 100%; background: #0076be; color: white; border: none; padding: 12px; font-size: 15px; font-weight: bold; border-radius: 5px; cursor: pointer; transition: background 0.3s; }
        .btn-login:hover { background: #005a93; }
        .alert { padding: 10px; border-radius: 5px; font-size: 13px; margin-bottom: 20px; text-align: center; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    </style>
</head>
<body>

<div class="login-card">
    <div class="brand-header">
        <h2>Sunrise Dental Clinic</h2>
        <p>Patient & Appointment Management System</p>
    </div>

    <%
        String error = request.getParameter("error");
        String msg = request.getParameter("msg");
        if (error != null) {
    %>
        <div class="alert alert-danger"><%= error %></div>
    <% } else if (msg != null) { %>
        <div class="alert alert-success"><%= msg %></div>
    <% } %>

    <form action="<%=request.getContextPath()%>/auth" method="POST" onsubmit="return validateLogin()">
        <input type="hidden" name="action" value="login">

        <div class="form-group">
            <label for="username">Username</label>
            <input type="text" id="username" name="username" placeholder="Enter your username" required>
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="Enter your password" required>
        </div>

        <button type="submit" class="btn-login">Sign In</button>
    </form>
</div>

<script>
    function validateLogin() {
        const u = document.getElementById("username").value.trim();
        const p = document.getElementById("password").value.trim();
        if (u === "" || p === "") {
            alert("Please fill in both Username and Password fields.");
            return false;
        }
        return true;
    }
</script>

</body>
</html>