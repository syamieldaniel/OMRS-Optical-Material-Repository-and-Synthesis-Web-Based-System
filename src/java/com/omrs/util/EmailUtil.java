package com.omrs.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.Socket;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import javax.net.ssl.SSLSocketFactory;
import javax.servlet.ServletContext;

public class EmailUtil {
    private EmailUtil() {}

    public static boolean sendPasswordResetEmail(ServletContext context, String toEmail, String username, String resetLink) {
        String subject = "OMRS password reset";
        String body = "Hi " + safeName(username) + ",\r\n\r\n" +
                "We received a request to reset your OMRS password.\r\n\r\n" +
                "Open this secure link to set a new password:\r\n" + resetLink + "\r\n\r\n" +
                "This link expires in 30 minutes and can be used only once.\r\n" +
                "If you did not request this, you can ignore this email.\r\n\r\n" +
                "OMRS";

        return sendEmail(context, toEmail, subject, body, "Password reset link for " + toEmail + ": " + resetLink);
    }

    public static boolean sendStudentApprovalEmail(ServletContext context, String toEmail, String studentName, String loginLink) {
        String subject = "Your OMRS FYP account has been approved";
        String body = "Hi " + safeName(studentName) + ",\r\n\r\n" +
                "Your FYP student account has been approved by your supervisor.\r\n\r\n" +
                "You can now log in to OMRS and start using your research workspace:\r\n" + loginLink + "\r\n\r\n" +
                "OMRS";

        return sendEmail(context, toEmail, subject, body, "FYP approval email for " + toEmail + ". Login link: " + loginLink);
    }

    private static boolean sendEmail(ServletContext context, String toEmail, String subject, String body, String fallbackLogMessage) {
        String provider = setting(context, "OMRS_EMAIL_PROVIDER");
        if ("brevo".equalsIgnoreCase(provider)) {
            return sendBrevoEmail(context, toEmail, subject, body, fallbackLogMessage);
        }

        String host = setting(context, "OMRS_SMTP_HOST");
        String from = setting(context, "OMRS_SMTP_FROM");

        if (isBlank(host) || isBlank(from)) {
            context.log("SMTP is not configured. " + fallbackLogMessage);
            return true;
        }

        int port = parseInt(setting(context, "OMRS_SMTP_PORT"), 587);
        boolean startTls = parseBoolean(setting(context, "OMRS_SMTP_STARTTLS"), true);
        boolean ssl = parseBoolean(setting(context, "OMRS_SMTP_SSL"), port == 465);
        String smtpUser = setting(context, "OMRS_SMTP_USERNAME");
        String smtpPass = setting(context, "OMRS_SMTP_PASSWORD");

        try {
            sendSmtp(host, port, ssl, startTls, smtpUser, smtpPass, from, toEmail, subject, body);
            return true;
        } catch (Exception e) {
            context.log("Unable to send email to " + toEmail, e);
            return false;
        }
    }

    private static boolean sendBrevoEmail(ServletContext context, String toEmail, String subject, String body, String fallbackLogMessage) {
        String apiKey = setting(context, "OMRS_EMAIL_API_KEY");
        String from = setting(context, "OMRS_EMAIL_FROM");
        String fromName = setting(context, "OMRS_EMAIL_FROM_NAME");

        if (isBlank(apiKey) || isBlank(from)) {
            context.log("Brevo is not configured. " + fallbackLogMessage);
            return true;
        }

        try {
            URL url = new URL("https://api.brevo.com/v3/smtp/email");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(15000);
            conn.setDoOutput(true);
            conn.setRequestProperty("accept", "application/json");
            conn.setRequestProperty("api-key", apiKey);
            conn.setRequestProperty("content-type", "application/json; charset=UTF-8");

            String json = buildBrevoPayload(from, fromName, toEmail, subject, body);
            try (OutputStreamWriter out = new OutputStreamWriter(conn.getOutputStream(), StandardCharsets.UTF_8)) {
                out.write(json);
            }

            int status = conn.getResponseCode();
            if (status >= 200 && status < 300) {
                return true;
            }

            context.log("Brevo email failed for " + toEmail + ". HTTP status: " + status + ". Response: " + readHttpResponse(conn));
            return false;
        } catch (Exception e) {
            context.log("Unable to send Brevo email to " + toEmail, e);
            return false;
        }
    }

    private static String buildBrevoPayload(String from, String fromName, String toEmail, String subject, String body) {
        String senderName = isBlank(fromName) ? "OMRS" : fromName;
        return "{" +
                "\"sender\":{\"name\":\"" + jsonEscape(senderName) + "\",\"email\":\"" + jsonEscape(from) + "\"}," +
                "\"to\":[{\"email\":\"" + jsonEscape(toEmail) + "\"}]," +
                "\"subject\":\"" + jsonEscape(subject) + "\"," +
                "\"textContent\":\"" + jsonEscape(body) + "\"," +
                "\"htmlContent\":\"" + jsonEscape(toHtml(body)) + "\"" +
                "}";
    }

