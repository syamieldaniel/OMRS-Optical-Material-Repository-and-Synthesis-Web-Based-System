<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.omrs.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Applications - OMRS</title>
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
        
        .btn-primary {
            background: linear-gradient(135deg, #a78bfa 0%, #d8b4fe 100%);
            color: #1a202c;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(167, 139, 250, 0.2);
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 40px rgba(167,139,250,0.3);
        }
        
        .btn-approve {
            background: rgba(34,197,94,0.1);
            border: 1px solid rgba(34,197,94,0.3);
            color: #22c55e;
            transition: all 0.3s ease;
        }
        .btn-approve:hover {
            background: rgba(34,197,94,0.2);
        }
        
        .btn-reject {
            background: rgba(239,68,68,0.1);
            border: 1px solid rgba(239,68,68,0.3);
            color: #ef4444;
            transition: all 0.3s ease;
        }
        .btn-reject:hover {
            background: rgba(239,68,68,0.2);
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
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center">
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
                <h1 class="text-3xl font-bold text-gray-900 mb-2">Pending Applications</h1>
                <p class="text-gray-700">Review and approve student applications</p>
            </div>
            
            <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-500/10 border border-red-500/30 text-red-400 px-6 py-4 rounded-2xl mb-6">
                <i class="fas fa-exclamation-circle mr-2"></i><%= request.getAttribute("error") %>
            </div>
            <% } %>
            
            <% if (request.getAttribute("success") != null) { %>
            <div class="bg-green-500/10 border border-green-500/30 text-green-400 px-6 py-4 rounded-2xl mb-6">
                <i class="fas fa-check-circle mr-2"></i><%= request.getAttribute("success") %>
            </div>
            <% } %>
            
            <% List<User> pendingStudents = (List<User>) request.getAttribute("pendingStudents"); %>
            <% if (pendingStudents == null || pendingStudents.isEmpty()) { %>
            <div class="glass rounded-2xl p-12 text-center">
                <div class="w-16 h-16 rounded-full bg-green-500/10 flex items-center justify-center mx-auto mb-4">
                    <i class="fas fa-check-circle text-green-400 text-3xl"></i>
                </div>
                <p class="text-gray-700 text-lg">No pending applications</p>
                <p class="text-gray-700 text-sm mt-2">All applications have been reviewed</p>
            </div>
            <% } else { %>
            <div class="space-y-4">
                <% for (User student : pendingStudents) { %>
                <div class="glass rounded-2xl p-6 border border-purple-500/30 hover:border-purple-500/30 transition-colors">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-4 flex-1">
                            <%
                                String studentDisplayName = student.getFullName() != null && !student.getFullName().isEmpty()
                                        ? student.getFullName() : student.getUsername();
                                String studentInitial = studentDisplayName != null && !studentDisplayName.isEmpty()
                                        ? studentDisplayName.substring(0, 1).toUpperCase() : "?";
                            %>
                            <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center flex-shrink-0">
                                <span class="text-white font-bold text-lg"><%= studentInitial %></span>
                            </div>
                            <div>
                                <h3 class="text-white font-semibold text-lg"><%= studentDisplayName %></h3>
                                <p class="text-gray-700 text-sm"><%= student.getEmail() %></p>
                                <p class="text-gray-700 text-xs mt-1"><i class="fas fa-user-circle mr-1"></i><%= student.getUsername() %></p>
                            </div>
                        </div>
                        <div class="flex items-center space-x-3 flex-shrink-0">
                            <form action="${pageContext.request.contextPath}/supervisor/applications" method="POST" class="inline">
                                <input type="hidden" name="userId" value="<%= student.getUserId() %>">
                                <input type="hidden" name="action" value="approve">
                                <button type="submit" class="btn-approve px-6 py-2 rounded-xl font-medium transition-all hover:shadow-lg">
                                    <i class="fas fa-check mr-2"></i>Approve
                                </button>
                            </form>
                            <form action="${pageContext.request.contextPath}/supervisor/applications" method="POST" class="inline">
                                <input type="hidden" name="userId" value="<%= student.getUserId() %>">
                                <input type="hidden" name="action" value="reject">
                                <button type="submit" class="btn-reject px-6 py-2 rounded-xl font-medium transition-all hover:shadow-lg">
                                    <i class="fas fa-times mr-2"></i>Reject
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </main>
    </div>
    
    <!-- Mobile Bottom Nav -->
    <nav class="lg:hidden fixed bottom-0 left-0 right-0 glass border-t border-purple-500/30 px-6 py-3">
        <div class="flex justify-around items-center">
            <a href="${pageContext.request.contextPath}/supervisor/dashboard" class="text-gray-700 flex flex-col items-center hover:text-white">
                <i class="fas fa-home text-lg"></i>
                <span class="text-xs mt-1">Home</span>
            </a>
            <a href="${pageContext.request.contextPath}/supervisor/students" class="text-gray-700 flex flex-col items-center hover:text-white">
                <i class="fas fa-users text-lg"></i>
                <span class="text-xs mt-1">Students</span>
            </a>
            <a href="${pageContext.request.contextPath}/supervisor/applications" class="text-purple-400 flex flex-col items-center">
                <i class="fas fa-user-plus text-lg"></i>
                <span class="text-xs mt-1">Apps</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="text-gray-700 flex flex-col items-center hover:text-white">
                <i class="fas fa-user text-lg"></i>
                <span class="text-xs mt-1">Profile</span>
            </a>
        </div>
    </nav>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
<script>
function toggleDropdown(e, dropdownId) {
    e.preventDefault();
    const dropdown = document.getElementById(dropdownId);
    dropdown.classList.toggle('hidden');
}
document.addEventListener('click', function(e) {
    const dropdowns = document.querySelectorAll('[id$="-dropdown"]');
    dropdowns.forEach(d => {
        if (!d.previousElementSibling.contains(e.target) && !d.contains(e.target)) {
            d.classList.add('hidden');
        }
    });
});
</script>
</html>






