<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Repository - OMRS</title>
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
        .experiment-card,
        .search-panel {
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
        
        .form-input, .form-select {
            background: rgba(255, 255, 255, 1);
            border: 1px solid rgba(168, 85, 247, 0.2);
            color: #2d3748;
            transition: all 0.3s ease;
            font-weight: 500;
        }
        .form-input:focus, .form-select:focus {
            border-color: #a78bfa;
            box-shadow: 0 0 0 3px rgba(167, 139, 250, 0.15);
            outline: none;
        }
        .form-input::placeholder {
            color: rgba(45, 55, 72, 0.6);
        }
        
        /* Style dropdown options */
        .form-select option {
            background: #ffffff;
            color: #2d3748;
        }
        .form-select option:checked {
            background: linear-gradient(135deg, #a78bfa, #d8b4fe);
            color: #1a202c;
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
    </style>
</head>
<body class="min-h-screen">
    <% 
        User user = (User) session.getAttribute("user");
        List<Experiment> experiments = (List<Experiment>) request.getAttribute("experiments");
        Map<String, Integer> commentCounts = (Map<String, Integer>) request.getAttribute("commentCounts");
        List<String> materialTypes = (List<String>) request.getAttribute("materialTypes");
        String keyword = (String) request.getAttribute("keyword");
        String selectedMaterial = (String) request.getAttribute("selectedMaterial");
        String dateFrom = (String) request.getAttribute("dateFrom");
        String dateTo = (String) request.getAttribute("dateTo");
        String selectedTestType = (String) request.getAttribute("selectedTestType");
        Integer resultCount = (Integer) request.getAttribute("resultCount");
        
        if (keyword == null) keyword = "";
        if (selectedMaterial == null) selectedMaterial = "";
        if (dateFrom == null) dateFrom = "";
        if (dateTo == null) dateTo = "";
        if (selectedTestType == null) selectedTestType = "";
    %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            
            <!-- Page Header -->
            <div class="repo-header rounded-2xl p-6 lg:p-8 mb-8">
                <p class="text-sm font-semibold text-purple-700 mb-2">Repository Search</p>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">Search Experiments</h1>
                <p class="text-gray-700">Find approved experiments by keyword, material, or experiment date.</p>
            </div>
            
            <!-- Search Form -->
            <form method="GET" action="${pageContext.request.contextPath}/repository/search" class="search-panel rounded-2xl p-6 lg:p-8 mb-10">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    <div>
                        <label class="block text-gray-900 font-medium mb-2">Keyword</label>
                        <input type="text" name="keyword" value="<%= keyword %>" placeholder="Search title, description, or keywords..." class="w-full form-input px-4 py-3 rounded-lg">
                    </div>
                    
                    <div>
                        <label class="block text-gray-900 font-medium mb-2">Material Type</label>
                        <select name="material" class="w-full form-select px-4 py-3 rounded-lg">
                            <option value="">All Materials</option>
                            <% if (materialTypes != null) {
                                for (String material : materialTypes) {
                            %>
                            <option value="<%= material %>" <%= material.equals(selectedMaterial) ? "selected" : "" %>><%= material %></option>
                            <% } } %>
                        </select>
                    </div>
                    
                    <div>
                        <label class="block text-gray-900 font-medium mb-2">From Date</label>
                        <input type="date" name="dateFrom" value="<%= dateFrom %>" class="w-full form-input px-4 py-3 rounded-lg">
                    </div>
                    
                    <div>
                        <label class="block text-gray-900 font-medium mb-2">To Date</label>
                        <input type="date" name="dateTo" value="<%= dateTo %>" class="w-full form-input px-4 py-3 rounded-lg">
                    </div>
                </div>
                
                <div class="flex flex-col sm:flex-row gap-3">
                    <button type="submit" class="px-6 py-3 rounded-xl font-semibold text-white transition bg-purple-600 hover:bg-purple-700">
                        <i class="fas fa-search mr-2"></i>Search
                    </button>
                    <a href="${pageContext.request.contextPath}/repository/search" class="px-6 py-3 rounded-xl font-semibold text-purple-700 hover:text-purple-900 transition bg-purple-50 border border-purple-100 text-center">
                        Clear
                    </a>
                </div>
            </form>
            
            <!-- Results -->
            <% if (keyword.length() > 0 || selectedMaterial.length() > 0) { %>
            <div class="mb-8">
                <p class="text-gray-700 text-sm">
                    Found <strong class="text-purple-600"><%= resultCount != null ? resultCount : 0 %></strong> experiment<%= (resultCount != null && resultCount != 1) ? "s" : "" %>
                </p>
            </div>
            <% } %>
            
            <!-- Results Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
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
                    <div class="pt-4 border-t border-gray-200 flex items-center justify-between">
                        <span class="text-purple-600 text-sm font-medium">View Details</span>
                        <span class="repo-meta">
                            <i class="fas fa-comments mr-1 text-purple-500"></i>
                            <%= commentCounts != null ? commentCounts.getOrDefault(exp.getExperimentId(), 0) : 0 %>
                        </span>
                    </div>
                </a>
                <% } 
                } else if (keyword.length() > 0 || selectedMaterial.length() > 0) { %>
                <div class="col-span-full text-center py-16 repo-header rounded-2xl">
                    <i class="fas fa-search text-5xl text-purple-300 mb-4"></i>
                    <p class="text-gray-700 text-lg">No experiments found matching your criteria</p>
                    <p class="text-gray-700 text-sm mt-2">Try adjusting your search filters</p>
                </div>
                <% } %>
            </div>
            
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




