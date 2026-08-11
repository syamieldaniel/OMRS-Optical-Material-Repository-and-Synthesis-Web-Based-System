package com.omrs.test;

import com.omrs.config.DBConnection;
import com.omrs.util.PasswordUtil;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
import java.util.Base64;

public class RepositorySampleSetup {
    private static final String DEMO_STUDENT_ID = "SREPO01";

    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ensureSchema(conn, st);
            String studentId = ensureRepositoryStudent(conn);

            upsertExperiment(conn, new SampleExperiment(
                    "EXP-006",
                    studentId,
                    "FTIR Analysis of PMMA-Silica Optical Composite",
                    "2026-06-16",
                    "PMMA-Silica Composite",
                    "1.0 wt%",
                    "SINGLE",
                    rows(
                            row("FTIR peak / feature", "Sample A: PMMA control", "Sample B: PMMA-SiO2 blend", "Sample C: PMMA-SiO2 annealed"),
                            row("C=O stretching", "1728 cm-1 strong", "1728 cm-1 retained", "1728 cm-1 sharper"),
                            row("C-O vibration", "906 cm-1 weak", "906 cm-1 visible", "906 cm-1 enhanced"),
                            row("Fingerprint peak", "759 cm-1", "759 cm-1", "759 cm-1 stable")),
                    "Evaluate FTIR transmittance changes in PMMA-silica composite films and compare the main C=O, C-O, and fingerprint-region peaks across three sample conditions.",
                    "Adding silica and annealing the composite will make the C-O related bands clearer while retaining the PMMA C=O peak near 1728 cm-1.",
                    "Composite treatment condition",
                    "FTIR peak position and relative transmittance intensity",
                    "Film casting method, substrate type, drying period, FTIR scan range, and baseline correction were kept constant.",
                    "PMMA solution was prepared and cast as a thin film. Silica was blended into the polymer matrix for the composite samples. The third sample was annealed under the same schedule before FTIR analysis.",
                    "FTIR",
                    "The attached FTIR spectrum shows three stacked transmittance traces. The C=O feature around 1728 cm-1 remains visible, while C-O related features near 906 cm-1 and the 759 cm-1 fingerprint region support comparison of bonding changes.",
                    "FTIR spectrometer in transmittance mode; spectra exported as an image for repository review.",
                    "4000-500 cm-1",
                    "Background/baseline correction was applied before comparing the three spectra.",
                    3,
                    "Peak positions estimated visually from the provided spectrum.",
                    true,
                    "The PMMA-silica composite keeps the main C=O band and shows clearer C-O/fingerprint-region features after treatment, suggesting interaction between PMMA and silica phases.",
                    "The attached file is an image of the FTIR graph, so exact peak intensity values should be confirmed from raw spectral data.",
                    "Upload raw FTIR CSV data and repeat the scan with controlled film thickness for more accurate quantitative comparison.",
                    "Sample A", "PMMA control film", "Baseline trace used to compare the polymer C=O peak and fingerprint region.",
                    "Sample B", "PMMA-silica blended film", "Composite trace with visible C-O related features.",
                    "Sample C", "Annealed PMMA-silica film", "Annealed composite trace with sharper peak features.",
                    "Ready repository example with FTIR evidence image and complete characterization metadata."));

            upsertTestData(conn, "TD-005", "EXP-006", "FTIR", "sampleftir.jpg", "/uploads/EXP-006/sampleftir.jpg", "24 KB");

