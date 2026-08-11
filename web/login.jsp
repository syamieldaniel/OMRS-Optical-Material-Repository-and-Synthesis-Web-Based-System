<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; box-sizing: border-box; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; color: #111827; }

        .auth-page {
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            animation: pageFade 0.42s ease both;
        }

        .about-panel {
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

        .about-panel::after {
            content: "";
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(255,255,255,0.07) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.07) 1px, transparent 1px);
            background-size: 46px 46px;
            opacity: 0.32;
        }

        .about-content,
        .about-footer {
            position: relative;
            z-index: 1;
        }

        .about-content {
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

        .feature-card {
            background: rgba(255, 255, 255, 0.11);
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 1rem;
            padding: 1rem;
            transition: transform 0.22s ease, background-color 0.22s ease, border-color 0.22s ease;
        }

        .feature-card:hover {
            transform: translateY(-2px);
            background: rgba(255, 255, 255, 0.15);
            border-color: rgba(255, 255, 255, 0.28);
        }

        .form-panel {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .login-card {
            width: 100%;
            max-width: 430px;
            border-radius: 1.25rem;
            padding: 2rem;
            animation: slideInRight 0.52s ease both;
        }

        .input-field {
            background: #ffffff;
            border: 1px solid rgba(124, 58, 237, 0.18);
            color: #111827;
            transition: all 0.2s ease;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
            font-weight: 500;
        }

        .input-field:focus {
            border-color: #7c3aed;
            box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.14);
            outline: none;
        }

        .input-field::placeholder {
            color: rgba(31, 41, 55, 0.55);
        }

        .btn-primary {
            background: linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%);
            color: #ffffff;
            transition: all 0.2s ease;
            box-shadow: 0 12px 24px rgba(124, 58, 237, 0.24);
            font-weight: 700;
        }

        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 16px 30px rgba(124, 58, 237, 0.30);
            background: linear-gradient(135deg, #6d28d9 0%, #5b21b6 100%);
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
            .auth-page,
            .about-content,
            .login-card,
            .feature-card,
            .btn-primary,
            .input-field,
            .link-primary {
                animation: none;
                transition: none;
            }
        }

        @media (max-width: 960px) {
            .auth-page {
                grid-template-columns: 1fr;
            }

            .about-panel {
                padding: 2rem 1.25rem;
            }

            .about-footer {
                display: none;
            }

            .form-panel {
                padding: 1.25rem;
            }
        }
    </style>
