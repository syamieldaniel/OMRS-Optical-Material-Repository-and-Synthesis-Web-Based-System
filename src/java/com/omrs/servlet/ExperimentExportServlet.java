package com.omrs.servlet;

import com.omrs.dao.ExperimentDAO;
import com.omrs.dao.UserDAO;
import com.omrs.model.Experiment;
import com.omrs.model.TestData;
import com.omrs.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/experiment/export/*")
public class ExperimentExportServlet extends HttpServlet {
    private ExperimentDAO experimentDAO = new ExperimentDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getPathInfo();
        if (path == null || path.length() <= 1) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Experiment ID is required.");
            return;
        }

        User user = (User) session.getAttribute("user");
        String experimentId = path.substring(1);
        Experiment experiment = experimentDAO.getById(experimentId);
        if (experiment == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Experiment not found.");
            return;
        }

        if (!canExport(user, experiment, session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to export this experiment.");
            return;
        }

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/csv;charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + experiment.getExperimentId() + "-experiment.csv\"");

        try (PrintWriter out = resp.getWriter()) {
            writeCsv(out, experiment);
        }
    }

    private boolean canExport(User user, Experiment experiment, HttpSession session) {
        if ("STUDENT".equals(user.getRole())) {
            String studentId = (String) session.getAttribute("studentId");
            return studentId != null && studentId.equals(experiment.getStudentId());
        }

        if ("SUPERVISOR".equals(user.getRole())) {
            String supervisorId = (String) session.getAttribute("supervisorId");
            if (supervisorId == null) {
                supervisorId = userDAO.getSupervisorId(user.getUserId());
            }
            Map<String, String> supervisorInfo = userDAO.getSupervisorByStudent(experiment.getStudentId());
            return supervisorId != null && supervisorId.equals(supervisorInfo.get("supervisorId"));
        }

        return "APPROVED".equals(experiment.getStatus());
    }

    private void writeCsv(PrintWriter out, Experiment experiment) {
        out.println("Section,Field,Value");
        row(out, "Experiment", "Experiment ID", experiment.getExperimentId());
        row(out, "Experiment", "Title", experiment.getTitle());
        row(out, "Experiment", "Student ID", experiment.getStudentId());
        row(out, "Experiment", "Student Name", experiment.getStudentName());
        row(out, "Experiment", "Date", valueOf(experiment.getExperimentDate()));
        row(out, "Experiment", "Status", experiment.getStatus());
        row(out, "Experiment", "Material Type", experiment.getMaterialType());
        row(out, "Experiment", "Concentration", experiment.getConcentration());
        row(out, "Experiment", "Study Objective", experiment.getStudyObjective());
        row(out, "Protocol", "Hypothesis", experiment.getHypothesis());
        row(out, "Protocol", "Independent Variable", experiment.getIndependentVariable());
        row(out, "Protocol", "Dependent Variable", experiment.getDependentVariable());
        row(out, "Protocol", "Controlled Variables", experiment.getControlledVariables());
        row(out, "Experiment", "Preparation Notes", experiment.getPreparationNotes());
        row(out, "Experiment", "Characterization Methods", experiment.getCharacterizationMethods());
        row(out, "Experiment", "Characterization Notes", experiment.getCharacterizationNotes());
        row(out, "Characterization", "Instrument Details", experiment.getInstrumentDetails());
        row(out, "Characterization", "Scan Range", experiment.getScanRange());
        row(out, "Characterization", "Calibration Reference", experiment.getCalibrationReference());
        row(out, "Characterization", "Replicate Count", valueOf(experiment.getReplicateCount()));
        row(out, "Characterization", "Measurement Uncertainty", experiment.getMeasurementUncertainty());
        row(out, "Characterization", "Raw Data Required", valueOf(experiment.getRawDataRequired()));
        row(out, "Conclusion", "Key Finding", experiment.getConclusion());
        row(out, "Conclusion", "Limitations", experiment.getLimitations());
        row(out, "Conclusion", "Next Steps", experiment.getNextSteps());
        row(out, "Experiment", "Supervisor Feedback", experiment.getFeedback());

        row(out, "Sample 1", "Name", experiment.getSampleOneName());
        row(out, "Sample 1", "Condition", experiment.getSampleOneCondition());
        row(out, "Sample 1", "Notes", experiment.getSampleOneNotes());
        row(out, "Sample 2", "Name", experiment.getSampleTwoName());
        row(out, "Sample 2", "Condition", experiment.getSampleTwoCondition());
        row(out, "Sample 2", "Notes", experiment.getSampleTwoNotes());
        row(out, "Sample 3", "Name", experiment.getSampleThreeName());
        row(out, "Sample 3", "Condition", experiment.getSampleThreeCondition());
        row(out, "Sample 3", "Notes", experiment.getSampleThreeNotes());

        if (experiment.getTestFiles() != null && !experiment.getTestFiles().isEmpty()) {
            for (TestData file : experiment.getTestFiles()) {
                String section = "Test Data " + file.getTestDataId();
                row(out, section, "Type", file.getTestType());
                row(out, section, "File Name", file.getFileName());
                row(out, section, "File Size", file.getFileSize());
                row(out, section, "Upload Date", valueOf(file.getUploadDate()));
            }
        }
    }

    private void row(PrintWriter out, String section, String field, String value) {
        out.println(csv(section) + "," + csv(field) + "," + csv(value));
    }

    private String csv(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "\"\"";
        }
        return "\"" + value.replace("\"", "\"\"").replace("\r\n", "\n").replace("\r", "\n") + "\"";
    }

    private String valueOf(Object value) {
        return value == null ? "" : String.valueOf(value);
    }
}
