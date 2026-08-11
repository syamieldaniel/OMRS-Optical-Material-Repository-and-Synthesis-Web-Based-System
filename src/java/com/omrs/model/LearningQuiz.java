package com.omrs.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class LearningQuiz {
    private String quizId;
    private String title;
    private String category;
    private String description;
    private int uploadedByUserId;
    private String uploadedByName;
    private int questionCount;
    private int totalAttempts;
    private Timestamp createdAt;
    private List<LearningQuizQuestion> questions = new ArrayList<>();

    public String getQuizId() { return quizId; }
    public void setQuizId(String quizId) { this.quizId = quizId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getUploadedByUserId() { return uploadedByUserId; }
    public void setUploadedByUserId(int uploadedByUserId) { this.uploadedByUserId = uploadedByUserId; }

    public String getUploadedByName() { return uploadedByName; }
    public void setUploadedByName(String uploadedByName) { this.uploadedByName = uploadedByName; }

    public int getQuestionCount() { return questionCount; }
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }

    public int getTotalAttempts() { return totalAttempts; }
    public void setTotalAttempts(int totalAttempts) { this.totalAttempts = totalAttempts; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<LearningQuizQuestion> getQuestions() { return questions; }
    public void setQuestions(List<LearningQuizQuestion> questions) { this.questions = questions; }
}
