## 1. TypeScript Error Fixes - Admin Pagination

- [x] 1.1 Import AdminPagination component in master-data.tsx
- [x] 1.2 Import AdminPagination component in user-management.tsx
- [x] 1.3 Destructure start/end/total from meta object in master-data.tsx
- [x] 1.4 Destructure start/end/total from meta object in user-management.tsx
- [x] 1.5 Fix onPageChange parameter type in master-data.tsx
- [x] 1.6 Fix onPageChange parameter type in user-management.tsx
- [x] 1.7 Verify tsc --noEmit passes for admin pages

## 2. TypeScript Error Fixes - Session Management Routes

- [x] 2.1 Add autoCloseUpdate route definition to resources/js/routes/lecturer.ts
- [x] 2.2 Add activate route definition to resources/js/routes/lecturer.ts
- [x] 2.3 Register autoCloseUpdate route in Laravel routes/lecturer.php
- [x] 2.4 Register activate route in Laravel routes/lecturer.php
- [x] 2.5 Verify tsc --noEmit passes for session-mgmt components

## 3. TypeScript Error Fixes - Student Pages

- [x] 3.1 Move broadcast variable declaration before usage in student/ai-chat/index.tsx
- [x] 3.2 Add canPin prop to PinnedMessagesProps interface in student/chat/room.tsx components
- [x] 3.3 Verify tsc --noEmit passes for student pages

## 4. TypeScript Error Fixes - Verification

- [x] 4.1 Run tsc --noEmit and confirm zero errors
- [x] 4.2 Run npm run build and confirm successful compilation
- [x] 4.3 Smoke test affected pages (admin master-data, user-management, lecturer session-mgmt, student ai-chat, chat room)

## 5. OpenSpec Audit

- [x] 5.1 Create docs/openspec-audit.md with table structure
- [x] 5.2 Audit admin-ux-performance change
- [x] 5.3 Audit auth-shared-pages change
- [x] 5.4 Audit chat-enhancements change
- [x] 5.5 Audit chat-polish change
- [x] 5.6 Audit jwt-auto-refresh change
- [x] 5.7 Audit lecturer-ai-settings change
- [x] 5.8 Audit lecturer-analytics change
- [x] 5.9 Audit lecturer-analytics-detail change
- [x] 5.10 Audit lecturer-course-detail change
- [x] 5.11 Audit lecturer-courses change
- [x] 5.12 Audit lecturer-session-mgmt change
- [x] 5.13 Audit standardize-metrics-scale change
- [x] 5.14 Audit student-ai-chat change
- [x] 5.15 Audit student-chat-room-v2 change
- [x] 5.16 Audit student-chat-spaces change
- [x] 5.17 Audit student-course-detail change
- [x] 5.18 Audit student-courses change
- [x] 5.19 Audit student-dashboard-analytics change
- [x] 5.20 Audit student-groups change
- [x] 5.21 Audit student-profile change
- [x] 5.22 Audit student-reflections change
- [x] 5.23 Audit verification-wave1-4 change
- [x] 5.24 Summarize audit findings (complete/archived/in-progress counts)

## 6. UX Consistency - Dark Mode

- [x] 6.1 Extract useDarkMode hook from admin layout to resources/js/hooks/useDarkMode.ts
- [x] 6.2 Create ThemeProvider context in resources/js/contexts/ThemeContext.tsx
- [x] 6.3 Add dark mode toggle to student layout
- [x] 6.4 Add dark mode toggle to lecturer layout
- [x] 6.5 Implement theme persistence via localStorage
- [x] 6.6 Test dark mode toggle in student pages
- [x] 6.7 Test dark mode toggle in lecturer pages
- [x] 6.8 Verify theme synchronization across roles

## 7. UX Consistency - Keyboard Shortcuts

- [x] 7.1 Extract useKeyboardShortcuts hook from admin layout to resources/js/hooks/useKeyboardShortcuts.ts
- [x] 7.2 Create KeyboardShortcutProvider context in resources/js/contexts/KeyboardShortcutContext.tsx
- [x] 7.3 Define student-specific shortcut map in resources/js/config/shortcuts/student.ts
- [x] 7.4 Define lecturer-specific shortcut map in resources/js/config/shortcuts/lecturer.ts
- [x] 7.5 Add KeyboardShortcutProvider to student layout
- [x] 7.6 Add KeyboardShortcutProvider to lecturer layout
- [x] 7.7 Create keyboard shortcut help modal component
- [x] 7.8 Test keyboard shortcuts in student pages (Ctrl+K, ?, etc.)
- [x] 7.9 Test keyboard shortcuts in lecturer pages
- [x] 7.10 Verify no shortcut conflicts between roles

