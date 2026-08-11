<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.omrs.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Learning Material - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; }
        body { background: #f5f1ed; color: #1f2937; }
        .glass { background: rgba(255,255,255,0.88); backdrop-filter: blur(18px); border: 1px solid rgba(167,139,250,0.22); box-shadow: 0 8px 32px rgba(0,0,0,0.08); }
        .sidebar { background: linear-gradient(180deg, #7c3aed 0%, #6d28d9 100%); }
        .nav-item { transition: all 0.3s ease; color: #fff; font-weight: 500; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,0.15); border-left: 3px solid #fbbf24; }
        .input-field { background: #fff; border: 1px solid rgba(167,139,250,0.25); }
        .btn-primary { background: linear-gradient(135deg, #a78bfa 0%, #d8b4fe 100%); color: #1a202c; font-weight: 600; }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        String userDisplayName = user.getFullName() != null && !user.getFullName().isEmpty() ? user.getFullName() : user.getUsername();
        String userInitial = userDisplayName != null && !userDisplayName.isEmpty() ? userDisplayName.substring(0, 1).toUpperCase() : "?";
    %>
    <div class="flex min-h-screen">
    <%@ include file="../common/sidebar.jsp" %>
    <main class="flex-1 lg:ml-64 max-w-4xl mx-auto w-full p-6 lg:p-10">
        <a href="${pageContext.request.contextPath}/learning/manage" class="text-purple-700 font-medium text-sm"><i class="fas fa-arrow-left mr-2"></i>Back to Manage Content</a>
        <div class="glass rounded-2xl p-8 mt-4">
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Publish Learning Material</h1>
            <p class="text-gray-700 mb-6">Upload lecture notes, lab references, or a guided reading page for nanophysics learners.</p>
            <% if (request.getAttribute("error") != null) { %>
            <div class="mb-6 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-red-700"><%= request.getAttribute("error") %></div>
            <% } %>
            <form action="${pageContext.request.contextPath}/learning/material/create" method="POST" enctype="multipart/form-data" class="space-y-5">
                <div>
                    <label class="block text-sm font-medium mb-2">Title</label>
                    <input type="text" name="title" required class="input-field w-full px-4 py-3 rounded-xl" placeholder="Introduction to Quantum Confinement in Nanomaterials">
                </div>
                <div>
                    <label class="block text-sm font-medium mb-2">Category</label>
                    <input type="text" name="category" class="input-field w-full px-4 py-3 rounded-xl" placeholder="Nanophysics Fundamentals">
                </div>
                <div>
                    <label class="block text-sm font-medium mb-2">Short Description</label>
                    <textarea name="description" rows="3" class="input-field w-full px-4 py-3 rounded-xl" placeholder="Briefly describe what students will learn from this material."></textarea>
                </div>
                <div>
                    <label class="block text-sm font-medium mb-2">Lesson Content</label>
                    <textarea name="content" rows="10" class="input-field w-full px-4 py-3 rounded-xl" placeholder="Paste your lecture notes, explanations, reading guide, or experiment theory here."></textarea>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                    <div>
                        <label class="block text-sm font-medium mb-2">External Resource Link</label>
                        <input type="url" name="externalLink" class="input-field w-full px-4 py-3 rounded-xl" placeholder="https://...">
                    </div>
                    <div>
                        <label class="block text-sm font-medium mb-2">Upload File</label>
                        <input type="file" name="materialFile" accept=".pdf,.doc,.docx,.ppt,.pptx,.txt,.jpg,.png" class="input-field w-full px-4 py-3 rounded-xl">
                    </div>
                </div>
                <div class="flex gap-3 pt-2">
                    <a href="${pageContext.request.contextPath}/learning/manage" class="glass px-5 py-3 rounded-xl text-gray-700 font-medium">Cancel</a>
                    <button type="submit" class="btn-primary px-5 py-3 rounded-xl">Publish Material</button>
                </div>
            </form>
        </div>
    </main>
    </div>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>

