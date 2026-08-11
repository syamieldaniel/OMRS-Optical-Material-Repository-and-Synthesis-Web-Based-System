package com.omrs.servlet;

import com.omrs.dao.LogbookDAO;
import com.omrs.dao.UserDAO;
import com.omrs.model.Logbook;
import com.omrs.model.User;
import java.io.IOException;
import java.time.YearMonth;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/logbook/*")
public class LogbookServlet extends HttpServlet {
    private LogbookDAO dao = new LogbookDAO();
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String path = req.getPathInfo();
        String month = req.getParameter("month");
        if (month == null || month.isEmpty()) {
            month = YearMonth.now().toString();
        }
        
        // STUDENT routes
        if ("STUDENT".equals(user.getRole())) {
            String studentId = (String) session.getAttribute("studentId");
            String studentType = (String) session.getAttribute("studentType");
            if (studentType == null || studentType.trim().isEmpty()) {
                studentType = userDAO.getStudentType(user.getUserId());
                user.setStudentType(studentType);
                session.setAttribute("studentType", studentType);
            }
            if (!"FYP".equals(studentType)) {
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
                return;
            }
            
            if (path == null || path.equals("/") || path.equals("/dashboard")) {
                List<Logbook> logbooks = dao.getByStudentAndMonth(studentId, month);
                // Ensure all 5 weeks are present
                for (int i = 1; i <= 5; i++) {
                    boolean found = false;
                    for (Logbook lb : logbooks) {
                        if (lb.getWeek() == i) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        Logbook empty = new Logbook();
                        empty.setStudentId(studentId);
                        empty.setMonth(month);
                        empty.setWeek(i);
                        logbooks.add(empty);
                    }
                }
                java.util.Collections.sort(logbooks, (a, b) -> Integer.compare(a.getWeek(), b.getWeek()));
                
                req.setAttribute("logbooks", logbooks);
                req.setAttribute("month", month);
                req.getRequestDispatcher("/pages/student/logbook-dashboard.jsp").forward(req, resp);
            }
        }
        
        // SUPERVISOR routes
        else if ("SUPERVISOR".equals(user.getRole())) {
            String supervisorId = (String) session.getAttribute("supervisorId");
            
            if (path == null || path.equals("/") || path.equals("/dashboard")) {
                List<Logbook> logbooks = dao.getBySupervisorAndMonth(supervisorId, month);
                req.setAttribute("logbooks", logbooks);
                req.setAttribute("month", month);
                req.getRequestDispatcher("/pages/supervisor/logbook-dashboard.jsp").forward(req, resp);
            } else if (path.startsWith("/view/")) {
                // View individual logbook
                String logbookId = path.substring(6); // Remove "/view/" prefix
                Logbook logbook = dao.getById(logbookId);
                
                if (logbook != null) {
                    req.setAttribute("logbook", logbook);
                    req.getRequestDispatcher("/pages/supervisor/logbook-view.jsp").forward(req, resp);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/logbook/dashboard");
                }
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
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
        String action = req.getParameter("action");
        String month = req.getParameter("month");
        
        if ("STUDENT".equals(user.getRole())) {
            String studentId = (String) session.getAttribute("studentId");
            String studentType = (String) session.getAttribute("studentType");
            if (studentType == null || studentType.trim().isEmpty()) {
                studentType = userDAO.getStudentType(user.getUserId());
                user.setStudentType(studentType);
                session.setAttribute("studentType", studentType);
            }
            if (!"FYP".equals(studentType)) {
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
                return;
            }
            
            if ("save".equals(action)) {
                handleSaveWeekly(req, resp, studentId, month);
            }
        }
        
        else if ("SUPERVISOR".equals(user.getRole())) {
            String supervisorId = (String) session.getAttribute("supervisorId");
            String supervisorName = user.getFullName();
            
            if ("approve".equals(action)) {
                handleApprove(req, resp, supervisorName, month);
            } else if ("note".equals(action)) {
                handleAddNote(req, resp, month);
            }
        }
    }
    
    private void handleSaveWeekly(HttpServletRequest req, HttpServletResponse resp, String studentId, String month) throws IOException, ServletException {
        int week = Integer.parseInt(req.getParameter("week"));
        String activities = req.getParameter("activities");
        
        Logbook logbook = dao.getByStudentMonthWeek(studentId, month, week);
        
        if (logbook == null) {
            logbook = new Logbook();
            logbook.setStudentId(studentId);
            logbook.setMonth(month);
            logbook.setWeek(week);
        }
        
        logbook.setActivities(activities);
        
        if (dao.createOrUpdate(logbook)) {
            resp.sendRedirect(req.getContextPath() + "/logbook/dashboard?month=" + month);
        } else {
            req.setAttribute("error", "Failed to save week " + week);
            resp.sendRedirect(req.getContextPath() + "/logbook/dashboard?month=" + month);
        }
    }
    
    private void handleApprove(HttpServletRequest req, HttpServletResponse resp, String supervisorName, String month) throws IOException {
        String studentId = req.getParameter("studentId");
        int week = Integer.parseInt(req.getParameter("week"));
        String signature = req.getParameter("signature");
        
        if (dao.approve(studentId, month, week, supervisorName, signature)) {
            resp.sendRedirect(req.getContextPath() + "/logbook/dashboard?month=" + month);
        } else {
            resp.sendRedirect(req.getContextPath() + "/logbook/dashboard?month=" + month);
        }
    }
    
    private void handleAddNote(HttpServletRequest req, HttpServletResponse resp, String month) throws IOException {
        String studentId = req.getParameter("studentId");
        int week = Integer.parseInt(req.getParameter("week"));
        String notes = req.getParameter("notes");
        
        if (dao.addNotes(studentId, month, week, notes)) {
            resp.sendRedirect(req.getContextPath() + "/logbook/dashboard?month=" + month);
        } else {
            resp.sendRedirect(req.getContextPath() + "/logbook/dashboard?month=" + month);
        }
    }
}
