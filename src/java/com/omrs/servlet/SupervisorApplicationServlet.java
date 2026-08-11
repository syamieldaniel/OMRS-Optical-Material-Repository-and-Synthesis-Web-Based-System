package com.omrs.servlet;

import com.omrs.dao.UserDAO;
import com.omrs.model.User;
import com.omrs.util.EmailUtil;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/supervisor/applications")
public class SupervisorApplicationServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"SUPERVISOR".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        Object flashSuccess = session.getAttribute("success");
        Object flashError = session.getAttribute("error");
        if (flashSuccess != null) {
            req.setAttribute("success", flashSuccess);
            session.removeAttribute("success");
        }
        if (flashError != null) {
            req.setAttribute("error", flashError);
            session.removeAttribute("error");
        }
        
        String supervisorId = userDAO.getSupervisorId(user.getUserId());
        if (supervisorId == null) {
            req.setAttribute("error", "Supervisor profile not found. Please contact admin.");
            req.getRequestDispatcher("/pages/supervisor/applications.jsp").forward(req, resp);
            return;
        }
        List<User> pendingStudents = userDAO.getPendingStudents(supervisorId);
        if (pendingStudents == null) {
            pendingStudents = new java.util.ArrayList<>();
        }
        req.setAttribute("pendingStudents", pendingStudents);
        req.getRequestDispatcher("/pages/supervisor/applications.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"SUPERVISOR".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }
        
        try {
            String userIdStr = req.getParameter("userId");
            String action = req.getParameter("action");
            
            if (userIdStr == null || userIdStr.isEmpty() || action == null || action.isEmpty()) {
                req.setAttribute("error", "Invalid request parameters.");
                doGet(req, resp);
                return;
            }
            
            int studentId = Integer.parseInt(userIdStr);
            String status = "approve".equals(action) ? "APPROVED" : "REJECTED";
            String supervisorId = userDAO.getSupervisorId(user.getUserId());
            if (supervisorId == null) {
                session.setAttribute("error", "Supervisor profile not found.");
                resp.sendRedirect(req.getContextPath() + "/supervisor/applications");
                return;
            }
            
            boolean success = userDAO.updateUserStatusForSupervisorStudent(studentId, supervisorId, status);
            if (success) {
                String message = "Student " + action + "d successfully.";
                if ("APPROVED".equals(status)) {
                    User approvedStudent = userDAO.getUserById(studentId);
                    if (approvedStudent != null) {
                        boolean emailSent = EmailUtil.sendStudentApprovalEmail(
                                getServletContext(),
                                approvedStudent.getEmail(),
                                displayName(approvedStudent),
                                buildLoginLink(req));
                        if (!emailSent) {
                            message += " Approval email could not be sent. Please check SMTP settings.";
                        }
                    }
                }
                session.setAttribute("success", message);
                resp.sendRedirect(req.getContextPath() + "/supervisor/applications");
            } else {
                session.setAttribute("error", "Failed to update status. Please verify that the student belongs to your supervision list.");
                resp.sendRedirect(req.getContextPath() + "/supervisor/applications");
            }
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid user ID format.");
            doGet(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "An error occurred: " + e.getMessage());
            doGet(req, resp);
        }
    }

    private String buildLoginLink(HttpServletRequest req) {
        String base = req.getScheme() + "://" + req.getServerName();
        int port = req.getServerPort();
        boolean defaultPort = ("http".equals(req.getScheme()) && port == 80)
                || ("https".equals(req.getScheme()) && port == 443);
        if (!defaultPort) {
            base += ":" + port;
        }
        return base + req.getContextPath() + "/login";
    }

    private String displayName(User user) {
        if (user.getFullName() != null && !user.getFullName().trim().isEmpty()) {
            return user.getFullName();
        }
        return user.getUsername();
    }
}
