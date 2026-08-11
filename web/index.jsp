<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; box-sizing: border-box; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; color: #111827; }

        .entry-page {
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            animation: pageFade 0.42s ease both;
        }

        .intro-panel {
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 3.5rem;
            overflow: hidden;
            background:
                radial-gradient(circle at 16% 12%, rgba(251, 191, 36, 0.20), transparent 26%),
                linear-gradient(135deg, #4c1d95 0%, #5b21b6 46%, #6d28d9 100%);
            color: #ffffff;
        }

        .intro-panel::after {
            content: "";
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(255,255,255,0.07) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.07) 1px, transparent 1px);
            background-size: 46px 46px;
            opacity: 0.32;
        }

        .intro-content,
        .intro-footer {
            position: relative;
            z-index: 1;
        }

        .intro-footer {
            margin-top: 3rem;
            padding-top: 1.5rem;
            border-top: 1px solid rgba(255, 255, 255, 0.16);
        }

        .footer-links {
            display: flex;
            align-items: center;
            gap: 1.25rem;
            flex-wrap: wrap;
        }

        .footer-links span {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            min-height: 2rem;
            padding: 0.35rem 0;
        }

        .intro-content {
            animation: slideInLeft 0.52s ease both;
        }

        .brand-badge {
            width: 3.25rem;
            height: 3.25rem;
            border-radius: 1rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.16);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }

        .glass {
            background: rgba(255, 255, 255, 0.88);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(167, 139, 250, 0.22);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
        }

        .module-card {
            background: rgba(255, 255, 255, 0.11);
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 1rem;
            padding: 1rem;
            transition: transform 0.22s ease, background-color 0.22s ease, border-color 0.22s ease;
        }

        .module-card:hover {
            transform: translateY(-2px);
            background: rgba(255, 255, 255, 0.15);
            border-color: rgba(255, 255, 255, 0.28);
        }

        .role-panel {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .role-card {
            width: 100%;
            max-width: 430px;
            border-radius: 1.25rem;
            padding: 2rem;
            animation: slideInRight 0.52s ease both;
        }

        .alert-success {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
        }

        .alert-error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
        }

        .role-option {
            display: flex;
            gap: 1rem;
            align-items: flex-start;
            padding: 1rem;
            border-radius: 1rem;
            background: #ffffff;
            border: 1.5px solid rgba(124, 58, 237, 0.14);
            box-shadow: 0 4px 12px rgba(167, 139, 250, 0.10);
            transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .role-option:hover {
            transform: translateY(-2px);
            border-color: rgba(124, 58, 237, 0.36);
            box-shadow: 0 12px 24px rgba(167, 139, 250, 0.18);
        }

        .role-icon {
            width: 3rem;
            height: 3rem;
            flex: 0 0 3rem;
            border-radius: 0.9rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #f3e8ff;
            color: #6d28d9;
        }

        .role-arrow {
            margin-left: auto;
            color: #7c3aed;
            padding-top: 0.35rem;
        }

        .link-primary {
            color: #6d28d9;
            font-weight: 700;
            transition: color 0.2s ease;
        }

        .link-primary:hover {
            color: #4c1d95;
        }

        @keyframes pageFade {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideInLeft {
            from { opacity: 0; transform: translateX(-14px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(14px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @media (prefers-reduced-motion: reduce) {
            .entry-page,
            .intro-content,
            .role-card,
            .module-card,
            .role-option,
            .link-primary {
                animation: none;
                transition: none;
            }
        }

        @media (max-width: 960px) {
            .entry-page {
                grid-template-columns: 1fr;
            }

            .intro-panel {
                padding: 2rem 1.25rem;
            }

            .intro-footer {
                display: none;
            }

            .role-panel {
                padding: 1.25rem;
            }
        }
    </style>
</head>
<body>
    <main class="entry-page">
        <section class="intro-panel">
            <div class="intro-content">
                <div class="inline-flex items-center gap-3 mb-14">
                    <span class="brand-badge">
                        <i class="fas fa-flask text-xl text-white"></i>
                    </span>
                    <span>
                        <span class="block text-2xl font-extrabold leading-none">OMRS</span>
                        <span class="block text-xs text-purple-100 mt-1 max-w-xs">Optical Material Repository and Synthesis Web Based System</span>
                    </span>
                </div>

                <p class="text-amber-300 text-sm font-bold uppercase tracking-wide mb-3">Academic research management</p>
                <h1 class="text-4xl lg:text-5xl font-extrabold leading-tight max-w-3xl mb-5">
                    Start your research workflow with the right role.
                </h1>
                <p class="text-purple-100 text-lg max-w-2xl mb-10">
                    OMRS connects students, supervisors, and researchers through experiment records, learning materials, repository browsing, and structured review.
                </p>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-3xl">
                    <div class="module-card">
                        <i class="fas fa-flask text-amber-300 text-xl mb-4"></i>
                        <h2 class="font-bold mb-1">Experiment records</h2>
                        <p class="text-sm text-purple-100">Create optical material studies and upload supporting characterization files.</p>
                    </div>
                    <div class="module-card">
                        <i class="fas fa-book text-amber-300 text-xl mb-4"></i>
                        <h2 class="font-bold mb-1">Logbook tracking</h2>
                        <p class="text-sm text-purple-100">Keep FYP progress, supervisor guidance, and weekly notes organized.</p>
                    </div>
                    <div class="module-card">
                        <i class="fas fa-user-check text-amber-300 text-xl mb-4"></i>
                        <h2 class="font-bold mb-1">Supervisor approval</h2>
                        <p class="text-sm text-purple-100">Review student submissions and give clear feedback in one system.</p>
                    </div>
                    <div class="module-card">
                        <i class="fas fa-folder-open text-amber-300 text-xl mb-4"></i>
                        <h2 class="font-bold mb-1">Repository access</h2>
                        <p class="text-sm text-purple-100">Browse approved experiments and shared learning resources.</p>
                    </div>
                </div>
            </div>

            <div class="intro-footer">
                <div class="footer-links text-sm text-purple-100">
                    <span><i class="fas fa-graduation-cap text-amber-300"></i>Student learning</span>
                    <span><i class="fas fa-microscope text-amber-300"></i>Optical analysis</span>
                    <span><i class="fas fa-comments text-amber-300"></i>Feedback workflow</span>
                </div>
            </div>
        </section>

        <section class="role-panel">
            <div class="role-card glass">
                <div class="mb-8">
                    <div class="w-12 h-12 rounded-xl bg-purple-100 flex items-center justify-center mb-5">
                        <i class="fas fa-user-plus text-purple-700"></i>
                    </div>
                    <h2 class="text-3xl font-extrabold text-gray-900 mb-2">Create account</h2>
                    <p class="text-gray-700 font-medium">Choose your role to begin registration.</p>
                </div>

                <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error px-4 py-3 rounded-xl mb-6 flex gap-3">
                    <i class="fas fa-circle-exclamation mt-1"></i>
                    <span class="text-sm font-semibold"><%= request.getAttribute("error") %></span>
                </div>
                <% } %>
                <% if (request.getParameter("message") != null) { %>
                <div class="alert-success px-4 py-3 rounded-xl mb-6 flex gap-3">
                    <i class="fas fa-circle-check mt-1"></i>
                    <span class="text-sm font-semibold"><%= request.getParameter("message") %></span>
                </div>
                <% } %>

                <div class="space-y-4">
                    <a href="${pageContext.request.contextPath}/signup?role=STUDENT" class="role-option">
                        <span class="role-icon"><i class="fas fa-user-graduate"></i></span>
                        <span>
                            <span class="block font-bold text-gray-900">Student</span>
                            <span class="block text-sm text-gray-600 mt-1">Submit experiments, manage learning, and track progress.</span>
                        </span>
                        <i class="fas fa-chevron-right role-arrow"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/signup?role=SUPERVISOR" class="role-option">
                        <span class="role-icon"><i class="fas fa-chalkboard-user"></i></span>
                        <span>
                            <span class="block font-bold text-gray-900">Supervisor</span>
                            <span class="block text-sm text-gray-600 mt-1">Review student submissions, approvals, and logbooks.</span>
                        </span>
                        <i class="fas fa-chevron-right role-arrow"></i>
                    </a>

                    <a href="${pageContext.request.contextPath}/signup?role=RESEARCHER" class="role-option">
                        <span class="role-icon"><i class="fas fa-microscope"></i></span>
                        <span>
                            <span class="block font-bold text-gray-900">Researcher</span>
                            <span class="block text-sm text-gray-600 mt-1">Explore repository content and research resources.</span>
                        </span>
                        <i class="fas fa-chevron-right role-arrow"></i>
                    </a>
                </div>

                <div class="mt-7 pt-6 border-t border-purple-100 text-center">
                    <p class="text-sm text-gray-700 font-medium">
                        Already have an account?
                        <a href="${pageContext.request.contextPath}/login.jsp" class="link-primary">Login</a>
                    </p>
                </div>
            </div>
        </section>
    </main>
</body>
</html>
