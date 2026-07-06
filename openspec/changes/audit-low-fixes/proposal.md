## Why

Low-priority audit issues represent UX polish and performance optimizations that improve overall platform quality. While not blocking production, these issues affect user experience (misleading language selector, missing navigation breadcrumbs, blank empty states) and system efficiency (no HTTP/2 connection pooling). Fixing them completes the audit remediation and delivers a more polished, performant platform.

## What Changes

This change implements 4 low-priority quality improvements:

1. **Remove Non-Functional Language Selector (L1)**: Remove misleading language preference UI that does nothing (no i18n framework wired). Eliminates user confusion. (1 hour)

2. **Add Missing Breadcrumbs (L2)**: Add breadcrumb navigation to 5 pages (courses/show, groups/show, chat/room, reflections, ai-chat) so users maintain context in deep navigation flows. Note: chat-spaces page is deprecated (redirects to courses/show), excluded. (3 hours)

3. **Verify & Add Empty State Illustrations (L3)**: Verify existing EmptyState components render correctly. Components exist in codebase for dashboard, courses, chat-spaces, and reflections — confirm they trigger properly or fix conditional rendering. (2 hours)

4. **HTTP/2 Connection Pooling (L4)**: Enable HTTP/2 and connection pooling for outbound HTTP calls to reduce connection overhead and improve response times. (1 hour)

All changes are non-breaking and additive.

## Capabilities

### New Capabilities

- `ux-polish`: User experience improvements including removal of misleading UI, breadcrumb navigation, and empty state illustrations
- `performance-optimization`: HTTP/2 connection pooling for improved request efficiency

### Modified Capabilities

<!-- No existing capabilities modified -->

## Impact

**Services Affected**:
- Client-App Frontend (React/TypeScript): 3 changes (remove language selector, add breadcrumbs, add empty states)
- Client-App Backend (Laravel): 1 change (HTTP/2 connection pooling)

**Code Areas**:
- User preferences component: Remove language selector UI
- Page layouts: Add Breadcrumbs component to 5 pages (courses/show, groups/show, chat/room, reflections, ai-chat)
- Dashboard/chart components: Verify and fix existing EmptyState rendering
- HTTP client configuration: Enable HTTP/2 and connection pooling

**APIs**:
- No API changes
- No breaking changes

**Dependencies**:
- Uses existing Breadcrumbs component
- Uses existing EmptyState component pattern
- No new dependencies

**Data/Database**:
- No schema changes
- No migrations
