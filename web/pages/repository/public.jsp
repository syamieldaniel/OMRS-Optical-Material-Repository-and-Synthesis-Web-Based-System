<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.omrs.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Public Research Repository - OMRS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { font-family: 'Segoe UI', 'Trebuchet MS', sans-serif; }
        body { background: #f5f1ed; font-size: 15px; line-height: 1.6; }
        .glass { background: rgba(255, 255, 255, 0.88); backdrop-filter: blur(20px); border: 1px solid rgba(167, 139, 250, 0.2); box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08); }
        .repo-card { background: #ffffff; border: 1px solid rgba(124, 58, 237, 0.14); box-shadow: 0 10px 28px rgba(88, 28, 135, 0.08); transition: all 0.2s ease; }
        .repo-card:hover { transform: translateY(-2px); border-color: rgba(124, 58, 237, 0.30); box-shadow: 0 16px 34px rgba(88, 28, 135, 0.12); }
        .repo-hero { background: linear-gradient(135deg, #ffffff 0%, #f8fafc 52%, #f0fdfa 100%); border: 1px solid rgba(20, 184, 166, 0.18); }
        .search-input { border: 1px solid rgba(124, 58, 237, 0.18); background: #ffffff; box-shadow: 0 8px 20px rgba(88, 28, 135, 0.06); }
        .search-input:focus { border-color: #8b5cf6; box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.14); outline: none; }
        .btn-primary { background: #7c3aed; color: #ffffff; transition: all 0.2s ease; }
        .btn-primary:hover { background: #6d28d9; transform: translateY(-1px); }
        .source-pill { border: 1px solid rgba(20, 184, 166, 0.24); background: rgba(20, 184, 166, 0.10); color: #0f766e; }
    </style>
</head>
<body class="min-h-screen">
    <%
        User user = (User) session.getAttribute("user");
        String initialQuery = request.getParameter("query") != null ? request.getParameter("query") : "ZnO band gap UV-Vis";
        initialQuery = initialQuery.replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    %>
    <div class="flex min-h-screen">
        <%@ include file="../common/sidebar.jsp" %>

        <main class="flex-1 lg:ml-64 p-6 lg:p-10 pt-20 lg:pt-10">
            <div class="repo-hero rounded-2xl p-8 mb-8 shadow-sm">
                <div class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-6 mb-8">
                    <div>
                        <p class="text-sm font-semibold text-teal-700 mb-2">External Repository Search</p>
                        <h1 class="text-3xl lg:text-4xl font-bold text-gray-900 mb-2">Public Research Repository</h1>
                        <p class="text-gray-700 max-w-3xl">Search public research metadata from Crossref without leaving OMRS. Use it to find papers related to optical materials, characterization methods, DSSC, band gap, UV-Vis, SEM, XRD, and preparation methods.</p>
                    </div>
                    <div class="flex flex-wrap gap-2">
                        <a href="${pageContext.request.contextPath}/repository/browse" class="inline-flex items-center rounded-xl bg-purple-50 border border-purple-100 px-4 py-3 text-purple-700 font-semibold">
                            <i class="fas fa-database mr-2"></i>OMRS Records
                        </a>
                        <a href="${pageContext.request.contextPath}/repository/search" class="inline-flex items-center rounded-xl bg-purple-50 border border-purple-100 px-4 py-3 text-purple-700 font-semibold">
                            <i class="fas fa-filter mr-2"></i>Internal Search
                        </a>
                    </div>
                </div>

                <form id="publicSearchForm" class="grid grid-cols-1 xl:grid-cols-[1fr_auto] gap-4">
                    <div class="relative">
                        <input type="text" id="publicQuery" name="query" value="<%= initialQuery %>"
                               class="search-input w-full rounded-xl px-6 py-4 pl-12 text-gray-900"
                               placeholder="Search public papers, e.g. ZnO nanorod DSSC UV-Vis">
                        <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-500"></i>
                    </div>
                    <button type="submit" class="btn-primary rounded-xl px-7 py-4 font-semibold">
                        <i class="fas fa-globe mr-2"></i>Search Public API
                    </button>
                </form>

                <div class="mt-5 flex flex-wrap gap-2 text-sm">
                    <button type="button" data-suggestion="ZnO nanorod DSSC" class="suggestion rounded-full bg-white border border-purple-100 px-4 py-2 text-purple-700 font-semibold">ZnO nanorod DSSC</button>
                    <button type="button" data-suggestion="optical band gap UV-Vis semiconductor" class="suggestion rounded-full bg-white border border-purple-100 px-4 py-2 text-purple-700 font-semibold">Band gap UV-Vis</button>
                    <button type="button" data-suggestion="thin film optical characterization XRD SEM" class="suggestion rounded-full bg-white border border-purple-100 px-4 py-2 text-purple-700 font-semibold">XRD SEM thin film</button>
                    <button type="button" data-suggestion="natural dye sensitized solar cell optical material" class="suggestion rounded-full bg-white border border-purple-100 px-4 py-2 text-purple-700 font-semibold">Natural dye DSSC</button>
                </div>
            </div>

            <div id="publicStatus" class="glass rounded-2xl p-6 mb-6">
                <div class="flex items-center text-gray-700">
                    <i class="fas fa-circle-info text-purple-600 mr-3"></i>
                    <span>Enter a keyword to search public research metadata.</span>
                </div>
            </div>

            <div id="publicResults" class="grid grid-cols-1 xl:grid-cols-2 gap-6"></div>
        </main>
    </div>

    <script>
        const form = document.getElementById('publicSearchForm');
        const queryInput = document.getElementById('publicQuery');
        const statusBox = document.getElementById('publicStatus');
        const resultsBox = document.getElementById('publicResults');

        function escapeHtml(value) {
            return String(value || '').replace(/[&<>"']/g, function(character) {
                return {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#39;'
                }[character];
            });
        }

        function restoreAbstract(index) {
            if (!index) return '';
            const words = [];
            Object.keys(index).forEach(function(word) {
                index[word].forEach(function(position) {
                    words[position] = word;
                });
            });
            return words.filter(Boolean).join(' ');
        }

        function getAuthors(work) {
            if (!work.authorships || !work.authorships.length) return 'Unknown authors';
            return work.authorships.slice(0, 4).map(function(item) {
                return item.author && item.author.display_name ? item.author.display_name : 'Unknown';
            }).join(', ') + (work.authorships.length > 4 ? ' et al.' : '');
        }

        function getSource(work) {
            if (work.primary_location && work.primary_location.source && work.primary_location.source.display_name) {
                return work.primary_location.source.display_name;
            }
            return work.type ? work.type.replace(/_/g, ' ') : 'Public source';
        }

        function firstArrayValue(value, fallback) {
            return Array.isArray(value) && value.length ? value[0] : fallback;
        }

        function getCrossrefYear(item) {
            const dateParts = item.published && item.published['date-parts']
                    || item['published-print'] && item['published-print']['date-parts']
                    || item['published-online'] && item['published-online']['date-parts']
                    || item.issued && item.issued['date-parts'];
            return dateParts && dateParts[0] && dateParts[0][0] ? dateParts[0][0] : 'N/A';
        }

        function stripHtml(value) {
            const element = document.createElement('div');
            element.innerHTML = value || '';
            return element.textContent || element.innerText || '';
        }

        function normalizeCrossrefResults(data) {
            const items = data && data.message && data.message.items ? data.message.items : [];
            return items.map(function(item) {
                const title = firstArrayValue(item.title, 'Untitled public research record');
                const source = firstArrayValue(item['container-title'], item.publisher || item.type || 'Public source');
                const authors = (item.author || []).map(function(author) {
                    return [author.given, author.family].filter(Boolean).join(' ') || author.name || 'Unknown';
                });
                const concepts = (item.subject || []).slice(0, 4).map(function(subject) {
                    return { display_name: subject };
                });
                return {
                    display_name: title,
                    publication_year: getCrossrefYear(item),
                    type: item.type,
                    doi: item.URL || (item.DOI ? 'https://doi.org/' + item.DOI : '#'),
                    cited_by_count: item['is-referenced-by-count'] || 0,
                    abstract_text: stripHtml(item.abstract || ''),
                    primary_location: {
                        source: {
                            display_name: source
                        }
                    },
                    authorships: authors.map(function(name) {
                        return {
                            author: {
                                display_name: name
                            }
                        };
                    }),
                    concepts: concepts,
                    open_access: {
                        is_oa: Boolean(item.license && item.license.length)
                    }
                };
            });
        }

        function renderResults(works, query) {
            if (!works.length) {
                statusBox.innerHTML = '<div class="flex items-center text-gray-700"><i class="fas fa-magnifying-glass mr-3 text-purple-600"></i><span>No public results found for <strong>' + escapeHtml(query) + '</strong>.</span></div>';
                resultsBox.innerHTML = '';
                return;
            }

            statusBox.innerHTML = '<div class="flex flex-col md:flex-row md:items-center md:justify-between gap-2 text-gray-700"><span><i class="fas fa-check-circle mr-3 text-teal-600"></i>Showing ' + works.length + ' public results for <strong>' + escapeHtml(query) + '</strong>.</span><span class="text-sm text-gray-600">Source: Crossref public API</span></div>';
            resultsBox.innerHTML = works.map(function(work) {
                const title = work.display_name || 'Untitled public research record';
                const year = work.publication_year || 'N/A';
                const source = getSource(work);
                const authors = getAuthors(work);
                const abstractText = work.abstract_text || restoreAbstract(work.abstract_inverted_index);
                const shortAbstract = abstractText ? abstractText.substring(0, 260) + (abstractText.length > 260 ? '...' : '') : 'No abstract available from the public metadata.';
                const doiUrl = work.doi || work.id || '#';
                const concepts = (work.concepts || []).slice(0, 4).map(function(concept) {
                    return '<span class="rounded-full bg-purple-50 px-3 py-1 text-xs font-semibold text-purple-700 border border-purple-100">' + escapeHtml(concept.display_name) + '</span>';
                }).join('');
                const openAccess = work.open_access && work.open_access.is_oa;
                return '<article class="repo-card rounded-2xl p-6">' +
                    '<div class="flex flex-wrap items-center gap-2 mb-4">' +
                        '<span class="source-pill rounded-full px-3 py-1 text-xs font-bold">Crossref</span>' +
                        '<span class="rounded-full bg-gray-100 px-3 py-1 text-xs font-semibold text-gray-700">' + escapeHtml(year) + '</span>' +
                        (openAccess ? '<span class="rounded-full bg-green-50 px-3 py-1 text-xs font-semibold text-green-700 border border-green-100">Open Access</span>' : '') +
                    '</div>' +
                    '<h2 class="text-xl font-bold text-gray-900 mb-3 leading-snug">' + escapeHtml(title) + '</h2>' +
                    '<p class="text-sm text-purple-700 font-semibold mb-2">' + escapeHtml(authors) + '</p>' +
                    '<p class="text-sm text-gray-600 mb-4">' + escapeHtml(source) + '</p>' +
                    '<p class="text-gray-700 mb-5">' + escapeHtml(shortAbstract) + '</p>' +
                    '<div class="flex flex-wrap gap-2 mb-5">' + concepts + '</div>' +
                    '<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 pt-4 border-t border-purple-100">' +
                        '<span class="text-sm text-gray-600"><i class="fas fa-quote-right mr-2 text-purple-500"></i>' + (work.cited_by_count || 0) + ' citations</span>' +
                        '<a href="' + escapeHtml(doiUrl) + '" target="_blank" rel="noopener" class="inline-flex items-center justify-center rounded-xl bg-purple-600 px-4 py-2 text-white font-semibold">' +
                            '<i class="fas fa-up-right-from-square mr-2"></i>Open Source' +
                        '</a>' +
                    '</div>' +
                '</article>';
            }).join('');
        }

        async function searchPublicRepository(query) {
            const cleanQuery = query.trim();
            if (!cleanQuery) return;
            statusBox.innerHTML = '<div class="flex items-center text-gray-700"><i class="fas fa-spinner fa-spin mr-3 text-purple-600"></i><span>Searching public research metadata...</span></div>';
            resultsBox.innerHTML = '';
            const url = '${pageContext.request.contextPath}/api/repository/public-search?query=' + encodeURIComponent(cleanQuery);
            try {
                const response = await fetch(url, { headers: { 'Accept': 'application/json' } });
                const data = await response.json();
                if (!response.ok) throw new Error(data.error || 'Public search returned status ' + response.status);
                renderResults(normalizeCrossrefResults(data), cleanQuery);
                const pageUrl = new URL(window.location.href);
                pageUrl.searchParams.set('query', cleanQuery);
                window.history.replaceState({}, '', pageUrl.toString());
            } catch (error) {
                statusBox.innerHTML = '<div class="flex flex-col gap-2 text-red-700"><div class="flex items-center"><i class="fas fa-triangle-exclamation mr-3"></i><span>Public search is unavailable right now.</span></div><p class="text-sm text-red-600 ml-7">' + escapeHtml(error.message || 'Check server internet access and try again.') + '</p><a href="https://search.crossref.org/?q=' + encodeURIComponent(cleanQuery) + '" target="_blank" rel="noopener" class="ml-7 text-sm font-semibold text-purple-700 hover:text-purple-900">Open this search directly on Crossref</a></div>';
            }
        }

        form.addEventListener('submit', function(event) {
            event.preventDefault();
            searchPublicRepository(queryInput.value);
        });

        document.querySelectorAll('.suggestion').forEach(function(button) {
            button.addEventListener('click', function() {
                queryInput.value = button.dataset.suggestion;
                searchPublicRepository(queryInput.value);
            });
        });

        if (queryInput.value.trim()) {
            searchPublicRepository(queryInput.value);
        }
    </script>
    <%@ include file="../common/system-chatbot.jsp" %>
    <%@ include file="../common/sidebar-style.jsp" %>
</body>
</html>
