/*
 * OMRS Thesis Code Excerpt
 * Feature: Student Optical Material Study Creation
 *
 * This documentation-only file combines the main MVC workflow used in OMRS:
 * 1. StudentServlet receives and validates the experiment form.
 * 2. Experiment model stores optical study details.
 * 3. ExperimentDAO saves the study record using PreparedStatement.
 *
 * Source files represented:
 * - src/java/com/omrs/servlet/StudentServlet.java
 * - src/java/com/omrs/model/Experiment.java
 * - src/java/com/omrs/dao/ExperimentDAO.java
 */

package com.omrs.thesis;

import com.omrs.config.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.util.Arrays;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/student/create")
@MultipartConfig(maxFileSize = 16177215)
public class ExperimentCreationWorkflow extends HttpServlet {
    private final ExperimentDAO experimentDAO = new ExperimentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String title = request.getParameter("title");
        String date = request.getParameter("date");
        String materialType = request.getParameter("materialType");
        String action = request.getParameter("action");

        if (isBlank(title) || isBlank(date) || isBlank(materialType)) {
            request.setAttribute("error", "Title, date and material type are required.");
            request.getRequestDispatcher("/pages/student/create.jsp").forward(request, response);
            return;
        }

        Experiment experiment = new Experiment();
        experiment.setExperimentId(experimentDAO.generateId());
        experiment.setStudentId((String) session.getAttribute("studentId"));
        experiment.setTitle(title.trim());
        experiment.setExperimentDate(Date.valueOf(date));
        experiment.setMaterialType(resolveMaterialType(
                materialType,
                request.getParameter("customMaterial")
        ));
        experiment.setConcentration(buildConcentration(
                request.getParameter("concentrationAmount"),
                request.getParameter("concentrationUnit"),
                request.getParameter("concentrationUnitOther")
        ));
        experiment.setStudyObjective(trimToNull(request.getParameter("studyObjective")));
        experiment.setPreparationNotes(trimToNull(request.getParameter("preparationNotes")));
        experiment.setCharacterizationMethods(buildMethods(
                request.getParameterValues("characterizationMethods")
        ));
        experiment.setSampleOneName(trimToNull(request.getParameter("sampleOneName")));
        experiment.setSampleTwoName(trimToNull(request.getParameter("sampleTwoName")));
        experiment.setSampleThreeName(trimToNull(request.getParameter("sampleThreeName")));
        experiment.setStatus("submit".equals(action) ? "PENDING" : "DRAFT");

        if (experimentDAO.create(experiment)) {
            response.sendRedirect(request.getContextPath()
                    + "/student/view/" + experiment.getExperimentId());
        } else {
            request.setAttribute("error", "Failed to save experiment.");
            request.getRequestDispatcher("/pages/student/create.jsp").forward(request, response);
        }
    }

    private String resolveMaterialType(String selected, String customMaterial) {
        if ("Other".equals(selected)) {
            return trimToNull(customMaterial);
        }
        return trimToNull(selected);
    }

    private String buildConcentration(String amount, String unit, String otherUnit) {
        String selectedUnit = "Other".equals(unit) ? otherUnit : unit;
        if (isBlank(amount) && isBlank(selectedUnit)) return null;
        if (isBlank(selectedUnit)) return amount.trim();
        if (isBlank(amount)) return selectedUnit.trim();
        return amount.trim() + " " + selectedUnit.trim();
    }

    private String buildMethods(String[] selectedMethods) {
        if (selectedMethods == null || selectedMethods.length == 0) {
            return null;
        }
        return String.join(", ", Arrays.asList(selectedMethods));
    }

    private String trimToNull(String value) {
        return isBlank(value) ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static class Experiment {
        private String experimentId;
        private String studentId;
        private String title;
        private Date experimentDate;
        private String materialType;
        private String concentration;
        private String studyObjective;
        private String preparationNotes;
        private String characterizationMethods;
        private String sampleOneName;
        private String sampleTwoName;
        private String sampleThreeName;
        private String status;

        public String getExperimentId() { return experimentId; }
        public void setExperimentId(String experimentId) { this.experimentId = experimentId; }
        public String getStudentId() { return studentId; }
        public void setStudentId(String studentId) { this.studentId = studentId; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public Date getExperimentDate() { return experimentDate; }
        public void setExperimentDate(Date experimentDate) { this.experimentDate = experimentDate; }
        public String getMaterialType() { return materialType; }
        public void setMaterialType(String materialType) { this.materialType = materialType; }
        public String getConcentration() { return concentration; }
        public void setConcentration(String concentration) { this.concentration = concentration; }
        public String getStudyObjective() { return studyObjective; }
        public void setStudyObjective(String studyObjective) { this.studyObjective = studyObjective; }
        public String getPreparationNotes() { return preparationNotes; }
        public void setPreparationNotes(String preparationNotes) { this.preparationNotes = preparationNotes; }
        public String getCharacterizationMethods() { return characterizationMethods; }
        public void setCharacterizationMethods(String characterizationMethods) { this.characterizationMethods = characterizationMethods; }
        public String getSampleOneName() { return sampleOneName; }
        public void setSampleOneName(String sampleOneName) { this.sampleOneName = sampleOneName; }
        public String getSampleTwoName() { return sampleTwoName; }
        public void setSampleTwoName(String sampleTwoName) { this.sampleTwoName = sampleTwoName; }
        public String getSampleThreeName() { return sampleThreeName; }
        public void setSampleThreeName(String sampleThreeName) { this.sampleThreeName = sampleThreeName; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
    }

    public static class ExperimentDAO {
        public String generateId() {
            return "EXP" + System.currentTimeMillis();
        }

        public boolean create(Experiment experiment) {
            String sql = "INSERT INTO experiments "
                    + "(experiment_id, student_id, title, experiment_date, material_type, "
                    + "concentration, study_objective, preparation_notes, "
                    + "characterization_methods, sample_1_name, sample_2_name, "
                    + "sample_3_name, status) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement statement = connection.prepareStatement(sql)) {

                statement.setString(1, experiment.getExperimentId());
                statement.setString(2, experiment.getStudentId());
                statement.setString(3, experiment.getTitle());
                statement.setDate(4, experiment.getExperimentDate());
                statement.setString(5, experiment.getMaterialType());
                statement.setString(6, experiment.getConcentration());
                statement.setString(7, experiment.getStudyObjective());
                statement.setString(8, experiment.getPreparationNotes());
                statement.setString(9, experiment.getCharacterizationMethods());
                statement.setString(10, experiment.getSampleOneName());
                statement.setString(11, experiment.getSampleTwoName());
                statement.setString(12, experiment.getSampleThreeName());
                statement.setString(13, experiment.getStatus());

                return statement.executeUpdate() > 0;
            } catch (Exception exception) {
                exception.printStackTrace();
                return false;
            }
        }
    }
}
