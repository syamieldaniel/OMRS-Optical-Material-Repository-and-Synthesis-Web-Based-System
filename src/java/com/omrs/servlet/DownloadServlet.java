package com.omrs.servlet;

import com.omrs.dao.RepositoryDAO;
import com.omrs.model.TestData;
import java.io.IOException;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet for downloading test data files from experiments
 */
@WebServlet(name = "DownloadServlet", urlPatterns = {"/download/*"})
public class DownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        // Extract testDataId from either path parameter or query parameter
        String testDataId = null;
        
        // Try path parameter first (e.g., /download/TD-001)
        if (pathInfo != null && !pathInfo.equals("/")) {
            testDataId = pathInfo.substring(1);
        } else {
            // Try query parameter (e.g., ?testDataId=TD-001)
            testDataId = request.getParameter("testDataId");
            // Fallback to file parameter for backward compatibility
            if (testDataId == null) {
                testDataId = request.getParameter("file");
            }
        }
        
        if (testDataId == null || testDataId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Test data ID is required");
            return;
        }
        
        // Retrieve test data information from database
        RepositoryDAO dao = new RepositoryDAO();
        TestData testData = dao.getTestDataById(testDataId);

        if (testData == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Test data not found");
            return;
        }
        
        String filePath = testData.getFilePath();
        File file = resolveUploadedFile(request, filePath);

        if (file == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Uploaded file is missing. Ask the student to re-upload the file.");
            return;
        }
        
        try {
            // Determine content type based on file extension
            String fileName = testData.getFileName().toLowerCase();
            String contentType = "application/octet-stream";
            boolean isViewable = false;
            
            if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
                contentType = "image/jpeg";
                isViewable = true;
            } else if (fileName.endsWith(".png")) {
                contentType = "image/png";
                isViewable = true;
            } else if (fileName.endsWith(".gif")) {
                contentType = "image/gif";
                isViewable = true;
            } else if (fileName.endsWith(".svg")) {
                contentType = "image/svg+xml";
                isViewable = true;
            } else if (fileName.endsWith(".tif") || fileName.endsWith(".tiff")) {
                contentType = "image/tiff";
                isViewable = true;
            } else if (fileName.endsWith(".txt")) {
                contentType = "text/plain";
                isViewable = true;
            } else if (fileName.endsWith(".csv")) {
                contentType = "text/csv";
                isViewable = true;
            } else if (fileName.endsWith(".dat")) {
                contentType = "text/plain";
                isViewable = true;
            } else if (fileName.endsWith(".pdf")) {
                contentType = "application/pdf";
                isViewable = true;
            }
            
            // Set response headers
            response.setContentType(contentType);
            
            // Check if this is a view request
            String action = request.getParameter("action");
            if ("view".equals(action) && isViewable) {
                // For viewing, use inline disposition
                response.setHeader("Content-Disposition", "inline; filename=\"" + testData.getFileName() + "\"");
            } else {
                // For downloading, use attachment disposition
                response.setHeader("Content-Disposition", "attachment; filename=\"" + testData.getFileName() + "\"");
            }
            
            response.setContentLength((int) file.length());

            // Write file to response output stream
            try (FileInputStream fis = new FileInputStream(file);
                 OutputStream out = response.getOutputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
                out.flush();
            }
        } catch (IOException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error downloading file: " + e.getMessage());
        }
    }

    private File resolveUploadedFile(HttpServletRequest request, String storedPath) {
        if (storedPath == null || storedPath.trim().isEmpty()) {
            return null;
        }

        String normalized = storedPath.replace("\\", "/");
        String relative = normalized.startsWith("/") ? normalized.substring(1) : normalized;
        List<File> candidates = new ArrayList<>();

        String realPath = request.getServletContext().getRealPath(normalized);
        if (realPath != null) {
            candidates.add(new File(realPath));
        }

        String appRoot = request.getServletContext().getRealPath("/");
        if (appRoot != null) {
            candidates.add(new File(appRoot, relative));
        }

        String uploadBase = firstNonBlank(
                getServletContext().getInitParameter("OMRS_UPLOAD_DIR"),
                System.getProperty("omrs.upload.dir"),
                System.getenv("OMRS_UPLOAD_DIR"));
        if (uploadBase != null) {
            candidates.add(new File(uploadBase, relative.replaceFirst("^uploads/", "")));
            candidates.add(new File(uploadBase, relative));
        }

        String userDir = System.getProperty("user.dir");
        if (userDir != null) {
            candidates.add(new File(userDir, "web/" + relative));
            candidates.add(new File(userDir, "build/web/" + relative));
        }

        String userHome = System.getProperty("user.home");
        if (userHome != null) {
            candidates.add(new File(userHome + File.separator + ".omrs" + File.separator + "uploads",
                    relative.replaceFirst("^uploads/", "")));
        }

        for (File candidate : candidates) {
            if (candidate != null && candidate.exists() && candidate.isFile() && candidate.canRead()) {
                return candidate;
            }
        }

        return null;
    }

    private String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }
        return null;
    }
}
