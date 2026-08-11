package com.omrs.servlet;

import com.omrs.dao.LearningDAO;
import com.omrs.model.LearningMaterial;
import com.omrs.model.LearningQuiz;
import com.omrs.model.LearningQuizAttempt;
import com.omrs.model.LearningQuizQuestion;
import com.omrs.model.User;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/learning/*")
@MultipartConfig(maxFileSize = 16177215)
public class LearningServlet extends HttpServlet {
    private LearningDAO learningDAO = new LearningDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = requireUser(req, resp);
        if (user == null) return;

        String path = req.getPathInfo();
        if (path == null || "/".equals(path) || "/index".equals(path)) {
            req.setAttribute("materials", learningDAO.getAllMaterials());
            req.setAttribute("quizzes", learningDAO.getAllQuizzes());
            req.getRequestDispatcher("/pages/learning/index.jsp").forward(req, resp);
        } else if ("/manage".equals(path)) {
            if (!isLecturer(user)) {
                resp.sendRedirect(req.getContextPath() + "/learning");
                return;
            }
            req.setAttribute("materials", learningDAO.getMaterialsByAuthor(user.getUserId()));
            req.setAttribute("quizzes", learningDAO.getQuizzesByAuthor(user.getUserId()));
            req.getRequestDispatcher("/pages/learning/manage.jsp").forward(req, resp);
        } else if ("/material/create".equals(path)) {
            if (!isLecturer(user)) {
                resp.sendRedirect(req.getContextPath() + "/learning");
                return;
            }
            req.getRequestDispatcher("/pages/learning/material-create.jsp").forward(req, resp);
        } else if (path.startsWith("/material/view/")) {
            String materialId = path.substring("/material/view/".length());
            LearningMaterial material = learningDAO.getMaterialById(materialId);
            if (material == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("material", material);
            req.getRequestDispatcher("/pages/learning/material-view.jsp").forward(req, resp);
        } else if (path.startsWith("/material/file/")) {
            String materialId = path.substring("/material/file/".length());
            sendMaterialFile(materialId, req, resp);
        } else if ("/quiz/create".equals(path)) {
            if (!isLecturer(user)) {
                resp.sendRedirect(req.getContextPath() + "/learning");
                return;
            }
            req.getRequestDispatcher("/pages/learning/quiz-create.jsp").forward(req, resp);
        } else if (path.startsWith("/quiz/view/")) {
            String quizId = path.substring("/quiz/view/".length());
            LearningQuiz quiz = learningDAO.getQuizById(quizId);
            if (quiz == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("quiz", quiz);
            if (isLecturer(user)) {
                req.setAttribute("attempts", learningDAO.getAttemptsForQuiz(quizId));
            } else {
                req.setAttribute("latestAttempt", learningDAO.getLatestAttempt(quizId, user.getUserId()));
            }
            req.getRequestDispatcher("/pages/learning/quiz-view.jsp").forward(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = requireUser(req, resp);
        if (user == null) return;

        String path = req.getPathInfo();
        if ("/material/create".equals(path)) {
            if (!isLecturer(user)) {
                resp.sendRedirect(req.getContextPath() + "/learning");
                return;
            }
            createMaterial(req, resp, user);
        } else if ("/quiz/create".equals(path)) {
            if (!isLecturer(user)) {
                resp.sendRedirect(req.getContextPath() + "/learning");
                return;
            }
            createQuiz(req, resp, user);
        } else if (path != null && path.startsWith("/quiz/submit/")) {
            submitQuiz(req, resp, user, path.substring("/quiz/submit/".length()));
        } else if (path != null && path.startsWith("/material/delete/")) {
            if (isLecturer(user)) {
                learningDAO.deleteMaterial(path.substring("/material/delete/".length()), user.getUserId());
            }
            resp.sendRedirect(req.getContextPath() + "/learning/manage");
        } else if (path != null && path.startsWith("/quiz/delete/")) {
            if (isLecturer(user)) {
                learningDAO.deleteQuiz(path.substring("/quiz/delete/".length()), user.getUserId());
            }
            resp.sendRedirect(req.getContextPath() + "/learning/manage");
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void createMaterial(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        String title = trim(req.getParameter("title"));
        String category = trim(req.getParameter("category"));
        String description = trim(req.getParameter("description"));
        String content = trim(req.getParameter("content"));
        String externalLink = trim(req.getParameter("externalLink"));

        if (title == null || title.isEmpty()) {
            req.setAttribute("error", "Material title is required.");
            req.getRequestDispatcher("/pages/learning/material-create.jsp").forward(req, resp);
            return;
        }

        Part filePart = req.getPart("materialFile");
        LearningMaterial material = new LearningMaterial();
        material.setMaterialId(learningDAO.generateMaterialId());
        material.setTitle(title);
        material.setCategory(category != null && !category.isEmpty() ? category : "Nanophysics");
        material.setDescription(description);
        material.setContent(content);
        material.setExternalLink(externalLink);
        material.setUploadedByUserId(user.getUserId());

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = extractFileName(filePart);
            if (fileName != null && !fileName.isEmpty()) {
                String uploadDir = getServletContext().getRealPath("/uploads/learning/" + material.getMaterialId());
                File uploadFolder = new File(uploadDir);
                if (!uploadFolder.exists()) {
                    uploadFolder.mkdirs();
                }
                filePart.write(uploadDir + File.separator + fileName);
                material.setFileName(fileName);
                material.setFilePath("/uploads/learning/" + material.getMaterialId() + "/" + fileName);
            }
        }

        if (learningDAO.createMaterial(material)) {
            resp.sendRedirect(req.getContextPath() + "/learning/material/view/" + material.getMaterialId());
        } else {
            req.setAttribute("error", "Failed to publish learning material.");
            req.getRequestDispatcher("/pages/learning/material-create.jsp").forward(req, resp);
        }
    }

    private void createQuiz(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        String title = trim(req.getParameter("title"));
        String category = trim(req.getParameter("category"));
        String description = trim(req.getParameter("description"));
        String quizId = learningDAO.generateQuizId();
        String[] questionTexts = req.getParameterValues("questionText");
        String[] optionAs = req.getParameterValues("optionA");
        String[] optionBs = req.getParameterValues("optionB");
        String[] optionCs = req.getParameterValues("optionC");
        String[] optionDs = req.getParameterValues("optionD");
        String[] correctOptions = req.getParameterValues("correctOption");
        String[] explanations = req.getParameterValues("explanation");

        if (title == null || title.isEmpty()) {
            req.setAttribute("error", "Quiz title is required.");
            req.getRequestDispatcher("/pages/learning/quiz-create.jsp").forward(req, resp);
            return;
        }

        List<LearningQuizQuestion> questions = new ArrayList<>();
        if (questionTexts != null) {
            for (int i = 0; i < questionTexts.length; i++) {
                String questionText = trim(questionTexts[i]);
                if (questionText == null || questionText.isEmpty()) {
                    continue;
                }
                LearningQuizQuestion question = new LearningQuizQuestion();
                question.setQuestionId(quizId + "-Q" + (questions.size() + 1));
                question.setQuestionOrder(questions.size() + 1);
                question.setQuestionText(questionText);
                question.setOptionA(safeValue(optionAs, i));
                question.setOptionB(safeValue(optionBs, i));
                question.setOptionC(safeValue(optionCs, i));
                question.setOptionD(safeValue(optionDs, i));
                question.setCorrectOption(safeValue(correctOptions, i));
                question.setExplanation(safeValue(explanations, i));
                if (question.getOptionA().isEmpty() || question.getOptionB().isEmpty() ||
                    question.getOptionC().isEmpty() || question.getOptionD().isEmpty() ||
                    question.getCorrectOption().isEmpty()) {
                    continue;
                }
                questions.add(question);
            }
        }

        if (questions.isEmpty()) {
            req.setAttribute("error", "Please add at least one complete quiz question.");
            req.getRequestDispatcher("/pages/learning/quiz-create.jsp").forward(req, resp);
            return;
        }

        LearningQuiz quiz = new LearningQuiz();
        quiz.setQuizId(quizId);
        quiz.setTitle(title);
        quiz.setCategory(category != null && !category.isEmpty() ? category : "Nanophysics");
        quiz.setDescription(description);
        quiz.setUploadedByUserId(user.getUserId());
        quiz.setQuestions(questions);

        if (learningDAO.createQuiz(quiz)) {
            resp.sendRedirect(req.getContextPath() + "/learning/quiz/view/" + quiz.getQuizId());
        } else {
            req.setAttribute("error", "Failed to create quiz.");
            req.getRequestDispatcher("/pages/learning/quiz-create.jsp").forward(req, resp);
        }
    }

    private void submitQuiz(HttpServletRequest req, HttpServletResponse resp, User user, String quizId) throws IOException, ServletException {
        LearningQuiz quiz = learningDAO.getQuizById(quizId);
        if (quiz == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        int score = 0;
        for (LearningQuizQuestion question : quiz.getQuestions()) {
            String answer = trim(req.getParameter("answer_" + question.getQuestionId()));
            if (answer != null && answer.equalsIgnoreCase(question.getCorrectOption())) {
                score++;
            }
        }

        LearningQuizAttempt attempt = new LearningQuizAttempt();
        attempt.setAttemptId(learningDAO.generateAttemptId());
        attempt.setQuizId(quizId);
        attempt.setUserId(user.getUserId());
        attempt.setScore(score);
        attempt.setTotalQuestions(quiz.getQuestions().size());
        learningDAO.saveQuizAttempt(attempt);

        resp.sendRedirect(req.getContextPath() + "/learning/quiz/view/" + quizId + "?submitted=true");
    }

    private void sendMaterialFile(String materialId, HttpServletRequest req, HttpServletResponse resp) throws IOException {
        LearningMaterial material = learningDAO.getMaterialById(materialId);
        if (material == null || material.getFilePath() == null || material.getFilePath().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String realPath = req.getServletContext().getRealPath(material.getFilePath());
        File file = new File(realPath);
        if (!file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileName = material.getFileName();
        String lowerFileName = fileName != null ? fileName.toLowerCase() : "";
        boolean inline = "view".equalsIgnoreCase(req.getParameter("action")) && lowerFileName.endsWith(".pdf");

        resp.setContentType(getServletContext().getMimeType(fileName));
        if (resp.getContentType() == null || "application/octet-stream".equals(resp.getContentType())) {
            resp.setContentType(lowerFileName.endsWith(".pdf") ? "application/pdf" : "application/octet-stream");
        }
        resp.setHeader("Content-Disposition", (inline ? "inline" : "attachment") + "; filename=\"" + fileName + "\"");
        resp.setContentLength((int) file.length());
        try (FileInputStream fis = new FileInputStream(file)) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                resp.getOutputStream().write(buffer, 0, bytesRead);
            }
            resp.getOutputStream().flush();
        }
    }

    private User requireUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return (User) session.getAttribute("user");
    }

    private boolean isLecturer(User user) {
        return "SUPERVISOR".equals(user.getRole());
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private String safeValue(String[] values, int index) {
        if (values == null || index >= values.length || values[index] == null) {
            return "";
        }
        return values[index].trim();
    }

    private String extractFileName(Part part) {
        try {
            String contentDisp = part.getHeader("content-disposition");
            if (contentDisp == null) return null;
            String[] items = contentDisp.split(";");
            for (String item : items) {
                item = item.trim();
                if (item.startsWith("filename")) {
                    int start = item.indexOf('=');
                    if (start >= 0) {
                        String fileName = item.substring(start + 1).trim();
                        if (fileName.startsWith("\"") && fileName.endsWith("\"")) {
                            fileName = fileName.substring(1, fileName.length() - 1);
                        }
                        return new File(fileName).getName();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
