package com.omrs.servlet;

import com.omrs.model.OpticalCalculationResult;
import com.omrs.model.OpticalMaterial;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "OpticalConstantsServlet", urlPatterns = {
    "/optical-constants",
    "/optical-constants/",
    "/optical-constants/material/*"
})
public class OpticalConstantsServlet extends HttpServlet {
    private static final List<OpticalMaterial> MATERIALS = buildMaterials();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String materialId = request.getParameter("material");
        String pathInfo = request.getPathInfo();
        if ((materialId == null || materialId.trim().isEmpty()) && pathInfo != null && pathInfo.length() > 1) {
            materialId = pathInfo.substring(1);
        }

        OpticalMaterial selectedMaterial = findMaterial(materialId);
        request.setAttribute("materials", MATERIALS);
        request.setAttribute("selectedMaterial", selectedMaterial);

        String wavelengthParam = request.getParameter("wavelength");
        String thicknessParam = request.getParameter("thickness");
        String thicknessUnit = defaultIfBlank(request.getParameter("thicknessUnit"), "mm");
        String chartMetric = defaultIfBlank(request.getParameter("metric"), "n");
        request.setAttribute("chartMetric", chartMetric);
        request.setAttribute("chartLabel", getChartLabel(chartMetric));

        if (selectedMaterial != null) {
            request.setAttribute("chartWavelengths", buildChartWavelengths(selectedMaterial));
            request.setAttribute("chartValues", buildChartValues(selectedMaterial, chartMetric, thicknessParam, thicknessUnit));
        }

        if (selectedMaterial != null && "csv".equalsIgnoreCase(request.getParameter("export"))) {
            exportCsv(response, selectedMaterial, chartMetric, thicknessParam, thicknessUnit);
            return;
        }

        if (selectedMaterial != null) {
            try {
                double wavelengthUm = Double.parseDouble(defaultIfBlank(wavelengthParam, "0.55"));
                if (wavelengthUm < selectedMaterial.getWavelengthMinUm() || wavelengthUm > selectedMaterial.getWavelengthMaxUm()) {
                    request.setAttribute("error", "Wavelength is outside the valid range for " + selectedMaterial.getName()
                            + " (" + format(selectedMaterial.getWavelengthMinUm()) + "–" + format(selectedMaterial.getWavelengthMaxUm()) + " um).");
                } else {
                    request.setAttribute("result", calculate(selectedMaterial, wavelengthUm, thicknessParam, thicknessUnit));
                }
            } catch (NumberFormatException ex) {
                request.setAttribute("error", "Please enter a valid numeric wavelength.");
            }
        }

