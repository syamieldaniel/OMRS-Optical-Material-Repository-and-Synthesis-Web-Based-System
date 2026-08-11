<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - OMRS</title>
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

        .dashboard-chat {
            position: fixed;
            right: 1.5rem;
            bottom: 1.5rem;
            width: min(380px, calc(100vw - 2rem));
            z-index: 60;
        }

        .dashboard-chat-panel {
            max-height: 70vh;
            display: none;
        }

        .dashboard-chat-panel.open {
            display: block;
        }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        String studentType = (String) session.getAttribute("studentType");
        boolean isFypStudent = "FYP".equals(studentType);
    %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            <!-- Welcome Section -->
            <div class="mb-8">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                    Welcome, <span class="text-purple-600"><%= user.getFullName() != null && !user.getFullName().isEmpty() ? user.getFullName() : user.getUsername() %></span>
                </h1>
                <p class="text-gray-700 font-semibold">Manage your experiment submissions and track progress</p>
            </div>
            
            <!-- Supervisor Info Card -->
            <% String supervisorName = (String) request.getAttribute("supervisorName");
               String supervisorEmail = (String) request.getAttribute("supervisorEmail");
            %>
            <% if (isFypStudent && supervisorName != null && !supervisorName.isEmpty()) { %>
            <div class="glass rounded-2xl p-6 mb-10 border border-purple-500/30">
                <div class="flex items-start">
                    <div class="flex items-start space-x-4">
                        <div class="w-12 h-12 rounded-xl bg-purple-500/20 flex items-center justify-center flex-shrink-0">
                            <i class="fas fa-user-tie text-purple-400"></i>
                        </div>
                        <div>
                            <p class="text-gray-700 text-sm font-medium mb-1">Your Supervisor</p>
                            <h3 class="text-gray-900 text-lg font-semibold"><%= supervisorName %></h3>
                            <p class="text-gray-700 text-sm mt-2">
                                <i class="fas fa-envelope text-purple-400 mr-2"></i><%= supervisorEmail %>
                            </p>
                            <p class="text-gray-700 text-sm mt-1">
                                <i class="fas fa-envelope text-purple-400 mr-2"></i><%= supervisorEmail != null ? supervisorEmail : "N/A" %>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
            
            <!-- Research Flow -->
            <div class="glass rounded-2xl p-6 mb-10">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 mb-6">
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Optical Materials Research Flow</h2>
                        <p class="text-gray-700 text-sm mt-1">
                            <%= isFypStudent
                                ? "Use the modules in this order so learning, experiment data, logbook progress, supervisor review, and repository publishing stay connected."
                                : "Use the modules in this order so learning, optical constants, experiment records, and repository browsing feel connected." %>
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/student/create" class="btn-primary px-5 py-3 rounded-xl text-gray-900 font-semibold text-sm">
                        <i class="fas fa-flask mr-2"></i>Start Study
                    </a>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-5 gap-4">
                    <a href="${pageContext.request.contextPath}/learning" class="rounded-xl border border-purple-200 bg-white p-4 hover:border-purple-400 transition">
                        <div class="w-10 h-10 rounded-lg bg-purple-50 flex items-center justify-center mb-3"><i class="fas fa-graduation-cap text-purple-600"></i></div>
                        <p class="text-xs font-semibold text-purple-700 mb-1">Learn</p>
                        <h3 class="font-semibold text-gray-900">Learning Materials</h3>
                        <p class="text-sm text-gray-600 mt-2">Review optical material concepts and take quizzes before the lab work.</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/student/create" class="rounded-xl border border-purple-200 bg-white p-4 hover:border-purple-400 transition">
                        <div class="w-10 h-10 rounded-lg bg-indigo-50 flex items-center justify-center mb-3"><i class="fas fa-atom text-indigo-600"></i></div>
                        <p class="text-xs font-semibold text-purple-700 mb-1">Plan</p>
                        <h3 class="font-semibold text-gray-900">Experiment Study</h3>
                        <p class="text-sm text-gray-600 mt-2">Choose material, set concentration, and compare three sample conditions.</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/optical-constants" class="rounded-xl border border-purple-200 bg-white p-4 hover:border-purple-400 transition">
                        <div class="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center mb-3"><i class="fas fa-wave-square text-blue-600"></i></div>
                        <p class="text-xs font-semibold text-purple-700 mb-1">Analyze</p>
                        <h3 class="font-semibold text-gray-900">Optical Constants</h3>
                        <p class="text-sm text-gray-600 mt-2">Use wavelength, refractive index, and transmission values to support discussion.</p>
                    </a>
                    <% if (isFypStudent) { %>
                    <a href="${pageContext.request.contextPath}/logbook/dashboard" class="rounded-xl border border-purple-200 bg-white p-4 hover:border-purple-400 transition">
                        <div class="w-10 h-10 rounded-lg bg-amber-50 flex items-center justify-center mb-3"><i class="fas fa-book-open text-amber-600"></i></div>
                        <p class="text-xs font-semibold text-purple-700 mb-1">Track</p>
                        <h3 class="font-semibold text-gray-900">Logbook</h3>
                        <p class="text-sm text-gray-600 mt-2">Record weekly preparation, testing, analysis, and supervisor guidance.</p>
                    </a>
                    <% } %>
                    <a href="${pageContext.request.contextPath}/repository" class="rounded-xl border border-purple-200 bg-white p-4 hover:border-purple-400 transition">
                        <div class="w-10 h-10 rounded-lg bg-green-50 flex items-center justify-center mb-3"><i class="fas fa-database text-green-600"></i></div>
                        <p class="text-xs font-semibold text-purple-700 mb-1"><%= isFypStudent ? "Share" : "Browse" %></p>
                        <h3 class="font-semibold text-gray-900">Repository</h3>
                        <p class="text-sm text-gray-600 mt-2"><%= isFypStudent ? "Approved experiments become searchable research records." : "Browse approved optical material studies for references." %></p>
                    </a>
                </div>
            </div>

            <!-- Stats -->
            <div class="grid grid-cols-4 gap-6 mb-10">
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-cyan-500/10 flex items-center justify-center">
                            <i class="fas fa-flask text-purple-600 text-xl"></i>
                        </div>
                        <span class="text-purple-600 text-xs font-medium bg-cyan-500/10 px-2 py-1 rounded-full">Total</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900">${total}</p>
                    <p class="text-gray-700 text-sm mt-1">Experiments</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-gray-500/10 flex items-center justify-center">
                            <i class="fas fa-pencil-alt text-gray-700 text-xl"></i>
                        </div>
                        <span class="text-gray-700 text-xs font-medium bg-gray-500/10 px-2 py-1 rounded-full">Draft</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900">${draft}</p>
                    <p class="text-gray-700 text-sm mt-1">In Progress</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-yellow-500/10 flex items-center justify-center">
                            <i class="fas fa-clock text-yellow-400 text-xl"></i>
                        </div>
                        <span class="text-yellow-400 text-xs font-medium bg-yellow-500/10 px-2 py-1 rounded-full">Pending</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900">${pending}</p>
                    <p class="text-gray-700 text-sm mt-1">Awaiting Review</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
                            <i class="fas fa-check text-green-400 text-xl"></i>
                        </div>
                        <span class="text-green-400 text-xs font-medium bg-green-500/10 px-2 py-1 rounded-full">Approved</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900">${approved}</p>
                    <p class="text-gray-700 text-sm mt-1">Completed</p>
                </div>
            </div>
            
            <!-- Actions & Table Header -->
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
                <h2 class="text-xl font-semibold text-gray-900">My Experiments</h2>
                <a href="${pageContext.request.contextPath}/student/create" class="btn-primary px-6 py-3 rounded-xl text-gray-900 font-semibold text-sm">
                    <i class="fas fa-plus mr-2"></i> New Experiment
                </a>
            </div>
            
            <!-- Experiments Table -->
            <div class="glass rounded-2xl overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b border-purple-500/30">
                                <th class="px-6 py-4 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">ID</th>
                                <th class="px-6 py-4 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Title</th>
                                <th class="px-6 py-4 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Material</th>
                                <th class="px-6 py-4 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Date</th>
                                <th class="px-6 py-4 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-4 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% List<Experiment> list = (List<Experiment>) request.getAttribute("experiments");
                               if (list != null && !list.isEmpty()) { 
                                   for (Experiment e : list) { %>
                            <tr class="table-row border-b border-purple-500/30/50">
                                <td class="px-6 py-4">
                                    <span class="text-purple-600 font-mono text-sm"><%= e.getExperimentId() %></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-gray-900 font-medium"><%= e.getTitle() %></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-gray-700"><%= e.getMaterialType() %></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-gray-700 font-mono text-sm"><%= e.getExperimentDate() %></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="status-<%= e.getStatus() %> px-3 py-1 rounded-full text-xs font-medium"><%= e.getStatus() %></span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center space-x-2">
                                        <a href="${pageContext.request.contextPath}/student/view/<%= e.getExperimentId() %>" 
                                           class="action-btn w-8 h-8 rounded-lg bg-cyan-500/10 flex items-center justify-center text-purple-600 hover:bg-cyan-500/20"
                                           title="View">
                                            <i class="fas fa-eye text-sm"></i>
                                        </a>
                                        <% if ("DRAFT".equals(e.getStatus()) || "PENDING".equals(e.getStatus()) || "REJECTED".equals(e.getStatus())) { %>
                                        <a href="${pageContext.request.contextPath}/student/edit/<%= e.getExperimentId() %>" 
                                           class="action-btn w-8 h-8 rounded-lg bg-purple-500/10 flex items-center justify-center text-purple-400 hover:bg-purple-500/20"
                                           title="<%= "PENDING".equals(e.getStatus()) ? "Update Pending Experiment" : "Edit" %>">
                                            <i class="fas fa-edit text-sm"></i>
                                        </a>
                                        <% } %>
                                        <% if ("DRAFT".equals(e.getStatus())) { %>
                                        <a href="${pageContext.request.contextPath}/student/delete/<%= e.getExperimentId() %>" 
                                           onclick="return confirm('Are you sure you want to delete this experiment?')"
                                           class="action-btn w-8 h-8 rounded-lg bg-red-500/10 flex items-center justify-center text-red-400 hover:bg-red-500/20"
                                           title="Delete">
                                            <i class="fas fa-trash text-sm"></i>
                                        </a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } } else { %>
                            <tr>
                                <td colspan="6" class="px-6 py-16 text-center">
                                    <div class="w-16 h-16 rounded-full bg-gray-800 flex items-center justify-center mx-auto mb-4">
                                        <i class="fas fa-flask text-gray-700 text-2xl"></i>
                                    </div>
                                    <p class="text-gray-700 mb-4">No experiments yet</p>
                                    <a href="${pageContext.request.contextPath}/student/create" class="text-purple-600 font-medium hover:underline">
                                        <i class="fas fa-plus mr-1"></i> Create your first experiment
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <div class="dashboard-chat">
        <div id="dashboardChatPanel" class="dashboard-chat-panel glass rounded-2xl overflow-hidden mb-3">
            <div class="bg-purple-600 text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <p class="font-semibold">OMRS Assistant</p>
                    <p class="text-xs text-purple-100">Ask about navigation or system workflow</p>
                </div>
                <button type="button" onclick="toggleDashboardChat()" class="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div id="dashboardChatMessages" class="h-80 overflow-y-auto p-4 space-y-3 bg-purple-50">
                <div class="max-w-[88%] rounded-xl bg-white border border-purple-100 p-3 text-sm text-gray-800">
                    Hi! I can help you find pages, understand experiment status, use logbooks, browse the repository, and manage notifications.
                </div>
            </div>
            <div class="p-4 bg-white border-t border-purple-100">
                <div class="flex gap-2">
                    <input type="text" id="dashboardChatInput" class="flex-1 px-3 py-2 rounded-lg border border-purple-200 focus:outline-none focus:ring-2 focus:ring-purple-200 text-sm" placeholder="Ask about OMRS...">
                    <button type="button" id="dashboardChatSend" onclick="sendDashboardChatMessage()" class="btn-primary px-4 py-2 rounded-lg text-sm">
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
                <p id="dashboardChatStatus" class="hidden text-xs text-gray-600 mt-2"></p>
            </div>
        </div>
        <button type="button" onclick="toggleDashboardChat()" class="ml-auto flex items-center gap-2 rounded-full bg-purple-600 text-white px-5 py-3 shadow-lg hover:bg-purple-700 transition">
            <i class="fas fa-comments"></i>
            <span class="font-semibold">Ask OMRS</span>
        </button>
    </div>
    
    <script>
        const dashboardChatRole = 'STUDENT';
        const dashboardChatPage = 'Student Dashboard';

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

        function toggleDashboardChat() {
            document.getElementById('dashboardChatPanel').classList.toggle('open');
        }

        function addDashboardChatBubble(message, role) {
            const messages = document.getElementById('dashboardChatMessages');
            const bubble = document.createElement('div');
            bubble.className = role === 'user'
                ? 'ml-auto max-w-[88%] rounded-xl bg-purple-600 p-3 text-sm text-white'
                : 'max-w-[88%] rounded-xl bg-white border border-purple-100 p-3 text-sm text-gray-800 whitespace-pre-wrap';
            bubble.textContent = message;
            messages.appendChild(bubble);
            messages.scrollTop = messages.scrollHeight;
        }

        async function sendDashboardChatMessage() {
            const input = document.getElementById('dashboardChatInput');
            const button = document.getElementById('dashboardChatSend');
            const status = document.getElementById('dashboardChatStatus');
            const question = input.value.trim();
            if (!question) return;

            addDashboardChatBubble(question, 'user');
            input.value = '';
            button.disabled = true;
            button.classList.add('opacity-60');
            status.classList.remove('hidden', 'text-red-500');
            status.textContent = 'Thinking...';

            const params = new URLSearchParams();
            params.append('question', question);
            params.append('role', dashboardChatRole);
            params.append('currentPage', dashboardChatPage);

            try {
                const response = await fetch('${pageContext.request.contextPath}/ai/system-chat', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                    body: params.toString()
                });
                const data = await response.json();
                if (!response.ok || !data.success) {
                    throw new Error(data.message || 'Unable to answer right now.');
                }
                addDashboardChatBubble(data.message, 'assistant');
                status.classList.add('hidden');
            } catch (error) {
                status.classList.add('text-red-500');
                status.textContent = error.message;
            } finally {
                button.disabled = false;
                button.classList.remove('opacity-60');
            }
        }

        const dashboardChatInput = document.getElementById('dashboardChatInput');
        if (dashboardChatInput) {
            dashboardChatInput.addEventListener('keydown', function(event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    sendDashboardChatMessage();
                }
            });
        }
    </script>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>





