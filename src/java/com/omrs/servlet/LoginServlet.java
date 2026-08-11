package com.omrs.servlet;

import com.omrs.dao.UserDAO;
import com.omrs.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User u = (User) session.getAttribute("user");
            if ("STUDENT".equals(u.getRole())) {
                resp.sendRedirect("student/dashboard");
            } else if ("RESEARCHER".equals(u.getRole())) {
                resp.sendRedirect("repository");
            } else {
                resp.sendRedirect("supervisor/dashboard");
            }
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String role = req.getParameter("role");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        
        User user = userDAO.login(username, password);
        
        if (user != null) {
            if ("PENDING".equals(user.getStatus())) {
                req.setAttribute("error", "Your account is pending supervisor approval.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            } else if ("REJECTED".equals(user.getStatus())) {
                req.setAttribute("error", "Your account has been rejected.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }
            
            if (!role.equals(user.getRole())) {
                req.setAttribute("error", "Invalid role for this account.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }
            
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            
            if ("STUDENT".equals(user.getRole())) {
                String studentId = userDAO.getStudentId(user.getUserId());
                String studentType = userDAO.getStudentType(user.getUserId());
                user.setStudentId(studentId);
                user.setStudentType(studentType);
                session.setAttribute("studentId", studentId);
                session.setAttribute("studentType", studentType);
                resp.sendRedirect("student/dashboard");
            } else if ("RESEARCHER".equals(user.getRole())) {
                resp.sendRedirect("repository");
            } else {
                session.setAttribute("supervisorId", userDAO.getSupervisorId(user.getUserId()));
                resp.sendRedirect("supervisor/dashboard");
            }
        } else {
            req.setAttribute("error", "Invalid username or password");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
