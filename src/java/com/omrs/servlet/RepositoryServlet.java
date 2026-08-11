package com.omrs.servlet;

import com.omrs.dao.NotificationDAO;
import com.omrs.dao.RepositoryDAO;
import com.omrs.model.Experiment;
import com.omrs.model.User;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.util.*;

/**
 * Servlet controller for Repository module.
 * Handles browsing, searching, and viewing approved experiments.
 */
@WebServlet(name = "RepositoryServlet", urlPatterns = {
    "/repository",
    "/repository/",
    "/repository/browse",
    "/repository/browse/*",
    "/repository/search",
    "/repository/public",
    "/repository/view/*",
    "/repository/material/*"
})
public class RepositoryServlet extends HttpServlet {
    
    private RepositoryDAO repositoryDAO = new RepositoryDAO();
    private NotificationDAO notificationDAO = new NotificationDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String path = request.getServletPath();
        String pathInfo = request.getPathInfo();
        
        try {
            if ("/repository".equals(path) || "/repository/".equals(path)) {
                // Main repository page with statistics
                showMainPage(request, response);
            } else if ("/repository/browse".equals(path)) {
                // Browse all approved experiments
                showBrowsePage(request, response);
            } else if ("/repository/search".equals(path)) {
                // Search with filters
                showSearchResults(request, response);
            } else if ("/repository/public".equals(path)) {
                // Search external public research repositories
                showPublicRepository(request, response);
            } else if (path.startsWith("/repository/view") && pathInfo != null) {
                // View single experiment details
                String experimentId = pathInfo.substring(1);
                showExperimentDetail(request, response, experimentId);
            } else if (path.startsWith("/repository/material") && pathInfo != null) {
                // Browse by material type
                String materialType = java.net.URLDecoder.decode(pathInfo.substring(1), "UTF-8");
                showByMaterial(request, response, materialType);
            } else {
                showMainPage(request, response);
            }
        } catch (Exception e) {
            System.err.println("Repository Servlet Error: " + e.getMessage());
            e.printStackTrace(System.err);
            // Send detailed error for debugging
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<pre style='color:red;font-family:monospace;'>");
            response.getWriter().println("ERROR in RepositoryServlet: " + e.getMessage());
            response.getWriter().println("\nStack Trace:");
            e.printStackTrace(response.getWriter());
            response.getWriter().println("</pre>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();
        String pathInfo = request.getPathInfo();
        String action = request.getParameter("action");

        if (path.startsWith("/repository/view") && pathInfo != null && "comment".equals(action)) {
            User user = (User) session.getAttribute("user");
            String experimentId = pathInfo.substring(1);
            String commentText = request.getParameter("commentText");

            if (commentText != null && !commentText.trim().isEmpty()) {
                boolean saved = repositoryDAO.addComment(experimentId, user.getUserId(), commentText.trim());
                Integer ownerUserId = repositoryDAO.getExperimentOwnerUserId(experimentId);
                if (saved && ownerUserId != null && ownerUserId != user.getUserId()) {
                    notificationDAO.create(
                        ownerUserId,
                        "New repository comment",
                        displayName(user) + " commented on your approved material record.",
                        "/repository/view/" + experimentId + "#comments"
                    );
                }
            }

            response.sendRedirect(request.getContextPath() + "/repository/view/" + experimentId + "#comments");
            return;
        }

        if (path.startsWith("/repository/view") && pathInfo != null && "deleteComment".equals(action)) {
            User user = (User) session.getAttribute("user");
            String experimentId = pathInfo.substring(1);
            String commentId = request.getParameter("commentId");
            boolean moderator = "SUPERVISOR".equals(user.getRole());

            if (commentId != null && !commentId.trim().isEmpty()) {
                repositoryDAO.deleteComment(commentId, user.getUserId(), moderator);
            }

            response.sendRedirect(request.getContextPath() + "/repository/view/" + experimentId + "#comments");
            return;
        }

        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    private String displayName(User user) {
        return user.getFullName() != null && !user.getFullName().trim().isEmpty()
            ? user.getFullName() : user.getUsername();
    }
    
    /**
     * Show main repository page with statistics and categories
     */
    private void showMainPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Map<String, Object> stats = repositoryDAO.getStatistics();
        List<String> materialTypes = repositoryDAO.getMaterialTypes();
        
        // Ensure stats map has default values
        if (stats == null) {
            stats = new HashMap<>();
        }
        stats.putIfAbsent("totalExperiments", 0);
        stats.putIfAbsent("totalMaterials", 0);
        stats.putIfAbsent("totalTestData", 0);
        stats.putIfAbsent("recentExperiments", new ArrayList<>());
        stats.putIfAbsent("materialCounts", new HashMap<>());
        
        request.setAttribute("stats", stats);
        request.setAttribute("materialTypes", materialTypes != null ? materialTypes : new ArrayList<>());
        request.setAttribute("recentExperiments", stats.get("recentExperiments"));
        request.setAttribute("materialCounts", stats.get("materialCounts"));
        
        request.getRequestDispatcher("/pages/repository/index.jsp").forward(request, response);
    }
    
    /**
     * Show browse page with all approved experiments
     */
    private void showBrowsePage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Pagination
        int page = 1;
        int pageSize = 12;
        
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) page = Integer.parseInt(pageParam);
        } catch (NumberFormatException e) {}
        
        List<Experiment> experiments = repositoryDAO.getApprovedPaginated(page, pageSize);
        int totalCount = repositoryDAO.getTotalApprovedCount();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        List<String> materialTypes = repositoryDAO.getMaterialTypes();
        
        request.setAttribute("experiments", experiments);
        request.setAttribute("materialTypes", materialTypes);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("commentCounts", repositoryDAO.getCommentCounts(experiments));
        
        request.getRequestDispatcher("/pages/repository/browse.jsp").forward(request, response);
    }
    
    /**
     * Show search results with filters
     */
    private void showSearchResults(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String materialType = request.getParameter("material");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");
        String testType = request.getParameter("testType");
        
        List<Experiment> results = repositoryDAO.search(keyword, materialType, dateFrom, dateTo, testType);
        List<String> materialTypes = repositoryDAO.getMaterialTypes();
        
        request.setAttribute("experiments", results);
        request.setAttribute("materialTypes", materialTypes);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedMaterial", materialType);
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("selectedTestType", testType);
        request.setAttribute("resultCount", results.size());
        request.setAttribute("commentCounts", repositoryDAO.getCommentCounts(results));
        
        request.getRequestDispatcher("/pages/repository/search.jsp").forward(request, response);
    }

    private void showPublicRepository(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/pages/repository/public.jsp").forward(request, response);
    }
    
    /**
     * Show single experiment detail
     */
    private void showExperimentDetail(HttpServletRequest request, HttpServletResponse response, String experimentId)
            throws ServletException, IOException {
        
        Experiment experiment = repositoryDAO.getApprovedById(experimentId);
        
        if (experiment == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Experiment not found or not approved");
            return;
        }
        
        // Get related experiments (same material type)
        List<Experiment> related = repositoryDAO.getByMaterialType(experiment.getMaterialType());
        related.removeIf(e -> e.getExperimentId().equals(experimentId));
        if (related.size() > 4) related = related.subList(0, 4);
        
        request.setAttribute("experiment", experiment);
        request.setAttribute("relatedExperiments", related);
        request.setAttribute("comments", repositoryDAO.getComments(experimentId));
        
        request.getRequestDispatcher("/pages/repository/view.jsp").forward(request, response);
    }
    
    /**
     * Show experiments filtered by material type
     */
    private void showByMaterial(HttpServletRequest request, HttpServletResponse response, String materialType)
            throws ServletException, IOException {
        
        List<Experiment> experiments = repositoryDAO.getByMaterialType(materialType);
        List<String> materialTypes = repositoryDAO.getMaterialTypes();
        
        request.setAttribute("experiments", experiments);
        request.setAttribute("materialTypes", materialTypes);
        request.setAttribute("selectedMaterial", materialType);
        request.setAttribute("resultCount", experiments.size());
        request.setAttribute("commentCounts", repositoryDAO.getCommentCounts(experiments));
        
        request.getRequestDispatcher("/pages/repository/browse.jsp").forward(request, response);
    }
}
