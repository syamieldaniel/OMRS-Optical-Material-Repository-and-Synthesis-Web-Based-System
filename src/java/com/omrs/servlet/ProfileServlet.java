package com.omrs.servlet;

import com.omrs.dao.UserDAO;
import com.omrs.model.User;
import com.omrs.util.EmailValidator;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/profile")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class ProfileServlet extends HttpServlet {
    private static final Set<String> ALLOWED_IMAGE_TYPES = new HashSet<>(
            Arrays.asList("image/jpeg", "image/png", "image/gif", "image/webp"));

    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        
        // Get additional info
        String studentId = (String) session.getAttribute("studentId");
        String supervisorId = (String) session.getAttribute("supervisorId");
        String supervisorName = null;
        if (supervisorId != null) {
            supervisorName = userDAO.getSupervisorName(supervisorId);
        }
        
        req.setAttribute("studentId", studentId);
        req.setAttribute("supervisorId", supervisorId);
        req.setAttribute("supervisorName", supervisorName);
        req.setAttribute("user", user);
        
        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        
        String email = req.getParameter("email");
        String fullName = req.getParameter("fullName");
        String password = req.getParameter("password");
        Part profilePicture = req.getPart("profilePicture");

        if (!EmailValidator.isValid(email)) {
            req.setAttribute("error", "Please enter a valid email address that you can access.");
            doGet(req, resp);
            return;
        }
        
        // Update user
        user.setEmail(email);
        user.setFullName(fullName);
        if (password != null && !password.isEmpty()) {
            user.setPassword(password);
        }

        if (profilePicture != null && profilePicture.getSize() > 0) {
            String savedPath = saveProfilePicture(profilePicture, user.getUserId());
            if (savedPath == null) {
                req.setAttribute("error", "Please upload a JPG, PNG, GIF, or WebP image up to 5 MB.");
                doGet(req, resp);
                return;
            }
            user.setProfilePicture(savedPath);
        }
        
        boolean success = userDAO.updateUser(user);
        if (success && password != null && !password.trim().isEmpty()) {
            success = userDAO.updatePassword(user.getUserId(), password);
        }
        if (success) {
            req.setAttribute("message", "Profile updated successfully");
        } else {
            req.setAttribute("error", "Failed to update profile");
        }
        
        doGet(req, resp);
    }

    private String saveProfilePicture(Part part, int userId) throws IOException {
        String contentType = part.getContentType();
        if (contentType == null || !ALLOWED_IMAGE_TYPES.contains(contentType.toLowerCase())) {
            return null;
        }

        String extension = getExtension(part);
        if (extension == null) {
            extension = extensionFromContentType(contentType);
        }
        if (extension == null) {
            return null;
        }

        String uploadDir = getServletContext().getRealPath("/uploads/profile");
        File uploadFolder = new File(uploadDir);
        if (!uploadFolder.exists()) {
            uploadFolder.mkdirs();
        }

        String fileName = "user-" + userId + "-" + System.currentTimeMillis() + extension;
        part.write(uploadDir + File.separator + fileName);
        return "/uploads/profile/" + fileName;
    }

    private String getExtension(Part part) {
        String submittedName = part.getSubmittedFileName();
        if (submittedName == null) {
            return null;
        }
        String fileName = new File(submittedName).getName().toLowerCase();
        int dot = fileName.lastIndexOf('.');
        if (dot < 0) {
            return null;
        }
        String extension = fileName.substring(dot);
        return Arrays.asList(".jpg", ".jpeg", ".png", ".gif", ".webp").contains(extension) ? extension : null;
    }

    private String extensionFromContentType(String contentType) {
        if ("image/jpeg".equalsIgnoreCase(contentType)) return ".jpg";
        if ("image/png".equalsIgnoreCase(contentType)) return ".png";
        if ("image/gif".equalsIgnoreCase(contentType)) return ".gif";
        if ("image/webp".equalsIgnoreCase(contentType)) return ".webp";
        return null;
    }
}
