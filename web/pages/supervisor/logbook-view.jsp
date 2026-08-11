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
    <title>Review Logbook - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; }
        .glass { background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(20px); border: 1px solid rgba(167, 139, 250, 0.2); box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08); }
        .badge-approved { background: #d1fae5; color: #065f46; }
        .badge-pending { background: #fef3c7; color: #92400e; }
        .note { background: #fef9c3; border-left: 4px solid #eab308; padding: 1rem; border-radius: 0.5rem; }
        .supervisor-badge { background: #fce7f3; color: #831843; }
        .student-badge { background: #f3e8ff; color: #5b21b6; }
        .sidebar { background: linear-gradient(180deg, #7c3aed 0%, #6d28d9 100%); border-right: 1px solid rgba(0, 0, 0, 0.1); }
        .nav-item { transition: all 0.3s ease; color: #ffffff; font-weight: 500; font-size: 0.95rem; letter-spacing: 0.3px; }
        .nav-item:hover, .nav-item.active { background: rgba(255, 255, 255, 0.15); color: #ffffff; border-left: 3px solid #fbbf24; font-weight: 600; }
    </style>
</head>
<body class="min-h-screen">
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

            <div class="max-w-5xl mx-auto px-4 py-8">
        <!-- Header -->
        <div class="mb-8">
            <a href="<%= request.getContextPath() %>/logbook/dashboard" class="text-purple-600 hover:text-purple-800 mb-4 inline-block">
                <i class="fas fa-arrow-left mr-2"></i>Back to Logbooks
            </a>
            <div class="flex justify-between items-start">
                <div>
                    <h1 class="text-3xl font-bold text-gray-800 mb-2"><%= logbook.getTitle() %></h1>
                    <div class="flex items-center gap-4">
                        <% String statusClass = logbook.isApproved() ? "badge-approved" : "badge-pending"; %>
                        <span class="<%= statusClass %> px-3 py-1 rounded-full text-sm font-semibold">
                            <%= logbook.getStatus() %>
                        </span>
                        <span class="student-badge px-3 py-1 rounded-full text-sm">
                            <i class="fas fa-user-graduate mr-1"></i><%= logbook.getStudentName() %>
                        </span>
                        <span class="text-gray-600"><i class="fas fa-calendar mr-2"></i><%= logbook.getEntryDate() %></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="glass rounded-lg p-8 mb-8">
            <h2 class="text-lg font-semibold text-gray-800 mb-4">Research Activities</h2>
            <div class="prose prose-sm max-w-none">
                <div class="text-gray-700 whitespace-pre-wrap bg-gray-50 p-4 rounded border border-gray-200">
                    <%= logbook.getContent() != null && !logbook.getContent().isEmpty() ? logbook.getContent() : "<em class='text-gray-400'>No activities recorded</em>" %>
                </div>
            </div>
        </div>

        <!-- Supervisor Notes Section -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Main Notes Area -->
            <div class="lg:col-span-2">
                <div class="glass rounded-lg p-8">
                    <h3 class="text-xl font-semibold text-gray-800 mb-6">
                        <i class="fas fa-sticky-note mr-2 text-yellow-600"></i>Supervisor Notes & Feedback
                    </h3>

                    <!-- Current Notes -->
                    <% if (logbook.getSupervisorNotes() != null && !logbook.getSupervisorNotes().isEmpty()) { %>
                        <div class="note mb-8">
                            <p class="font-semibold text-gray-800 mb-2">Notes from <%= logbook.getSupervisorName() %></p>
                            <p class="text-gray-700"><%= logbook.getSupervisorNotes() %></p>
                        </div>
                    <% } else { %>
                        <p class="text-gray-500 text-center py-8 mb-8">No notes added yet</p>
                    <% } %>

                    <!-- Add Notes Form (if not approved) -->
                    <% if (!logbook.isApproved()) { %>
                        <div class="border-t border-gray-300 pt-6">
                            <h4 class="font-semibold text-gray-800 mb-4">
                                <i class="fas fa-pen mr-2 text-yellow-600"></i>Add Notes
                            </h4>
                            <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="space-y-4">
                                <input type="hidden" name="action" value="note">
                                <input type="hidden" name="studentId" value="<%= logbook.getStudentId() %>">
                                <input type="hidden" name="week" value="<%= logbook.getWeek() %>">
                                <input type="hidden" name="month" value="<%= logbook.getMonth() %>">
                                
                                <textarea name="notes" placeholder="Add supervisor notes or feedback..." required rows="4"
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-yellow-500"></textarea>
                                
                                <button type="submit" class="bg-yellow-600 text-white px-6 py-2 rounded-lg hover:bg-yellow-700 transition">
                                    <i class="fas fa-save mr-2"></i>Save Notes
                                </button>
                            </form>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Approval Section -->
            <div class="lg:col-span-1">
                <div class="glass rounded-lg p-8 sticky top-24">
                    <h3 class="text-lg font-semibold text-gray-800 mb-6">
                        <i class="fas fa-check-circle mr-2 text-green-600"></i>Approval Status
                    </h3>

                    <% if (logbook.isApproved()) { %>
                        <!-- Approved Info -->
                        <div class="bg-green-50 border border-green-300 rounded-lg p-4 mb-6">
                            <p class="text-green-800 font-semibold mb-2">
                                <i class="fas fa-check-circle text-green-600 mr-2"></i>Week <%= logbook.getWeek() %> Approved
                            </p>
                            <div class="text-sm text-gray-700 space-y-2">
                                <p><strong>Approved By:</strong> <%= logbook.getSupervisorName() %></p>
                                <p><strong>Signature:</strong> <%= logbook.getSupervisorSignature() %></p>
                                <p><strong>Date:</strong> <%= logbook.getApprovedDate() %></p>
                            </div>
                        </div>
                    <% } else { %>
                        <!-- Approval Form -->
                        <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="space-y-4">
                            <input type="hidden" name="action" value="approve">
                            <input type="hidden" name="studentId" value="<%= logbook.getStudentId() %>">
                            <input type="hidden" name="week" value="<%= logbook.getWeek() %>">
                            <input type="hidden" name="month" value="<%= logbook.getMonth() %>">
                            
                            <div>
                                <label class="block text-sm font-semibold text-gray-800 mb-2">
                                    Your Signature
                                </label>
                                <input type="text" name="signature" placeholder="Enter your signature" required
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                            </div>
                            
                            <button type="submit" class="w-full bg-green-600 text-white px-4 py-3 rounded-lg hover:bg-green-700 transition font-semibold">
                                <i class="fas fa-check mr-2"></i>Approve Week <%= logbook.getWeek() %>
                            </button>
                        </form>
                    <% } %>

                    <!-- Metadata -->
                    <div class="mt-6 pt-6 border-t border-gray-300">
                        <p class="text-xs text-gray-600 mb-2">
                            <strong>Logbook ID:</strong> <%= logbook.getLogbookId() %>
                        </p>
                        <p class="text-xs text-gray-600">
                            <strong>Created:</strong> <%= logbook.getCreatedAt() %>
                        </p>
                    </div>
                </div>
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



