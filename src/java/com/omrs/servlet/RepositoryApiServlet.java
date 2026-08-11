package com.omrs.servlet;

import com.omrs.dao.RepositoryDAO;
import com.omrs.model.Experiment;
import com.omrs.model.TestData;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.*;

/**
 * REST API Servlet for Repository module.
 * Provides JSON endpoints for accessing optical material data.
 * Similar to refractiveindex.info API functionality.
 * 
 * API Endpoints:
 * GET /api/repository                    - Get all approved experiments
 * GET /api/repository/stats              - Get repository statistics
 * GET /api/repository/materials          - Get list of material types
 * GET /api/repository/experiment/{id}    - Get single experiment details
 * GET /api/repository/search?keyword=&material=&dateFrom=&dateTo=&testType=
 * GET /api/repository/public-search?query= - Search Crossref public research metadata
 * GET /api/repository/material/{type}    - Get experiments by material type
 */
@WebServlet(name = "RepositoryApiServlet", urlPatterns = {
    "/api/repository",
    "/api/repository/*"
})
public class RepositoryApiServlet extends HttpServlet {
    
    private RepositoryDAO repositoryDAO = new RepositoryDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Unauthorized. Please login.\"}");
            return;
        }
        
        // Set CORS headers for API access
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // GET /api/repository - Get all approved experiments
                handleGetAll(request, response);
            } else if (pathInfo.equals("/stats")) {
                // GET /api/repository/stats
                handleGetStats(response);
            } else if (pathInfo.equals("/materials")) {
                // GET /api/repository/materials
                handleGetMaterials(response);
            } else if (pathInfo.equals("/search")) {
                // GET /api/repository/search
                handleSearch(request, response);
            } else if (pathInfo.equals("/public-search")) {
                // GET /api/repository/public-search
                handlePublicSearch(request, response);
            } else if (pathInfo.startsWith("/experiment/")) {
                // GET /api/repository/experiment/{id}
                String experimentId = pathInfo.substring("/experiment/".length());
                handleGetExperiment(response, experimentId);
            } else if (pathInfo.startsWith("/material/")) {
                // GET /api/repository/material/{type}
                String materialType = java.net.URLDecoder.decode(
                    pathInfo.substring("/material/".length()), "UTF-8");
                handleGetByMaterial(response, materialType);
            } else {
                sendError(response, 404, "Endpoint not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, 500, "Internal server error: " + e.getMessage());
        }
    }
    
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle CORS preflight
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(HttpServletResponse.SC_OK);
    }
    
    /**
     * GET /api/repository - Get all approved experiments with pagination
     */
    private void handleGetAll(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int page = getIntParam(request, "page", 1);
        int pageSize = getIntParam(request, "pageSize", 20);
        
        List<Experiment> experiments = repositoryDAO.getApprovedPaginated(page, pageSize);
        int totalCount = repositoryDAO.getTotalApprovedCount();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":{");
        json.append("\"experiments\":").append(experimentsToJson(experiments)).append(",");
        json.append("\"pagination\":{");
        json.append("\"currentPage\":").append(page).append(",");
        json.append("\"pageSize\":").append(pageSize).append(",");
        json.append("\"totalPages\":").append(totalPages).append(",");
        json.append("\"totalCount\":").append(totalCount);
        json.append("}");
        json.append("}");
        json.append("}");
        
        response.getWriter().write(json.toString());
    }

    /**
     * GET /api/repository/public-search - Proxy Crossref public research search
     */
    private void handlePublicSearch(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String query = request.getParameter("query");
        if (query == null || query.trim().isEmpty()) {
            sendError(response, 400, "Please enter a public search keyword.");
            return;
        }

        String encodedQuery = URLEncoder.encode(query.trim(), "UTF-8");
        String crossrefUrl = "https://api.crossref.org/works?rows=12&query=" + encodedQuery;
        HttpURLConnection conn = null;

        try {
            URL url = new URL(crossrefUrl);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(15000);
            conn.setRequestProperty("Accept", "application/json");
            conn.setRequestProperty("User-Agent", "OMRS/1.0 (Crossref public search)");

            int status = conn.getResponseCode();
            String body = readResponse(conn);

            if (status >= 200 && status < 300) {
                response.getWriter().write(body);
            } else {
                sendError(response, 502, "Crossref returned status " + status + ". " + body);
            }
        } catch (Exception e) {
            sendError(response, 503, "Public search could not reach Crossref. Check server internet access. " + e.getMessage());
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }
    
    /**
     * GET /api/repository/stats - Get repository statistics
     */
    private void handleGetStats(HttpServletResponse response) throws IOException {
        Map<String, Object> stats = repositoryDAO.getStatistics();
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":{");
        json.append("\"totalExperiments\":").append(stats.get("totalExperiments")).append(",");
        json.append("\"totalMaterials\":").append(stats.get("totalMaterials")).append(",");
        json.append("\"totalTestData\":").append(stats.get("totalTestData")).append(",");
        
        // Material counts
        json.append("\"materialCounts\":{");
        @SuppressWarnings("unchecked")
        Map<String, Integer> materialCounts = (Map<String, Integer>) stats.get("materialCounts");
        if (materialCounts != null) {
            int i = 0;
            for (Map.Entry<String, Integer> entry : materialCounts.entrySet()) {
                if (i > 0) json.append(",");
                json.append("\"").append(escapeJson(entry.getKey())).append("\":").append(entry.getValue());
                i++;
            }
        }
        json.append("},");
        
        // Test type counts
        json.append("\"testTypeCounts\":{");
        @SuppressWarnings("unchecked")
        Map<String, Integer> testTypeCounts = (Map<String, Integer>) stats.get("testTypeCounts");
        if (testTypeCounts != null) {
            int i = 0;
            for (Map.Entry<String, Integer> entry : testTypeCounts.entrySet()) {
                if (i > 0) json.append(",");
                json.append("\"").append(escapeJson(entry.getKey())).append("\":").append(entry.getValue());
                i++;
            }
        }
        json.append("},");
        
        // Recent experiments
        json.append("\"recentExperiments\":");
        @SuppressWarnings("unchecked")
        List<Experiment> recent = (List<Experiment>) stats.get("recentExperiments");
        json.append(experimentsToJson(recent != null ? recent : new ArrayList<>()));
        
        json.append("}");
        json.append("}");
        
        response.getWriter().write(json.toString());
    }
    
    /**
     * GET /api/repository/materials - Get list of material types
     */
    private void handleGetMaterials(HttpServletResponse response) throws IOException {
        List<String> materials = repositoryDAO.getMaterialTypes();
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":{");
        json.append("\"materials\":[");
        for (int i = 0; i < materials.size(); i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(escapeJson(materials.get(i))).append("\"");
        }
        json.append("],");
        json.append("\"count\":").append(materials.size());
        json.append("}");
        json.append("}");
        
        response.getWriter().write(json.toString());
    }
    
    /**
     * GET /api/repository/search - Search experiments with filters
     */
    private void handleSearch(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String keyword = request.getParameter("keyword");
        String materialType = request.getParameter("material");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String testType = request.getParameter("testType");
        
        List<Experiment> results = repositoryDAO.search(keyword, materialType, dateFrom, dateTo, testType);
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":{");
        json.append("\"query\":{");
        json.append("\"keyword\":").append(keyword != null ? "\"" + escapeJson(keyword) + "\"" : "null").append(",");
        json.append("\"material\":").append(materialType != null ? "\"" + escapeJson(materialType) + "\"" : "null").append(",");
        json.append("\"dateFrom\":").append(dateFrom != null ? "\"" + dateFrom + "\"" : "null").append(",");
        json.append("\"dateTo\":").append(dateTo != null ? "\"" + dateTo + "\"" : "null").append(",");
        json.append("\"testType\":").append(testType != null ? "\"" + testType + "\"" : "null");
        json.append("},");
        json.append("\"results\":").append(experimentsToJson(results)).append(",");
        json.append("\"count\":").append(results.size());
        json.append("}");
        json.append("}");
        
        response.getWriter().write(json.toString());
    }
    
    /**
     * GET /api/repository/experiment/{id} - Get single experiment details
     */
    private void handleGetExperiment(HttpServletResponse response, String experimentId) throws IOException {
        Experiment experiment = repositoryDAO.getApprovedById(experimentId);
        
        if (experiment == null) {
            sendError(response, 404, "Experiment not found or not approved");
            return;
        }
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":").append(experimentToDetailJson(experiment));
        json.append("}");
        
        response.getWriter().write(json.toString());
    }
    
    /**
     * GET /api/repository/material/{type} - Get experiments by material type
     */
    private void handleGetByMaterial(HttpServletResponse response, String materialType) throws IOException {
        List<Experiment> experiments = repositoryDAO.getByMaterialType(materialType);
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":{");
        json.append("\"materialType\":\"").append(escapeJson(materialType)).append("\",");
        json.append("\"experiments\":").append(experimentsToJson(experiments)).append(",");
        json.append("\"count\":").append(experiments.size());
        json.append("}");
        json.append("}");
        
        response.getWriter().write(json.toString());
    }
    
    /**
     * Convert list of experiments to JSON array
     */
    private String experimentsToJson(List<Experiment> experiments) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < experiments.size(); i++) {
            if (i > 0) json.append(",");
            json.append(experimentToJson(experiments.get(i)));
        }
        json.append("]");
        return json.toString();
    }
    
    /**
     * Convert single experiment to JSON (basic)
     */
    private String experimentToJson(Experiment e) {
        StringBuilder json = new StringBuilder("{");
        json.append("\"experimentId\":\"").append(escapeJson(e.getExperimentId())).append("\",");
        json.append("\"title\":\"").append(escapeJson(e.getTitle())).append("\",");
        json.append("\"materialType\":\"").append(escapeJson(e.getMaterialType())).append("\",");
        json.append("\"concentration\":").append(e.getConcentration() != null ? "\"" + escapeJson(e.getConcentration()) + "\"" : "null").append(",");
        json.append("\"experimentDate\":\"").append(e.getExperimentDate()).append("\",");
        json.append("\"studentName\":").append(e.getStudentName() != null ? "\"" + escapeJson(e.getStudentName()) + "\"" : "null");
        json.append("}");
        return json.toString();
    }
    
    /**
     * Convert single experiment to detailed JSON (with test data)
     */
    private String experimentToDetailJson(Experiment e) {
        StringBuilder json = new StringBuilder("{");
        json.append("\"experimentId\":\"").append(escapeJson(e.getExperimentId())).append("\",");
        json.append("\"title\":\"").append(escapeJson(e.getTitle())).append("\",");
        json.append("\"materialType\":\"").append(escapeJson(e.getMaterialType())).append("\",");
        json.append("\"concentration\":").append(e.getConcentration() != null ? "\"" + escapeJson(e.getConcentration()) + "\"" : "null").append(",");
        json.append("\"experimentDate\":\"").append(e.getExperimentDate()).append("\",");
        json.append("\"preparationNotes\":").append(e.getPreparationNotes() != null ? "\"" + escapeJson(e.getPreparationNotes()) + "\"" : "null").append(",");
        json.append("\"studentId\":\"").append(escapeJson(e.getStudentId())).append("\",");
        json.append("\"studentName\":").append(e.getStudentName() != null ? "\"" + escapeJson(e.getStudentName()) + "\"" : "null").append(",");
        json.append("\"status\":\"").append(e.getStatus()).append("\",");
        
        // Test data
        json.append("\"testData\":[");
        List<TestData> testFiles = e.getTestFiles();
        if (testFiles != null) {
            for (int i = 0; i < testFiles.size(); i++) {
                if (i > 0) json.append(",");
                TestData t = testFiles.get(i);
                json.append("{");
                json.append("\"testDataId\":\"").append(escapeJson(t.getTestDataId())).append("\",");
                json.append("\"testType\":\"").append(escapeJson(t.getTestType())).append("\",");
                json.append("\"fileName\":\"").append(escapeJson(t.getFileName())).append("\",");
                json.append("\"fileSize\":").append(t.getFileSize() != null ? "\"" + escapeJson(t.getFileSize()) + "\"" : "null");
                json.append("}");
            }
        }
        json.append("]");
        
        json.append("}");
        return json.toString();
    }
    
    /**
     * Send error response
     */
    private void sendError(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(message) + "\"}");
    }

    private String readResponse(HttpURLConnection conn) throws IOException {
        InputStream stream = conn.getResponseCode() >= 400 ? conn.getErrorStream() : conn.getInputStream();
        if (stream == null) {
            return "";
        }

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(stream, "UTF-8"))) {
            StringBuilder body = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
            return body.toString();
        }
    }
    
    /**
     * Get integer parameter with default value
     */
    private int getIntParam(HttpServletRequest request, String name, int defaultValue) {
        try {
            String value = request.getParameter(name);
            if (value != null) return Integer.parseInt(value);
        } catch (NumberFormatException e) {}
        return defaultValue;
    }
    
    /**
     * Escape special characters for JSON
     */
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}