## 8. UX Consistency - Global Search

- [x] 8.1 Extract GlobalSearchModal component from admin to resources/js/components/ui/GlobalSearchModal.tsx
- [x] 8.2 Create student global search endpoint in Laravel (routes/student.php, controller)
- [x] 8.3 Create lecturer global search endpoint in Laravel (routes/lecturer.php, controller)
- [x] 8.4 Implement student search logic (courses, groups, reflections)
- [x] 8.5 Implement lecturer search logic (courses, students, sessions, analytics)
- [x] 8.6 Add GlobalSearchModal to student layout
- [x] 8.7 Add GlobalSearchModal to lecturer layout
- [x] 8.8 Test global search in student pages (Ctrl+K trigger, search results, navigation)
- [x] 8.9 Test global search in lecturer pages
- [x] 8.10 Verify search results are role-scoped

## 9. Test Coverage Documentation

- [x] 9.1 Create docs/test-coverage-wave1-4.md with matrix structure
- [x] 9.2 Document auth feature test coverage (login, logout, JWT refresh, role-based access)
- [x] 9.3 Document student feature test coverage (courses, groups, reflections, AI chat, profile)
- [x] 9.4 Document lecturer feature test coverage (courses, session mgmt, analytics, AI settings)
- [x] 9.5 Document admin feature test coverage (user mgmt, master data, audit log, UX features)
- [x] 9.6 Identify and flag missing unit tests
- [x] 9.7 Identify and flag missing integration tests
- [x] 9.8 Identify and flag missing E2E tests
- [x] 9.9 Link to existing test files where applicable
- [x] 9.10 Summarize coverage gaps and prioritize by user impact

## 10. Implementation Documentation

- [x] 10.1 Create docs/implementation-patterns.md
- [x] 10.2 Document BFF proxy pattern (route → controller → Core API)
- [x] 10.3 Document Inertia.js page pattern (controller → props → React component)
- [x] 10.4 Document role-based routing pattern (middleware, route files, navigation)
- [x] 10.5 Create docs/architecture-decisions.md
- [x] 10.6 Document BFF architecture rationale
- [x] 10.7 Document monorepo structure rationale
- [x] 10.8 Document TypeScript strict mode decision
- [x] 10.9 Create docs/migration-guides/ directory
- [x] 10.10 Create migration guide for adding new role
- [x] 10.11 Create migration guide for extending UX features
- [x] 10.12 Create migration guide for OpenSpec workflow

## 11. Bundle Size Analysis

- [x] 11.1 Measure current bundle size (npm run build, check public/build/manifest.json)
- [x] 11.2 Implement code splitting for dark mode toggle
- [x] 11.3 Implement code splitting for global search modal
- [x] 11.4 Implement lazy loading for keyboard shortcut help modal
- [x] 11.5 Measure bundle size after UX consistency changes
- [x] 11.6 Document bundle size impact in design.md

## 12. Regression Testing

- [x] 12.1 Add regression tests for admin dark mode
- [x] 12.2 Add regression tests for admin keyboard shortcuts
- [x] 12.3 Add regression tests for admin global search
- [x] 12.4 Run full test suite after TypeScript fixes
- [x] 12.5 Manual smoke test all admin pages
- [x] 12.6 Manual smoke test all student pages
- [x] 12.7 Manual smoke test all lecturer pages

## 13. Final Verification

- [x] 13.1 Run tsc --noEmit and confirm zero errors
- [x] 13.2 Run npm run build and confirm successful compilation
- [x] 13.3 Verify all OpenSpec changes audited (21 total)
- [x] 13.4 Verify dark mode works in all roles
- [x] 13.5 Verify keyboard shortcuts work in all roles
- [x] 13.6 Verify global search works in all roles
- [x] 13.7 Verify test coverage documentation complete
- [x] 13.8 Verify implementation documentation complete
- [x] 13.9 Review bundle size impact acceptable
- [x] 13.10 Confirm no regressions in existing features
