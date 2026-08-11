<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; box-sizing: border-box; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; color: #111827; }

        .signup-page {
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            animation: pageFade 0.42s ease both;
        }

        .intro-panel {
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 3.5rem;
            overflow: hidden;
            background:
                radial-gradient(circle at 16% 12%, rgba(251, 191, 36, 0.20), transparent 26%),
                linear-gradient(135deg, #4c1d95 0%, #5b21b6 46%, #6d28d9 100%);
            color: #ffffff;
        }

        .intro-panel::after {
            content: "";
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(255,255,255,0.07) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.07) 1px, transparent 1px);
            background-size: 46px 46px;
            opacity: 0.32;
        }

        .intro-content,
        .intro-footer {
            position: relative;
            z-index: 1;
        }

        .intro-content {
            animation: slideInLeft 0.52s ease both;
        }

        .brand-badge {
            width: 3.25rem;
            height: 3.25rem;
            border-radius: 1rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.16);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }

        .glass {
            background: rgba(255, 255, 255, 0.88);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(167, 139, 250, 0.22);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
        }

        .module-card {
            background: rgba(255, 255, 255, 0.11);
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 1rem;
            padding: 1rem;
            transition: transform 0.22s ease, background-color 0.22s ease, border-color 0.22s ease;
        }

        .module-card:hover {
            transform: translateY(-2px);
            background: rgba(255, 255, 255, 0.15);
            border-color: rgba(255, 255, 255, 0.28);
        }

        .form-panel {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .signup-card {
            width: 100%;
            max-width: 430px;
            max-height: calc(100vh - 4rem);
            overflow-y: auto;
            border-radius: 1.25rem;
            padding: 2rem;
            animation: slideInRight 0.52s ease both;
        }

        .signup-card::-webkit-scrollbar {
            width: 8px;
        }

        .signup-card::-webkit-scrollbar-track {
            background: transparent;
        }

        .signup-card::-webkit-scrollbar-thumb {
            background: rgba(124, 58, 237, 0.22);
            border-radius: 999px;
        }

        .input-field {
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.18);
            color: #111827;
            transition: all 0.2s ease;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
            font-weight: 500;
        }

        .input-field:focus {
            border-color: #7c3aed;
            box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.14);
            outline: none;
        }

        .input-field::placeholder {
            color: rgba(31, 41, 55, 0.55);
            font-weight: 500;
        }

        .btn-primary {
            background: linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%);
            color: #ffffff;
            transition: all 0.2s ease;
            box-shadow: 0 12px 24px rgba(124, 58, 237, 0.24);
            font-weight: 700;
        }

        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 16px 30px rgba(124, 58, 237, 0.30);
            background: linear-gradient(135deg, #6d28d9 0%, #5b21b6 100%);
        }

        .dept-card {
            cursor: pointer;
            background: #ffffff;
            border: 1.5px solid rgba(124, 58, 237, 0.16);
            box-shadow: 0 4px 12px rgba(167, 139, 250, 0.08);
            transition: transform 0.2s ease, border-color 0.2s ease, background-color 0.2s ease, box-shadow 0.2s ease;
        }

        .dept-card:hover {
            transform: translateY(-1px);
            border-color: rgba(124, 58, 237, 0.35);
            background: #faf7ff;
        }

        .dept-card.active {
            border-color: rgba(124, 58, 237, 0.62);
            background: #f3e8ff;
            box-shadow: 0 10px 22px rgba(124, 58, 237, 0.16);
        }

        .role-pill {
            background: #f3e8ff;
            border: 1px solid rgba(124, 58, 237, 0.18);
            color: #5b21b6;
        }

        .link-primary {
            color: #6d28d9;
            font-weight: 700;
            transition: color 0.2s ease;
        }

        .link-primary:hover {
            color: #4c1d95;
        }

        .role-switch-link {
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.16);
            color: #6d28d9;
            transition: transform 0.2s ease, background-color 0.2s ease, border-color 0.2s ease;
        }

        .role-switch-link:hover {
            transform: translateY(-1px);
            background: #f3e8ff;
            border-color: rgba(124, 58, 237, 0.35);
        }

        @keyframes pageFade {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideInLeft {
            from { opacity: 0; transform: translateX(-14px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(14px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @media (max-width: 960px) {
            .signup-page {
                grid-template-columns: 1fr;
            }

            .intro-panel {
                padding: 2rem 1.25rem;
            }

            .intro-footer {
                display: none;
            }

            .form-panel {
                padding: 1.25rem;
            }

            .signup-card {
                max-height: none;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .signup-page,
            .intro-content,
            .signup-card,
            .module-card,
            .dept-card,
            .btn-primary,
            .input-field,
            .link-primary,
            .role-switch-link {
                animation: none;
                transition: none;
            }
        }
    </style>
</head>
<body>
    <%
        String role = (String) request.getAttribute("role");
        if (role == null) role = request.getParameter("role");
        if (role == null) role = "STUDENT";
        
        List<Map<String, String>> supervisors = (List<Map<String, String>>) request.getAttribute("supervisors");
        
        String roleIcon = "fa-user-graduate";
        String roleColor = "purple";
        String roleTitle = "Student";
        String roleSummary = "Submit experiments, manage learning materials, and track your optical research progress.";
        if ("SUPERVISOR".equals(role)) {
            roleIcon = "fa-user-tie";
            roleColor = "purple";
            roleTitle = "Supervisor";
            roleSummary = "Review student submissions, approve progress, and guide FYP research work.";
        } else if ("RESEARCHER".equals(role)) {
            roleIcon = "fa-microscope";
            roleColor = "purple";
            roleTitle = "Researcher";
            roleSummary = "Browse repository records and access shared optical materials research resources.";
        }
    %>

    <main class="signup-page">
        <section class="intro-panel">
            <div class="intro-content">
                <a href="${pageContext.request.contextPath}/index.jsp" class="inline-flex items-center gap-3 mb-14">
                    <span class="brand-badge">
                        <i class="fas fa-flask text-xl text-white"></i>
                    </span>
                    <span>
                        <span class="block text-2xl font-extrabold leading-none">OMRS</span>
                        <span class="block text-xs text-purple-100 mt-1 max-w-xs">Optical Material Repository and Synthesis Web Based System</span>
                    </span>
                </a>

                <p class="text-amber-300 text-sm font-bold uppercase tracking-wide mb-3">Create your account</p>
                <h1 class="text-4xl lg:text-5xl font-extrabold leading-tight max-w-3xl mb-5">
                    Join OMRS as a <%= roleTitle %>.
                </h1>
                <p class="text-purple-100 text-lg max-w-2xl mb-10">
                    <%= roleSummary %>
                </p>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 max-w-4xl">
                    <div class="module-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-id-card text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Role access</h2>
                        <p class="text-sm text-purple-100">Your dashboard is shaped around your selected OMRS role.</p>
                    </div>
                    <div class="module-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-shield-halved text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Approval flow</h2>
                        <p class="text-sm text-purple-100">FYP and supervisor access supports review and approval steps.</p>
                    </div>
                    <div class="module-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-folder-open text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Research hub</h2>
                        <p class="text-sm text-purple-100">Learning, repository, experiments, and logbooks stay connected.</p>
                    </div>
                </div>
            </div>

            <div class="intro-footer">
                <div class="flex items-center gap-6 text-sm text-purple-100">
                    <span><i class="fas fa-user-graduate text-amber-300 mr-2"></i>Students</span>
                    <span><i class="fas fa-chalkboard-user text-amber-300 mr-2"></i>Supervisors</span>
                    <span><i class="fas fa-microscope text-amber-300 mr-2"></i>Researchers</span>
                </div>
            </div>
        </section>

        <section class="form-panel">
            <div class="signup-card glass">
                <div class="mb-7">
                    <div class="w-12 h-12 rounded-xl bg-purple-100 flex items-center justify-center mb-5">
                        <i class="fas <%= roleIcon %> text-purple-700"></i>
                    </div>
                    <h2 class="text-3xl font-extrabold text-gray-900 mb-2">Create account</h2>
                    <div class="inline-flex items-center gap-2 role-pill px-4 py-2 rounded-full">
                        <i class="fas <%= roleIcon %> text-<%= roleColor %>-700"></i>
                        <span class="text-sm font-bold">Signing up as <%= roleTitle %></span>
                    </div>
                </div>

                <% if (request.getAttribute("error") != null) { %>
                <div class="bg-red-50 border border-red-300 text-red-700 rounded-xl px-4 py-3 mb-6 flex items-center">
                    <i class="fas fa-exclamation-circle mr-3"></i>
                    <span class="text-sm font-semibold"><%= request.getAttribute("error") %></span>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/signup" method="POST" id="signupForm">
                    <input type="hidden" name="role" value="<%= role %>">
                    
                    <!-- Full Name -->
                    <div class="mb-4">
                        <label class="block text-gray-800 text-sm font-bold mb-2">Full Name <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <i class="fas fa-user absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="text" name="fullName" required
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-900 placeholder-gray-600"
                                   placeholder="Enter your full name">
                        </div>
                    </div>
                    
                    <!-- Email -->
                    <div class="mb-4">
                        <label class="block text-gray-800 text-sm font-bold mb-2">Email <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <i class="fas fa-envelope absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="email" name="email" required
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-900 placeholder-gray-600"
                                   placeholder="Enter your email">
                        </div>
                        <p class="text-xs text-gray-600 mt-1">Use a real inbox. Password reset links will be sent here.</p>
                    </div>
                    
                    <!-- Username -->
                    <div class="mb-4">
                        <label class="block text-gray-800 text-sm font-bold mb-2">Username <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <i class="fas fa-at absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="text" name="username" required
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-900 placeholder-gray-600"
                                   placeholder="Choose a username">
                        </div>
                    </div>
                    
                    <!-- Password -->
                    <div class="mb-4">
                        <label class="block text-gray-800 text-sm font-bold mb-2">Password <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <i class="fas fa-lock absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="password" name="password" required id="password"
                                   class="input-field w-full pl-11 pr-12 py-3 rounded-xl text-gray-900 placeholder-gray-600"
                                   placeholder="Create a password">
                            <button type="button" onclick="togglePasswordVisibility('password', 'eyeIcon')" class="absolute right-4 top-1/2 -translate-y-1/2 text-purple-600 hover:text-purple-900 transition" aria-label="Show password">
                                <i class="fas fa-eye" id="eyeIcon"></i>
                            </button>
                        </div>
                    </div>
                    
                    <% if ("STUDENT".equals(role)) { %>
                    <!-- Student Type -->
                    <div class="mb-4">
                        <label class="block text-gray-800 text-sm font-bold mb-2">Student Type <span class="text-red-500">*</span></label>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                            <label class="dept-card rounded-xl p-4 active" onclick="selectStudentType('NORMAL')">
                                <input type="radio" name="studentType" value="NORMAL" class="hidden" checked>
                                <div class="flex items-start gap-3">
                                    <i class="fas fa-flask text-purple-600 mt-1"></i>
                                    <div>
                                        <p class="font-bold text-gray-900">Normal Student</p>
                                        <p class="text-xs text-gray-600 mt-1">Record and manage experiments independently.</p>
                                    </div>
                                </div>
                            </label>
                            <label class="dept-card rounded-xl p-4" onclick="selectStudentType('FYP')">
                                <input type="radio" name="studentType" value="FYP" class="hidden">
                                <div class="flex items-start gap-3">
                                    <i class="fas fa-user-tie text-purple-600 mt-1"></i>
                                    <div>
                                        <p class="font-bold text-gray-900">FYP Student</p>
                                        <p class="text-xs text-gray-600 mt-1">Connect experiments with logbook and supervisor review.</p>
                                    </div>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- Student ID -->
                    <div class="mb-4">
                        <label class="block text-gray-800 text-sm font-bold mb-2">Student ID <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <i class="fas fa-id-card absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="text" name="studentId" required
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-gray-900 placeholder-gray-600"
                                   placeholder="e.g., S12345">
                        </div>
                    </div>
                    
                    <!-- Supervisor Selection -->
                    <div id="supervisorBlock" class="mb-6 hidden">
                        <label class="block text-gray-800 text-sm font-bold mb-2">Select Supervisor <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <i class="fas fa-user-tie absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <select name="supervisorId" id="supervisorSelect"
                                    class="input-field w-full pl-11 pr-10 py-3 rounded-xl text-gray-900 appearance-none cursor-pointer">
                                <option value="">-- Select supervisor --</option>
                                <% if (supervisors != null) {
                                       for (Map<String, String> sup : supervisors) { %>
                                <option value="<%= sup.get("id") %>"><%= sup.get("username") %></option>
                                <%     }
                                   } %>
                            </select>
                            <i class="fas fa-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none text-xs"></i>
                        </div>
                    </div>
                    
                    <!-- Notice for Students -->
                    <div id="studentNotice" class="bg-green-50 border border-green-200 rounded-xl px-4 py-3 mb-6 flex items-start">
                        <i class="fas fa-info-circle text-green-600 mr-3 mt-0.5"></i>
                        <span class="text-green-700 text-sm font-medium">Normal students can login after registration. Choose FYP Student if you need supervisor approval and logbook tracking.</span>
                    </div>
                    <% } %>
                    
                    <!-- Submit -->
                    <button type="submit" class="btn-primary w-full py-3 rounded-xl font-bold inline-flex items-center justify-center gap-2">
                        <i class="fas fa-user-plus"></i>
                        Create Account
                    </button>
                </form>

                <!-- Divider -->
                <div class="flex items-center my-6">
                    <div class="flex-1 border-t border-purple-100"></div>
                    <span class="px-4 text-gray-600 text-sm font-medium">or</span>
                    <div class="flex-1 border-t border-purple-100"></div>
                </div>

                <!-- Login Link -->
                <div class="text-center">
                    <p class="text-gray-700 text-sm font-medium">
                        Already have an account?
                        <a href="${pageContext.request.contextPath}/login.jsp" class="link-primary">Sign in</a>
                    </p>
                </div>

                <!-- Change Role -->
                <div class="text-center mt-6">
                    <p class="text-gray-700 text-sm mb-3 font-medium">Not a <%= roleTitle.toLowerCase() %>?</p>
                    <div class="flex justify-center gap-3 flex-wrap">
                        <% if (!"STUDENT".equals(role)) { %>
                        <a href="${pageContext.request.contextPath}/signup?role=STUDENT" class="role-switch-link px-4 py-2 rounded-lg text-sm font-bold">Student</a>
                        <% } %>
                        <% if (!"SUPERVISOR".equals(role)) { %>
                        <a href="${pageContext.request.contextPath}/signup?role=SUPERVISOR" class="role-switch-link px-4 py-2 rounded-lg text-sm font-bold">Supervisor</a>
                        <% } %>
                        <% if (!"RESEARCHER".equals(role)) { %>
                        <a href="${pageContext.request.contextPath}/signup?role=RESEARCHER" class="role-switch-link px-4 py-2 rounded-lg text-sm font-bold">Researcher</a>
                        <% } %>
                    </div>
                </div>
            </div>
        </section>
    </main>
    
    <script>
        // Supervisor data from server
        const supervisors = [
            <% if (supervisors != null) {
                for (int i = 0; i < supervisors.size(); i++) {
                    Map<String, String> sup = supervisors.get(i); %>
            { id: "<%= sup.get("id") %>", name: "<%= sup.get("username") %>" }<%= i < supervisors.size()-1 ? "," : "" %>
            <% } } %>
        ];
        
        function togglePasswordVisibility(inputId, iconId) {
            const pwd = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (!pwd || !icon) return;

            const showPassword = pwd.type === 'password';
            pwd.type = showPassword ? 'text' : 'password';
            icon.classList.toggle('fa-eye', !showPassword);
            icon.classList.toggle('fa-eye-slash', showPassword);
            const button = icon.closest('button');
            if (button) {
                button.setAttribute('aria-label', showPassword ? 'Hide password' : 'Show password');
            }
        }

        function selectStudentType(type) {
            document.querySelectorAll('input[name="studentType"]').forEach(input => {
                const card = input.closest('.dept-card');
                input.checked = input.value === type;
                if (card) {
                    card.classList.toggle('active', input.checked);
                }
            });

            const supervisorBlock = document.getElementById('supervisorBlock');
            const supervisorSelect = document.getElementById('supervisorSelect');
            const notice = document.getElementById('studentNotice');
            const isFyp = type === 'FYP';

            if (supervisorBlock) supervisorBlock.classList.toggle('hidden', !isFyp);
            if (supervisorSelect) supervisorSelect.required = isFyp;
            if (notice) {
                notice.className = isFyp
                    ? 'bg-yellow-50 border border-yellow-200 rounded-xl px-4 py-3 mb-6 flex items-start'
                    : 'bg-green-50 border border-green-200 rounded-xl px-4 py-3 mb-6 flex items-start';
                notice.querySelector('i').className = isFyp ? 'fas fa-info-circle text-yellow-600 mr-3 mt-0.5' : 'fas fa-info-circle text-green-600 mr-3 mt-0.5';
                notice.querySelector('span').className = isFyp ? 'text-yellow-700 text-sm font-medium' : 'text-green-700 text-sm font-medium';
                notice.querySelector('span').textContent = isFyp
                    ? 'FYP student accounts need supervisor approval before login. Logbook tracking will be enabled.'
                    : 'Normal students can login after registration and use learning, optical constants, experiments, and repository modules.';
            }
        }
    </script>
</body>
</html>