            upsertExperiment(conn, new SampleExperiment(
                    "EXP-007",
                    studentId,
                    "UV-Vis Band Gap Study of ZnO Nanorod Optical Film",
                    "2026-06-18",
                    "ZnO Nanorod Film",
                    "25 mM growth solution",
                    "SINGLE",
                    rows(
                            row("Optical parameter", "Measured value", "Interpretation", "Evidence file"),
                            row("Absorption edge", "~365 nm", "ZnO near-UV absorption", "UV-Vis spectrum image"),
                            row("Visible absorbance", "<0.20 a.u. above 600 nm", "High visible transparency", "Raw CSV"),
                            row("Estimated band gap", "~3.30 eV", "Consistent with ZnO nanostructure", "Tauc analysis notes")),
                    "Determine the optical absorption edge and visible-region transparency of a hydrothermally grown ZnO nanorod film for repository comparison.",
                    "The ZnO nanorod film will show strong near-UV absorption with a band gap close to 3.3 eV and low absorbance in the visible region.",
                    "Wavelength of incident light",
                    "UV-Vis absorbance and estimated optical band gap",
                    "Substrate type, seed layer, growth time, solution molarity, scan speed, and baseline correction were kept constant.",
                    "A seeded glass substrate was immersed in zinc nitrate and HMTA growth solution, rinsed with deionized water, dried at 70 C, and measured after cooling.",
                    "UV-VIS",
                    "The UV-Vis image shows a steep absorption edge around 365 nm and progressively lower absorbance at longer wavelengths. The CSV file provides the plotted absorbance values.",
                    "Double-beam UV-Vis spectrophotometer; baseline corrected using bare glass substrate.",
                    "300-900 nm",
                    "Bare glass substrate reference and air baseline were used before sample measurement.",
                    3,
                    "Wavelength accuracy +/-1 nm; absorbance repeatability +/-0.02 a.u.",
                    true,
                    "The ZnO nanorod film produced a clear near-UV absorption edge and low visible absorbance, supporting its suitability for transparent optical or DSSC photoanode studies.",
                    "Band gap was estimated from plotted data and should be refined with full Tauc extrapolation from raw spectral exports.",
                    "Repeat the analysis with different growth times and compare nanorod density using SEM.",
                    "Sample A", "Seeded glass control", "Used for baseline correction and substrate comparison.",
                    "Sample B", "ZnO nanorod film", "Hydrothermally grown nanorod layer used for UV-Vis measurement.",
                    "Sample C", "Annealed ZnO film", "Proposed follow-up condition for crystallinity comparison.",
                    "Approved complete UV-Vis repository sample with spectrum image and raw CSV attachment."));

            upsertTestData(conn, "TD-007", "EXP-007", "UV-VIS", "zno_uvvis_spectrum.svg", "/uploads/EXP-007/zno_uvvis_spectrum.svg", "7 KB");
            upsertTestData(conn, "TD-008", "EXP-007", "UV-VIS", "zno_uvvis_raw.csv", "/uploads/EXP-007/zno_uvvis_raw.csv", "198 bytes");

            upsertExperiment(conn, new SampleExperiment(
                    "EXP-008",
                    studentId,
                    "SEM Morphology of TiO2 Natural Dye DSSC Photoanode",
                    "2026-06-20",
                    "TiO2 Natural Dye DSSC",
                    "Doctor-bladed TiO2 paste",
                    "SINGLE",
                    rows(
                            row("Morphology metric", "Observed value", "Effect on DSSC layer", "Evidence file"),
                            row("Average particle diameter", "~82 nm", "Supports dye adsorption surface area", "SEM morphology image"),
                            row("Estimated porosity", "~38%", "Allows electrolyte penetration", "Particle summary CSV"),
                            row("Aggregation level", "Moderate", "May reduce uniform charge transport", "SEM morphology image")),
                    "Assess the surface morphology and porosity of a TiO2 photoanode coated for natural dye-sensitized solar cell preparation.",
                    "A porous TiO2 nanoparticle network will improve dye adsorption and electrolyte access, but excessive aggregation may reduce charge transport.",
                    "TiO2 film coating and sintering condition",
                    "Particle morphology, porosity, and aggregation level",
                    "Substrate size, paste batch, coating blade gap, drying period, and sintering temperature profile were kept constant.",
                    "TiO2 paste was doctor-bladed onto conductive glass, dried, sintered, and sensitized with natural dye extract before morphology documentation.",
                    "SEM",
                    "The SEM characterization image shows a porous nanoparticle network with moderate aggregation. The CSV summary records estimated particle diameter and porosity observations.",
                    "SEM operated at 5 kV accelerating voltage with 50,000x magnification; image exported for repository viewing.",
                    "500 nm scale bar field of view",
                    "Magnification and scale bar were checked against the SEM instrument calibration before export.",
                    2,
                    "Particle diameter estimated from representative regions; uncertainty about +/-10 nm.",
                    true,
                    "The TiO2 film shows a porous network suitable for dye uptake, with moderate aggregation that should be optimized for improved DSSC charge transport.",
                    "The SEM image is representative and should be supported by multiple field-of-view images for formal morphology statistics.",
                    "Compare sintering temperatures and add cross-sectional SEM to evaluate film thickness.",
                    "Sample A", "Unsensitized TiO2 film", "Reference morphology before dye immersion.",
                    "Sample B", "Natural dye-sensitized TiO2", "Main sample shown in SEM image.",
                    "Sample C", "Post-rinse sensitized film", "Follow-up sample for dye retention comparison.",
                    "Approved complete SEM repository sample with morphology image and particle summary attachment."));

