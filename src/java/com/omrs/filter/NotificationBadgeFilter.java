package com.omrs.filter;

import com.omrs.dao.NotificationDAO;
import com.omrs.model.User;
import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

@WebFilter("/*")
public class NotificationBadgeFilter implements Filter {
    private NotificationDAO notificationDAO;

    @Override
    public void init(FilterConfig filterConfig) {
        notificationDAO = new NotificationDAO();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest) {
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            HttpSession session = httpRequest.getSession(false);
            String path = httpRequest.getServletPath();

            if (session != null && session.getAttribute("user") instanceof User && shouldCheck(path)) {
                User user = (User) session.getAttribute("user");
                request.setAttribute("unreadNotificationCount", notificationDAO.getUnreadCount(user.getUserId()));
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }

    private boolean shouldCheck(String path) {
        return path == null
                || !(path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/img/")
                || path.startsWith("/uploads/")
                || path.startsWith("/api/"));
    }
}
