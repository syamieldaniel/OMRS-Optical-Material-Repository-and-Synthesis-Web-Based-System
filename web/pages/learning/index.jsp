<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Materials - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; box-sizing: border-box; }
        body { background: #f5f1ed; color: #1f2937; font-size: 15px; line-height: 1.6; }
        .surface { background: rgba(255,255,255,0.92); border: 1px solid rgba(148,163,184,0.22); box-shadow: 0 14px 34px rgba(15,23,42,0.07); }
        .hero { background: linear-gradient(135deg, #ffffff 0%, #f8fafc 52%, #eef2ff 100%); border: 1px solid rgba(124,58,237,0.14); }
        .content-card { background: #fff; border: 1px solid rgba(124,58,237,0.12); transition: transform .2s ease, border-color .2s ease, box-shadow .2s ease; }
        .content-card:hover { transform: translateY(-2px); border-color: rgba(124,58,237,.30); box-shadow: 0 14px 28px rgba(88,28,135,.10); }
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
        int totalQuestions = 0;
        if (quizzes != null) for (LearningQuiz quiz : quizzes) totalQuestions += quiz.getQuestionCount();
    %>
    <div class="flex min-h-screen">
        <%@ include file="../common/sidebar.jsp" %>

        <main class="flex-1 lg:ml-64 p-4 sm:p-6 lg:p-10 pt-20 lg:pt-10">
            <section class="hero rounded-2xl p-6 lg:p-8 mb-6">
                <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-6">
                    <div>
                        <div class="inline-flex items-center gap-2 rounded-full bg-white border border-purple-100 px-3 py-1 text-sm font-semibold text-purple-700 mb-4">
                            <i class="fas fa-book-open"></i>
                            Learning Hub
                        </div>
                        <h1 class="text-3xl lg:text-4xl font-extrabold text-gray-950 mb-2">Learning Materials</h1>
                        <p class="text-gray-700 max-w-3xl">Review nanophysics notes, supporting files, external references, and practice quizzes prepared by supervisors.</p>
                    </div>
                    <div class="grid grid-cols-3 gap-3 min-w-full xl:min-w-[420px]">
                        <div class="surface rounded-xl p-4">
                            <p class="text-xs uppercase text-gray-500 font-bold">Materials</p>
                            <p class="text-2xl font-extrabold text-gray-950"><%= materialCount %></p>
                        </div>
                        <div class="surface rounded-xl p-4">
                            <p class="text-xs uppercase text-gray-500 font-bold">Quizzes</p>
                            <p class="text-2xl font-extrabold text-gray-950"><%= quizCount %></p>
                        </div>
                        <div class="surface rounded-xl p-4">
                            <p class="text-xs uppercase text-gray-500 font-bold">Questions</p>
                            <p class="text-2xl font-extrabold text-gray-950"><%= totalQuestions %></p>
                        </div>
                    </div>
                </div>
            </section>

            <section class="surface rounded-2xl p-5 mb-6">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                    <div class="flex flex-col sm:flex-row gap-3 flex-1">
                        <div class="relative flex-1">
                            <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            <input id="learningSearch" type="text" class="input-field w-full rounded-xl pl-11 pr-4 py-3" placeholder="Search title, category, author, or description">
                        </div>
                        <div class="grid grid-cols-3 gap-2 sm:w-[360px]">
                            <button type="button" class="tab-btn active rounded-xl px-3 py-3 font-bold" data-filter="all">All</button>
                            <button type="button" class="tab-btn rounded-xl px-3 py-3 font-bold" data-filter="material">Materials</button>
                            <button type="button" class="tab-btn rounded-xl px-3 py-3 font-bold" data-filter="quiz">Quizzes</button>
                        </div>
                    </div>
                    <% if ("SUPERVISOR".equals(user.getRole())) { %>
                    <div class="flex gap-3">
                        <a href="${pageContext.request.contextPath}/learning/material/create" class="rounded-xl bg-purple-600 px-5 py-3 text-white font-bold"><i class="fas fa-file-circle-plus mr-2"></i>Material</a>
                        <a href="${pageContext.request.contextPath}/learning/quiz/create" class="rounded-xl border border-purple-100 bg-purple-50 px-5 py-3 text-purple-700 font-bold"><i class="fas fa-square-poll-horizontal mr-2"></i>Quiz</a>
                    </div>
                    <% } %>
                </div>
            </section>

            <% if ("STUDENT".equals(user.getRole())) { %>
            <section class="surface rounded-2xl p-5 mb-6">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                    <div>
                        <h2 class="text-lg font-bold text-gray-950">Prepare before recording experiments</h2>
                        <p class="text-sm text-gray-600 mt-1">Use lessons and quizzes to revise optical material concepts before creating experiment records.</p>
                    </div>
                    <div class="flex flex-wrap gap-3">
                        <a href="${pageContext.request.contextPath}/student/create" class="rounded-xl bg-purple-600 px-5 py-3 text-white font-bold"><i class="fas fa-flask mr-2"></i>Create Study</a>
                        <a href="${pageContext.request.contextPath}/optical-constants" class="rounded-xl border border-cyan-100 bg-cyan-50 px-5 py-3 text-cyan-700 font-bold"><i class="fas fa-wave-square mr-2"></i>Optical Constants</a>
                    </div>
                </div>
            </section>
            <% } %>

            <div class="grid grid-cols-1 xl:grid-cols-2 gap-6" id="learningGrid">
                <section class="surface rounded-2xl p-6" data-section="material">
                    <div class="flex items-center justify-between mb-5">
                        <h2 class="text-xl font-bold text-gray-950">Materials Library</h2>
                        <span class="badge text-xs px-3 py-1 rounded-full"><%= materialCount %> items</span>
                    </div>
                    <div class="space-y-4">
                        <% if (materials == null || materials.isEmpty()) { %>
                        <div class="rounded-xl border border-dashed border-purple-200 p-8 text-center text-gray-600">No learning materials have been published yet.</div>
                        <% } else { for (LearningMaterial material : materials) {
                            String materialSearch = ((material.getTitle() != null ? material.getTitle() : "") + " " +
                                (material.getCategory() != null ? material.getCategory() : "") + " " +
                                (material.getDescription() != null ? material.getDescription() : "") + " " +
                                (material.getUploadedByName() != null ? material.getUploadedByName() : "")).toLowerCase();
                            materialSearch = materialSearch.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                        %>
                        <a href="${pageContext.request.contextPath}/learning/material/view/<%= material.getMaterialId() %>" class="content-card block rounded-xl p-5" data-learning-card data-type="material" data-search="<%= materialSearch %>">
                            <div class="flex items-start justify-between gap-4 mb-3">
                                <div>
                                    <p class="text-xs uppercase tracking-wide text-purple-600 font-bold"><%= material.getCategory() != null && !material.getCategory().isEmpty() ? material.getCategory() : "Nanophysics" %></p>
                                    <h3 class="text-lg font-bold text-gray-950 mt-1"><%= material.getTitle() %></h3>
                                </div>
                                <i class="fas fa-file-lines text-purple-500 text-xl mt-1"></i>
                            </div>
                            <p class="text-gray-700 text-sm leading-6"><%= material.getDescription() != null ? material.getDescription() : "Open this material to read the lesson and access the resources." %></p>
                            <div class="flex flex-wrap gap-2 mt-4 text-xs">
                                <% if (material.getFileName() != null && !material.getFileName().isEmpty()) { %><span class="badge px-3 py-1 rounded-full"><i class="fas fa-paperclip mr-1"></i>File</span><% } %>
                                <% if (material.getExternalLink() != null && !material.getExternalLink().isEmpty()) { %><span class="badge px-3 py-1 rounded-full"><i class="fas fa-link mr-1"></i>Link</span><% } %>
                                <span class="badge px-3 py-1 rounded-full">By <%= material.getUploadedByName() %></span>
                            </div>
                        </a>
                        <% } } %>
                    </div>
                </section>

                <section class="surface rounded-2xl p-6" data-section="quiz">
                    <div class="flex items-center justify-between mb-5">
                        <h2 class="text-xl font-bold text-gray-950">Practice Quizzes</h2>
                        <span class="badge text-xs px-3 py-1 rounded-full"><%= quizCount %> quizzes</span>
                    </div>
                    <div class="space-y-4">
                        <% if (quizzes == null || quizzes.isEmpty()) { %>
                        <div class="rounded-xl border border-dashed border-purple-200 p-8 text-center text-gray-600">No quizzes yet. Check back after supervisors publish one.</div>
                        <% } else { for (LearningQuiz quiz : quizzes) {
                            String quizSearch = ((quiz.getTitle() != null ? quiz.getTitle() : "") + " " +
                                (quiz.getCategory() != null ? quiz.getCategory() : "") + " " +
                                (quiz.getDescription() != null ? quiz.getDescription() : "") + " " +
                                (quiz.getUploadedByName() != null ? quiz.getUploadedByName() : "")).toLowerCase();
                            quizSearch = quizSearch.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                        %>
                        <a href="${pageContext.request.contextPath}/learning/quiz/view/<%= quiz.getQuizId() %>" class="content-card block rounded-xl p-5" data-learning-card data-type="quiz" data-search="<%= quizSearch %>">
                            <div class="flex items-start justify-between gap-4">
                                <div>
                                    <p class="text-xs uppercase tracking-wide text-teal-600 font-bold"><%= quiz.getCategory() != null && !quiz.getCategory().isEmpty() ? quiz.getCategory() : "Nanophysics" %></p>
                                    <h3 class="text-lg font-bold text-gray-950 mt-1"><%= quiz.getTitle() %></h3>
                                    <p class="text-gray-700 text-sm mt-2"><%= quiz.getDescription() != null ? quiz.getDescription() : "Self-check quiz for nanophysics revision." %></p>
                                </div>
                                <i class="fas fa-circle-play text-purple-500 text-xl mt-1"></i>
                            </div>
                            <div class="flex flex-wrap gap-2 mt-4 text-xs">
                                <span class="badge px-3 py-1 rounded-full"><%= quiz.getQuestionCount() %> questions</span>
                                <span class="badge px-3 py-1 rounded-full"><%= quiz.getTotalAttempts() %> attempts</span>
                                <span class="badge px-3 py-1 rounded-full">By <%= quiz.getUploadedByName() %></span>
                            </div>
                        </a>
                        <% } } %>
                    </div>
                </section>
            </div>
        </main>
    </div>

    <script>
        const searchInput = document.getElementById('learningSearch');
        const cards = Array.from(document.querySelectorAll('[data-learning-card]'));
        const sections = Array.from(document.querySelectorAll('[data-section]'));
        const tabs = Array.from(document.querySelectorAll('.tab-btn'));
        let activeFilter = 'all';

        function applyLearningFilters() {
            const query = searchInput.value.trim().toLowerCase();
            cards.forEach(card => {
                const typeMatch = activeFilter === 'all' || card.dataset.type === activeFilter;
                const queryMatch = !query || card.dataset.search.includes(query);
                card.style.display = typeMatch && queryMatch ? '' : 'none';
            });
            sections.forEach(section => {
                const sectionMatch = activeFilter === 'all' || section.dataset.section === activeFilter;
                section.style.display = sectionMatch ? '' : 'none';
            });
        }

        searchInput.addEventListener('input', applyLearningFilters);
        tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                activeFilter = tab.dataset.filter;
                tabs.forEach(item => item.classList.toggle('active', item === tab));
                applyLearningFilters();
            });
        });
    </script>
    <%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>
