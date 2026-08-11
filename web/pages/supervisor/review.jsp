<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Experiment - OMRS</title>
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
        
        .input-field {
            background: #ffffff;
            border: 1px solid rgba(167, 139, 250, 0.2);
            color: #1a202c;
            transition: all 0.3s ease;
        }
        .input-field:focus {
            border-color: #a78bfa;
            box-shadow: 0 0 0 3px rgba(167, 139, 250, 0.1);
            outline: none;
        }
        
        .btn-approve {
            background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
            color: #ffffff;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(34, 197, 94, 0.2);
        }
        .btn-approve:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(34, 197, 94, 0.3);
        }
        
        .btn-reject {
            background: rgba(239,68,68,0.1);
            border: 1px solid rgba(239,68,68,0.3);
            color: #ef4444;
            transition: all 0.3s ease;
        }
        .btn-reject:hover {
            background: rgba(239,68,68,0.2);
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
        Experiment exp = (Experiment) request.getAttribute("experiment");
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
        
        <!-- Page Title -->
        <div class="mb-8">
            <h1 class="text-3xl font-bold text-gray-900 mb-2">Review Optical Material Study</h1>
            <p class="text-gray-700 font-semibold">Evaluate the objective, sample comparison plan, uploaded data, and student notes.</p>
        </div>
        
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
                    <p class="text-gray-700 text-sm">Submitted</p>
                    <p class="text-gray-700 font-mono"><%= exp.getExperimentDate() %></p>
                    <a href="${pageContext.request.contextPath}/experiment/export/<%= exp.getExperimentId() %>"
                       class="inline-flex items-center mt-3 px-3 py-2 rounded-lg bg-green-500/10 text-green-600 hover:bg-green-500/20 transition-colors text-sm font-semibold">
                        <i class="fas fa-file-csv mr-2"></i>Export CSV
                    </a>
                </div>
            </div>
        </div>
        
        <!-- Experiment Details -->
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
                        <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getStudyObjective() %></p>
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
                        <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mb-1">Hypothesis</p>
                        <p class="text-gray-900 whitespace-pre-wrap mb-4"><%= exp.getHypothesis() %></p>
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
                        <p class="text-xs uppercase tracking-wide text-purple-700 font-semibold mt-4 mb-1">Controlled Variables</p>
                        <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getControlledVariables() %></p>
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
                        <div class="space-y-4">
                            <h3 class="text-gray-900 font-semibold"><%= exp.getComparisonMetricLabel() != null && !exp.getComparisonMetricLabel().isEmpty() ? exp.getComparisonMetricLabel() : "Comparison Metric" %></h3>
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
                            <p class="text-gray-900 font-semibold mb-2">Sample A</p>
                            <p class="text-gray-700 text-sm mb-1">Sample Label</p>
                            <p class="text-gray-900 mb-3"><%= exp.getSampleOneName() != null && !exp.getSampleOneName().isEmpty() ? exp.getSampleOneName() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Changed Condition</p>
                            <p class="text-gray-900 mb-3"><%= exp.getSampleOneCondition() != null && !exp.getSampleOneCondition().isEmpty() ? exp.getSampleOneCondition() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Observation / Result Notes</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getSampleOneNotes() != null && !exp.getSampleOneNotes().isEmpty() ? exp.getSampleOneNotes() : "No notes provided." %></p>
                        </div>
                        <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                            <p class="text-gray-900 font-semibold mb-2">Sample B</p>
                            <p class="text-gray-700 text-sm mb-1">Sample Label</p>
                            <p class="text-gray-900 mb-3"><%= exp.getSampleTwoName() != null && !exp.getSampleTwoName().isEmpty() ? exp.getSampleTwoName() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Changed Condition</p>
                            <p class="text-gray-900 mb-3"><%= exp.getSampleTwoCondition() != null && !exp.getSampleTwoCondition().isEmpty() ? exp.getSampleTwoCondition() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Observation / Result Notes</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getSampleTwoNotes() != null && !exp.getSampleTwoNotes().isEmpty() ? exp.getSampleTwoNotes() : "No notes provided." %></p>
                        </div>
                        <div class="bg-purple-50 rounded-xl p-5 border border-purple-200">
                            <p class="text-gray-900 font-semibold mb-2">Sample C</p>
                            <p class="text-gray-700 text-sm mb-1">Sample Label</p>
                            <p class="text-gray-900 mb-3"><%= exp.getSampleThreeName() != null && !exp.getSampleThreeName().isEmpty() ? exp.getSampleThreeName() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Changed Condition</p>
                            <p class="text-gray-900 mb-3"><%= exp.getSampleThreeCondition() != null && !exp.getSampleThreeCondition().isEmpty() ? exp.getSampleThreeCondition() : "Not specified" %></p>
                            <p class="text-gray-700 text-sm mb-1">Observation / Result Notes</p>
                            <p class="text-gray-900 whitespace-pre-wrap"><%= exp.getSampleThreeNotes() != null && !exp.getSampleThreeNotes().isEmpty() ? exp.getSampleThreeNotes() : "No notes provided." %></p>
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
                        <p class="text-gray-900 whitespace-pre-wrap font-mono text-sm leading-relaxed">
                            <%= exp.getPreparationNotes() != null && !exp.getPreparationNotes().isEmpty() ? exp.getPreparationNotes() : "No preparation notes provided." %>
                        </p>
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
            <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-3 mb-6">
                <div class="flex items-center">
                <div class="w-10 h-10 rounded-xl bg-blue-500/10 flex items-center justify-center mr-4">
                    <i class="fas fa-file-upload text-blue-400"></i>
                </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Uploaded Characterization Data</h2>
                        <p class="text-sm text-gray-600">Preview submitted files before making your decision.</p>
                    </div>
                </div>
                <span class="self-start lg:self-auto rounded-full bg-purple-50 px-3 py-1 text-sm font-semibold text-purple-700"><%= files.size() %> file<%= files.size() == 1 ? "" : "s" %></span>
            </div>
            
            <div class="space-y-5">
                <% for (TestData file : files) {
                    String fileNameLower = file.getFileName() != null ? file.getFileName().toLowerCase() : "";
                    boolean isImage = fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") ||
                            fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif") ||
                            fileNameLower.endsWith(".svg") ||
                            fileNameLower.endsWith(".tif") || fileNameLower.endsWith(".tiff");
                    boolean isText = fileNameLower.endsWith(".txt") || fileNameLower.endsWith(".csv") ||
                            fileNameLower.endsWith(".dat");
                    boolean isPdf = fileNameLower.endsWith(".pdf");
                    String viewUrl = request.getContextPath() + "/download?testDataId=" + file.getTestDataId() + "&action=view";
                    String downloadUrl = request.getContextPath() + "/download?testDataId=" + file.getTestDataId();
                %>
                <div class="rounded-2xl border border-purple-200 bg-white overflow-hidden shadow-sm">
                    <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4 p-5 bg-gradient-to-r from-purple-50 to-white border-b border-purple-100">
                        <div class="flex items-center min-w-0">
                            <div class="w-12 h-12 rounded-xl flex items-center justify-center mr-4 flex-shrink-0
                                <%= "FTIR".equals(file.getTestType()) ? "bg-yellow-100 text-yellow-600" : 
                                    "SEM".equals(file.getTestType()) ? "bg-purple-100 text-purple-600" : 
                                    "UV-VIS".equals(file.getTestType()) ? "bg-red-100 text-red-600" : 
                                    "bg-gray-100 text-gray-700" %>">
                                <i class="fas <%= isImage ? "fa-image" : isPdf ? "fa-file-pdf" : isText ? "fa-file-lines" : "fa-file-alt" %>"></i>
                            </div>
                            <div class="min-w-0 flex-1">
                                <div class="flex flex-wrap items-center gap-2 mb-1">
                                    <span class="text-sm font-semibold px-2.5 py-0.5 rounded-lg
                                        <%= "FTIR".equals(file.getTestType()) ? "bg-yellow-100 text-yellow-700" : 
                                            "SEM".equals(file.getTestType()) ? "bg-purple-100 text-purple-700" : 
                                            "UV-VIS".equals(file.getTestType()) ? "bg-red-100 text-red-700" : 
                                            "bg-gray-100 text-gray-700" %>">
                                        <%= file.getTestType() %>
                                    </span>
                                    <span class="text-xs text-gray-500"><%= isImage ? "Image preview" : isPdf ? "PDF preview" : isText ? "Text preview" : "File" %></span>
                                </div>
                                <p class="text-gray-900 break-all text-sm font-semibold"><%= file.getFileName() %></p>
                                <p class="text-gray-600 text-xs">ID <%= file.getTestDataId() %> - <%= file.getFileSize() %></p>
                            </div>
                        </div>
                        <div class="flex flex-wrap gap-2">
                            <% if (isImage || isText || isPdf) { %>
                            <a href="<%= viewUrl %>" target="_blank" rel="noopener"
                               class="px-3 py-2 rounded-lg bg-purple-100 text-purple-700 hover:bg-purple-200 transition-colors text-sm font-semibold inline-flex items-center">
                                <i class="fas fa-up-right-from-square mr-2"></i>Open
                            </a>
                            <% } %>
                            <a href="<%= downloadUrl %>"
                               class="px-3 py-2 rounded-lg bg-blue-100 text-blue-700 hover:bg-blue-200 transition-colors text-sm font-semibold inline-flex items-center">
                                <i class="fas fa-download mr-2"></i>Download
                            </a>
                        </div>
                    </div>

                    <% if (isImage) { %>
                    <div class="p-5 bg-white">
                        <a href="<%= viewUrl %>" target="_blank" rel="noopener" class="block">
                            <img src="<%= viewUrl %>"
                                 alt="<%= file.getFileName() %>"
                                 onerror="this.classList.add('hidden'); document.getElementById('preview-error-<%= file.getTestDataId() %>').classList.remove('hidden');"
                                 class="w-full max-h-[460px] object-contain rounded-xl border border-purple-100 bg-gray-50">
                        </a>
                        <div id="preview-error-<%= file.getTestDataId() %>" class="hidden rounded-xl border border-amber-200 bg-amber-50 p-5 text-amber-800">
                            <div class="flex items-start gap-3">
                                <i class="fas fa-triangle-exclamation mt-1"></i>
                                <div>
                                    <p class="font-semibold">Preview could not be loaded.</p>
                                    <p class="text-sm mt-1">The file record exists, but the uploaded file is not available from the server. Try Open or Download; if both fail, ask the student to re-upload it.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } else if (isText) { %>
                    <div class="p-5 bg-white">
                        <div class="bg-gray-50 rounded-xl p-4 max-h-80 overflow-auto border border-purple-100">
                            <pre id="content-supervisor-<%= file.getTestDataId() %>" class="text-xs text-gray-800 whitespace-pre-wrap font-mono">Loading content...</pre>
                        </div>
                        <script>
                            fetch('<%= viewUrl %>')
                                .then(response => {
                                    if (!response.ok) {
                                        throw new Error('File unavailable on server');
                                    }
                                    return response;
                                })
                                .then(response => response.text())
                                .then(content => {
                                    document.getElementById('content-supervisor-<%= file.getTestDataId() %>').textContent = content;
                                })
                                .catch(error => {
                                    document.getElementById('content-supervisor-<%= file.getTestDataId() %>').textContent = 'Preview unavailable: ' + error.message + '. Try Open or Download; if both fail, ask the student to re-upload it.';
                                });
                        </script>
                    </div>
                    <% } else if (isPdf) { %>
                    <div class="p-5 bg-white">
                        <iframe src="<%= viewUrl %>"
                                class="w-full h-[520px] border border-purple-100 rounded-xl bg-gray-50"
                                title="<%= file.getFileName() %>"></iframe>
                    </div>
                    <% } else { %>
                    <div class="p-5 bg-white">
                        <p class="text-gray-700 text-sm">This file type cannot be previewed in the browser. Use Download to inspect it.</p>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
        <% } %>
        
        <!-- Review Form -->
        <form action="${pageContext.request.contextPath}/supervisor/review/<%= exp.getExperimentId() %>" method="POST" class="glass rounded-2xl p-8">
            <div class="flex items-center mb-6">
                <div class="w-10 h-10 rounded-xl bg-green-500/10 flex items-center justify-center mr-4">
                    <i class="fas fa-clipboard-check text-green-600"></i>
                </div>
                <div>
                    <h2 class="text-xl font-semibold text-gray-900">Your Decision</h2>
                    <p class="text-sm text-gray-600">Add comments when a revision would help the student improve the submission.</p>
                </div>
            </div>
            
            <div class="mb-6">
                <label class="block text-gray-700 text-sm font-medium mb-2">Feedback / Comments</label>
                <textarea name="feedback" rows="4"
                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                          placeholder="Provide feedback to the student (optional for approval, recommended for rejection)..."></textarea>
            </div>
            
            <!-- Action Buttons -->
            <div class="flex flex-col sm:flex-row gap-4">
                <button type="submit" name="action" value="reject"
                        class="btn-reject flex-1 px-6 py-4 rounded-xl text-red-500 font-semibold text-center border border-red-200 bg-red-50 hover:bg-red-100">
                    <i class="fas fa-times mr-2"></i> Reject & Request Revision
                </button>
                <button type="submit" name="action" value="approve"
                        class="btn-approve flex-1 px-6 py-4 rounded-xl text-white font-semibold text-center shadow-lg shadow-green-500/20">
                    <i class="fas fa-check mr-2"></i> Approve Experiment
                </button>
            </div>
        </form>
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






