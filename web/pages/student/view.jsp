<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.omrs.model.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Experiment - OMRS</title>
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
        
        .status-DRAFT { background: rgba(107,114,128,0.12); color: #4b5563; border-color: rgba(107,114,128,0.3); }
        .status-PENDING { background: rgba(124, 58, 237,0.1); color: #7c3aed; border-color: rgba(124, 58, 237,0.3); }
        .status-APPROVED { background: rgba(34,197,94,0.1); color: #22c55e; border-color: rgba(34,197,94,0.3); }
        .status-REJECTED { background: rgba(239,68,68,0.1); color: #ef4444; border-color: rgba(239,68,68,0.3); }

        .input-field {
            background: #ffffff;
            border: 1px solid rgba(167, 139, 250, 0.2);
            color: #1a202c;
        }

        .viz-bar {
            height: 100%;
            border-radius: 999px;
            min-width: 0.35rem;
            transition: width 0.45s ease;
        }

        .viz-card {
            background: #ffffff;
            border: 1px solid rgba(167, 139, 250, 0.24);
            box-shadow: 0 6px 18px rgba(124, 58, 237, 0.08);
        }

        .viz-track {
            height: 0.85rem;
            border-radius: 999px;
            overflow: hidden;
            background: #ede9fe;
            border: 1px solid rgba(167, 139, 250, 0.20);
        }

        .viz-dot {
            width: 0.75rem;
            height: 0.75rem;
            border-radius: 999px;
        }

        .viz-chart {
            background: #ffffff;
            border: 1px solid rgba(167, 139, 250, 0.24);
            box-shadow: 0 8px 24px rgba(124, 58, 237, 0.08);
        }

        .viz-chart svg {
            width: 100%;
            height: auto;
            min-height: 300px;
        }

        .viz-axis-label {
            font-size: 12px;
            fill: #6b7280;
            font-weight: 600;
        }

        .viz-value-label {
            font-size: 13px;
            fill: #111827;
            font-weight: 700;
        }
    </style>
</head>
<body class="min-h-screen">
    <% 
        User user = (User) session.getAttribute("user"); 
        String studentType = (String) session.getAttribute("studentType");
        boolean isFypStudent = "FYP".equals(studentType);
        Experiment exp = (Experiment) request.getAttribute("experiment");
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
        List<String> characterizationMethods = new ArrayList<>();
        if (exp.getCharacterizationMethods() != null && !exp.getCharacterizationMethods().trim().isEmpty()) {
            characterizationMethods = Arrays.asList(exp.getCharacterizationMethods().split("\\s*,\\s*"));
        }
        boolean isComparisonStudy = "COMPARISON".equals(exp.getStudyType());
        boolean hasComparisonGraph = isComparisonStudy && exp.getMaterialAMetricValue() != null && exp.getMaterialBMetricValue() != null;
        double graphMax = hasComparisonGraph ? Math.max(Math.abs(exp.getMaterialAMetricValue()), Math.abs(exp.getMaterialBMetricValue())) : 0;
        int materialAWidth = graphMax > 0 ? Math.max(6, (int) Math.round(Math.abs(exp.getMaterialAMetricValue()) / graphMax * 100)) : 0;
        int materialBWidth = graphMax > 0 ? Math.max(6, (int) Math.round(Math.abs(exp.getMaterialBMetricValue()) / graphMax * 100)) : 0;
        List<String[]> comparisonTableRows = exp.getComparisonTableRows();
    %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">

        <!-- Student Info Card -->
        <div class="glass rounded-2xl p-6 mb-6">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-cyan-400 to-purple-600 flex items-center justify-center">
                        <span class="text-white text-xl font-bold"><%= exp.getStudentName() != null ? exp.getStudentName().charAt(0) : "?" %></span>
                    </div>
                    <div>
                        <p class="text-gray-900 font-semibold text-lg"><%= exp.getStudentName() %></p>
                        <p class="text-gray-700 text-sm"><%= exp.getStudentId() %></p>
                    </div>
                </div>
                <div class="text-right">
                    <span class="status-<%= exp.getStatus() %> px-3 py-1 rounded-full text-xs font-medium border">
                        <i class="fas <%= "APPROVED".equals(exp.getStatus()) ? "fa-check-circle" : 
                                        "PENDING".equals(exp.getStatus()) ? "fa-clock" :
                                        "REJECTED".equals(exp.getStatus()) ? "fa-times-circle" : "fa-pencil-alt" %> mr-1"></i>
                        <%= exp.getStatus() %>
                    </span>
                    <p class="text-gray-700 text-sm mt-2">Submitted</p>
                    <p class="text-white font-mono"><%= sdf.format(exp.getExperimentDate()) %></p>
                    <a href="${pageContext.request.contextPath}/experiment/export/<%= exp.getExperimentId() %>"
                       class="inline-flex items-center mt-3 px-3 py-2 rounded-lg bg-green-500/10 text-green-600 hover:bg-green-500/20 transition-colors text-sm font-semibold">
                        <i class="fas fa-file-csv mr-2"></i>Export CSV
                    </a>
                </div>
            </div>
        </div>

        <!-- Feedback Alerts -->
        <% if ("REJECTED".equals(exp.getStatus()) && exp.getFeedback() != null && !exp.getFeedback().isEmpty()) { %>
        <div class="bg-red-500/10 border border-red-500/30 rounded-2xl p-6 mb-6">
            <div class="flex items-start">
                <div class="w-12 h-12 rounded-xl bg-red-500/20 flex items-center justify-center mr-4 flex-shrink-0">
                    <i class="fas fa-exclamation-triangle text-red-400 text-xl"></i>
                </div>
                <div class="flex-1">
                    <h3 class="text-red-400 font-semibold text-lg mb-1">Revision Required</h3>
                    <p class="text-white"><%= exp.getFeedback() %></p>
                    <a href="${pageContext.request.contextPath}/student/edit/<%= exp.getExperimentId() %>" 
                       class="inline-flex items-center mt-3 text-red-400 hover:text-red-300 text-sm font-medium">
                        <i class="fas fa-edit mr-2"></i> Edit and Resubmit
                    </a>
                </div>
            </div>
        </div>
        <% } else if ("APPROVED".equals(exp.getStatus()) && exp.getFeedback() != null && !exp.getFeedback().isEmpty()) { %>
        <div class="bg-green-500/10 border border-green-500/30 rounded-2xl p-6 mb-6">
            <div class="flex items-start">
                <div class="w-12 h-12 rounded-xl bg-green-500/20 flex items-center justify-center mr-4 flex-shrink-0">
                    <i class="fas fa-check-circle text-green-400 text-xl"></i>
                </div>
                <div>
                    <h3 class="text-green-400 font-semibold text-lg mb-1">Supervisor Feedback</h3>
                    <p class="text-white"><%= exp.getFeedback() %></p>
                </div>
            </div>
        </div>
        <% } else if ("PENDING".equals(exp.getStatus())) { %>
        <div class="bg-yellow-500/10 border border-yellow-500/30 rounded-2xl p-6 mb-6">
            <div class="flex items-start">
                <div class="w-12 h-12 rounded-xl bg-yellow-500/20 flex items-center justify-center mr-4 flex-shrink-0">
                    <i class="fas fa-clock text-yellow-400 text-xl"></i>
                </div>
                <div>
                    <h3 class="text-yellow-400 font-semibold text-lg mb-1">Awaiting Review</h3>
                    <p class="text-gray-700 mb-3">Your experiment is being reviewed by your supervisor. You can still update details while it is pending.</p>
                    <a href="${pageContext.request.contextPath}/student/edit/<%= exp.getExperimentId() %>"
                       class="inline-flex items-center text-sm font-semibold text-yellow-600 hover:text-yellow-500 transition-colors">
                        <i class="fas fa-edit mr-2"></i>Update pending experiment
                    </a>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Optical Study Details -->
        <div class="glass rounded-2xl p-8 mb-6">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-xl font-semibold text-gray-900">Optical Study Details</h2>
                <span class="text-purple-600 font-mono text-sm"><%= exp.getExperimentId() %></span>
            </div>
            <div class="space-y-6">
                <div>
                    <p class="text-gray-700 text-sm mb-1">Title</p>
                    <p class="text-gray-900 text-lg font-medium"><%= exp.getTitle() %></p>
                </div>
                <% if (exp.getStudyObjective() != null && !exp.getStudyObjective().isEmpty()) { %>
                <div>
                    <p class="text-gray-700 text-sm mb-2">Optical Study Objective</p>
                    <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                        <p class="text-gray-900 whitespace-pre-wrap leading-relaxed"><%= exp.getStudyObjective() %></p>
                    </div>
                </div>
                <% } %>
                <% if ((exp.getHypothesis() != null && !exp.getHypothesis().isEmpty()) ||
                       (exp.getIndependentVariable() != null && !exp.getIndependentVariable().isEmpty()) ||
                       (exp.getDependentVariable() != null && !exp.getDependentVariable().isEmpty()) ||
                       (exp.getControlledVariables() != null && !exp.getControlledVariables().isEmpty())) { %>
                <div>
                    <p class="text-gray-700 text-sm mb-2">Research Protocol</p>
                    <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                        <% if (exp.getHypothesis() != null && !exp.getHypothesis().isEmpty()) { %>
                        <div class="mb-4">
                            <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Hypothesis</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getHypothesis() %></p>
                        </div>
                        <% } %>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="bg-white rounded-xl p-4 border border-purple-100">
                                <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Independent Variable</p>
                                <p class="text-gray-900"><%= exp.getIndependentVariable() != null && !exp.getIndependentVariable().isEmpty() ? exp.getIndependentVariable() : "Not specified" %></p>
                            </div>
                            <div class="bg-white rounded-xl p-4 border border-purple-100">
                                <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Dependent Variable</p>
                                <p class="text-gray-900"><%= exp.getDependentVariable() != null && !exp.getDependentVariable().isEmpty() ? exp.getDependentVariable() : "Not specified" %></p>
                            </div>
                        </div>
                        <% if (exp.getControlledVariables() != null && !exp.getControlledVariables().isEmpty()) { %>
                        <div class="mt-4">
                            <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Controlled Variables</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getControlledVariables() %></p>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <p class="text-gray-700 text-sm mb-1">Optical Material</p>
                        <p class="text-gray-900 font-medium flex items-center">
                            <i class="fas fa-atom text-purple-400 mr-2"></i>
                            <%= exp.getMaterialType() %>
                        </p>
                    </div>
                    <div>
                        <p class="text-gray-700 text-sm mb-1">Main Concentration / Composition</p>
                        <p class="text-gray-900 font-medium flex items-center">
                            <i class="fas fa-vial text-green-400 mr-2"></i>
                            <%= exp.getConcentration() != null && !exp.getConcentration().isEmpty() ? exp.getConcentration() : "N/A" %>
                        </p>
                    </div>
                </div>
                <% if (isComparisonStudy) { %>
                <div>
                    <p class="text-gray-700 text-sm mb-2">Two-Material Comparison</p>
                    <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-5">
                            <div class="bg-white rounded-xl p-4 border border-purple-100">
                                <p class="text-xs font-semibold text-purple-700 mb-1">Material A</p>
                                <p class="text-gray-900 font-semibold"><%= exp.getMaterialType() %></p>
                                <p class="text-gray-700 text-sm"><%= exp.getConcentration() != null && !exp.getConcentration().isEmpty() ? exp.getConcentration() : "No concentration recorded" %></p>
                            </div>
                            <div class="bg-white rounded-xl p-4 border border-purple-100">
                                <p class="text-xs font-semibold text-pink-700 mb-1">Material B</p>
                                <p class="text-gray-900 font-semibold"><%= exp.getMaterialBType() != null && !exp.getMaterialBType().isEmpty() ? exp.getMaterialBType() : "Not specified" %></p>
                                <p class="text-gray-700 text-sm"><%= exp.getMaterialBConcentration() != null && !exp.getMaterialBConcentration().isEmpty() ? exp.getMaterialBConcentration() : "No concentration recorded" %></p>
                            </div>
                        </div>
                        <% if (hasComparisonGraph) { %>
                        <div>
                            <div class="flex items-center justify-between mb-3">
                                <h3 class="text-gray-900 font-semibold"><%= exp.getComparisonMetricLabel() != null && !exp.getComparisonMetricLabel().isEmpty() ? exp.getComparisonMetricLabel() : "Comparison Metric" %></h3>
                                <span class="text-xs text-gray-600">Bar chart</span>
                            </div>
                            <div class="space-y-4">
                                <div>
                                    <div class="flex justify-between text-sm mb-1">
                                        <span class="font-medium text-gray-800"><%= exp.getMaterialType() %></span>
                                        <span class="text-gray-700"><%= exp.getMaterialAMetricValue() %></span>
                                    </div>
                                    <div class="h-5 rounded-full bg-white border border-purple-100 overflow-hidden">
                                        <div class="h-full bg-purple-500 rounded-full" style="width: <%= materialAWidth %>%"></div>
                                    </div>
                                </div>
                                <div>
                                    <div class="flex justify-between text-sm mb-1">
                                        <span class="font-medium text-gray-800"><%= exp.getMaterialBType() %></span>
                                        <span class="text-gray-700"><%= exp.getMaterialBMetricValue() %></span>
                                    </div>
                                    <div class="h-5 rounded-full bg-white border border-purple-100 overflow-hidden">
                                        <div class="h-full bg-pink-500 rounded-full" style="width: <%= materialBWidth %>%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% } else { %>
                        <p class="text-gray-700 text-sm">Add numeric values for both materials to show a comparison graph.</p>
                        <% } %>
                        <% if (exp.getComparisonNotes() != null && !exp.getComparisonNotes().isEmpty()) { %>
                        <div class="mt-5 pt-5 border-t border-purple-200">
                            <p class="text-gray-700 text-sm mb-1">Comparison Notes</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getComparisonNotes() %></p>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>
                <% if (!comparisonTableRows.isEmpty()) { %>
                <div>
                    <p class="text-gray-700 text-sm mb-2">Comparison Data Table</p>
                    <div class="overflow-x-auto bg-white rounded-xl border border-purple-200">
                        <table id="comparisonDataTable" class="w-full min-w-[720px] text-sm">
                            <thead class="bg-purple-100 text-gray-900">
                                <tr>
                                    <th class="text-left p-3 border border-purple-200">Metric / Property</th>
                                    <th class="text-left p-3 border border-purple-200">Sample A / Material A</th>
                                    <th class="text-left p-3 border border-purple-200">Sample B / Material B</th>
                                    <th class="text-left p-3 border border-purple-200">Sample C / Control</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (String[] row : comparisonTableRows) { %>
                                <tr>
                                    <td class="p-3 border border-purple-100 font-medium text-gray-900"><%= row[0] %></td>
                                    <td class="p-3 border border-purple-100 text-gray-800"><%= row[1].isEmpty() ? "-" : row[1] %></td>
                                    <td class="p-3 border border-purple-100 text-gray-800"><%= row[2].isEmpty() ? "-" : row[2] %></td>
                                    <td class="p-3 border border-purple-100 text-gray-800"><%= row[3].isEmpty() ? "-" : row[3] %></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div id="experimentDataViz" class="mt-5 rounded-xl border border-purple-200 bg-purple-50 p-5 hidden">
                        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-5">
                            <div>
                                <p class="text-gray-900 font-semibold">Characterization Metric Graph</p>
                                <p class="text-gray-700 text-sm">Select a metric to compare the three sample values.</p>
                            </div>
                            <select id="vizMetricSelect" class="input-field px-3 py-2 rounded-lg text-sm min-w-[220px]"></select>
                        </div>
                        <div id="vizSummary" class="mb-5"></div>
                        <div id="vizChart"></div>
                    </div>
                </div>
                <% } %>
                <div>
                    <p class="text-gray-700 text-sm mb-2">Sample Comparison Plan</p>
                    <div class="grid grid-cols-1 xl:grid-cols-3 gap-4">
                        <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                            <div class="flex items-center justify-between mb-3">
                                <h3 class="text-gray-900 font-semibold">Sample A</h3>
                                <span class="text-xs px-2.5 py-1 rounded-full bg-white border border-purple-200 text-purple-700">Sample A</span>
                            </div>
                            <div class="space-y-3 text-sm">
                                <div>
                                    <p class="text-gray-700 mb-1">Sample Label</p>
                                    <p class="text-gray-900 font-medium"><%= exp.getSampleOneName() != null && !exp.getSampleOneName().isEmpty() ? exp.getSampleOneName() : "Not specified" %></p>
                                </div>
                                <div>
                                    <p class="text-gray-700 mb-1">Changed Condition</p>
                                    <p class="text-gray-900"><%= exp.getSampleOneCondition() != null && !exp.getSampleOneCondition().isEmpty() ? exp.getSampleOneCondition() : "Not specified" %></p>
                                </div>
                                <div>
                                    <p class="text-gray-700 mb-1">Observation / Result Notes</p>
                                    <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getSampleOneNotes() != null && !exp.getSampleOneNotes().isEmpty() ? exp.getSampleOneNotes() : "No notes provided." %></p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                            <div class="flex items-center justify-between mb-3">
                                <h3 class="text-gray-900 font-semibold">Sample B</h3>
                                <span class="text-xs px-2.5 py-1 rounded-full bg-white border border-purple-200 text-purple-700">Sample B</span>
                            </div>
                            <div class="space-y-3 text-sm">
                                <div>
                                    <p class="text-gray-700 mb-1">Sample Label</p>
                                    <p class="text-gray-900 font-medium"><%= exp.getSampleTwoName() != null && !exp.getSampleTwoName().isEmpty() ? exp.getSampleTwoName() : "Not specified" %></p>
                                </div>
                                <div>
                                    <p class="text-gray-700 mb-1">Changed Condition</p>
                                    <p class="text-gray-900"><%= exp.getSampleTwoCondition() != null && !exp.getSampleTwoCondition().isEmpty() ? exp.getSampleTwoCondition() : "Not specified" %></p>
                                </div>
                                <div>
                                    <p class="text-gray-700 mb-1">Observation / Result Notes</p>
                                    <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getSampleTwoNotes() != null && !exp.getSampleTwoNotes().isEmpty() ? exp.getSampleTwoNotes() : "No notes provided." %></p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                            <div class="flex items-center justify-between mb-3">
                                <h3 class="text-gray-900 font-semibold">Sample C</h3>
                                <span class="text-xs px-2.5 py-1 rounded-full bg-white border border-purple-200 text-purple-700">Sample C</span>
                            </div>
                            <div class="space-y-3 text-sm">
                                <div>
                                    <p class="text-gray-700 mb-1">Sample Label</p>
                                    <p class="text-gray-900 font-medium"><%= exp.getSampleThreeName() != null && !exp.getSampleThreeName().isEmpty() ? exp.getSampleThreeName() : "Not specified" %></p>
                                </div>
                                <div>
                                    <p class="text-gray-700 mb-1">Changed Condition</p>
                                    <p class="text-gray-900"><%= exp.getSampleThreeCondition() != null && !exp.getSampleThreeCondition().isEmpty() ? exp.getSampleThreeCondition() : "Not specified" %></p>
                                </div>
                                <div>
                                    <p class="text-gray-700 mb-1">Observation / Result Notes</p>
                                    <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getSampleThreeNotes() != null && !exp.getSampleThreeNotes().isEmpty() ? exp.getSampleThreeNotes() : "No notes provided." %></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% if (!characterizationMethods.isEmpty() || (exp.getCharacterizationNotes() != null && !exp.getCharacterizationNotes().isEmpty())) { %>
                <div>
                    <p class="text-gray-700 text-sm mb-2">Optical Characterization Plan</p>
                    <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                        <% if (!characterizationMethods.isEmpty()) { %>
                        <div class="flex flex-wrap gap-2 mb-4">
                            <% for (String method : characterizationMethods) { %>
                            <span class="px-3 py-1 rounded-full bg-white border border-purple-200 text-purple-700 text-sm font-medium"><%= method %></span>
                            <% } %>
                        </div>
                        <% } %>
                        <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getCharacterizationNotes() != null && !exp.getCharacterizationNotes().isEmpty() ? exp.getCharacterizationNotes() : "No characterization notes provided." %></p>
                        <% if ((exp.getInstrumentDetails() != null && !exp.getInstrumentDetails().isEmpty()) ||
                               (exp.getScanRange() != null && !exp.getScanRange().isEmpty()) ||
                               (exp.getCalibrationReference() != null && !exp.getCalibrationReference().isEmpty()) ||
                               exp.getReplicateCount() != null ||
                               (exp.getMeasurementUncertainty() != null && !exp.getMeasurementUncertainty().isEmpty()) ||
                               exp.getRawDataRequired() != null) { %>
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-5 pt-5 border-t border-purple-200">
                            <div class="bg-white rounded-xl p-4 border border-purple-100">
                                <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Instrument Details</p>
                                <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getInstrumentDetails() != null && !exp.getInstrumentDetails().isEmpty() ? exp.getInstrumentDetails() : "Not specified" %></p>
                            </div>
                            <div class="bg-white rounded-xl p-4 border border-purple-100">
                                <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Scan / Calibration</p>
                                <p class="text-gray-900"><%= exp.getScanRange() != null && !exp.getScanRange().isEmpty() ? exp.getScanRange() : "Scan range not specified" %></p>
                                <p class="text-gray-700 text-sm whitespace-pre-wrap mt-2"><%= exp.getCalibrationReference() != null && !exp.getCalibrationReference().isEmpty() ? exp.getCalibrationReference() : "No calibration reference recorded" %></p>
                            </div>
                            <div class="bg-white rounded-xl p-4 border border-purple-100">
                                <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Data Quality</p>
                                <p class="text-gray-900">Replicates: <%= exp.getReplicateCount() != null ? exp.getReplicateCount() : "N/A" %></p>
                                <p class="text-gray-900">Uncertainty: <%= exp.getMeasurementUncertainty() != null && !exp.getMeasurementUncertainty().isEmpty() ? exp.getMeasurementUncertainty() : "N/A" %></p>
                                <p class="text-gray-900">Raw data required: <%= Boolean.TRUE.equals(exp.getRawDataRequired()) ? "Yes" : "No" %></p>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>
                <div>
                    <p class="text-gray-700 text-sm mb-2">Common Preparation Method</p>
                    <div class="bg-purple-50 rounded-xl p-6 border border-purple-200">
                        <pre class="text-gray-900 whitespace-pre-wrap font-mono text-sm leading-relaxed"><%= exp.getPreparationNotes() != null && !exp.getPreparationNotes().isEmpty() ? exp.getPreparationNotes() : "No preparation notes provided." %></pre>
                    </div>
                </div>
                <% if ((exp.getConclusion() != null && !exp.getConclusion().isEmpty()) ||
                       (exp.getLimitations() != null && !exp.getLimitations().isEmpty()) ||
                       (exp.getNextSteps() != null && !exp.getNextSteps().isEmpty())) { %>
                <div>
                    <p class="text-gray-700 text-sm mb-2">Conclusion and Next Steps</p>
                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
                        <div class="bg-teal-50 rounded-xl p-5 border border-teal-200">
                            <p class="text-xs uppercase tracking-wide text-teal-700 font-semibold mb-2">Key Finding</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getConclusion() != null && !exp.getConclusion().isEmpty() ? exp.getConclusion() : "Not provided" %></p>
                        </div>
                        <div class="bg-amber-50 rounded-xl p-5 border border-amber-200">
                            <p class="text-xs uppercase tracking-wide text-amber-700 font-semibold mb-2">Limitations</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getLimitations() != null && !exp.getLimitations().isEmpty() ? exp.getLimitations() : "Not provided" %></p>
                        </div>
                        <div class="bg-sky-50 rounded-xl p-5 border border-sky-200">
                            <p class="text-xs uppercase tracking-wide text-sky-700 font-semibold mb-2">Next Steps</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getNextSteps() != null && !exp.getNextSteps().isEmpty() ? exp.getNextSteps() : "Not provided" %></p>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Test Data Files -->
        <% List<TestData> files = exp.getTestFiles(); %>
        <% if (files != null && !files.isEmpty()) { %>
        <div class="glass rounded-2xl p-8 mb-6">
            <div class="flex items-center mb-6">
                <div class="w-10 h-10 rounded-xl bg-blue-500/10 flex items-center justify-center mr-4">
                    <i class="fas fa-file-upload text-blue-400"></i>
                </div>
                <h2 class="text-xl font-semibold text-gray-900">Uploaded Characterization Data</h2>
            </div>
            <div class="space-y-3">
                <% for (TestData file : files) { %>
                <div class="flex items-center justify-between bg-black/30 rounded-xl p-4 border border-purple-500/30 hover:border-gray-700 transition-colors">
                    <div class="flex items-center flex-1 min-w-0">
                        <div class="w-10 h-10 rounded-lg flex items-center justify-center mr-4 flex-shrink-0
                            <%= "FTIR".equals(file.getTestType()) ? "bg-yellow-500/20 text-yellow-400" :
                                "SEM".equals(file.getTestType()) ? "bg-purple-500/20 text-purple-400" :
                                "UV-VIS".equals(file.getTestType()) ? "bg-red-500/20 text-red-400" :
                                "bg-gray-500/20 text-gray-700" %>">
                            <i class="fas fa-file-alt"></i>
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center gap-2 mb-1">
                                <span class="text-sm font-medium px-2.5 py-0.5 rounded-lg
                                    <%= "FTIR".equals(file.getTestType()) ? "bg-yellow-500/20 text-yellow-400" :
                                        "SEM".equals(file.getTestType()) ? "bg-purple-500/20 text-purple-400" :
                                        "UV-VIS".equals(file.getTestType()) ? "bg-red-500/20 text-red-400" :
                                        "bg-gray-500/20 text-gray-700" %>">
                                    <%= file.getTestType() %>
                                </span>
                            </div>
                            <p class="text-gray-900 truncate text-sm"><%= file.getFileName() %></p>
                            <p class="text-gray-700 text-xs"><%= file.getFileSize() %></p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/download?testDataId=<%= file.getTestDataId() %>"
                       class="px-3 py-2 rounded-lg bg-blue-500/10 text-blue-400 hover:bg-blue-500/20 transition-colors text-sm font-medium flex-shrink-0 ml-4">
                        <i class="fas fa-download mr-2"></i>Download
                    </a>
                </div>

                <!-- Inline Content Display -->
                <%
                String fileNameLower = file.getFileName().toLowerCase();
                boolean isImage = fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") ||
                                fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif") ||
                                fileNameLower.endsWith(".svg") ||
                                fileNameLower.endsWith(".tif") || fileNameLower.endsWith(".tiff");
                boolean isText = fileNameLower.endsWith(".txt") || fileNameLower.endsWith(".csv") ||
                               fileNameLower.endsWith(".dat");
                boolean isPdf = fileNameLower.endsWith(".pdf");
                %>

                <% if (isImage) { %>
                    <div class="mt-4 ml-14 border-l-2 border-purple-500/30 pl-4">
                        <img src="${pageContext.request.contextPath}/download?testDataId=<%= file.getTestDataId() %>&action=view"
                             alt="<%= file.getFileName() %>"
                             class="max-w-full h-auto rounded-lg border border-gray-200"
                             style="max-height: 300px; object-fit: contain;">
                    </div>
                <% } else if (isText) { %>
                    <div class="mt-4 ml-14 border-l-2 border-purple-500/30 pl-4">
                        <div class="bg-gray-50 rounded-lg p-4 max-h-64 overflow-auto">
                            <pre id="content-student-<%= file.getTestDataId() %>" class="text-xs text-gray-800 whitespace-pre-wrap font-mono">
                                <i class="fas fa-spinner fa-spin mr-2"></i>Loading content...
                            </pre>
                        </div>
                        <script>
                            fetch('${pageContext.request.contextPath}/download?testDataId=<%= file.getTestDataId() %>&action=view')
                                .then(response => response.text())
                                .then(content => {
                                    document.getElementById('content-student-<%= file.getTestDataId() %>').textContent = content;
                                })
                                .catch(error => {
                                    document.getElementById('content-student-<%= file.getTestDataId() %>').innerHTML =
                                        '<span class="text-red-500">Error loading content: ' + error.message + '</span>';
                                });
                        </script>
                    </div>
                <% } else if (isPdf) { %>
                    <div class="mt-4 ml-14 border-l-2 border-purple-500/30 pl-4">
                        <iframe src="${pageContext.request.contextPath}/download?testDataId=<%= file.getTestDataId() %>&action=view"
                                class="w-full h-64 border border-gray-200 rounded-lg"
                                title="<%= file.getFileName() %>">
                            <p>Your browser does not support iframes.
                               <a href="${pageContext.request.contextPath}/download?testDataId=<%= file.getTestDataId() %>&action=view">View PDF</a>
                            </p>
                        </iframe>
                    </div>
                <% } %>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- Action Buttons -->
        <% if ("DRAFT".equals(exp.getStatus()) || "PENDING".equals(exp.getStatus()) || "REJECTED".equals(exp.getStatus())) { %>
        <div class="flex flex-col sm:flex-row gap-4">
            <a href="${pageContext.request.contextPath}/student/dashboard" 
               class="flex-1 px-6 py-3 rounded-xl bg-gray-800 text-white hover:bg-gray-700 transition-colors text-center font-medium">
                <i class="fas fa-arrow-left mr-2"></i>Back to Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/student/edit/<%= exp.getExperimentId() %>" 
               class="flex-1 px-6 py-3 rounded-xl bg-gradient-to-br from-cyan-400 to-purple-600 text-gray-900 hover:shadow-lg transition-all text-center font-semibold">
                <i class="fas fa-edit mr-2"></i><%= "PENDING".equals(exp.getStatus()) ? "Update Experiment" : "Edit Experiment" %>
            </a>
        </div>
        <% } else { %>
        <div class="flex justify-center">
            <a href="${pageContext.request.contextPath}/student/dashboard" 
               class="px-6 py-3 rounded-xl bg-gray-800 text-white hover:bg-gray-700 transition-colors font-medium">
                <i class="fas fa-arrow-left mr-2"></i>Back to Dashboard
            </a>
        </div>
        <% } %>
        </main>
    </div>
    
    <script>
        function initializeExperimentVisualization() {
            const table = document.getElementById('comparisonDataTable');
            const container = document.getElementById('experimentDataViz');
            const select = document.getElementById('vizMetricSelect');
            const chart = document.getElementById('vizChart');
            const summary = document.getElementById('vizSummary');
            if (!table || !container || !select || !chart || !summary) return;

            const samples = ['Sample A / Material A', 'Sample B / Material B', 'Sample C / Control'];
            const rows = Array.from(table.querySelectorAll('tbody tr')).map(row => {
                const cells = Array.from(row.querySelectorAll('td')).map(cell => cell.textContent.trim());
                const values = cells.slice(1, 4).map(value => {
                    const match = value.replace(/,/g, '').match(/-?\d+(\.\d+)?/);
                    return match ? Number(match[0]) : null;
                });
                return { metric: cells[0], raw: cells.slice(1, 4), values };
            }).filter(row => row.metric && row.values.some(value => value !== null));

            if (!rows.length) return;

            container.classList.remove('hidden');
            select.innerHTML = rows.map((row, index) => '<option value="' + index + '">' + escapeHtml(row.metric) + '</option>').join('');

            function escapeHtml(value) {
                return String(value || '').replace(/[&<>"']/g, function(character) {
                    return {
                        '&': '&amp;',
                        '<': '&lt;',
                        '>': '&gt;',
                        '"': '&quot;',
                        "'": '&#39;'
                    }[character];
                });
            }

            function render(index) {
                const row = rows[index];
                const numericValues = row.values.filter(value => value !== null);
                const minValue = Math.min(...numericValues);
                const maxValue = Math.max(...numericValues);
                const range = maxValue === minValue ? Math.max(Math.abs(maxValue), 1) : maxValue - minValue;
                const yMin = maxValue === minValue ? minValue - range : minValue - (range * 0.12);
                const yMax = maxValue === minValue ? maxValue + range : maxValue + (range * 0.12);
                const validIndexes = row.values
                    .map((value, valueIndex) => ({ value, valueIndex }))
                    .filter(item => item.value !== null);
                const best = validIndexes.length
                    ? validIndexes.reduce((current, item) => item.value > current.value ? item : current, validIndexes[0])
                    : null;

                summary.innerHTML =
                    '<div class="rounded-xl bg-white border border-purple-100 p-4 flex flex-col md:flex-row md:items-center md:justify-between gap-3">' +
                        '<div>' +
                            '<p class="text-xs font-semibold text-purple-700 uppercase tracking-wide">Selected metric</p>' +
                            '<p class="text-xl font-bold text-gray-900">' + escapeHtml(row.metric) + '</p>' +
                        '</div>' +
                        '<div class="text-sm text-gray-700">' +
                            (best ? '<span class="font-semibold text-purple-700">' + escapeHtml(samples[best.valueIndex]) + '</span> has the highest numeric value.' : 'No numeric values available for this metric.') +
                        '</div>' +
                    '</div>';

                const width = 760;
                const height = 330;
                const padding = { top: 34, right: 34, bottom: 72, left: 72 };
                const plotWidth = width - padding.left - padding.right;
                const plotHeight = height - padding.top - padding.bottom;
                const pointColors = ['#7c3aed', '#db2777', '#0891b2'];
                const xPositions = row.values.map((value, sampleIndex) => padding.left + (plotWidth / 2) * sampleIndex);
                const yForValue = value => padding.top + ((yMax - value) / (yMax - yMin)) * plotHeight;
                const points = row.values.map((value, sampleIndex) => {
                    if (value === null) return null;
                    return { x: xPositions[sampleIndex], y: yForValue(value), value, sampleIndex };
                });
                const linePoints = points.filter(point => point !== null).map(point => point.x + ',' + point.y).join(' ');
                const gridValues = [0, 0.25, 0.5, 0.75, 1].map(step => yMin + ((yMax - yMin) * step));

                const gridMarkup = gridValues.map(value => {
                    const y = yForValue(value);
                    return '<line x1="' + padding.left + '" y1="' + y + '" x2="' + (width - padding.right) + '" y2="' + y + '" stroke="#ede9fe" stroke-width="1" />' +
                        '<text x="' + (padding.left - 12) + '" y="' + (y + 4) + '" text-anchor="end" class="viz-axis-label">' + formatNumber(value) + '</text>';
                }).join('');

                const pointMarkup = points.map(point => {
                    if (!point) return '';
                    const labelY = point.y < 58 ? point.y + 28 : point.y - 14;
                    return '<g>' +
                        '<circle cx="' + point.x + '" cy="' + point.y + '" r="8" fill="' + pointColors[point.sampleIndex] + '" stroke="#ffffff" stroke-width="4" />' +
                        '<text x="' + point.x + '" y="' + labelY + '" text-anchor="middle" class="viz-value-label">' + escapeHtml(row.raw[point.sampleIndex]) + '</text>' +
                    '</g>';
                }).join('');

                const axisSamples = ['Sample A', 'Sample B', 'Sample C'];
                const sampleLabels = axisSamples.map((sample, sampleIndex) =>
                    '<text x="' + xPositions[sampleIndex] + '" y="' + (height - 35) + '" text-anchor="middle" class="viz-axis-label">' + escapeHtml(sample) + '</text>'
                ).join('');

                const cardsMarkup = row.values.map((value, sampleIndex) => {
                    const dotColors = ['bg-purple-500', 'bg-pink-500', 'bg-cyan-500'];
                    const valueLabel = row.raw[sampleIndex] && row.raw[sampleIndex] !== '-' ? row.raw[sampleIndex] : 'No numeric value';
                    const isBest = best && best.valueIndex === sampleIndex;
                    return '<div class="viz-card rounded-xl p-4' + (isBest ? ' ring-2 ring-purple-300' : '') + '">' +
                        '<div class="flex items-start justify-between gap-3 mb-3">' +
                            '<div class="flex items-center gap-2">' +
                                '<span class="viz-dot ' + dotColors[sampleIndex] + '"></span>' +
                                '<span class="font-semibold text-gray-900">' + escapeHtml(samples[sampleIndex]) + '</span>' +
                            '</div>' +
                            (isBest ? '<span class="text-xs px-2 py-1 rounded-full bg-purple-100 text-purple-700 font-semibold">Highest</span>' : '') +
                        '</div>' +
                        '<p class="text-2xl font-bold text-gray-900">' + escapeHtml(valueLabel) + '</p>' +
                    '</div>';
                }).join('');

                chart.innerHTML =
                    '<div class="viz-chart rounded-xl p-4 mb-4 overflow-x-auto">' +
                        '<svg viewBox="0 0 ' + width + ' ' + height + '" role="img" aria-label="' + escapeHtml(row.metric) + ' line graph">' +
                            '<rect x="0" y="0" width="' + width + '" height="' + height + '" rx="18" fill="#ffffff"></rect>' +
                            gridMarkup +
                            '<line x1="' + padding.left + '" y1="' + padding.top + '" x2="' + padding.left + '" y2="' + (height - padding.bottom) + '" stroke="#c4b5fd" stroke-width="2" />' +
                            '<line x1="' + padding.left + '" y1="' + (height - padding.bottom) + '" x2="' + (width - padding.right) + '" y2="' + (height - padding.bottom) + '" stroke="#c4b5fd" stroke-width="2" />' +
                            (linePoints ? '<polyline points="' + linePoints + '" fill="none" stroke="#7c3aed" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" />' : '') +
                            pointMarkup +
                            sampleLabels +
                            '<text x="' + padding.left + '" y="22" class="viz-axis-label">Value</text>' +
                            '<text x="' + (width - padding.right) + '" y="' + (height - 12) + '" text-anchor="end" class="viz-axis-label">Samples</text>' +
                        '</svg>' +
                    '</div>' +
                    '<div class="grid grid-cols-1 lg:grid-cols-3 gap-4">' + cardsMarkup + '</div>';
            }

            function formatNumber(value) {
                if (Math.abs(value) >= 100) return value.toFixed(0);
                if (Math.abs(value) >= 10) return value.toFixed(1);
                return value.toFixed(2);
            }

            select.addEventListener('change', function() {
                render(Number(this.value));
            });
            render(0);
        }

        document.addEventListener('DOMContentLoaded', initializeExperimentVisualization);

        function toggleDropdown(event, dropdownId) {
            event.stopPropagation();
            const dropdown = document.getElementById(dropdownId);
            const isHidden = dropdown.classList.contains('hidden');
            
            document.querySelectorAll('[id*="dropdown"]').forEach(d => {
                if (d.id !== dropdownId) {
                    d.classList.add('hidden');
                }
            });
            
            if (isHidden) {
                dropdown.classList.remove('hidden');
            } else {
                dropdown.classList.add('hidden');
            }
        }
        
        document.addEventListener('click', function() {
            document.querySelectorAll('[id*="dropdown"]').forEach(d => {
                d.classList.add('hidden');
            });
        });
    </script>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>





