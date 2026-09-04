<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sunrise Dental - Register Appointment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background-color: #f4f7f6; }
        .form-container { width: 450px; background: white; padding: 25px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input, select { width: 100%; padding: 8px; box-sizing: border-box; }
        .btn { background-color: #28a745; color: white; border: none; padding: 10px; cursor: pointer; width: 100%; border-radius: 4px; }
        .btn:hover { background-color: #218838; }
        .error { color: red; font-size: 12px; }
    </style>
</head>
<body>

<div class="form-container">
    <h2>Register Appointment</h2>
    <form id="apptForm" action="api/appointment" method="POST" onsubmit="return validateForm()">
        <div class="form-group">
            <label>Patient ID / Code:</label>
            <input type="number" id="patientId" name="patientId" placeholder="e.g. 1001" min="1" required>
        </div>
        <div class="form-group">
            <label>Dentist ID:</label>
            <input type="number" id="dentistId" name="dentistId" placeholder="e.g. 1" min="1" required>
        </div>
        <div class="form-group">
            <label>Treatment Type:</label>
            <select name="treatmentId" id="treatmentId" required>
                <option value="" disabled selected>Select a treatment</option>
                <option value="1">General Consultation (Rs. 1,500)</option>
                <option value="2">Tooth Extraction (Rs. 3,500)</option>
                <option value="3">Dental Cleaning (Rs. 5,000)</option>
                <option value="4">Root Canal (Rs. 15,000)</option>
            </select>
        </div>
        <div class="form-group">
            <label>Date & Time:</label>
            <input type="datetime-local" id="datetime" name="datetime" required>
        </div>
        <button type="submit" class="btn">Register Appointment</button>
    </form>
</div>

<script>

    function validateForm() {
        const patientId = document.getElementById("patientId").value;
        const dentistId = document.getElementById("dentistId").value;
        const treatmentId = document.getElementById("treatmentId").value;
        const datetime = document.getElementById("datetime").value;

        if (parseInt(patientId) <= 0 || isNaN(patientId)) {
            alert("Please enter a valid positive Patient ID.");
            return false;
        }

        if (parseInt(dentistId) <= 0 || isNaN(dentistId)) {
            alert("Please enter a valid positive Dentist ID.");
            return false;
        }

        if (!treatmentId || treatmentId === "") {
            alert("Please select a valid treatment type.");
            return false;
        }

        if (!datetime) {
            alert("Please select a valid appointment date and time.");
            return false;
        }

        const selectedDate = new Date(datetime);
        const currentDate = new Date();

        if (selectedDate < currentDate) {
            alert("Appointment date and time cannot be in the past!");
            return false;
        }

        return true;
    }
</script>

</body>
</html>