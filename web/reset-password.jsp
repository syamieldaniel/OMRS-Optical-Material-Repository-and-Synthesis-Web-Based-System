<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; box-sizing: border-box; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; color: #111827; }

        .reset-page {
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

        .intro-content {
            animation: slideInLeft 0.52s ease both;
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

        .form-panel {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .reset-card {
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
            font-weight: 500;
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

        @media (max-width: 960px) {
            .reset-page {
                grid-template-columns: 1fr;
            }

            .intro-panel {
                padding: 2rem 1.25rem;
            }

            .intro-footer {
                display: none;
            }

            .form-panel {
                padding: 1.25rem;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .reset-page,
            .intro-content,
            .reset-card,
            .module-card,
            .btn-primary,
            .input-field,
            .link-primary {
                animation: none;
                transition: none;
            }
        }
    </style>
</head>
<body>
    <%
        String mode = (String) request.getAttribute("mode");
        if (mode == null) {
            mode = "request";
        }
        boolean resetMode = "reset".equals(mode);
        boolean invalidMode = "invalid".equals(mode);
        String resetToken = (String) request.getAttribute("token");
    %>
    <main class="reset-page">
        <section class="intro-panel">
            <div class="intro-content">
                <a href="${pageContext.request.contextPath}/index.jsp" class="inline-flex items-center gap-3 mb-14">
                    <span class="brand-badge">
                        <i class="fas fa-flask text-xl text-white"></i>
                    </span>
                    <span>
                        <span class="block text-2xl font-extrabold leading-none">OMRS</span>
                        <span class="block text-xs text-purple-100 mt-1 max-w-xs">Optical Material Repository and Synthesis Web Based System</span>
                    </span>
                </a>

                <p class="text-amber-300 text-sm font-bold uppercase tracking-wide mb-3">Account recovery</p>
                <h1 class="text-4xl lg:text-5xl font-extrabold leading-tight max-w-3xl mb-5">
                    Reset your password and return to your research workspace.
                </h1>
                <p class="text-purple-100 text-lg max-w-2xl mb-10">
                    Request a secure email link first, then use that one-time link to set a new password for your OMRS account.
                </p>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 max-w-4xl">
                    <div class="module-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-user-shield text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Request link</h2>
                        <p class="text-sm text-purple-100">Enter your registered username and email address.</p>
                    </div>
                    <div class="module-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-key text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Check email</h2>
                        <p class="text-sm text-purple-100">Open the secure reset link sent to your inbox.</p>
                    </div>
                    <div class="module-card">
                        <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                            <i class="fas fa-arrow-right-to-bracket text-amber-300"></i>
                        </div>
                        <h2 class="font-bold mb-1">Set password</h2>
                        <p class="text-sm text-purple-100">Create your new password from the emailed link.</p>
                    </div>
                </div>
            </div>

            <div class="intro-footer">
                <div class="footer-links text-sm text-purple-100">
                    <span><i class="fas fa-shield-halved text-amber-300"></i>Secure access</span>
                    <span><i class="fas fa-database text-amber-300"></i>Research records</span>
                    <span><i class="fas fa-comments text-amber-300"></i>Supervisor workflow</span>
                </div>
            </div>
        </section>

        <section class="form-panel">
            <div class="reset-card glass">
                <div class="mb-7">
                    <div class="w-12 h-12 rounded-xl bg-purple-100 flex items-center justify-center mb-5">
                        <i class="fas fa-key text-purple-700"></i>
                    </div>
                    <h2 class="text-3xl font-extrabold text-gray-900 mb-2"><%= resetMode ? "Create new password" : "Reset password" %></h2>
                    <p class="text-gray-700 font-medium">
                        <%= resetMode
                                ? "This secure link is active for your account. Choose a new password below."
                                : "Enter your account details and we will email a secure reset link." %>
                    </p>
                </div>

                <% if (request.getAttribute("success") != null) { %>
                <div class="bg-green-50 border border-green-300 text-green-700 px-4 py-3 rounded-xl mb-6 flex gap-3">
                    <i class="fas fa-circle-check mt-1"></i>
                    <span class="text-sm font-semibold"><%= request.getAttribute("success") %></span>
                </div>
                <% } %>

                <% if (request.getAttribute("error") != null) { %>
                <div class="bg-red-50 border border-red-300 text-red-700 px-4 py-3 rounded-xl mb-6 flex gap-3">
                    <i class="fas fa-circle-exclamation mt-1"></i>
                    <span class="text-sm font-semibold"><%= request.getAttribute("error") %></span>
                </div>
                <% } %>

                <% if (resetMode) { %>
                <form action="${pageContext.request.contextPath}/reset-password" method="POST" class="space-y-5">
                    <input type="hidden" name="token" value="<%= resetToken %>">
                    <div class="bg-purple-50 border border-purple-200 text-purple-800 px-4 py-3 rounded-xl flex gap-3">
                        <i class="fas fa-user-check mt-1"></i>
                        <span class="text-sm font-semibold">This reset link is valid. Set your new password below.</span>
                    </div>

                    <div>
                        <label class="block text-gray-800 text-sm font-bold mb-2">New Password</label>
                        <div class="relative">
                            <i class="fas fa-lock absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="password" name="newPassword" id="newPassword" required minlength="6" placeholder="Enter new password"
                                   class="input-field w-full pl-11 pr-12 py-3 rounded-xl">
                            <button type="button" onclick="togglePasswordVisibility('newPassword', 'newPasswordEyeIcon')" class="absolute right-4 top-1/2 -translate-y-1/2 text-purple-600 hover:text-purple-900 transition" aria-label="Show new password">
                                <i class="fas fa-eye" id="newPasswordEyeIcon"></i>
                            </button>
                        </div>
                    </div>

                    <div>
                        <label class="block text-gray-800 text-sm font-bold mb-2">Confirm Password</label>
                        <div class="relative">
                            <i class="fas fa-lock absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="password" name="confirmPassword" id="confirmPassword" required minlength="6" placeholder="Confirm new password"
                                   class="input-field w-full pl-11 pr-12 py-3 rounded-xl">
                            <button type="button" onclick="togglePasswordVisibility('confirmPassword', 'confirmPasswordEyeIcon')" class="absolute right-4 top-1/2 -translate-y-1/2 text-purple-600 hover:text-purple-900 transition" aria-label="Show confirm password">
                                <i class="fas fa-eye" id="confirmPasswordEyeIcon"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn-primary w-full py-3 rounded-xl mt-3 inline-flex items-center justify-center gap-2">
                        <i class="fas fa-rotate"></i>
                        Reset Password
                    </button>
                </form>
                <% } else { %>
                <form action="${pageContext.request.contextPath}/reset-password" method="POST" class="space-y-5">
                    <div>
                        <label class="block text-gray-800 text-sm font-bold mb-2">Username</label>
                        <div class="relative">
                            <i class="fas fa-user absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="text" name="username" required placeholder="Enter your username"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl">
                        </div>
                    </div>

                    <div>
                        <label class="block text-gray-800 text-sm font-bold mb-2">Email</label>
                        <div class="relative">
                            <i class="fas fa-envelope absolute left-4 top-1/2 -translate-y-1/2 text-purple-500"></i>
                            <input type="email" name="email" required placeholder="Enter your account email"
                                   class="input-field w-full pl-11 pr-4 py-3 rounded-xl">
                        </div>
                    </div>

                    <button type="submit" class="btn-primary w-full py-3 rounded-xl mt-3 inline-flex items-center justify-center gap-2">
                        <i class="fas fa-envelope"></i>
                        Email Reset Link
                    </button>
                </form>
                <% } %>

                <% if (invalidMode) { %>
                <div class="mt-5 text-center">
                    <a href="${pageContext.request.contextPath}/reset-password" class="link-primary text-sm inline-flex items-center gap-2">
                        <i class="fas fa-paper-plane"></i>
                        Request a new reset link
                    </a>
                </div>
                <% } %>

                <div class="mt-7 pt-6 border-t border-purple-100 text-center">
                    <a href="${pageContext.request.contextPath}/login" class="link-primary text-sm inline-flex items-center gap-2">
                        <i class="fas fa-arrow-left"></i>
                        Back to login
                    </a>
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
