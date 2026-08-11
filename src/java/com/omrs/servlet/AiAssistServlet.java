package com.omrs.servlet;

import com.omrs.model.User;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ai/*")
public class AiAssistServlet extends HttpServlet {
    private static final String GEMINI_GENERATE_URL_PREFIX = "https://generativelanguage.googleapis.com/v1beta/models/";
    private static final String GEMINI_GENERATE_URL_SUFFIX = ":generateContent";
    private static final String DEFAULT_MODEL = "gemini-2.5-flash";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, false, "Please log in before using the AI assistant.");
            return;
        }

        String path = req.getPathInfo();
        if (path == null || !(path.equals("/study-objective") || path.equals("/study-summary") || path.equals("/chat") || path.equals("/system-chat"))) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            writeJson(resp, false, "AI assistant route not found.");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!path.equals("/system-chat") && !"STUDENT".equals(user.getRole())) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            writeJson(resp, false, "Only students can use this AI assistant.");
            return;
        }

        String apiKey = getConfigValue("GEMINI_API_KEY", "gemini.api.key");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            writeJson(resp, false, "AI is not configured yet. Set GEMINI_API_KEY as a server environment variable, Java system property, or web.xml context-param.");
            return;
        }

        String prompt = buildPrompt(path, req);
        if (prompt.length() > 6000) {
            prompt = prompt.substring(0, 6000);
        }

        try {
            String systemInstruction = getSystemInstruction(path);
            int maxTokens = path.equals("/chat") || path.equals("/system-chat") ? 360 : 240;
            String generatedText = callGemini(apiKey, prompt, systemInstruction, maxTokens);
            writeJson(resp, true, generatedText);
        } catch (Exception ex) {
            resp.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
            writeJson(resp, false, "AI request failed: " + ex.getMessage());
        }
    }

    private String buildPrompt(String path, HttpServletRequest req) {
        if (path.equals("/study-summary")) {
            return buildStudySummaryPrompt(req);
        }
        if (path.equals("/chat")) {
            return buildChatPrompt(req);
        }
        if (path.equals("/system-chat")) {
            return buildSystemChatPrompt(req);
        }
        return buildStudyObjectivePrompt(req);
    }

    private String getSystemInstruction(String path) {
        if (path.equals("/study-summary")) {
            return "You summarize optical material experiment drafts for students. Return concise, structured text with short headings and no markdown tables.";
        }
        if (path.equals("/chat")) {
            return "You are an optical material study assistant. Answer using the student's current form details when relevant. Be concise, cautious, and practical. Do not invent exact results.";
        }
        if (path.equals("/system-chat")) {
            return "You are the OMRS system navigation assistant. Answer only questions related to using OMRS, navigating modules, experiment workflow, supervisor review, logbooks, learning materials, optical constants, repository, notifications, and profile settings. Be concise and give menu paths or page names when useful. If the question is unrelated, politely say you can only help with OMRS system use.";
        }
        return "You help optical material students write clear, cautious, academic experiment objectives. Return only the objective text.";
    }

    private String buildStudyObjectivePrompt(HttpServletRequest req) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Draft one concise academic study objective for an optical material experiment.\n");
        prompt.append("Use 1-2 sentences. Mention the material, sample variation, and characterization focus when available.\n");
        prompt.append("Avoid inventing exact numerical results. Keep the writing suitable for a student lab/repository submission.\n\n");
        appendStudyContext(prompt, req);
        return prompt.toString();
    }

    private String buildStudySummaryPrompt(HttpServletRequest req) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Summarize this optical material experiment draft for a student before submission.\n");
        prompt.append("Return 4 short sections: Study overview, Sample comparison, Characterization plan, Missing or weak details.\n");
        prompt.append("Use concise bullets. If details are missing, say what the student should add.\n\n");
        appendStudyContext(prompt, req);
        return prompt.toString();
    }

    private String buildChatPrompt(HttpServletRequest req) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Student question: ").append(trimToNull(req.getParameter("question")) == null ? "" : req.getParameter("question").trim()).append("\n\n");
        prompt.append("Current experiment form context:\n");
        appendStudyContext(prompt, req);
        return prompt.toString();
    }

    private String buildSystemChatPrompt(HttpServletRequest req) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("User role: ").append(trimToNull(req.getParameter("role")) == null ? "Unknown" : req.getParameter("role").trim()).append('\n');
        prompt.append("Current page: ").append(trimToNull(req.getParameter("currentPage")) == null ? "Dashboard" : req.getParameter("currentPage").trim()).append('\n');
        prompt.append("User question: ").append(trimToNull(req.getParameter("question")) == null ? "" : req.getParameter("question").trim()).append("\n\n");
        prompt.append("OMRS navigation and workflow reference:\n");
        prompt.append("- Student Dashboard: view experiment counts, research flow, supervisor details, and experiment list.\n");
        prompt.append("- New Experiment: create an optical material study, save as draft, submit for supervisor review, add sample comparison, table values, files, and AI objective support.\n");
        prompt.append("- Student Experiment View: view status, feedback, comparison visualization, uploaded characterization data, and CSV export.\n");
        prompt.append("- Student Edit: revise drafts or rejected experiments, then resubmit.\n");
        prompt.append("- Student Logbooks: FYP students record weekly progress, preparation, testing, analysis, and supervisor comments.\n");
        prompt.append("- Learning Materials: access learning content and quizzes.\n");
        prompt.append("- Optical Constants: reference optical material constants and related values.\n");
        prompt.append("- Repository: browse/search approved experiments, view public details, comments, and downloadable test data.\n");
        prompt.append("- Notifications: view unread updates such as submissions, approvals, rejections, and comments.\n");
        prompt.append("- Profile: update personal details and profile picture.\n");
        prompt.append("- Supervisor Dashboard: view pending reviews, student counts, applications, and pending experiment cards.\n");
        prompt.append("- Supervisor Review: inspect student experiment details, uploaded files, visualizations, then approve or reject with feedback.\n");
        prompt.append("- My Students: view supervised student profiles and their submitted experiments.\n");
        prompt.append("- Applications: approve or reject pending FYP student applications.\n");
        return prompt.toString();
    }

    private void appendStudyContext(StringBuilder prompt, HttpServletRequest req) {
        appendField(prompt, "Title", req.getParameter("title"));
        appendField(prompt, "Study type", req.getParameter("studyType"));
        appendField(prompt, "Material A", resolveOther(req.getParameter("materialType"), req.getParameter("customMaterial")));
        appendField(prompt, "Material A concentration", combineConcentration(req.getParameter("concentrationAmount"), req.getParameter("concentrationUnit"), req.getParameter("concentrationUnitOther")));
        appendField(prompt, "Material B", resolveOther(req.getParameter("materialBType"), req.getParameter("customMaterialB")));
        appendField(prompt, "Material B concentration", combineConcentration(req.getParameter("materialBConcentrationAmount"), req.getParameter("materialBConcentrationUnit"), req.getParameter("materialBConcentrationUnitOther")));
        appendField(prompt, "Comparison metric label", req.getParameter("comparisonMetricLabel"));
        appendField(prompt, "Material A metric value", req.getParameter("materialAMetricValue"));
        appendField(prompt, "Material B metric value", req.getParameter("materialBMetricValue"));
        appendField(prompt, "Comparison notes", req.getParameter("comparisonNotes"));
        appendComparisonTable(prompt, req);
        appendField(prompt, "Study objective", req.getParameter("studyObjective"));
        appendField(prompt, "Hypothesis", req.getParameter("hypothesis"));
        appendField(prompt, "Independent variable", req.getParameter("independentVariable"));
        appendField(prompt, "Dependent variable", req.getParameter("dependentVariable"));
        appendField(prompt, "Controlled variables", req.getParameter("controlledVariables"));
        appendField(prompt, "Sample A", combineParts(req.getParameter("sampleOneName"), req.getParameter("sampleOneCondition"), req.getParameter("sampleOneNotes")));
        appendField(prompt, "Sample B", combineParts(req.getParameter("sampleTwoName"), req.getParameter("sampleTwoCondition"), req.getParameter("sampleTwoNotes")));
        appendField(prompt, "Sample C", combineParts(req.getParameter("sampleThreeName"), req.getParameter("sampleThreeCondition"), req.getParameter("sampleThreeNotes")));
        appendField(prompt, "Characterization methods", combineParts(joinValues(req.getParameterValues("characterizationMethods")), req.getParameter("characterizationOther")));
        appendField(prompt, "Expected analysis notes", req.getParameter("characterizationNotes"));
        appendField(prompt, "Instrument details", req.getParameter("instrumentDetails"));
        appendField(prompt, "Scan range", req.getParameter("scanRange"));
        appendField(prompt, "Calibration reference", req.getParameter("calibrationReference"));
        appendField(prompt, "Replicate count", req.getParameter("replicateCount"));
        appendField(prompt, "Measurement uncertainty", req.getParameter("measurementUncertainty"));
        appendField(prompt, "Raw data required", req.getParameter("rawDataRequired") == null ? null : "Yes");
        appendField(prompt, "Preparation notes", req.getParameter("preparationNotes"));
        appendField(prompt, "Conclusion", req.getParameter("conclusion"));
        appendField(prompt, "Limitations", req.getParameter("limitations"));
        appendField(prompt, "Next steps", req.getParameter("nextSteps"));
    }

    private void appendComparisonTable(StringBuilder prompt, HttpServletRequest req) {
        String[] metrics = req.getParameterValues("tableMetric");
        String[] sampleA = req.getParameterValues("tableSampleA");
        String[] sampleB = req.getParameterValues("tableSampleB");
        String[] sampleC = req.getParameterValues("tableSampleC");
        if (metrics == null) {
            return;
        }

        StringBuilder table = new StringBuilder();
        for (int i = 0; i < metrics.length; i++) {
            String metric = valueAt(metrics, i);
            String a = valueAt(sampleA, i);
            String b = valueAt(sampleB, i);
            String c = valueAt(sampleC, i);
            if (metric == null && a == null && b == null && c == null) {
                continue;
            }
            table.append(metric == null ? "Metric" : metric)
                    .append(" | A: ").append(a == null ? "-" : a)
                    .append(" | B: ").append(b == null ? "-" : b)
                    .append(" | C: ").append(c == null ? "-" : c)
                    .append('\n');
        }
        appendField(prompt, "Comparison table", table.toString());
    }

    private String valueAt(String[] values, int index) {
        if (values == null || index >= values.length) {
            return null;
        }
        return trimToNull(values[index]);
    }

    private String callGemini(String apiKey, String prompt, String systemInstruction, int maxOutputTokens) throws IOException {
        String model = getConfigValue("OMRS_AI_MODEL", "omrs.ai.model");
        if (model == null || model.trim().isEmpty()) {
            model = DEFAULT_MODEL;
        }

        String payload = "{"
                + "\"systemInstruction\":{\"parts\":[{\"text\":\"" + escapeJson(systemInstruction) + "\"}]},"
                + "\"contents\":[{\"role\":\"user\",\"parts\":[{\"text\":\"" + escapeJson(prompt) + "\"}]}],"
                + "\"generationConfig\":{\"maxOutputTokens\":" + maxOutputTokens + ",\"temperature\":0.4}"
                + "}";

        URL url = new URL(GEMINI_GENERATE_URL_PREFIX + model.trim() + GEMINI_GENERATE_URL_SUFFIX);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(45000);
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("x-goog-api-key", apiKey.trim());

        byte[] body = payload.getBytes(StandardCharsets.UTF_8);
        try (OutputStream out = conn.getOutputStream()) {
            out.write(body);
        }

        int status = conn.getResponseCode();
        String responseBody = readStream(status >= 400 ? conn.getErrorStream() : conn.getInputStream());
        if (status >= 400) {
            String apiMessage = extractJsonString(responseBody, "message");
            throw new IOException(apiMessage == null ? "Gemini API returned HTTP " + status : apiMessage);
        }

        String generatedText = extractJsonString(responseBody, "text");
        if (generatedText == null || generatedText.trim().isEmpty()) {
            throw new IOException("Gemini response did not include generated text.");
        }
        return generatedText.trim();
    }

    private String getConfigValue(String envOrContextName, String systemPropertyName) {
        String value = System.getenv(envOrContextName);
        if (value != null && !value.trim().isEmpty()) {
            return value;
        }

        value = System.getProperty(systemPropertyName);
        if (value != null && !value.trim().isEmpty()) {
            return value;
        }

        return getServletContext().getInitParameter(envOrContextName);
    }

    private void appendField(StringBuilder builder, String label, String value) {
        String trimmed = trimToNull(value);
        if (trimmed != null) {
            builder.append(label).append(": ").append(trimmed).append('\n');
        }
    }

    private String resolveOther(String value, String otherValue) {
        String trimmed = trimToNull(value);
        if ("Other".equals(trimmed)) {
            return otherValue;
        }
        return trimmed;
    }

    private String combineConcentration(String amount, String unit, String otherUnit) {
        String trimmedAmount = trimToNull(amount);
        String trimmedUnit = trimToNull(unit);
        if (trimmedAmount == null) {
            return null;
        }
        if ("Other".equals(trimmedUnit)) {
            trimmedUnit = trimToNull(otherUnit);
        }
        return trimmedUnit == null ? trimmedAmount : trimmedAmount + " " + trimmedUnit;
    }

    private String combineParts(String... values) {
        StringBuilder combined = new StringBuilder();
        for (String value : values) {
            String trimmed = trimToNull(value);
            if (trimmed == null) {
                continue;
            }
            if (combined.length() > 0) {
                combined.append("; ");
            }
            combined.append(trimmed);
        }
        return combined.length() == 0 ? null : combined.toString();
    }

    private String joinValues(String[] values) {
        if (values == null || values.length == 0) {
            return null;
        }
        StringBuilder joined = new StringBuilder();
        for (String value : values) {
            String trimmed = trimToNull(value);
            if (trimmed == null) {
                continue;
            }
            if (joined.length() > 0) {
                joined.append(", ");
            }
            joined.append(trimmed);
        }
        return joined.length() == 0 ? null : joined.toString();
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String readStream(InputStream stream) throws IOException {
        if (stream == null) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
        }
        return builder.toString();
    }

    private void writeJson(HttpServletResponse resp, boolean success, String message) throws IOException {
        resp.getWriter().write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}");
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        StringBuilder escaped = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '"':
                    escaped.append("\\\"");
                    break;
                case '\\':
                    escaped.append("\\\\");
                    break;
                case '\b':
                    escaped.append("\\b");
                    break;
                case '\f':
                    escaped.append("\\f");
                    break;
                case '\n':
                    escaped.append("\\n");
                    break;
                case '\r':
                    escaped.append("\\r");
                    break;
                case '\t':
                    escaped.append("\\t");
                    break;
                default:
                    if (c < 32) {
                        escaped.append(String.format("\\u%04x", (int) c));
                    } else {
                        escaped.append(c);
                    }
            }
        }
        return escaped.toString();
    }

    private String extractJsonString(String json, String key) {
        if (json == null || key == null) {
            return null;
        }
        String needle = "\"" + key + "\"";
        int index = json.indexOf(needle);
        while (index >= 0) {
            int colon = json.indexOf(':', index + needle.length());
            if (colon < 0) {
                return null;
            }
            int quote = json.indexOf('"', colon + 1);
            if (quote < 0) {
                return null;
            }
            String value = parseJsonString(json, quote);
            if (value != null) {
                return value;
            }
            index = json.indexOf(needle, quote + 1);
        }
        return null;
    }

    private String parseJsonString(String json, int quoteIndex) {
        if (quoteIndex < 0 || quoteIndex >= json.length() || json.charAt(quoteIndex) != '"') {
            return null;
        }
        StringBuilder value = new StringBuilder();
        for (int i = quoteIndex + 1; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '"') {
                return value.toString();
            }
            if (c != '\\') {
                value.append(c);
                continue;
            }
            if (++i >= json.length()) {
                return null;
            }
            char escaped = json.charAt(i);
            switch (escaped) {
                case '"':
                case '\\':
                case '/':
                    value.append(escaped);
                    break;
                case 'b':
                    value.append('\b');
                    break;
                case 'f':
                    value.append('\f');
                    break;
                case 'n':
                    value.append('\n');
                    break;
                case 'r':
                    value.append('\r');
                    break;
                case 't':
                    value.append('\t');
                    break;
                case 'u':
                    if (i + 4 >= json.length()) {
                        return null;
                    }
                    String hex = json.substring(i + 1, i + 5);
                    try {
                        value.append((char) Integer.parseInt(hex, 16));
                    } catch (NumberFormatException ex) {
                        return null;
                    }
                    i += 4;
                    break;
                default:
                    value.append(escaped);
            }
        }
        return null;
    }
}
