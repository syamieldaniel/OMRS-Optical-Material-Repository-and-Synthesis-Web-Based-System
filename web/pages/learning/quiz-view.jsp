<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; }
        body { background: #f5f1ed; color: #1f2937; }
        .glass { background: rgba(255,255,255,0.88); backdrop-filter: blur(18px); border: 1px solid rgba(167,139,250,0.22); box-shadow: 0 8px 32px rgba(0,0,0,0.08); }
        .sidebar { background: linear-gradient(180deg, #7c3aed 0%, #6d28d9 100%); }
        .nav-item { transition: all 0.3s ease; color: #fff; font-weight: 500; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,0.15); border-left: 3px solid #fbbf24; }
        .btn-primary { background: linear-gradient(135deg, #a78bfa 0%, #d8b4fe 100%); color: #1a202c; font-weight: 600; }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        String homeUrl = "STUDENT".equals(user.getRole()) ? request.getContextPath() + "/student/dashboard"
                : "SUPERVISOR".equals(user.getRole()) ? request.getContextPath() + "/supervisor/dashboard"
                : request.getContextPath() + "/repository";
        String homeLabel = "RESEARCHER".equals(user.getRole()) ? "Repository" : "Dashboard";
        String userDisplayName = user.getFullName() != null && !user.getFullName().isEmpty() ? user.getFullName() : user.getUsername();
        String userInitial = userDisplayName != null && !userDisplayName.isEmpty() ? userDisplayName.substring(0, 1).toUpperCase() : "?";
        LearningQuiz quiz = (LearningQuiz) request.getAttribute("quiz");
        List<LearningQuizAttempt> attempts = (List<LearningQuizAttempt>) request.getAttribute("attempts");
        LearningQuizAttempt latestAttempt = (LearningQuizAttempt) request.getAttribute("latestAttempt");
    %>
    <div class="flex min-h-screen">
    <%@ include file="../common/sidebar.jsp" %>
    <main class="flex-1 lg:ml-64 max-w-5xl mx-auto w-full p-6 lg:p-10">
        <a href="${pageContext.request.contextPath}/learning" class="text-purple-700 font-medium text-sm"><i class="fas fa-arrow-left mr-2"></i>Back to Learning Hub</a>
        <div class="glass rounded-2xl p-8 mt-4">
            <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4 mb-6">
                <div>
                    <p class="text-xs uppercase tracking-wide text-green-600 font-semibold"><%= quiz.getCategory() %></p>
                    <h1 class="text-3xl font-bold text-gray-900 mt-2"><%= quiz.getTitle() %></h1>
                    <p class="text-gray-700 mt-3"><%= quiz.getDescription() != null ? quiz.getDescription() : "" %></p>
                    <p class="text-sm text-gray-500 mt-3">Created by <%= quiz.getUploadedByName() %> • <%= quiz.getQuestionCount() %> questions</p>
                </div>
                <% if (!"SUPERVISOR".equals(user.getRole()) && latestAttempt != null) { %>
                <div class="rounded-xl bg-purple-50 px-5 py-4 text-center">
                    <p class="text-sm text-gray-600">Latest score</p>
                    <p class="text-3xl font-bold text-purple-700"><%= latestAttempt.getScore() %>/<%= latestAttempt.getTotalQuestions() %></p>
                </div>
                <% } %>
            </div>

            <% if ("SUPERVISOR".equals(user.getRole())) { %>
            <section class="mb-8">
                <h2 class="text-xl font-semibold mb-4">Questions</h2>
                <div class="space-y-4">
                    <% for (LearningQuizQuestion question : quiz.getQuestions()) { %>
                    <div class="rounded-xl border border-purple-100 bg-white p-5">
                        <p class="font-semibold text-gray-900"><%= question.getQuestionOrder() %>. <%= question.getQuestionText() %></p>
                        <ul class="mt-3 space-y-1 text-sm text-gray-700">
                            <li>A. <%= question.getOptionA() %></li>
                            <li>B. <%= question.getOptionB() %></li>
                            <li>C. <%= question.getOptionC() %></li>
                            <li>D. <%= question.getOptionD() %></li>
                        </ul>
                        <p class="mt-3 text-sm text-green-700 font-medium">Correct answer: <%= question.getCorrectOption() %></p>
                        <% if (question.getExplanation() != null && !question.getExplanation().isEmpty()) { %>
                        <p class="mt-2 text-sm text-gray-600"><%= question.getExplanation() %></p>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </section>
            <section>
                <h2 class="text-xl font-semibold mb-4">Recent Attempts</h2>
                <div class="space-y-3">
                    <% if (attempts == null || attempts.isEmpty()) { %>
                    <p class="text-gray-600">No one has attempted this quiz yet.</p>
                    <% } else { for (LearningQuizAttempt attempt : attempts) { %>
                    <div class="rounded-xl border border-purple-100 bg-white px-5 py-4 flex items-center justify-between">
                        <div>
                            <p class="font-medium text-gray-900"><%= attempt.getUsername() %></p>
                            <p class="text-xs text-gray-500"><%= attempt.getSubmittedAt() %></p>
                        </div>
                        <p class="text-purple-700 font-semibold"><%= attempt.getScore() %>/<%= attempt.getTotalQuestions() %></p>
                    </div>
                    <% } } %>
                </div>
            </section>
            <% } else { %>
            <form action="${pageContext.request.contextPath}/learning/quiz/submit/<%= quiz.getQuizId() %>" method="POST" class="space-y-5">
                <% for (LearningQuizQuestion question : quiz.getQuestions()) { %>
                <section class="rounded-xl border border-purple-100 bg-white p-5">
                    <p class="font-semibold text-gray-900"><%= question.getQuestionOrder() %>. <%= question.getQuestionText() %></p>
                    <div class="mt-4 space-y-3">
                        <label class="flex items-center gap-3"><input type="radio" name="answer_<%= question.getQuestionId() %>" value="A" required> <span>A. <%= question.getOptionA() %></span></label>
                        <label class="flex items-center gap-3"><input type="radio" name="answer_<%= question.getQuestionId() %>" value="B"> <span>B. <%= question.getOptionB() %></span></label>
                        <label class="flex items-center gap-3"><input type="radio" name="answer_<%= question.getQuestionId() %>" value="C"> <span>C. <%= question.getOptionC() %></span></label>
                        <label class="flex items-center gap-3"><input type="radio" name="answer_<%= question.getQuestionId() %>" value="D"> <span>D. <%= question.getOptionD() %></span></label>
                    </div>
                    <% if (request.getParameter("submitted") != null && question.getExplanation() != null && !question.getExplanation().isEmpty()) { %>
                    <div class="mt-4 rounded-lg bg-purple-50 px-4 py-3 text-sm text-gray-700"><%= question.getExplanation() %></div>
                    <% } %>
                </section>
                <% } %>
                <button type="submit" class="btn-primary px-6 py-3 rounded-xl">Submit Quiz</button>
            </form>
            <% } %>
        </div>
    </main>
    </div>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>

