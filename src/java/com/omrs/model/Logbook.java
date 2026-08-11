package com.omrs.model;

import java.sql.Timestamp;

public class Logbook {
    private String logbookId;
    private String studentId;
    private String studentName;
    private String month;
    private Integer week;
    private String activities;
    private String supervisorNotes;
    private String supervisorSignature;
    private String supervisorName;
    private Timestamp approvedDate;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private java.util.List<LogbookComment> comments;
    
    public String getLogbookId() { return logbookId; }
    public void setLogbookId(String id) { this.logbookId = id; }
    
    public String getStudentId() { return studentId; }
    public void setStudentId(String id) { this.studentId = id; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String name) { this.studentName = name; }
    
    public String getMonth() { return month; }
    public void setMonth(String month) { this.month = month; }
    
    public Integer getWeek() { return week; }
    public void setWeek(Integer week) { this.week = week; }
    
    public String getActivities() { return activities; }
    public void setActivities(String activities) { this.activities = activities; }
    
    public String getSupervisorNotes() { return supervisorNotes; }
    public void setSupervisorNotes(String notes) { this.supervisorNotes = notes; }
    
    public String getSupervisorSignature() { return supervisorSignature; }
    public void setSupervisorSignature(String sig) { this.supervisorSignature = sig; }
    
    public String getSupervisorName() { return supervisorName; }
    public void setSupervisorName(String name) { this.supervisorName = name; }
    
    public Timestamp getApprovedDate() { return approvedDate; }
    public void setApprovedDate(Timestamp date) { this.approvedDate = date; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    public java.util.List<LogbookComment> getComments() { return comments; }
    public void setComments(java.util.List<LogbookComment> comments) { this.comments = comments; }
    
    public boolean isApproved() {
        return supervisorSignature != null && !supervisorSignature.isEmpty();
    }
    
    // Convenience methods for view page
    public String getTitle() {
        return "Week " + week + " - " + month;
    }
    
    public String getStatus() {
        return isApproved() ? "Approved" : "Pending Review";
    }
    
    public String getEntryDate() {
        return createdAt != null ? createdAt.toString().substring(0, 10) : "N/A";
    }
    
    public String getContent() {
        return activities != null ? activities : "";
    }
}
