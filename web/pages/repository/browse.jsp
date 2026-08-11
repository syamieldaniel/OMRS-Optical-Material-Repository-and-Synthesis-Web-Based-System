<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Repository - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; }
        
        .glass { background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(20px); border: 1px solid rgba(167, 139, 250, 0.2); box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08); }
        
        .sidebar {
            background: linear-gradient(180deg, #7c3aed 0%, #6d28d9 100%);
            border-right: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .nav-item {
            transition: all 0.3s ease;
            color: #ffffff;
            font-weight: 500;
            font-size: 0.95rem;
            letter-spacing: 0.3px;
        }
        .nav-item:hover, .nav-item.active {
            background: rgba(255, 255, 255, 0.15);
            color: #ffffff;
            border-left: 3px solid #fbbf24;
            font-weight: 600;
        }
        
        .repo-header,
        .experiment-card {
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.14);
            box-shadow: 0 10px 28px rgba(88, 28, 135, 0.08);
        }
        .experiment-card {
            min-height: 15rem;
            transition: all 0.2s ease;
        }
        .experiment-card:hover { 
            transform: translateY(-2px); 
            box-shadow: 0 16px 34px rgba(88, 28, 135, 0.12);
            border-color: rgba(124, 58, 237, 0.30);
        }
        .material-badge {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.35rem 0.75rem;
            background: #f5f3ff;
            color: #5b21b6;
            font-size: 0.78rem;
            font-weight: 800;
        }
        .repo-meta {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            color: #4b5563;
            font-size: 0.85rem;
            font-weight: 700;
        }
        .pagination-btn {
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.16);
            color: #5b21b6;
        }
        .pagination-btn.active {
            background: #7c3aed;
            color: #ffffff;
            border-color: #7c3aed;
        }
        .pagination-btn:disabled { opacity: 0.5; cursor: not-allowed; }
    </style>
</head>
<body class="min-h-screen">
    <% 
        User user = (User) session.getAttribute("user");
        List<Experiment> experiments = (List<Experiment>) request.getAttribute("experiments");
        Map<String, Integer> commentCounts = (Map<String, Integer>) request.getAttribute("commentCounts");
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        Integer totalPages = (Integer) request.getAttribute("totalPages");
        Integer totalCount = (Integer) request.getAttribute("totalCount");
        
        if (currentPage == null) currentPage = 1;
        if (totalPages == null) totalPages = 1;
        if (totalCount == null) totalCount = experiments != null ? experiments.size() : 0;
    %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            
            <!-- Page Header -->
            <div class="repo-header rounded-2xl p-6 lg:p-8 mb-8">
                <div class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4">
                    <div>
                        <p class="text-sm font-semibold text-purple-700 mb-2">Repository Browse</p>
                        <h1 class="text-3xl font-bold text-gray-900 mb-2">Browse Experiments</h1>
                        <p class="text-gray-700">Explore approved optical material experiments and characterization records.</p>
                    </div>
                    <div class="rounded-xl bg-purple-50 border border-purple-100 px-4 py-3 text-purple-700 font-semibold w-fit">
                        Showing <%= experiments != null ? experiments.size() : 0 %> of <%= totalCount %>
                    </div>
                </div>
            </div>
            
            <!-- Experiments Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-10">
                <% if (experiments != null && !experiments.isEmpty()) {
                    for (Experiment exp : experiments) {
                %>
                <a href="${pageContext.request.contextPath}/repository/view/<%= exp.getExperimentId() %>" class="experiment-card rounded-2xl p-6 transition flex flex-col">
                    <div class="mb-4">
                        <span class="material-badge badge-<%= exp.getMaterialType() != null ? exp.getMaterialType().toLowerCase() : "other" %>">
                            <%= exp.getMaterialType() != null ? exp.getMaterialType() : "Unknown" %>
                        </span>
                    </div>
                    <h3 class="text-lg font-semibold text-gray-900 line-clamp-2 mb-3"><%= exp.getTitle() %></h3>
                    <p class="text-gray-700 text-sm line-clamp-3 mb-4 flex-1"><%= exp.getPreparationNotes() != null ? exp.getPreparationNotes().substring(0, Math.min(150, exp.getPreparationNotes().length())) : "No description" %></p>
                    <div class="pt-4 border-t border-purple-100 flex items-center justify-between">
                        <span class="text-purple-600 text-sm font-medium">View Details</span>
                        <span class="repo-meta">
                            <i class="fas fa-comments mr-1 text-purple-500"></i>
                            <%= commentCounts != null ? commentCounts.getOrDefault(exp.getExperimentId(), 0) : 0 %>
                        </span>
                    </div>
                </a>
                <% } 
                } else { %>
                <div class="col-span-full text-center py-16 repo-header rounded-2xl">
                    <i class="fas fa-inbox text-5xl text-purple-300 mb-4"></i>
                    <p class="text-gray-700 text-lg">No experiments found</p>
                </div>
                <% } %>
            </div>
            
            <!-- Pagination -->
            <% if (totalPages > 1) { %>
            <div class="flex items-center justify-center gap-2 flex-wrap">
                <% if (currentPage > 1) { %>
                <a href="?page=<%= currentPage - 1 %>" class="pagination-btn px-3 py-2 rounded-lg text-gray-900">
                    <i class="fas fa-chevron-left"></i>
                </a>
                <% } %>
                
                <% for (int i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) { %>
                    <% if (i == currentPage) { %>
                    <button class="pagination-btn active px-4 py-2 rounded-lg font-medium"><%= i %></button>
                    <% } else { %>
                    <a href="?page=<%= i %>" class="pagination-btn px-4 py-2 rounded-lg text-gray-900"><%= i %></a>
                    <% } %>
                <% } %>
                
                <% if (currentPage < totalPages) { %>
                <a href="?page=<%= currentPage + 1 %>" class="pagination-btn px-3 py-2 rounded-lg text-gray-900">
                    <i class="fas fa-chevron-right"></i>
                </a>
                <% } %>
            </div>
            <% } %>
            
        </main>
    </div>

    <script>
        function toggleDropdown(event, dropdownId) {
            event.preventDefault();
            event.stopPropagation();
            const dropdown = document.getElementById(dropdownId);
            dropdown.classList.toggle('hidden');
        }
        
        // Close dropdowns when clicking outside
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.group')) {
                document.querySelectorAll('[id^="repo-dropdown"]').forEach(dropdown => {
                    dropdown.classList.add('hidden');
                });
            }
        });
    </script>
<%@ include file="../common/system-chatbot.jsp" %>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>




