<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supervisor Dashboard - OMRS</title>
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

        .review-list {
            border: 1px solid rgba(168, 85, 247, 0.16);
        }

        .review-card {
            display: grid;
            grid-template-columns: minmax(170px, 1.05fr) minmax(230px, 1.45fr) minmax(150px, 0.9fr) minmax(110px, 0.7fr) minmax(105px, 0.65fr) auto;
            gap: 1.25rem;
            align-items: center;
            background: #ffffff;
            border-top: 1px solid rgba(168, 85, 247, 0.16);
        }

        .review-card:first-child {
            border-top: 0;
        }

        .review-card:hover {
            background: #fbf8ff;
        }

        .review-label {
            color: #6b7280;
            font-size: 0.7rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .status-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            padding: 0.35rem 0.75rem;
            font-size: 0.75rem;
            font-weight: 700;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .status-PENDING { background: rgba(245, 158, 11, 0.12); color: #b45309; border-color: rgba(245, 158, 11, 0.28); }
        .status-APPROVED { background: rgba(34, 197, 94, 0.12); color: #15803d; border-color: rgba(34, 197, 94, 0.28); }
        .status-REJECTED { background: rgba(239, 68, 68, 0.12); color: #b91c1c; border-color: rgba(239, 68, 68, 0.28); }
        .status-DRAFT { background: rgba(107, 114, 128, 0.12); color: #4b5563; border-color: rgba(107, 114, 128, 0.28); }

        @media (max-width: 900px) {
            .review-header {
                display: none;
            }

            .review-card {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
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

        @media (max-width: 1023px) {
            .dashboard-chat {
                bottom: 5.75rem;
            }
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
            
            <!-- Welcome Section -->
            <div class="mb-10">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                    Welcome, <span class="bg-gradient-to-r from-purple-600 to-purple-700 bg-clip-text text-transparent"><%= user.getFullName() != null && !user.getFullName().isEmpty() ? user.getFullName() : user.getUsername() %></span>
                </h1>
                <p class="text-gray-700 font-semibold">Manage student experiments and applications</p>
            </div>
            
            <!-- Stats -->
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-10">
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-yellow-500/10 flex items-center justify-center">
                            <i class="fas fa-clock text-yellow-400 text-xl"></i>
                        </div>
                        <span class="text-yellow-400 text-xs font-medium bg-yellow-500/10 px-2 py-1 rounded-full">Pending</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900">${pendingCount}</p>
                    <p class="text-gray-700 text-sm mt-1">Experiments</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
                            <i class="fas fa-check text-green-400 text-xl"></i>
                        </div>
                        <span class="text-green-400 text-xs font-medium bg-green-500/10 px-2 py-1 rounded-full">Approved</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900">${approvedCount}</p>
                    <p class="text-gray-700 text-sm mt-1">Experiments</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-purple-500/10 flex items-center justify-center">
                            <i class="fas fa-users text-purple-400 text-xl"></i>
                        </div>
                        <span class="text-purple-400 text-xs font-medium bg-purple-500/10 px-2 py-1 rounded-full">Students</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900">${studentCount}</p>
                    <p class="text-gray-700 text-sm mt-1">Active</p>
                </div>
                
                <div class="stat-card glass rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div class="w-12 h-12 rounded-xl bg-cyan-500/10 flex items-center justify-center">
                            <i class="fas fa-user-plus text-purple-600 text-xl"></i>
                        </div>
                        <span class="text-purple-600 text-xs font-medium bg-cyan-500/10 px-2 py-1 rounded-full">New</span>
                    </div>
                    <p class="text-3xl font-bold text-gray-900">${pendingApplications}</p>
                    <p class="text-gray-700 text-sm mt-1">Applications</p>
                </div>
            </div>
            
            <!-- Experiments Table -->
            <div class="mb-6">
                <h2 class="text-xl font-semibold text-gray-900">Student Experiments</h2>
                <p class="text-gray-600 text-sm">All experiment records from your supervised students.</p>
            </div>
            
            <div class="glass rounded-2xl overflow-hidden review-list">
                <div class="review-header grid grid-cols-[minmax(170px,1.05fr)_minmax(230px,1.45fr)_minmax(150px,0.9fr)_minmax(110px,0.7fr)_minmax(105px,0.65fr)_auto] gap-5 px-6 py-4 border-b border-purple-200 bg-purple-50/50">
                    <span class="review-label">Student</span>
                    <span class="review-label">Experiment</span>
                    <span class="review-label">Material</span>
                    <span class="review-label">Date</span>
                    <span class="review-label">Status</span>
                    <span class="review-label">Action</span>
                </div>

                <% List<Experiment> experiments = (List<Experiment>) request.getAttribute("experimentList");
                   if (experiments != null && !experiments.isEmpty()) {
                       for (Experiment e : experiments) {
                           String studentName = e.getStudentName() != null && !e.getStudentName().trim().isEmpty() ? e.getStudentName() : "Student";
                           String materialName = e.getMaterialType() != null && !e.getMaterialType().trim().isEmpty() ? e.getMaterialType() : "Not specified";
                           String status = e.getStatus() != null ? e.getStatus() : "PENDING";
                           boolean needsReview = "PENDING".equals(status);
                %>
                <div class="review-card p-6">
                    <div class="flex items-center gap-3 min-w-0">
                        <div class="w-11 h-11 rounded-full bg-gradient-to-br from-cyan-400 to-purple-600 flex items-center justify-center shrink-0">
                            <span class="text-white text-sm font-semibold"><%= studentName.substring(0, 1).toUpperCase() %></span>
                        </div>
                        <div class="min-w-0">
                            <p class="font-semibold text-gray-900 truncate"><%= studentName %></p>
                            <p class="text-gray-600 text-xs font-mono"><%= e.getStudentId() %></p>
                        </div>
                    </div>
                    <div class="min-w-0">
                        <p class="font-semibold text-gray-900 truncate"><%= e.getTitle() != null ? e.getTitle() : "Untitled Experiment" %></p>
                        <p class="text-purple-700 text-xs font-mono mt-1"><%= e.getExperimentId() %></p>
                    </div>
                    <div>
                        <span class="inline-flex max-w-full items-center rounded-full bg-purple-50 px-3 py-1 text-sm font-semibold text-purple-700 border border-purple-100">
                            <span class="truncate"><%= materialName %></span>
                        </span>
                    </div>
                    <div>
                        <span class="text-gray-700 font-mono text-sm whitespace-nowrap"><%= e.getExperimentDate() %></span>
                    </div>
                    <div>
                        <span class="status-pill status-<%= status %>"><%= status %></span>
                    </div>
                    <div class="flex justify-start lg:justify-end">
                        <a href="${pageContext.request.contextPath}/supervisor/review/<%= e.getExperimentId() %>"
                           class="btn-primary px-5 py-2.5 rounded-lg text-gray-900 text-sm font-semibold inline-flex items-center justify-center whitespace-nowrap">
                            <i class="fas fa-eye mr-2"></i><%= needsReview ? "Review" : "View" %>
                        </a>
                    </div>
                </div>
                <% } } else { %>
                <div class="px-6 py-16 text-center bg-white">
                    <div class="w-16 h-16 rounded-full bg-green-500/10 flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-check text-green-400 text-2xl"></i>
                    </div>
                    <p class="text-gray-900 font-semibold mb-2">No submitted experiments yet</p>
                    <p class="text-gray-700 text-sm">Student experiments will appear here once they create a record.</p>
                </div>
                <% } %>
            </div>
        </main>
    </div>

    <div class="dashboard-chat">
        <div id="dashboardChatPanel" class="dashboard-chat-panel glass rounded-2xl overflow-hidden mb-3">
            <div class="bg-purple-600 text-white px-5 py-4 flex items-center justify-between">
                <div>
                    <p class="font-semibold">OMRS Assistant</p>
                    <p class="text-xs text-purple-100">Ask about navigation or supervisor workflow</p>
                </div>
                <button type="button" onclick="toggleDashboardChat()" class="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div id="dashboardChatMessages" class="h-80 overflow-y-auto p-4 space-y-3 bg-purple-50">
                <div class="max-w-[88%] rounded-xl bg-white border border-purple-100 p-3 text-sm text-gray-800">
                    Hi! I can help you find pending reviews, approve experiments, manage students, check applications, and use repository or notification pages.
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
    
    <!-- Mobile Bottom Nav -->
    <nav class="lg:hidden fixed bottom-0 left-0 right-0 glass border-t border-purple-500/30 px-6 py-3">
        <div class="flex justify-around items-center">
            <a href="${pageContext.request.contextPath}/supervisor/dashboard" class="text-purple-400 flex flex-col items-center">
                <i class="fas fa-home text-lg"></i>
                <span class="text-xs mt-1">Home</span>
            </a>
            <a href="${pageContext.request.contextPath}/supervisor/applications" class="text-gray-700 flex flex-col items-center">
                <i class="fas fa-user-plus text-lg"></i>
                <span class="text-xs mt-1">Applications</span>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="text-gray-700 flex flex-col items-center">
                <i class="fas fa-user text-lg"></i>
                <span class="text-xs mt-1">Profile</span>
            </a>
        </div>
    </div>
    
    <script>
        const dashboardChatRole = 'SUPERVISOR';
        const dashboardChatPage = 'Supervisor Dashboard';

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





