<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.omrs.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Optical Constants Explorer - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; box-sizing: border-box; }
        body { background: #f5f1ed; color: #111827; font-size: 15px; line-height: 1.6; }
        .surface { background: rgba(255,255,255,0.92); border: 1px solid rgba(148, 163, 184, 0.22); box-shadow: 0 14px 34px rgba(15, 23, 42, 0.07); }
        .hero { background: linear-gradient(135deg, #ffffff 0%, #f8fafc 48%, #ecfeff 100%); border: 1px solid rgba(14, 165, 233, 0.16); }
        .material-card { border: 1px solid #e5e7eb; background: #fff; transition: border-color .2s ease, box-shadow .2s ease, transform .2s ease; }
        .material-card:hover { border-color: rgba(14, 165, 233, .36); transform: translateY(-1px); box-shadow: 0 12px 24px rgba(15, 23, 42, .07); }
        .material-card.active { border-color: rgba(124, 58, 237, .45); box-shadow: 0 14px 28px rgba(124, 58, 237, .13); }
        .input-control { border: 1px solid #d8b4fe; background: #fff; color: #111827; transition: border-color .2s ease, box-shadow .2s ease; }
        .input-control:focus { border-color: #7c3aed; box-shadow: 0 0 0 3px rgba(124,58,237,.13); outline: none; }
        .metric-card { background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%); border: 1px solid #e5e7eb; }
        .metric-icon { width: 2.5rem; height: 2.5rem; display: inline-flex; align-items: center; justify-content: center; border-radius: .75rem; background: #ecfeff; color: #0e7490; }
        .pill { border: 1px solid #e9d5ff; background: #faf5ff; color: #6d28d9; }
        .accent-pill { border: 1px solid #bae6fd; background: #f0f9ff; color: #0369a1; }
        .range-input { accent-color: #7c3aed; }
        .chart-shell { min-height: 340px; }
        .formula-box { background: #0f172a; color: #e2e8f0; border: 1px solid rgba(148, 163, 184, .28); }
        .result-bar { height: .625rem; border-radius: 999px; background: #e5e7eb; overflow: hidden; }
        .result-bar span { display: block; height: 100%; background: linear-gradient(90deg, #14b8a6, #7c3aed); }
        @media (max-width: 640px) {
            .hero, .surface { border-radius: 1rem !important; }
            .metric-value { font-size: 1.75rem !important; }
        }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        String studentType = (String) session.getAttribute("studentType");
        boolean isFypStudent = "FYP".equals(studentType);
        List<OpticalMaterial> materials = (List<OpticalMaterial>) request.getAttribute("materials");
        OpticalMaterial selectedMaterial = (OpticalMaterial) request.getAttribute("selectedMaterial");
        OpticalCalculationResult result = (OpticalCalculationResult) request.getAttribute("result");
        String error = (String) request.getAttribute("error");
        String chartWavelengths = (String) request.getAttribute("chartWavelengths");
        String chartValues = (String) request.getAttribute("chartValues");
        String chartMetric = (String) request.getAttribute("chartMetric");
        String chartLabel = (String) request.getAttribute("chartLabel");
        String wavelengthValue = request.getParameter("wavelength") != null ? request.getParameter("wavelength") : "0.55";
        String thicknessValue = request.getParameter("thickness") != null ? request.getParameter("thickness") : "1";
        String thicknessUnit = request.getParameter("thicknessUnit") != null ? request.getParameter("thicknessUnit") : "mm";
        String safeWavelengthValue = wavelengthValue.matches("[0-9]+(\\.[0-9]+)?") ? wavelengthValue : "0.55";
        String safeThicknessValue = thicknessValue.matches("[0-9]+(\\.[0-9]+)?") ? thicknessValue : "1";
        String safeThicknessUnit = java.util.Arrays.asList("nm", "um", "mm", "cm", "m", "km").contains(thicknessUnit) ? thicknessUnit : "mm";
        String activeMetric = java.util.Arrays.asList("n", "reflectance", "transmission").contains(chartMetric) ? chartMetric : "n";
        int materialCount = materials != null ? materials.size() : 0;
        int categoryCount = 0;
        if (materials != null) {
            java.util.Set<String> categories = new java.util.HashSet<>();
            for (OpticalMaterial m : materials) categories.add(m.getCategory());
            categoryCount = categories.size();
        }
        double rangeMin = selectedMaterial != null ? selectedMaterial.getWavelengthMinUm() : 0.2;
        double rangeMax = selectedMaterial != null ? selectedMaterial.getWavelengthMaxUm() : 2.0;
    %>
    <div class="flex min-h-screen">
        <%@ include file="../common/sidebar.jsp" %>

        <main class="flex-1 lg:ml-64 p-4 sm:p-6 lg:p-10 pt-20 lg:pt-10">
            <section class="hero rounded-2xl p-6 lg:p-8 mb-6">
                <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-6">
                    <div class="max-w-4xl">
                        <div class="inline-flex items-center gap-2 rounded-full bg-white border border-cyan-100 px-3 py-1 text-sm font-semibold text-cyan-700 mb-4">
                            <i class="fas fa-wave-square"></i>
                            Optical Constants
                        </div>
                        <h1 class="text-3xl lg:text-4xl font-extrabold text-gray-950 leading-tight mb-3">Optical Constants Explorer</h1>
                        <p class="text-gray-700 max-w-3xl">Calculate refractive index, dielectric constants, reflectance, and transmission for common optical and nanophysics materials.</p>
                    </div>
                    <div class="grid grid-cols-2 sm:grid-cols-3 gap-3 min-w-full xl:min-w-[420px]">
                        <div class="surface rounded-xl p-4">
                            <p class="text-xs text-gray-500 font-semibold uppercase">Materials</p>
                            <p class="text-2xl font-bold text-gray-950"><%= materialCount %></p>
                        </div>
                        <div class="surface rounded-xl p-4">
                            <p class="text-xs text-gray-500 font-semibold uppercase">Categories</p>
                            <p class="text-2xl font-bold text-gray-950"><%= categoryCount %></p>
                        </div>
                        <a href="${pageContext.request.contextPath}/repository" class="surface rounded-xl p-4 text-purple-700 font-bold flex items-center justify-center gap-2 col-span-2 sm:col-span-1">
                            <i class="fas fa-database"></i>
                            Repository
                        </a>
                    </div>
                </div>
            </section>

            <% if ("STUDENT".equals(user.getRole())) { %>
            <section class="surface rounded-2xl p-5 mb-6">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                    <div>
                        <h2 class="text-lg font-bold text-gray-950">Analysis workspace</h2>
                        <p class="text-sm text-gray-600 mt-1"><%= isFypStudent
                            ? "Use calculated constants in experiment analysis and weekly logbook notes."
                            : "Use calculated constants in experiment analysis notes." %></p>
                    </div>
                    <div class="flex flex-wrap gap-3">
                        <a href="${pageContext.request.contextPath}/student/create" class="rounded-xl bg-purple-600 px-5 py-3 text-white font-semibold inline-flex items-center gap-2">
                            <i class="fas fa-plus"></i>New Experiment
                        </a>
                        <% if (isFypStudent) { %>
                        <a href="${pageContext.request.contextPath}/logbook/dashboard" class="rounded-xl border border-purple-100 bg-purple-50 px-5 py-3 text-purple-700 font-semibold inline-flex items-center gap-2">
                            <i class="fas fa-book-open"></i>Logbook
                        </a>
                        <% } %>
                    </div>
                </div>
            </section>
            <% } %>

            <% if (error != null) { %>
            <div class="mb-6 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-red-700">
                <i class="fas fa-circle-exclamation mr-2"></i><%= error %>
            </div>
            <% } %>

            <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                <aside class="xl:col-span-4">
                    <div class="surface rounded-2xl p-5 xl:sticky xl:top-6">
                        <div class="flex items-center justify-between gap-4 mb-4">
                            <div>
                                <h2 class="text-xl font-bold text-gray-950">Material Catalog</h2>
                                <p class="text-sm text-gray-600"><%= materialCount %> optical datasets</p>
                            </div>
                            <span class="w-11 h-11 rounded-xl bg-cyan-50 text-cyan-700 flex items-center justify-center">
                                <i class="fas fa-layer-group"></i>
                            </span>
                        </div>
                        <div class="relative mb-4">
                            <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-500"></i>
                            <input id="materialSearch" type="text" placeholder="Search material or formula"
                                   class="input-control w-full rounded-xl pl-11 pr-4 py-3">
                        </div>
                        <div class="flex gap-2 overflow-x-auto pb-2 mb-3" id="categoryFilters">
                            <button type="button" class="category-filter pill rounded-full px-3 py-2 text-sm font-bold whitespace-nowrap" data-category="all">All</button>
                            <% if (materials != null) {
                                java.util.LinkedHashSet<String> categories = new java.util.LinkedHashSet<>();
                                for (OpticalMaterial material : materials) categories.add(material.getCategory());
                                for (String category : categories) { %>
                                <button type="button" class="category-filter rounded-full border border-gray-200 bg-white px-3 py-2 text-sm font-bold text-gray-600 whitespace-nowrap" data-category="<%= category.toLowerCase() %>"><%= category %></button>
                            <% }} %>
                        </div>
                        <div id="materialList" class="space-y-3 max-h-[680px] overflow-auto pr-1">
                            <% if (materials != null) for (OpticalMaterial material : materials) {
                                boolean active = selectedMaterial != null && material.getId().equals(selectedMaterial.getId());
                                String searchText = (material.getName() + " " + material.getChemicalFormula() + " " + material.getCategory()).toLowerCase();
                            %>
                            <a href="${pageContext.request.contextPath}/optical-constants?material=<%= material.getId() %>"
                               data-search="<%= searchText %>"
                               data-category="<%= material.getCategory().toLowerCase() %>"
                               class="material-card block rounded-xl p-4 <%= active ? "active" : "" %>">
                                <div class="flex items-start justify-between gap-3">
                                    <div>
                                        <p class="text-gray-950 font-bold"><%= material.getName() %></p>
                                        <p class="text-sm text-gray-600"><%= material.getChemicalFormula() %></p>
                                    </div>
                                    <span class="rounded-full bg-gray-100 px-3 py-1 text-xs font-bold text-gray-700"><%= material.getCategory() %></span>
                                </div>
                                <div class="mt-3 flex items-center justify-between text-sm text-gray-600">
                                    <span><i class="fas fa-arrows-left-right mr-2 text-cyan-600"></i><%= material.getWavelengthMinUm() %>-<%= material.getWavelengthMaxUm() %> um</span>
                                    <i class="fas fa-chevron-right text-gray-400"></i>
                                </div>
                            </a>
                            <% } %>
                        </div>
                    </div>
                </aside>

                <section class="xl:col-span-8 space-y-6">
                    <% if (selectedMaterial == null) { %>
                    <div class="surface rounded-2xl p-8 lg:p-10 text-center">
                        <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-cyan-50 flex items-center justify-center">
                            <i class="fas fa-wave-square text-2xl text-cyan-700"></i>
                        </div>
                        <h2 class="text-2xl font-bold text-gray-950 mb-2">Select a Material</h2>
                        <p class="text-gray-600 max-w-2xl mx-auto">The calculator opens as soon as a material is selected.</p>
                    </div>
                    <% } else { %>
                    <div class="surface rounded-2xl p-6 lg:p-8">
                        <div class="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-5">
                            <div>
                                <div class="flex flex-wrap items-center gap-2 mb-3">
                                    <span class="pill rounded-full px-3 py-1 text-sm font-bold"><%= selectedMaterial.getCategory() %></span>
                                    <span class="accent-pill rounded-full px-3 py-1 text-sm font-bold"><%= selectedMaterial.getWavelengthMinUm() %>-<%= selectedMaterial.getWavelengthMaxUm() %> um</span>
                                </div>
                                <h2 class="text-3xl font-extrabold text-gray-950"><%= selectedMaterial.getName() %></h2>
                                <p class="text-gray-600 mt-1"><%= selectedMaterial.getChemicalFormula() %></p>
                                <p class="text-gray-700 mt-4 max-w-3xl"><%= selectedMaterial.getComments() %></p>
                            </div>
                            <div class="flex flex-wrap gap-2">
                                <a href="<%= selectedMaterial.getReferenceUrl() %>" target="_blank" rel="noopener noreferrer" class="rounded-xl border border-gray-200 bg-white px-4 py-3 text-gray-700 font-bold inline-flex items-center gap-2">
                                    <i class="fas fa-book"></i>Reference
                                </a>
                                <a href="<%= selectedMaterial.getSourceUrl() %>" target="_blank" rel="noopener noreferrer" class="rounded-xl bg-gray-950 px-4 py-3 text-white font-bold inline-flex items-center gap-2">
                                    <i class="fas fa-up-right-from-square"></i>Source
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="surface rounded-2xl p-6 lg:p-8">
                        <div class="flex items-center justify-between gap-3 mb-5">
                            <div>
                                <h3 class="text-xl font-bold text-gray-950">Calculator</h3>
                                <p class="text-sm text-gray-600">Wavelength uses micrometers.</p>
                            </div>
                            <span class="metric-icon"><i class="fas fa-calculator"></i></span>
                        </div>
                        <form id="calculatorForm" action="${pageContext.request.contextPath}/optical-constants" method="GET" class="space-y-5">
                            <input type="hidden" name="material" value="<%= selectedMaterial.getId() %>">
                            <input type="hidden" name="metric" id="metricInput" value="<%= activeMetric %>">

                            <div>
                                <div class="flex items-center justify-between gap-3 mb-2">
                                    <label class="text-sm font-bold text-gray-700">Wavelength</label>
                                    <span class="text-sm font-semibold text-purple-700"><span id="wavelengthReadout"><%= safeWavelengthValue %></span> um</span>
                                </div>
                                <input id="wavelengthSlider" type="range" min="<%= rangeMin %>" max="<%= rangeMax %>" step="0.0001" value="<%= safeWavelengthValue %>" class="range-input w-full mb-3">
                                <div class="grid grid-cols-1 sm:grid-cols-[1fr_auto] gap-3">
                                    <input id="wavelengthInput" type="number" step="0.0001" min="<%= rangeMin %>" max="<%= rangeMax %>" name="wavelength" value="<%= safeWavelengthValue %>" class="input-control w-full rounded-xl px-4 py-3">
                                    <div class="flex gap-2">
                                        <button type="button" class="preset rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm font-bold text-gray-700" data-value="0.365">365 nm</button>
                                        <button type="button" class="preset rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm font-bold text-gray-700" data-value="0.55">550 nm</button>
                                        <button type="button" class="preset rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm font-bold text-gray-700" data-value="1.55">1550 nm</button>
                                    </div>
                                </div>
                                <p class="text-xs text-gray-500 mt-2">Valid range: <%= rangeMin %> to <%= rangeMax %> um.</p>
                            </div>

                            <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-2">Thickness</label>
                                    <input type="number" step="0.0001" min="0" name="thickness" value="<%= safeThicknessValue %>" class="input-control w-full rounded-xl px-4 py-3">
                                </div>
                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-2">Unit</label>
                                    <select name="thicknessUnit" class="input-control w-full rounded-xl px-4 py-3">
                                        <option value="nm" <%= "nm".equals(safeThicknessUnit) ? "selected" : "" %>>nm</option>
                                        <option value="um" <%= "um".equals(safeThicknessUnit) ? "selected" : "" %>>um</option>
                                        <option value="mm" <%= "mm".equals(safeThicknessUnit) ? "selected" : "" %>>mm</option>
                                        <option value="cm" <%= "cm".equals(safeThicknessUnit) ? "selected" : "" %>>cm</option>
                                        <option value="m" <%= "m".equals(safeThicknessUnit) ? "selected" : "" %>>m</option>
                                        <option value="km" <%= "km".equals(safeThicknessUnit) ? "selected" : "" %>>km</option>
                                    </select>
                                </div>
                                <div class="flex items-end">
                                    <button type="submit" class="w-full rounded-xl bg-purple-600 px-5 py-3 font-bold text-white hover:bg-purple-700 transition">
                                        <i class="fas fa-rotate mr-2"></i>Calculate
                                    </button>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 sm:grid-cols-3 gap-2">
                                <button type="button" class="metric-tab rounded-xl px-4 py-3 font-bold border <%= "n".equals(activeMetric) ? "bg-purple-600 text-white border-purple-600" : "bg-white text-gray-700 border-gray-200" %>" data-metric="n">Refractive Index</button>
                                <button type="button" class="metric-tab rounded-xl px-4 py-3 font-bold border <%= "reflectance".equals(activeMetric) ? "bg-purple-600 text-white border-purple-600" : "bg-white text-gray-700 border-gray-200" %>" data-metric="reflectance">Reflectance</button>
                                <button type="button" class="metric-tab rounded-xl px-4 py-3 font-bold border <%= "transmission".equals(activeMetric) ? "bg-purple-600 text-white border-purple-600" : "bg-white text-gray-700 border-gray-200" %>" data-metric="transmission">Transmission</button>
                            </div>
                        </form>
                    </div>

                    <% if (result != null) { %>
                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                        <div class="metric-card rounded-2xl p-5">
                            <div class="flex items-center justify-between mb-4"><span class="metric-icon"><i class="fas fa-wave-square"></i></span><span class="text-xs font-bold text-gray-500">n</span></div>
                            <p class="text-sm text-gray-600">Refractive Index</p>
                            <p class="metric-value text-3xl font-extrabold text-gray-950"><%= String.format(java.util.Locale.US, "%.6f", result.getRefractiveIndex()) %></p>
                        </div>
                        <div class="metric-card rounded-2xl p-5">
                            <div class="flex items-center justify-between mb-4"><span class="metric-icon"><i class="fas fa-eye-low-vision"></i></span><span class="text-xs font-bold text-gray-500">k</span></div>
                            <p class="text-sm text-gray-600">Extinction Coefficient</p>
                            <p class="metric-value text-3xl font-extrabold text-gray-950"><%= String.format(java.util.Locale.US, "%.6f", result.getExtinctionCoefficient()) %></p>
                        </div>
                        <div class="metric-card rounded-2xl p-5">
                            <div class="flex items-center justify-between mb-4"><span class="metric-icon"><i class="fas fa-arrow-up-right-dots"></i></span><span class="text-xs font-bold text-gray-500">R</span></div>
                            <p class="text-sm text-gray-600">Reflectance</p>
                            <p class="metric-value text-3xl font-extrabold text-gray-950"><%= String.format(java.util.Locale.US, "%.3f", result.getReflectance() * 100.0) %>%</p>
                            <div class="result-bar mt-3"><span style="width:<%= Math.min(100.0, result.getReflectance() * 100.0) %>%"></span></div>
                        </div>
                        <div class="metric-card rounded-2xl p-5">
                            <p class="text-sm text-gray-600">Dielectric Constant e1</p>
                            <p class="metric-value text-3xl font-extrabold text-gray-950"><%= String.format(java.util.Locale.US, "%.6f", result.getEpsilon1()) %></p>
                            <p class="text-xs text-gray-500 mt-2">Real component</p>
                        </div>
                        <div class="metric-card rounded-2xl p-5">
                            <p class="text-sm text-gray-600">Dielectric Constant e2</p>
                            <p class="metric-value text-3xl font-extrabold text-gray-950"><%= String.format(java.util.Locale.US, "%.6f", result.getEpsilon2()) %></p>
                            <p class="text-xs text-gray-500 mt-2">Imaginary component</p>
                        </div>
                        <div class="metric-card rounded-2xl p-5">
                            <p class="text-sm text-gray-600">Absorption Coefficient</p>
                            <p class="metric-value text-3xl font-extrabold text-gray-950"><%= String.format(java.util.Locale.US, "%.3f", result.getAbsorptionCoefficientCm()) %></p>
                            <p class="text-xs text-gray-500 mt-2">cm^-1</p>
                        </div>
                    </div>
                    <% } %>

                    <div class="surface rounded-2xl p-6 lg:p-8">
                        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-5">
                            <div>
                                <h3 class="text-xl font-bold text-gray-950"><%= chartLabel != null ? chartLabel : "Refractive Index n" %> Curve</h3>
                                <p class="text-sm text-gray-600"><%= selectedMaterial.getName() %>, <%= selectedMaterial.getWavelengthMinUm() %>-<%= selectedMaterial.getWavelengthMaxUm() %> um</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/optical-constants?material=<%= selectedMaterial.getId() %>&metric=<%= activeMetric %>&wavelength=<%= safeWavelengthValue %>&thickness=<%= safeThicknessValue %>&thicknessUnit=<%= safeThicknessUnit %>&export=csv"
                               class="rounded-xl border border-purple-200 bg-purple-50 px-4 py-3 text-sm font-bold text-purple-700 inline-flex items-center gap-2">
                                <i class="fas fa-file-csv"></i>Export CSV
                            </a>
                        </div>
                        <div class="chart-shell rounded-2xl border border-gray-200 bg-white p-3">
                            <canvas id="refractiveIndexChart" class="w-full h-[320px]"></canvas>
                        </div>
                    </div>

                    <% if (result != null) { %>
                    <div class="surface rounded-2xl p-6 lg:p-8">
                        <div class="flex items-center justify-between gap-3 mb-4">
                            <h3 class="text-xl font-bold text-gray-950">Transmission Estimate</h3>
                            <span class="metric-icon"><i class="fas fa-lightbulb"></i></span>
                        </div>
                        <% if (result.getInternalTransmission() != null) { %>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div class="rounded-2xl border border-gray-200 bg-white p-5">
                                <p class="text-sm text-gray-600 mb-2">Internal Transmission</p>
                                <p class="text-3xl font-extrabold text-gray-950"><%= String.format(java.util.Locale.US, "%.3f", result.getInternalTransmission() * 100.0) %>%</p>
                                <div class="result-bar mt-3"><span style="width:<%= Math.min(100.0, result.getInternalTransmission() * 100.0) %>%"></span></div>
                            </div>
                            <div class="rounded-2xl border border-gray-200 bg-white p-5">
                                <p class="text-sm text-gray-600 mb-2">Single-pass with Fresnel Losses</p>
                                <p class="text-3xl font-extrabold text-gray-950"><%= String.format(java.util.Locale.US, "%.3f", result.getSinglePassTransmission() * 100.0) %>%</p>
                                <div class="result-bar mt-3"><span style="width:<%= Math.min(100.0, result.getSinglePassTransmission() * 100.0) %>%"></span></div>
                            </div>
                        </div>
                        <% } else { %>
                        <p class="text-gray-700">Enter thickness to estimate transmission.</p>
                        <% } %>
                    </div>
                    <% } %>

                    <details class="surface rounded-2xl p-6 lg:p-8">
                        <summary class="cursor-pointer text-xl font-bold text-gray-950 flex items-center justify-between">
                            Formula and Reference
                            <i class="fas fa-chevron-down text-gray-400"></i>
                        </summary>
                        <div class="mt-5 space-y-4">
                            <div class="formula-box rounded-2xl p-5 overflow-auto">
                                <pre class="whitespace-pre-wrap text-sm"><%= selectedMaterial.getFormulaDisplay() %></pre>
                            </div>
                            <p class="text-sm text-gray-700"><span class="font-bold">Reference:</span> <%= selectedMaterial.getReferenceTitle() %></p>
                        </div>
                    </details>
                    <% } %>
                </section>
            </div>
        </main>
    </div>

    <script>
        const searchInput = document.getElementById('materialSearch');
        const materialCards = Array.from(document.querySelectorAll('#materialList [data-search]'));
        const categoryButtons = Array.from(document.querySelectorAll('.category-filter'));
        let activeCategory = 'all';

        function filterMaterials() {
            const query = searchInput ? searchInput.value.trim().toLowerCase() : '';
            materialCards.forEach(card => {
                const categoryMatch = activeCategory === 'all' || card.dataset.category === activeCategory;
                const queryMatch = !query || card.dataset.search.includes(query);
                card.style.display = categoryMatch && queryMatch ? '' : 'none';
            });
        }

        if (searchInput) searchInput.addEventListener('input', filterMaterials);
        categoryButtons.forEach(button => {
            button.addEventListener('click', () => {
                activeCategory = button.dataset.category;
                categoryButtons.forEach(item => {
                    item.className = 'category-filter rounded-full border px-3 py-2 text-sm font-bold whitespace-nowrap ' +
                        (item === button ? 'border-purple-200 bg-purple-50 text-purple-700' : 'border-gray-200 bg-white text-gray-600');
                });
                filterMaterials();
            });
        });

        const wavelengthInput = document.getElementById('wavelengthInput');
        const wavelengthSlider = document.getElementById('wavelengthSlider');
        const wavelengthReadout = document.getElementById('wavelengthReadout');
        function syncWavelength(value, source) {
            if (!value) return;
            const min = wavelengthSlider ? Number(wavelengthSlider.min) : Number.MIN_VALUE;
            const max = wavelengthSlider ? Number(wavelengthSlider.max) : Number.MAX_VALUE;
            let next = Math.min(max, Math.max(min, Number(value)));
            next = Number.isFinite(next) ? next : min;
            const text = next.toFixed(4).replace(/0+$/, '').replace(/\.$/, '');
            if (source !== 'input' && wavelengthInput) wavelengthInput.value = text;
            if (source !== 'slider' && wavelengthSlider) wavelengthSlider.value = next;
            if (wavelengthReadout) wavelengthReadout.textContent = text;
        }
        if (wavelengthInput) wavelengthInput.addEventListener('input', () => syncWavelength(wavelengthInput.value, 'input'));
        if (wavelengthSlider) wavelengthSlider.addEventListener('input', () => syncWavelength(wavelengthSlider.value, 'slider'));
        document.querySelectorAll('.preset').forEach(button => {
            button.addEventListener('click', () => syncWavelength(button.dataset.value, 'preset'));
        });

        const metricInput = document.getElementById('metricInput');
        const calculatorForm = document.getElementById('calculatorForm');
        document.querySelectorAll('.metric-tab').forEach(button => {
            button.addEventListener('click', () => {
                if (metricInput) metricInput.value = button.dataset.metric;
                if (calculatorForm) calculatorForm.submit();
            });
        });

        const chartCanvas = document.getElementById('refractiveIndexChart');
        <% if (selectedMaterial != null && chartWavelengths != null && chartValues != null) { %>
        if (chartCanvas) {
            const wavelengths = <%= chartWavelengths %>;
            const values = <%= chartValues %>;
            const selectedWavelength = <%= safeWavelengthValue %>;
            const selectedValue = <%
                if (result == null) {
                    out.print("null");
                } else if ("reflectance".equals(activeMetric)) {
                    out.print(String.format(java.util.Locale.US, "%.6f", result.getReflectance() * 100.0));
                } else if ("transmission".equals(activeMetric)) {
                    out.print(result.getSinglePassTransmission() != null
                        ? String.format(java.util.Locale.US, "%.6f", result.getSinglePassTransmission() * 100.0)
                        : "null");
                } else {
                    out.print(String.format(java.util.Locale.US, "%.6f", result.getRefractiveIndex()));
                }
            %>;

            function drawOpticalChart() {
                const ctx = chartCanvas.getContext('2d');
                const ratio = window.devicePixelRatio || 1;
                const rect = chartCanvas.getBoundingClientRect();
                chartCanvas.width = rect.width * ratio;
                chartCanvas.height = rect.height * ratio;
                ctx.setTransform(ratio, 0, 0, ratio, 0, 0);

                const width = rect.width;
                const height = rect.height;
                const padding = { top: 24, right: 24, bottom: 46, left: 58 };
                const plotWidth = width - padding.left - padding.right;
                const plotHeight = height - padding.top - padding.bottom;
                const minX = Math.min(...wavelengths);
                const maxX = Math.max(...wavelengths);
                const minY = Math.min(...values);
                const maxY = Math.max(...values);
                const yPadding = (maxY - minY) * 0.1 || 0.1;
                const lowY = minY - yPadding;
                const highY = maxY + yPadding;
                const xToPx = x => padding.left + ((x - minX) / (maxX - minX)) * plotWidth;
                const yToPx = y => padding.top + plotHeight - ((y - lowY) / (highY - lowY)) * plotHeight;

                ctx.clearRect(0, 0, width, height);
                ctx.fillStyle = '#ffffff';
                ctx.fillRect(0, 0, width, height);

                ctx.strokeStyle = '#e5e7eb';
                ctx.lineWidth = 1;
                ctx.beginPath();
                for (let i = 0; i <= 4; i++) {
                    const y = padding.top + (plotHeight / 4) * i;
                    ctx.moveTo(padding.left, y);
                    ctx.lineTo(padding.left + plotWidth, y);
                }
                for (let i = 0; i <= 5; i++) {
                    const x = padding.left + (plotWidth / 5) * i;
                    ctx.moveTo(x, padding.top);
                    ctx.lineTo(x, padding.top + plotHeight);
                }
                ctx.stroke();

                const gradient = ctx.createLinearGradient(padding.left, 0, padding.left + plotWidth, 0);
                gradient.addColorStop(0, '#14b8a6');
                gradient.addColorStop(1, '#7c3aed');
                ctx.strokeStyle = gradient;
                ctx.lineWidth = 3;
                ctx.beginPath();
                wavelengths.forEach((wavelength, index) => {
                    const x = xToPx(wavelength);
                    const y = yToPx(values[index]);
                    if (index === 0) ctx.moveTo(x, y);
                    else ctx.lineTo(x, y);
                });
                ctx.stroke();

                if (!Number.isNaN(selectedWavelength) && selectedValue !== null) {
                    const pointX = xToPx(selectedWavelength);
                    const pointY = yToPx(selectedValue);
                    ctx.strokeStyle = '#f59e0b';
                    ctx.lineWidth = 1.5;
                    ctx.setLineDash([5, 5]);
                    ctx.beginPath();
                    ctx.moveTo(pointX, padding.top);
                    ctx.lineTo(pointX, padding.top + plotHeight);
                    ctx.stroke();
                    ctx.setLineDash([]);
                    ctx.fillStyle = '#f59e0b';
                    ctx.beginPath();
                    ctx.arc(pointX, pointY, 5.5, 0, Math.PI * 2);
                    ctx.fill();
                }

                ctx.fillStyle = '#6b7280';
                ctx.font = '12px Segoe UI';
                ctx.textAlign = 'center';
                for (let i = 0; i <= 5; i++) {
                    const value = minX + ((maxX - minX) / 5) * i;
                    ctx.fillText(value.toFixed(2), padding.left + (plotWidth / 5) * i, height - 16);
                }
                ctx.textAlign = 'right';
                for (let i = 0; i <= 4; i++) {
                    const value = lowY + ((highY - lowY) / 4) * (4 - i);
                    ctx.fillText(value.toFixed(3), padding.left - 8, padding.top + (plotHeight / 4) * i + 4);
                }
                ctx.fillStyle = '#374151';
                ctx.font = '13px Segoe UI';
                ctx.textAlign = 'center';
                ctx.fillText('Wavelength (um)', padding.left + plotWidth / 2, height - 2);
                ctx.save();
                ctx.translate(16, padding.top + plotHeight / 2);
                ctx.rotate(-Math.PI / 2);
                ctx.fillText('<%= chartLabel != null ? chartLabel : "Refractive Index n" %>', 0, 0);
                ctx.restore();
            }

            drawOpticalChart();
            window.addEventListener('resize', drawOpticalChart);
        }
        <% } %>
    </script>

    <%@ include file="../common/system-chatbot.jsp" %>
    <%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>
