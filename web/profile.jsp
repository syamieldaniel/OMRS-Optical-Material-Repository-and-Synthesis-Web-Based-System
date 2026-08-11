<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - OMRS</title>
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
        
        .input-field {
            background: rgba(255, 255, 255, 1);
            border: 1px solid rgba(168, 85, 247, 0.2);
            color: #1a202c;
            transition: all 0.3s ease;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
            font-weight: 500;
        }
        .input-field:focus {
            border-color: #a78bfa;
            box-shadow: 0 0 0 3px rgba(167, 139, 250, 0.15);
            outline: none;
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
        
        .btn-secondary {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            color: #1a202c;
            transition: all 0.3s ease;
        }
        .btn-secondary:hover {
            background: rgba(255,255,255,0.1);
        }
    </style>
</head>
<body class="min-h-screen">
    <% 
        User user = (User) session.getAttribute("user");
        String backUrl;
        String backLabel;
        if ("STUDENT".equals(user.getRole())) {
            backUrl = "student/dashboard";
            backLabel = "Dashboard";
        } else if ("SUPERVISOR".equals(user.getRole())) {
            backUrl = "supervisor/dashboard";
            backLabel = "Dashboard";
        } else {
            backUrl = "repository";
            backLabel = "Repository";
        }
        String profilePicture = user.getProfilePicture();
        boolean hasProfilePicture = profilePicture != null && !profilePicture.trim().isEmpty();
    %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="pages/common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
        
        <% if (request.getAttribute("success") != null) { %>
        <div class="bg-green-500/10 border border-green-500/30 rounded-xl px-4 py-3 mb-6 flex items-center">
            <i class="fas fa-check-circle text-green-400 mr-3"></i>
            <span class="text-green-400 text-sm"><%= request.getAttribute("success") %></span>
        </div>
        <% } %>
        
        <% if (request.getAttribute("error") != null) { %>
        <div class="bg-red-500/10 border border-red-500/30 rounded-xl px-4 py-3 mb-6 flex items-center">
            <i class="fas fa-exclamation-circle text-red-400 mr-3"></i>
            <span class="text-red-400 text-sm"><%= request.getAttribute("error") %></span>
        </div>
        <% } %>
        
        <!-- Profile Header -->
        <div class="glass rounded-2xl p-8 mb-6">
            <div class="flex flex-col md:flex-row items-center md:items-start gap-6">
                <div class="w-24 h-24 rounded-2xl bg-gradient-to-br from-cyan-400 to-purple-600 flex items-center justify-center overflow-hidden">
                    <% if (hasProfilePicture) { %>
                    <img src="${pageContext.request.contextPath}<%= profilePicture %>" alt="Profile picture" class="w-full h-full object-cover">
                    <% } else { %>
                    <span class="text-white text-3xl font-bold"><%= user.getUsername().substring(0,1).toUpperCase() %></span>
                    <% } %>
                </div>
                <div class="text-center md:text-left flex-1">
                    <h1 class="text-2xl font-bold text-gray-900 mb-1">
                        <%= user.getFullName() != null && !user.getFullName().isEmpty() ? user.getFullName() : user.getUsername() %>
                    </h1>
                    <p class="text-gray-700 mb-3">@<%= user.getUsername() %></p>
                    <div class="flex flex-wrap justify-center md:justify-start gap-2">
                        <span class="px-3 py-1 rounded-full text-xs font-medium 
                            <%= "STUDENT".equals(user.getRole()) ? "bg-cyan-500/10 text-purple-600" : 
                               "SUPERVISOR".equals(user.getRole()) ? "bg-purple-500/10 text-purple-400" : 
                               "bg-green-500/10 text-green-400" %>">
                            <i class="fas <%= "STUDENT".equals(user.getRole()) ? "fa-user-graduate" : 
                                            "SUPERVISOR".equals(user.getRole()) ? "fa-user-tie" : "fa-microscope" %> mr-1"></i>
                            <%= user.getRole() %>
                        </span>
                        <span class="px-3 py-1 rounded-full text-xs font-medium bg-green-500/10 text-green-400">
                            <i class="fas fa-check-circle mr-1"></i>
                            <%= user.getStatus() %>
                        </span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Edit Profile Form -->
        <div class="glass rounded-2xl p-8">
            <h2 class="text-xl font-semibold text-gray-900 mb-6">Edit Profile</h2>
            
            <form action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Profile Picture -->
                    <div class="md:col-span-2">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Profile Picture</label>
                        <div class="relative">
                            <i class="fas fa-image absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="file" name="profilePicture" accept="image/jpeg,image/png,image/gif,image/webp"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-900 file:mr-4 file:rounded-lg file:border-0 file:bg-purple-100 file:px-4 file:py-2 file:text-purple-700 file:font-semibold">
                        </div>
                        <p class="text-gray-700 text-xs mt-1">Accepted formats: JPG, PNG, GIF, WebP. Maximum size: 5 MB.</p>
                    </div>
                    
                    <!-- Full Name -->
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Full Name</label>
                        <div class="relative">
                            <i class="fas fa-user absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="text" name="fullName" 
                                   value="<%= user.getFullName() != null ? user.getFullName() : "" %>"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-900 placeholder-gray-600"
                                   placeholder="Enter your full name">
                        </div>
                    </div>
                    
                    <!-- Email -->
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Email</label>
                        <div class="relative">
                            <i class="fas fa-envelope absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="email" name="email" 
                                   value="<%= user.getEmail() %>"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-900 placeholder-gray-600"
                                   placeholder="Enter your email">
                        </div>
                        <p class="text-gray-700 text-xs mt-1">Use an email inbox you can access for password reset links.</p>
                    </div>
                    
                    <!-- Username (Read Only) -->
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Username</label>
                        <div class="relative">
                            <i class="fas fa-at absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="text" value="<%= user.getUsername() %>" disabled
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-700 cursor-not-allowed">
                        </div>
                        <p class="text-gray-700 text-xs mt-1">Username cannot be changed</p>
                    </div>
                    
                    <!-- Role (Read Only) -->
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Role</label>
                        <div class="relative">
                            <i class="fas fa-shield-alt absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="text" value="<%= user.getRole() %>" disabled
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-700 cursor-not-allowed">
                        </div>
                    </div>

                    <!-- Password -->
                    <div class="md:col-span-2">
                        <label class="block text-gray-700 text-sm font-medium mb-2">New Password</label>
                        <div class="relative">
                            <i class="fas fa-lock absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="password" name="password"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-900 placeholder-gray-600"
                                   placeholder="Leave blank to keep your current password">
                        </div>
                        <p class="text-gray-700 text-xs mt-1">Passwords are stored using salted PBKDF2 hashing.</p>
                    </div>
                </div>
                
                <!-- Buttons -->
                <div class="flex flex-col sm:flex-row gap-4 mt-8">
                    <button type="submit" class="btn-primary px-8 py-3 rounded-xl text-gray-900 font-semibold">
                        <i class="fas fa-save mr-2"></i> Save Changes
                    </button>
                    <a href="${pageContext.request.contextPath}/<%= backUrl %>" 
                       class="btn-secondary px-8 py-3 rounded-xl text-gray-900 font-medium text-center">
                        Cancel
                    </a>
                </div>
            </form>
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
    <%@ include file="pages/common/sidebar-style.jsp" %>
</body>
</html>