        request.getRequestDispatcher("/pages/optical/index.jsp").forward(request, response);
    }

    private OpticalMaterial findMaterial(String materialId) {
        if (materialId == null) return null;
        for (OpticalMaterial material : MATERIALS) {
            if (material.getId().equalsIgnoreCase(materialId)) return material;
        }
        return null;
    }

    private OpticalCalculationResult calculate(OpticalMaterial material, double wavelengthUm, String thicknessParam, String thicknessUnit) {
        OpticalCalculationResult result = new OpticalCalculationResult();
        double n = computeRefractiveIndex(material.getId(), wavelengthUm);
        double k = 0.0;
        double epsilon1 = (n * n) - (k * k);
        double epsilon2 = 2.0 * n * k;
        double alpha = wavelengthUm <= 0 ? 0.0 : (4.0 * Math.PI * k * 10000.0) / wavelengthUm;
        double reflectance = (((n - 1.0) * (n - 1.0)) + (k * k)) / (((n + 1.0) * (n + 1.0)) + (k * k));

        result.setWavelengthUm(wavelengthUm);
        result.setRefractiveIndex(n);
        result.setExtinctionCoefficient(k);
        result.setEpsilon1(epsilon1);
        result.setEpsilon2(epsilon2);
        result.setAbsorptionCoefficientCm(alpha);
        result.setReflectance(reflectance);

        if (thicknessParam != null && !thicknessParam.trim().isEmpty()) {
            try {
                double thicknessValue = Double.parseDouble(thicknessParam);
                double thicknessCm = convertThicknessToCm(thicknessValue, thicknessUnit);
                double internalTransmission = Math.exp(-alpha * thicknessCm);
                double singlePassTransmission = internalTransmission * Math.pow(1.0 - reflectance, 2.0);
                result.setThicknessValue(thicknessValue);
                result.setThicknessUnit(thicknessUnit);
                result.setInternalTransmission(internalTransmission);
                result.setSinglePassTransmission(singlePassTransmission);
            } catch (NumberFormatException ignore) {
                result.setThicknessUnit(thicknessUnit);
            }
        }
        return result;
    }

    private double computeRefractiveIndex(String materialId, double wavelengthUm) {
        double l2 = wavelengthUm * wavelengthUm;
        double n2;
        switch (materialId) {
            case "SiO2":
                n2 = 1.0
                        + (0.6961663 * l2) / (l2 - Math.pow(0.0684043, 2))
                        + (0.4079426 * l2) / (l2 - Math.pow(0.1162414, 2))
                        + (0.8974794 * l2) / (l2 - Math.pow(9.896161, 2));
                break;
            case "PMMA":
                n2 = 1.0 + (1.1819 * l2) / (l2 - 0.011313);
                break;
            case "ZnO":
                n2 = 2.81418 + (0.87968 * l2) / (l2 - Math.pow(0.3042, 2)) - (0.00711 * l2);
                break;
            case "TiO2":
                n2 = 7.197 + 0.3322 / (l2 - 0.0843);
                break;
            case "MgF2":
                n2 = 1.0
                        + (0.48755108 * l2) / (l2 - Math.pow(0.04338408, 2))
                        + (0.39875031 * l2) / (l2 - Math.pow(0.09461442, 2))
                        + (2.3120353 * l2) / (l2 - Math.pow(23.793604, 2));
                break;
            case "CaF2":
                n2 = 1.0
                        + (0.5675888 * l2) / (l2 - Math.pow(0.050263605, 2))
                        + (0.4710914 * l2) / (l2 - Math.pow(0.1003909, 2))
                        + (3.8484723 * l2) / (l2 - Math.pow(34.649040, 2));
                break;
            case "Al2O3":
                n2 = 1.0
                        + (1.023798 * l2) / (l2 - Math.pow(0.06144821, 2))
                        + (1.058264 * l2) / (l2 - Math.pow(0.1106997, 2))
                        + (5.280792 * l2) / (l2 - Math.pow(17.92656, 2));
                break;
            case "LiNbO3":
                n2 = 1.0
                        + (2.6734 * l2) / (l2 - 0.01764)
                        + (1.2290 * l2) / (l2 - 0.05914)
                        + (12.614 * l2) / (l2 - 474.60);
                break;
            case "ZnSe":
                n2 = 1.0
                        + (4.45813734 * l2) / (l2 - Math.pow(0.200859853, 2))
                        + (0.467216334 * l2) / (l2 - Math.pow(0.391371166, 2))
                        + (2.89566290 * l2) / (l2 - Math.pow(47.1362108, 2));
                break;
            case "BK7":
                n2 = 1.0
                        + (0.614555251 * l2) / (l2 - 0.0145987884)
                        + (0.656775017 * l2) / (l2 - 0.00287769588)
                        + (1.02699346 * l2) / (l2 - 107.653051);
                break;
            default:
                throw new IllegalArgumentException("Unsupported material: " + materialId);
        }
        return Math.sqrt(n2);
    }

    private double convertThicknessToCm(double thicknessValue, String unit) {
        switch (unit) {
            case "nm": return thicknessValue * 1.0e-7;
            case "um": return thicknessValue * 1.0e-4;
            case "mm": return thicknessValue * 0.1;
            case "cm": return thicknessValue;
            case "m": return thicknessValue * 100.0;
            case "km": return thicknessValue * 100000.0;
            default: return thicknessValue * 0.1;
        }
    }

    private String defaultIfBlank(String value, String defaultValue) {
        return value == null || value.trim().isEmpty() ? defaultValue : value.trim();
    }

    private String buildChartWavelengths(OpticalMaterial material) {
        List<String> values = new ArrayList<>();
        int points = 60;
        double min = material.getWavelengthMinUm();
        double max = material.getWavelengthMaxUm();
        double step = (max - min) / (points - 1);
        for (int i = 0; i < points; i++) {
            double wavelength = min + (step * i);
            values.add(formatChartValue(wavelength));
        }
        return "[" + String.join(",", values) + "]";
    }

    private String buildChartValues(OpticalMaterial material, String metric, String thicknessParam, String thicknessUnit) {
        List<String> values = new ArrayList<>();
        int points = 60;
        double min = material.getWavelengthMinUm();
        double max = material.getWavelengthMaxUm();
        double step = (max - min) / (points - 1);
        for (int i = 0; i < points; i++) {
            double wavelength = min + (step * i);
            values.add(formatChartValue(computeMetricValue(material, wavelength, metric, thicknessParam, thicknessUnit)));
        }
        return "[" + String.join(",", values) + "]";
    }

    private double computeMetricValue(OpticalMaterial material, double wavelengthUm, String metric, String thicknessParam, String thicknessUnit) {
        OpticalCalculationResult result = calculate(material, wavelengthUm, thicknessParam, thicknessUnit);
        if ("reflectance".equals(metric)) {
            return result.getReflectance() * 100.0;
        }
        if ("transmission".equals(metric)) {
            return result.getSinglePassTransmission() != null ? result.getSinglePassTransmission() * 100.0 : 0.0;
        }
        return result.getRefractiveIndex();
    }

    private String getChartLabel(String metric) {
        if ("reflectance".equals(metric)) {
            return "Reflectance (%)";
        }
        if ("transmission".equals(metric)) {
            return "Transmission (%)";
        }
        return "Refractive Index n";
    }

    private void exportCsv(HttpServletResponse response, OpticalMaterial material, String metric, String thicknessParam, String thicknessUnit)
            throws IOException {
        response.setContentType("text/csv");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + material.getId() + "-" + metric + "-chart.csv\"");

        try (PrintWriter writer = response.getWriter()) {
            writer.println("material,metric,wavelength_um,value");
            int points = 60;
            double min = material.getWavelengthMinUm();
            double max = material.getWavelengthMaxUm();
            double step = (max - min) / (points - 1);
            for (int i = 0; i < points; i++) {
                double wavelength = min + (step * i);
                double value = computeMetricValue(material, wavelength, metric, thicknessParam, thicknessUnit);
                writer.println(csv(material.getId()) + "," + csv(metric) + "," + formatChartValue(wavelength) + "," + formatChartValue(value));
            }
        }
    }

    private String csv(String value) {
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }

    private String format(double value) {
        return String.format(java.util.Locale.US, "%.4f", value).replaceAll("0+$", "").replaceAll("\\.$", "");
    }

    private String formatChartValue(double value) {
        return String.format(java.util.Locale.US, "%.6f", value);
    }

    private static List<OpticalMaterial> buildMaterials() {
        List<OpticalMaterial> materials = new ArrayList<>();
        materials.add(material("SiO2", "Fused Silica", "SiO2", "Oxide", 0.21, 6.7,
                "n^2 - 1 = (0.6961663l^2)/(l^2-0.0684043^2) + (0.4079426l^2)/(l^2-0.1162414^2) + (0.8974794l^2)/(l^2-9.896161^2)",
                "Malitson 1965: n 0.21-6.7 um",
                "https://doi.org/10.1364/JOSA.55.001205",
                "https://refractiveindex.info/?material=SiO2",
                "Fused silica, 20 C. Sellmeier formula widely used for optical design."));
        materials.add(material("PMMA", "PMMA", "Poly(methyl methacrylate)", "Polymer", 0.4368, 1.052,
                "n^2 - 1 = (1.1819l^2)/(l^2-0.011313)",
                "Sultanova et al. 2009: n 0.4368-1.052 um",
                "https://doi.org/10.12693/APhysPolA.116.585",
                "https://refractiveindex.info/?book=plastics&page=pmma&shelf=3d",
                "20 C. Useful for acrylic optical components and polymer comparison."));
        materials.add(material("ZnO", "Zinc Oxide", "ZnO", "Semiconductor", 0.45, 4.0,
                "n^2 = 2.81418 + (0.87968l^2)/(l^2-0.3042^2) - 0.00711l^2",
                "Bond et al. 1965: n(o) 0.45-4.0 um",
                "https://doi.org/10.1063/1.1714367",
                "https://refractiveindex.info/?book=ZnO&page=Bond-o&shelf=main",
                "Ordinary ray, room temperature. Good fit for ZnO thin-film study comparisons."));
        materials.add(material("TiO2", "Titanium Dioxide", "TiO2", "Oxide", 0.43, 1.53,
                "n^2 = 7.197 + 0.3322/(l^2-0.0843)",
                "Devore 1951: n(e) 0.43-1.53 um",
                "https://doi.org/10.1364/JOSA.41.000416",
                "https://refractiveindex.info/?book=TiO2&page=Devore-e&shelf=main",
                "Extraordinary ray, room temperature. Suitable for rutile-style optical analysis."));
        materials.add(material("MgF2", "Magnesium Fluoride", "MgF2", "Fluoride", 0.2, 7.0,
                "n^2 - 1 = (0.48755108l^2)/(l^2-0.04338408^2) + (0.39875031l^2)/(l^2-0.09461442^2) + (2.3120353l^2)/(l^2-23.793604^2)",
                "Dodge 1984: n(o) 0.2-7.0 um",
                "https://doi.org/10.1364/AO.23.001980",
                "https://refractiveindex.info/?book=MgF2&page=Dodge-o&shelf=main",
                "19 C, ordinary ray. Classic low-index material for coatings and UV-IR optics."));
        materials.add(material("CaF2", "Calcium Fluoride", "CaF2", "Fluoride", 0.23, 9.7,
                "n^2 - 1 = (0.5675888l^2)/(l^2-0.050263605^2) + (0.4710914l^2)/(l^2-0.1003909^2) + (3.8484723l^2)/(l^2-34.649040^2)",
                "Malitson 1963: n 0.23-9.7 um",
                "https://doi.org/10.1364/AO.2.001103",
                "https://refractiveindex.info/?book=CaF2&page=Malitson&shelf=main",
                "24 C. Wide transparency range, strong choice for UV and IR windows."));
        materials.add(material("Al2O3", "Sapphire", "Al2O3", "Crystal", 0.2652, 5.577,
                "n^2 - 1 = (1.023798l^2)/(l^2-0.06144821^2) + (1.058264l^2)/(l^2-0.1106997^2) + (5.280792l^2)/(l^2-17.92656^2)",
                "Malitson 1962: alpha-Al2O3, n(o) 0.2652-5.577 um",
                "https://doi.org/10.1364/JOSA.52.001377",
                "https://refractiveindex.info/?book=Al2O3&page=Malitson&shelf=main",
                "Synthetic sapphire, ordinary ray. Robust substrate and window material."));
        materials.add(material("LiNbO3", "Lithium Niobate", "LiNbO3", "Nonlinear Crystal", 0.4, 5.0,
                "n^2 - 1 = (2.6734l^2)/(l^2-0.01764) + (1.2290l^2)/(l^2-0.05914) + (12.614l^2)/(l^2-474.60)",
                "Zelmon et al. 1997: n(o) 0.4-5.0 um",
                "https://doi.org/10.1364/JOSAB.14.003319",
                "https://refractiveindex.info/?book=LiNbO3&page=Zelmon-o&shelf=main",
                "21 C, ordinary ray. Important electro-optic and nonlinear optical crystal."));
        materials.add(material("ZnSe", "Zinc Selenide", "ZnSe", "Semiconductor", 0.54, 18.2,
                "n^2 - 1 = (4.45813734l^2)/(l^2-0.200859853^2) + (0.467216334l^2)/(l^2-0.391371166^2) + (2.89566290l^2)/(l^2-47.1362108^2)",
                "Connolly et al. 1979: n 0.54-18.2 um",
                "https://refractiveindex.info/?book=ZnSe&page=Connolly&shelf=main",
                "https://refractiveindex.info/?book=ZnSe&page=Connolly&shelf=main",
                "CVD ZnSe, 23 C. Widely used for infrared laser optics and windows."));
        materials.add(material("BK7", "BK7 Optical Glass", "BK7", "Glass", 0.29, 2.4,
                "n^2 - 1 = (0.614555251l^2)/(l^2-0.0145987884) + (0.656775017l^2)/(l^2-0.00287769588) + (1.02699346l^2)/(l^2-107.653051)",
                "CDGM Zemax catalog 2022-06: H-K9L / BK7, 0.29-2.4 um",
                "https://refractiveindex.info/?book=BK7&page=CDGM&shelf=popular_glass",
                "https://refractiveindex.info/?book=BK7&page=CDGM&shelf=popular_glass",
                "Common optical crown glass used across lenses, windows, and general optical design."));
        return materials;
    }

    private static OpticalMaterial material(String id, String name, String chemicalFormula, String category,
            double wavelengthMinUm, double wavelengthMaxUm, String formulaDisplay, String referenceTitle,
            String referenceUrl, String sourceUrl, String comments) {
        OpticalMaterial material = new OpticalMaterial();
        material.setId(id);
        material.setName(name);
        material.setChemicalFormula(chemicalFormula);
        material.setCategory(category);
        material.setWavelengthMinUm(wavelengthMinUm);
        material.setWavelengthMaxUm(wavelengthMaxUm);
        material.setFormulaDisplay(formulaDisplay);
        material.setReferenceTitle(referenceTitle);
        material.setReferenceUrl(referenceUrl);
        material.setSourceUrl(sourceUrl);
        material.setComments(comments);
        return material;
    }
}
