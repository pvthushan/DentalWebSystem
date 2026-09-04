package com.sunrisedental.web;

import com.sunrisedental.dao.UserDAO;
import com.sunrisedental.factory.DAOFactory;
import com.sunrisedental.dto.User;
import com.sunrisedental.util.SystemLogger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = DAOFactory.getUserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("logout".equalsIgnoreCase(action)) {
            handleLogout(request, response);
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("login".equalsIgnoreCase(action)) {
            handleLogin(request, response);
        } else if ("logout".equalsIgnoreCase(action)) {
            handleLogout(request, response);
        } else {
            response.sendRedirect("login.jsp?error=Invalid+Action");
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=Username+and+Password+are+required");
            return;
        }

        try {
            User user = userDAO.authenticate(username.trim(), password.trim());

            if (user != null) {
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession session = request.getSession(true);
                session.setAttribute("loggedUser", user);
                session.setAttribute("userRole", user.getRoleName());
                session.setAttribute("userId", user.getUserId());

                session.setMaxInactiveInterval(30 * 60);

                SystemLogger.logAction(user.getUsername(), "User logged into the system");

                switch (user.getRoleName().toUpperCase()) {
                    case "SYSTEM_ADMIN":
                        response.sendRedirect("admin-dashboard");
                        break;
                    case "CLINIC_MANAGER":
                        response.sendRedirect("manager-dashboard.jsp");
                        break;
                    case "RECEPTIONIST":
                        response.sendRedirect("receptionist-dashboard.jsp");
                        break;
                    case "DENTIST":
                        response.sendRedirect("dashboard.jsp?role=dentist");
                        break;
                    default:
                        response.sendRedirect("login.jsp?error=Unauthorized+Role");
                        break;
                }
            } else {
                SystemLogger.logAction(username.trim(), "Failed login attempt with invalid credentials");
                response.sendRedirect("login.jsp?error=Invalid+Username+or+Password");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Authentication+System+Error");
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        String loggedOutUser = "Unknown";

        if (session != null) {
            User user = (User) session.getAttribute("loggedUser");
            if (user != null) {
                loggedOutUser = user.getUsername();
            }

            SystemLogger.logAction(loggedOutUser, "User logged out of the system");

            session.removeAttribute("loggedUser");
            session.removeAttribute("userRole");
            session.removeAttribute("userId");
            session.invalidate();
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        response.sendRedirect("login.jsp?msg=Successfully+logged+out");
    }
}