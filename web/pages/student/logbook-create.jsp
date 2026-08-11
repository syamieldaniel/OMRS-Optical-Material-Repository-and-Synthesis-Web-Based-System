<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate, com.omrs.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Logbook Entry - OMRS</title>
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
        textarea { resize: vertical; }
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
        <div class="mb-8">
            <h2 class="text-3xl font-bold text-gray-800">Create New Logbook Entry</h2>
            <p class="text-gray-600 mt-1">Record your daily activities and progress</p>
        </div>

        <!-- Error Message -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                <i class="fas fa-exclamation-circle mr-2"></i><%= request.getAttribute("error") %>
            </div>
        <% } %>

        <!-- Create Form -->
        <div class="glass rounded-lg p-8">
            <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="space-y-6">
                <input type="hidden" name="action" value="create">
                
                <!-- Entry Date -->
                <div>
                    <label class="block text-gray-700 font-semibold mb-2">
                        <i class="fas fa-calendar mr-2 text-purple-600"></i>Entry Date
                    </label>
                    <input type="date" name="entryDate" value="<%= LocalDate.now() %>" required 
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
                </div>
                
                <!-- Title -->
                <div>
                    <label class="block text-gray-700 font-semibold mb-2">
                        <i class="fas fa-heading mr-2 text-purple-600"></i>Title
                    </label>
                    <input type="text" name="title" placeholder="e.g., Day 1: Project Planning" required 
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                        maxlength="255">
                </div>
                
                <!-- Content -->
                <div>
                    <label class="block text-gray-700 font-semibold mb-2">
                        <i class="fas fa-pen mr-2 text-purple-600"></i>Content
                    </label>
                    <textarea name="content" placeholder="Write your daily log entry here..." required rows="10"
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"></textarea>
                    <p class="text-gray-500 text-sm mt-2">Describe your activities, findings, and progress</p>
                </div>
                
                <!-- Buttons -->
                <div class="flex gap-4 pt-4">
                    <button type="submit" class="bg-purple-600 text-white px-8 py-3 rounded-lg hover:bg-purple-700 transition font-medium">
                        <i class="fas fa-save mr-2"></i>Save as Draft
                    </button>
                    <a href="<%= request.getContextPath() %>/logbook/dashboard" class="bg-gray-400 text-white px-8 py-3 rounded-lg hover:bg-gray-500 transition font-medium">
                        <i class="fas fa-times mr-2"></i>Cancel
                    </a>
                </div>
            </form>
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