            upsertTestData(conn, "TD-009", "EXP-008", "SEM", "tio2_sem_morphology.svg", "/uploads/EXP-008/tio2_sem_morphology.svg", "8 KB");
            upsertTestData(conn, "TD-010", "EXP-008", "SEM", "tio2_particle_summary.csv", "/uploads/EXP-008/tio2_particle_summary.csv", "154 bytes");

            System.out.println("Repository samples EXP-006, EXP-007, and EXP-008 are ready for student " + studentId + ".");
        } catch (Exception e) {
            System.out.println("Repository sample setup failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void ensureSchema(Connection conn, Statement st) throws Exception {
        st.executeUpdate("ALTER TABLE test_data MODIFY COLUMN test_type VARCHAR(50) NOT NULL");
        addColumnIfMissing(conn, st, "experiments", "study_type", "VARCHAR(30) DEFAULT 'SINGLE'");
        addColumnIfMissing(conn, st, "experiments", "comparison_table_data", "TEXT NULL");
        addColumnIfMissing(conn, st, "experiments", "hypothesis", "TEXT NULL");
        addColumnIfMissing(conn, st, "experiments", "independent_variable", "VARCHAR(255) NULL");
        addColumnIfMissing(conn, st, "experiments", "dependent_variable", "VARCHAR(255) NULL");
        addColumnIfMissing(conn, st, "experiments", "controlled_variables", "TEXT NULL");
        addColumnIfMissing(conn, st, "experiments", "instrument_details", "TEXT NULL");
        addColumnIfMissing(conn, st, "experiments", "scan_range", "VARCHAR(255) NULL");
        addColumnIfMissing(conn, st, "experiments", "calibration_reference", "TEXT NULL");
        addColumnIfMissing(conn, st, "experiments", "replicate_count", "INT NULL");
        addColumnIfMissing(conn, st, "experiments", "measurement_uncertainty", "VARCHAR(255) NULL");
        addColumnIfMissing(conn, st, "experiments", "raw_data_required", "BOOLEAN NULL");
        addColumnIfMissing(conn, st, "experiments", "conclusion", "TEXT NULL");
        addColumnIfMissing(conn, st, "experiments", "limitations", "TEXT NULL");
        addColumnIfMissing(conn, st, "experiments", "next_steps", "TEXT NULL");
        addColumnIfMissing(conn, st, "students", "student_type", "ENUM('NORMAL','FYP') DEFAULT 'NORMAL'");
        st.executeUpdate("ALTER TABLE students MODIFY supervisor_id VARCHAR(20) NULL");
    }

    private static void addColumnIfMissing(Connection conn, Statement st, String tableName, String columnName, String definition) throws Exception {
        DatabaseMetaData meta = conn.getMetaData();
        try (ResultSet rs = meta.getColumns(null, null, tableName, columnName)) {
            if (!rs.next()) {
                st.executeUpdate("ALTER TABLE " + tableName + " ADD COLUMN " + columnName + " " + definition);
            }
        }
    }

    private static String ensureRepositoryStudent(Connection conn) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement("SELECT student_id FROM students WHERE student_id = ?")) {
            ps.setString(1, DEMO_STUDENT_ID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return DEMO_STUDENT_ID;
            }
        }

        Integer userId = null;
        try (PreparedStatement ps = conn.prepareStatement("SELECT user_id FROM users WHERE username = ?")) {
            ps.setString(1, "repository.demo");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                userId = rs.getInt("user_id");
            }
        }

        if (userId == null) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO users (username, password, email, full_name, role, status) VALUES (?, ?, ?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, "repository.demo");
                ps.setString(2, PasswordUtil.hash("RepositoryDemo123"));
                ps.setString(3, "repository.demo@omrs.local");
                ps.setString(4, "Repository Demo Student");
                ps.setString(5, "STUDENT");
                ps.setString(6, "APPROVED");
                ps.executeUpdate();
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    userId = keys.getInt(1);
                }
            }
        }

        if (userId == null) {
            throw new IllegalStateException("Unable to create repository demo student user.");
        }

        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO students (student_id, user_id, student_type, supervisor_id) VALUES (?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE user_id = VALUES(user_id), student_type = VALUES(student_type)")) {
            ps.setString(1, DEMO_STUDENT_ID);
            ps.setInt(2, userId);
            ps.setString(3, "NORMAL");
            ps.setNull(4, Types.VARCHAR);
            ps.executeUpdate();
        }

        return DEMO_STUDENT_ID;
    }

    private static void upsertExperiment(Connection conn, SampleExperiment e) throws Exception {
        String sql =
                "INSERT INTO experiments (" +
                "experiment_id, student_id, title, experiment_date, material_type, concentration, study_type, " +
                "comparison_table_data, study_objective, hypothesis, independent_variable, dependent_variable, controlled_variables, " +
                "preparation_notes, characterization_methods, characterization_notes, instrument_details, scan_range, calibration_reference, " +
                "replicate_count, measurement_uncertainty, raw_data_required, conclusion, limitations, next_steps, " +
                "sample_1_name, sample_1_condition, sample_1_notes, sample_2_name, sample_2_condition, sample_2_notes, " +
                "sample_3_name, sample_3_condition, sample_3_notes, status, feedback" +
                ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) " +
                "ON DUPLICATE KEY UPDATE title=VALUES(title), experiment_date=VALUES(experiment_date), material_type=VALUES(material_type), " +
                "concentration=VALUES(concentration), study_type=VALUES(study_type), comparison_table_data=VALUES(comparison_table_data), " +
                "study_objective=VALUES(study_objective), hypothesis=VALUES(hypothesis), independent_variable=VALUES(independent_variable), " +
                "dependent_variable=VALUES(dependent_variable), controlled_variables=VALUES(controlled_variables), preparation_notes=VALUES(preparation_notes), " +
                "characterization_methods=VALUES(characterization_methods), characterization_notes=VALUES(characterization_notes), instrument_details=VALUES(instrument_details), " +
                "scan_range=VALUES(scan_range), calibration_reference=VALUES(calibration_reference), replicate_count=VALUES(replicate_count), " +
                "measurement_uncertainty=VALUES(measurement_uncertainty), raw_data_required=VALUES(raw_data_required), conclusion=VALUES(conclusion), " +
                "limitations=VALUES(limitations), next_steps=VALUES(next_steps), sample_1_name=VALUES(sample_1_name), sample_1_condition=VALUES(sample_1_condition), " +
                "sample_1_notes=VALUES(sample_1_notes), sample_2_name=VALUES(sample_2_name), sample_2_condition=VALUES(sample_2_condition), " +
                "sample_2_notes=VALUES(sample_2_notes), sample_3_name=VALUES(sample_3_name), sample_3_condition=VALUES(sample_3_condition), " +
                "sample_3_notes=VALUES(sample_3_notes), status=VALUES(status), feedback=VALUES(feedback)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            ps.setString(i++, e.id);
            ps.setString(i++, e.studentId);
            ps.setString(i++, e.title);
            ps.setDate(i++, java.sql.Date.valueOf(e.date));
            ps.setString(i++, e.materialType);
            ps.setString(i++, e.concentration);
            ps.setString(i++, e.studyType);
            ps.setString(i++, e.tableData);
            ps.setString(i++, e.objective);
            ps.setString(i++, e.hypothesis);
            ps.setString(i++, e.independentVariable);
            ps.setString(i++, e.dependentVariable);
            ps.setString(i++, e.controlledVariables);
            ps.setString(i++, e.preparationNotes);
            ps.setString(i++, e.characterizationMethods);
            ps.setString(i++, e.characterizationNotes);
            ps.setString(i++, e.instrumentDetails);
            ps.setString(i++, e.scanRange);
            ps.setString(i++, e.calibrationReference);
            ps.setInt(i++, e.replicateCount);
            ps.setString(i++, e.measurementUncertainty);
            ps.setBoolean(i++, e.rawDataRequired);
            ps.setString(i++, e.conclusion);
            ps.setString(i++, e.limitations);
            ps.setString(i++, e.nextSteps);
            ps.setString(i++, e.sampleOneName);
            ps.setString(i++, e.sampleOneCondition);
            ps.setString(i++, e.sampleOneNotes);
            ps.setString(i++, e.sampleTwoName);
            ps.setString(i++, e.sampleTwoCondition);
            ps.setString(i++, e.sampleTwoNotes);
            ps.setString(i++, e.sampleThreeName);
            ps.setString(i++, e.sampleThreeCondition);
            ps.setString(i++, e.sampleThreeNotes);
            ps.setString(i++, "APPROVED");
            ps.setString(i, e.feedback);
            ps.executeUpdate();
        }
    }

    private static void upsertTestData(Connection conn, String id, String experimentId, String testType,
                                       String fileName, String filePath, String fileSize) throws Exception {
        String sql =
                "INSERT INTO test_data (test_data_id, experiment_id, test_type, file_name, file_path, file_size) " +
                "VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE test_type=VALUES(test_type), file_name=VALUES(file_name), " +
                "file_path=VALUES(file_path), file_size=VALUES(file_size)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, experimentId);
            ps.setString(3, testType);
            ps.setString(4, fileName);
            ps.setString(5, filePath);
            ps.setString(6, fileSize);
            ps.executeUpdate();
        }
    }

    private static String[] row(String... cells) {
        return cells;
    }

    private static String rows(String[]... rows) {
        StringBuilder out = new StringBuilder();
        for (int r = 0; r < rows.length; r++) {
            if (r > 0) out.append("\n");
            for (int c = 0; c < rows[r].length; c++) {
                if (c > 0) out.append("\t");
                out.append(Base64.getEncoder().encodeToString(rows[r][c].getBytes(StandardCharsets.UTF_8)));
            }
        }
        return out.toString();
    }

    private static class SampleExperiment {
        final String id;
        final String studentId;
        final String title;
        final String date;
        final String materialType;
        final String concentration;
        final String studyType;
        final String tableData;
        final String objective;
        final String hypothesis;
        final String independentVariable;
        final String dependentVariable;
        final String controlledVariables;
        final String preparationNotes;
        final String characterizationMethods;
        final String characterizationNotes;
        final String instrumentDetails;
        final String scanRange;
        final String calibrationReference;
        final int replicateCount;
        final String measurementUncertainty;
        final boolean rawDataRequired;
        final String conclusion;
        final String limitations;
        final String nextSteps;
        final String sampleOneName;
        final String sampleOneCondition;
        final String sampleOneNotes;
        final String sampleTwoName;
        final String sampleTwoCondition;
        final String sampleTwoNotes;
        final String sampleThreeName;
        final String sampleThreeCondition;
        final String sampleThreeNotes;
        final String feedback;

        SampleExperiment(String id, String studentId, String title, String date, String materialType, String concentration,
                         String studyType, String tableData, String objective, String hypothesis, String independentVariable,
                         String dependentVariable, String controlledVariables, String preparationNotes, String characterizationMethods,
                         String characterizationNotes, String instrumentDetails, String scanRange, String calibrationReference,
                         int replicateCount, String measurementUncertainty, boolean rawDataRequired, String conclusion,
                         String limitations, String nextSteps, String sampleOneName, String sampleOneCondition,
                         String sampleOneNotes, String sampleTwoName, String sampleTwoCondition, String sampleTwoNotes,
                         String sampleThreeName, String sampleThreeCondition, String sampleThreeNotes, String feedback) {
            this.id = id;
            this.studentId = studentId;
            this.title = title;
            this.date = date;
            this.materialType = materialType;
            this.concentration = concentration;
            this.studyType = studyType;
            this.tableData = tableData;
            this.objective = objective;
            this.hypothesis = hypothesis;
            this.independentVariable = independentVariable;
            this.dependentVariable = dependentVariable;
            this.controlledVariables = controlledVariables;
            this.preparationNotes = preparationNotes;
            this.characterizationMethods = characterizationMethods;
            this.characterizationNotes = characterizationNotes;
            this.instrumentDetails = instrumentDetails;
            this.scanRange = scanRange;
            this.calibrationReference = calibrationReference;
            this.replicateCount = replicateCount;
            this.measurementUncertainty = measurementUncertainty;
            this.rawDataRequired = rawDataRequired;
            this.conclusion = conclusion;
            this.limitations = limitations;
            this.nextSteps = nextSteps;
            this.sampleOneName = sampleOneName;
            this.sampleOneCondition = sampleOneCondition;
            this.sampleOneNotes = sampleOneNotes;
            this.sampleTwoName = sampleTwoName;
            this.sampleTwoCondition = sampleTwoCondition;
            this.sampleTwoNotes = sampleTwoNotes;
            this.sampleThreeName = sampleThreeName;
            this.sampleThreeCondition = sampleThreeCondition;
            this.sampleThreeNotes = sampleThreeNotes;
            this.feedback = feedback;
        }
    }
}
