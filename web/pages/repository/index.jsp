<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Optical Material Repository - OMRS</title>
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

        .repo-card {
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.12);
            box-shadow: 0 10px 30px rgba(88, 28, 135, 0.08);
            transition: all 0.2s ease;
        }
        .repo-card:hover {
            transform: translateY(-2px);
            border-color: rgba(124, 58, 237, 0.28);
            box-shadow: 0 16px 36px rgba(88, 28, 135, 0.12);
        }
        .stat-card {
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.12);
            box-shadow: 0 8px 24px rgba(88, 28, 135, 0.06);
        }
        .search-input {
            border: 1px solid rgba(124, 58, 237, 0.18);
            background: #ffffff;
            box-shadow: 0 8px 20px rgba(88, 28, 135, 0.06);
        }
        .search-input:focus {
            border-color: #8b5cf6;
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.14);
            outline: none;
        }
        .btn-primary {
            background: #7c3aed;
            color: #ffffff;
        }
        .btn-primary:hover {
            background: #6d28d9;
        }
        .material-icon {
            width: 2.75rem;
            height: 2.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f5f3ff;
            color: #7c3aed;
        }
        .repo-hero {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 52%, #f0fdfa 100%);
            border: 1px solid rgba(124, 58, 237, 0.16);
        }
        .repo-section-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1.25rem;
        }
        .repo-action-icon {
            width: 3rem;
            height: 3rem;
            border-radius: 0.9rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #f5f3ff;
        }
        .repo-pill {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.35rem 0.7rem;
            background: #f5f3ff;
            color: #5b21b6;
            font-size: 0.8rem;
            font-weight: 800;
        }
    </style>
