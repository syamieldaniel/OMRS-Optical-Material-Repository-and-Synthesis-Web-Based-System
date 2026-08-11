<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.omrs.model.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Experiment - OMRS</title>
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
            box-shadow: 0 8px 16px rgba(167,139,250,0.3);
        }
        
        .btn-secondary {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            transition: all 0.3s ease;
        }
        .btn-secondary:hover {
            background: rgba(255,255,255,0.1);
        }
        
        .btn-draft {
            background: rgba(139,92,246,0.1);
            border: 1.5px solid rgba(124, 58, 237,0.3);
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
        Experiment exp = (Experiment) request.getAttribute("experiment");
        String materialTypeValue = exp.getMaterialType() != null ? exp.getMaterialType() : "";
        boolean isCustomMaterial =
            !"Silica".equals(materialTypeValue) &&
            !"PMMA".equals(materialTypeValue) &&
            !"Zinc Oxide".equals(materialTypeValue) &&
            !"Titanium Dioxide".equals(materialTypeValue) &&
            !"Graphene".equals(materialTypeValue) &&
            !"Gold Nanoparticle".equals(materialTypeValue) &&
            !"Silver Nanoparticle".equals(materialTypeValue);
        Set<String> knownCharacterizationMethods = new LinkedHashSet<>(Arrays.asList("SEM", "XRD", "UV-Vis", "FTIR", "Two-Point Probe"));
        Set<String> selectedCharacterizationMethods = new LinkedHashSet<>();
        String characterizationOtherValue = "";
        String concentrationValue = exp.getConcentration() != null ? exp.getConcentration() : "";
        String concentrationAmountValue = concentrationValue;
        String concentrationUnitValue = "";
        String concentrationUnitOtherValue = "";
        List<String> concentrationUnits = Arrays.asList("", "M", "mM", "uM", "ppm", "wt%", "vol%", "mg/mL", "g/L", "%", "Other");
        if (concentrationValue.contains(" ")) {
            String possibleUnit = concentrationValue.substring(concentrationValue.lastIndexOf(" ") + 1).trim();
            String possibleAmount = concentrationValue.substring(0, concentrationValue.lastIndexOf(" ")).trim();
            if (concentrationUnits.contains(possibleUnit)) {
                concentrationAmountValue = possibleAmount;
                concentrationUnitValue = possibleUnit;
            }
        }
        String studyTypeValue = "COMPARISON".equals(exp.getStudyType()) ? "COMPARISON" : "SINGLE";
        String materialBTypeValue = exp.getMaterialBType() != null ? exp.getMaterialBType() : "";
        boolean isCustomMaterialB =
            !materialBTypeValue.isEmpty() &&
            !"Silica".equals(materialBTypeValue) &&
            !"PMMA".equals(materialBTypeValue) &&
            !"Zinc Oxide".equals(materialBTypeValue) &&
            !"Titanium Dioxide".equals(materialBTypeValue) &&
            !"Graphene".equals(materialBTypeValue) &&
            !"Gold Nanoparticle".equals(materialBTypeValue) &&
            !"Silver Nanoparticle".equals(materialBTypeValue);
        String materialBConcentrationValue = exp.getMaterialBConcentration() != null ? exp.getMaterialBConcentration() : "";
        String materialBConcentrationAmountValue = materialBConcentrationValue;
        String materialBConcentrationUnitValue = "";
        String materialBConcentrationUnitOtherValue = "";
        if (materialBConcentrationValue.contains(" ")) {
            String possibleUnit = materialBConcentrationValue.substring(materialBConcentrationValue.lastIndexOf(" ") + 1).trim();
            String possibleAmount = materialBConcentrationValue.substring(0, materialBConcentrationValue.lastIndexOf(" ")).trim();
            if (concentrationUnits.contains(possibleUnit)) {
                materialBConcentrationAmountValue = possibleAmount;
                materialBConcentrationUnitValue = possibleUnit;
            }
        }
        String comparisonMetricLabelValue = exp.getComparisonMetricLabel() != null ? exp.getComparisonMetricLabel() : "";
        String materialAMetricValue = exp.getMaterialAMetricValue() != null ? String.valueOf(exp.getMaterialAMetricValue()) : "";
        String materialBMetricValue = exp.getMaterialBMetricValue() != null ? String.valueOf(exp.getMaterialBMetricValue()) : "";
        String comparisonNotesValue = exp.getComparisonNotes() != null ? exp.getComparisonNotes() : "";
        List<String[]> comparisonTableRows = exp.getComparisonTableRows();
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
        if (exp.getCharacterizationMethods() != null && !exp.getCharacterizationMethods().trim().isEmpty()) {
            String[] methodParts = exp.getCharacterizationMethods().split("\\s*,\\s*");
            for (String method : methodParts) {
                if (knownCharacterizationMethods.contains(method)) {
                    selectedCharacterizationMethods.add(method);
                } else if (method != null && !method.trim().isEmpty()) {
                    characterizationOtherValue = characterizationOtherValue.isEmpty() ? method.trim() : characterizationOtherValue + ", " + method.trim();
                }
            }
        }
    %>
    
    <div class="flex min-h-screen">
        
        <!-- Sidebar -->
        <%@ include file="../common/sidebar.jsp" %>
        
        <!-- Main Content -->
        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">

        <!-- Feedback Alert (if rejected) -->
        <% if ("REJECTED".equals(exp.getStatus()) && exp.getFeedback() != null && !exp.getFeedback().isEmpty()) { %>
        <div class="bg-red-500/10 border border-red-500/30 rounded-2xl p-6 mb-6">
            <div class="flex items-start">
                <div class="w-12 h-12 rounded-xl bg-red-500/20 flex items-center justify-center mr-4 flex-shrink-0">
                    <i class="fas fa-exclamation-triangle text-red-400 text-xl"></i>
                </div>
                <div>
                    <h3 class="text-red-400 font-semibold text-lg mb-1">Revision Required</h3>
                    <p class="text-white"><%= exp.getFeedback() %></p>
                </div>
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
        <form action="${pageContext.request.contextPath}/student/update/<%= exp.getExperimentId() %>" method="POST" enctype="multipart/form-data" id="experimentForm" class="glass rounded-2xl p-8">
            <div class="exp-required-strip p-4 mb-6 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-3">
                <div>
                    <p class="text-xs font-semibold uppercase tracking-wide text-purple-700 mb-1">Review the required fields first</p>
                    <p class="text-sm text-gray-700">Material, study title, experiment date, objective, and preparation method should be clear before resubmission.</p>
                </div>
                <span class="inline-flex items-center rounded-full bg-white px-3 py-1 text-sm font-semibold text-purple-700 border border-purple-100">
                    <i class="fas fa-check-circle mr-2"></i>Changes save here
                </span>
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
                
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <label class="material-card <%= "Silica".equals(materialTypeValue) ? "active" : "" %> glass rounded-xl p-4 text-center" onclick="selectMaterial('Silica')">
                        <input type="radio" name="materialType" value="Silica" class="hidden" <%= "Silica".equals(materialTypeValue) ? "checked" : "" %> required>
                        <div class="w-12 h-12 rounded-lg bg-cyan-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-gem text-purple-600 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">Silica</p>
                        <p class="text-gray-700 text-xs">SiO2</p>
                    </label>
                    <label class="material-card <%= "PMMA".equals(materialTypeValue) ? "active" : "" %> glass rounded-xl p-4 text-center" onclick="selectMaterial('PMMA')">
                        <input type="radio" name="materialType" value="PMMA" class="hidden" <%= "PMMA".equals(materialTypeValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-purple-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-cube text-purple-400 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">PMMA</p>
                        <p class="text-gray-700 text-xs">Acrylic</p>
                    </label>
                    <label class="material-card <%= "Zinc Oxide".equals(materialTypeValue) ? "active" : "" %> glass rounded-xl p-4 text-center" onclick="selectMaterial('Zinc Oxide')">
                        <input type="radio" name="materialType" value="Zinc Oxide" class="hidden" <%= "Zinc Oxide".equals(materialTypeValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-yellow-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-sun text-yellow-400 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">Zinc Oxide</p>
                        <p class="text-gray-700 text-xs">ZnO</p>
                    </label>
                    <label class="material-card <%= "Titanium Dioxide".equals(materialTypeValue) ? "active" : "" %> glass rounded-xl p-4 text-center" onclick="selectMaterial('Titanium Dioxide')">
                        <input type="radio" name="materialType" value="Titanium Dioxide" class="hidden" <%= "Titanium Dioxide".equals(materialTypeValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-blue-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-shield-alt text-blue-400 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">TiO2</p>
                        <p class="text-gray-700 text-xs">Titanium</p>
                    </label>
                    <label class="material-card <%= "Graphene".equals(materialTypeValue) ? "active" : "" %> glass rounded-xl p-4 text-center" onclick="selectMaterial('Graphene')">
                        <input type="radio" name="materialType" value="Graphene" class="hidden" <%= "Graphene".equals(materialTypeValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-gray-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-layer-group text-gray-700 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">Graphene</p>
                        <p class="text-gray-700 text-xs">Carbon</p>
                    </label>
                    <label class="material-card <%= "Gold Nanoparticle".equals(materialTypeValue) ? "active" : "" %> glass rounded-xl p-4 text-center" onclick="selectMaterial('Gold Nanoparticle')">
                        <input type="radio" name="materialType" value="Gold Nanoparticle" class="hidden" <%= "Gold Nanoparticle".equals(materialTypeValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-yellow-600/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-coins text-yellow-500 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">AuNP</p>
                        <p class="text-gray-700 text-xs">Gold</p>
                    </label>
                    <label class="material-card <%= "Silver Nanoparticle".equals(materialTypeValue) ? "active" : "" %> glass rounded-xl p-4 text-center" onclick="selectMaterial('Silver Nanoparticle')">
                        <input type="radio" name="materialType" value="Silver Nanoparticle" class="hidden" <%= "Silver Nanoparticle".equals(materialTypeValue) ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-slate-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-circle text-slate-300 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">AgNP</p>
                        <p class="text-gray-700 text-xs">Silver</p>
                    </label>
                    <label class="material-card <%= isCustomMaterial ? "active" : "" %> glass rounded-xl p-4 text-center" onclick="selectMaterial('Other')">
                        <input type="radio" name="materialType" value="Other" class="hidden" <%= isCustomMaterial ? "checked" : "" %>>
                        <div class="w-12 h-12 rounded-lg bg-green-500/10 flex items-center justify-center mx-auto mb-3">
                            <i class="fas fa-plus text-green-400 text-xl"></i>
                        </div>
                        <p class="text-gray-900 text-sm font-medium">Other</p>
                        <p class="text-gray-700 text-xs">Custom</p>
                    </label>
                </div>

                <div id="customMaterialDiv" class="<%= isCustomMaterial ? "" : "hidden" %> mt-4">
                    <label class="block text-gray-700 text-sm font-medium mb-2">
                        Custom Material Name <span class="text-red-400">*</span>
                    </label>
                    <div class="relative">
                        <i class="fas fa-cube absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                        <input type="text" name="customMaterial" id="customMaterialInput" value="<%= isCustomMaterial ? materialTypeValue : "" %>"
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
                        <p class="text-gray-700 text-sm">Update the second material and numeric result used for visualization</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Material B</label>
                        <select name="materialBType" id="materialBType" class="input-field w-full px-4 py-3 rounded-xl" onchange="toggleMaterialBOther()">
                            <option value="" <%= materialBTypeValue.isEmpty() ? "selected" : "" %>>Select second material</option>
                            <option value="Silica" <%= "Silica".equals(materialBTypeValue) ? "selected" : "" %>>Silica</option>
                            <option value="PMMA" <%= "PMMA".equals(materialBTypeValue) ? "selected" : "" %>>PMMA</option>
                            <option value="Zinc Oxide" <%= "Zinc Oxide".equals(materialBTypeValue) ? "selected" : "" %>>Zinc Oxide</option>
                            <option value="Titanium Dioxide" <%= "Titanium Dioxide".equals(materialBTypeValue) ? "selected" : "" %>>Titanium Dioxide</option>
                            <option value="Graphene" <%= "Graphene".equals(materialBTypeValue) ? "selected" : "" %>>Graphene</option>
                            <option value="Gold Nanoparticle" <%= "Gold Nanoparticle".equals(materialBTypeValue) ? "selected" : "" %>>Gold Nanoparticle</option>
                            <option value="Silver Nanoparticle" <%= "Silver Nanoparticle".equals(materialBTypeValue) ? "selected" : "" %>>Silver Nanoparticle</option>
                            <option value="Other" <%= isCustomMaterialB ? "selected" : "" %>>Other</option>
                        </select>
                        <input type="text" name="customMaterialB" id="customMaterialBInput" value="<%= isCustomMaterialB ? materialBTypeValue : "" %>"
                               class="<%= isCustomMaterialB ? "" : "hidden" %> input-field w-full mt-3 px-4 py-3 rounded-xl placeholder-gray-600"
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
                        <p class="text-gray-700 text-sm">Update the study title and experiment date</p>
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
                            <input type="text" name="title" required value="<%= exp.getTitle() %>"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl placeholder-gray-600">
                        </div>
                    </div>
                    
                    <!-- Date -->
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">
                            Experiment Date <span class="text-red-400">*</span>
                        </label>
                        <div class="relative">
                            <i class="fas fa-calendar absolute left-4 top-1/2 -translate-y-1/2 text-gray-700"></i>
                            <input type="date" name="date" required value="<%= exp.getExperimentDate() %>"
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
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-indigo-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-bullseye text-indigo-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Optical Study Objective</h2>
                        <p class="text-gray-700 text-sm">Refine the optical property or behavior being compared</p>
                    </div>
                </div>

                <textarea name="studyObjective" rows="4"
                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getStudyObjective() != null ? exp.getStudyObjective() : "" %></textarea>
            </div>

            <!-- Research Protocol Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-rose-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-flask-vial text-rose-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Research Protocol</h2>
                        <p class="text-gray-700 text-sm">Update the hypothesis, changed variable, measured response, and controls</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div class="lg:col-span-2">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Hypothesis</label>
                        <textarea name="hypothesis" rows="3"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getHypothesis() != null ? exp.getHypothesis() : "" %></textarea>
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Independent Variable</label>
                        <input type="text" name="independentVariable" value="<%= exp.getIndependentVariable() != null ? exp.getIndependentVariable() : "" %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Dependent Variable</label>
                        <input type="text" name="dependentVariable" value="<%= exp.getDependentVariable() != null ? exp.getDependentVariable() : "" %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                    </div>
                    <div class="lg:col-span-2">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Controlled Variables</label>
                        <textarea name="controlledVariables" rows="3"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getControlledVariables() != null ? exp.getControlledVariables() : "" %></textarea>
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
                        <p class="text-gray-700 text-sm">Keep the three related sample variations together in one study record</p>
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
                                <input type="text" name="sampleOneName" value="<%= exp.getSampleOneName() != null ? exp.getSampleOneName() : "" %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Changed Condition</label>
                                <input type="text" name="sampleOneCondition" value="<%= exp.getSampleOneCondition() != null ? exp.getSampleOneCondition() : "" %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Observation / Result Notes</label>
                                <textarea name="sampleOneNotes" rows="5"
                                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getSampleOneNotes() != null ? exp.getSampleOneNotes() : "" %></textarea>
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
                                <input type="text" name="sampleTwoName" value="<%= exp.getSampleTwoName() != null ? exp.getSampleTwoName() : "" %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Changed Condition</label>
                                <input type="text" name="sampleTwoCondition" value="<%= exp.getSampleTwoCondition() != null ? exp.getSampleTwoCondition() : "" %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Observation / Result Notes</label>
                                <textarea name="sampleTwoNotes" rows="5"
                                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getSampleTwoNotes() != null ? exp.getSampleTwoNotes() : "" %></textarea>
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
                                <input type="text" name="sampleThreeName" value="<%= exp.getSampleThreeName() != null ? exp.getSampleThreeName() : "" %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Changed Condition</label>
                                <input type="text" name="sampleThreeCondition" value="<%= exp.getSampleThreeCondition() != null ? exp.getSampleThreeCondition() : "" %>"
                                       class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                            </div>
                            <div>
                                <label class="block text-gray-700 text-sm font-medium mb-2">Observation / Result Notes</label>
                                <textarea name="sampleThreeNotes" rows="5"
                                          class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getSampleThreeNotes() != null ? exp.getSampleThreeNotes() : "" %></textarea>
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
                        <p class="text-gray-700 text-sm">Update the techniques and comparison plan for the three samples</p>
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
                            <input type="checkbox" name="characterizationMethods" value="SEM" class="accent-purple-600" <%= selectedCharacterizationMethods.contains("SEM") ? "checked" : "" %>>
                            <span><i class="fas fa-microscope text-purple-500 mr-2"></i>SEM</span>
                        </label>
                        <input type="file" name="semFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-purple-100 file:text-purple-700">
                    </div>
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="XRD" class="accent-purple-600" <%= selectedCharacterizationMethods.contains("XRD") ? "checked" : "" %>>
                            <span><i class="fas fa-chart-line text-indigo-500 mr-2"></i>XRD</span>
                        </label>
                        <input type="file" name="xrdFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-indigo-100 file:text-indigo-700">
                    </div>
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="UV-Vis" class="accent-purple-600" <%= selectedCharacterizationMethods.contains("UV-Vis") ? "checked" : "" %>>
                            <span><i class="fas fa-wave-square text-blue-500 mr-2"></i>UV-Vis</span>
                        </label>
                        <input type="file" name="uvvisFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-blue-100 file:text-blue-700">
                    </div>
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="FTIR" class="accent-purple-600" <%= selectedCharacterizationMethods.contains("FTIR") ? "checked" : "" %>>
                            <span><i class="fas fa-file-waveform text-yellow-600 mr-2"></i>FTIR</span>
                        </label>
                        <input type="file" name="ftirFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-yellow-100 file:text-yellow-700">
                    </div>
                    <div class="char-method-card">
                        <label class="flex items-center gap-3 font-semibold mb-3">
                            <input type="checkbox" name="characterizationMethods" value="Two-Point Probe" class="accent-purple-600" <%= selectedCharacterizationMethods.contains("Two-Point Probe") ? "checked" : "" %>>
                            <span><i class="fas fa-bolt text-emerald-500 mr-2"></i>Two-Point Probe</span>
                        </label>
                        <input type="file" name="probeFile" accept=".pdf,.csv,.xlsx,.xls,.jpg,.jpeg,.png,.gif,.svg,.txt,.dat"
                               class="input-field w-full px-3 py-2 rounded-lg text-gray-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:bg-emerald-100 file:text-emerald-700">
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
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getCharacterizationNotes() != null ? exp.getCharacterizationNotes() : "" %></textarea>
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
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getInstrumentDetails() != null ? exp.getInstrumentDetails() : "" %></textarea>
                    </div>
                    <div class="char-settings-card">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Scan Range / Conditions</label>
                        <input type="text" name="scanRange" value="<%= exp.getScanRange() != null ? exp.getScanRange() : "" %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 mb-4">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Calibration / Reference</label>
                        <textarea name="calibrationReference" rows="3"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getCalibrationReference() != null ? exp.getCalibrationReference() : "" %></textarea>
                    </div>
                    <div class="char-settings-card">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Replicates</label>
                        <input type="number" name="replicateCount" min="1" value="<%= exp.getReplicateCount() != null ? exp.getReplicateCount() : "" %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 mb-4">
                        <label class="block text-gray-700 text-sm font-medium mb-2">Measurement Uncertainty</label>
                        <input type="text" name="measurementUncertainty" value="<%= exp.getMeasurementUncertainty() != null ? exp.getMeasurementUncertainty() : "" %>"
                               class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600">
                        <label class="char-raw-toggle mt-4 rounded-xl px-4 py-3 text-gray-900 flex items-center gap-3">
                            <input type="checkbox" name="rawDataRequired" value="true" class="accent-purple-600" <%= Boolean.TRUE.equals(exp.getRawDataRequired()) ? "checked" : "" %>>
                            <span>Raw characterization data is required for review</span>
                        </label>
                    </div>
                </div>
            </div>

            <!-- Preparation Notes Section -->
            <div class="mb-8">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 mb-6">
                    <div class="flex items-center">
                        <div class="w-10 h-10 rounded-xl bg-green-500/10 flex items-center justify-center mr-4">
                            <i class="fas fa-clipboard-list text-green-400"></i>
                        </div>
                        <div>
                            <h2 class="text-xl font-semibold text-gray-900">Common Preparation Method</h2>
                            <p class="text-gray-700 text-sm">Update this as numbered steps so it is easier to follow during review</p>
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
7. Prepare for characterization:"><%= exp.getPreparationNotes() != null ? exp.getPreparationNotes() : "" %></textarea>
            </div>

            <!-- Comparison Results Table Section -->
            <div class="glass rounded-2xl p-8 mb-6">
                <div class="flex items-center mb-6">
                    <div class="w-10 h-10 rounded-xl bg-emerald-500/10 flex items-center justify-center mr-4">
                        <i class="fas fa-table text-emerald-500"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-semibold text-gray-900">Characterization Results Table</h2>
                        <p class="text-gray-700 text-sm">Update measured values after characterization for side-by-side sample comparison</p>
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
                            <% for (int i = 0; i < 5; i++) {
                                String[] row = i < comparisonTableRows.size() ? comparisonTableRows.get(i) : new String[] {"", "", "", ""};
                                String selectedMetric = row[0] != null ? row[0] : "";
                                boolean hasCustomMetric = !selectedMetric.isEmpty() && !metricOptionList.contains(selectedMetric);
                            %>
                            <tr>
                                <td class="p-2 border border-purple-100">
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
                                    <input type="text" name="tableSampleA" value="<%= row[1] %>" class="input-field w-full px-3 py-2 rounded-lg" placeholder="Sample A value">
                                </td>
                                <td class="p-2 border border-purple-100">
                                    <input type="text" name="tableSampleB" value="<%= row[2] %>" class="input-field w-full px-3 py-2 rounded-lg" placeholder="Sample B value">
                                </td>
                                <td class="p-2 border border-purple-100">
                                    <input type="text" name="tableSampleC" value="<%= row[3] %>" class="input-field w-full px-3 py-2 rounded-lg" placeholder="Sample C value">
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
                        <p class="text-gray-700 text-sm">Update the key finding, limitations, and next experiment recommendation</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Conclusion / Key Finding</label>
                        <textarea name="conclusion" rows="5"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getConclusion() != null ? exp.getConclusion() : "" %></textarea>
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Limitations</label>
                        <textarea name="limitations" rows="5"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getLimitations() != null ? exp.getLimitations() : "" %></textarea>
                    </div>
                    <div>
                        <label class="block text-gray-700 text-sm font-medium mb-2">Next Steps</label>
                        <textarea name="nextSteps" rows="5"
                                  class="input-field w-full px-4 py-3 rounded-xl placeholder-gray-600 resize-none"><%= exp.getNextSteps() != null ? exp.getNextSteps() : "" %></textarea>
                    </div>
                </div>
            </div>
            
            <!-- Action Buttons -->
            <% boolean isPendingEdit = "PENDING".equals(exp.getStatus()); %>
            <div class="exp-actions flex flex-col sm:flex-row gap-4 pt-2">
                <a href="${pageContext.request.contextPath}/student/view/<%= exp.getExperimentId() %>" 
                   class="btn-secondary px-6 py-3 rounded-xl text-white font-medium text-center">
                    <i class="fas fa-times mr-2"></i>Cancel
                </a>
                <button type="submit" name="action" value="<%= isPendingEdit ? "save" : "draft" %>"
                        class="btn-draft px-6 py-3 rounded-xl text-purple-400 font-medium">
                    <i class="fas fa-save mr-2"></i><%= isPendingEdit ? "Save Updates" : "Save as Draft" %>
                </button>
                <button type="submit" name="action" value="submit"
                        class="btn-primary px-6 py-3 rounded-xl text-gray-900 font-semibold">
                    <i class="fas fa-paper-plane mr-2"></i><%= isPendingEdit ? "Submit Updated Version" : "Submit for Review" %>
                </button>
            </div>
        </form>
    <script>
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
        
        function selectMaterial(material) {
            document.querySelectorAll('.material-card').forEach(card => {
                card.classList.remove('active');
                if (card.querySelector('input').value === material) {
                    card.classList.add('active');
                    card.querySelector('input').checked = true;
                }
            });

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

        document.addEventListener('DOMContentLoaded', function() {
            const selectedMaterial = document.querySelector('input[name="materialType"]:checked');
            if (selectedMaterial) {
                selectMaterial(selectedMaterial.value);
            }
            toggleConcentrationUnitOther();
            toggleStudyType();
            initExperimentSections();
        });
    </script>
    </div>

<%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>





