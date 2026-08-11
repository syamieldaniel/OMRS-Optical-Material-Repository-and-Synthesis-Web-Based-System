<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, com.omrs.model.*, java.time.YearMonth" %>
<%
    // Debug: Check if user is authenticated
    Object userObj = session.getAttribute("user");
    Object supervisorIdObj = session.getAttribute("supervisorId");
    
    List<Logbook> logbooks = (List<Logbook>) request.getAttribute("logbooks");
    String month = (String) request.getAttribute("month");
    User user = (User) session.getAttribute("user");
    
    // Default to current month if not specified
    if (month == null || month.isEmpty()) {
        month = YearMonth.now().toString();
    }
    
    // Calculate stats
    int totalLogbooks = 0;
    int approvedLogbooks = 0;
    int pendingLogbooks = 0;
    int totalStudents = 0;
    if (logbooks != null && !logbooks.isEmpty()) {
        totalLogbooks = logbooks.size();
        for (Logbook lb : logbooks) {
            if (lb.isApproved()) {
                approvedLogbooks++;
            } else {
                pendingLogbooks++;
            }
        }
    }
    
    // Group logbooks by student
    Map<String, List<Logbook>> studentLogbooks = new HashMap<>();
    if (logbooks != null && !logbooks.isEmpty()) {
        for (Logbook lb : logbooks) {
            if (lb != null && lb.getStudentId() != null) {
                String studentName = lb.getStudentName() != null ? lb.getStudentName() : "Unknown";
                String key = lb.getStudentId() + "|" + studentName;
                studentLogbooks.putIfAbsent(key, new java.util.ArrayList<Logbook>());
                studentLogbooks.get(key).add(lb);
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Logbooks Review - OMRS</title>
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
        
        .logbook-table {
            border-collapse: separate;
            border-spacing: 0;
            min-width: 980px;
        }
        .logbook-table th {
            background: #f3e8ff;
            color: #4c1d95;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(124, 58, 237, 0.18);
        }
        .logbook-table td {
            padding: 1rem;
            vertical-align: top;
            border-bottom: 1px solid rgba(124, 58, 237, 0.12);
            background: #ffffff;
        }
        .week-col { width: 6rem; font-weight: 800; color: #5b21b6; }
        .activities-col { width: 40%; }
        .notes-col { width: 35%; }
        .action-col { width: 25%; }
        .status-approved td { background: rgba(236, 253, 245, 0.88); }
        .status-pending td { background: #ffffff; }
        .month-card {
            border-radius: 1rem;
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.16);
            box-shadow: 0 8px 22px rgba(88, 28, 135, 0.07);
        }
        .review-student-card {
            border-radius: 1rem;
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.16);
            box-shadow: 0 8px 22px rgba(88, 28, 135, 0.07);
        }
        .logbook-input,
        .logbook-textarea {
            border: 1px solid rgba(124, 58, 237, 0.20);
            border-radius: 0.75rem;
            background: rgba(248, 250, 252, 0.95);
            outline: none;
        }
        .logbook-textarea { min-height: 6rem; padding: 0.75rem; }
        .logbook-input { padding: 0.5rem 0.65rem; }
        .logbook-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            border-radius: 999px;
            padding: 0.35rem 0.7rem;
            font-size: 0.78rem;
            font-weight: 800;
        }
        .logbook-pill.approved { background: #dcfce7; color: #166534; }
        
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
    
    <div class="flex min-h-screen">
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>

        <!-- Main Content -->
        <div class="flex-1 lg:ml-64">
            <!-- Top Nav for Mobile -->
            <nav class="glass shadow-sm sticky top-0 z-40 lg:hidden">
                <div class="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
                    <h1 class="text-xl font-bold text-purple-700">OMRS</h1>
                    <div class="flex items-center gap-4">
                        <a href="<%= request.getContextPath() %>/logout" class="text-gray-700 hover:text-red-600">
                            <i class="fas fa-sign-out-alt"></i>
                        </a>
                    </div>
                </div>
            </nav>

            <div class="max-w-7xl mx-auto px-4 py-8">
                <!-- Header -->
                <div class="mb-8">
                    <h2 class="text-3xl font-bold text-gray-800">Student Logbooks</h2>
                    <p class="text-gray-600 mt-1">Review and approve student weekly activities</p>
                </div>

                <!-- Stats -->
                <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-10">
                    <div class="stat-card glass rounded-2xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 rounded-xl bg-purple-500/10 flex items-center justify-center">
                                <i class="fas fa-book text-purple-400 text-xl"></i>
                            </div>
                            <span class="text-purple-400 text-xs font-medium bg-purple-500/10 px-2 py-1 rounded-full">Total</span>
                        </div>
                        <p class="text-3xl font-bold text-gray-900"><%= totalLogbooks %></p>
                        <p class="text-gray-700 text-sm mt-1">Logbook Entries</p>
                    </div>
                    
                    <div class="stat-card glass rounded-2xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
                                <i class="fas fa-check text-green-400 text-xl"></i>
                            </div>
                            <span class="text-green-400 text-xs font-medium bg-green-500/10 px-2 py-1 rounded-full">Approved</span>
                        </div>
                        <p class="text-3xl font-bold text-gray-900"><%= approvedLogbooks %></p>
                        <p class="text-gray-700 text-sm mt-1">Approved</p>
                    </div>
                    
                    <div class="stat-card glass rounded-2xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 rounded-xl bg-yellow-500/10 flex items-center justify-center">
                                <i class="fas fa-clock text-yellow-400 text-xl"></i>
                            </div>
                            <span class="text-yellow-400 text-xs font-medium bg-yellow-500/10 px-2 py-1 rounded-full">Pending</span>
                        </div>
                        <p class="text-3xl font-bold text-gray-900"><%= pendingLogbooks %></p>
                        <p class="text-gray-700 text-sm mt-1">Pending Review</p>
                    </div>
                    
                    <div class="stat-card glass rounded-2xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 rounded-xl bg-cyan-500/10 flex items-center justify-center">
                                <i class="fas fa-users text-purple-600 text-xl"></i>
                            </div>
                            <span class="text-purple-600 text-xs font-medium bg-cyan-500/10 px-2 py-1 rounded-full">Students</span>
                        </div>
                        <p class="text-3xl font-bold text-gray-900"><%= studentLogbooks.size() %></p>
                        <p class="text-gray-700 text-sm mt-1">Active Students</p>
                    </div>
                </div>

                <!-- Month Navigation -->
                <div class="month-card p-4 lg:p-5 mb-6">
                    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                        <div>
                            <p class="text-xs font-semibold uppercase tracking-wide text-purple-600">Selected month</p>
                            <p class="text-xl font-bold text-gray-900"><%= month %></p>
                        </div>
                        <div class="flex flex-col sm:flex-row gap-3 sm:items-center">
                            <%
                                String prevMonth = YearMonth.parse(month).minusMonths(1).toString();
                                String nextMonth = YearMonth.parse(month).plusMonths(1).toString();
                            %>
                            <a href="<%= request.getContextPath() %>/logbook/dashboard?month=<%= prevMonth %>" class="bg-purple-600 text-white px-5 py-2.5 rounded-xl font-semibold hover:bg-purple-700 transition text-center">
                                <i class="fas fa-chevron-left mr-2"></i>Previous
                            </a>
                            <a href="<%= request.getContextPath() %>/logbook/dashboard?month=<%= nextMonth %>" class="bg-purple-600 text-white px-5 py-2.5 rounded-xl font-semibold hover:bg-purple-700 transition text-center">
                                Next<i class="fas fa-chevron-right ml-2"></i>
                            </a>
                        </div>
                    </div>
                </div>

        <!-- Students Logbooks -->
        <% if (studentLogbooks.isEmpty()) { %>
            <div class="glass rounded-lg p-8 text-center">
                <i class="fas fa-book text-4xl text-gray-300 mb-4"></i>
                <p class="text-gray-500 text-lg">No logbook entries for this month</p>
            </div>
        <% } else { %>
            <% for (String key : studentLogbooks.keySet()) { 
                String[] parts = key.split("\\|");
                String studentId = parts[0];
                String studentName = parts[1];
                List<Logbook> weeks = studentLogbooks.get(key);
            %>
            
            <!-- Student Section -->
            <div class="mb-8">
                <div class="review-student-card p-4 mb-4 border-l-4 border-purple-600">
                    <h3 class="text-xl font-bold text-gray-800">
                        <i class="fas fa-user-graduate mr-2 text-purple-600"></i><%= studentName %> (<%= studentId %>)
                    </h3>
                </div>

                <!-- Student Logbook Table -->
                <div class="glass rounded-2xl overflow-x-auto">
                    <table class="logbook-table w-full">
                        <thead>
                            <tr>
                                <th class="week-col">WEEK</th>
                                <th class="activities-col">RESEARCH ACTIVITIES</th>
                                <th class="notes-col">SUPERVISOR NOTES & SIGNATURE</th>
                                <th class="action-col">ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Logbook logbook : weeks) { 
                                String rowClass = logbook.isApproved() ? "status-approved" : "status-pending";
                            %>
                            <tr class="<%= rowClass %>">
                                <td class="week-col"><%= logbook.getWeek() %></td>
                                <td class="activities-col">
                                    <p class="text-sm"><%= logbook.getActivities() != null ? logbook.getActivities() : "-" %></p>
                                </td>
                                <td class="notes-col">
                                    <% if (logbook.isApproved()) { %>
                                        <div class="text-sm">
                                            <p class="font-semibold"><%= logbook.getSupervisorName() %></p>
                                            <p>Signature: <%= logbook.getSupervisorSignature() %></p>
                                            <p class="text-xs text-gray-600"><%= logbook.getApprovedDate() %></p>
                                        </div>
                                    <% } else { %>
                                        <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="space-y-2">
                                            <input type="hidden" name="action" value="note">
                                            <input type="hidden" name="month" value="<%= month %>">
                                            <input type="hidden" name="studentId" value="<%= studentId %>">
                                            <input type="hidden" name="week" value="<%= logbook.getWeek() %>">
                                            <textarea name="notes" rows="3" placeholder="Add supervisor notes..." class="logbook-textarea w-full text-sm"></textarea>
                                            <button type="submit" class="bg-yellow-600 text-white px-3 py-2 rounded-lg text-xs font-semibold hover:bg-yellow-700">
                                                <i class="fas fa-sticky-note mr-1"></i>Save Notes
                                            </button>
                                        </form>
                                    <% } %>
                                </td>
                                <td class="action-col">
                                    <% if (!logbook.isApproved()) { %>
                                        <div class="flex gap-2">
                                            <a href="<%= request.getContextPath() %>/logbook/view/<%= logbook.getLogbookId() %>" class="bg-blue-600 text-white px-3 py-2 rounded-lg text-xs font-semibold hover:bg-blue-700 inline-block">
                                                <i class="fas fa-eye mr-1"></i>View
                                            </a>
                                            <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="inline-block">
                                                <input type="hidden" name="action" value="approve">
                                                <input type="hidden" name="month" value="<%= month %>">
                                                <input type="hidden" name="studentId" value="<%= studentId %>">
                                                <input type="hidden" name="week" value="<%= logbook.getWeek() %>">
                                                <input type="text" name="signature" placeholder="Signature" class="logbook-input w-28 text-xs" required>
                                                <button type="submit" class="bg-green-600 text-white px-3 py-2 rounded-lg text-xs font-semibold hover:bg-green-700">
                                                    <i class="fas fa-check mr-1"></i>Approve
                                                </button>
                                            </form>
                                        </div>
                                    <% } else { %>
                                        <div class="flex gap-2 items-center">
                                            <a href="<%= request.getContextPath() %>/logbook/view/<%= logbook.getLogbookId() %>" class="bg-blue-600 text-white px-3 py-2 rounded-lg text-xs font-semibold hover:bg-blue-700">
                                                <i class="fas fa-eye mr-1"></i>View
                                            </a>
                                            <span class="logbook-pill approved">
                                                <i class="fas fa-check-circle mr-1"></i>Approved
                                            </span>
                                        </div>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <% } %>
        <% } %>
            </div>
        </div>
    </div>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
<script>
function toggleDropdown(event, dropdownId) {
    event.preventDefault();
    event.stopPropagation();
    const dropdown = document.getElementById(dropdownId);
    const isHidden = dropdown.classList.contains('hidden');
    document.querySelectorAll('[id*="repo-dropdown"]').forEach(function(item) {
        if (item.id !== dropdownId) {
            item.classList.add('hidden');
        }
    });
    if (isHidden) {
        dropdown.classList.remove('hidden');
    } else {
        dropdown.classList.add('hidden');
    }
}

document.addEventListener('click', function() {
    document.querySelectorAll('[id*="repo-dropdown"]').forEach(function(item) {
        item.classList.add('hidden');
    });
});
</script>
</html>



