<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.omrs.model.*" %>
<%!
    private String h(Object value) {
        if (value == null) return "";
        return value.toString()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%
        Experiment experiment = (Experiment) request.getAttribute("experiment");
        List<Experiment> relatedExperiments = (List<Experiment>) request.getAttribute("relatedExperiments");
        List<RepositoryComment> comments = (List<RepositoryComment>) request.getAttribute("comments");
        List<String> characterizationMethods = new ArrayList<>();
        String mat = experiment != null ? experiment.getMaterialType() : "Unknown";
        String pageTitle = experiment != null ? experiment.getTitle() + " - OMRS Repository" : "Experiment Not Found";
        if (experiment != null && experiment.getCharacterizationMethods() != null && !experiment.getCharacterizationMethods().trim().isEmpty()) {
            characterizationMethods = Arrays.asList(experiment.getCharacterizationMethods().split("\\s*,\\s*"));
        }
    %>
    <title><%= pageTitle %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
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
        
        .mono { font-family: 'JetBrains Mono', monospace; }
        .glass-card { 
            background: rgba(255, 255, 255, 1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(124, 58, 237, 0.14);
            box-shadow: 0 10px 28px rgba(88, 28, 135, 0.08);
        }
        .data-card { 
            background: rgba(255, 255, 255, 1);
            border: 1px solid rgba(124, 58, 237, 0.14);
            box-shadow: 0 4px 14px rgba(88, 28, 135, 0.05);
        }
        .gradient-text { background: linear-gradient(135deg, #a78bfa, #d8b4fe); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
        .material-badge { display: inline-flex; align-items: center; padding: 6px 16px; border-radius: 999px; font-size: 0.875rem; font-weight: 800; }
        .badge-silica { background: #f5f3ff; color: #5b21b6; }
        .badge-pmma { background: #f5f3ff; color: #5b21b6; }
        .badge-zno { background: #fdf2f8; color: #be185d; }
        .badge-tio2 { background: #eef2ff; color: #4338ca; }
        .badge-graphene { background: #f1f5f9; color: #334155; }
        .badge-gold { background: #fef3c7; color: #92400e; }
        .badge-silver { background: #f1f5f9; color: #475569; }
        .badge-other { background: rgba(124, 58, 237, 0.12); color: #7c3aed; }
        .test-badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 6px; font-size: 0.7rem; font-weight: 600; text-transform: uppercase; }
        .test-sem { background: rgba(220, 38, 38, 0.2); color: #dc2626; }
        .test-uv { background: rgba(168, 85, 247, 0.2); color: #a78bfa; }
        .test-ftir { background: rgba(124, 58, 237, 0.2); color: #7c3aed; }
        .test-xrd { background: rgba(168, 85, 247, 0.2); color: #a78bfa; }
        .test-tem { background: rgba(236, 72, 153, 0.2); color: #ec4899; }
        .test-other { background: rgba(107, 114, 128, 0.2); color: #6b7280; }
        .property-row { display: flex; padding: 12px 0; border-bottom: 1px solid rgba(168, 85, 247, 0.05); }
        .property-row:last-child { border-bottom: none; }
        .property-label { width: 140px; color: #6b7280; font-size: 0.875rem; font-weight: 600; }
        .property-value { flex: 1; color: #2d3748; }
        .notes-content { background: #f8fafc; border: 1px solid rgba(124, 58, 237, 0.16); border-radius: 12px; padding: 20px; white-space: pre-wrap; line-height: 1.7; color: #2d3748; }
        .related-card { background: rgba(255, 255, 255, 1); border: 1px solid rgba(124, 58, 237, 0.14); transition: all 0.2s ease; }
        .related-card:hover { transform: translateY(-2px); border-color: rgba(124, 58, 237, 0.30); box-shadow: 0 10px 24px rgba(88, 28, 135, 0.08); }
        .copy-btn { background: #f5f3ff; border: 1px solid rgba(124, 58, 237, 0.18); color: #5b21b6; transition: all 0.2s ease; }
        .copy-btn:hover { background: #ede9fe; border-color: rgba(124, 58, 237, 0.35); }
        .comment-box { background: #ffffff; border: 1px solid rgba(124, 58, 237, 0.15); }
        .comment-input { background: #ffffff; border: 1px solid rgba(167, 139, 250, 0.35); color: #1f2937; resize: vertical; }
        .comment-input:focus { border-color: #7c3aed; box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.12); outline: none; }
        .comment-submit { background: linear-gradient(135deg, #7c3aed, #a78bfa); color: #ffffff; }
        .comment-delete { color: #dc2626; border: 1px solid rgba(220, 38, 38, 0.25); }
        .comment-delete:hover { background: rgba(220, 38, 38, 0.08); }
    </style>
</head>
<body class="min-h-screen">
    <% 
        User user = (User) session.getAttribute("user");
    %>
    
    <div class="flex min-h-screen">
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            <% if (experiment != null) { %>
            
            <!-- Breadcrumb -->
            <nav class="text-sm mb-6">
                <a href="${pageContext.request.contextPath}/repository" class="text-gray-700 hover:text-purple-600">Repository</a>
                <span class="text-gray-700 mx-2">/</span>
                <a href="${pageContext.request.contextPath}/repository/material/<%= java.net.URLEncoder.encode(mat, "UTF-8") %>" 
                   class="text-gray-700 hover:text-purple-600"><%= mat %></a>
                <span class="text-gray-700 mx-2">/</span>
                <span class="text-gray-700"><%= experiment.getExperimentId() %></span>
            </nav>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div class="lg:col-span-2 space-y-6">
                <!-- Header Card -->
                <div class="glass-card rounded-2xl p-8">
                    <div class="flex flex-wrap items-start justify-between gap-4 mb-6">
                        <%
                            String badgeClass = "badge-other";
                            if ("Silica".equals(mat)) badgeClass = "badge-silica";
                            else if ("PMMA".equals(mat)) badgeClass = "badge-pmma";
                            else if ("Zinc Oxide".equals(mat)) badgeClass = "badge-zno";
                            else if ("Titanium Dioxide".equals(mat)) badgeClass = "badge-tio2";
                            else if ("Graphene".equals(mat)) badgeClass = "badge-graphene";
                            else if ("Gold Nanoparticle".equals(mat)) badgeClass = "badge-gold";
                            else if ("Silver Nanoparticle".equals(mat)) badgeClass = "badge-silver";
                        %>
                        <span class="material-badge <%= badgeClass %>">
                            <i class="fas fa-atom mr-2"></i><%= mat %>
                        </span>
                        <span class="text-purple-600 font-mono text-sm"><%= experiment.getExperimentId() %></span>
                    </div>
                    <h1 class="text-2xl md:text-3xl font-bold text-gray-900 mb-4"><%= experiment.getTitle() %></h1>
                    <div class="flex flex-wrap items-center gap-6 text-gray-700 text-sm">
                        <div class="flex items-center">
                            <i class="fas fa-user mr-2 text-purple-600"></i>
                            <span><%= experiment.getStudentName() != null ? experiment.getStudentName() : "Unknown" %></span>
                        </div>
                        <div class="flex items-center">
                            <i class="fas fa-calendar mr-2 text-purple-400"></i>
                            <span><%= experiment.getExperimentDate() %></span>
                        </div>
                        <div class="flex items-center">
                            <i class="fas fa-check-circle mr-2 text-green-400"></i>
                            <span>Approved</span>
                        </div>
                    </div>
                </div>

                <!-- Properties Card -->
                <div class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-list-alt mr-3 text-purple-600"></i>Material Properties
                    </h2>
                    <div class="data-card rounded-xl p-6">
                        <div class="property-row">
                            <span class="property-label">Material Type</span>
                            <span class="material-badge badge-<%= mat != null ? mat.toLowerCase() : "other" %>">
                                <%= mat != null ? mat : "Unknown" %>
                            </span>
                        </div>
                        <div class="property-row">
                            <span class="property-label">Concentration</span>
                            <span class="property-value mono">
                                <%= experiment.getConcentration() != null && !experiment.getConcentration().isEmpty() 
                                    ? experiment.getConcentration() : "Not specified" %>
                            </span>
                        </div>
                        <div class="property-row">
                            <span class="property-label">Experiment Date</span>
                            <span class="property-value mono"><%= experiment.getExperimentDate() %></span>
                        </div>
                        <div class="property-row">
                            <span class="property-label">Experiment ID</span>
                            <span class="property-value mono text-purple-600"><%= experiment.getExperimentId() %></span>
                        </div>
                        <div class="property-row">
                            <span class="property-label">Student ID</span>
                            <span class="property-value mono"><%= experiment.getStudentId() %></span>
                        </div>
                    </div>
                </div>

                <% if (experiment.getStudyObjective() != null && !experiment.getStudyObjective().isEmpty()) { %>
                <div class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-bullseye mr-3 text-indigo-500"></i>Study Objective
                    </h2>
                    <div class="notes-content text-gray-700 text-sm"><%= experiment.getStudyObjective() %></div>
                </div>
                <% } %>

                <% if ((experiment.getHypothesis() != null && !experiment.getHypothesis().isEmpty()) ||
                       (experiment.getIndependentVariable() != null && !experiment.getIndependentVariable().isEmpty()) ||
                       (experiment.getDependentVariable() != null && !experiment.getDependentVariable().isEmpty()) ||
                       (experiment.getControlledVariables() != null && !experiment.getControlledVariables().isEmpty())) { %>
                <div class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-flask-vial mr-3 text-rose-500"></i>Research Protocol
                    </h2>
                    <% if (experiment.getHypothesis() != null && !experiment.getHypothesis().isEmpty()) { %>
                    <div class="notes-content text-gray-700 text-sm mb-5"><%= experiment.getHypothesis() %></div>
                    <% } %>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-5">
                        <div class="data-card rounded-xl p-4">
                            <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Independent Variable</p>
                            <p class="text-gray-900"><%= experiment.getIndependentVariable() != null && !experiment.getIndependentVariable().isEmpty() ? experiment.getIndependentVariable() : "Not specified" %></p>
                        </div>
                        <div class="data-card rounded-xl p-4">
                            <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Dependent Variable</p>
                            <p class="text-gray-900"><%= experiment.getDependentVariable() != null && !experiment.getDependentVariable().isEmpty() ? experiment.getDependentVariable() : "Not specified" %></p>
                        </div>
                    </div>
                    <% if (experiment.getControlledVariables() != null && !experiment.getControlledVariables().isEmpty()) { %>
                    <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-2">Controlled Variables</p>
                    <div class="notes-content text-gray-700 text-sm"><%= experiment.getControlledVariables() %></div>
                    <% } %>
                </div>
                <% } %>

                <div class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-layer-group mr-3 text-amber-500"></i>Three Experimental Sets
                    </h2>
                    <div class="grid grid-cols-1 xl:grid-cols-3 gap-4">
                        <div class="data-card rounded-xl p-5">
                            <p class="text-gray-900 font-semibold mb-2">Experiment 1</p>
                            <p class="text-gray-700 text-sm mb-1">Label</p>
                            <p class="text-gray-900 mb-3"><%= experiment.getSampleOneName() != null && !experiment.getSampleOneName().isEmpty() ? experiment.getSampleOneName() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Condition</p>
                            <p class="text-gray-900 mb-3"><%= experiment.getSampleOneCondition() != null && !experiment.getSampleOneCondition().isEmpty() ? experiment.getSampleOneCondition() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Notes</p>
                            <p class="text-gray-700 text-sm whitespace-pre-wrap"><%= experiment.getSampleOneNotes() != null && !experiment.getSampleOneNotes().isEmpty() ? experiment.getSampleOneNotes() : "No notes provided." %></p>
                        </div>
                        <div class="data-card rounded-xl p-5">
                            <p class="text-gray-900 font-semibold mb-2">Experiment 2</p>
                            <p class="text-gray-700 text-sm mb-1">Label</p>
                            <p class="text-gray-900 mb-3"><%= experiment.getSampleTwoName() != null && !experiment.getSampleTwoName().isEmpty() ? experiment.getSampleTwoName() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Condition</p>
                            <p class="text-gray-900 mb-3"><%= experiment.getSampleTwoCondition() != null && !experiment.getSampleTwoCondition().isEmpty() ? experiment.getSampleTwoCondition() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Notes</p>
                            <p class="text-gray-700 text-sm whitespace-pre-wrap"><%= experiment.getSampleTwoNotes() != null && !experiment.getSampleTwoNotes().isEmpty() ? experiment.getSampleTwoNotes() : "No notes provided." %></p>
                        </div>
                        <div class="data-card rounded-xl p-5">
                            <p class="text-gray-900 font-semibold mb-2">Experiment 3</p>
                            <p class="text-gray-700 text-sm mb-1">Label</p>
                            <p class="text-gray-900 mb-3"><%= experiment.getSampleThreeName() != null && !experiment.getSampleThreeName().isEmpty() ? experiment.getSampleThreeName() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Condition</p>
                            <p class="text-gray-900 mb-3"><%= experiment.getSampleThreeCondition() != null && !experiment.getSampleThreeCondition().isEmpty() ? experiment.getSampleThreeCondition() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Notes</p>
                            <p class="text-gray-700 text-sm whitespace-pre-wrap"><%= experiment.getSampleThreeNotes() != null && !experiment.getSampleThreeNotes().isEmpty() ? experiment.getSampleThreeNotes() : "No notes provided." %></p>
                        </div>
                    </div>
                </div>

                <% if (!characterizationMethods.isEmpty() || (experiment.getCharacterizationNotes() != null && !experiment.getCharacterizationNotes().isEmpty())) { %>
                <div class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-microscope mr-3 text-sky-500"></i>Characterization
                    </h2>
                    <% if (!characterizationMethods.isEmpty()) { %>
                    <div class="flex flex-wrap gap-2 mb-4">
                        <% for (String method : characterizationMethods) { %>
                        <span class="px-3 py-1 rounded-full bg-purple-50 border border-purple-200 text-purple-700 text-sm font-medium"><%= method %></span>
                        <% } %>
                    </div>
                    <% } %>
                    <div class="notes-content text-gray-700 text-sm"><%= experiment.getCharacterizationNotes() != null && !experiment.getCharacterizationNotes().isEmpty() ? experiment.getCharacterizationNotes() : "No characterization notes provided." %></div>
                    <% if ((experiment.getInstrumentDetails() != null && !experiment.getInstrumentDetails().isEmpty()) ||
                           (experiment.getScanRange() != null && !experiment.getScanRange().isEmpty()) ||
                           (experiment.getCalibrationReference() != null && !experiment.getCalibrationReference().isEmpty()) ||
                           experiment.getReplicateCount() != null ||
                           (experiment.getMeasurementUncertainty() != null && !experiment.getMeasurementUncertainty().isEmpty()) ||
                           experiment.getRawDataRequired() != null) { %>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-5">
                        <div class="data-card rounded-xl p-4">
                            <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Instrument</p>
                            <p class="text-gray-700 text-sm whitespace-pre-wrap"><%= experiment.getInstrumentDetails() != null && !experiment.getInstrumentDetails().isEmpty() ? experiment.getInstrumentDetails() : "Not specified" %></p>
                        </div>
                        <div class="data-card rounded-xl p-4">
                            <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Scan / Calibration</p>
                            <p class="text-gray-900 text-sm"><%= experiment.getScanRange() != null && !experiment.getScanRange().isEmpty() ? experiment.getScanRange() : "Scan range not specified" %></p>
                            <p class="text-gray-700 text-sm whitespace-pre-wrap mt-2"><%= experiment.getCalibrationReference() != null && !experiment.getCalibrationReference().isEmpty() ? experiment.getCalibrationReference() : "No calibration reference recorded" %></p>
                        </div>
                        <div class="data-card rounded-xl p-4">
                            <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Quality Check</p>
                            <p class="text-gray-900 text-sm">Replicates: <%= experiment.getReplicateCount() != null ? experiment.getReplicateCount() : "N/A" %></p>
                            <p class="text-gray-900 text-sm">Uncertainty: <%= experiment.getMeasurementUncertainty() != null && !experiment.getMeasurementUncertainty().isEmpty() ? experiment.getMeasurementUncertainty() : "N/A" %></p>
                            <p class="text-gray-900 text-sm">Raw data required: <%= Boolean.TRUE.equals(experiment.getRawDataRequired()) ? "Yes" : "No" %></p>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>

                <!-- Preparation Notes -->
                <% if (experiment.getPreparationNotes() != null && !experiment.getPreparationNotes().isEmpty()) { %>
                <div class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-file-alt mr-3 text-purple-400"></i>Overall Preparation Notes
                    </h2>
                    <div class="notes-content text-gray-700 text-sm"><%= experiment.getPreparationNotes() %></div>
                </div>
                <% } %>

                <% if ((experiment.getConclusion() != null && !experiment.getConclusion().isEmpty()) ||
                       (experiment.getLimitations() != null && !experiment.getLimitations().isEmpty()) ||
                       (experiment.getNextSteps() != null && !experiment.getNextSteps().isEmpty())) { %>
                <div class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-clipboard-check mr-3 text-teal-500"></i>Conclusion and Data Quality
                    </h2>
                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
                        <div class="data-card rounded-xl p-5">
                            <p class="text-xs uppercase tracking-wide text-teal-700 font-semibold mb-2">Key Finding</p>
                            <p class="text-gray-700 text-sm whitespace-pre-wrap"><%= experiment.getConclusion() != null && !experiment.getConclusion().isEmpty() ? experiment.getConclusion() : "Not provided" %></p>
                        </div>
                        <div class="data-card rounded-xl p-5">
                            <p class="text-xs uppercase tracking-wide text-amber-700 font-semibold mb-2">Limitations</p>
                            <p class="text-gray-700 text-sm whitespace-pre-wrap"><%= experiment.getLimitations() != null && !experiment.getLimitations().isEmpty() ? experiment.getLimitations() : "Not provided" %></p>
                        </div>
                        <div class="data-card rounded-xl p-5">
                            <p class="text-xs uppercase tracking-wide text-sky-700 font-semibold mb-2">Next Steps</p>
                            <p class="text-gray-700 text-sm whitespace-pre-wrap"><%= experiment.getNextSteps() != null && !experiment.getNextSteps().isEmpty() ? experiment.getNextSteps() : "Not provided" %></p>
                        </div>
                    </div>
                </div>
                <% } %>

                <!-- Test Data Files -->
                <% List<TestData> testFiles = experiment.getTestFiles();
                   if (testFiles != null && !testFiles.isEmpty()) { %>
                <div class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-database mr-3 text-green-400"></i>Characterization Data
                        <span class="ml-3 px-2 py-1 rounded-full text-xs bg-green-500/20 text-green-400">
                            <%= testFiles.size() %> file<%= testFiles.size() != 1 ? "s" : "" %>
                        </span>
                    </h2>
                    <div class="space-y-3">
                        <% for (TestData td : testFiles) {
                            String testType = td.getTestType();
                            String testBadgeClass = "test-other";
                            String testIcon = "file";
                            if ("SEM".equals(testType)) { testBadgeClass = "test-sem"; testIcon = "microscope"; }
                            else if ("UV-VIS".equals(testType)) { testBadgeClass = "test-uv"; testIcon = "sun"; }
                            else if ("FTIR".equals(testType)) { testBadgeClass = "test-ftir"; testIcon = "wave-square"; }
                        %>
                        <div class="data-card rounded-xl p-4">
                            <div class="flex items-center justify-between mb-4">
                                <div class="flex items-center space-x-4">
                                    <div class="w-10 h-10 rounded-lg bg-gray-800 flex items-center justify-center">
                                        <i class="fas fa-<%= testIcon %> text-gray-700"></i>
                                    </div>
                                    <div>
                                        <div class="flex items-center space-x-2 mb-1">
                                            <span class="test-badge <%= testBadgeClass %>"><%= testType %></span>
                                            <span class="text-gray-900 text-sm font-medium"><%= td.getFileName() %></span>
                                        </div>
                                        <span class="text-gray-700 text-xs">
                                            <%= td.getFileSize() != null ? td.getFileSize() : "Unknown size" %>
                                        </span>
                                    </div>
                                </div>
                                <a href="${pageContext.request.contextPath}/download/<%= td.getTestDataId() %>"
                                   class="px-4 py-2 rounded-lg text-purple-600 border border-cyan-500/30 hover:bg-cyan-500/10 transition text-sm">
                                    <i class="fas fa-download mr-2"></i>Download
                                </a>
                            </div>

                            <!-- Inline Content Display -->
                            <%
                            String fileNameLower = td.getFileName().toLowerCase();
                            boolean isImage = fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") ||
                                            fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif") ||
                                            fileNameLower.endsWith(".svg") ||
                                            fileNameLower.endsWith(".tif") || fileNameLower.endsWith(".tiff");
                            boolean isText = fileNameLower.endsWith(".txt") || fileNameLower.endsWith(".csv") ||
                                           fileNameLower.endsWith(".dat");
                            boolean isPdf = fileNameLower.endsWith(".pdf");
                            %>

                            <% if (isImage) { %>
                                <div class="mt-4 border-t border-gray-200 pt-4">
                                    <img src="${pageContext.request.contextPath}/download/<%= td.getTestDataId() %>?action=view"
                                         alt="<%= td.getFileName() %>"
                                         class="max-w-full h-auto rounded-lg border border-gray-200"
                                         style="max-height: 400px; object-fit: contain;">
                                </div>
                            <% } else if (isText) { %>
                                <div class="mt-4 border-t border-gray-200 pt-4">
                                    <div class="bg-gray-50 rounded-lg p-4 max-h-96 overflow-auto">
                                        <pre id="content-<%= td.getTestDataId() %>" class="text-xs text-gray-800 whitespace-pre-wrap font-mono">
                                            <i class="fas fa-spinner fa-spin mr-2"></i>Loading content...
                                        </pre>
                                    </div>
                                    <script>
                                        fetch('${pageContext.request.contextPath}/download/<%= td.getTestDataId() %>?action=view')
                                            .then(response => response.text())
                                            .then(content => {
                                                document.getElementById('content-<%= td.getTestDataId() %>').textContent = content;
                                            })
                                            .catch(error => {
                                                document.getElementById('content-<%= td.getTestDataId() %>').innerHTML =
                                                    '<span class="text-red-500">Error loading content: ' + error.message + '</span>';
                                            });
                                    </script>
                                </div>
                            <% } else if (isPdf) { %>
                                <div class="mt-4 border-t border-gray-200 pt-4">
                                    <iframe src="${pageContext.request.contextPath}/download/<%= td.getTestDataId() %>?action=view"
                                            class="w-full h-96 border border-gray-200 rounded-lg"
                                            title="<%= td.getFileName() %>">
                                        <p>Your browser does not support iframes.
                                           <a href="${pageContext.request.contextPath}/download/<%= td.getTestDataId() %>?action=view">View PDF</a>
                                        </p>
                                    </iframe>
                                </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <!-- Repository Comments -->
                <div id="comments" class="glass-card rounded-2xl p-8">
                    <h2 class="text-xl font-semibold text-gray-900 mb-6 flex items-center">
                        <i class="fas fa-comments mr-3 text-purple-600"></i>Repository Comments
                        <span class="ml-3 px-2 py-1 rounded-full text-xs bg-purple-50 text-purple-700 border border-purple-100">
                            <%= comments != null ? comments.size() : 0 %>
                        </span>
                    </h2>

                    <form method="POST" action="${pageContext.request.contextPath}/repository/view/<%= experiment.getExperimentId() %>#comments" class="mb-6">
                        <input type="hidden" name="action" value="comment">
                        <label for="commentText" class="block text-gray-700 text-sm font-medium mb-2">Add a comment</label>
                        <textarea id="commentText" name="commentText" rows="4" maxlength="1000" required
                                  class="comment-input w-full rounded-xl px-4 py-3 placeholder-gray-500"
                                  placeholder="Share a question, note, or observation about this material record..."></textarea>
                        <div class="flex justify-end mt-3">
                            <button type="submit" class="comment-submit px-5 py-2.5 rounded-xl font-semibold text-sm">
                                <i class="fas fa-paper-plane mr-2"></i>Post Comment
                            </button>
                        </div>
                    </form>

                    <% if (comments != null && !comments.isEmpty()) {
                        for (RepositoryComment comment : comments) {
                            String displayName = comment.getUserName() != null && !comment.getUserName().isEmpty() ? comment.getUserName() : "User";
                            String role = comment.getUserRole() != null ? comment.getUserRole() : "USER";
                            boolean canDeleteComment = user.getUserId() == comment.getUserId() || "SUPERVISOR".equals(user.getRole());
                    %>
                    <div class="comment-box rounded-xl p-5 mb-3">
                        <div class="flex flex-wrap items-center justify-between gap-3 mb-3">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                                    <%= h(displayName.substring(0, 1).toUpperCase()) %>
                                </div>
                                <div>
                                    <p class="text-gray-900 font-semibold"><%= h(displayName) %></p>
                                    <p class="text-gray-500 text-xs"><%= h(role.substring(0, 1) + role.substring(1).toLowerCase()) %></p>
                                </div>
                            </div>
                            <div class="flex items-center gap-3">
                                <span class="text-gray-500 text-xs"><%= comment.getCreatedAt() != null ? comment.getCreatedAt() : "" %></span>
                                <% if (canDeleteComment) { %>
                                <form method="POST" action="${pageContext.request.contextPath}/repository/view/<%= experiment.getExperimentId() %>#comments" onsubmit="return confirm('Delete this comment?');">
                                    <input type="hidden" name="action" value="deleteComment">
                                    <input type="hidden" name="commentId" value="<%= comment.getCommentId() %>">
                                    <button type="submit" class="comment-delete rounded-lg px-3 py-1 text-xs font-semibold">
                                        <i class="fas fa-trash-alt mr-1"></i>Delete
                                    </button>
                                </form>
                                <% } %>
                            </div>
                        </div>
                        <p class="text-gray-700 whitespace-pre-wrap"><%= h(comment.getCommentText()) %></p>
                    </div>
                    <%  }
                    } else { %>
                    <div class="comment-box rounded-xl p-8 text-center">
                        <i class="fas fa-comment-dots text-3xl text-purple-300 mb-3"></i>
                        <p class="text-gray-700">No comments yet. Be the first to discuss this material record.</p>
                    </div>
                    <% } %>
                </div>
                </div>

                <!-- Sidebar -->
                <div class="space-y-6">

                <!-- Citation Card -->
                <div class="glass-card rounded-2xl p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                        <i class="fas fa-quote-left mr-2 text-purple-400"></i>Cite This Data
                    </h3>
                    <div class="bg-gray-900 rounded-xl p-4 text-white text-xs leading-relaxed">
                        <%= experiment.getStudentName() != null ? experiment.getStudentName() : "Unknown" %>, 
                        "<%= experiment.getTitle() %>", 
                        OMRS Repository, 
                        Universiti Malaysia Terengganu, 
                        <%= experiment.getExperimentDate() %>, 
                        ID: <%= experiment.getExperimentId() %>
                    </div>
                </div>

                <!-- Related Experiments -->
                <% if (relatedExperiments != null && !relatedExperiments.isEmpty()) { %>
                <div class="glass-card rounded-2xl p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                        <i class="fas fa-link mr-2 text-purple-600"></i>Related Experiments
                    </h3>
                    <div class="space-y-3">
                        <% for (Experiment rel : relatedExperiments) { %>
                        <a href="${pageContext.request.contextPath}/repository/view/<%= rel.getExperimentId() %>" 
                           class="related-card block rounded-xl p-4">
                            <p class="text-gray-900 text-sm font-medium mb-1 line-clamp-1"><%= rel.getTitle() %></p>
                            <div class="flex items-center justify-between text-xs text-gray-700">
                                <span class="mono"><%= rel.getExperimentId() %></span>
                                <span><%= rel.getExperimentDate() %></span>
                            </div>
                        </a>
                        <% } %>
                    </div>
                    <a href="${pageContext.request.contextPath}/repository/material/<%= java.net.URLEncoder.encode(mat, "UTF-8") %>" 
                       class="block mt-4 text-center text-purple-600 text-sm hover:text-cyan-300 transition">
                        View all <%= mat %> experiments <i class="fas fa-arrow-right ml-1"></i>
                    </a>
                </div>
                <% } %>

                <!-- Back Button -->
                <a href="${pageContext.request.contextPath}/repository/browse" 
                   class="block w-full px-6 py-3 rounded-xl font-medium text-center text-purple-600 border border-gray-600 hover:border-purple-500 hover:text-purple-700 transition">
                    <i class="fas fa-arrow-left mr-2"></i>Back to Browse
                </a>
            </div>
        </div>
    </div>
    <% } else { %>
    <!-- Not Found State -->
    <div class="max-w-2xl mx-auto px-4 py-20 text-center">
        <div class="w-24 h-24 mx-auto mb-8 rounded-2xl bg-gray-800 flex items-center justify-center">
            <i class="fas fa-exclamation-triangle text-4xl text-yellow-500"></i>
        </div>
        <h1 class="text-3xl font-bold text-gray-900 mb-4">Experiment Not Found</h1>
        <p class="text-gray-700 mb-8">
            The experiment you're looking for doesn't exist or hasn't been approved yet.
        </p>
        <a href="${pageContext.request.contextPath}/repository/browse" 
           class="inline-flex items-center px-8 py-3 rounded-xl font-semibold text-gray-900"
           style="background: linear-gradient(135deg, #00fff5, #8b5cf6);">
            <i class="fas fa-th-large mr-2"></i>Browse Repository
        </a>
    </div>
    <% } %>

    <!-- Footer -->
    <footer class="py-8 border-t border-white/5 mt-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <p class="text-gray-700 text-sm">© 2025 OMRS - Universiti Malaysia Terengganu</p>
        </div>
    </footer>

    <script>
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
    </script>
        </main>
    </div>
<%@ include file="../common/system-chatbot.jsp" %>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>




