<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.omrs.model.*, java.util.List" %>
<%
    Logbook logbook = (Logbook) request.getAttribute("logbook");
    User user = (User) session.getAttribute("user");
    if (logbook == null) {
        response.sendRedirect(request.getContextPath() + "/logbook/dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Logbook - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; }
        .glass { background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(20px); border: 1px solid rgba(167, 139, 250, 0.2); box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08); }
        .sidebar { background: linear-gradient(180deg, #7c3aed 0%, #6d28d9 100%); border-right: 1px solid rgba(0, 0, 0, 0.1); }
        .nav-item { transition: all 0.3s ease; color: #ffffff; font-weight: 500; font-size: 0.95rem; letter-spacing: 0.3px; }
        .nav-item:hover, .nav-item.active { background: rgba(255, 255, 255, 0.15); color: #ffffff; border-left: 3px solid #fbbf24; font-weight: 600; }
        .badge-draft { background: #fef3c7; color: #92400e; }
        .badge-submitted { background: #dbeafe; color: #1e40af; }
        .badge-reviewed { background: #d1fae5; color: #065f46; }
        .comment { background: #f9fafb; border-left: 4px solid #7c3aed; }
        .note { background: #fffbeb; border-left: 4px solid #f59e0b; }
    </style>
</head>
<body class="min-h-screen">
    <% User user = (User) session.getAttribute("user"); %>
    
    <div class="flex min-h-screen">
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>

        <!-- Main Content -->
        <div class="flex-1 lg:ml-64">
            <!-- Top Nav for Mobile -->
            <nav class="glass shadow-sm sticky top-0 z-40 lg:hidden">
                <div class="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
                    <h1 class="text-xl font-bold text-purple-700">OMRS</h1>
                    <div class="flex items-center gap-4">
                        <a href="<%= request.getContextPath() %>/logout" class="text-gray-700 hover:text-red-600">
                            <i class="fas fa-sign-out-alt"></i>
                        </a>
                    </div>
                </div>
            </nav>

            <div class="max-w-4xl mx-auto px-4 py-8">
        <!-- Header -->
        <div class="flex justify-between items-start mb-6">
            <div>
                <a href="<%= request.getContextPath() %>/logbook/dashboard" class="text-purple-600 hover:text-purple-800 mb-4 inline-block">
                    <i class="fas fa-arrow-left mr-2"></i>Back to Logbooks
                </a>
                <h1 class="text-3xl font-bold text-gray-800 mb-2"><%= logbook.getTitle() %></h1>
                <div class="flex items-center gap-4">
                    <span class="badge-<%= logbook.getStatus().toLowerCase() %> px-3 py-1 rounded-full text-sm font-semibold">
                        <%= logbook.getStatus() %>
                    </span>
                    <span class="text-gray-600"><i class="fas fa-calendar mr-2"></i><%= logbook.getEntryDate() %></span>
                </div>
            </div>
            <% if ("STUDENT".equals(user.getRole()) && "DRAFT".equals(logbook.getStatus())) { %>
                <div class="flex gap-2">
                    <a href="<%= request.getContextPath() %>/logbook/edit/<%= logbook.getLogbookId() %>" class="bg-yellow-600 text-white px-4 py-2 rounded-lg hover:bg-yellow-700 transition">
                        <i class="fas fa-edit mr-2"></i>Edit
                    </a>
                </div>
            <% } %>
        </div>

        <!-- Main Content -->
        <div class="glass rounded-lg p-8 mb-8">
            <div class="prose prose-sm max-w-none">
                <div class="text-gray-700 whitespace-pre-wrap"><%= logbook.getContent() %></div>
            </div>
            
            <!-- Submit Button for Students -->
            <% if ("STUDENT".equals(user.getRole()) && "DRAFT".equals(logbook.getStatus())) { %>
                <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="mt-6">
                    <input type="hidden" name="action" value="submit">
                    <input type="hidden" name="logbookId" value="<%= logbook.getLogbookId() %>">
                    <button type="submit" class="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition">
                        <i class="fas fa-check mr-2"></i>Submit for Review
                    </button>
                </form>
            <% } %>
        </div>

        <!-- Comments and Notes Section -->
        <div class="glass rounded-lg p-8">
            <h3 class="text-xl font-semibold text-gray-800 mb-6">
                <i class="fas fa-comments mr-2 text-purple-600"></i>Comments & Notes
            </h3>

            <!-- Comments List -->
            <% if (logbook.getComments() != null && !logbook.getComments().isEmpty()) { %>
                <div class="space-y-4 mb-8">
                    <% for (LogbookComment comment : logbook.getComments()) { %>
                        <div class="<%= "NOTE".equals(comment.getCommentType()) ? "note" : "comment" %> p-4 rounded">
                            <div class="flex justify-between items-start mb-2">
                                <div>
                                    <p class="font-semibold text-gray-800"><%= comment.getUserName() %></p>
                                    <p class="text-xs text-gray-500">
                                        <% 
                                            String type = "NOTE".equals(comment.getCommentType()) ? "Note" : "Comment";
                                            out.print(type);
                                        %>
                                        • <%= comment.getCreatedAt() %>
                                    </p>
                                </div>
                            </div>
                            <p class="text-gray-700"><%= comment.getCommentText() %></p>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <p class="text-gray-500 text-center py-8">No comments or notes yet</p>
            <% } %>

            <!-- Add Comment Form for Supervisors -->
            <% if ("SUPERVISOR".equals(user.getRole()) && !("DRAFT".equals(logbook.getStatus()))) { %>
                <div class="border-t border-gray-300 pt-6">
                    <h4 class="font-semibold text-gray-800 mb-4">Add Comment</h4>
                    <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="space-y-4">
                        <input type="hidden" name="action" value="comment">
                        <input type="hidden" name="logbookId" value="<%= logbook.getLogbookId() %>">
                        
                        <textarea name="commentText" placeholder="Write your feedback here..." required rows="4"
                            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"></textarea>
                        
                        <button type="submit" class="bg-purple-600 text-white px-6 py-2 rounded-lg hover:bg-purple-700 transition">
                            <i class="fas fa-comment-dots mr-2"></i>Post Comment
                        </button>
                    </form>

                    <!-- Add Note Form -->
                    <h4 class="font-semibold text-gray-800 mt-6 mb-4">Add Internal Note</h4>
                    <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="space-y-4">
                        <input type="hidden" name="action" value="add-note">
                        <input type="hidden" name="logbookId" value="<%= logbook.getLogbookId() %>">
                        
                        <textarea name="noteText" placeholder="Write private notes for your records..." required rows="4"
                            class="w-full px-4 py-2 border border-yellow-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-yellow-500"></textarea>
                        
                        <button type="submit" class="bg-yellow-600 text-white px-6 py-2 rounded-lg hover:bg-yellow-700 transition">
                            <i class="fas fa-sticky-note mr-2"></i>Save Note
                        </button>
                    </form>
                </div>
            <% } %>
            </div>
            </div>
        </div>
    </div>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
<script>
function toggleDropdown(event, dropdownId) {
    event.preventDefault();
    event.stopPropagation();
    const dropdown = document.getElementById(dropdownId);
    const isHidden = dropdown.classList.contains('hidden');
    document.querySelectorAll('[id*="repo-dropdown"]').forEach(function(item) {
        if (item.id !== dropdownId) {
            item.classList.add('hidden');
        }
    });
    if (isHidden) {
        dropdown.classList.remove('hidden');
    } else {
        dropdown.classList.add('hidden');
    }
}

document.addEventListener('click', function() {
    document.querySelectorAll('[id*="repo-dropdown"]').forEach(function(item) {
        item.classList.add('hidden');
    });
});
</script>
</html>



