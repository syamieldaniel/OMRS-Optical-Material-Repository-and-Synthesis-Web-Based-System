<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.omrs.model.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Experiment - OMRS</title>
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
        
        .btn-primary {
            background: linear-gradient(135deg, #a78bfa 0%, #d8b4fe 100%);
            color: #1a202c;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(167, 139, 250, 0.3);
            font-weight: 600;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(37, 99, 235, 0.3);
        }
        
        .btn-secondary {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            color: #1a202c;
            transition: all 0.3s ease;
        }
        .btn-secondary:hover {
            background: rgba(255,255,255,0.1);
        }
        
        .btn-draft {
            background: rgba(139,92,246,0.1);
            border: 1.5px solid rgba(124, 58, 237,0.3);
            color: #a855f7;
            transition: all 0.3s ease;
        }
        .btn-draft:hover {
            background: rgba(139,92,246,0.2);
        }
        
        .material-card {
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .material-card:hover {
            border-color: rgba(0,255,245,0.3);
            background: rgba(0,255,245,0.05);
        }
        .material-card.active {
            border-color: rgba(124, 58, 237, 0.55);
            background: rgba(124, 58, 237, 0.10);
            box-shadow: inset 0 0 0 2px rgba(124, 58, 237, 0.12), 0 10px 24px rgba(124, 58, 237, 0.10);
        }

        .exp-quick-nav {
            position: sticky;
            top: 1rem;
            z-index: 30;
            display: flex;
            gap: 0.5rem;
            overflow-x: auto;
            padding: 0.7rem;
            margin-bottom: 1rem;
            border-radius: 1rem;
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid rgba(124, 58, 237, 0.18);
            box-shadow: 0 12px 30px rgba(88, 28, 135, 0.10);
            backdrop-filter: blur(16px);
        }

        .exp-quick-nav a {
            flex: 0 0 auto;
            border-radius: 999px;
            padding: 0.55rem 0.9rem;
            color: #5b21b6;
            background: rgba(124, 58, 237, 0.08);
            border: 1px solid transparent;
            font-size: 0.85rem;
            font-weight: 700;
            white-space: nowrap;
        }

        .exp-quick-nav a.active,
        .exp-quick-nav a:hover {
            color: #ffffff;
            background: #7c3aed;
            border-color: rgba(91, 33, 182, 0.22);
        }

        #experimentForm {
            background: rgba(255, 255, 255, 0.78);
        }

        #experimentForm > div:has(h2) {
            scroll-margin-top: 6rem;
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.16);
            box-shadow: 0 8px 22px rgba(88, 28, 135, 0.07);
        }

        #experimentForm > div:has(h2) > .flex:first-child,
        #experimentForm > div:has(h2) > .flex.flex-col:first-child {
            padding-bottom: 1rem;
            border-bottom: 1px solid rgba(124, 58, 237, 0.12);
        }

        .exp-required-strip {
            border-radius: 1rem;
            border: 1px solid rgba(124, 58, 237, 0.18);
            background: linear-gradient(135deg, rgba(124, 58, 237, 0.10), rgba(20, 184, 166, 0.08));
        }

        .exp-actions {
            position: sticky;
            bottom: 1rem;
            z-index: 25;
            padding: 1rem;
            border-radius: 1rem;
            background: rgba(255, 255, 255, 0.94);
            border: 1px solid rgba(124, 58, 237, 0.18);
            box-shadow: 0 14px 36px rgba(88, 28, 135, 0.16);
            backdrop-filter: blur(16px);
        }

        .char-subsection {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin: 1.25rem 0 1rem;
            padding: 0.75rem 1rem;
            border-radius: 0.85rem;
            background: rgba(14, 165, 233, 0.08);
            border: 1px solid rgba(14, 165, 233, 0.16);
        }

        .char-subsection span {
            width: 1.75rem;
            height: 1.75rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            background: #0ea5e9;
            color: #ffffff;
            font-weight: 800;
            font-size: 0.8rem;
        }

        .char-method-card {
            border: 1px solid rgba(124, 58, 237, 0.18);
            border-radius: 1rem;
            padding: 1rem;
            background: #ffffff;
            color: #111827;
        }

        .char-method-card label {
            margin-bottom: 0.75rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid rgba(124, 58, 237, 0.12);
        }

        .char-method-card input[type="file"] {
            background: rgba(248, 250, 252, 0.95);
        }

        .char-settings-card {
            border: 1px solid rgba(124, 58, 237, 0.16);
            border-radius: 1rem;
            padding: 1rem;
            background: rgba(248, 250, 252, 0.78);
        }

        .char-raw-toggle {
            border: 1px solid rgba(20, 184, 166, 0.24);
            background: rgba(20, 184, 166, 0.08);
        }

        @media (max-width: 1023px) {
            .exp-quick-nav {
                top: 4.35rem;
            }
        }

    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        String studentType = (String) session.getAttribute("studentType");
        boolean isFypStudent = "FYP".equals(studentType);
        String titleValue = request.getParameter("title") != null ? request.getParameter("title") : "";
        String dateValue = request.getParameter("date") != null ? request.getParameter("date") : "";
        String concentrationValue = request.getParameter("concentration") != null ? request.getParameter("concentration") : "";
        String concentrationAmountValue = request.getParameter("concentrationAmount") != null ? request.getParameter("concentrationAmount") : concentrationValue;
        String concentrationUnitValue = request.getParameter("concentrationUnit") != null ? request.getParameter("concentrationUnit") : "";
        String concentrationUnitOtherValue = request.getParameter("concentrationUnitOther") != null ? request.getParameter("concentrationUnitOther") : "";
        List<String> concentrationUnits = Arrays.asList("", "M", "mM", "uM", "ppm", "wt%", "vol%", "mg/mL", "g/L", "%", "Other");
        if (request.getParameter("concentrationAmount") == null && concentrationValue.contains(" ")) {
            String possibleUnit = concentrationValue.substring(concentrationValue.lastIndexOf(" ") + 1).trim();
            String possibleAmount = concentrationValue.substring(0, concentrationValue.lastIndexOf(" ")).trim();
            if (concentrationUnits.contains(possibleUnit)) {
                concentrationAmountValue = possibleAmount;
                concentrationUnitValue = possibleUnit;
            }
        }
        String studyTypeValue = "COMPARISON".equals(request.getParameter("studyType")) ? "COMPARISON" : "SINGLE";
        String materialBValue = request.getParameter("materialBType") != null ? request.getParameter("materialBType") : "";
        String customMaterialBValue = request.getParameter("customMaterialB") != null ? request.getParameter("customMaterialB") : "";
        String materialBConcentrationAmountValue = request.getParameter("materialBConcentrationAmount") != null ? request.getParameter("materialBConcentrationAmount") : "";
        String materialBConcentrationUnitValue = request.getParameter("materialBConcentrationUnit") != null ? request.getParameter("materialBConcentrationUnit") : "";
        String materialBConcentrationUnitOtherValue = request.getParameter("materialBConcentrationUnitOther") != null ? request.getParameter("materialBConcentrationUnitOther") : "";
        String comparisonMetricLabelValue = request.getParameter("comparisonMetricLabel") != null ? request.getParameter("comparisonMetricLabel") : "";
        String materialAMetricValue = request.getParameter("materialAMetricValue") != null ? request.getParameter("materialAMetricValue") : "";
        String materialBMetricValue = request.getParameter("materialBMetricValue") != null ? request.getParameter("materialBMetricValue") : "";
        String comparisonNotesValue = request.getParameter("comparisonNotes") != null ? request.getParameter("comparisonNotes") : "";
        String[] tableMetricValues = request.getParameterValues("tableMetric");
        String[] tableSampleAValues = request.getParameterValues("tableSampleA");
        String[] tableSampleBValues = request.getParameterValues("tableSampleB");
        String[] tableSampleCValues = request.getParameterValues("tableSampleC");
        String[] metricOptions = {
            "",
            "Growth time (h)",
            "Band gap energy Eg (eV)",
            "Absorbance peak wavelength (nm)",
            "Maximum absorbance (a.u.)",
            "Transmittance (%)",
            "Reflectance (%)",
            "Refractive index",
            "Film thickness (nm)",
            "Particle / rod diameter (nm)",
            "Rod length (nm)",
            "XRD peak position 2theta (degree)",
            "XRD peak intensity (a.u.)",
            "Efficiency without dye (%)",
            "Efficiency with dye (%)",
            "Current density (mA/cm2)",
            "Voltage (V)",
            "Resistance (ohm)",
            "Conductivity (S/m)",
            "Other observation"
        };
        List<String> metricOptionList = Arrays.asList(metricOptions);
        String studyObjectiveValue = request.getParameter("studyObjective") != null ? request.getParameter("studyObjective") : "";
        String hypothesisValue = request.getParameter("hypothesis") != null ? request.getParameter("hypothesis") : "";
        String independentVariableValue = request.getParameter("independentVariable") != null ? request.getParameter("independentVariable") : "";
        String dependentVariableValue = request.getParameter("dependentVariable") != null ? request.getParameter("dependentVariable") : "";
        String controlledVariablesValue = request.getParameter("controlledVariables") != null ? request.getParameter("controlledVariables") : "";
        String preparationNotesValue = request.getParameter("preparationNotes") != null ? request.getParameter("preparationNotes") : "";
        String characterizationNotesValue = request.getParameter("characterizationNotes") != null ? request.getParameter("characterizationNotes") : "";
        String instrumentDetailsValue = request.getParameter("instrumentDetails") != null ? request.getParameter("instrumentDetails") : "";
        String scanRangeValue = request.getParameter("scanRange") != null ? request.getParameter("scanRange") : "";
        String calibrationReferenceValue = request.getParameter("calibrationReference") != null ? request.getParameter("calibrationReference") : "";
        String replicateCountValue = request.getParameter("replicateCount") != null ? request.getParameter("replicateCount") : "";
        String measurementUncertaintyValue = request.getParameter("measurementUncertainty") != null ? request.getParameter("measurementUncertainty") : "";
        boolean rawDataRequiredValue = request.getParameter("rawDataRequired") != null;
        String conclusionValue = request.getParameter("conclusion") != null ? request.getParameter("conclusion") : "";
        String limitationsValue = request.getParameter("limitations") != null ? request.getParameter("limitations") : "";
        String nextStepsValue = request.getParameter("nextSteps") != null ? request.getParameter("nextSteps") : "";
        String characterizationOtherValue = request.getParameter("characterizationOther") != null ? request.getParameter("characterizationOther") : "";
        String materialValue = request.getParameter("materialType") != null ? request.getParameter("materialType") : "";
        String customMaterialValue = request.getParameter("customMaterial") != null ? request.getParameter("customMaterial") : "";
        Set<String> characterizationSelections = new LinkedHashSet<>();
        String[] characterizationValues = request.getParameterValues("characterizationMethods");
        if (characterizationValues != null) {
            characterizationSelections.addAll(Arrays.asList(characterizationValues));
        }
        String sampleOneNameValue = request.getParameter("sampleOneName") != null ? request.getParameter("sampleOneName") : "";
        String sampleOneConditionValue = request.getParameter("sampleOneCondition") != null ? request.getParameter("sampleOneCondition") : "";
        String sampleOneNotesValue = request.getParameter("sampleOneNotes") != null ? request.getParameter("sampleOneNotes") : "";
        String sampleTwoNameValue = request.getParameter("sampleTwoName") != null ? request.getParameter("sampleTwoName") : "";
        String sampleTwoConditionValue = request.getParameter("sampleTwoCondition") != null ? request.getParameter("sampleTwoCondition") : "";
        String sampleTwoNotesValue = request.getParameter("sampleTwoNotes") != null ? request.getParameter("sampleTwoNotes") : "";
        String sampleThreeNameValue = request.getParameter("sampleThreeName") != null ? request.getParameter("sampleThreeName") : "";
        String sampleThreeConditionValue = request.getParameter("sampleThreeCondition") != null ? request.getParameter("sampleThreeCondition") : "";
        String sampleThreeNotesValue = request.getParameter("sampleThreeNotes") != null ? request.getParameter("sampleThreeNotes") : "";
    %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">

        <!-- Page Title -->
        <div class="mb-8">
            <h1 class="text-3xl font-bold text-gray-900 mb-2">New Optical Material Study</h1>
            <p class="text-gray-700">Record one material study, compare three samples, and upload optical characterization data.</p>
        </div>

        <!-- Error Message -->
        <% if (request.getAttribute("error") != null) { %>
        <div class="mb-6 bg-red-500/10 border border-red-500/30 rounded-2xl px-6 py-4 flex items-start">
            <i class="fas fa-exclamation-circle text-red-400 mr-4 mt-1"></i>
            <div>
                <p class="text-red-400 font-semibold">Error</p>
                <p class="text-red-300 text-sm"><%= request.getAttribute("error") %></p>
            </div>
        </div>
        <% } %>

        <nav class="exp-quick-nav" aria-label="Experiment sections">
            <a href="#section-study-type">Type</a>
            <a href="#section-material">Material</a>
            <a href="#section-comparison">Compare</a>
            <a href="#section-setup">Setup</a>
            <a href="#section-objective">Objective</a>
            <a href="#section-samples">Samples</a>
            <a href="#section-characterization">Characterization</a>
            <a href="#section-preparation">Method</a>
            <a href="#section-results">Results</a>
            <a href="#section-conclusion">Conclusion</a>
        </nav>

        <!-- Form -->
        <form action="${pageContext.request.contextPath}/student/create" method="POST" enctype="multipart/form-data" id="experimentForm" class="glass rounded-2xl p-8">
            <div class="exp-required-strip p-4 mb-6 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-3">
                <div>
                    <p class="text-xs font-semibold uppercase tracking-wide text-purple-700 mb-1">Start with the required fields</p>
                    <p class="text-sm text-gray-700">Material, study title, experiment date, objective, and preparation method are the core details for review.</p>
                </div>
                <span class="inline-flex items-center rounded-full bg-white px-3 py-1 text-sm font-semibold text-purple-700 border border-purple-100">
                    <i class="fas fa-check-circle mr-2"></i>Draft anytime
                </span>
            </div>
            <div class="mb-8 grid grid-cols-1 md:grid-cols-3 gap-3">
                <div class="rounded-xl border border-purple-200 bg-purple-50/70 p-4">
                    <p class="text-xs font-semibold text-purple-700 mb-1">1. Material</p>
                    <p class="text-sm text-gray-700">Choose the optical material first.</p>
                </div>
                <div class="rounded-xl border border-purple-200 bg-purple-50/70 p-4">
                    <p class="text-xs font-semibold text-purple-700 mb-1">2. Setup</p>
                    <p class="text-sm text-gray-700">Enter title, date, and concentration unit.</p>
                </div>
                <div class="rounded-xl border border-purple-200 bg-purple-50/70 p-4">
                    <p class="text-xs font-semibold text-purple-700 mb-1">3. Aim & Samples</p>
                    <p class="text-sm text-gray-700">Define objective and compare Sample A, B, and C.</p>
                </div>
            </div>

            <!-- Study Type Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-indigo-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-chart-bar text-indigo-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Study Type</h2>
                        <p class="text-gray-700 text-sm">Choose whether this experiment studies one material or compares two different materials</p>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <label class="border border-purple-200 rounded-xl p-4 bg-purple-50/40 cursor-pointer">
                        <input type="radio" name="studyType" value="SINGLE" class="accent-purple-600 mr-2" <%= "SINGLE".equals(studyTypeValue) ? "checked" : "" %> onchange="toggleStudyType()">
                        <span class="font-semibold text-gray-900">Single Material Study</span>
                        <p class="text-sm text-gray-700 mt-1">Compare conditions or samples within one material.</p>
                    </label>
                    <label class="border border-purple-200 rounded-xl p-4 bg-purple-50/40 cursor-pointer">
                        <input type="radio" name="studyType" value="COMPARISON" class="accent-purple-600 mr-2" <%= "COMPARISON".equals(studyTypeValue) ? "checked" : "" %> onchange="toggleStudyType()">
                        <span class="font-semibold text-gray-900">Compare Two Materials</span>
                        <p class="text-sm text-gray-700 mt-1">Compare optical results between Material A and Material B.</p>
                    </label>
                </div>
            </div>
            
            <!-- Material Type Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-purple-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-atom text-purple-400"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Optical Material <span class="text-red-400">*</span></h2>
                        <p class="text-gray-700 text-sm">Select the material being prepared or characterized</p>
                    </div>
                </div>

                <div class="rounded-xl border border-purple-200 bg-purple-50/70 p-4 mb-6">
                    <p class="text-xs font-semibold uppercase tracking-wide text-purple-700 mb-1">Step 2 of the research flow</p>
                    <p class="text-sm text-gray-700"><%= isFypStudent
                        ? "This study record connects your learning materials, optical-constants calculations, weekly logbook progress, supervisor review, and final repository entry."
                        : "This study record connects your learning materials, optical-constants calculations, experiment files, and repository browsing." %></p>
                </div>
                
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <label class="material-card glass rounded-xl p-4 text-center <%= "Silica".equals(materialValue) ? "active" : "" %>" onclick="selectMaterial('Silica')">
                        <input type="radio" name="materialType" value="Silica" class="hidden" <%= "Silica".equals(materialValue) ? "checked" : "" %> required>
                        <div class="w-12 h-12 rounded-lg bg-cyan-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-gem text-purple-600 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">Silica</p>
                        <p class="text-gray-700 text-xs">SiO2</p>
                    </label>
                    
                    <label class="material-card glass rounded-xl p-4 text-center <%= "PMMA".equals(materialValue) ? "active" : "" %>" onclick="selectMaterial('PMMA')">
                        <input type="radio" name="materialType" value="PMMA" class="hidden" <%= "PMMA".equals(materialValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-purple-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-cube text-purple-400 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">PMMA</p>
                        <p class="text-gray-700 text-xs">Acrylic</p>
                    </label>
                    
                    <label class="material-card glass rounded-xl p-4 text-center <%= "Zinc Oxide".equals(materialValue) ? "active" : "" %>" onclick="selectMaterial('Zinc Oxide')">
                        <input type="radio" name="materialType" value="Zinc Oxide" class="hidden" <%= "Zinc Oxide".equals(materialValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-yellow-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-sun text-yellow-400 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">Zinc Oxide</p>
                        <p class="text-gray-700 text-xs">ZnO</p>
                    </label>
                    
                    <label class="material-card glass rounded-xl p-4 text-center <%= "Titanium Dioxide".equals(materialValue) ? "active" : "" %>" onclick="selectMaterial('Titanium Dioxide')">
                        <input type="radio" name="materialType" value="Titanium Dioxide" class="hidden" <%= "Titanium Dioxide".equals(materialValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-blue-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-shield-alt text-blue-400 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">TiO2</p>
                        <p class="text-gray-700 text-xs">Titanium</p>
                    </label>
                    
                    <label class="material-card glass rounded-xl p-4 text-center <%= "Graphene".equals(materialValue) ? "active" : "" %>" onclick="selectMaterial('Graphene')">
                        <input type="radio" name="materialType" value="Graphene" class="hidden" <%= "Graphene".equals(materialValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-gray-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-layer-group text-gray-700 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">Graphene</p>
                        <p class="text-gray-700 text-xs">Carbon</p>
                    </label>
                    
                    <label class="material-card glass rounded-xl p-4 text-center <%= "Gold Nanoparticle".equals(materialValue) ? "active" : "" %>" onclick="selectMaterial('Gold Nanoparticle')">
                        <input type="radio" name="materialType" value="Gold Nanoparticle" class="hidden" <%= "Gold Nanoparticle".equals(materialValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-yellow-600/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-coins text-yellow-500 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">AuNP</p>
                        <p class="text-gray-700 text-xs">Gold</p>
                    </label>
                    
                    <label class="material-card glass rounded-xl p-4 text-center <%= "Silver Nanoparticle".equals(materialValue) ? "active" : "" %>" onclick="selectMaterial('Silver Nanoparticle')">
                        <input type="radio" name="materialType" value="Silver Nanoparticle" class="hidden" <%= "Silver Nanoparticle".equals(materialValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-slate-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-circle text-slate-300 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">AgNP</p>
                        <p class="text-gray-700 text-xs">Silver</p>
                    </label>
                    
                    <label class="material-card glass rounded-xl p-4 text-center <%= "Other".equals(materialValue) ? "active" : "" %>" onclick="selectMaterial('Other')">
                        <input type="radio" name="materialType" value="Other" class="hidden" <%= "Other".equals(materialValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-green-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-plus text-green-400 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">Other</p>
                        <p class="text-gray-700 text-xs">Custom</p>
                    </label>
                </div>
                
                <!-- Custom Material Input -->
                <div id="customMaterialDiv" class="<%= "Other".equals(materialValue) ? "" : "hidden" %> mt-4">
                    <label class="block text-gray-700 text-sm font-medium mb-2">
                        Custom Material Name <span class="text-red-400">*</span>
                    </label>
                    <div class="relative">
                        <i class="fas fa-cube absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                        <input type="text" name="customMaterial" id="customMaterialInput" value="<%= customMaterialValue %>"
                               class="input-field w-full pl-11 pr-4 py-3 rounded-xl placeholder-gray-600"
                               placeholder="e.g., Perovskite film, dye-doped PMMA, hybrid nanocomposite">
                    </div>
                </div>
            </div>

            <!-- Material Comparison Section -->
            <div id="comparisonSection" class="<%= "COMPARISON".equals(studyTypeValue) ? "" : "hidden" %> glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-pink-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-balance-scale text-pink-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Material B and Comparison Data</h2>
                        <p class="text-gray-700 text-sm">Add the second material and one numeric result so OMRS can visualize the comparison</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Material B</label>
                        <select name="materialBType" id="materialBType" class="input-field w-full px-4 py-3 rounded-xl" onchange="toggleMaterialBOther()">
                            <option value="" <%= materialBValue.isEmpty() ? "selected" : "" %>>Select second material</option>
                            <option value="Silica" <%= "Silica".equals(materialBValue) ? "selected" : "" %>>Silica</option>
                            <option value="PMMA" <%= "PMMA".equals(materialBValue) ? "selected" : "" %>>PMMA</option>
                            <option value="Zinc Oxide" <%= "Zinc Oxide".equals(materialBValue) ? "selected" : "" %>>Zinc Oxide</option>
                            <option value="Titanium Dioxide" <%= "Titanium Dioxide".equals(materialBValue) ? "selected" : "" %>>Titanium Dioxide</option>
                            <option value="Graphene" <%= "Graphene".equals(materialBValue) ? "selected" : "" %>>Graphene</option>
                            <option value="Gold Nanoparticle" <%= "Gold Nanoparticle".equals(materialBValue) ? "selected" : "" %>>Gold Nanoparticle</option>
                            <option value="Silver Nanoparticle" <%= "Silver Nanoparticle".equals(materialBValue) ? "selected" : "" %>>Silver Nanoparticle</option>
                            <option value="Other" <%= "Other".equals(materialBValue) ? "selected" : "" %>>Other</option>
                        </select>
                        <input type="text" name="customMaterialB" id="customMaterialBInput" value="<%= customMaterialBValue %>"
                               class="<%= "Other".equals(materialBValue) ? "" : "hidden" %> input-field w-full mt-3 px-4 py-3 rounded-xl placeholder-gray-600"
                               placeholder="Enter custom Material B name">
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Material B Concentration / Composition</label>
                        <div class="grid grid-cols-1 md:grid-cols-[1fr_150px] gap-3">
                            <input type="text" name="materialBConcentrationAmount" value="<%= materialBConcentrationAmountValue %>"
                                   class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600" placeholder="e.g., 0.75, 10, 100">
                            <select name="materialBConcentrationUnit" id="materialBConcentrationUnit" class="input-field w-full px-4 py-3 rounded-xl" onchange="toggleMaterialBUnitOther()">
                                <option value="" <%= materialBConcentrationUnitValue.isEmpty() ? "selected" : "" %>>Unit</option>
                                <option value="M" <%= "M".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>M</option>
                                <option value="mM" <%= "mM".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>mM</option>
                                <option value="uM" <%= "uM".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>uM</option>
                                <option value="ppm" <%= "ppm".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>ppm</option>
                                <option value="wt%" <%= "wt%".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>wt%</option>
                                <option value="vol%" <%= "vol%".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>vol%</option>
                                <option value="mg/mL" <%= "mg/mL".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>mg/mL</option>
                                <option value="g/L" <%= "g/L".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>g/L</option>
                                <option value="%" <%= "%".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>%</option>
                                <option value="Other" <%= "Other".equals(materialBConcentrationUnitValue) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                        <input type="text" name="materialBConcentrationUnitOther" id="materialBConcentrationUnitOther" value="<%= materialBConcentrationUnitOtherValue %>"
                               class="<%= "Other".equals(materialBConcentrationUnitValue) ? "" : "hidden" %> input-field w-full mt-3 px-4 py-3 rounded-xl placeholder-gray-600"
                               placeholder="Enter custom unit, e.g., mol%, v/v">
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Graph Metric</label>
                        <input type="text" name="comparisonMetricLabel" value="<%= comparisonMetricLabelValue %>" class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600" placeholder="e.g., Band gap (eV), Transmittance (%)">
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Material A Value</label>
                        <input type="number" step="any" name="materialAMetricValue" value="<%= materialAMetricValue %>" class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600" placeholder="e.g., 3.21">
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Material B Value</label>
                        <input type="number" step="any" name="materialBMetricValue" value="<%= materialBMetricValue %>" class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600" placeholder="e.g., 3.05">
                    </div>
                </div>
                <div class="mt-6">
                    <label class="block text-gray-700 text-sm font-medium mb-2">Comparison Notes</label>
                    <textarea name="comparisonNotes" rows="4" class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none" placeholder="Summarize which material performed better and what optical result supports the conclusion."><%= comparisonNotesValue %></textarea>
                </div>
            </div>

            <!-- Basic Info Section -->
            <div class="mb-8">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-cyan-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-info-circle text-purple-600"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Study Setup</h2>
                        <p class="text-gray-700 text-sm">Name the study and record when the work was carried out</p>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Title -->
                    <div class="md:col-span-2">
                        <label class="block text-gray-700 text-sm font-medium mb-2">
                            Study Title <span class="text-red-400">*</span>
                        </label>
                        <div class="relative">
                            <i class="fas fa-flask absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="text" name="title" id="expTitle" required value="<%= titleValue %>"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl placeholder-gray-600"
                                   placeholder="e.g., Optical characterization of ZnO thin films at different annealing temperatures">
                        </div>
                    </div>
                    <!-- Date -->
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">
                            Experiment Date <span class="text-red-400">*</span>
                        </label>
                        <div class="relative">
                            <i class="fas fa-calendar absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="date" name="date" required id="expDate" value="<%= dateValue %>"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl">
                        </div>
                    </div>
                    <!-- Concentration -->
                    <div class="md:col-span-2">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Main Concentration / Composition</label>
                        <div class="grid grid-cols-1 md:grid-cols-[1fr_150px] gap-3">
                            <div class="relative">
                                <i class="fas fa-vial absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                                <input type="text" name="concentrationAmount" value="<%= concentrationAmountValue %>"
                                       class="input-field w-full pl-11 pr-4 py-3 rounded-xl placeholder-gray-600"
                                       placeholder="e.g., 0.5, 10, 100">
                            </div>
                            <select name="concentrationUnit" id="concentrationUnit"
                                    class="input-field w-full px-4 py-3 rounded-xl"
                                    onchange="toggleConcentrationUnitOther()">
                                <option value="" <%= concentrationUnitValue.isEmpty() ? "selected" : "" %>>Unit</option>
                                <option value="M" <%= "M".equals(concentrationUnitValue) ? "selected" : "" %>>M</option>
                                <option value="mM" <%= "mM".equals(concentrationUnitValue) ? "selected" : "" %>>mM</option>
                                <option value="uM" <%= "uM".equals(concentrationUnitValue) ? "selected" : "" %>>uM</option>
                                <option value="ppm" <%= "ppm".equals(concentrationUnitValue) ? "selected" : "" %>>ppm</option>
                                <option value="wt%" <%= "wt%".equals(concentrationUnitValue) ? "selected" : "" %>>wt%</option>
                                <option value="vol%" <%= "vol%".equals(concentrationUnitValue) ? "selected" : "" %>>vol%</option>
                                <option value="mg/mL" <%= "mg/mL".equals(concentrationUnitValue) ? "selected" : "" %>>mg/mL</option>
                                <option value="g/L" <%= "g/L".equals(concentrationUnitValue) ? "selected" : "" %>>g/L</option>
                                <option value="%" <%= "%".equals(concentrationUnitValue) ? "selected" : "" %>>%</option>
                                <option value="Other" <%= "Other".equals(concentrationUnitValue) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                        <input type="text" name="concentrationUnitOther" id="concentrationUnitOther" value="<%= concentrationUnitOtherValue %>"
                               class="<%= "Other".equals(concentrationUnitValue) ? "" : "hidden" %> input-field w-full mt-3 px-4 py-3 rounded-xl placeholder-gray-600"
                               placeholder="Enter custom unit, e.g., mol%, v/v">
                    </div>
                </div>
            </div>

            <!-- Study Objective Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center justify-between gap-4 mb-6">
                    <div class="w-10 h-10 rounded-xl bg-indigo-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-bullseye text-indigo-500"></i>
                    </div>
                    <div class="flex-1">
                        <h2 class="text-xl font-semibold text-gray-900">Optical Study Objective</h2>
                        <p class="text-gray-700 text-sm">State the optical property or behavior you want to compare</p>
                    </div>
                    <button type="button" id="aiObjectiveBtn" onclick="generateStudyObjective()"
                            class="btn-draft px-4 py-2 rounded-xl text-sm font-semibold whitespace-nowrap">
                        <i class="fas fa-wand-magic-sparkles mr-2"></i>Generate with AI
                    </button>
                </div>

                <textarea name="studyObjective" id="studyObjective" rows="4"
                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                          placeholder="Example: Compare three ZnO thin-film annealing temperatures and evaluate transmittance, absorption edge, band gap trend, and surface morphology."><%= studyObjectiveValue %></textarea>
                <p id="aiObjectiveStatus" class="text-sm text-gray-700 mt-3 hidden"></p>
            </div>

            <!-- Research Protocol Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-rose-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-flask-vial text-rose-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Research Protocol</h2>
                        <p class="text-gray-700 text-sm">Define the hypothesis, changed variable, measured response, and controls before recording results</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div class="lg:col-span-2">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Hypothesis</label>
                        <textarea name="hypothesis" rows="3"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                  placeholder="Example: Increasing annealing temperature will improve ZnO crystallinity and shift the optical absorption edge."><%= hypothesisValue %></textarea>
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Independent Variable</label>
                        <input type="text" name="independentVariable" value="<%= independentVariableValue %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                               placeholder="e.g., Annealing temperature">
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Dependent Variable</label>
                        <input type="text" name="dependentVariable" value="<%= dependentVariableValue %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                               placeholder="e.g., Optical band gap, transmittance">
                    </div>
                    <div class="lg:col-span-2">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Controlled Variables</label>
                        <textarea name="controlledVariables" rows="3"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                  placeholder="List conditions kept constant, such as substrate type, precursor concentration, coating cycle, drying time, and instrument settings."><%= controlledVariablesValue %></textarea>
                    </div>
                </div>
            </div>

            <!-- AI Study Assistant Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center justify-between gap-4 mb-6">
                    <div class="flex items-center">
                        <div class="w-10 h-10 rounded-xl bg-purple-500/10 flex items-center justify-center mr-4">
                            <i class="fas fa-sparkles text-purple-500"></i>
                        </div>
                        <div>
                            <h2 class="text-xl font-semibold text-gray-900">AI Study Assistant</h2>
                            <p class="text-gray-700 text-sm">Summarize this draft or ask for help based on your current form details</p>
                        </div>
                    </div>
                    <button type="button" id="aiSummaryBtn" onclick="generateStudySummary()"
                            class="btn-draft px-4 py-2 rounded-xl text-sm font-semibold whitespace-nowrap">
                        <i class="fas fa-list-check mr-2"></i>Summarize Draft
                    </button>
                </div>

                <div id="aiSummaryBox" class="hidden rounded-xl border border-purple-200 bg-purple-50 p-5 mb-6">
                    <p class="text-xs font-semibold text-purple-700 uppercase tracking-wide mb-2">AI Summary</p>
                    <div id="aiSummaryContent" class="text-gray-900 text-sm whitespace-pre-wrap leading-relaxed"></div>
                </div>
                <p id="aiSummaryStatus" class="text-sm text-gray-700 mb-4 hidden"></p>

                <div class="rounded-xl border border-purple-200 bg-white overflow-hidden">
                    <div id="aiChatMessages" class="h-64 overflow-y-auto p-4 space-y-3 bg-purple-50/50">
                        <div class="max-w-[85%] rounded-xl bg-white border border-purple-100 p-3 text-sm text-gray-800">
                            Ask about improving your objective, choosing characterization methods, interpreting comparison metrics, or checking missing details.
                        </div>
                    </div>
                    <div class="p-4 border-t border-purple-100 bg-white">
                        <div class="flex flex-col md:flex-row gap-3">
                            <input type="text" id="aiChatInput"
                                   class="input-field flex-1 px-4 py-3 rounded-xl placeholder-gray-600"
                                   placeholder="Ask the AI about this experiment draft...">
                            <button type="button" id="aiChatBtn" onclick="sendAiChatMessage()"
                                    class="btn-primary px-5 py-3 rounded-xl font-semibold whitespace-nowrap">
                                <i class="fas fa-paper-plane mr-2"></i>Ask
                            </button>
                        </div>
                        <p id="aiChatStatus" class="text-sm text-gray-700 mt-3 hidden"></p>
                    </div>
                </div>
            </div>

            <!-- Sample Comparison Plan -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-amber-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-layer-group text-amber-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Sample Comparison Plan</h2>
                        <p class="text-gray-700 text-sm">Use one controlled study with three sample variations, such as temperature, time, concentration, or dopant ratio</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
                    <div class="border border-purple-200 rounded-2xl p-5 bg-purple-50/50">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="text-lg font-semibold text-gray-900">Sample A</h3>
                            <span class="text-xs px-3 py-1 rounded-full bg-white text-purple-700 border border-purple-200">Sample A</span>
                        </div>
                        <div class="space-y-4">
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Sample Label</label>
                                <input type="text" name="sampleOneName" value="<%= sampleOneNameValue %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                                       placeholder="e.g., ZnO-300C">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Changed Condition</label>
                                <input type="text" name="sampleOneCondition" value="<%= sampleOneConditionValue %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                                       placeholder="e.g., Annealed at 300 C for 1 hour">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Observation / Result Notes</label>
                                <textarea name="sampleOneNotes" rows="5"
                                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                          placeholder="Record visible film quality, expected optical behavior, or any preparation difference for this sample."><%= sampleOneNotesValue %></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="border border-purple-200 rounded-2xl p-5 bg-purple-50/50">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="text-lg font-semibold text-gray-900">Sample B</h3>
                            <span class="text-xs px-3 py-1 rounded-full bg-white text-purple-700 border border-purple-200">Sample B</span>
                        </div>
                        <div class="space-y-4">
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Sample Label</label>
                                <input type="text" name="sampleTwoName" value="<%= sampleTwoNameValue %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                                       placeholder="e.g., ZnO-400C">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Changed Condition</label>
                                <input type="text" name="sampleTwoCondition" value="<%= sampleTwoConditionValue %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                                       placeholder="e.g., Annealed at 400 C for 1 hour">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Observation / Result Notes</label>
                                <textarea name="sampleTwoNotes" rows="5"
                                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                          placeholder="Record visible film quality, expected optical behavior, or any preparation difference for this sample."><%= sampleTwoNotesValue %></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="border border-purple-200 rounded-2xl p-5 bg-purple-50/50">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="text-lg font-semibold text-gray-900">Sample C</h3>
                            <span class="text-xs px-3 py-1 rounded-full bg-white text-purple-700 border border-purple-200">Sample C</span>
                        </div>
                        <div class="space-y-4">
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Sample Label</label>
                                <input type="text" name="sampleThreeName" value="<%= sampleThreeNameValue %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                                       placeholder="e.g., ZnO-500C">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Changed Condition</label>
                                <input type="text" name="sampleThreeCondition" value="<%= sampleThreeConditionValue %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                                       placeholder="e.g., Annealed at 500 C for 1 hour">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Observation / Result Notes</label>
                                <textarea name="sampleThreeNotes" rows="5"
                                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                          placeholder="Record visible film quality, expected optical behavior, or any preparation difference for this sample."><%= sampleThreeNotesValue %></textarea>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Characterization Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-sky-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-microscope text-sky-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Optical Characterization Plan</h2>
                        <p class="text-gray-700 text-sm">Choose the techniques used to evaluate the three samples</p>
                    </div>
                </div>

                <div class="char-subsection">
                    <span>1</span>
                    <div>
                        <p class="font-semibold text-gray-900">Select techniques and upload files</p>
                        <p class="text-sm text-gray-700">Tick the methods used, then attach the matching raw or processed file.</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 mb-6">
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="SEM" class="accent-purple-600" <%= characterizationSelections.contains("SEM") ? "checked" : "" %>>
                            <span><i class="fas fa-microscope text-purple-500 mr-2"></i>SEM</span>
                        </label>
                        <input type="file" name="semFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-purple-100 file:text-purple-700">
                        <p class="text-gray-700 text-xs mt-2">Upload SEM images or morphology data.</p>
                    </div>
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="XRD" class="accent-purple-600" <%= characterizationSelections.contains("XRD") ? "checked" : "" %>>
                            <span><i class="fas fa-chart-line text-indigo-500 mr-2"></i>XRD</span>
                        </label>
                        <input type="file" name="xrdFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-indigo-100 file:text-indigo-700">
                        <p class="text-gray-700 text-xs mt-2">Upload diffractogram, peaks, or phase analysis.</p>
                    </div>
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="UV-Vis" class="accent-purple-600" <%= characterizationSelections.contains("UV-Vis") ? "checked" : "" %>>
                            <span><i class="fas fa-wave-square text-blue-500 mr-2"></i>UV-Vis</span>
                        </label>
                        <input type="file" name="uvvisFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-blue-100 file:text-blue-700">
                        <p class="text-gray-700 text-xs mt-2">Upload absorbance, transmittance, or Tauc data.</p>
                    </div>
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="FTIR" class="accent-purple-600" <%= characterizationSelections.contains("FTIR") ? "checked" : "" %>>
                            <span><i class="fas fa-file-waveform text-yellow-600 mr-2"></i>FTIR</span>
                        </label>
                        <input type="file" name="ftirFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-yellow-100 file:text-yellow-700">
                        <p class="text-gray-700 text-xs mt-2">Upload spectra or bond assignment data.</p>
                    </div>
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="Two-Point Probe" class="accent-purple-600" <%= characterizationSelections.contains("Two-Point Probe") ? "checked" : "" %>>
                            <span><i class="fas fa-bolt text-emerald-500 mr-2"></i>Two-Point Probe</span>
                        </label>
                        <input type="file" name="probeFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-emerald-100 file:text-emerald-700">
                        <p class="text-gray-700 text-xs mt-2">Upload resistance, conductivity, or I-V data.</p>
                    </div>
                </div>

                <div class="char-subsection">
                    <span>2</span>
                    <div>
                        <p class="font-semibold text-gray-900">Explain the analysis plan</p>
                        <p class="text-sm text-gray-700">Use this area for extra methods and how the results will be compared.</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div class="char-settings-card">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Other Technique</label>
                        <input type="text" name="characterizationOther" value="<%= characterizationOtherValue %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                               placeholder="e.g., Raman, AFM, PL">
                        <input type="file" name="otherCharacterizationFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full mt-3 px-4 py-3 rounded-xl text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-slate-100 file:text-slate-700">
                    </div>
                    <div class="char-settings-card">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Expected Analysis / Comparison Notes</label>
                        <textarea name="characterizationNotes" rows="4"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                  placeholder="Example: Use UV-Vis to compare transmittance and absorption edge, FTIR to confirm bonding, and SEM to compare surface morphology."><%= characterizationNotesValue %></textarea>
                    </div>
                </div>

                <div class="char-subsection">
                    <span>3</span>
                    <div>
                        <p class="font-semibold text-gray-900">Record measurement settings</p>
                        <p class="text-sm text-gray-700">These details help supervisors understand how reliable the uploaded data is.</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-6">
                    <div class="char-settings-card">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Instrument Details</label>
                        <textarea name="instrumentDetails" rows="4"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                  placeholder="Record instrument model, key settings, sample holder, and measurement mode."><%= instrumentDetailsValue %></textarea>
                    </div>
                    <div class="char-settings-card">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Scan Range / Conditions</label>
                        <input type="text" name="scanRange" value="<%= scanRangeValue %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 mb-4"
                               placeholder="e.g., UV-Vis 300-800 nm, 1 nm step">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Calibration / Reference</label>
                        <textarea name="calibrationReference" rows="3"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                  placeholder="e.g., Quartz blank, baseline correction, white reference tile, instrument calibration date."><%= calibrationReferenceValue %></textarea>
                    </div>
                    <div class="char-settings-card">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Replicates</label>
                        <input type="number" name="replicateCount" min="1" value="<%= replicateCountValue %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 mb-4"
                               placeholder="e.g., 3">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Measurement Uncertainty</label>
                        <input type="text" name="measurementUncertainty" value="<%= measurementUncertaintyValue %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600"
                               placeholder="e.g., +/- 0.02 eV, instrument tolerance">
                        <label class="char-raw-toggle mt-4 rounded-xl px-4 py-3 text-gray-900 flex items-center gap-3">
                            <input type="checkbox" name="rawDataRequired" value="true" class="accent-purple-600" <%= rawDataRequiredValue ? "checked" : "" %>>
                            <span>Raw characterization data is required for review</span>
                        </label>
                    </div>
                </div>
            </div>

            <!-- Preparation Notes Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 mb-6">
                    <div class="flex items-center">
                        <div class="w-10 h-10 rounded-xl bg-green-500/10 flex items-center justify-center mr-4">
                            <i class="fas fa-clipboard-list text-green-400"></i>
                        </div>
                        <div>
                            <h2 class="text-xl font-semibold text-gray-900">Common Preparation Method</h2>
                            <p class="text-gray-700 text-sm">Write this as numbered steps so it is easier to follow during review</p>
                        </div>
                    </div>
                    <button type="button" onclick="insertPreparationSteps()"
                            class="btn-draft px-4 py-2 rounded-xl text-sm font-semibold whitespace-nowrap">
                        <i class="fas fa-list-ol mr-2"></i>Use Numbered Format
                    </button>
                </div>
                <div class="rounded-xl border border-green-200 bg-green-50/70 p-4 mb-4">
                    <p class="text-sm text-gray-700">
                        Recommended format: substrate cleaning, solution preparation, coating/deposition, heating/growth,
                        washing/drying, sample variation, and characterization readiness.
                    </p>
                </div>
                
                <textarea name="preparationNotes" id="preparationNotes" rows="10"
                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                          placeholder="1. Clean substrate:
2. Prepare precursor / material solution:
3. Coat or deposit sample:
4. Heat / grow / anneal:
5. Wash and dry:
6. Apply sample variation:
7. Prepare for characterization:"><%= preparationNotesValue %></textarea>
            </div>

            <!-- Comparison Results Table Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-emerald-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-table text-emerald-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Characterization Results Table</h2>
                        <p class="text-gray-700 text-sm">Enter measured values after characterization so samples can be compared side by side</p>
                    </div>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full min-w-[720px] border border-purple-200 rounded-xl overflow-hidden">
                        <thead class="bg-purple-100 text-gray-900">
                            <tr>
                                <th class="text-left p-3 border border-purple-200">Metric / Property</th>
                                <th class="text-left p-3 border border-purple-200">Sample A / Material A</th>
                                <th class="text-left p-3 border border-purple-200">Sample B / Material B</th>
                                <th class="text-left p-3 border border-purple-200">Sample C / Control</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < 5; i++) { %>
                            <tr>
                                <td class="p-2 border border-purple-100">
                                    <%
                                        String selectedMetric = tableMetricValues != null && i < tableMetricValues.length ? tableMetricValues[i] : "";
                                        boolean hasCustomMetric = selectedMetric != null && !selectedMetric.isEmpty() && !metricOptionList.contains(selectedMetric);
                                    %>
                                    <select name="tableMetric" class="input-field w-full px-3 py-2 rounded-lg">
                                        <% for (String option : metricOptions) { %>
                                        <option value="<%= option %>" <%= option.equals(selectedMetric) ? "selected" : "" %>><%= option.isEmpty() ? "Select metric" : option %></option>
                                        <% } %>
                                        <% if (hasCustomMetric) { %>
                                        <option value="<%= selectedMetric %>" selected><%= selectedMetric %></option>
                                        <% } %>
                                    </select>
                                </td>
                                <td class="p-2 border border-purple-100">
                                    <input type="text" name="tableSampleA" value="<%= tableSampleAValues != null && i < tableSampleAValues.length ? tableSampleAValues[i] : "" %>" class="input-field w-full px-3 py-2 rounded-lg" placeholder="Sample A value">
                                </td>
                                <td class="p-2 border border-purple-100">
                                    <input type="text" name="tableSampleB" value="<%= tableSampleBValues != null && i < tableSampleBValues.length ? tableSampleBValues[i] : "" %>" class="input-field w-full px-3 py-2 rounded-lg" placeholder="Sample B value">
                                </td>
                                <td class="p-2 border border-purple-100">
                                    <input type="text" name="tableSampleC" value="<%= tableSampleCValues != null && i < tableSampleCValues.length ? tableSampleCValues[i] : "" %>" class="input-field w-full px-3 py-2 rounded-lg" placeholder="Sample C value">
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Conclusion and Data Quality Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-teal-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-clipboard-check text-teal-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Conclusion and Data Quality</h2>
                        <p class="text-gray-700 text-sm">Summarize the finding, limits, and next experiment so the record is reusable in the repository</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Conclusion / Key Finding</label>
                        <textarea name="conclusion" rows="5"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                  placeholder="State the best-performing sample and cite the strongest evidence from the data."><%= conclusionValue %></textarea>
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Limitations</label>
                        <textarea name="limitations" rows="5"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                  placeholder="Record missing repeats, noisy spectra, equipment limits, or uncontrolled conditions."><%= limitationsValue %></textarea>
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Next Steps</label>
                        <textarea name="nextSteps" rows="5"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"
                                  placeholder="Suggest the next sample condition, characterization method, or analysis improvement."><%= nextStepsValue %></textarea>
                    </div>
                </div>
            </div>
            
            <!-- Action Buttons -->
            <div class="exp-actions flex flex-col sm:flex-row gap-4 pt-2">
                <a href="${pageContext.request.contextPath}/student/dashboard" 
                   class="btn-secondary px-6 py-3 rounded-xl font-medium text-center">
                    <i class="fas fa-times mr-2"></i>Cancel
                </a>
                <button type="submit" name="action" value="draft"
                        class="btn-draft flex-1 px-6 py-3 rounded-xl text-purple-400 font-medium">
                    <i class="fas fa-save mr-2"></i> Save as Draft
                </button>
                <button type="submit" name="action" value="submit"
                        class="btn-primary flex-1 px-6 py-3 rounded-xl text-gray-900 font-semibold">
                    <i class="fas fa-paper-plane mr-2"></i> Submit for Review
                </button>
            </div>
        </form>
    <script>
        function toggleDropdown(event, dropdownId) {
            event.stopPropagation();
            const dropdown = document.getElementById(dropdownId);
            const isHidden = dropdown.classList.contains('hidden');
            
            // Close all other dropdowns
            document.querySelectorAll('[id*="dropdown"]').forEach(d => {
                if (d.id !== dropdownId) {
                    d.classList.add('hidden');
                }
            });
            
            // Toggle current dropdown
            if (isHidden) {
                dropdown.classList.remove('hidden');
            } else {
                dropdown.classList.add('hidden');
            }
        }
        
        // Close dropdown when clicking outside
        document.addEventListener('click', function() {
            document.querySelectorAll('[id*="dropdown"]').forEach(d => {
                d.classList.add('hidden');
            });
        });
        
        function selectMaterial(material) {
            document.querySelectorAll('.material-card').forEach(card => {
                card.classList.remove('active');
                if (card.querySelector('input').value === material) {
                    card.classList.add('active');
                    card.querySelector('input').checked = true;
                }
            });
            
            // Show/hide custom material input
            const customDiv = document.getElementById('customMaterialDiv');
            const customInput = document.getElementById('customMaterialInput');
            if (material === 'Other') {
                customDiv.classList.remove('hidden');
                customInput.required = true;
            } else {
                customDiv.classList.add('hidden');
                customInput.required = false;
                customInput.value = '';
            }
        }

        function toggleConcentrationUnitOther() {
            const unitSelect = document.getElementById('concentrationUnit');
            const otherInput = document.getElementById('concentrationUnitOther');
            if (!unitSelect || !otherInput) return;

            if (unitSelect.value === 'Other') {
                otherInput.classList.remove('hidden');
                otherInput.required = true;
            } else {
                otherInput.classList.add('hidden');
                otherInput.required = false;
                otherInput.value = '';
            }
        }

        function toggleStudyType() {
            const selected = document.querySelector('input[name="studyType"]:checked');
            const comparisonSection = document.getElementById('comparisonSection');
            const comparisonNavLink = document.querySelector('.exp-quick-nav a[href="#section-comparison"]');
            const isComparison = selected && selected.value === 'COMPARISON';
            if (comparisonSection) comparisonSection.classList.toggle('hidden', !isComparison);
            if (comparisonNavLink) comparisonNavLink.classList.toggle('hidden', !isComparison);

            ['materialBType', 'materialAMetricValue', 'materialBMetricValue'].forEach(id => {
                const field = document.getElementById(id) || document.querySelector('[name="' + id + '"]');
                if (field) field.required = isComparison;
            });
            toggleMaterialBOther();
            toggleMaterialBUnitOther();
        }

        function toggleMaterialBOther() {
            const materialSelect = document.getElementById('materialBType');
            const otherInput = document.getElementById('customMaterialBInput');
            const isComparison = document.querySelector('input[name="studyType"]:checked')?.value === 'COMPARISON';
            if (!materialSelect || !otherInput) return;

            if (isComparison && materialSelect.value === 'Other') {
                otherInput.classList.remove('hidden');
                otherInput.required = true;
            } else {
                otherInput.classList.add('hidden');
                otherInput.required = false;
                if (materialSelect.value !== 'Other') otherInput.value = '';
            }
        }

        function toggleMaterialBUnitOther() {
            const unitSelect = document.getElementById('materialBConcentrationUnit');
            const otherInput = document.getElementById('materialBConcentrationUnitOther');
            if (!unitSelect || !otherInput) return;

            if (unitSelect.value === 'Other') {
                otherInput.classList.remove('hidden');
                otherInput.required = true;
            } else {
                otherInput.classList.add('hidden');
                otherInput.required = false;
                otherInput.value = '';
            }
        }

        function insertPreparationSteps() {
            const field = document.getElementById('preparationNotes');
            if (!field) return;
            if (field.value.trim() && !confirm('Replace the current preparation notes with the numbered format?')) {
                return;
            }
            field.value = [
                '1. Clean substrate:',
                '- ',
                '',
                '2. Prepare precursor / material solution:',
                '- ',
                '',
                '3. Coat or deposit sample:',
                '- ',
                '',
                '4. Heat / grow / anneal:',
                '- ',
                '',
                '5. Wash and dry:',
                '- ',
                '',
                '6. Apply sample variation:',
                '- ',
                '',
                '7. Prepare for characterization:',
                '- '
            ].join('\n');
            field.focus();
        }

        function initExperimentSections() {
            const sectionMap = [
                ['Study Type', 'section-study-type'],
                ['Optical Material', 'section-material'],
                ['Material B', 'section-comparison'],
                ['Study Setup', 'section-setup'],
                ['Optical Study Objective', 'section-objective'],
                ['Sample Comparison Plan', 'section-samples'],
                ['Optical Characterization Plan', 'section-characterization'],
                ['Common Preparation Method', 'section-preparation'],
                ['Characterization Results Table', 'section-results'],
                ['Conclusion and Data Quality', 'section-conclusion']
            ];
            const headings = Array.from(document.querySelectorAll('#experimentForm h2'));
            sectionMap.forEach(([label, id]) => {
                const heading = headings.find(item => item.textContent.trim().includes(label));
                if (!heading) return;
                let section = heading;
                while (section && section.parentElement && section.parentElement.id !== 'experimentForm') {
                    section = section.parentElement;
                }
                if (section && section.parentElement && section.parentElement.id === 'experimentForm') {
                    section.id = id;
                }
            });

            const navLinks = Array.from(document.querySelectorAll('.exp-quick-nav a'));
            const sections = navLinks
                .map(link => document.querySelector(link.getAttribute('href')))
                .filter(Boolean);

            if ('IntersectionObserver' in window && sections.length) {
                const observer = new IntersectionObserver(entries => {
                    entries.forEach(entry => {
                        if (!entry.isIntersecting) return;
                        navLinks.forEach(link => link.classList.toggle('active', link.getAttribute('href') === '#' + entry.target.id));
                    });
                }, { rootMargin: '-35% 0px -55% 0px', threshold: 0.01 });
                sections.forEach(section => observer.observe(section));
            }
        }

        function getCheckedValues(name) {
            return Array.from(document.querySelectorAll('input[name="' + name + '"]:checked')).map(input => input.value);
        }

        function getFieldValue(name) {
            const field = document.querySelector('[name="' + name + '"]');
            return field ? field.value : '';
        }

        function appendRepeatedValues(params, name) {
            document.querySelectorAll('[name="' + name + '"]').forEach(field => {
                params.append(name, field.value || '');
            });
        }

        function buildAiParams() {
            const selectedMaterial = document.querySelector('input[name="materialType"]:checked');
            const selectedStudyType = document.querySelector('input[name="studyType"]:checked');
            const params = new URLSearchParams();
            params.append('title', getFieldValue('title'));
            params.append('date', getFieldValue('date'));
            params.append('studyType', selectedStudyType ? selectedStudyType.value : 'SINGLE');
            params.append('materialType', selectedMaterial ? selectedMaterial.value : '');
            params.append('customMaterial', getFieldValue('customMaterial'));
            params.append('concentrationAmount', getFieldValue('concentrationAmount'));
            params.append('concentrationUnit', getFieldValue('concentrationUnit'));
            params.append('concentrationUnitOther', getFieldValue('concentrationUnitOther'));
            params.append('materialBType', getFieldValue('materialBType'));
            params.append('customMaterialB', getFieldValue('customMaterialB'));
            params.append('materialBConcentrationAmount', getFieldValue('materialBConcentrationAmount'));
            params.append('materialBConcentrationUnit', getFieldValue('materialBConcentrationUnit'));
            params.append('materialBConcentrationUnitOther', getFieldValue('materialBConcentrationUnitOther'));
            params.append('comparisonMetricLabel', getFieldValue('comparisonMetricLabel'));
            params.append('materialAMetricValue', getFieldValue('materialAMetricValue'));
            params.append('materialBMetricValue', getFieldValue('materialBMetricValue'));
            params.append('comparisonNotes', getFieldValue('comparisonNotes'));
            appendRepeatedValues(params, 'tableMetric');
            appendRepeatedValues(params, 'tableSampleA');
            appendRepeatedValues(params, 'tableSampleB');
            appendRepeatedValues(params, 'tableSampleC');
            params.append('studyObjective', getFieldValue('studyObjective'));
            params.append('sampleOneName', getFieldValue('sampleOneName'));
            params.append('sampleOneCondition', getFieldValue('sampleOneCondition'));
            params.append('sampleOneNotes', getFieldValue('sampleOneNotes'));
            params.append('sampleTwoName', getFieldValue('sampleTwoName'));
            params.append('sampleTwoCondition', getFieldValue('sampleTwoCondition'));
            params.append('sampleTwoNotes', getFieldValue('sampleTwoNotes'));
            params.append('sampleThreeName', getFieldValue('sampleThreeName'));
            params.append('sampleThreeCondition', getFieldValue('sampleThreeCondition'));
            params.append('sampleThreeNotes', getFieldValue('sampleThreeNotes'));
            params.append('characterizationOther', getFieldValue('characterizationOther'));
            params.append('characterizationNotes', getFieldValue('characterizationNotes'));
            params.append('preparationNotes', getFieldValue('preparationNotes'));
            getCheckedValues('characterizationMethods').forEach(value => params.append('characterizationMethods', value));
            return params;
        }

        async function generateStudyObjective() {
            const button = document.getElementById('aiObjectiveBtn');
            const status = document.getElementById('aiObjectiveStatus');
            const objectiveField = document.getElementById('studyObjective');
            const params = buildAiParams();

            button.disabled = true;
            button.classList.add('opacity-60', 'cursor-not-allowed');
            status.classList.remove('hidden', 'text-red-500', 'text-green-600');
            status.classList.add('text-gray-700');
            status.textContent = 'Generating objective from your study details...';

            try {
                const response = await fetch('${pageContext.request.contextPath}/ai/study-objective', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                    body: params.toString()
                });
                const data = await response.json();
                if (!response.ok || !data.success) {
                    throw new Error(data.message || 'Unable to generate objective.');
                }
                objectiveField.value = data.message;
                status.classList.remove('text-gray-700', 'text-red-500');
                status.classList.add('text-green-600');
                status.textContent = 'Objective generated. You can edit it before saving.';
            } catch (error) {
                status.classList.remove('text-gray-700', 'text-green-600');
                status.classList.add('text-red-500');
                status.textContent = error.message;
            } finally {
                button.disabled = false;
                button.classList.remove('opacity-60', 'cursor-not-allowed');
            }
        }

        async function generateStudySummary() {
            const button = document.getElementById('aiSummaryBtn');
            const status = document.getElementById('aiSummaryStatus');
            const box = document.getElementById('aiSummaryBox');
            const content = document.getElementById('aiSummaryContent');
            const params = buildAiParams();

            button.disabled = true;
            button.classList.add('opacity-60', 'cursor-not-allowed');
            status.classList.remove('hidden', 'text-red-500', 'text-green-600');
            status.classList.add('text-gray-700');
            status.textContent = 'Summarizing your current draft...';

            try {
                const response = await fetch('${pageContext.request.contextPath}/ai/study-summary', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                    body: params.toString()
                });
                const data = await response.json();
                if (!response.ok || !data.success) {
                    throw new Error(data.message || 'Unable to summarize draft.');
                }
                content.textContent = data.message;
                box.classList.remove('hidden');
                status.classList.remove('text-gray-700', 'text-red-500');
                status.classList.add('text-green-600');
                status.textContent = 'Summary generated from your current form details.';
            } catch (error) {
                status.classList.remove('text-gray-700', 'text-green-600');
                status.classList.add('text-red-500');
                status.textContent = error.message;
            } finally {
                button.disabled = false;
                button.classList.remove('opacity-60', 'cursor-not-allowed');
            }
        }

        function addAiChatBubble(message, role) {
            const messages = document.getElementById('aiChatMessages');
            const bubble = document.createElement('div');
            bubble.className = role === 'user'
                ? 'ml-auto max-w-[85%] rounded-xl bg-purple-600 p-3 text-sm text-white'
                : 'max-w-[85%] rounded-xl bg-white border border-purple-100 p-3 text-sm text-gray-800 whitespace-pre-wrap';
            bubble.textContent = message;
            messages.appendChild(bubble);
            messages.scrollTop = messages.scrollHeight;
        }

        async function sendAiChatMessage() {
            const input = document.getElementById('aiChatInput');
            const button = document.getElementById('aiChatBtn');
            const status = document.getElementById('aiChatStatus');
            const question = input.value.trim();
            if (!question) return;

            const params = buildAiParams();
            params.append('question', question);
            addAiChatBubble(question, 'user');
            input.value = '';

            button.disabled = true;
            button.classList.add('opacity-60', 'cursor-not-allowed');
            status.classList.remove('hidden', 'text-red-500');
            status.classList.add('text-gray-700');
            status.textContent = 'AI is thinking...';

            try {
                const response = await fetch('${pageContext.request.contextPath}/ai/chat', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                    body: params.toString()
                });
                const data = await response.json();
                if (!response.ok || !data.success) {
                    throw new Error(data.message || 'Unable to answer right now.');
                }
                addAiChatBubble(data.message, 'assistant');
                status.classList.add('hidden');
            } catch (error) {
                status.classList.remove('text-gray-700');
                status.classList.add('text-red-500');
                status.textContent = error.message;
            } finally {
                button.disabled = false;
                button.classList.remove('opacity-60', 'cursor-not-allowed');
            }
        }
        
        // Set today's date as default
        window.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('expDate');
            const selectedMaterial = document.querySelector('input[name="materialType"]:checked');
            if (dateInput && !dateInput.value) {
                const today = new Date();
                const year = today.getFullYear();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const day = String(today.getDate()).padStart(2, '0');
                dateInput.value = year + '-' + month + '-' + day;
            }
            console.log("Page loaded, date field set to today");

            if (selectedMaterial) {
                selectMaterial(selectedMaterial.value);
            }
            toggleConcentrationUnitOther();
            toggleStudyType();
            initExperimentSections();

            const aiChatInput = document.getElementById('aiChatInput');
            if (aiChatInput) {
                aiChatInput.addEventListener('keydown', function(event) {
                    if (event.key === 'Enter') {
                        event.preventDefault();
                        sendAiChatMessage();
                    }
                });
            }
            
            // Add form submission listener for debugging
            const form = document.getElementById('experimentForm');
            if (form) {
                form.addEventListener('submit', function(e) {
                    console.log("Form submission detected");
                    console.log("Title:", document.getElementById('expTitle').value);
                    console.log("Date:", document.getElementById('expDate').value);
                    console.log("Material:", document.querySelector('input[name="materialType"]:checked')?.value);
                    console.log("Action:", document.activeElement?.value);
                    
                    const formData = new FormData(this);
                    console.log("FormData entries:");
                    for (let [key, value] of formData.entries()) {
                        if (value instanceof File) {
                            console.log(key + ":", value.name, "(" + value.size + " bytes)");
                        } else {
                            console.log(key + ":", value);
                        }
                    }
                });
            }
        });
    </script>
    </div>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>





