package com.omrs.servlet;

import com.omrs.dao.UserDAO;
import com.omrs.model.User;
import com.omrs.util.EmailValidator;
import com.omrs.util.EmailUtil;
import java.io.IOException;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.util.Base64;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private static final int TOKEN_BYTES = 32;
    private static final long TOKEN_LIFETIME_MS = 30L * 60L * 1000L;
    private static final SecureRandom RANDOM = new SecureRandom();

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token != null && !token.trim().isEmpty()) {
            prepareTokenView(req, token.trim());
        } else {
            req.setAttribute("mode", "request");
        }
        req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token != null && !token.trim().isEmpty()) {
            resetPasswordFromToken(req, resp, token.trim());
            return;
        }

        requestResetLink(req, resp);
    }

    private void requestResetLink(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");

        if (username == null || username.trim().isEmpty()
                || email == null || email.trim().isEmpty()) {
            req.setAttribute("mode", "request");
            req.setAttribute("error", "Please enter your username and registered email.");
            forward(req, resp);
            return;
        }

        if (!EmailValidator.isValid(email)) {
            req.setAttribute("mode", "request");
            req.setAttribute("error", "Please enter a valid email address.");
            forward(req, resp);
            return;
        }

        User user = userDAO.getUserByUsernameAndEmail(username.trim(), email.trim());
        if (user != null) {
            String rawToken = generateToken();
            String tokenHash = hashToken(rawToken);
            Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + TOKEN_LIFETIME_MS);

            boolean tokenSaved = userDAO.createPasswordResetToken(user.getUserId(), tokenHash, expiresAt);
            boolean emailSent = false;
            if (tokenSaved) {
                String resetLink = buildResetLink(req, rawToken);
                emailSent = EmailUtil.sendPasswordResetEmail(getServletContext(), user.getEmail(), user.getUsername(), resetLink);
            }

            if (!tokenSaved || !emailSent) {
                req.setAttribute("mode", "request");
                req.setAttribute("error", "We could not process the reset request right now. Please try again later.");
                forward(req, resp);
                return;
            }
        }

        req.setAttribute("mode", "request");
        req.setAttribute("success", "If the account details match our records, a reset link has been sent to that email.");
        forward(req, resp);
    }

    private void resetPasswordFromToken(HttpServletRequest req, HttpServletResponse resp, String token) throws ServletException, IOException {
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (newPassword == null || newPassword.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {
            prepareTokenView(req, token);
            req.setAttribute("error", "Please enter and confirm your new password.");
            forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            prepareTokenView(req, token);
            req.setAttribute("error", "Passwords do not match.");
            forward(req, resp);
            return;
        }

        if (newPassword.length() < 6) {
            prepareTokenView(req, token);
            req.setAttribute("error", "Password must be at least 6 characters.");
            forward(req, resp);
            return;
        }

        boolean success = userDAO.resetPasswordWithToken(hashToken(token), newPassword);
        if (success) {
            req.setAttribute("mode", "request");
            req.setAttribute("success", "Password reset successfully. You can now log in.");
        } else {
            req.setAttribute("mode", "invalid");
            req.setAttribute("error", "This reset link is invalid or has expired. Please request a new link.");
        }

        forward(req, resp);
    }

    private void prepareTokenView(HttpServletRequest req, String token) {
        User user = userDAO.getUserByValidResetToken(hashToken(token));
        if (user == null) {
            req.setAttribute("mode", "invalid");
            req.setAttribute("error", "This reset link is invalid or has expired. Please request a new link.");
            return;
        }

        req.setAttribute("mode", "reset");
        req.setAttribute("token", token);
        req.setAttribute("resetUsername", user.getUsername());
    }

    private void forward(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
    }

    private String buildResetLink(HttpServletRequest req, String token) throws IOException {
        String baseUrl = req.getRequestURL().toString();
        return baseUrl + "?token=" + URLEncoder.encode(token, "UTF-8");
    }

    private String generateToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes("UTF-8"));
            StringBuilder hex = new StringBuilder(hash.length * 2);
            for (byte b : hash) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (Exception e) {
            throw new IllegalStateException("Unable to hash reset token", e);
        }
    }
}
