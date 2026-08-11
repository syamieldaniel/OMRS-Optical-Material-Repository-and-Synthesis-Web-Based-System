<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Learning Content - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; box-sizing: border-box; }
        body { background: #f5f1ed; color: #1f2937; font-size: 15px; line-height: 1.6; }
        .surface { background: rgba(255,255,255,0.92); border: 1px solid rgba(148,163,184,0.22); box-shadow: 0 14px 34px rgba(15,23,42,0.07); }
        .hero { background: linear-gradient(135deg, #ffffff 0%, #f8fafc 52%, #f0fdfa 100%); border: 1px solid rgba(20,184,166,0.18); }
        .content-card { background: #fff; border: 1px solid rgba(124,58,237,0.12); transition: transform .2s ease, border-color .2s ease, box-shadow .2s ease; }
        .content-card:hover { transform: translateY(-1px); border-color: rgba(124,58,237,.30); box-shadow: 0 12px 24px rgba(88,28,135,.09); }
        .badge { background: #f5f3ff; color: #6d28d9; border: 1px solid #ede9fe; }
        .input-field { background: #fff; border: 1px solid rgba(124,58,237,.18); }
        .input-field:focus { border-color: #7c3aed; box-shadow: 0 0 0 3px rgba(124,58,237,.13); outline: none; }
        .tab-btn.active { background: #7c3aed; color: #fff; border-color: #7c3aed; }
        .tab-btn { border: 1px solid #e5e7eb; background: #fff; color: #374151; }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        List<LearningMaterial> materials = (List<LearningMaterial>) request.getAttribute("materials");
        List<LearningQuiz> quizzes = (List<LearningQuiz>) request.getAttribute("quizzes");
        int materialCount = materials != null ? materials.size() : 0;
        int quizCount = quizzes != null ? quizzes.size() : 0;
        int totalAttempts = 0;
        int totalQuestions = 0;
        if (quizzes != null) for (LearningQuiz quiz : quizzes) {
            totalAttempts += quiz.getTotalAttempts();
            totalQuestions += quiz.getQuestionCount();
        }
    %>
    <div class="flex min-h-screen">
        <%@ include file="../common/sidebar.jsp" %>

        <main class="flex-1 lg:ml-64 p-4 sm:p-6 lg:p-10 pt-20 lg:pt-10">
            <section class="hero rounded-2xl p-6 lg:p-8 mb-6">
                <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-6">
                    <div>
                        <div class="inline-flex items-center gap-2 rounded-full bg-white border border-teal-100 px-3 py-1 text-sm font-semibold text-teal-700 mb-4">
                            <i class="fas fa-chalkboard-user"></i>
                            Supervisor Content Studio
                        </div>
                        <h1 class="text-3xl lg:text-4xl font-extrabold text-gray-950 mb-2">Manage Learning Content</h1>
                        <p class="text-gray-700 max-w-3xl">Publish lessons, attach references, and build quizzes with as many questions as your learning activity needs.</p>
                    </div>
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 min-w-full xl:min-w-[560px]">
                        <div class="surface rounded-xl p-4"><p class="text-xs uppercase text-gray-500 font-bold">Materials</p><p class="text-2xl font-extrabold text-gray-950"><%= materialCount %></p></div>
                        <div class="surface rounded-xl p-4"><p class="text-xs uppercase text-gray-500 font-bold">Quizzes</p><p class="text-2xl font-extrabold text-gray-950"><%= quizCount %></p></div>
                        <div class="surface rounded-xl p-4"><p class="text-xs uppercase text-gray-500 font-bold">Questions</p><p class="text-2xl font-extrabold text-gray-950"><%= totalQuestions %></p></div>
                        <div class="surface rounded-xl p-4"><p class="text-xs uppercase text-gray-500 font-bold">Attempts</p><p class="text-2xl font-extrabold text-gray-950"><%= totalAttempts %></p></div>
                    </div>
                </div>
            </section>

            <section class="surface rounded-2xl p-5 mb-6">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                    <div class="flex flex-col sm:flex-row gap-3 flex-1">
                        <div class="relative flex-1">
                            <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            <input id="manageSearch" type="text" class="input-field w-full rounded-xl pl-11 pr-4 py-3" placeholder="Search your materials and quizzes">
                        </div>
                        <div class="grid grid-cols-3 gap-2 sm:w-[360px]">
                            <button type="button" class="tab-btn active rounded-xl px-3 py-3 font-bold" data-filter="all">All</button>
                            <button type="button" class="tab-btn rounded-xl px-3 py-3 font-bold" data-filter="material">Materials</button>
                            <button type="button" class="tab-btn rounded-xl px-3 py-3 font-bold" data-filter="quiz">Quizzes</button>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <a href="${pageContext.request.contextPath}/learning/material/create" class="rounded-xl bg-purple-600 px-5 py-3 text-white font-bold"><i class="fas fa-file-circle-plus mr-2"></i>New Material</a>
                        <a href="${pageContext.request.contextPath}/learning/quiz/create" class="rounded-xl border border-purple-100 bg-purple-50 px-5 py-3 text-purple-700 font-bold"><i class="fas fa-square-poll-horizontal mr-2"></i>New Quiz</a>
                    </div>
                </div>
            </section>

            <div class="grid grid-cols-1 xl:grid-cols-2 gap-6">
                <section class="surface rounded-2xl p-6" data-section="material">
                    <div class="flex items-center justify-between mb-5">
                        <h2 class="text-xl font-bold text-gray-950">Your Materials</h2>
                        <span class="badge text-xs px-3 py-1 rounded-full"><%= materialCount %> items</span>
                    </div>
                    <div class="space-y-4">
                        <% if (materials == null || materials.isEmpty()) { %>
                        <div class="rounded-xl border border-dashed border-purple-200 p-8 text-center text-gray-600">You have not published any learning materials yet.</div>
                        <% } else { for (LearningMaterial material : materials) {
                            String materialSearch = ((material.getTitle() != null ? material.getTitle() : "") + " " +
                                (material.getCategory() != null ? material.getCategory() : "") + " " +
                                (material.getDescription() != null ? material.getDescription() : "")).toLowerCase();
                            materialSearch = materialSearch.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                        %>
                        <div class="content-card rounded-xl p-5" data-manage-card data-type="material" data-search="<%= materialSearch %>">
                            <div class="flex items-start justify-between gap-4 mb-3">
                                <div>
                                    <p class="text-xs uppercase tracking-wide text-purple-600 font-bold"><%= material.getCategory() != null && !material.getCategory().isEmpty() ? material.getCategory() : "Nanophysics" %></p>
                                    <h3 class="text-lg font-bold text-gray-950 mt-1"><%= material.getTitle() %></h3>
                                </div>
                                <form action="${pageContext.request.contextPath}/learning/material/delete/<%= material.getMaterialId() %>" method="POST" onsubmit="return confirm('Delete this material?');">
                                    <button type="submit" class="w-10 h-10 rounded-xl border border-red-100 bg-red-50 text-red-600 hover:bg-red-100"><i class="fas fa-trash"></i></button>
                                </form>
                            </div>
                            <p class="text-gray-700 text-sm leading-6"><%= material.getDescription() != null ? material.getDescription() : "Open this material to review lesson content and resources." %></p>
                            <div class="flex flex-wrap gap-2 mt-4 text-xs">
                                <% if (material.getFileName() != null && !material.getFileName().isEmpty()) { %><span class="badge px-3 py-1 rounded-full"><i class="fas fa-paperclip mr-1"></i><%= material.getFileName() %></span><% } %>
                                <% if (material.getExternalLink() != null && !material.getExternalLink().isEmpty()) { %><span class="badge px-3 py-1 rounded-full"><i class="fas fa-link mr-1"></i>External resource</span><% } %>
                            </div>
                            <a href="${pageContext.request.contextPath}/learning/material/view/<%= material.getMaterialId() %>" class="mt-4 inline-flex items-center text-purple-700 font-bold text-sm">Open material<i class="fas fa-arrow-right ml-2"></i></a>
                        </div>
                        <% } } %>
                    </div>
                </section>

                <section class="surface rounded-2xl p-6" data-section="quiz">
                    <div class="flex items-center justify-between mb-5">
                        <h2 class="text-xl font-bold text-gray-950">Your Quizzes</h2>
                        <span class="badge text-xs px-3 py-1 rounded-full"><%= quizCount %> quizzes</span>
                    </div>
                    <div class="space-y-4">
                        <% if (quizzes == null || quizzes.isEmpty()) { %>
                        <div class="rounded-xl border border-dashed border-purple-200 p-8 text-center text-gray-600">You have not created any quizzes yet.</div>
                        <% } else { for (LearningQuiz quiz : quizzes) {
                            String quizSearch = ((quiz.getTitle() != null ? quiz.getTitle() : "") + " " +
                                (quiz.getCategory() != null ? quiz.getCategory() : "") + " " +
                                (quiz.getDescription() != null ? quiz.getDescription() : "")).toLowerCase();
                            quizSearch = quizSearch.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                        %>
                        <div class="content-card rounded-xl p-5" data-manage-card data-type="quiz" data-search="<%= quizSearch %>">
                            <div class="flex items-start justify-between gap-4">
                                <div>
                                    <p class="text-xs uppercase tracking-wide text-teal-600 font-bold"><%= quiz.getCategory() != null && !quiz.getCategory().isEmpty() ? quiz.getCategory() : "Nanophysics" %></p>
                                    <h3 class="text-lg font-bold text-gray-950 mt-1"><%= quiz.getTitle() %></h3>
                                    <p class="text-gray-700 text-sm mt-2"><%= quiz.getDescription() != null ? quiz.getDescription() : "Self-check quiz for revision and learner practice." %></p>
                                </div>
                                <form action="${pageContext.request.contextPath}/learning/quiz/delete/<%= quiz.getQuizId() %>" method="POST" onsubmit="return confirm('Delete this quiz?');">
                                    <button type="submit" class="w-10 h-10 rounded-xl border border-red-100 bg-red-50 text-red-600 hover:bg-red-100"><i class="fas fa-trash"></i></button>
                                </form>
                            </div>
                            <div class="flex flex-wrap gap-2 mt-4 text-xs">
                                <span class="badge px-3 py-1 rounded-full"><%= quiz.getQuestionCount() %> questions</span>
                                <span class="badge px-3 py-1 rounded-full"><%= quiz.getTotalAttempts() %> attempts</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/learning/quiz/view/<%= quiz.getQuizId() %>" class="mt-4 inline-flex items-center text-purple-700 font-bold text-sm">Open quiz<i class="fas fa-arrow-right ml-2"></i></a>
                        </div>
                        <% } } %>
                    </div>
                </section>
            </div>
        </main>
    </div>

    <script>
        const searchInput = document.getElementById('manageSearch');
        const cards = Array.from(document.querySelectorAll('[data-manage-card]'));
        const sections = Array.from(document.querySelectorAll('[data-section]'));
        const tabs = Array.from(document.querySelectorAll('.tab-btn'));
        let activeFilter = 'all';

        function applyFilters() {
            const query = searchInput.value.trim().toLowerCase();
            cards.forEach(card => {
                const typeMatch = activeFilter === 'all' || card.dataset.type === activeFilter;
                const queryMatch = !query || card.dataset.search.includes(query);
                card.style.display = typeMatch && queryMatch ? '' : 'none';
            });
            sections.forEach(section => {
                section.style.display = activeFilter === 'all' || section.dataset.section === activeFilter ? '' : 'none';
            });
        }

        searchInput.addEventListener('input', applyFilters);
        tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                activeFilter = tab.dataset.filter;
                tabs.forEach(item => item.classList.toggle('active', item === tab));
                applyFilters();
            });
        });
    </script>
    <%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>
