<%@ page import="com.omrs.model.User" %>
<%
    User sidebarUser = (User) session.getAttribute("user");
    String sidebarRole = sidebarUser != null ? sidebarUser.getRole() : "";
    String sidebarStudentType = (String) session.getAttribute("studentType");
    boolean sidebarIsStudent = "STUDENT".equals(sidebarRole);
    boolean sidebarIsSupervisor = "SUPERVISOR".equals(sidebarRole);
    boolean sidebarIsFypStudent = sidebarIsStudent && "FYP".equals(sidebarStudentType);
    String sidebarUri = request.getRequestURI();
    String sidebarPath = sidebarUri != null ? sidebarUri.substring(request.getContextPath().length()) : "";
    String sidebarDisplayName = sidebarUser != null && sidebarUser.getFullName() != null && !sidebarUser.getFullName().trim().isEmpty()
            ? sidebarUser.getFullName()
            : sidebarUser != null ? sidebarUser.getUsername() : "User";
    String sidebarInitial = sidebarDisplayName != null && !sidebarDisplayName.isEmpty() ? sidebarDisplayName.substring(0, 1).toUpperCase() : "?";
    String sidebarRoleLabel = sidebarIsStudent ? "Student" : sidebarIsSupervisor ? "Supervisor" : "Researcher";
    boolean sidebarRepositoryActive = sidebarPath.startsWith("/repository");
    boolean sidebarLearningActive = sidebarPath.startsWith("/learning");
    boolean sidebarOpticalActive = sidebarPath.startsWith("/optical-constants");
    boolean sidebarNotificationsActive = sidebarPath.startsWith("/notifications");
    boolean sidebarProfileActive = sidebarPath.startsWith("/profile");
    boolean sidebarLogbookActive = sidebarPath.startsWith("/logbook");
%>

<button type="button" id="mobileSidebarToggle" class="omrs-mobile-menu-button lg:hidden" onclick="toggleMobileSidebar()" aria-controls="omrsSidebar" aria-expanded="false">
    <i class="fas fa-bars"></i>
    <span>Menu</span>
</button>
<div id="mobileSidebarOverlay" class="omrs-mobile-sidebar-overlay lg:hidden" onclick="closeMobileSidebar()" aria-hidden="true"></div>

