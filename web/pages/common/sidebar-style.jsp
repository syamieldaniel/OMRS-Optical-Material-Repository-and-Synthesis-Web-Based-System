<style>
    .sidebar {
        width: 17rem !important;
        background:
            radial-gradient(circle at 18% 8%, rgba(251, 191, 36, 0.18), transparent 28%),
            linear-gradient(180deg, #4c1d95 0%, #5b21b6 45%, #6d28d9 100%) !important;
        border-right: 1px solid rgba(255, 255, 255, 0.12) !important;
        box-shadow: 18px 0 45px rgba(76, 29, 149, 0.18) !important;
    }

    .sidebar .p-6 {
        padding: 1.5rem 1.25rem !important;
    }

    .sidebar nav {
        gap: 0.35rem !important;
    }

    .sidebar .w-12.h-12 {
        border-radius: 1rem !important;
        background: rgba(255, 255, 255, 0.16) !important;
        border: 1px solid rgba(255, 255, 255, 0.18) !important;
        box-shadow: none !important;
    }

    .nav-item {
        position: relative !important;
        min-height: 2.85rem !important;
        border-radius: 0.85rem !important;
        color: rgba(255, 255, 255, 0.78) !important;
        background: transparent !important;
        border: 1px solid transparent !important;
        box-shadow: none !important;
        font-weight: 600 !important;
        letter-spacing: 0 !important;
        transition: transform 0.18s ease, background-color 0.18s ease, color 0.18s ease, border-color 0.18s ease !important;
    }

    .nav-item:hover {
        transform: translateX(2px) !important;
        color: #ffffff !important;
        background: rgba(255, 255, 255, 0.10) !important;
        border-color: rgba(255, 255, 255, 0.12) !important;
    }

    .nav-item.active {
        color: #ffffff !important;
        background: rgba(255, 255, 255, 0.16) !important;
        border: 1px solid rgba(255, 255, 255, 0.18) !important;
        box-shadow: inset 3px 0 0 #fbbf24, 0 10px 24px rgba(31, 11, 70, 0.18) !important;
    }

    .nav-item i:first-child {
        width: 1.5rem !important;
        min-width: 1.5rem !important;
        height: 1.5rem !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        color: inherit !important;
        opacity: 0.95 !important;
    }

    .sidebar .absolute.bottom-0 {
        padding: 1.25rem !important;
        background: rgba(31, 11, 70, 0.18) !important;
        border-top: 1px solid rgba(255, 255, 255, 0.12) !important;
        backdrop-filter: blur(12px) !important;
    }

    .sidebar .absolute.bottom-0 .w-10 {
        box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.12) !important;
    }

    .sidebar [id*="repo-dropdown"] {
        position: static !important;
        width: auto !important;
        margin: 0.35rem 0 0.35rem 1rem !important;
        padding: 0.35rem !important;
        overflow: hidden !important;
        background: rgba(255, 255, 255, 0.09) !important;
        border: 1px solid rgba(255, 255, 255, 0.12) !important;
        border-radius: 0.85rem !important;
        box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.08) !important;
    }

    .sidebar [id*="repo-dropdown"].hidden {
        display: none !important;
    }

    .sidebar [id*="repo-dropdown"] a {
        display: flex !important;
        align-items: center !important;
        min-height: 2.35rem !important;
        padding: 0.55rem 0.75rem !important;
        color: rgba(255, 255, 255, 0.76) !important;
        background: transparent !important;
        border-radius: 0.65rem !important;
        font-weight: 600 !important;
        transition: background-color 0.18s ease, color 0.18s ease, transform 0.18s ease !important;
    }

    .sidebar [id*="repo-dropdown"] a:hover {
        transform: translateX(2px) !important;
        color: #ffffff !important;
        background: rgba(255, 255, 255, 0.12) !important;
    }

    .sidebar [id*="repo-dropdown"] a i {
        color: inherit !important;
        opacity: 0.9 !important;
    }

    @media (min-width: 1024px) {
        .lg\:ml-64 {
            margin-left: 17rem !important;
        }
    }

    .omrs-mobile-menu-button,
    .omrs-mobile-sidebar-overlay {
        display: none;
    }

    @media (max-width: 1023px) {
        html {
            -webkit-text-size-adjust: 100%;
        }

        body.mobile-sidebar-open {
            overflow: hidden;
        }

        .omrs-mobile-menu-button {
            position: fixed;
            top: 0.85rem;
            left: 0.85rem;
            z-index: 95;
            display: inline-flex !important;
            align-items: center;
            gap: 0.55rem;
            min-height: 2.75rem;
            padding: 0 0.9rem;
            border-radius: 999px;
            border: 1px solid rgba(124, 58, 237, 0.22);
            background: rgba(255, 255, 255, 0.96);
            color: #5b21b6;
            box-shadow: 0 12px 30px rgba(88, 28, 135, 0.18);
            font-weight: 800;
            letter-spacing: 0;
            backdrop-filter: blur(14px);
        }

        .omrs-mobile-menu-button i,
        .omrs-mobile-menu-button span {
            color: inherit !important;
        }

        .omrs-mobile-sidebar-overlay {
            position: fixed;
            inset: 0;
            z-index: 90;
            display: block !important;
            pointer-events: none;
            opacity: 0;
            background: rgba(15, 23, 42, 0.48);
            transition: opacity 0.22s ease;
        }

        .omrs-mobile-sidebar-overlay.mobile-open {
            pointer-events: auto;
            opacity: 1;
        }

        .sidebar {
            top: 0 !important;
            left: 0 !important;
            z-index: 100 !important;
            display: block !important;
            width: min(17rem, calc(100vw - 3.5rem)) !important;
            height: 100dvh !important;
            max-height: 100dvh !important;
            overflow-y: auto !important;
            padding-bottom: 6.5rem !important;
            transform: translateX(-105%);
            transition: transform 0.24s ease;
            box-shadow: 18px 0 45px rgba(31, 11, 70, 0.32) !important;
        }

        .sidebar.mobile-open {
            transform: translateX(0);
        }

        .sidebar .p-6 {
            padding-top: 4.5rem !important;
        }

        .sidebar .absolute.bottom-0 {
            position: fixed !important;
            width: min(17rem, calc(100vw - 3.5rem)) !important;
        }

        main.flex-1,
        .flex-1.lg\:ml-64 {
            width: 100% !important;
            min-width: 0 !important;
        }

        main.flex-1 {
            padding-left: 1rem !important;
            padding-right: 1rem !important;
        }

        main.flex-1:not(.pt-20) {
            padding-top: 5rem !important;
        }

        h1.text-3xl,
        h1.text-4xl,
        .text-4xl {
            font-size: 1.85rem !important;
            line-height: 2.25rem !important;
        }

        h2.text-2xl,
        .text-3xl {
            font-size: 1.45rem !important;
            line-height: 1.95rem !important;
        }

        .glass,
        .glass-card,
        .stat-card,
        .material-card {
            border-radius: 0.85rem !important;
        }

        .p-6,
        .p-8,
        .p-10,
        .p-card,
        .p-lg {
            padding: 1rem !important;
        }

        main.flex-1.pt-20 {
            padding-top: 5rem !important;
        }

        .gap-8,
        .gap-10 {
            gap: 1rem !important;
        }

        .mb-10,
        .mb-12 {
            margin-bottom: 1.5rem !important;
        }

        .grid.grid-cols-3,
        .grid.grid-cols-4,
        .grid.grid-cols-5 {
            grid-template-columns: repeat(1, minmax(0, 1fr)) !important;
        }

        table {
            width: 100%;
        }

        .overflow-x-auto {
            -webkit-overflow-scrolling: touch;
        }

        .logbook-table,
        table.min-w-\[720px\] {
            min-width: 720px;
        }

        .glass:has(> table),
        .glass-card:has(> table) {
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch;
        }

        input,
        textarea,
        select,
        button,
        a {
            max-width: 100%;
        }

        input,
        textarea,
        select {
            font-size: 16px !important;
        }

        .dashboard-chat,
        .system-chat {
            right: 1rem !important;
            bottom: 1rem !important;
            width: min(380px, calc(100vw - 2rem)) !important;
        }
    }

    @media (max-width: 480px) {
        main.flex-1 {
            padding-left: 0.85rem !important;
            padding-right: 0.85rem !important;
        }

        .grid.grid-cols-2 {
            grid-template-columns: repeat(1, minmax(0, 1fr)) !important;
        }

        .flex.gap-3,
        .flex.gap-4 {
            flex-wrap: wrap;
        }

        .btn-primary,
        a.glass,
        button.glass {
            width: 100%;
            justify-content: center;
            text-align: center;
        }

        .system-chat button span,
        .dashboard-chat button span {
            display: none;
        }
    }
</style>
