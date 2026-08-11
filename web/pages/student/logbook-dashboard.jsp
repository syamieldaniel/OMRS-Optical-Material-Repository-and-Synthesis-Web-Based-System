<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.omrs.model.*, java.time.YearMonth" %>
<%
    List<Logbook> logbooks = (List<Logbook>) request.getAttribute("logbooks");
    String month = (String) request.getAttribute("month");
    User user = (User) session.getAttribute("user");
    if (month == null || month.isEmpty()) {
        month = YearMonth.now().toString();
    }
    
    // Calculate stats
    int totalEntries = 0;
    int approvedEntries = 0;
    int pendingEntries = 0;
    if (logbooks != null) {
        totalEntries = logbooks.size();
        for (Logbook lb : logbooks) {
            if (lb.isApproved()) {
                approvedEntries++;
            } else {
                pendingEntries++;
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weekly Logbook - OMRS</title>
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
            min-width: 860px;
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
        .activities-col { width: 55%; }
        .notes-col { width: 39%; }
        .status-approved td { background: rgba(236, 253, 245, 0.88); }
        .status-pending td { background: #ffffff; }
        .logbook-textarea {
            min-height: 8.5rem;
            border: 1px solid rgba(124, 58, 237, 0.20);
            border-radius: 0.85rem;
            background: rgba(248, 250, 252, 0.95);
            padding: 0.9rem;
            outline: none;
        }
        .logbook-textarea:focus {
            border-color: #7c3aed;
            box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.12);
        }
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
        .logbook-pill.pending { background: #fef3c7; color: #92400e; }
        .month-card {
            border-radius: 1rem;
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.16);
            box-shadow: 0 8px 22px rgba(88, 28, 135, 0.07);
        }
        .btn-small { padding: 0.55rem 0.9rem; font-size: 0.85rem; border-radius: 0.75rem; font-weight: 700; }
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
                    <h2 class="text-3xl font-bold text-gray-800">Monthly Logbook - <%= month %></h2>
                    <p class="text-gray-600 mt-1">Record your weekly research activities</p>
                </div>

                <div class="glass rounded-2xl p-6 mb-8">
                    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                        <div>
                            <p class="text-xs font-semibold uppercase tracking-wide text-purple-600 mb-2">Research progress log</p>
                            <h3 class="text-xl font-semibold text-gray-900">Connect weekly progress to your optical material study</h3>
                            <p class="text-gray-700 text-sm mt-2">Use each week to record preparation, sample comparison, UV-Vis/FTIR/SEM analysis, optical-constants calculations, and supervisor feedback.</p>
                        </div>
                        <div class="flex flex-wrap gap-3">
                            <a href="${pageContext.request.contextPath}/student/create" class="bg-purple-600 text-white px-5 py-3 rounded-xl font-semibold">
                                <i class="fas fa-flask mr-2"></i>New Study
                            </a>
                            <a href="${pageContext.request.contextPath}/optical-constants" class="glass px-5 py-3 rounded-xl text-purple-700 font-semibold">
                                <i class="fas fa-wave-square mr-2"></i>Optical Constants
                            </a>
                            <a href="${pageContext.request.contextPath}/repository" class="glass px-5 py-3 rounded-xl text-purple-700 font-semibold">
                                <i class="fas fa-database mr-2"></i>Repository
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Stats -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 lg:gap-6 mb-10">
                    <div class="stat-card glass rounded-2xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 rounded-xl bg-purple-500/10 flex items-center justify-center">
                                <i class="fas fa-book text-purple-400 text-xl"></i>
                            </div>
                            <span class="text-purple-400 text-xs font-medium bg-purple-500/10 px-2 py-1 rounded-full">Total</span>
                        </div>
                        <p class="text-3xl font-bold text-gray-900"><%= totalEntries %></p>
                        <p class="text-gray-700 text-sm mt-1">Logbook Entries</p>
                    </div>
                    
                    <div class="stat-card glass rounded-2xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
                                <i class="fas fa-check text-green-400 text-xl"></i>
                            </div>
                            <span class="text-green-400 text-xs font-medium bg-green-500/10 px-2 py-1 rounded-full">Approved</span>
                        </div>
                        <p class="text-3xl font-bold text-gray-900"><%= approvedEntries %></p>
                        <p class="text-gray-700 text-sm mt-1">Approved</p>
                    </div>
                    
                    <div class="stat-card glass rounded-2xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <div class="w-12 h-12 rounded-xl bg-yellow-500/10 flex items-center justify-center">
                                <i class="fas fa-clock text-yellow-400 text-xl"></i>
                            </div>
                            <span class="text-yellow-400 text-xs font-medium bg-yellow-500/10 px-2 py-1 rounded-full">Pending</span>
                        </div>
                        <p class="text-3xl font-bold text-gray-900"><%= pendingEntries %></p>
                        <p class="text-gray-700 text-sm mt-1">Pending Review</p>
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

                <!-- Logbook Table -->
                <div class="glass rounded-2xl overflow-x-auto">
                    <table class="logbook-table w-full">
                        <thead>
                            <tr>
                                <th class="week-col">WEEK</th>
                                <th class="activities-col">RESEARCH ACTIVITIES</th>
                                <th class="notes-col">SUPERVISOR NOTES & SIGNATURE</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                if (logbooks != null) {
                                    for (Logbook logbook : logbooks) {
                                        String rowClass = logbook.isApproved() ? "status-approved" : "status-pending";
                            %>
                            <tr class="<%= rowClass %>">
                                <td class="week-col"><%= logbook.getWeek() %></td>
                                <td class="activities-col">
                                    <form method="POST" action="<%= request.getContextPath() %>/logbook/dashboard" class="space-y-2">
                                        <input type="hidden" name="action" value="save">
                                        <input type="hidden" name="month" value="<%= month %>">
                                        <input type="hidden" name="week" value="<%= logbook.getWeek() %>">
                                        <textarea name="activities" rows="4" class="logbook-textarea w-full"
                                            <%= logbook.isApproved() ? "readonly" : "" %>><%=  logbook.getActivities() != null ? logbook.getActivities() : "" %></textarea>
                                        <% if (!logbook.isApproved()) { %>
                                            <button type="submit" class="bg-purple-600 text-white btn-small hover:bg-purple-700">
                                                <i class="fas fa-save mr-1"></i>Save
                                            </button>
                                        <% } %>
                                    </form>
                        </td>
                        <td class="notes-col">
                            <div class="mb-3">
                                <p class="text-sm font-semibold text-gray-700 mb-1">Notes:</p>
                                <p class="text-sm"><%= logbook.getSupervisorNotes() != null ? logbook.getSupervisorNotes() : "-" %></p>
                            </div>
                            <% if (logbook.isApproved()) { %>
                                <div class="mb-2">
                                    <p class="text-xs font-semibold text-gray-600">Supervisor: <%= logbook.getSupervisorName() %></p>
                                    <p class="text-xs">Signature: <%= logbook.getSupervisorSignature() %></p>
                                    <p class="text-xs text-gray-500">Date: <%= logbook.getApprovedDate() %></p>
                                </div>
                            <% } else { %>
                                <span class="logbook-pill pending"><i class="fas fa-clock"></i>Pending Supervisor Review</span>
                            <% } %>
                        </td>
                    </tr>
                    <% 
                            }
                        }
                    %>
                </tbody>
            </table>
            </div>

            <!-- Instructions -->
            <div class="mt-8 glass rounded-2xl p-6 bg-blue-50 border-l-4 border-blue-600">
                <h3 class="font-semibold text-blue-800 mb-2"><i class="fas fa-info-circle mr-2"></i>Logbook Notes</h3>
                <ul class="text-blue-700 text-sm space-y-1 ml-6">
                    <li>Record weekly preparation, testing, analysis, and supervisor discussion.</li>
                    <li>Click Save before moving to another week or month.</li>
                    <li>Approved entries become read-only.</li>
                    <li>Your supervisor will add notes and a signature after review.</li>
                </ul>
            </div>
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



