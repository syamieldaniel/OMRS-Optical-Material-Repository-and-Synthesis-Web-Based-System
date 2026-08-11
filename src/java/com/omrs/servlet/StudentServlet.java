package com.omrs.servlet;

import com.omrs.dao.ExperimentDAO;
import com.omrs.dao.NotificationDAO;
import com.omrs.dao.UserDAO;
import com.omrs.model.Experiment;
import com.omrs.model.TestData;
import com.omrs.model.User;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.Date;
import java.util.Arrays;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/student/*")
@MultipartConfig(maxFileSize = 16177215) // 16MB max file size
public class StudentServlet extends HttpServlet {
    private ExperimentDAO dao = new ExperimentDAO();
    private UserDAO userDAO = new UserDAO();
    private NotificationDAO notificationDAO = new NotificationDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"STUDENT".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        String studentId = (String) session.getAttribute("studentId");
        String studentType = (String) session.getAttribute("studentType");
        if (studentType == null || studentType.trim().isEmpty()) {
            studentType = userDAO.getStudentType(user.getUserId());
            user.setStudentType(studentType);
            session.setAttribute("studentType", studentType);
        }
        String path = req.getPathInfo();
        
        if (path == null || path.equals("/") || path.equals("/dashboard")) {
            List<Experiment> list = dao.getByStudent(studentId);
            int[] stats = dao.getStats(studentId);
            Map<String, String> supervisorInfo = userDAO.getSupervisorByStudent(studentId);
            req.setAttribute("experiments", list);
            req.setAttribute("total", stats[0]);
            req.setAttribute("draft", stats[1]);
            req.setAttribute("pending", stats[2]);
            req.setAttribute("approved", stats[3]);
            req.setAttribute("supervisorName", supervisorInfo.get("name"));
            req.setAttribute("supervisorEmail", supervisorInfo.get("email"));
            req.getRequestDispatcher("/pages/student/dashboard.jsp").forward(req, resp);
            
        } else if (path.equals("/create")) {
            req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
            
        } else if (path.startsWith("/view/")) {
            String id = path.substring(6);
            req.setAttribute("experiment", dao.getById(id));
            req.getRequestDispatcher("/pages/student/view.jsp").forward(req, resp);
            
        } else if (path.startsWith("/edit/")) {
            String id = path.substring(6);
            req.setAttribute("experiment", dao.getById(id));
            req.getRequestDispatcher("/pages/student/edit.jsp").forward(req, resp);
            
        } else if (path.startsWith("/delete/")) {
            String id = path.substring(8);
            dao.delete(id);
            resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("=== StudentServlet doPost called ===");
        System.out.println("Path Info: " + req.getPathInfo());
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            System.out.println("Session invalid or user not found");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"STUDENT".equals(user.getRole())) {
            System.out.println("User role is not STUDENT: " + user.getRole());
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        String studentId = (String) session.getAttribute("studentId");
        System.out.println("Student ID: " + studentId);
        
        if (studentId == null || studentId.isEmpty()) {
            System.out.println("ERROR: Student ID not found in session");
            req.setAttribute("error", "Student ID not found in session.");
            req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
            return;
        }
        
        String path = req.getPathInfo();
        System.out.println("Processing path: " + path);
        
        try {
            if (path == null || path.equals("/") || path.equals("/create")) {
                System.out.println("Creating new experiment...");
                
                String title = req.getParameter("title");
                String dateStr = req.getParameter("date");
                String studyType = normalizeStudyType(req.getParameter("studyType"));
                String materialType = req.getParameter("materialType");
                String customMaterial = req.getParameter("customMaterial");
                String concentration = buildConcentration(req.getParameter("concentrationAmount"), req.getParameter("concentrationUnit"), req.getParameter("concentrationUnitOther"));
                String materialBType = resolveMaterialType(req.getParameter("materialBType"), req.getParameter("customMaterialB"));
                String materialBConcentration = buildConcentration(req.getParameter("materialBConcentrationAmount"), req.getParameter("materialBConcentrationUnit"), req.getParameter("materialBConcentrationUnitOther"));
                String studyObjective = req.getParameter("studyObjective");
                String prepNotes = req.getParameter("preparationNotes");
                String characterizationNotes = req.getParameter("characterizationNotes");
                String action = req.getParameter("action");
                
                System.out.println("=== Form Parameters ===");
                System.out.println("Title: [" + title + "]");
                System.out.println("Date: [" + dateStr + "]");
                System.out.println("Material: [" + materialType + "]");
                System.out.println("Concentration: [" + concentration + "]");
                System.out.println("Action: [" + action + "]");
                System.out.println("=======================");
                
                // Validate required fields
                if (title == null) {
                    System.out.println("ERROR: Title parameter is NULL");
                    req.setAttribute("error", "Title parameter not received. Please refresh and try again.");
                    req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
                    return;
                }
                
                if (title.trim().isEmpty()) {
                    System.out.println("ERROR: Title is empty/whitespace");
                    req.setAttribute("error", "Please provide an experiment title.");
                    req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
                    return;
                }
                
                if (dateStr == null || dateStr.isEmpty()) {
                    System.out.println("ERROR: Date is empty");
                    req.setAttribute("error", "Please provide an experiment date.");
                    req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
                    return;
                }
                
                if (materialType == null || materialType.trim().isEmpty()) {
                    System.out.println("ERROR: Material type is empty");
                    req.setAttribute("error", "Please select a material type.");
                    req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
                    return;
                }

                materialType = resolveMaterialType(materialType, customMaterial);
                if (materialType == null) {
                    System.out.println("ERROR: Custom material is empty");
                    req.setAttribute("error", "Please provide a custom material name.");
                    req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
                    return;
                }

                if ("COMPARISON".equals(studyType) && materialBType == null) {
                    System.out.println("ERROR: Second material is empty");
                    req.setAttribute("error", "Please select the second material for the comparison study.");
                    req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
                    return;
                }
                
                Experiment e = new Experiment();
                String expId = dao.generateId();
                System.out.println("Generated Experiment ID: " + expId);
                
                e.setExperimentId(expId);
                e.setStudentId(studentId);
                e.setTitle(title.trim());
                e.setExperimentDate(Date.valueOf(dateStr));
                e.setMaterialType(materialType);
                e.setConcentration(concentration);
                e.setStudyType(studyType);
                e.setMaterialBType("COMPARISON".equals(studyType) ? materialBType : null);
                e.setMaterialBConcentration("COMPARISON".equals(studyType) ? materialBConcentration : null);
                e.setComparisonMetricLabel("COMPARISON".equals(studyType) ? trimToNull(req.getParameter("comparisonMetricLabel")) : null);
                e.setMaterialAMetricValue("COMPARISON".equals(studyType) ? parseOptionalDouble(req.getParameter("materialAMetricValue")) : null);
                e.setMaterialBMetricValue("COMPARISON".equals(studyType) ? parseOptionalDouble(req.getParameter("materialBMetricValue")) : null);
                e.setComparisonNotes("COMPARISON".equals(studyType) ? trimToNull(req.getParameter("comparisonNotes")) : null);
                e.setComparisonTableData(buildComparisonTableData(req));
                e.setStudyObjective(trimToNull(studyObjective));
                e.setHypothesis(trimToNull(req.getParameter("hypothesis")));
                e.setIndependentVariable(trimToNull(req.getParameter("independentVariable")));
                e.setDependentVariable(trimToNull(req.getParameter("dependentVariable")));
                e.setControlledVariables(trimToNull(req.getParameter("controlledVariables")));
                e.setPreparationNotes(prepNotes != null ? prepNotes.trim() : "");
                e.setCharacterizationMethods(buildCharacterizationMethods(req.getParameterValues("characterizationMethods"), req.getParameter("characterizationOther")));
                e.setCharacterizationNotes(trimToNull(characterizationNotes));
                e.setInstrumentDetails(trimToNull(req.getParameter("instrumentDetails")));
                e.setScanRange(trimToNull(req.getParameter("scanRange")));
                e.setCalibrationReference(trimToNull(req.getParameter("calibrationReference")));
                e.setReplicateCount(parseOptionalInteger(req.getParameter("replicateCount")));
                e.setMeasurementUncertainty(trimToNull(req.getParameter("measurementUncertainty")));
                e.setRawDataRequired(req.getParameter("rawDataRequired") != null);
                e.setConclusion(trimToNull(req.getParameter("conclusion")));
                e.setLimitations(trimToNull(req.getParameter("limitations")));
                e.setNextSteps(trimToNull(req.getParameter("nextSteps")));
                e.setSampleOneName(trimToNull(req.getParameter("sampleOneName")));
                e.setSampleOneCondition(trimToNull(req.getParameter("sampleOneCondition")));
                e.setSampleOneNotes(trimToNull(req.getParameter("sampleOneNotes")));
                e.setSampleTwoName(trimToNull(req.getParameter("sampleTwoName")));
                e.setSampleTwoCondition(trimToNull(req.getParameter("sampleTwoCondition")));
                e.setSampleTwoNotes(trimToNull(req.getParameter("sampleTwoNotes")));
                e.setSampleThreeName(trimToNull(req.getParameter("sampleThreeName")));
                e.setSampleThreeCondition(trimToNull(req.getParameter("sampleThreeCondition")));
                e.setSampleThreeNotes(trimToNull(req.getParameter("sampleThreeNotes")));
                e.setStatus("submit".equals(action) ? "PENDING" : "DRAFT");
                
                System.out.println("Experiment object created, calling dao.create()...");
                boolean success = dao.create(e);
                System.out.println("Experiment creation result: " + success);
                
                if (success) {
                    handleCharacterizationFileUploads(req, expId);
                    
                    if ("PENDING".equals(e.getStatus())) {
                        notifySupervisorAboutSubmission(e, user);
                    }

                    System.out.println("Redirecting to view page");
                    resp.sendRedirect(req.getContextPath() + "/student/view/" + e.getExperimentId());
                } else {
                    System.out.println("ERROR: Failed to create experiment in database");
                    req.setAttribute("error", "Failed to create experiment. Please check your data and try again.");
                    req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
                }
                
            } else if (path.startsWith("/update/")) {
                String id = path.substring(8);
                System.out.println("Updating experiment: " + id);
                
                Experiment e = dao.getById(id);
                if (e == null) {
                    System.out.println("ERROR: Experiment not found: " + id);
                    req.setAttribute("error", "Experiment not found.");
                    req.getRequestDispatcher("/pages/student/dashboard.jsp").forward(req, resp);
                    return;
                }
                
                e.setTitle(req.getParameter("title"));
                String studyType = normalizeStudyType(req.getParameter("studyType"));
                String dateStr = req.getParameter("date");
                if (dateStr == null || dateStr.isEmpty()) {
                    req.setAttribute("error", "Please provide an experiment date.");
                    req.setAttribute("experiment", e);
                    req.getRequestDispatcher("/pages/student/edit.jsp").forward(req, resp);
                    return;
                }
                e.setExperimentDate(Date.valueOf(dateStr));
                String materialType = resolveMaterialType(req.getParameter("materialType"), req.getParameter("customMaterial"));
                if (materialType == null) {
                    req.setAttribute("error", "Please provide a custom material name.");
                    req.setAttribute("experiment", e);
                    req.getRequestDispatcher("/pages/student/edit.jsp").forward(req, resp);
                    return;
                }
                e.setMaterialType(materialType);
                e.setConcentration(buildConcentration(req.getParameter("concentrationAmount"), req.getParameter("concentrationUnit"), req.getParameter("concentrationUnitOther")));
                String materialBType = resolveMaterialType(req.getParameter("materialBType"), req.getParameter("customMaterialB"));
                if ("COMPARISON".equals(studyType) && materialBType == null) {
                    req.setAttribute("error", "Please select the second material for the comparison study.");
                    req.setAttribute("experiment", e);
                    req.getRequestDispatcher("/pages/student/edit.jsp").forward(req, resp);
                    return;
                }
                e.setStudyType(studyType);
                e.setMaterialBType("COMPARISON".equals(studyType) ? materialBType : null);
                e.setMaterialBConcentration("COMPARISON".equals(studyType) ? buildConcentration(req.getParameter("materialBConcentrationAmount"), req.getParameter("materialBConcentrationUnit"), req.getParameter("materialBConcentrationUnitOther")) : null);
                e.setComparisonMetricLabel("COMPARISON".equals(studyType) ? trimToNull(req.getParameter("comparisonMetricLabel")) : null);
                e.setMaterialAMetricValue("COMPARISON".equals(studyType) ? parseOptionalDouble(req.getParameter("materialAMetricValue")) : null);
                e.setMaterialBMetricValue("COMPARISON".equals(studyType) ? parseOptionalDouble(req.getParameter("materialBMetricValue")) : null);
                e.setComparisonNotes("COMPARISON".equals(studyType) ? trimToNull(req.getParameter("comparisonNotes")) : null);
                e.setComparisonTableData(buildComparisonTableData(req));
                e.setStudyObjective(trimToNull(req.getParameter("studyObjective")));
                e.setHypothesis(trimToNull(req.getParameter("hypothesis")));
                e.setIndependentVariable(trimToNull(req.getParameter("independentVariable")));
                e.setDependentVariable(trimToNull(req.getParameter("dependentVariable")));
                e.setControlledVariables(trimToNull(req.getParameter("controlledVariables")));
                e.setPreparationNotes(trimToNull(req.getParameter("preparationNotes")));
                e.setCharacterizationMethods(buildCharacterizationMethods(req.getParameterValues("characterizationMethods"), req.getParameter("characterizationOther")));
                e.setCharacterizationNotes(trimToNull(req.getParameter("characterizationNotes")));
                e.setInstrumentDetails(trimToNull(req.getParameter("instrumentDetails")));
                e.setScanRange(trimToNull(req.getParameter("scanRange")));
                e.setCalibrationReference(trimToNull(req.getParameter("calibrationReference")));
                e.setReplicateCount(parseOptionalInteger(req.getParameter("replicateCount")));
                e.setMeasurementUncertainty(trimToNull(req.getParameter("measurementUncertainty")));
                e.setRawDataRequired(req.getParameter("rawDataRequired") != null);
                e.setConclusion(trimToNull(req.getParameter("conclusion")));
                e.setLimitations(trimToNull(req.getParameter("limitations")));
                e.setNextSteps(trimToNull(req.getParameter("nextSteps")));
                e.setSampleOneName(trimToNull(req.getParameter("sampleOneName")));
                e.setSampleOneCondition(trimToNull(req.getParameter("sampleOneCondition")));
                e.setSampleOneNotes(trimToNull(req.getParameter("sampleOneNotes")));
                e.setSampleTwoName(trimToNull(req.getParameter("sampleTwoName")));
                e.setSampleTwoCondition(trimToNull(req.getParameter("sampleTwoCondition")));
                e.setSampleTwoNotes(trimToNull(req.getParameter("sampleTwoNotes")));
                e.setSampleThreeName(trimToNull(req.getParameter("sampleThreeName")));
                e.setSampleThreeCondition(trimToNull(req.getParameter("sampleThreeCondition")));
                e.setSampleThreeNotes(trimToNull(req.getParameter("sampleThreeNotes")));
                String action = req.getParameter("action");
                String previousStatus = e.getStatus();
                boolean submitForReview = "submit".equals(action);
                if (submitForReview) {
                    e.setStatus("PENDING");
                    e.setFeedback(null);
                } else if ("PENDING".equals(previousStatus)) {
                    e.setStatus("PENDING");
                } else if ("APPROVED".equals(previousStatus)) {
                    e.setStatus("APPROVED");
                } else {
                    e.setStatus("DRAFT");
                }
                
                boolean success = dao.update(e);
                if (success) {
                    handleCharacterizationFileUploads(req, id);
                    if (submitForReview) {
                        notifySupervisorAboutSubmission(e, user);
                    }
                    resp.sendRedirect(req.getContextPath() + "/student/view/" + id);
                } else {
                    req.setAttribute("error", "Failed to update experiment. Please try again.");
                    req.setAttribute("experiment", e);
                    req.getRequestDispatcher("/pages/student/edit.jsp").forward(req, resp);
                }
            }
        } catch (IllegalArgumentException e) {
            System.out.println("ERROR: Invalid data format - " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Invalid data format: " + e.getMessage());
            if (path != null && path.startsWith("/update/")) {
                String id = path.substring(8);
                Experiment experiment = dao.getById(id);
                if (experiment != null) {
                    req.setAttribute("experiment", experiment);
                }
                req.getRequestDispatcher("/pages/student/edit.jsp").forward(req, resp);
            } else {
                req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            System.out.println("ERROR: Exception in doPost - " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Error saving experiment: " + e.getMessage());
            if (path != null && path.startsWith("/update/")) {
                String id = path.substring(8);
                Experiment experiment = dao.getById(id);
                if (experiment != null) {
                    req.setAttribute("experiment", experiment);
                }
                req.getRequestDispatcher("/pages/student/edit.jsp").forward(req, resp);
            } else {
                req.getRequestDispatcher("/pages/student/create.jsp").forward(req, resp);
            }
        }
    }
    
    private String extractFileName(Part part) {
        try {
            String contentDisp = part.getHeader("content-disposition");
            if (contentDisp == null) {
                System.out.println("WARNING: content-disposition header is null");
                return null;
            }
            
            String[] items = contentDisp.split(";");
            for (String s : items) {
                s = s.trim();
                if (s.startsWith("filename")) {
                    // Extract filename between quotes
                    int start = s.indexOf("=");
                    if (start >= 0) {
                        String fileName = s.substring(start + 1).trim();
                        // Remove quotes if present
                        if (fileName.startsWith("\"") && fileName.endsWith("\"")) {
                            fileName = fileName.substring(1, fileName.length() - 1);
                        }
                        // Get just the filename, not the full path
                        return new File(fileName).getName();
                    }
                }
            }
        } catch (Exception ex) {
            System.out.println("ERROR in extractFileName: " + ex.getMessage());
            ex.printStackTrace();
        }
        return null;
    }

    private void handleCharacterizationFileUploads(HttpServletRequest req, String experimentId) {
        try {
            String uploadDir = getUploadDirectory(experimentId);
            File uploadFolder = new File(uploadDir);
            if (!uploadFolder.exists() && !uploadFolder.mkdirs()) {
                throw new IOException("Unable to create upload directory: " + uploadFolder.getAbsolutePath());
            }

            String[][] uploadFields = {
                {"ftirFile", "FTIR"},
                {"semFile", "SEM"},
                {"uvvisFile", "UV-VIS"},
                {"xrdFile", "XRD"},
                {"probeFile", "Two-Point Probe"},
                {"otherCharacterizationFile", resolveOtherTestType(req.getParameter("characterizationOther"))}
            };

            for (String[] uploadField : uploadFields) {
                String fieldName = uploadField[0];
                String testType = uploadField[1];
                try {
                    Part filePart = req.getPart(fieldName);
                    if (filePart == null || filePart.getSize() <= 0) {
                        continue;
                    }

                    String fileName = extractFileName(filePart);
                    if (fileName == null || fileName.isEmpty()) {
                        continue;
                    }

                    String filePath = "/uploads/" + experimentId + "/" + fileName;
                    long fileSize = filePart.getSize();
                    File savedFile = new File(uploadFolder, fileName);
                    try (InputStream input = filePart.getInputStream()) {
                        Files.copy(input, savedFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }

                    TestData td = new TestData();
                    td.setTestDataId(dao.generateTestDataId());
                    td.setExperimentId(experimentId);
                    td.setTestType(testType);
                    td.setFileName(fileName);
                    td.setFilePath(filePath);
                    td.setFileSize(fileSize + " bytes");

                    dao.saveTestData(td);
                    System.out.println("Saved characterization data: " + testType + " - " + fileName);
                } catch (Exception ex) {
                    System.out.println("Error processing file " + fieldName + ": " + ex.getMessage());
                }
            }
        } catch (Exception ex) {
            System.out.println("Error handling characterization file uploads: " + ex.getMessage());
            ex.printStackTrace();
        }
    }

    private String resolveOtherTestType(String otherMethod) {
        String trimmed = trimToNull(otherMethod);
        return trimmed == null ? "Other" : trimmed;
    }

    private String resolveMaterialType(String materialType, String customMaterial) {
        if (materialType == null) {
            return null;
        }

        String trimmedMaterialType = materialType.trim();
        if (trimmedMaterialType.isEmpty()) {
            return null;
        }

        if ("Other".equals(trimmedMaterialType)) {
            if (customMaterial == null || customMaterial.trim().isEmpty()) {
                return null;
            }
            return customMaterial.trim();
        }

        return trimmedMaterialType;
    }

    private String buildConcentration(String amount, String unit, String customUnit) {
        String trimmedAmount = trimToNull(amount);
        String trimmedUnit = trimToNull(unit);
        String trimmedCustomUnit = trimToNull(customUnit);

        if (trimmedAmount == null) {
            return "";
        }

        if ("Other".equals(trimmedUnit)) {
            trimmedUnit = trimmedCustomUnit;
        }

        return trimmedUnit == null ? trimmedAmount : trimmedAmount + " " + trimmedUnit;
    }

    private String normalizeStudyType(String studyType) {
        return "COMPARISON".equals(studyType) ? "COMPARISON" : "SINGLE";
    }

    private Double parseOptionalDouble(String value) {
        String trimmed = trimToNull(value);
        if (trimmed == null) {
            return null;
        }
        return Double.valueOf(trimmed);
    }

    private Integer parseOptionalInteger(String value) {
        String trimmed = trimToNull(value);
        if (trimmed == null) {
            return null;
        }
        return Integer.valueOf(trimmed);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String buildCharacterizationMethods(String[] selectedMethods, String otherMethod) {
        List<String> methods = selectedMethods == null
                ? new java.util.ArrayList<>()
                : Arrays.stream(selectedMethods)
                    .map(this::trimToNull)
                    .filter(value -> value != null)
                    .distinct()
                    .collect(Collectors.toList());

        String trimmedOther = trimToNull(otherMethod);
        if (trimmedOther != null && !methods.contains(trimmedOther)) {
            methods.add(trimmedOther);
        }

        return methods.isEmpty() ? null : String.join(", ", methods);
    }

    private String buildComparisonTableData(HttpServletRequest req) {
        String[] metrics = req.getParameterValues("tableMetric");
        String[] sampleAValues = req.getParameterValues("tableSampleA");
        String[] sampleBValues = req.getParameterValues("tableSampleB");
        String[] sampleCValues = req.getParameterValues("tableSampleC");
        if (metrics == null) {
            return null;
        }

        StringBuilder tableData = new StringBuilder();
        for (int i = 0; i < metrics.length; i++) {
            String metric = valueAt(metrics, i);
            String sampleA = valueAt(sampleAValues, i);
            String sampleB = valueAt(sampleBValues, i);
            String sampleC = valueAt(sampleCValues, i);
            if (metric == null && sampleA == null && sampleB == null && sampleC == null) {
                continue;
            }
            if (tableData.length() > 0) {
                tableData.append('\n');
            }
            tableData.append(encodeCell(metric)).append('\t')
                     .append(encodeCell(sampleA)).append('\t')
                     .append(encodeCell(sampleB)).append('\t')
                     .append(encodeCell(sampleC));
        }
        return tableData.length() == 0 ? null : tableData.toString();
    }

    private String valueAt(String[] values, int index) {
        if (values == null || index >= values.length) {
            return null;
        }
        return trimToNull(values[index]);
    }

    private String encodeCell(String value) {
        String safeValue = value == null ? "" : value;
        return Base64.getEncoder().encodeToString(safeValue.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }

    private void notifySupervisorAboutSubmission(Experiment experiment, User student) {
        Integer supervisorUserId = userDAO.getSupervisorUserIdByStudent(experiment.getStudentId());
        if (supervisorUserId == null) return;

        String studentName = student.getFullName() != null && !student.getFullName().trim().isEmpty()
                ? student.getFullName()
                : student.getUsername();
        String message = studentName + " submitted \"" + experiment.getTitle() + "\" for review.";

        notificationDAO.create(
            supervisorUserId,
            "Experiment submitted",
            message,
            "/supervisor/review/" + experiment.getExperimentId()
        );
    }

    private String getUploadDirectory(String experimentId) {
        String configuredBase = firstNonBlank(
                getServletContext().getInitParameter("OMRS_UPLOAD_DIR"),
                System.getProperty("omrs.upload.dir"),
                System.getenv("OMRS_UPLOAD_DIR"));

        String webUploads = getServletContext().getRealPath("/uploads");
        String homeUploads = System.getProperty("user.home") + File.separator + ".omrs" + File.separator + "uploads";
        String[] candidates = {configuredBase, webUploads, homeUploads};

        for (String candidate : candidates) {
            if (candidate == null || candidate.trim().isEmpty()) {
                continue;
            }

            File baseDir = new File(candidate.trim());
            if ((baseDir.exists() || baseDir.mkdirs()) && baseDir.isDirectory() && baseDir.canWrite()) {
                return new File(baseDir, experimentId).getAbsolutePath();
            }
        }

        return new File(homeUploads, experimentId).getAbsolutePath();
    }

    private String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }
        return null;
    }
}
