-- OMRS Database Setup
-- Run this in phpMyAdmin

-- If database exists, drop and recreate or run ALTER
-- ALTER TABLE users ADD COLUMN status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING';
-- UPDATE users SET status = 'APPROVED' WHERE status IS NULL;

DROP DATABASE IF EXISTS omrs_db;
CREATE DATABASE IF NOT EXISTS omrs_db;
USE omrs_db;

-- Users Table
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    profile_picture VARCHAR(500),
    role ENUM('STUDENT', 'SUPERVISOR', 'RESEARCHER') NOT NULL,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Supervisors Table
CREATE TABLE supervisors (
    supervisor_id VARCHAR(20) PRIMARY KEY,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Students Table
CREATE TABLE students (
    student_id VARCHAR(20) PRIMARY KEY,
    user_id INT NOT NULL,
    student_type ENUM('NORMAL', 'FYP') DEFAULT 'NORMAL',
    supervisor_id VARCHAR(20) NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (supervisor_id) REFERENCES supervisors(supervisor_id)
);

-- Experiments Table
CREATE TABLE experiments (
    experiment_id VARCHAR(20) PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL,
    title VARCHAR(255) NOT NULL,
    experiment_date DATE NOT NULL,
    material_type VARCHAR(100) NOT NULL,
    concentration VARCHAR(50),
    study_type VARCHAR(30) DEFAULT 'SINGLE',
    material_b_type VARCHAR(100),
    material_b_concentration VARCHAR(50),
    comparison_metric_label VARCHAR(120),
    material_a_metric_value DOUBLE,
    material_b_metric_value DOUBLE,
    comparison_notes TEXT,
    comparison_table_data TEXT,
    study_objective TEXT,
    hypothesis TEXT,
    independent_variable VARCHAR(255),
    dependent_variable VARCHAR(255),
    controlled_variables TEXT,
    preparation_notes TEXT,
    characterization_methods TEXT,
    characterization_notes TEXT,
    instrument_details TEXT,
    scan_range VARCHAR(255),
    calibration_reference TEXT,
    replicate_count INT,
    measurement_uncertainty VARCHAR(255),
    raw_data_required BOOLEAN DEFAULT FALSE,
    conclusion TEXT,
    limitations TEXT,
    next_steps TEXT,
    sample_1_name VARCHAR(120),
    sample_1_condition VARCHAR(255),
    sample_1_notes TEXT,
    sample_2_name VARCHAR(120),
    sample_2_condition VARCHAR(255),
    sample_2_notes TEXT,
    sample_3_name VARCHAR(120),
    sample_3_condition VARCHAR(255),
    sample_3_notes TEXT,
    status ENUM('DRAFT', 'PENDING', 'APPROVED', 'REJECTED') DEFAULT 'DRAFT',
    feedback TEXT,
    has_test_files BOOLEAN DEFAULT FALSE,
    file_count INT DEFAULT 0,
    last_file_upload_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- Test Data Table
CREATE TABLE test_data (
    test_data_id VARCHAR(20) PRIMARY KEY,
    experiment_id VARCHAR(20) NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size VARCHAR(50),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (experiment_id) REFERENCES experiments(experiment_id) ON DELETE CASCADE
);

-- Learning Materials Table
CREATE TABLE learning_materials (
    material_id VARCHAR(20) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    content TEXT,
    external_link VARCHAR(500),
    file_name VARCHAR(255),
    file_path VARCHAR(500),
    uploaded_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Repository Comments Table
CREATE TABLE repository_comments (
    comment_id VARCHAR(20) PRIMARY KEY,
    experiment_id VARCHAR(20) NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (experiment_id) REFERENCES experiments(experiment_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Notifications Table
CREATE TABLE notifications (
    notification_id VARCHAR(20) PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    link_url VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Learning Quizzes Table
CREATE TABLE learning_quizzes (
    quiz_id VARCHAR(20) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    uploaded_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Learning Quiz Questions Table
CREATE TABLE learning_quiz_questions (
    question_id VARCHAR(20) PRIMARY KEY,
    quiz_id VARCHAR(20) NOT NULL,
    question_order INT NOT NULL,
    question_text TEXT NOT NULL,
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_option CHAR(1) NOT NULL,
    explanation TEXT,
    FOREIGN KEY (quiz_id) REFERENCES learning_quizzes(quiz_id) ON DELETE CASCADE
);

-- Learning Quiz Attempts Table
CREATE TABLE learning_quiz_attempts (
    attempt_id VARCHAR(20) PRIMARY KEY,
    quiz_id VARCHAR(20) NOT NULL,
    user_id INT NOT NULL,
    score INT NOT NULL,
    total_questions INT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quiz_id) REFERENCES learning_quizzes(quiz_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Logbook Weekly Table
CREATE TABLE logbooks (
    logbook_id VARCHAR(20) PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL,
    month VARCHAR(7) NOT NULL,
    week INT NOT NULL,
    activities TEXT,
    supervisor_notes TEXT,
    supervisor_signature VARCHAR(255),
    supervisor_name VARCHAR(255),
    approved_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_student_month_week (student_id, month, week),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- INSERT SAMPLE DATA

-- Supervisors
-- Sample password hashes are PBKDF2 values generated by the application.
INSERT INTO users (username, password, email, full_name, role, status) VALUES 
('draizat', 'pbkdf2$120000$ABy6bHx7lGJroekP2FgV/g==$IjsBRAYmuNx3EyIziPdmfKP1Hn/PgvgqVabdAjHMAzw=', 'aizat@umt.edu.my', 'Dr. Aizat Rahman', 'SUPERVISOR', 'APPROVED'),
('drnora', 'pbkdf2$120000$ABy6bHx7lGJroekP2FgV/g==$IjsBRAYmuNx3EyIziPdmfKP1Hn/PgvgqVabdAjHMAzw=', 'nora@umt.edu.my', 'Dr. Nora Ismail', 'SUPERVISOR', 'APPROVED'),
('drfarid', 'pbkdf2$120000$ABy6bHx7lGJroekP2FgV/g==$IjsBRAYmuNx3EyIziPdmfKP1Hn/PgvgqVabdAjHMAzw=', 'farid@umt.edu.my', 'Dr. Farid Hassan', 'SUPERVISOR', 'APPROVED'),
('drsiti', 'pbkdf2$120000$ABy6bHx7lGJroekP2FgV/g==$IjsBRAYmuNx3EyIziPdmfKP1Hn/PgvgqVabdAjHMAzw=', 'siti@umt.edu.my', 'Dr. Siti Aminah', 'SUPERVISOR', 'APPROVED'),
('drlee', 'pbkdf2$120000$ABy6bHx7lGJroekP2FgV/g==$IjsBRAYmuNx3EyIziPdmfKP1Hn/PgvgqVabdAjHMAzw=', 'lee@umt.edu.my', 'Dr. Lee Wei Ming', 'SUPERVISOR', 'APPROVED');

INSERT INTO supervisors (supervisor_id, user_id) VALUES 
('SV001', 1),
('SV002', 2),
('SV003', 3),
('SV004', 4),
('SV005', 5);

-- Students
INSERT INTO users (username, password, email, role, status) VALUES 
('ahmad', 'pbkdf2$120000$yQ/hIWcwksb99HrXQFlJvw==$KtB5/n44IU0y/qTaxJwXchedWSGQ1AQKwCiIdgSMI4M=', 'ahmad@umt.edu.my', 'STUDENT', 'APPROVED'),
('DanishYum', 'pbkdf2$120000$olELg+LYVC8/BoJPaHpflw==$lbTLJs5ZAAAhKyA0dloOAHGbE4xRCwWotJvf3gilfAE=', 'danish@umt.edu.my', 'STUDENT', 'APPROVED'),
('Miel', 'pbkdf2$120000$BprinL3vBwtyGMVW10p3kg==$OoDNwtm393+kkvnS82kNvzmHtczJwXhQCfMwTBBv6jI=', 'miel@umt.edu.my', 'STUDENT', 'APPROVED'),
('aliph', 'pbkdf2$120000$+0DYi8MJQAaLdFZuZDsvOw==$Z/R0QeO50i1qzE/FTAruu3V8hpU9pJt0DkKqh7QqGII=', 'alif@umt.edu.my', 'STUDENT', 'APPROVED');

INSERT INTO students (student_id, user_id, supervisor_id) VALUES 
('S71964', 6, 'SV001'),
('S71619', 7, 'SV002'),
('S71965', 8, 'SV003'),
('S73821', 9, 'SV004');

UPDATE students SET student_type = 'FYP' WHERE supervisor_id IS NOT NULL;

-- Sample Experiments
INSERT INTO experiments (
    experiment_id, student_id, title, experiment_date, material_type, concentration, study_objective, preparation_notes,
    characterization_methods, characterization_notes, sample_1_name, sample_1_condition, sample_1_notes,
    sample_2_name, sample_2_condition, sample_2_notes, sample_3_name, sample_3_condition, sample_3_notes, status, feedback
) VALUES
('EXP-001', 'S71964', 'Silica Nanoparticle Synthesis', '2024-01-15', 'Silica', '0.5 M', 'Compare three silica nanoparticle preparation batches.', 'Sol-gel method at room temperature.', 'FTIR, SEM', 'Analyze particle surface bonding and morphology across all three batches.', 'Batch A', 'Drying time 2 hours', 'Baseline synthesis condition.', 'Batch B', 'Drying time 4 hours', 'Extended drying to compare morphology.', 'Batch C', 'Drying time 6 hours', 'Longest drying window for trend comparison.', 'APPROVED', 'Good work!'),
('EXP-002', 'S71964', 'PMMA Polymer Characterization', '2024-01-20', 'PMMA', '1.0 M', 'Study PMMA films under three curing conditions.', 'Dissolved in acetone.', 'SEM, UV-Vis', 'Check surface uniformity and optical transparency.', 'Film 1', 'Room-temperature cure', 'Reference PMMA film.', 'Film 2', '50 C cure', 'Moderate thermal treatment.', 'Film 3', '70 C cure', 'Higher cure temperature for comparison.', 'PENDING', NULL),
('EXP-003', 'S71964', 'Zinc Oxide Thin Film', '2024-01-18', 'Zinc Oxide', '0.75 M', 'Evaluate ZnO thin films grown at three times.', 'Spray pyrolysis technique.', 'XRD, SEM, UV-Vis', 'Observe crystal orientation and optical response.', 'ZnO-2h', 'Growth time 2 hours', 'Shortest deposition cycle.', 'ZnO-3h', 'Growth time 3 hours', 'Intermediate growth cycle.', 'ZnO-5h', 'Growth time 5 hours', 'Longest growth cycle.', 'DRAFT', NULL),
('EXP-004', 'S71964', 'Titanium Dioxide Photocatalyst', '2024-01-10', 'Titanium Dioxide', '0.3 M', 'Test three annealing conditions for TiO2 powder.', 'Hydrothermal method.', 'XRD, FTIR', 'Verify phase formation after annealing.', 'Anneal-A', '400 C for 1 hour', 'Lower temperature condition.', 'Anneal-B', '500 C for 1 hour', 'Mid temperature condition.', 'Anneal-C', '600 C for 1 hour', 'Highest temperature condition.', 'REJECTED', 'Temperature too high.');

-- Complete two-material comparison example with graph values
INSERT INTO experiments (
    experiment_id, student_id, title, experiment_date, material_type, concentration, study_type,
    material_b_type, material_b_concentration, comparison_metric_label, material_a_metric_value,
    material_b_metric_value, comparison_notes, study_objective, preparation_notes,
    characterization_methods, characterization_notes, sample_1_name, sample_1_condition, sample_1_notes,
    sample_2_name, sample_2_condition, sample_2_notes, sample_3_name, sample_3_condition, sample_3_notes, status, feedback
) VALUES
('EXP-005', 'S71964', 'ZnO vs TiO2 Optical Band Gap Comparison', '2026-05-19', 'Zinc Oxide', '0.5 M',
'COMPARISON', 'Titanium Dioxide', '0.5 M', 'Optical band gap (eV)', 3.21, 3.05,
'ZnO shows a slightly higher optical band gap than TiO2 under the same concentration and annealing condition. The comparison suggests ZnO may be more suitable where a wider band gap and stronger UV response are required.',
'Compare ZnO and TiO2 thin films prepared under the same concentration and annealing condition to evaluate optical band gap differences.',
'Both precursor solutions were prepared at 0.5 M. Glass substrates were cleaned with acetone, ethanol, and deionized water. Films were deposited using the same coating cycle and annealed at 450 C for 1 hour before characterization.',
'UV-Vis, FTIR, SEM',
'UV-Vis spectra were used to estimate band gap values. FTIR confirmed bonding signatures, while SEM was used to compare surface morphology between both films.',
'ZnO film', '0.5 M ZnO annealed at 450 C for 1 hour', 'Higher estimated band gap and clear UV absorption edge.',
'TiO2 film', '0.5 M TiO2 annealed at 450 C for 1 hour', 'Slightly lower estimated band gap with stable optical response.',
'Shared control', 'Same substrate cleaning, coating cycle, and annealing profile', 'The shared preparation condition makes the material comparison more reliable.',
'APPROVED', 'Complete comparison study with clear objective, characterization plan, and visualizable graph values.');

-- Ready repository sample with FTIR image attachment
INSERT INTO experiments (
    experiment_id, student_id, title, experiment_date, material_type, concentration, study_type,
    comparison_table_data, study_objective, hypothesis, independent_variable, dependent_variable,
    controlled_variables, preparation_notes, characterization_methods, characterization_notes,
    instrument_details, scan_range, calibration_reference, replicate_count, measurement_uncertainty,
    raw_data_required, conclusion, limitations, next_steps,
    sample_1_name, sample_1_condition, sample_1_notes,
    sample_2_name, sample_2_condition, sample_2_notes,
    sample_3_name, sample_3_condition, sample_3_notes, status, feedback
) VALUES (
    'EXP-006', 'S71964', 'FTIR Analysis of PMMA-Silica Optical Composite', '2026-06-16',
    'PMMA-Silica Composite', '1.0 wt%', 'SINGLE',
    'RlRJUiBwZWFrIC8gZmVhdHVyZQ==\tU2FtcGxlIEE6IFBNTUEgY29udHJvbA==\tU2FtcGxlIEI6IFBNTUEtU2lPMiBibGVuZA==\tU2FtcGxlIEM6IFBNTUEtU2lPMiBhbm5lYWxlZA==\nQz1PIHN0cmV0Y2hpbmc=\tMTcyOCBjbS0xIHN0cm9uZw==\tMTcyOCBjbS0xIHJldGFpbmVk\tMTcyOCBjbS0xIHNoYXJwZXI=\nQy1PIHZpYnJhdGlvbg==\tOTA2IGNtLTEgd2Vhaw==\tOTA2IGNtLTEgdmlzaWJsZQ==\tOTA2IGNtLTEgZW5oYW5jZWQ=\nRmluZ2VycHJpbnQgcGVhaw==\tNzU5IGNtLTE=\tNzU5IGNtLTE=\tNzU5IGNtLTEgc3RhYmxl',
    'Evaluate FTIR transmittance changes in PMMA-silica composite films and compare the main C=O, C-O, and fingerprint-region peaks across three sample conditions.',
    'Adding silica and annealing the composite will make the C-O related bands clearer while retaining the PMMA C=O peak near 1728 cm-1.',
    'Composite treatment condition',
    'FTIR peak position and relative transmittance intensity',
    'Film casting method, substrate type, drying period, FTIR scan range, and baseline correction were kept constant.',
    'PMMA solution was prepared and cast as a thin film. Silica was blended into the polymer matrix for the composite samples. The third sample was annealed under the same schedule before FTIR analysis.',
    'FTIR',
    'The attached FTIR spectrum shows three stacked transmittance traces. The C=O feature around 1728 cm-1 remains visible, while C-O related features near 906 cm-1 and the 759 cm-1 fingerprint region support comparison of bonding changes.',
    'FTIR spectrometer in transmittance mode; spectra exported as an image for repository review.',
    '4000-500 cm-1',
    'Background/baseline correction was applied before comparing the three spectra.',
    3,
    'Peak positions estimated visually from the provided spectrum.',
    TRUE,
    'The PMMA-silica composite keeps the main C=O band and shows clearer C-O/fingerprint-region features after treatment, suggesting interaction between PMMA and silica phases.',
    'The attached file is an image of the FTIR graph, so exact peak intensity values should be confirmed from raw spectral data.',
    'Upload raw FTIR CSV data and repeat the scan with controlled film thickness for more accurate quantitative comparison.',
    'Sample A', 'PMMA control film', 'Baseline trace used to compare the polymer C=O peak and fingerprint region.',
    'Sample B', 'PMMA-silica blended film', 'Composite trace with visible C-O related features.',
    'Sample C', 'Annealed PMMA-silica film', 'Annealed composite trace with sharper peak features.',
    'APPROVED',
    'Ready repository example with FTIR evidence image and complete characterization metadata.'
);

-- Sample Test Data
INSERT INTO test_data (test_data_id, experiment_id, test_type, file_name, file_path, file_size) VALUES
('TD-001', 'EXP-001', 'FTIR', 'silica_ftir_analysis.csv', 'C:\\uploads\\EXP-001\\silica_ftir_analysis.csv', '2.5 MB'),
('TD-002', 'EXP-002', 'SEM', 'pmma_sem_images.zip', 'C:\\uploads\\EXP-002\\pmma_sem_images.zip', '45.3 MB'),
('TD-003', 'EXP-002', 'UV-VIS', 'pmma_uv_spectrum.txt', 'C:\\uploads\\EXP-002\\pmma_uv_spectrum.txt', '0.5 MB'),
('TD-004', 'EXP-003', 'FTIR', 'zno_ftir_data.csv', 'C:\\uploads\\EXP-003\\zno_ftir_data.csv', '1.2 MB'),
('TD-005', 'EXP-006', 'FTIR', 'sampleftir.jpg', '/uploads/EXP-006/sampleftir.jpg', '24 KB');

-- Sample Learning Materials
INSERT INTO learning_materials (material_id, title, category, description, content, external_link, file_name, file_path, uploaded_by) VALUES
('LM-001', 'Introduction to Nanophysics', 'Nanophysics Fundamentals', 'A starter overview of nanoscale phenomena, confinement, and material behavior.', 'Nanophysics studies how matter behaves when dimensions shrink to the nanoscale. At this scale, quantum confinement, surface effects, and tunneling become important. Use this lesson as a starting point before moving to optical and electronic applications.', 'https://en.wikipedia.org/wiki/Nanophysics', NULL, NULL, 1),
('LM-002', 'Optical Properties of Nanoparticles', 'Optical Properties', 'Key ideas behind absorption, scattering, and plasmonic response.', 'Nanoparticles interact with light differently from bulk materials. Particle size, composition, and surrounding medium can shift optical absorption and scattering. Noble metal nanoparticles are especially important because of localized surface plasmon resonance.', NULL, NULL, NULL, 1);

-- Sample Learning Quiz
INSERT INTO learning_quizzes (quiz_id, title, category, description, uploaded_by) VALUES
('LQ-001', 'Nanophysics Basics Quiz', 'Nanophysics Fundamentals', 'Quick revision quiz on nanoscale concepts.', 1);

INSERT INTO learning_quiz_questions (question_id, quiz_id, question_order, question_text, option_a, option_b, option_c, option_d, correct_option, explanation) VALUES
('LQ-001-Q1', 'LQ-001', 1, 'Why do materials at the nanoscale often behave differently from bulk materials?', 'Because gravity becomes stronger', 'Because quantum and surface effects become significant', 'Because they stop interacting with light', 'Because atoms disappear', 'B', 'At the nanoscale, quantum confinement and high surface-to-volume ratio strongly affect behavior.'),
('LQ-001-Q2', 'LQ-001', 2, 'Which property is commonly associated with gold nanoparticles?', 'Localized surface plasmon resonance', 'Superconductivity at room temperature', 'Permanent magnetism in all cases', 'Infinite thermal conductivity', 'A', 'Gold nanoparticles are well known for plasmonic optical behavior.'),
('LQ-001-Q3', 'LQ-001', 3, 'What happens to surface-to-volume ratio as particle size decreases?', 'It decreases', 'It stays constant', 'It increases', 'It becomes zero', 'C', 'Smaller particles expose proportionally more surface area relative to their volume.');

-- Sample Logbooks (Weekly) - April 2026
-- Student S71964 - All 5 weeks (pending approval)
INSERT INTO logbooks (logbook_id, student_id, month, week, activities, supervisor_notes, supervisor_signature, supervisor_name, approved_date) VALUES
('LB-2026-04-W1', 'S71964', '2026-04', 1, 'Week 1 activities - Data processing and analysis of preliminary results', NULL, NULL, NULL, NULL),
('LB-2026-04-W2', 'S71964', '2026-04', 2, 'Week 2 activities - Lab experiments conducted with new parameters', NULL, NULL, NULL, NULL),
('LB-2026-04-W3', 'S71964', '2026-04', 3, 'Week 3 activities - Results compilation and documentation', NULL, NULL, NULL, NULL),
('LB-2026-04-W4', 'S71964', '2026-04', 4, 'Week 4 activities - Report writing and figure preparation', NULL, NULL, NULL, NULL),
('LB-2026-04-W5', 'S71964', '2026-04', 5, 'Week 5 activities - Final review and manuscript submission', NULL, NULL, NULL, NULL),

-- Student S71619 - 2 weeks (1 approved, 1 pending)
('LB-2026-04-DK-W1', 'S71619', '2026-04', 1, 'Literature review on experimental techniques and methodologies', 'Good progress, continue with current approach', 'Dr. Aizat', 'Dr. Aizat', '2026-04-07 10:00:00'),
('LB-2026-04-DK-W2', 'S71619', '2026-04', 2, 'Lab setup and equipment testing for upcoming experiments', NULL, NULL, NULL, NULL),

-- Student S71965 - 2 weeks (both pending)
('LB-2026-04-MY-W1', 'S71965', '2026-04', 1, 'Data collection from field experiments in natural habitat', NULL, NULL, NULL, NULL),
('LB-2026-04-MY-W2', 'S71965', '2026-04', 2, 'Preliminary analysis of collected results and patterns', NULL, NULL, NULL, NULL),

-- Student S73821 - 2 weeks (1 approved, 1 pending)
('LB-2026-04-AH-W1', 'S73821', '2026-04', 1, 'Thesis literature survey focusing on recent publications', 'Continue focusing on recent publications from last 5 years', 'Dr. Aizat', 'Dr. Aizat', '2026-04-08 14:30:00'),
('LB-2026-04-AH-W2', 'S73821', '2026-04', 2, 'Research methodology refinement and validation protocols', NULL, NULL, NULL, NULL);

-- Historical Logbooks (January 2024) - For reference
-- INSERT INTO logbooks (logbook_id, student_id, month, week, activities, supervisor_notes, supervisor_signature, supervisor_name, approved_date) VALUES
-- ('LB-2024-01-W1', 'S71964', '2024-01', 1, 'Literature review on silica nanoparticles. Reviewed 15 research papers. Prepared lab workspace and materials list.', 'Good start on literature review. Make sure to cite recent papers.', 'Dr. Aizat', 'Dr. Aizat', '2024-01-06 10:30:00'),
-- ('LB-2024-01-W2', 'S71964', '2024-01', 2, 'Conducted material preparation. Set up synthesis equipment. Calibrated all instruments according to SOP.', 'Excellent preparation. Instruments well calibrated.', 'Dr. Aizat', 'Dr. Aizat', '2024-01-13 11:00:00'),
-- ('LB-2024-01-W3', 'S71964', '2024-01', 3, 'Conducted first trial of silica synthesis. Initial results show promising particle formation.', 'Good results so far. Continue with trial 2.', 'Dr. Aizat', 'Dr. Aizat', '2024-01-20 14:30:00'),
-- ('LB-2024-01-W4', 'S71964', '2024-01', 4, 'Completed second trial with adjusted parameters. FTIR analysis shows expected functional groups.', 'Excellent work! Results look very promising.', 'Dr. Aizat', 'Dr. Aizat', '2024-01-27 09:15:00'),
-- ('LB-2024-01-W5', 'S71964', '2024-01', 5, 'Data compilation and analysis. Prepared graphs and charts. Drafted preliminary report section.', NULL, NULL, NULL, NULL);

SELECT 'Database created!' AS Status;
