<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, java.util.Arrays, com.omrs.model.User, com.omrs.model.Experiment" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Profile - OMRS</title>
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

        .status-APPROVED { background: rgba(34, 197, 94, 0.10); color: #16a34a; border: 1px solid rgba(34, 197, 94, 0.30); font-weight: 600; }
        .status-PENDING { background: rgba(124, 58, 237, 0.10); color: #7c3aed; border: 1px solid rgba(124, 58, 237, 0.30); font-weight: 600; }
        .status-REJECTED { background: rgba(239, 68, 68, 0.10); color: #dc2626; border: 1px solid rgba(239, 68, 68, 0.30); font-weight: 600; }

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
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(167, 139, 250, 0.3);
            font-weight: 600;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(167, 139, 250, 0.4);
        }

        .btn-success {
            background: linear-gradient(135deg, #4ade80 0%, #86efac 100%);
            color: #14532d;
            box-shadow: 0 4px 15px rgba(74, 222, 128, 0.25);
        }

        .btn-danger {
            background: linear-gradient(135deg, #fda4af 0%, #fecdd3 100%);
            color: #881337;
            box-shadow: 0 4px 15px rgba(244, 114, 182, 0.20);
        }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        User student = (User) request.getAttribute("student");
        List<Experiment> studentExperiments = (List<Experiment>) request.getAttribute("studentExperiments");

        String userDisplayName = user != null && user.getFullName() != null && !user.getFullName().isEmpty()
                ? user.getFullName() : (user != null ? user.getUsername() : "Supervisor");
        String userInitial = userDisplayName != null && !userDisplayName.isEmpty()
                ? userDisplayName.substring(0, 1).toUpperCase() : "?";

        String studentDisplayName = student != null && student.getFullName() != null && !student.getFullName().isEmpty()
                ? student.getFullName() : (student != null ? student.getUsername() : "Student");
        String studentInitial = studentDisplayName != null && !studentDisplayName.isEmpty()
                ? studentDisplayName.substring(0, 1).toUpperCase() : "?";
        String studentEmail = student != null && student.getEmail() != null ? student.getEmail() : "N/A";
        String studentStatus = student != null && student.getStatus() != null ? student.getStatus() : "UNKNOWN";
        String studentIdValue = request.getAttribute("studentId") != null ? String.valueOf(request.getAttribute("studentId")) : "N/A";
        String supervisorName = request.getAttribute("supervisorName") != null ? String.valueOf(request.getAttribute("supervisorName")) : "N/A";
        String accountCreated = student != null && student.getCreatedAt() != null ? student.getCreatedAt().toString() : "N/A";
        int totalExperiments = studentExperiments != null ? studentExperiments.size() : 0;
        int pendingExperiments = 0;
        int approvedExperiments = 0;
        int rejectedExperiments = 0;
        if (studentExperiments != null) {
            for (Experiment experiment : studentExperiments) {
                if ("PENDING".equals(experiment.getStatus())) {
                    pendingExperiments++;
                } else if ("APPROVED".equals(experiment.getStatus())) {
                    approvedExperiments++;
                } else if ("REJECTED".equals(experiment.getStatus())) {
                    rejectedExperiments++;
                }
            }
        }
    %>

    <div class="flex min-h-screen">
        <%@ include file="../common/sidebar.jsp" %>

        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            <a href="${pageContext.request.contextPath}/supervisor/students" class="inline-flex items-center text-purple-600 hover:text-purple-700 font-medium mb-6">
                <i class="fas fa-arrow-left mr-2"></i>Back to Students
            </a>

            <% if (student != null) { %>
            <div class="glass rounded-2xl p-8 mb-8">
                <div class="flex flex-col gap-6 xl:flex-row xl:items-start xl:justify-between">
                    <div class="flex items-start space-x-5">
                        <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-purple-400 to-pink-400 flex items-center justify-center shrink-0">
                            <span class="text-white text-3xl font-bold"><%= studentInitial %></span>
                        </div>
                        <div>
                            <div class="flex flex-wrap items-center gap-3 mb-2">
                                <h1 class="text-3xl font-bold text-gray-900"><%= studentDisplayName %></h1>
                                <span class="status-<%= studentStatus %> px-3 py-1 rounded-full text-sm inline-flex items-center">
                                    <i class="fas <%= "APPROVED".equals(studentStatus) ? "fa-check-circle" :
                                                    "PENDING".equals(studentStatus) ? "fa-clock" :
                                                    "REJECTED".equals(studentStatus) ? "fa-times-circle" : "fa-exclamation-circle" %> mr-2"></i>
                                    <%= studentStatus %>
                                </span>
                            </div>
                            <p class="text-gray-700 text-lg"><%= studentEmail %></p>
                            <p class="text-gray-600 text-sm mt-2">Student ID: <span class="font-semibold text-gray-900"><%= studentIdValue %></span></p>
                        </div>
                    </div>

                    <% if ("PENDING".equals(studentStatus)) { %>
                    <div class="flex flex-col sm:flex-row gap-3">
                        <form method="post" action="${pageContext.request.contextPath}/supervisor/applications">
                            <input type="hidden" name="userId" value="<%= student.getUserId() %>">
                            <input type="hidden" name="action" value="approve">
                            <button type="submit" class="btn-primary btn-success px-5 py-3 rounded-xl font-semibold inline-flex items-center justify-center w-full sm:w-auto">
                                <i class="fas fa-check mr-2"></i>Approve Student
                            </button>
                        </form>
                        <form method="post" action="${pageContext.request.contextPath}/supervisor/applications">
                            <input type="hidden" name="userId" value="<%= student.getUserId() %>">
                            <input type="hidden" name="action" value="reject">
                            <button type="submit" class="btn-primary btn-danger px-5 py-3 rounded-xl font-semibold inline-flex items-center justify-center w-full sm:w-auto">
                                <i class="fas fa-times mr-2"></i>Reject Student
                            </button>
                        </form>
                    </div>
                    <% } %>
                </div>
            </div>

            <div class="grid grid-cols-1 xl:grid-cols-3 gap-8">
                <div class="xl:col-span-2 space-y-8">
                    <div class="glass rounded-2xl p-8">
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 rounded-xl bg-purple-100 flex items-center justify-center mr-3">
                                <i class="fas fa-id-card text-purple-600"></i>
                            </div>
                            <h2 class="text-xl font-semibold text-gray-900">Basic Information</h2>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                            <div>
                                <p class="text-gray-600 text-sm mb-1 font-medium">Username</p>
                                <p class="text-gray-900 font-semibold"><%= student.getUsername() != null ? student.getUsername() : "N/A" %></p>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm mb-1 font-medium">Email</p>
                                <p class="text-gray-900 font-semibold break-all"><%= studentEmail %></p>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm mb-1 font-medium">Role</p>
                                <p class="text-gray-900 font-semibold"><%= student.getRole() != null ? student.getRole() : "N/A" %></p>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm mb-1 font-medium">Status</p>
                                <p class="text-gray-900 font-semibold"><%= studentStatus %></p>
                            </div>
                        </div>
                    </div>

                    <div class="glass rounded-2xl p-8">
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 rounded-xl bg-pink-100 flex items-center justify-center mr-3">
                                <i class="fas fa-graduation-cap text-pink-600"></i>
                            </div>
                            <h2 class="text-xl font-semibold text-gray-900">Student Details</h2>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                            <div>
                                <p class="text-gray-600 text-sm mb-1 font-medium">Student ID</p>
                                <p class="text-gray-900 font-semibold font-mono"><%= studentIdValue %></p>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm mb-1 font-medium">Supervisor</p>
                                <p class="text-gray-900 font-semibold"><%= supervisorName %></p>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm mb-1 font-medium">Account Created</p>
                                <p class="text-gray-900 font-semibold"><%= accountCreated %></p>
                            </div>
                            <div>
                                <p class="text-gray-600 text-sm mb-1 font-medium">Profile Name</p>
                                <p class="text-gray-900 font-semibold"><%= studentDisplayName %></p>
                            </div>
                        </div>
                    </div>

                    <div class="glass rounded-2xl p-8">
                        <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between mb-6">
                            <div class="flex items-center">
                                <div class="w-10 h-10 rounded-xl bg-indigo-100 flex items-center justify-center mr-3">
                                    <i class="fas fa-flask text-indigo-600"></i>
                                </div>
                                <div>
                                    <h2 class="text-xl font-semibold text-gray-900">Submitted Experiments</h2>
                                    <p class="text-sm text-gray-600">Supervisor-facing view of this student's experiment history</p>
                                </div>
                            </div>
                            <div class="flex flex-wrap gap-2">
                                <span class="px-3 py-1 rounded-full bg-purple-100 text-purple-700 text-sm font-semibold">Total: <%= totalExperiments %></span>
                                <span class="px-3 py-1 rounded-full bg-amber-100 text-amber-700 text-sm font-semibold">Pending: <%= pendingExperiments %></span>
                                <span class="px-3 py-1 rounded-full bg-green-100 text-green-700 text-sm font-semibold">Approved: <%= approvedExperiments %></span>
                                <span class="px-3 py-1 rounded-full bg-red-100 text-red-700 text-sm font-semibold">Rejected: <%= rejectedExperiments %></span>
                            </div>
                        </div>

                        <% if (studentExperiments != null && !studentExperiments.isEmpty()) { %>
                        <div class="space-y-4">
                            <% for (Experiment experiment : studentExperiments) {
                                List<String> methods = new ArrayList<String>();
                                if (experiment.getCharacterizationMethods() != null && !experiment.getCharacterizationMethods().trim().isEmpty()) {
                                    methods = Arrays.asList(experiment.getCharacterizationMethods().split("\\s*,\\s*"));
                                }
                            %>
                            <div class="rounded-2xl border border-purple-100 bg-white p-5">
                                <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
                                    <div class="space-y-3 flex-1 min-w-0">
                                        <div class="flex flex-wrap items-center gap-3">
                                            <h3 class="text-lg font-semibold text-gray-900"><%= experiment.getTitle() != null ? experiment.getTitle() : "Untitled Experiment" %></h3>
                                            <span class="status-<%= experiment.getStatus() != null ? experiment.getStatus() : "PENDING" %> px-3 py-1 rounded-full text-xs inline-flex items-center">
                                                <i class="fas <%= "APPROVED".equals(experiment.getStatus()) ? "fa-check-circle" :
                                                                "PENDING".equals(experiment.getStatus()) ? "fa-clock" :
                                                                "REJECTED".equals(experiment.getStatus()) ? "fa-times-circle" : "fa-exclamation-circle" %> mr-2"></i>
                                                <%= experiment.getStatus() != null ? experiment.getStatus() : "UNKNOWN" %>
                                            </span>
                                            <span class="text-xs text-gray-500 font-mono"><%= experiment.getExperimentId() %></span>
                                        </div>

                                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                                            <div>
                                                <p class="text-gray-500 mb-1">Date</p>
                                                <p class="font-semibold text-gray-900"><%= experiment.getExperimentDate() != null ? experiment.getExperimentDate() : "N/A" %></p>
                                            </div>
                                            <div>
                                                <p class="text-gray-500 mb-1">Material</p>
                                                <p class="font-semibold text-gray-900"><%= experiment.getMaterialType() != null && !experiment.getMaterialType().isEmpty() ? experiment.getMaterialType() : "N/A" %></p>
                                            </div>
                                            <div>
                                                <p class="text-gray-500 mb-1">Concentration</p>
                                                <p class="font-semibold text-gray-900"><%= experiment.getConcentration() != null && !experiment.getConcentration().isEmpty() ? experiment.getConcentration() : "N/A" %></p>
                                            </div>
                                        </div>

                                        <% if (experiment.getStudyObjective() != null && !experiment.getStudyObjective().isEmpty()) { %>
                                        <div>
                                            <p class="text-gray-500 text-sm mb-1">Study Objective</p>
                                            <p class="text-gray-800 text-sm whitespace-pre-wrap"><%= experiment.getStudyObjective() %></p>
                                        </div>
                                        <% } %>

                                        <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
                                            <div class="rounded-xl bg-purple-50 p-3 border border-purple-100">
                                                <p class="text-xs uppercase tracking-wide text-purple-600 font-semibold mb-1">Experiment 1</p>
                                                <p class="text-sm font-medium text-gray-900"><%= experiment.getSampleOneName() != null && !experiment.getSampleOneName().isEmpty() ? experiment.getSampleOneName() : "Not specified" %></p>
                                                <p class="text-xs text-gray-600 mt-1"><%= experiment.getSampleOneCondition() != null && !experiment.getSampleOneCondition().isEmpty() ? experiment.getSampleOneCondition() : "No condition provided" %></p>
                                            </div>
                                            <div class="rounded-xl bg-purple-50 p-3 border border-purple-100">
                                                <p class="text-xs uppercase tracking-wide text-purple-600 font-semibold mb-1">Experiment 2</p>
                                                <p class="text-sm font-medium text-gray-900"><%= experiment.getSampleTwoName() != null && !experiment.getSampleTwoName().isEmpty() ? experiment.getSampleTwoName() : "Not specified" %></p>
                                                <p class="text-xs text-gray-600 mt-1"><%= experiment.getSampleTwoCondition() != null && !experiment.getSampleTwoCondition().isEmpty() ? experiment.getSampleTwoCondition() : "No condition provided" %></p>
                                            </div>
                                            <div class="rounded-xl bg-purple-50 p-3 border border-purple-100">
                                                <p class="text-xs uppercase tracking-wide text-purple-600 font-semibold mb-1">Experiment 3</p>
                                                <p class="text-sm font-medium text-gray-900"><%= experiment.getSampleThreeName() != null && !experiment.getSampleThreeName().isEmpty() ? experiment.getSampleThreeName() : "Not specified" %></p>
                                                <p class="text-xs text-gray-600 mt-1"><%= experiment.getSampleThreeCondition() != null && !experiment.getSampleThreeCondition().isEmpty() ? experiment.getSampleThreeCondition() : "No condition provided" %></p>
                                            </div>
                                        </div>

                                        <% if (!methods.isEmpty()) { %>
                                        <div class="flex flex-wrap gap-2">
                                            <% for (String method : methods) { %>
                                            <span class="px-3 py-1 rounded-full bg-indigo-50 text-indigo-700 border border-indigo-100 text-xs font-semibold"><%= method %></span>
                                            <% } %>
                                        </div>
                                        <% } %>

                                        <% if (experiment.getFeedback() != null && !experiment.getFeedback().isEmpty()) { %>
                                        <div class="rounded-xl bg-gray-50 p-4 border border-gray-200">
                                            <p class="text-xs uppercase tracking-wide text-gray-500 font-semibold mb-1">Supervisor Feedback</p>
                                            <p class="text-sm text-gray-800 whitespace-pre-wrap"><%= experiment.getFeedback() %></p>
                                        </div>
                                        <% } %>
                                    </div>

                                    <div class="shrink-0">
                                        <a href="${pageContext.request.contextPath}/supervisor/review/<%= experiment.getExperimentId() %>" class="btn-primary px-5 py-3 rounded-xl font-semibold inline-flex items-center justify-center">
                                            <i class="fas fa-arrow-right mr-2"></i>Review
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <% } else { %>
                        <div class="rounded-2xl bg-purple-50 border border-purple-100 p-8 text-center">
                            <div class="w-14 h-14 rounded-full bg-white flex items-center justify-center mx-auto mb-4 border border-purple-100">
                                <i class="fas fa-flask text-purple-500 text-xl"></i>
                            </div>
                            <h3 class="text-lg font-semibold text-gray-900 mb-2">No Experiments Yet</h3>
                            <p class="text-gray-600">This student has not submitted any experiments so far.</p>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="space-y-8">
                    <div class="glass rounded-2xl p-8">
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 rounded-xl bg-amber-100 flex items-center justify-center mr-3">
                                <i class="fas fa-bolt text-amber-600"></i>
                            </div>
                            <h2 class="text-xl font-semibold text-gray-900">Quick Actions</h2>
                        </div>
                        <div class="space-y-3">
                            <a href="${pageContext.request.contextPath}/supervisor/students" class="btn-primary w-full px-5 py-3 rounded-xl font-semibold inline-flex items-center justify-center">
                                <i class="fas fa-users mr-2"></i>Back to Student List
                            </a>
                            <a href="${pageContext.request.contextPath}/supervisor/applications" class="w-full px-5 py-3 rounded-xl bg-purple-100 text-purple-700 hover:bg-purple-200 transition font-semibold inline-flex items-center justify-center">
                                <i class="fas fa-user-plus mr-2"></i>Open Applications
                            </a>
                        </div>
                    </div>

                    <div class="glass rounded-2xl p-8">
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 rounded-xl bg-sky-100 flex items-center justify-center mr-3">
                                <i class="fas fa-circle-info text-sky-600"></i>
                            </div>
                            <h2 class="text-xl font-semibold text-gray-900">Overview</h2>
                        </div>
                        <div class="space-y-4 text-sm">
                            <div class="flex items-center justify-between">
                                <span class="text-gray-600">Current Status</span>
                                <span class="font-semibold text-gray-900"><%= studentStatus %></span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="text-gray-600">Assigned Supervisor</span>
                                <span class="font-semibold text-gray-900 text-right"><%= supervisorName %></span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="text-gray-600">Login Name</span>
                                <span class="font-semibold text-gray-900"><%= student.getUsername() != null ? student.getUsername() : "N/A" %></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div class="glass rounded-2xl p-12 text-center">
                <div class="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
                    <i class="fas fa-exclamation-circle text-red-600 text-3xl"></i>
                </div>
                <h2 class="text-2xl font-bold text-gray-900 mb-2">Student Not Found</h2>
                <p class="text-gray-700 mb-6">The student profile you're looking for doesn't exist or you don't have access to it.</p>
                <a href="${pageContext.request.contextPath}/supervisor/students" class="inline-flex items-center px-6 py-3 rounded-xl bg-purple-100 text-purple-700 hover:bg-purple-200 transition-colors font-medium">
                    <i class="fas fa-arrow-left mr-2"></i>Back to Students
                </a>
            </div>
            <% } %>
        </main>
    </div>

    <script>
    function toggleDropdown(e, dropdownId) {
        e.preventDefault();
        const dropdown = document.getElementById(dropdownId);
        dropdown.classList.toggle('hidden');
    }

    document.addEventListener('click', function(e) {
        const dropdowns = document.querySelectorAll('[id$="-dropdown"]');
        dropdowns.forEach(function(dropdown) {
            if (!dropdown.previousElementSibling.contains(e.target) && !dropdown.contains(e.target)) {
                dropdown.classList.add('hidden');
            }
        });
    });
    </script>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>



