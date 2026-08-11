<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.omrs.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Quiz - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; box-sizing: border-box; }
        body { background: #f5f1ed; color: #1f2937; font-size: 15px; line-height: 1.6; }
        .surface { background: rgba(255,255,255,0.92); border: 1px solid rgba(148,163,184,0.22); box-shadow: 0 14px 34px rgba(15,23,42,0.07); }
        .hero { background: linear-gradient(135deg, #ffffff 0%, #f8fafc 50%, #f0fdfa 100%); border: 1px solid rgba(20,184,166,0.18); }
        .input-field { background: #fff; border: 1px solid rgba(124,58,237,0.20); transition: border-color .2s ease, box-shadow .2s ease; }
        .input-field:focus { border-color: #7c3aed; box-shadow: 0 0 0 3px rgba(124,58,237,.13); outline: none; }
        .btn-primary { background: #7c3aed; color: #fff; font-weight: 700; transition: background .2s ease, transform .2s ease; }
        .btn-primary:hover { background: #6d28d9; transform: translateY(-1px); }
        .question-card { background: #fff; border: 1px solid rgba(124,58,237,0.14); box-shadow: 0 10px 24px rgba(88,28,135,.06); }
        .option-letter { width: 2rem; height: 2rem; border-radius: .75rem; display: inline-flex; align-items: center; justify-content: center; background: #f3e8ff; color: #6d28d9; font-weight: 800; }
        .tool-btn { border: 1px solid #e5e7eb; background: #fff; color: #374151; }
        .tool-btn:hover { border-color: #c4b5fd; color: #6d28d9; }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
    %>
    <div class="flex min-h-screen">
        <%@ include file="../common/sidebar.jsp" %>

        <main class="flex-1 lg:ml-64 p-4 sm:p-6 lg:p-10 pt-20 lg:pt-10">
            <a href="${pageContext.request.contextPath}/learning/manage" class="inline-flex items-center text-purple-700 font-semibold text-sm mb-4">
                <i class="fas fa-arrow-left mr-2"></i>Back to Manage Content
            </a>

            <section class="hero rounded-2xl p-6 lg:p-8 mb-6">
                <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-5">
                    <div>
                        <div class="inline-flex items-center gap-2 rounded-full bg-white border border-teal-100 px-3 py-1 text-sm font-semibold text-teal-700 mb-4">
                            <i class="fas fa-square-poll-horizontal"></i>
                            Quiz Builder
                        </div>
                        <h1 class="text-3xl lg:text-4xl font-extrabold text-gray-950 mb-2">Create Learning Quiz</h1>
                        <p class="text-gray-700 max-w-3xl">Build short or long quizzes for students. Add as many questions as needed and include explanations for feedback after submission.</p>
                    </div>
                    <div class="grid grid-cols-2 gap-3 min-w-full sm:min-w-[320px]">
                        <div class="surface rounded-xl p-4">
                            <p class="text-xs text-gray-500 font-bold uppercase">Questions</p>
                            <p class="text-2xl font-extrabold text-gray-950" id="questionCount">1</p>
                        </div>
                        <div class="surface rounded-xl p-4">
                            <p class="text-xs text-gray-500 font-bold uppercase">Minimum</p>
                            <p class="text-2xl font-extrabold text-gray-950">1</p>
                        </div>
                    </div>
                </div>
            </section>

            <% if (request.getAttribute("error") != null) { %>
            <div class="mb-6 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-red-700">
                <i class="fas fa-circle-exclamation mr-2"></i><%= request.getAttribute("error") %>
            </div>
            <% } %>

            <form id="quizForm" action="${pageContext.request.contextPath}/learning/quiz/create" method="POST" class="space-y-6">
                <section class="surface rounded-2xl p-6 lg:p-8">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <div>
                            <label class="block text-sm font-bold mb-2 text-gray-800">Quiz Title <span class="text-red-500">*</span></label>
                            <input type="text" name="title" required class="input-field w-full px-4 py-3 rounded-xl" placeholder="Nanoparticle Optical Properties Quiz">
                        </div>
                        <div>
                            <label class="block text-sm font-bold mb-2 text-gray-800">Category</label>
                            <input type="text" name="category" class="input-field w-full px-4 py-3 rounded-xl" placeholder="Optical Properties">
                        </div>
                    </div>
                    <div class="mt-5">
                        <label class="block text-sm font-bold mb-2 text-gray-800">Description</label>
                        <textarea name="description" rows="3" class="input-field w-full px-4 py-3 rounded-xl" placeholder="Explain the focus of this quiz and what learners should revise first."></textarea>
                    </div>
                </section>

                <section class="surface rounded-2xl p-6 lg:p-8">
                    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-5">
                        <div>
                            <h2 class="text-xl font-bold text-gray-950">Questions</h2>
                            <p class="text-sm text-gray-600">Each saved question needs a prompt, four options, and one correct answer.</p>
                        </div>
                        <button type="button" id="addQuestionBtn" class="btn-primary rounded-xl px-5 py-3 inline-flex items-center justify-center gap-2">
                            <i class="fas fa-plus"></i>Add Question
                        </button>
                    </div>
                    <div id="questionsContainer" class="space-y-5"></div>
                </section>

                <div class="surface rounded-2xl p-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 sticky bottom-4 z-10">
                    <p class="text-sm text-gray-600"><span class="font-bold text-gray-900" id="footerQuestionCount">1</span> question block ready.</p>
                    <div class="flex gap-3">
                        <a href="${pageContext.request.contextPath}/learning/manage" class="rounded-xl border border-gray-200 bg-white px-5 py-3 text-gray-700 font-semibold">Cancel</a>
                        <button type="submit" class="btn-primary px-5 py-3 rounded-xl">
                            <i class="fas fa-paper-plane mr-2"></i>Publish Quiz
                        </button>
                    </div>
                </div>
            </form>
        </main>
    </div>

    <template id="questionTemplate">
        <section class="question-card rounded-2xl p-5" data-question-card>
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
                <h3 class="text-lg font-bold text-gray-950">Question <span data-question-number></span></h3>
                <div class="flex gap-2">
                    <button type="button" class="tool-btn rounded-xl px-3 py-2 text-sm font-semibold" data-duplicate-question>
                        <i class="fas fa-copy mr-1"></i>Duplicate
                    </button>
                    <button type="button" class="tool-btn rounded-xl px-3 py-2 text-sm font-semibold text-red-600" data-remove-question>
                        <i class="fas fa-trash mr-1"></i>Remove
                    </button>
                </div>
            </div>
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-bold mb-2 text-gray-800">Question Text</label>
                    <textarea name="questionText" rows="3" class="input-field w-full px-4 py-3 rounded-xl" placeholder="Enter the question prompt."></textarea>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <label class="block">
                        <span class="flex items-center gap-2 text-sm font-bold mb-2 text-gray-800"><span class="option-letter">A</span>Option A</span>
                        <input type="text" name="optionA" class="input-field w-full px-4 py-3 rounded-xl">
                    </label>
                    <label class="block">
                        <span class="flex items-center gap-2 text-sm font-bold mb-2 text-gray-800"><span class="option-letter">B</span>Option B</span>
                        <input type="text" name="optionB" class="input-field w-full px-4 py-3 rounded-xl">
                    </label>
                    <label class="block">
                        <span class="flex items-center gap-2 text-sm font-bold mb-2 text-gray-800"><span class="option-letter">C</span>Option C</span>
                        <input type="text" name="optionC" class="input-field w-full px-4 py-3 rounded-xl">
                    </label>
                    <label class="block">
                        <span class="flex items-center gap-2 text-sm font-bold mb-2 text-gray-800"><span class="option-letter">D</span>Option D</span>
                        <input type="text" name="optionD" class="input-field w-full px-4 py-3 rounded-xl">
                    </label>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-bold mb-2 text-gray-800">Correct Option</label>
                        <select name="correctOption" class="input-field w-full px-4 py-3 rounded-xl">
                            <option value="">Select</option>
                            <option value="A">A</option>
                            <option value="B">B</option>
                            <option value="C">C</option>
                            <option value="D">D</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-bold mb-2 text-gray-800">Explanation</label>
                        <input type="text" name="explanation" class="input-field w-full px-4 py-3 rounded-xl" placeholder="Optional feedback after submission">
                    </div>
                </div>
            </div>
        </section>
    </template>

    <script>
        const questionsContainer = document.getElementById('questionsContainer');
        const questionTemplate = document.getElementById('questionTemplate');
        const questionCount = document.getElementById('questionCount');
        const footerQuestionCount = document.getElementById('footerQuestionCount');
        const addQuestionBtn = document.getElementById('addQuestionBtn');

        function questionCards() {
            return Array.from(questionsContainer.querySelectorAll('[data-question-card]'));
        }

        function updateQuestionNumbers() {
            const cards = questionCards();
            cards.forEach((card, index) => {
                card.querySelector('[data-question-number]').textContent = index + 1;
                const removeButton = card.querySelector('[data-remove-question]');
                removeButton.disabled = cards.length === 1;
                removeButton.classList.toggle('opacity-40', cards.length === 1);
                removeButton.classList.toggle('cursor-not-allowed', cards.length === 1);
            });
            questionCount.textContent = cards.length;
            footerQuestionCount.textContent = cards.length;
        }

        function addQuestion(copyFrom) {
            const fragment = questionTemplate.content.cloneNode(true);
            const card = fragment.querySelector('[data-question-card]');
            questionsContainer.appendChild(fragment);

            if (copyFrom) {
                ['questionText', 'optionA', 'optionB', 'optionC', 'optionD', 'correctOption', 'explanation'].forEach(name => {
                    const source = copyFrom.querySelector('[name="' + name + '"]');
                    const target = card.querySelector('[name="' + name + '"]');
                    if (source && target) target.value = source.value;
                });
            }

            card.querySelector('[data-remove-question]').addEventListener('click', () => {
                if (questionCards().length > 1) {
                    card.remove();
                    updateQuestionNumbers();
                }
            });
            card.querySelector('[data-duplicate-question]').addEventListener('click', () => {
                addQuestion(card);
            });
            updateQuestionNumbers();
            return card;
        }

        addQuestion();
        addQuestionBtn.addEventListener('click', () => {
            const card = addQuestion();
            card.scrollIntoView({ behavior: 'smooth', block: 'center' });
        });
    </script>

    <%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>
