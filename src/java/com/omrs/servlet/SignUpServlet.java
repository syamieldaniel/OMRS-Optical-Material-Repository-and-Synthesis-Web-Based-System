package com.omrs.servlet;

import com.omrs.dao.UserDAO;
import com.omrs.model.User;
import com.omrs.util.EmailValidator;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/signup")
public class SignUpServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Map<String, String>> supervisors = userDAO.getSupervisors();
        req.setAttribute("supervisors", supervisors);
        
        String role = req.getParameter("role");
        if (role == null) role = (String) req.getAttribute("role");
        if (role != null) {
            req.setAttribute("role", role);
        }
        req.getRequestDispatcher("/signup.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        String fullName = req.getParameter("fullName");
        String role = req.getParameter("role");
        String supervisorId = req.getParameter("supervisorId");
        String studentId = req.getParameter("studentId");
        String studentType = req.getParameter("studentType");

        if (!EmailValidator.isValid(email)) {
            req.setAttribute("error", "Please enter a valid email address that you can access.");
            req.setAttribute("role", role);
            doGet(req, resp);
            return;
        }
        
        // Validation for student
        if ("STUDENT".equals(role)) {
            studentType = "FYP".equals(studentType) ? "FYP" : "NORMAL";
            if ("FYP".equals(studentType) && (supervisorId == null || supervisorId.trim().isEmpty())) {
                req.setAttribute("error", "Please select a supervisor.");
                req.setAttribute("role", role);
                doGet(req, resp);
                return;
            }
        }
        
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setEmail(email);
        user.setFullName(fullName);
        user.setRole(role);
        user.setStudentType(studentType);
        
        try {
            boolean success = userDAO.register(user, supervisorId, studentId);
            if (success) {
                if ("STUDENT".equals(role)) {
                    if ("FYP".equals(studentType)) {
                        resp.sendRedirect("login.jsp?message=Registration successful! Please wait for supervisor approval.");
                    } else {
                        resp.sendRedirect("login.jsp?message=Registration successful! You can now login.");
                    }
                } else {
                    resp.sendRedirect("login.jsp?message=Registration successful! You can now login.");
                }
            } else {
                req.setAttribute("error", "Registration failed. Username or email may already exist.");
                req.setAttribute("role", role);
                doGet(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Registration failed: " + e.getMessage());
            req.setAttribute("role", role);
            doGet(req, resp);
        }
    }
}
