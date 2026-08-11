<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.omrs.model.*" %>
<%!
    private String h(Object value) {
        if (value == null) return "";
        return value.toString()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; }
        .sidebar { background: linear-gradient(180deg, #7c3aed 0%, #6d28d9 100%); }
        .nav-item { transition: all 0.3s ease; color: #ffffff; font-weight: 500; font-size: 0.95rem; letter-spacing: 0.3px; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,0.15); border-left: 3px solid #fbbf24; font-weight: 600; }
        .glass { background: rgba(255,255,255,0.9); border: 1px solid rgba(167,139,250,0.2); box-shadow: 0 8px 32px rgba(0,0,0,0.08); }
        .notification-card { background: #ffffff; border: 1.5px solid rgba(124,58,237,0.14); }
        .notification-card.unread { border-color: rgba(124,58,237,0.45); box-shadow: 0 8px 24px rgba(124,58,237,0.10); }
        .btn-primary { background: linear-gradient(135deg, #7c3aed, #a78bfa); color: #ffffff; }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
        Integer unreadCount = (Integer) request.getAttribute("unreadCount");
        if (unreadCount == null) unreadCount = 0;
        String dashboardHref = "STUDENT".equals(user.getRole()) ? request.getContextPath() + "/student/dashboard"
                : "SUPERVISOR".equals(user.getRole()) ? request.getContextPath() + "/supervisor/dashboard"
                : request.getContextPath() + "/repository";
    %>

    <div class="flex min-h-screen">
        <%@ include file="common/sidebar.jsp" %>

        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-8">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900 mb-2">Notifications</h1>
                    <p class="text-gray-700">Updates about repository comments and material activity</p>
                </div>
                <% if (unreadCount > 0) { %>
                <form method="POST" action="${pageContext.request.contextPath}/notifications">
                    <input type="hidden" name="action" value="markAllRead">
                    <button type="submit" class="btn-primary px-5 py-3 rounded-xl font-semibold">
                        <i class="fas fa-check-double mr-2"></i>Mark All Read
                    </button>
                </form>
                <% } %>
            </div>

            <div class="glass rounded-2xl p-6">
                <% if (notifications != null && !notifications.isEmpty()) {
                    for (Notification notification : notifications) {
                        String targetUrl = notification.getLinkUrl() != null && !notification.getLinkUrl().isEmpty()
                                ? request.getContextPath() + notification.getLinkUrl()
                                : request.getContextPath() + "/notifications";
                %>
                <div class="notification-card <%= notification.isRead() ? "" : "unread" %> rounded-xl p-5 mb-4">
                    <div class="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-4">
                        <a href="<%= targetUrl %>" class="block flex-1">
                            <div class="flex items-start gap-4">
                                <div class="w-11 h-11 rounded-xl <%= notification.isRead() ? "bg-gray-100 text-gray-500" : "bg-purple-100 text-purple-700" %> flex items-center justify-center">
                                    <i class="fas fa-bell"></i>
                                </div>
                                <div>
                                    <div class="flex flex-wrap items-center gap-2 mb-1">
                                        <h2 class="text-gray-900 font-semibold"><%= h(notification.getTitle()) %></h2>
                                        <% if (!notification.isRead()) { %>
                                        <span class="rounded-full bg-purple-100 px-2 py-0.5 text-xs font-semibold text-purple-700">New</span>
                                        <% } %>
                                    </div>
                                    <p class="text-gray-700"><%= h(notification.getMessage()) %></p>
                                    <p class="text-gray-500 text-xs mt-2"><%= notification.getCreatedAt() %></p>
                                </div>
                            </div>
                        </a>
                        <% if (!notification.isRead()) { %>
                        <form method="POST" action="${pageContext.request.contextPath}/notifications">
                            <input type="hidden" name="action" value="markRead">
                            <input type="hidden" name="notificationId" value="<%= notification.getNotificationId() %>">
                            <button type="submit" class="px-4 py-2 rounded-lg border border-purple-200 text-purple-700 hover:bg-purple-50 text-sm font-semibold">
                                Mark read
                            </button>
                        </form>
                        <% } %>
                    </div>
                </div>
                <%  }
                } else { %>
                <div class="text-center py-16">
                    <div class="w-20 h-20 rounded-2xl bg-purple-50 text-purple-300 flex items-center justify-center mx-auto mb-5">
                        <i class="fas fa-bell text-3xl"></i>
                    </div>
                    <h2 class="text-xl font-semibold text-gray-900 mb-2">No notifications yet</h2>
                    <p class="text-gray-700">Repository comment updates will appear here.</p>
                </div>
                <% } %>
            </div>
        </main>
    </div>

<%@ include file="common/sidebar-style.jsp" %>
</body>
</html>



