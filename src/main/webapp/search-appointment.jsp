<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.dto.User" %>
<%

    Object userObj = session.getAttribute("loggedUser");

    if (userObj == null) {
        response.sendRedirect("login.jsp?error=Unauthorized+Access");
        return;
    }

    User user = null;
    if (userObj instanceof User) {
        user = (User) userObj;
    } else {
        response.sendRedirect("login.jsp?error=Invalid+Session+State");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental - Search Appointment</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f4f7f6; padding: 30px; }
        .wrapper { max-width: 700px; margin: 0 auto; }
        .back-link { display: inline-block; margin-bottom: 20px; color: #0076be; text-decoration: none; font-weight: bold; }
        .search-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 25px; }
        .search-box { display: flex; gap: 10px; margin-top: 15px; }
        .search-box input { flex: 1; padding: 10px 12px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; outline: none; }
        .search-box input:focus { border-color: #0076be; }
        .btn-search { background: #0076be; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .btn-search:hover { background: #005a93; }


        .result-card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); display: none; }
        .result-header { border-bottom: 2px solid #eef2f5; padding-bottom: 10px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; }
        .status-badge { background: #28a745; color: white; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .detail-item label { display: block; font-size: 12px; color: #666; font-weight: bold; text-transform: uppercase; margin-bottom: 3px; }
        .detail-item span { font-size: 15px; color: #333; font-weight: 500; }
        .error-msg { color: #dc3545; background: #f8d7da; padding: 12px; border-radius: 4px; border: 1px solid #f5c6cb; margin-top: 15px; display: none; }
        .spinner { display: none; margin-top: 10px; font-size: 13px; color: #0076be; font-weight: bold; }
    </style>
    <script>

        async function fetchAppointmentData() {
            const apptInput = document.getElementById("apptNumberInput");
            const apptNum = apptInput.value.trim();
            const errorDiv = document.getElementById("errorMessage");
            const resultCard = document.getElementById("resultCard");
            const spinner = document.getElementById("loadingSpinner");


            errorDiv.style.display = "none";
            resultCard.style.display = "none";

            if (apptNum === "") {
                errorDiv.innerText = "Please enter an appointment number.";
                errorDiv.style.display = "block";
                apptInput.focus();
                return;
            }


            if (apptNum.length < 5 || apptNum.length > 30) {
                errorDiv.innerText = "Appointment number format is invalid. Length must be between 5 and 30 characters.";
                errorDiv.style.display = "block";
                apptInput.focus();
                return;
            }

            spinner.style.display = "block";

            try {

                const response = await fetch(`api/appointment?apptNumber=${encodeURIComponent(apptNum)}`);

                spinner.style.display = "none";

                if (response.ok) {
                    const data = await response.json();


                    document.getElementById("resApptNum").innerText = data.appointmentNumber;
                    document.getElementById("resStatus").innerText = data.status;
                    document.getElementById("resPatientName").innerText = data.patientName;
                    document.getElementById("resContact").innerText = data.contactNumber;
                    document.getElementById("resDentist").innerText = data.dentistName;
                    document.getElementById("resTreatment").innerText = data.treatmentName;
                    document.getElementById("resDatetime").innerText = data.appointmentDatetime;


                    const statusBadge = document.getElementById("resStatus");
                    if(data.status === 'COMPLETED') {
                        statusBadge.style.backgroundColor = '#28a745';
                    } else if(data.status === 'CANCELLED') {
                        statusBadge.style.backgroundColor = '#dc3545';
                    } else {
                        statusBadge.style.backgroundColor = '#ffc107';
                        statusBadge.style.color = '#333';
                    }

                    resultCard.style.display = "block";
                } else {
                    const errData = await response.json();
                    errorDiv.innerText = errData.error || "No appointment record found with this number.";
                    errorDiv.style.display = "block";
                }
            } catch (error) {
                spinner.style.display = "none";
                errorDiv.innerText = "Error connecting to server. Please try again later.";
                errorDiv.style.display = "block";
                console.error("Fetch Error:", error);
            }
        }
    </script>
</head>
<body>

<div class="wrapper">
    <a href="dashboard.jsp" class="back-link">&larr; Back to Dashboard</a>

    <div class="search-card">
        <h2>Search Appointment Details</h2>
        <p style="font-size: 13px; color: #666;">Enter the unique appointment number (e.g. APT-1700000000) to fetch real-time patient records.</p>

        <div class="search-box">
            <input type="text" id="apptNumberInput" placeholder="Enter Appointment Number..." required minlength="5" maxlength="30">
            <button type="button" class="btn-search" onclick="fetchAppointmentData()">Search Record</button>
        </div>
        <div id="loadingSpinner" class="spinner">Fetching data from Web Service...</div>
        <div id="errorMessage" class="error-msg"></div>
    </div>


    <div id="resultCard" class="result-card">
        <div class="result-header">
            <h3 id="resApptNum" style="color: #0076be;">-</h3>
            <span id="resStatus" class="status-badge">-</span>
        </div>

        <div class="detail-grid">
            <div class="detail-item">
                <label>Patient Name</label>
                <span id="resPatientName">-</span>
            </div>
            <div class="detail-item">
                <label>Contact Number</label>
                <span id="resContact">-</span>
            </div>
            <div class="detail-item">
                <label>Assigned Dentist</label>
                <span id="resDentist">-</span>
            </div>
            <div class="detail-item">
                <label>Treatment Type</label>
                <span id="resTreatment">-</span>
            </div>
            <div class="detail-item" style="grid-column: span 2;">
                <label>Appointment Date & Time</label>
                <span id="resDatetime">-</span>
            </div>
        </div>
    </div>
</div>

</body>
</html>