</head>
<body>
    <main class="auth-page">
        <section class="about-panel">
            <div class="about-content">
                <a href="${pageContext.request.contextPath}/index.jsp" class="inline-flex items-center gap-3 mb-14">
                    <span class="brand-badge">
                        <i class="fas fa-flask text-xl text-white"></i>
                    </span>
                    <span>
                        <span class="block text-2xl font-extrabold leading-none">OMRS</span>
                        <span class="block text-xs text-purple-100 mt-1 max-w-xs">Optical Material Repository and Synthesis Web Based System</span>
                    </span>
                </a>

                <p class="text-amber-300 text-sm font-bold uppercase tracking-wide mb-3">Research workflow platform</p>
                <h1 class="text-4xl lg:text-5xl font-extrabold leading-tight max-w-3xl mb-5">
                    One workspace for experiments, logbooks, reviews, and learning materials.
                </h1>
                <p class="text-purple-100 text-lg max-w-2xl mb-10">
                    Access your OMRS dashboard to manage optical material studies, supervisor feedback, repository records, and academic progress.
                </p>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 max-w-4xl">
                    <div class="feature-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-vial text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Experiments</h2>
                        <p class="text-sm text-purple-100">Submit optical material data and supporting files.</p>
                    </div>
                    <div class="feature-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-user-check text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Review</h2>
                        <p class="text-sm text-purple-100">Track supervisor approval and feedback.</p>
                    </div>
                    <div class="feature-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-book-open text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Learning</h2>
                        <p class="text-sm text-purple-100">Use shared resources, quizzes, and repository content.</p>
                    </div>
                </div>
            </div>

            <div class="about-footer">
                <div class="flex items-center gap-6 text-sm text-purple-100">
                    <span><i class="fas fa-shield-halved text-amber-300 mr-2"></i>Role-based access</span>
                    <span><i class="fas fa-database text-amber-300 mr-2"></i>Central research records</span>
                    <span><i class="fas fa-chart-line text-amber-300 mr-2"></i>Progress tracking</span>
                </div>
            </div>
        </section>

        <section class="form-panel">
            <div class="login-card glass">
                <div class="mb-8">
                    <div class="w-12 h-12 rounded-xl bg-purple-100 flex items-center justify-center mb-5">
                        <i class="fas fa-arrow-right-to-bracket text-purple-700"></i>
                    </div>
                    <h2 class="text-3xl font-extrabold text-gray-900 mb-2">Welcome back</h2>
                    <p class="text-gray-700 font-medium">Sign in to continue to your dashboard.</p>
                </div>

                <% if (request.getAttribute("error") != null) { %>
                <div class="bg-red-50 border border-red-300 text-red-700 px-4 py-3 rounded-xl mb-6 flex gap-3">
                    <i class="fas fa-circle-exclamation mt-1"></i>
                    <span class="text-sm font-semibold"><%= request.getAttribute("error") %></span>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/login" method="POST" class="space-y-5">
                    <div>
                        <label class="block text-gray-800 text-sm font-bold mb-2">Role</label>
                        <div class="relative">
                            <i class="fas fa-id-badge absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <select name="role" required class="input-field w-full pl-11 pr-10 py-3 rounded-xl appearance-none">
                                <option value="">Select your role</option>
                                <option value="STUDENT">Student</option>
                                <option value="SUPERVISOR">Supervisor</option>
                                <option value="RESEARCHER">Researcher</option>
                            </select>
                            <i class="fas fa-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-gray-500 pointer-events-none text-xs"></i>
                        </div>
                    </div>

                    <div>
                        <label class="block text-gray-800 text-sm font-bold mb-2">Username</label>
                        <div class="relative">
                            <i class="fas fa-user absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="text" name="username" required placeholder="Enter your username"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl">
                        </div>
                    </div>

                    <div>
                        <div class="flex items-center justify-between gap-4 mb-2">
                            <label class="block text-gray-800 text-sm font-bold">Password</label>
                            <a href="${pageContext.request.contextPath}/reset-password" class="link-primary text-sm">Forgot password?</a>
                        </div>
                        <div class="relative">
                            <i class="fas fa-lock absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="password" name="password" id="password" required placeholder="Enter your password"
                                   class="input-field w-full pl-11 pr-12 py-3 rounded-xl">
                            <button type="button" onclick="togglePasswordVisibility('password', 'passwordEyeIcon')" class="absolute right-4 top-1/2 -translate-y-1/2 text-purple-600 hover:text-purple-900 transition" aria-label="Show password">
                                <i class="fas fa-eye" id="passwordEyeIcon"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn-primary w-full py-3 rounded-xl inline-flex items-center justify-center gap-2 mt-2">
                        <i class="fas fa-arrow-right-to-bracket"></i>
                        Login
                    </button>
                </form>

                <div class="mt-7 pt-6 border-t border-purple-100 text-center">
                    <p class="text-sm text-gray-700 font-medium">
                        Don't have an account?
                        <a href="${pageContext.request.contextPath}/index.jsp" class="link-primary">Sign up here</a>
                    </p>
                </div>
            </div>
        </section>
    </main>
    <script>
        function togglePasswordVisibility(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (!input || !icon) return;

            const showPassword = input.type === 'password';
            input.type = showPassword ? 'text' : 'password';
            icon.classList.toggle('fa-eye', !showPassword);
            icon.classList.toggle('fa-eye-slash', showPassword);
            const button = icon.closest('button');
            if (button) {
                button.setAttribute('aria-label', showPassword ? 'Hide password' : 'Show password');
            }
        }
    </script>
</body>
</html>
