package com.omrs.model;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

public class Experiment {
    private String experimentId;
    private String studentId;
    private String studentName;
    private String title;
    private Date experimentDate;
    private String materialType;
    private String concentration;
    private String studyType;
    private String materialBType;
    private String materialBConcentration;
    private String comparisonMetricLabel;
    private Double materialAMetricValue;
    private Double materialBMetricValue;
    private String comparisonNotes;
    private String comparisonTableData;
    private String studyObjective;
    private String hypothesis;
    private String independentVariable;
    private String dependentVariable;
    private String controlledVariables;
    private String preparationNotes;
    private String characterizationMethods;
    private String characterizationNotes;
    private String instrumentDetails;
    private String scanRange;
    private String calibrationReference;
    private Integer replicateCount;
    private String measurementUncertainty;
    private Boolean rawDataRequired;
    private String conclusion;
    private String limitations;
    private String nextSteps;
    private String sampleOneName;
    private String sampleOneCondition;
    private String sampleOneNotes;
    private String sampleTwoName;
    private String sampleTwoCondition;
    private String sampleTwoNotes;
    private String sampleThreeName;
    private String sampleThreeCondition;
    private String sampleThreeNotes;
    private String status;
    private String feedback;
    private Timestamp createdAt;
    private List<TestData> testFiles = new ArrayList<>();
    
    public String getExperimentId() { return experimentId; }
    public void setExperimentId(String id) { this.experimentId = id; }
    
