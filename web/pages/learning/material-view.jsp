<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Learning Material - OMRS</title>
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
        LearningMaterial material = (LearningMaterial) request.getAttribute("material");
        User user = (User) session.getAttribute("user");
        String homeUrl = "STUDENT".equals(user.getRole()) ? request.getContextPath() + "/student/dashboard"
                : "SUPERVISOR".equals(user.getRole()) ? request.getContextPath() + "/supervisor/dashboard"
                : request.getContextPath() + "/repository";
        String homeLabel = "RESEARCHER".equals(user.getRole()) ? "Repository" : "Dashboard";
        String userDisplayName = user.getFullName() != null && !user.getFullName().isEmpty() ? user.getFullName() : user.getUsername();
        String userInitial = userDisplayName != null && !userDisplayName.isEmpty() ? userDisplayName.substring(0, 1).toUpperCase() : "?";
        boolean hasFile = material.getFileName() != null && !material.getFileName().isEmpty();
        boolean isPdf = hasFile && material.getFileName().toLowerCase().endsWith(".pdf");
        String externalLink = material.getExternalLink();
        String youtubeEmbedUrl = null;
        if (externalLink != null && !externalLink.trim().isEmpty()) {
            String trimmedLink = externalLink.trim();
            String videoId = null;

            int watchIndex = trimmedLink.indexOf("v=");
            if (watchIndex >= 0) {
                videoId = trimmedLink.substring(watchIndex + 2);
                int ampIndex = videoId.indexOf('&');
                if (ampIndex >= 0) {
                    videoId = videoId.substring(0, ampIndex);
                }
            } else {
                int shortIndex = trimmedLink.indexOf("youtu.be/");
                if (shortIndex >= 0) {
                    videoId = trimmedLink.substring(shortIndex + 9);
                    int queryIndex = videoId.indexOf('?');
                    if (queryIndex >= 0) {
                        videoId = videoId.substring(0, queryIndex);
                    }
                    int ampIndex = videoId.indexOf('&');
                    if (ampIndex >= 0) {
                        videoId = videoId.substring(0, ampIndex);
                    }
                } else {
                    int embedIndex = trimmedLink.indexOf("/embed/");
                    if (embedIndex >= 0) {
                        videoId = trimmedLink.substring(embedIndex + 7);
                        int queryIndex = videoId.indexOf('?');
                        if (queryIndex >= 0) {
                            videoId = videoId.substring(0, queryIndex);
                        }
                        int slashIndex = videoId.indexOf('/');
                        if (slashIndex >= 0) {
                            videoId = videoId.substring(0, slashIndex);
                        }
                    }
                }
            }

            if (videoId != null && !videoId.trim().isEmpty()) {
                youtubeEmbedUrl = "https://www.youtube.com/embed/" + videoId.trim();
            }
        }
    %>
    <div class="flex min-h-screen">
    <%@ include file="../common/sidebar.jsp" %>
    <main class="flex-1 lg:ml-64 max-w-5xl mx-auto w-full p-6 lg:p-10">
        <a href="${pageContext.request.contextPath}/learning" class="text-purple-700 font-medium text-sm"><i class="fas fa-arrow-left mr-2"></i>Back to Learning Hub</a>
        <div class="glass rounded-2xl p-8 mt-4">
            <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4 mb-6">
                <div>
                    <p class="text-xs uppercase tracking-wide text-purple-600 font-semibold"><%= material.getCategory() %></p>
                    <h1 class="text-3xl font-bold text-gray-900 mt-2"><%= material.getTitle() %></h1>
                    <p class="text-gray-600 mt-3">Prepared by <strong><%= material.getUploadedByName() %></strong></p>
                </div>
                <div class="flex gap-3">
                    <% if (hasFile) { %>
                    <a href="${pageContext.request.contextPath}/learning/material/file/<%= material.getMaterialId() %>" class="btn-primary px-5 py-3 rounded-xl"><i class="fas fa-download mr-2"></i>Download File</a>
                    <% } %>
                    <% if (externalLink != null && !externalLink.isEmpty()) { %>
                    <a href="<%= externalLink %>" target="_blank" class="glass px-5 py-3 rounded-xl text-purple-700 font-semibold"><i class="fas fa-up-right-from-square mr-2"></i>Open Link</a>
                    <% } %>
                </div>
            </div>
            <% if (material.getDescription() != null && !material.getDescription().isEmpty()) { %>
            <div class="rounded-xl bg-purple-50 px-5 py-4 text-gray-700 mb-6"><%= material.getDescription() %></div>
            <% } %>

            <% if (youtubeEmbedUrl != null) { %>
            <div class="mb-6">
                <div class="flex items-center justify-between mb-3">
                    <h2 class="text-xl font-semibold text-gray-900">Video Lesson</h2>
                    <a href="<%= externalLink %>" target="_blank" class="text-purple-700 font-medium text-sm">
                        <i class="fas fa-up-right-from-square mr-2"></i>Open on YouTube
                    </a>
                </div>
                <div class="rounded-2xl overflow-hidden border border-purple-200 bg-black aspect-video">
                    <iframe
                        src="<%= youtubeEmbedUrl %>"
                        class="w-full h-full"
                        title="YouTube video for <%= material.getTitle() %>"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                        referrerpolicy="strict-origin-when-cross-origin"
                        allowfullscreen>
                    </iframe>
                </div>
            </div>
            <% } %>

            <% if (isPdf) { %>
            <div class="mb-6">
                <div class="flex items-center justify-between mb-3">
                    <h2 class="text-xl font-semibold text-gray-900">PDF Preview</h2>
                    <a href="${pageContext.request.contextPath}/learning/material/file/<%= material.getMaterialId() %>" class="text-purple-700 font-medium text-sm">
                        <i class="fas fa-download mr-2"></i>Download PDF
                    </a>
                </div>
                <div class="rounded-2xl overflow-hidden border border-purple-200 bg-white">
                    <iframe
                        src="${pageContext.request.contextPath}/learning/material/file/<%= material.getMaterialId() %>?action=view"
                        class="w-full h-[720px]"
                        title="PDF preview for <%= material.getTitle() %>">
                    </iframe>
                </div>
            </div>
            <% } %>

            <div class="prose max-w-none whitespace-pre-wrap leading-7 text-gray-800"><%= material.getContent() != null && !material.getContent().isEmpty() ? material.getContent() : "No inline lesson content was provided for this material." %></div>
        </div>
    </main>
    </div>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>

