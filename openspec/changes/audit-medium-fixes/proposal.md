## Why

The security and quality audit identified 7 medium-priority issues affecting accessibility compliance, user experience quality, and operational observability. These issues do not pose immediate security threats but significantly impact platform quality: WCAG AA accessibility violations prevent users with disabilities from using the platform, silent error handling confuses users when operations fail, and missing distributed tracing makes production debugging extremely difficult. Fixing these now ensures legal compliance, professional UX quality, and operational readiness for production monitoring.

## What Changes

This change implements 7 medium-priority quality and compliance fixes:

1. **Modal Accessibility (M1)**: Create accessible BaseModal with focus trap, ESC handler, aria attributes; build specialized AlertModal, ConfirmDialog, FormModal components; refactor 25+ existing modals to use shared accessible components (10 hours)
2. **Color Contrast Compliance (M2)**: Fix ~199 instances of low-contrast text (2.9:1 ratio) across ~53 files to meet WCAG AA 4.5:1 minimum requirement for readability (4-6 hours)
3. **API Error Feedback (M3)**: Replace 6 silent error handlers (2 empty catches + 4 console.error-only) with visible toast notifications, especially getAuthToken() failures that silently break entire pages (4 hours)
4. **Mass Assignment Security (M4)**: Remove 'password' from User model $fillable array to follow Laravel security best practices (1 hour)
5. **Debug Log Cleanup (M5)**: Replace 10 Log::debug() statements in 2 files (ProfileController, ProfileStatsController) with Log::error() to prevent information disclosure in production logs (15 minutes)
6. **Timeout Alignment (M6)**: Document and align client/server timeout configurations to prevent race conditions where client times out before server completes (2 hours)
7. **Request ID Propagation (M7)**: Add X-Request-ID middleware across all 3 services (Core-API, Client-App, AI-Engine) for distributed request tracing and production debugging (4 hours)

All changes are non-breaking and improve quality without changing API contracts.

## Capabilities

### New Capabilities

- `modal-accessibility`: WCAG AA compliant modal system with BaseModal, focus management, and specialized accessible components
- `color-contrast-compliance`: WCAG AA color contrast standards across all UI text
- `api-error-feedback`: User-visible error notifications for all failed operations
- `model-security`: Laravel mass assignment protection and production log hygiene
- `service-observability`: Request tracing, timeout alignment, and distributed logging infrastructure

### Modified Capabilities

<!-- No existing capabilities are being modified -->

## Impact

**Services Affected**:
- Core-API (Node.js/TypeScript): 1 change (request ID response header + outbound propagation)
- Client-App Backend (Laravel): 4 changes (mass assignment, debug log cleanup, timeout alignment, request ID middleware)
- Client-App Frontend (React/TypeScript): 3 changes (modal refactor, color contrast, error toasts)
- AI-Engine (Python): 1 change (request ID already exists; verify header echo + log correlation)

**Related Service-Specific Openspecs**:
- `Kolabri-client-app/openspec/changes/client-app-api-reliability/` — detailed M6 implementation for Laravel controllers (timeout + error response standardization + controller logging)
- `Kolabri-client-app/openspec/changes/client-app-jwt-and-auth-timeout-fix/` — M6 auth controller timeout + JWT validation hardening
- `Kolabri-ai-engine/openspec/changes/add-request-id-correlation/` — detailed M7 implementation for AI Engine (structlog binding, MongoDB activity logs)

**Code Areas**:
- Modal components: Audit existing shared modals, refactor remaining 25+ modals incrementally
- Tailwind color classes: ~199 matches across 53 files (43 text-[#9CA3AF] + 156 text-gray-400/text-slate-400)
- Fetch/axios error handlers: 6 silent catches in 6 files (2 empty + 4 console.error-only)
- User model: $fillable array modification
- Logging configuration: Debug level adjustments in Laravel controllers
- HTTP middleware: Request ID propagation (Client-App missing; Core-API/AI-Engine need completion)

**APIs**:
- No API contract changes
- Response headers: Add X-Request-ID to all responses
- No breaking changes to existing functionality

**Dependencies**:
- No new external dependencies required
- Uses existing toast notification system
- Uses existing EmptyState component patterns

**Data/Database**:
- No schema changes required
- No migrations needed

**Testing Scope**:
- Accessibility: Screen reader testing, keyboard navigation, focus management
- Visual: Color contrast verification across 40+ instances
- UX: Error notification visibility and clarity
- Observability: Request tracing across service boundaries