    public String getStudentId() { return studentId; }
    public void setStudentId(String id) { this.studentId = id; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String name) { this.studentName = name; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public Date getExperimentDate() { return experimentDate; }
    public void setExperimentDate(Date date) { this.experimentDate = date; }
    
    public String getMaterialType() { return materialType; }
    public void setMaterialType(String type) { this.materialType = type; }
    
    public String getConcentration() { return concentration; }
    public void setConcentration(String conc) { this.concentration = conc; }

    public String getStudyType() { return studyType; }
    public void setStudyType(String studyType) { this.studyType = studyType; }

    public String getMaterialBType() { return materialBType; }
    public void setMaterialBType(String materialBType) { this.materialBType = materialBType; }

    public String getMaterialBConcentration() { return materialBConcentration; }
    public void setMaterialBConcentration(String materialBConcentration) { this.materialBConcentration = materialBConcentration; }

    public String getComparisonMetricLabel() { return comparisonMetricLabel; }
    public void setComparisonMetricLabel(String comparisonMetricLabel) { this.comparisonMetricLabel = comparisonMetricLabel; }

    public Double getMaterialAMetricValue() { return materialAMetricValue; }
    public void setMaterialAMetricValue(Double materialAMetricValue) { this.materialAMetricValue = materialAMetricValue; }

    public Double getMaterialBMetricValue() { return materialBMetricValue; }
    public void setMaterialBMetricValue(Double materialBMetricValue) { this.materialBMetricValue = materialBMetricValue; }

    public String getComparisonNotes() { return comparisonNotes; }
    public void setComparisonNotes(String comparisonNotes) { this.comparisonNotes = comparisonNotes; }

    public String getComparisonTableData() { return comparisonTableData; }
    public void setComparisonTableData(String comparisonTableData) { this.comparisonTableData = comparisonTableData; }

    public List<String[]> getComparisonTableRows() {
        List<String[]> rows = new ArrayList<>();
        if (comparisonTableData == null || comparisonTableData.trim().isEmpty()) {
            return rows;
        }
        String[] lines = comparisonTableData.split("\\R");
        for (String line : lines) {
            if (line == null || line.trim().isEmpty()) continue;
            String[] encodedCells = line.split("\\t", -1);
            String[] cells = new String[] {"", "", "", ""};
            for (int i = 0; i < cells.length && i < encodedCells.length; i++) {
                cells[i] = decodeCell(encodedCells[i]);
            }
            rows.add(cells);
        }
        return rows;
    }

    private String decodeCell(String value) {
        if (value == null || value.isEmpty()) {
            return "";
        }
        try {
            return new String(Base64.getDecoder().decode(value), java.nio.charset.StandardCharsets.UTF_8);
        } catch (IllegalArgumentException e) {
            return "";
        }
    }

    public String getStudyObjective() { return studyObjective; }
    public void setStudyObjective(String studyObjective) { this.studyObjective = studyObjective; }

    public String getHypothesis() { return hypothesis; }
    public void setHypothesis(String hypothesis) { this.hypothesis = hypothesis; }

    public String getIndependentVariable() { return independentVariable; }
    public void setIndependentVariable(String independentVariable) { this.independentVariable = independentVariable; }

    public String getDependentVariable() { return dependentVariable; }
    public void setDependentVariable(String dependentVariable) { this.dependentVariable = dependentVariable; }

    public String getControlledVariables() { return controlledVariables; }
    public void setControlledVariables(String controlledVariables) { this.controlledVariables = controlledVariables; }
    
    public String getPreparationNotes() { return preparationNotes; }
    public void setPreparationNotes(String notes) { this.preparationNotes = notes; }

    public String getCharacterizationMethods() { return characterizationMethods; }
    public void setCharacterizationMethods(String characterizationMethods) { this.characterizationMethods = characterizationMethods; }

    public String getCharacterizationNotes() { return characterizationNotes; }
    public void setCharacterizationNotes(String characterizationNotes) { this.characterizationNotes = characterizationNotes; }

    public String getInstrumentDetails() { return instrumentDetails; }
    public void setInstrumentDetails(String instrumentDetails) { this.instrumentDetails = instrumentDetails; }

    public String getScanRange() { return scanRange; }
    public void setScanRange(String scanRange) { this.scanRange = scanRange; }

    public String getCalibrationReference() { return calibrationReference; }
    public void setCalibrationReference(String calibrationReference) { this.calibrationReference = calibrationReference; }

    public Integer getReplicateCount() { return replicateCount; }
    public void setReplicateCount(Integer replicateCount) { this.replicateCount = replicateCount; }

    public String getMeasurementUncertainty() { return measurementUncertainty; }
    public void setMeasurementUncertainty(String measurementUncertainty) { this.measurementUncertainty = measurementUncertainty; }

    public Boolean getRawDataRequired() { return rawDataRequired; }
    public void setRawDataRequired(Boolean rawDataRequired) { this.rawDataRequired = rawDataRequired; }

    public String getConclusion() { return conclusion; }
    public void setConclusion(String conclusion) { this.conclusion = conclusion; }

    public String getLimitations() { return limitations; }
    public void setLimitations(String limitations) { this.limitations = limitations; }

    public String getNextSteps() { return nextSteps; }
    public void setNextSteps(String nextSteps) { this.nextSteps = nextSteps; }

    public String getSampleOneName() { return sampleOneName; }
    public void setSampleOneName(String sampleOneName) { this.sampleOneName = sampleOneName; }

    public String getSampleOneCondition() { return sampleOneCondition; }
    public void setSampleOneCondition(String sampleOneCondition) { this.sampleOneCondition = sampleOneCondition; }

    public String getSampleOneNotes() { return sampleOneNotes; }
    public void setSampleOneNotes(String sampleOneNotes) { this.sampleOneNotes = sampleOneNotes; }

    public String getSampleTwoName() { return sampleTwoName; }
    public void setSampleTwoName(String sampleTwoName) { this.sampleTwoName = sampleTwoName; }

    public String getSampleTwoCondition() { return sampleTwoCondition; }
    public void setSampleTwoCondition(String sampleTwoCondition) { this.sampleTwoCondition = sampleTwoCondition; }

    public String getSampleTwoNotes() { return sampleTwoNotes; }
    public void setSampleTwoNotes(String sampleTwoNotes) { this.sampleTwoNotes = sampleTwoNotes; }

    public String getSampleThreeName() { return sampleThreeName; }
    public void setSampleThreeName(String sampleThreeName) { this.sampleThreeName = sampleThreeName; }

    public String getSampleThreeCondition() { return sampleThreeCondition; }
    public void setSampleThreeCondition(String sampleThreeCondition) { this.sampleThreeCondition = sampleThreeCondition; }

    public String getSampleThreeNotes() { return sampleThreeNotes; }
    public void setSampleThreeNotes(String sampleThreeNotes) { this.sampleThreeNotes = sampleThreeNotes; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public List<TestData> getTestFiles() { return testFiles; }
    public void setTestFiles(List<TestData> files) { this.testFiles = files; }
}
