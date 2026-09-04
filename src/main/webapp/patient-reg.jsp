<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sunrise Dental - Register Patient</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background-color: #f4f7f6; }
        .form-container { width: 450px; background: white; padding: 25px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); margin: 0 auto; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input, textarea { width: 100%; padding: 8px; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; outline: none; }
        input:focus, textarea:focus { border-color: #007bff; }
        .btn { background-color: #007bff; color: white; border: none; padding: 10px; cursor: pointer; width: 100%; border-radius: 4px; font-weight: bold; }
        .btn:hover { background-color: #0056b3; }
        .msg { margin-bottom: 15px; padding: 10px; border-radius: 4px; text-align: center; }
        .success { background-color: #d4edda; color: #155724; }
        .error { background-color: #f8d7da; color: #721c24; }
    </style>
    <script>
        function validateForm() {
            const fullName = document.getElementById("fullName").value.trim();
            const address = document.getElementById("address").value.trim();
            const contact = document.getElementById("contactNumber").value.trim();
            const email = document.getElementById("email").value.trim();

            if (fullName.length < 3) {
                alert("Full Name must be at least 3 characters long.");
                document.getElementById("fullName").focus();
                return false;
            }

            if (address.length < 5) {
                alert("Please provide a valid address (at least 5 characters).");
                document.getElementById("address").focus();
                return false;
            }

            const phoneRegex = /^[0-9]{10}$/;
            if (!phoneRegex.test(contact)) {
                alert("Please enter a valid 10-digit contact number (numbers only).");
                document.getElementById("contactNumber").focus();
                return false;
            }

            if (email !== "") {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(email)) {
                    alert("Please enter a valid email address format.");
                    document.getElementById("email").focus();
                    return false;
                }
            }

            return true;
        }
    </script>
</head>
<body>

<div class="form-container">
    <h2>Register New Patient</h2>

    <%
        String msg = request.getParameter("msg");
        String error = request.getParameter("error");
        if (msg != null) {
    %>
    <div class="msg success"><%= msg.replaceAll("[<>]", "") %></div>
    <% } else if (error != null) { %>
    <div class="msg error"><%= error.replaceAll("[<>]", "") %></div>
    <% } %>

    <form action="api/patient" method="POST" onsubmit="return validateForm()">
        <div class="form-group">
            <label>Full Name:</label>
            <input type="text" id="fullName" name="fullName" placeholder="e.g. John Doe" required minlength="3" maxlength="100">
        </div>
        <div class="form-group">
            <label>Address:</label>
            <textarea id="address" name="address" rows="3" placeholder="e.g. 123, Main Street, Colombo" required minlength="5" maxlength="255"></textarea>
        </div>
        <div class="form-group">
            <label>Contact Number:</label>
            <input type="text" id="contactNumber" name="contactNumber" placeholder="e.g. 0771234567" required pattern="[0-9]{10}" maxlength="10">
        </div>
        <div class="form-group">
            <label>Email Address:</label>
            <input type="email" id="email" name="email" placeholder="e.g. johndoe@example.com" maxlength="100">
        </div>

        <button type="submit" class="btn">Register Patient</button>
    </form>
</div>

</body>
</html>