    private static String readHttpResponse(HttpURLConnection conn) {
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    conn.getErrorStream() != null ? conn.getErrorStream() : conn.getInputStream(),
                    StandardCharsets.UTF_8));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();
            return response.toString();
        } catch (Exception e) {
            return "";
        }
    }

    private static String toHtml(String body) {
        return "<html><body><p>" + jsonSafeHtml(body).replace("\r\n", "<br>").replace("\n", "<br>") + "</p></body></html>";
    }

    private static String jsonSafeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    private static String jsonEscape(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder escaped = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '"':
                    escaped.append("\\\"");
                    break;
                case '\\':
                    escaped.append("\\\\");
                    break;
                case '\b':
                    escaped.append("\\b");
                    break;
                case '\f':
                    escaped.append("\\f");
                    break;
                case '\n':
                    escaped.append("\\n");
                    break;
                case '\r':
                    escaped.append("\\r");
                    break;
                case '\t':
                    escaped.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        escaped.append(String.format("\\u%04x", (int) c));
                    } else {
                        escaped.append(c);
                    }
                    break;
            }
        }
        return escaped.toString();
    }

    private static void sendSmtp(String host, int port, boolean ssl, boolean startTls,
                                 String username, String password, String from, String to,
                                 String subject, String body) throws Exception {
        Socket socket = ssl
                ? SSLSocketFactory.getDefault().createSocket(host, port)
                : new Socket(host, port);

        SmtpSession smtp = new SmtpSession(socket);
        try {
            smtp.expect(220);
            smtp.command("EHLO localhost", 250);

            if (startTls && !ssl) {
                smtp.command("STARTTLS", 220);
                SSLSocketFactory sslFactory = (SSLSocketFactory) SSLSocketFactory.getDefault();
                socket = sslFactory.createSocket(socket, host, port, true);
                smtp = new SmtpSession(socket);
                smtp.command("EHLO localhost", 250);
            }

            if (!isBlank(username) && !isBlank(password)) {
                smtp.command("AUTH LOGIN", 334);
                smtp.command(Base64.getEncoder().encodeToString(username.getBytes(StandardCharsets.UTF_8)), 334);
                smtp.command(Base64.getEncoder().encodeToString(password.getBytes(StandardCharsets.UTF_8)), 235);
            }

            smtp.command("MAIL FROM:<" + from + ">", 250);
            smtp.command("RCPT TO:<" + to + ">", 250, 251);
            smtp.command("DATA", 354);
            smtp.data(buildMessage(from, to, subject, body));
            smtp.expect(250);
            smtp.command("QUIT", 221);
        } finally {
            try { socket.close(); } catch (Exception ignored) {}
        }
    }

    private static String buildMessage(String from, String to, String subject, String body) {
        StringBuilder message = new StringBuilder();
        message.append("From: ").append(from).append("\r\n");
        message.append("To: ").append(to).append("\r\n");
        message.append("Subject: ").append(subject).append("\r\n");
        message.append("MIME-Version: 1.0\r\n");
        message.append("Content-Type: text/plain; charset=UTF-8\r\n");
        message.append("\r\n");

        String[] lines = body.split("\\r?\\n", -1);
        for (String line : lines) {
            if (line.startsWith(".")) {
                message.append(".");
            }
            message.append(line).append("\r\n");
        }
        message.append(".");
        return message.toString();
    }

    private static String setting(ServletContext context, String name) {
        String value = context.getInitParameter(name);
        if (isBlank(value)) {
            value = System.getenv(name);
        }
        return value == null ? "" : value.trim();
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private static boolean parseBoolean(String value, boolean defaultValue) {
        if (isBlank(value)) {
            return defaultValue;
        }
        return "true".equalsIgnoreCase(value) || "yes".equalsIgnoreCase(value) || "1".equals(value);
    }

    private static int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private static String safeName(String username) {
        return isBlank(username) ? "there" : username.replaceAll("[\\r\\n]", "");
    }

    private static class SmtpSession {
        private final Socket socket;
        private final BufferedReader reader;
        private final BufferedWriter writer;

        SmtpSession(Socket socket) throws Exception {
            this.socket = socket;
            this.reader = new BufferedReader(new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
            this.writer = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream(), StandardCharsets.UTF_8));
        }

        void command(String command, int... expectedCodes) throws Exception {
            writer.write(command);
            writer.write("\r\n");
            writer.flush();
            expect(expectedCodes);
        }

        void data(String message) throws Exception {
            writer.write(message);
            writer.write("\r\n");
            writer.flush();
        }

        void expect(int... expectedCodes) throws Exception {
            int code = readResponseCode();
            for (int expected : expectedCodes) {
                if (code == expected) {
                    return;
                }
            }
            throw new IllegalStateException("Unexpected SMTP response code: " + code);
        }

        private int readResponseCode() throws Exception {
            String line = reader.readLine();
            if (line == null || line.length() < 3) {
                throw new IllegalStateException("Empty SMTP response");
            }

            String codeText = line.substring(0, 3);
            while (line.length() > 3 && line.charAt(3) == '-') {
                line = reader.readLine();
                if (line == null) {
                    break;
                }
            }
            return Integer.parseInt(codeText);
        }
    }
}