<aside id="omrsSidebar" class="sidebar w-64 fixed h-full hidden lg:block" aria-label="Primary navigation">
    <div class="p-6">
        <div class="flex items-center space-x-3 mb-10">
            <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center">
                <img src="${pageContext.request.contextPath}/img/omrs-logo.svg" alt="OMRS" class="w-8 h-8">
            </div>
            <span class="text-xl font-bold text-white">OMRS</span>
        </div>

        <nav class="space-y-2">
            <% if (sidebarIsStudent) { %>
            <a href="${pageContext.request.contextPath}/student/dashboard" class="nav-item <%= sidebarPath.startsWith("/student/dashboard") || sidebarPath.startsWith("/student/view") ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-home w-5"></i>
                <span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/create" class="nav-item <%= sidebarPath.startsWith("/student/create") || sidebarPath.startsWith("/student/edit") ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-plus w-5"></i>
                <span>New Experiment</span>
            </a>
            <% if (sidebarIsFypStudent) { %>
            <a href="${pageContext.request.contextPath}/logbook/dashboard" class="nav-item <%= sidebarLogbookActive ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-book-open w-5"></i>
                <span>Student Logbooks</span>
            </a>
            <% } %>
            <% } else if (sidebarIsSupervisor) { %>
            <a href="${pageContext.request.contextPath}/supervisor/dashboard" class="nav-item <%= sidebarPath.startsWith("/supervisor/dashboard") || sidebarPath.startsWith("/supervisor/review") ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-home w-5"></i>
                <span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/supervisor/students" class="nav-item <%= sidebarPath.startsWith("/supervisor/students") || sidebarPath.startsWith("/supervisor/student") ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-users w-5"></i>
                <span>My Students</span>
            </a>
            <a href="${pageContext.request.contextPath}/logbook/dashboard" class="nav-item <%= sidebarLogbookActive ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-book-open w-5"></i>
                <span>Student Logbooks</span>
            </a>
            <% } %>

            <a href="${pageContext.request.contextPath}/learning" class="nav-item <%= sidebarLearningActive ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-graduation-cap w-5"></i>
                <span>Learning Materials</span>
            </a>
            <a href="${pageContext.request.contextPath}/optical-constants" class="nav-item <%= sidebarOpticalActive ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-wave-square w-5"></i>
                <span>Optical Constants</span>
            </a>

            <% if (sidebarIsSupervisor) { %>
            <a href="${pageContext.request.contextPath}/supervisor/applications" class="nav-item <%= sidebarPath.startsWith("/supervisor/applications") ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-user-plus w-5"></i>
                <span>Applications</span>
            </a>
            <% } %>

            <div class="relative group">
                <button onclick="toggleSidebarDropdown(event, 'repo-dropdown-main')" class="nav-item <%= sidebarRepositoryActive ? "active text-white" : "text-purple-100 hover:text-white" %> w-full flex items-center space-x-3 px-4 py-3 rounded-lg">
                    <i class="fas fa-database w-5"></i>
                    <span>Repository</span>
                    <i class="fas fa-chevron-down w-4 ml-auto transition"></i>
                </button>
                <div id="repo-dropdown-main" class="<%= sidebarRepositoryActive ? "" : "hidden" %>">
                    <a href="${pageContext.request.contextPath}/repository" onclick="closeMobileSidebar()"><i class="fas fa-home w-4 mr-2"></i>Home</a>
                    <a href="${pageContext.request.contextPath}/repository/browse" onclick="closeMobileSidebar()"><i class="fas fa-th-large w-4 mr-2"></i>Browse</a>
                    <a href="${pageContext.request.contextPath}/repository/search" onclick="closeMobileSidebar()"><i class="fas fa-search w-4 mr-2"></i>Search</a>
                    <a href="${pageContext.request.contextPath}/repository/public" onclick="closeMobileSidebar()"><i class="fas fa-globe w-4 mr-2"></i>Public Research</a>
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/notifications" class="nav-item <%= sidebarNotificationsActive ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-bell w-5"></i>
                <span>Notifications</span>
                <% if (request.getAttribute("unreadNotificationCount") instanceof Integer && ((Integer) request.getAttribute("unreadNotificationCount")) > 0) { %>
                <span class="ml-auto bg-yellow-400 text-purple-900 text-xs font-bold min-w-[1.5rem] h-6 px-2 rounded-full flex items-center justify-center"><%= request.getAttribute("unreadNotificationCount") %></span>
                <% } %>
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="nav-item <%= sidebarProfileActive ? "active text-white" : "text-purple-100 hover:text-white" %> flex items-center space-x-3 px-4 py-3 rounded-lg" onclick="closeMobileSidebar()">
                <i class="fas fa-user w-5"></i>
                <span>Profile</span>
            </a>
        </nav>
    </div>

    <div class="absolute bottom-0 left-0 right-0 p-6 border-t border-purple-500/30">
        <div class="flex items-center space-x-3">
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 flex items-center justify-center overflow-hidden">
                <% if (sidebarUser != null && sidebarUser.getProfilePicture() != null && !sidebarUser.getProfilePicture().trim().isEmpty()) { %>
                <img src="${pageContext.request.contextPath}<%= sidebarUser.getProfilePicture() %>" alt="Profile picture" class="w-full h-full object-cover">
                <% } else { %>
                <span class="text-purple-800 font-bold"><%= sidebarInitial %></span>
                <% } %>
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-white text-sm font-semibold truncate"><%= sidebarDisplayName %></p>
                <p class="text-purple-200 text-xs"><%= sidebarRoleLabel %></p>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="text-purple-200 hover:text-red-300 transition">
                <i class="fas fa-sign-out-alt"></i>
            </a>
        </div>
    </div>
</aside>

<script>
    function toggleSidebarDropdown(event, dropdownId) {
        event.preventDefault();
        event.stopPropagation();
        const dropdown = document.getElementById(dropdownId);
        if (dropdown) {
            dropdown.classList.toggle('hidden');
        }
    }

    function toggleMobileSidebar() {
        const sidebar = document.getElementById('omrsSidebar');
        const overlay = document.getElementById('mobileSidebarOverlay');
        const toggle = document.getElementById('mobileSidebarToggle');
        const isOpen = sidebar && sidebar.classList.toggle('mobile-open');
        if (overlay) {
            overlay.classList.toggle('mobile-open', isOpen);
        }
        if (toggle) {
            toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        }
        document.body.classList.toggle('mobile-sidebar-open', isOpen);
    }

    function closeMobileSidebar() {
        const sidebar = document.getElementById('omrsSidebar');
        const overlay = document.getElementById('mobileSidebarOverlay');
        const toggle = document.getElementById('mobileSidebarToggle');
        if (sidebar) {
            sidebar.classList.remove('mobile-open');
        }
        if (overlay) {
            overlay.classList.remove('mobile-open');
        }
        if (toggle) {
            toggle.setAttribute('aria-expanded', 'false');
        }
        document.body.classList.remove('mobile-sidebar-open');
    }

    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeMobileSidebar();
        }
    });
</script>
