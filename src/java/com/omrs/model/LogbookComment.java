package com.omrs.model;

import java.sql.Timestamp;

public class LogbookComment {
    private String commentId;
    private String logbookId;
    private Integer userId;
    private String userName;
    private String commentText;
    private String commentType; // COMMENT or NOTE
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    public String getCommentId() { return commentId; }
    public void setCommentId(String id) { this.commentId = id; }
    
    public String getLogbookId() { return logbookId; }
    public void setLogbookId(String id) { this.logbookId = id; }
    
    public Integer getUserId() { return userId; }
    public void setUserId(Integer id) { this.userId = id; }
    
    public String getUserName() { return userName; }
    public void setUserName(String name) { this.userName = name; }
    
    public String getCommentText() { return commentText; }
    public void setCommentText(String text) { this.commentText = text; }
    
    public String getCommentType() { return commentType; }
    public void setCommentType(String type) { this.commentType = type; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
