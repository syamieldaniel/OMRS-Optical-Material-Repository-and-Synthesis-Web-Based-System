package com.omrs.servlet;

import com.omrs.dao.NotificationDAO;
import com.omrs.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    private NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        req.setAttribute("notifications", notificationDAO.getByUser(user.getUserId()));
        req.setAttribute("unreadCount", notificationDAO.getUnreadCount(user.getUserId()));
        req.getRequestDispatcher("/pages/notifications.jsp").forward(req, resp);
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
        if ("markAllRead".equals(action)) {
            notificationDAO.markAllAsRead(user.getUserId());
        } else if ("markRead".equals(action)) {
            notificationDAO.markAsRead(req.getParameter("notificationId"), user.getUserId());
        }

        resp.sendRedirect(req.getContextPath() + "/notifications");
    }
}
