package com.omrs.servlet;

import com.omrs.dao.ExperimentDAO;
import com.omrs.dao.NotificationDAO;
import com.omrs.dao.UserDAO;
import com.omrs.model.Experiment;
import com.omrs.model.User;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/supervisor/*")
public class SupervisorServlet extends HttpServlet {
    private ExperimentDAO experimentDAO = new ExperimentDAO();
    private UserDAO userDAO = new UserDAO();
    private NotificationDAO notificationDAO = new NotificationDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"SUPERVISOR".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        String supervisorId = userDAO.getSupervisorId(user.getUserId());
        if (supervisorId == null) {
            req.setAttribute("error", "Supervisor profile not found.");
            req.getRequestDispatcher("/pages/supervisor/dashboard.jsp").forward(req, resp);
            return;
        }
        
        session.setAttribute("supervisorId", supervisorId);
        String path = req.getPathInfo();
        
        if (path == null || path.equals("/") || path.equals("/dashboard")) {
            List<Experiment> pending = experimentDAO.getPending(supervisorId);
            List<Experiment> supervisorExperiments = experimentDAO.getBySupervisor(supervisorId);
            int[] stats = experimentDAO.getSupervisorStats(supervisorId);
            int pendingApplications = userDAO.countPendingStudents(supervisorId);
            List<User> approvedStudents = userDAO.getApprovedStudents(supervisorId);
            req.setAttribute("pendingList", pending);
            req.setAttribute("experimentList", supervisorExperiments);
            req.setAttribute("pendingCount", pending.size());
            req.setAttribute("approvedCount", stats[1]);
            req.setAttribute("studentCount", stats[2]);
            req.setAttribute("pendingApplications", pendingApplications);
            req.setAttribute("approvedStudents", approvedStudents);
            req.getRequestDispatcher("/pages/supervisor/dashboard.jsp").forward(req, resp);
            
        } else if (path.equals("/students")) {
            List<User> allStudents = userDAO.getAllStudents(supervisorId);
            req.setAttribute("students", allStudents);
            req.getRequestDispatcher("/pages/supervisor/students.jsp").forward(req, resp);
            
        } else if (path.startsWith("/review/")) {
            String id = path.substring(8);
            req.setAttribute("experiment", experimentDAO.getById(id));
            req.getRequestDispatcher("/pages/supervisor/review.jsp").forward(req, resp);
        } else if (path.startsWith("/student/")) {
            String studentIdentifier = path.substring(9);
            try {
                User student;
                if (studentIdentifier.matches("\\d+")) {
                    int studentUserId = Integer.parseInt(studentIdentifier);
                    student = userDAO.getStudentByUserIdAndSupervisor(studentUserId, supervisorId);
                } else {
                    student = userDAO.getStudentByStudentId(studentIdentifier);
                }
                if (student != null && "STUDENT".equals(student.getRole())) {
                    try {
                        String supervisorName = userDAO.getSupervisorName(supervisorId);
                        List<Experiment> studentExperiments = experimentDAO.getByStudent(student.getStudentId());
                        req.setAttribute("student", student);
                        req.setAttribute("studentId", student.getStudentId());
                        req.setAttribute("supervisorName", supervisorName);
                        req.setAttribute("studentExperiments", studentExperiments);
                    } catch (Exception e) {
                        e.printStackTrace();
                        // Set defaults if DAO calls fail
                        List<Experiment> studentExperiments = experimentDAO.getByStudent(student.getStudentId());
                        req.setAttribute("student", student);
                        req.setAttribute("studentId", student.getStudentId() != null ? student.getStudentId() : "N/A");
                        req.setAttribute("supervisorName", "N/A");
                        req.setAttribute("studentExperiments", studentExperiments);
                    }
                    req.getRequestDispatcher("/pages/supervisor/student_profile.jsp").forward(req, resp);
                } else {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"SUPERVISOR".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        String path = req.getPathInfo();
        
        if (path != null && path.startsWith("/review/")) {
            try {
                String id = path.substring(8);
                String action = req.getParameter("action");
                String feedback = req.getParameter("feedback");
                
                if (id == null || id.isEmpty() || action == null || action.isEmpty()) {
                    req.setAttribute("error", "Invalid review parameters.");
                    resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard");
                    return;
                }
                
                Experiment e = experimentDAO.getById(id);
                if (e == null) {
                    req.setAttribute("error", "Experiment not found.");
                    resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard");
                    return;
                }
                
                e.setFeedback(feedback != null ? feedback : "");
                String newStatus = "approve".equals(action) ? "APPROVED" : "REJECTED";
                e.setStatus(newStatus);
                boolean success = experimentDAO.update(e);
                
                if (success) {
                    notifyStudentAboutReview(e, newStatus, feedback);
                    resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard?success=true");
                } else {
                    req.setAttribute("error", "Failed to update experiment status.");
                    resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard");
                }
            } catch (Exception e) {
                e.printStackTrace();
                req.setAttribute("error", "An error occurred: " + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard");
        }
    }

    private void notifyStudentAboutReview(Experiment experiment, String status, String feedback) {
        Integer ownerUserId = experimentDAO.getOwnerUserId(experiment.getExperimentId());
        if (ownerUserId == null) return;

        boolean approved = "APPROVED".equals(status);
        String title = approved ? "Experiment approved" : "Experiment rejected";
        String message = "Your experiment \"" + experiment.getTitle() + "\" was " + status.toLowerCase() + ".";
        if (feedback != null && !feedback.trim().isEmpty()) {
            message += " Feedback: " + feedback.trim();
        }

        notificationDAO.create(
            ownerUserId,
            title,
            message,
            "/student/view/" + experiment.getExperimentId()
        );
    }
}
