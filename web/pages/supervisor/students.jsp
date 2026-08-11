<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Students - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; }
        
        .glass {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(167, 139, 250, 0.2);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
        }
        
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
        
        .stat-card {
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .stat-card:hover {
            transform: translateY(-3px);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #a78bfa 0%, #d8b4fe 100%);
            color: #1a202c;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(167, 139, 250, 0.3);
            font-weight: 600;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(167, 139, 250, 0.4);
        }
        
        .table-row {
            transition: all 0.2s ease;
            background: rgba(255, 255, 255, 1);
            border-bottom: 1px solid rgba(168, 85, 247, 0.15);
        }
        .table-row:hover {
            background: rgba(167, 139, 250, 0.08);
        }
    </style>
</head>
<body class="min-h-screen">
    <% User user = (User) session.getAttribute("user"); %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Mobile Header -->
        <header class="lg:hidden fixed top-0 left-0 right-0 glass z-50 px-4 py-3">
            <div class="flex justify-between items-center">
                <div class="flex items-center space-x-2">
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-400 to-pink-400 flex items-center justify-center">
                        <i class="fas fa-flask text-white text-sm"></i>
                    </div>
                    <span class="text-lg font-bold text-white">OMRS</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="text-gray-700">
                    <i class="fas fa-sign-out-alt"></i>
                </a>
            </div>
        </header>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            <!-- Page Header -->
            <div class="mb-10">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">My Students</h1>
                <p class="text-gray-700 font-medium">View and manage your supervised students</p>
            </div>
            
            <!-- Status Summary Cards -->
            <% 
                List<User> students = (List<User>) request.getAttribute("students");
                int totalStudents = students != null ? students.size() : 0;
                int approvedCount = 0;
                int pendingCount = 0;
                int rejectedCount = 0;
                
                if (students != null) {
                    for (User s : students) {
                        if ("APPROVED".equals(s.getStatus())) approvedCount++;
                        else if ("PENDING".equals(s.getStatus())) pendingCount++;
                        else if ("REJECTED".equals(s.getStatus())) rejectedCount++;
                    }
                }
            %>
            
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-10">
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-purple-100 flex items-center justify-center">
                            <i class="fas fa-users text-purple-600 text-xl"></i>
                        </div>
                        <span class="text-purple-600 text-xs font-medium bg-purple-100 px-2 py-1 rounded-full">Total</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900"><%= totalStudents %></p>
                    <p class="text-gray-700 text-sm mt-1 font-medium">Students</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-green-100 flex items-center justify-center">
                            <i class="fas fa-check-circle text-green-600 text-xl"></i>
                        </div>
                        <span class="text-green-600 text-xs font-medium bg-green-100 px-2 py-1 rounded-full">Approved</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900"><%= approvedCount %></p>
                    <p class="text-gray-700 text-sm mt-1 font-medium">Approved</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-purple-100 flex items-center justify-center">
                            <i class="fas fa-clock text-purple-600 text-xl"></i>
                        </div>
                        <span class="text-purple-600 text-xs font-medium bg-purple-100 px-2 py-1 rounded-full">Pending</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900"><%= pendingCount %></p>
                    <p class="text-gray-700 text-sm mt-1 font-medium">Pending</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-red-100 flex items-center justify-center">
                            <i class="fas fa-times-circle text-red-600 text-xl"></i>
                        </div>
                        <span class="text-red-600 text-xs font-medium bg-red-100 px-2 py-1 rounded-full">Rejected</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900"><%= rejectedCount %></p>
                    <p class="text-gray-700 text-sm mt-1 font-medium">Rejected</p>
                </div>
            </div>
            
            <!-- Students List -->
            <div class="glass rounded-2xl overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b border-purple-100">
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Student ID</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Name</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Email</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (students != null && !students.isEmpty()) { 
                                for (User s : students) { %>
                            <tr class="table-row">
                                <%
                                    String studentDisplayName = s.getFullName() != null && !s.getFullName().isEmpty()
                                            ? s.getFullName() : s.getUsername();
                                    String studentInitial = studentDisplayName != null && !studentDisplayName.isEmpty()
                                            ? studentDisplayName.substring(0, 1).toUpperCase() : "?";
                                %>
                                <td class="px-6 py-4">
                                    <span class="text-purple-600 font-mono text-sm font-semibold"><%= s.getStudentId() %></span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center">
                                        <div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-400 to-pink-400 flex items-center justify-center mr-3">
                                            <span class="text-white font-medium text-sm"><%= studentInitial %></span>
                                        </div>
                                        <span class="text-gray-900 font-medium"><%= studentDisplayName %></span>
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-gray-700 text-sm"><%= s.getEmail() %></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="status-<%= s.getStatus() %> px-3 py-1 rounded-full text-xs font-medium">
                                        <i class="fas <%= "APPROVED".equals(s.getStatus()) ? "fa-check-circle" : 
                                                        "PENDING".equals(s.getStatus()) ? "fa-clock" :
                                                        "REJECTED".equals(s.getStatus()) ? "fa-times-circle" : "fa-exclamation-circle" %> mr-1"></i>
                                        <%= s.getStatus() %>
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <a href="${pageContext.request.contextPath}/supervisor/student/<%= s.getUserId() %>" 
                                       class="btn-primary px-4 py-2 rounded-lg text-white text-sm font-medium inline-flex items-center">
                                        <i class="fas fa-arrow-right mr-2"></i>View
                                    </a>
                                </td>
                            </tr>
                            <% } } else { %>
                            <tr>
                                <td colspan="6" class="px-6 py-16 text-center">
                                    <div class="w-16 h-16 rounded-full bg-purple-100 flex items-center justify-center mx-auto mb-4">
                                        <i class="fas fa-users text-purple-600 text-2xl"></i>
                                    </div>
                                    <p class="text-gray-700 font-medium">No students assigned yet</p>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
    
    <!-- Mobile Bottom Nav -->
    <nav class="lg:hidden fixed bottom-0 left-0 right-0 glass border-t border-purple-100 px-6 py-3">
        <div class="flex justify-around items-center">
            <a href="${pageContext.request.contextPath}/supervisor/dashboard" class="text-gray-700 flex flex-col items-center hover:text-purple-600">
                <i class="fas fa-home text-lg"></i>
                <span class="text-xs mt-1">Home</span>
            </a>
            <a href="${pageContext.request.contextPath}/supervisor/students" class="text-purple-600 flex flex-col items-center font-medium">
                <i class="fas fa-users text-lg"></i>
                <span class="text-xs mt-1">Students</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="text-gray-700 flex flex-col items-center hover:text-purple-600">
                <i class="fas fa-user text-lg"></i>
                <span class="text-xs mt-1">Profile</span>
            </a>
        </div>
    </nav>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>






