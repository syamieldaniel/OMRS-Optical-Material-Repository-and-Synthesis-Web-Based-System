package com.omrs.model;

import java.sql.Timestamp;

public class TestData {
    private String testDataId;
    private String experimentId;
    private String testType;
    private String fileName;
    private String filePath;
    private String fileSize;
    private Timestamp uploadDate;
    
    public String getTestDataId() { return testDataId; }
    public void setTestDataId(String id) { this.testDataId = id; }
    
    public String getExperimentId() { return experimentId; }
    public void setExperimentId(String id) { this.experimentId = id; }
    
    public String getTestType() { return testType; }
    public void setTestType(String type) { this.testType = type; }
    
    public String getFileName() { return fileName; }
    public void setFileName(String name) { this.fileName = name; }
    
    public String getFilePath() { return filePath; }
    public void setFilePath(String path) { this.filePath = path; }
    
    public String getFileSize() { return fileSize; }
    public void setFileSize(String size) { this.fileSize = size; }
    
    public Timestamp getUploadDate() { return uploadDate; }
    public void setUploadDate(Timestamp date) { this.uploadDate = date; }
}