<%@ page import="com.omrs.model.User" %>
<%
    User chatUser = (User) session.getAttribute("user");
    String chatRole = chatUser != null && chatUser.getRole() != null ? chatUser.getRole() : "GUEST";
%>
<style>
    .system-chat {
        position: fixed;
        right: 1.5rem;
        bottom: 1.5rem;
        width: min(380px, calc(100vw - 2rem));
        z-index: 80;
    }

    .system-chat-panel {
        max-height: 70vh;
        display: none;
    }

    .system-chat-panel.open {
        display: block;
    }

    .system-chat-card {
        background: rgba(255, 255, 255, 0.96);
        border: 1px solid rgba(167, 139, 250, 0.25);
        box-shadow: 0 18px 45px rgba(88, 28, 135, 0.18);
        backdrop-filter: blur(16px);
    }

    @media (max-width: 640px) {
        .system-chat {
            right: 1rem;
            bottom: 1rem;
        }
    }
</style>

<div class="system-chat">
    <div id="systemChatPanel" class="system-chat-panel system-chat-card rounded-2xl overflow-hidden mb-3">
        <div class="bg-purple-600 text-white px-5 py-4 flex items-center justify-between">
            <div>
                <p class="font-semibold">OMRS Assistant</p>
                <p class="text-xs text-purple-100">Repository and system navigation help</p>
            </div>
            <button type="button" onclick="toggleSystemChat()" class="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div id="systemChatMessages" class="h-80 overflow-y-auto p-4 space-y-3 bg-purple-50">
            <div class="max-w-[88%] rounded-xl bg-white border border-purple-100 p-3 text-sm text-gray-800">
                Hi! I can help you browse repository experiments, search by material, view approved records, download data, cite experiments, or find other OMRS pages.
            </div>
        </div>
        <div class="p-4 bg-white border-t border-purple-100">
            <div class="flex gap-2">
                <input type="text" id="systemChatInput" class="flex-1 px-3 py-2 rounded-lg border border-purple-200 focus:outline-none focus:ring-2 focus:ring-purple-200 text-sm" placeholder="Ask about OMRS or repository...">
                <button type="button" id="systemChatSend" onclick="sendSystemChatMessage()" class="px-4 py-2 rounded-lg bg-purple-600 text-white hover:bg-purple-700 text-sm">
                    <i class="fas fa-paper-plane"></i>
                </button>
            </div>
            <p id="systemChatStatus" class="hidden text-xs text-gray-600 mt-2"></p>
        </div>
    </div>
    <button type="button" onclick="toggleSystemChat()" class="ml-auto flex items-center gap-2 rounded-full bg-purple-600 text-white px-5 py-3 shadow-lg hover:bg-purple-700 transition">
        <i class="fas fa-comments"></i>
        <span class="font-semibold">Ask OMRS</span>
    </button>
</div>

<script>
    const systemChatRole = '<%= chatRole %>';
    const systemChatPage = document.title || 'Repository';

    function toggleSystemChat() {
        document.getElementById('systemChatPanel').classList.toggle('open');
    }

    function addSystemChatBubble(message, role) {
        const messages = document.getElementById('systemChatMessages');
        const bubble = document.createElement('div');
        bubble.className = role === 'user'
            ? 'ml-auto max-w-[88%] rounded-xl bg-purple-600 p-3 text-sm text-white'
            : 'max-w-[88%] rounded-xl bg-white border border-purple-100 p-3 text-sm text-gray-800 whitespace-pre-wrap';
        bubble.textContent = message;
        messages.appendChild(bubble);
        messages.scrollTop = messages.scrollHeight;
    }

    async function sendSystemChatMessage() {
        const input = document.getElementById('systemChatInput');
        const button = document.getElementById('systemChatSend');
        const status = document.getElementById('systemChatStatus');
        const question = input.value.trim();
        if (!question) return;

        addSystemChatBubble(question, 'user');
        input.value = '';
        button.disabled = true;
        button.classList.add('opacity-60');
        status.classList.remove('hidden', 'text-red-500');
        status.textContent = 'Thinking...';

        const params = new URLSearchParams();
        params.append('question', question);
        params.append('role', systemChatRole);
        params.append('currentPage', systemChatPage);

        try {
            const response = await fetch('${pageContext.request.contextPath}/ai/system-chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: params.toString()
            });
            const data = await response.json();
            if (!response.ok || !data.success) {
                throw new Error(data.message || 'Unable to answer right now.');
            }
            addSystemChatBubble(data.message, 'assistant');
            status.classList.add('hidden');
        } catch (error) {
            status.classList.add('text-red-500');
            status.textContent = error.message;
        } finally {
            button.disabled = false;
            button.classList.remove('opacity-60');
        }
    }

    const systemChatInput = document.getElementById('systemChatInput');
    if (systemChatInput) {
        systemChatInput.addEventListener('keydown', function(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                sendSystemChatMessage();
            }
        });
    }
</script>