</head>
<body class="min-h-screen">
    <% 
        User user = (User) session.getAttribute("user");
        Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
        List<String> materialTypes = (List<String>) request.getAttribute("materialTypes");
        List<Experiment> recentExperiments = (List<Experiment>) request.getAttribute("recentExperiments");
        Map<String, Integer> materialCounts = (Map<String, Integer>) request.getAttribute("materialCounts");
        
        int totalExperiments = stats != null && stats.get("totalExperiments") != null ? (Integer) stats.get("totalExperiments") : 0;
        int totalMaterials = stats != null && stats.get("totalMaterials") != null ? (Integer) stats.get("totalMaterials") : 0;
        int totalTestData = stats != null && stats.get("totalTestData") != null ? (Integer) stats.get("totalTestData") : 0;
    %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            
            <!-- Page Header -->
            <div class="repo-hero rounded-2xl p-8 mb-8 shadow-sm">
                <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-6">
                    <div>
                        <p class="text-sm font-semibold text-purple-700 mb-2">Research Repository</p>
                        <h1 class="text-3xl lg:text-4xl font-bold text-gray-900 mb-2">Optical Material Repository</h1>
                        <p class="text-gray-700 max-w-2xl">Browse approved optical material studies, compare preparation notes, inspect characterization data, and find references for your next experiment.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/optical-constants" class="inline-flex items-center rounded-xl bg-purple-600 px-5 py-3 text-white font-semibold w-fit">
                        <i class="fas fa-wave-square mr-2"></i>Optical Constants
                    </a>
                </div>

                <form action="${pageContext.request.contextPath}/repository/search" method="GET">
                    <div class="relative max-w-3xl mt-8">
                        <input type="text" name="keyword" placeholder="Search materials, experiments, or keywords..." 
                               class="w-full px-6 py-3 pl-12 rounded-xl text-gray-900 search-input">
                        <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                        <button type="submit" class="absolute right-2 top-1/2 -translate-y-1/2 px-6 py-2 rounded-lg font-semibold btn-primary">
                            Search
                        </button>
                    </div>
                </form>
            </div>
            
            <!-- Statistics Cards -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 lg:gap-6 mb-10">
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-gray-700 text-sm mb-2">Total Experiments</p>
                            <p class="text-3xl font-bold text-purple-600"><%= totalExperiments %></p>
                        </div>
                        <div class="text-5xl text-purple-600/20"><i class="fas fa-flask"></i></div>
                    </div>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-gray-700 text-sm mb-2">Material Types</p>
                            <p class="text-3xl font-bold text-purple-400"><%= totalMaterials %></p>
                        </div>
                        <div class="text-5xl text-purple-400/20"><i class="fas fa-atom"></i></div>
                    </div>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-gray-700 text-sm mb-2">Test Data Files</p>
                            <p class="text-3xl font-bold text-green-400"><%= totalTestData %></p>
                        </div>
                        <div class="text-5xl text-green-400/20"><i class="fas fa-chart-line"></i></div>
                    </div>
                </div>
            </div>
            
            <!-- Quick Actions -->
            <div class="repo-section-title">
                <div>
                    <p class="repo-pill mb-2">Repository tools</p>
                    <h2 class="text-2xl font-bold text-gray-900">Find and reuse research records</h2>
                </div>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4 lg:gap-6 mb-12">
                <a href="${pageContext.request.contextPath}/repository/browse" class="repo-card rounded-2xl p-8 group">
                    <div class="flex items-center justify-between mb-4">
                        <span class="repo-action-icon"><i class="fas fa-th-large text-xl text-purple-600 group-hover:scale-110 transition"></i></span>
                    </div>
                    <h3 class="text-xl font-semibold text-gray-900 mb-2">Browse All</h3>
                    <p class="text-gray-700 mb-4">Explore all approved experiments with pagination and filtering</p>
                    <span class="inline-flex items-center text-purple-600 font-medium group-hover:translate-x-2 transition">
                        View All <i class="fas fa-arrow-right ml-2"></i>
                    </span>
                </a>
                
                <a href="${pageContext.request.contextPath}/repository/search" class="repo-card rounded-2xl p-8 group">
                    <div class="flex items-center justify-between mb-4">
                        <span class="repo-action-icon"><i class="fas fa-filter text-xl text-purple-600 group-hover:scale-110 transition"></i></span>
                    </div>
                    <h3 class="text-xl font-semibold text-gray-900 mb-2">Advanced Search</h3>
                    <p class="text-gray-700 mb-4">Search with filters by material type, date range, and test type</p>
                    <span class="inline-flex items-center text-purple-600 font-medium group-hover:translate-x-2 transition">
                        Open Search <i class="fas fa-arrow-right ml-2"></i>
                    </span>
                </a>

                <a href="${pageContext.request.contextPath}/optical-constants" class="repo-card rounded-2xl p-8 group">
                    <div class="flex items-center justify-between mb-4">
                        <span class="repo-action-icon"><i class="fas fa-wave-square text-xl text-indigo-500 group-hover:scale-110 transition"></i></span>
                    </div>
                    <h3 class="text-xl font-semibold text-gray-900 mb-2">Optical Constants Explorer</h3>
                    <p class="text-gray-700 mb-4">Calculate refractive index, dielectric constants, reflectance, and transmission for key materials.</p>
                    <span class="inline-flex items-center text-indigo-600 font-medium group-hover:translate-x-2 transition">
                        Open Explorer <i class="fas fa-arrow-right ml-2"></i>
                    </span>
                </a>

                <a href="${pageContext.request.contextPath}/repository/public" class="repo-card rounded-2xl p-8 group">
                    <div class="flex items-center justify-between mb-4">
                        <span class="repo-action-icon"><i class="fas fa-globe text-xl text-teal-500 group-hover:scale-110 transition"></i></span>
                    </div>
                    <h3 class="text-xl font-semibold text-gray-900 mb-2">Public Research</h3>
                    <p class="text-gray-700 mb-4">Search external papers and references from public research metadata.</p>
                    <span class="inline-flex items-center text-teal-600 font-medium group-hover:translate-x-2 transition">
                        Search Public API <i class="fas fa-arrow-right ml-2"></i>
                    </span>
                </a>
            </div>
            
            <!-- Material Types -->
            <div class="mb-12">
                <div class="repo-section-title">
                    <h2 class="text-2xl font-bold text-gray-900">Browse by Material Type</h2>
                </div>
                <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                    <% if (materialTypes != null && !materialTypes.isEmpty()) {
                        for (String material : materialTypes) {
                            String materialLower = material.toLowerCase();
                            String iconClass = "icon-" + materialLower;
                            int count = materialCounts != null ? materialCounts.getOrDefault(material, 0) : 0;
                    %>
                    <a href="${pageContext.request.contextPath}/repository/material/<%= material %>" class="repo-card rounded-xl p-6">
                        <div class="<%= iconClass %> material-icon rounded-lg mb-4 mx-auto">
                            <i class="fas fa-flask"></i>
                        </div>
                        <h3 class="text-center font-semibold text-gray-900 mb-2"><%= material %></h3>
                        <p class="text-center text-gray-700 text-sm"><%= count %> experiments</p>
                    </a>
                    <% } } %>
                </div>
            </div>
            
            <!-- Recent Experiments -->
            <div class="mb-12">
                <div class="repo-section-title">
                    <h2 class="text-2xl font-bold text-gray-900">Recent Additions</h2>
                    <a href="${pageContext.request.contextPath}/repository/browse" class="text-purple-600 hover:text-purple-700 text-sm font-medium">View All &rarr;</a>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <% if (recentExperiments != null && !recentExperiments.isEmpty()) {
                        int count = 0;
                        for (Experiment exp : recentExperiments) {
                            if (count >= 3) break;
                    %>
                    <a href="${pageContext.request.contextPath}/repository/view/<%= exp.getExperimentId() %>" class="repo-card rounded-xl p-6 block">
                        <div class="mb-4">
                            <h3 class="text-lg font-semibold text-gray-900 line-clamp-2 mb-2"><%= exp.getTitle() %></h3>
                            <p class="text-gray-700 text-sm line-clamp-2"><%= exp.getPreparationNotes() != null ? exp.getPreparationNotes().substring(0, Math.min(100, exp.getPreparationNotes().length())) : "No description available" %></p>
                        </div>
                        <div class="pt-4 border-t border-purple-100">
                            <p class="text-purple-600 text-sm font-medium"><%= exp.getMaterialType() != null ? exp.getMaterialType() : "Unknown" %></p>
                        </div>
                    </a>
                    <% count++; } } %>
                </div>
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



