# Test Coverage Matrix — Wave 1-4

> **Generated:** 2026-05-24  
> **Scope:** Auth, Student, Lecturer, Admin features across all Wave 1-4 OpenSpec changes  
> **Legend:** ✅ = Covered &nbsp; ⚠️ = Partial &nbsp; ❌ = Missing

---

## 1. Auth Features

| Feature | Unit Tests | Integration Tests (PHP Feature) | E2E Tests (Playwright) | Notes |
|---|---|---|---|---|
| **Login** | ✅ `PasswordStrengthMeter.test.tsx` (UI component only) | ✅ `AuthControllerTest.php` — success redirect, invalid credentials error | ✅ `auth.spec.ts` — landing page, form render, empty validation, invalid creds, admin login flow | UI validation + API response covered; no brute-force/rate-limit tests |
| **Register** | ✅ `PasswordStrengthMeter.test.tsx` (UI component only) | ✅ `AuthControllerTest.php` — creates user, stores session, redirects by role | ✅ `auth.spec.ts` — register page renders, fields visible | Role-based registration tested (lecturer only); student registration not explicitly tested by role |
| **Logout** | ❌ | ✅ `AuthControllerTest.php` — clears JWT/refresh_token/user session, sends refreshToken to Core API | ✅ `auth.spec.ts` — admin logout flow, redirects to /login | Good coverage; no test for token revocation failure handling |
| **JWT Auto-Refresh** | ❌ | ❌ | ❌ | **CRITICAL GAP.** JWT refresh interceptor is client-side only. No automated test ensures refresh flow works (token near expiry → refresh → retry). Auth failure data loss risk if this breaks silently. |
| **Role-Based Access** | ❌ | ✅ `MiddlewareTest.php` — JWT auth guard (redirect/401), role middleware (block wrong role, redirect/403), guest middleware | ✅ `permission-boundaries.spec.ts` — student blocked from admin/lecturer, lecturer blocked from admin, unauthenticated → login | ✅ `auth.spec.ts` — unauthenticated users redirected from /dashboard, /admin/dashboard | Covered end-to-end for all 3 roles + unauthenticated; no admin→student/lecturer access test (admin should likely be blocked too) |

**Auth Summary:** Login/logout/register are well covered. JWT auto-refresh is the critical gap — zero tests for the most fragile auth surface.

---

## 2. Student Features

| Feature | Unit Tests | Integration Tests (PHP Feature) | E2E Tests (Playwright) | Notes |
|---|---|---|---|---|
| **Courses** | ❌ | ✅ `CourseControllerTest.php` — index, show, store, update, delete (lecturer role tested; student routes share controller) | ✅ `student-flow.spec.ts` — student lands on /student/courses, courses page shows content | Student course enrollment flow not explicitly tested separate from lecturer course CRUD |
| **Groups** | ❌ | ✅ `GroupControllerTest.php` — `test_student_index_renders_group_detail` | ✅ `student-group-chat.spec.ts` — navigates through group to chat | Group listing and join flow tested via E2E navigation path |
| **Goals** | ❌ | ✅ `GoalControllerTest.php` — create page, store, redirect when exists, update | ✅ `student-goals.spec.ts` — full flow: navigation → goal page → show validation feedback | Goals CRUD well covered end-to-end |
| **Reflections** | ❌ | ✅ `ReflectionControllerTest.php` — index, store, update, delete | ✅ `student-reflections.spec.ts` — list, open create form, submit with course/validation feedback | Full CRUD coverage at integration level |
| **AI Chat** | ✅ `ChatMessageList.test.tsx` | ✅ `AiChatControllerTest.php` — show, 404 handling, timestamp normalization, save, bookmark | ⚠️ `student-flow.spec.ts` — page loads, textarea visible (smoke test only) | **Partial E2E.** No full AI conversation flow (send message → receive streaming response → bookmark). Integration test (`AiChatIntegrationTest.php`) is most comprehensive (417 lines, covers search, bookmarks, prompt templates). |
| **AI Chat (advanced)** | ✅ `useDragDrop.test.tsx`, `DropZoneOverlay.test.tsx`, `AISummaryButton.test.tsx`, `chat-summary.test.tsx`, `optimistic-message.test.ts` | ✅ `AiChatIntegrationTest.php` — search with cursor, bookmark CRUD, prompt templates | ❌ | Drag-drop, AI summary, optimistic updates well unit-tested. No E2E for these features. |
| **Chat Room** | ✅ `ChatMessageList.test.tsx` (loading/empty/reply states) | ❌ (no dedicated chat room controller test — uses group controller) | ⚠️ `student-group-chat.spec.ts` — send message, disabled when closed | **Partial.** No tests for: real-time Socket.io updates, AI intervention messages in chat, session timer/auto-close, pinned messages |
| **Chat Spaces** | ❌ | ❌ | ❌ (navigation covered implicitly via `student-group-chat` helper) | **MISSING.** Chat spaces listing/selection is key UX. No dedicated tests. |
| **Profile** | ❌ | ❌ | ⚠️ `student-flow.spec.ts` — profile page loads (smoke test) | **Partial.** No tests for profile edit, avatar upload, password change |
| **Dashboard Analytics** | ❌ | ❌ | ❌ | **MISSING.** Student dashboard with analytics charts not tested |
| **Shared UI Components** | ✅ `sanitize.test.ts`, `formatAiOutput.test.ts`, `csv-utils.test.ts`, `focus-management.test.ts`, `upload-attachments.test.ts`, `attachment-url.test.ts`, `errorHandler.test.ts`, `error-boundary.test.tsx`, `ToastNotification.test.tsx` | — | — | Strong utility-level unit test coverage |

**Student Summary:** Core CRUD (courses, groups, goals, reflections) is well covered at integration + E2E. AI Chat has strong unit + integration but weak E2E. Major gaps: chat spaces, profile edit, dashboard analytics, real-time chat features (Socket.io).

---

## 3. Lecturer Features

| Feature | Unit Tests | Integration Tests (PHP Feature) | E2E Tests (Playwright) | Notes |
|---|---|---|---|---|
| **Courses** | ❌ | ✅ `CourseControllerTest.php` — index, show, store, update, delete | ✅ `lecturer-flow.spec.ts` — landing after login, course list, create button, create page loads | Good coverage; all standard CRUD + navigation tested |
| **Course Detail** | ❌ | ✅ `CourseControllerTest.php` — `test_show_renders_course_detail` | ⚠️ (covered implicitly via analytics E2E navigation) | No dedicated course detail E2E; integration covers Inertia component + data assert |
| **Groups** | ❌ | ✅ `GroupControllerTest.php` — `test_index_renders_groups_page` (lecturer role) | ⚠️ (covered via analytics detail link navigation) | Lecturer group management (create group, assign students) not tested in E2E |
| **Session Management** | ❌ | ❌ | ❌ | **CRITICAL GAP.** Session management (create session, auto-close, activate) has known TypeScript errors (tasks 2.1-2.5). Zero tests. High risk of regression. |
| **Analytics** | ✅ `PlanVsDiskusiChart.test.tsx`, `MetricsRadarChart.test.tsx` | ✅ `AnalyticsControllerTest.php` — index (course summary), show (group detail with qualityScore/plansCount) | ✅ `lecturer-analytics.spec.ts` — full flow: analytics page → group detail → show metrics | Good coverage end-to-end. Chart components unit-tested. Analytics detail thoroughly E2E tested. |
| **AI Settings** | ❌ | ⚠️ `AISettingsControllerTest.php` (tested via admin routes) | ❌ (admin AI settings tested, no lecturer-specific AI settings E2E) | Lecturer AI settings (prompt templates, provider config) is a lecturer-level feature but tested via admin controller. Lecturer-specific settings flow untested. |
| **Dashboard/Overview** | ❌ | ❌ | ❌ | **MISSING.** Lecturer dashboard/landing page not tested |

**Lecturer Summary:** Analytics is the strongest — unit, integration, E2E all present. Session management is the critical gap: zero tests for a complex feature with known TypeScript issues. Lecturer AI settings route not tested separately from admin.

---

## 4. Admin Features

| Feature | Unit Tests | Integration Tests (PHP Feature) | E2E Tests (Playwright) | Notes |
|---|---|---|---|---|
| **User Management** | ❌ | ✅ `UserManagementControllerTest.php` — index, store, update, destroy | ✅ `admin-user-management.spec.ts` — page loads, user entries, search, create modal/form | Good coverage. Pagination filter/search/flush tested via E2E |
| **Master Data** | ❌ | ✅ `MasterDataControllerTest.php` — index, store course, update, store assignment, destroy | ✅ `admin-master-data.spec.ts` — page loads, course cards, create, search, tab navigation | Good coverage. CRUD for courses + assignments tested |
| **Audit Log** | ❌ | ✅ `AuditLogControllerTest.php` — index (table, meta, filters), API error handling (500) | ✅ `admin-audit-log.spec.ts` — table, action filter, pagination next/previous | Good coverage. Error states and edge cases tested |
| **AI Settings** | ❌ | ✅ `AISettingsControllerTest.php` — index, store, update, destroy | ✅ `admin-ai-settings.spec.ts` — page loads, provider list, add button, comparison page | Good coverage |
| **Dashboard** | ❌ | ⚠️ (no dedicated dashboard controller test) | ✅ `admin-dashboard.spec.ts` — stats/charts, sidebar nav, all page navigation links | Dashboard is simple; E2E covers navigation |
| **Dark Mode** | ❌ | ❌ | ❌ | **MISSING.** Dark mode toggle is admin-only feature. No tests for toggle, localStorage persistence, CSS class application |
| **Keyboard Shortcuts** | ❌ | ❌ | ❌ | **MISSING.** No tests for shortcuts (Ctrl+K, ?, etc.) |
| **Global Search** | ❌ | ❌ | ❌ | **MISSING.** Global search modal not tested |

**Admin Summary:** Core admin features (user mgmt, master data, audit log, AI settings) are well covered. UX features (dark mode, keyboard shortcuts, global search) are completely untested — these are Wave 4 additions that the post-wave4-cleanup aims to extend to all roles.

---

## 5. Cross-Cutting Concerns

| Feature | Unit Tests | Integration Tests (PHP Feature) | E2E Tests (Playwright) | Notes |
|---|---|---|---|---|
| **API Integration (Core API)** | ❌ | — (all PHP tests mock HTTP) | ✅ `api-integration.spec.ts` — Core API health check | Direct Core API calls test service availability |
| **API Integration (AI Engine)** | ❌ | — | ✅ `api-integration.spec.ts` — health, engagement analysis, chat endpoint, intervention (analyze/summary/prompt), analytics (group/export) | Strong service-level smoke tests. Full coverage of AI Engine endpoints |
| **Responsive Design** | ❌ | ❌ | ⚠️ `responsive.spec.ts` — login (mobile/tablet), welcome (mobile), register (mobile) | Only auth pages tested. No admin/lecturer/student page responsiveness tests |
| **Architecture Guards** | ✅ `architecture-guards.test.ts` — BFF boundary (no direct core calls), no legacy auth imports, test file count | — | — | Architecture enforcement prevents regressions |
| **Error Handling** | ✅ `errorHandler.test.ts`, `error-boundary.test.tsx` | ✅ scattered across feature tests (AuditLogControllerTest 500 handling, AiChatControllerTest 404) | ⚠️ (implicit in E2E flows, not explicit error state tests) | Good unit + integration; E2E error state testing is implicit |

---

## 6. Coverage Summary

### Test File Count

| Layer | Count | Paths |
|---|---|---|
| **Unit (tests/Unit/)** | 11 | `tests/Unit/static/`, `tests/Unit/components/`, `tests/Unit/lib/` |
| **Unit (resources/js/)** | 8 | `resources/js/lib/`, `resources/js/features/chat/` |
| **PHP Feature/Integration** | 13 | `tests/Feature/*.php` |
| **E2E (Playwright)** | 15 | `tests/e2e/*.spec.ts` |
| **Total** | **47** | |

### Coverage by Role

| Role | Unit | Integration | E2E | Overall |
|---|---|---|---|---|
| **Auth** | ⚠️ | ✅ | ✅ | **Good** (except JWT refresh) |
| **Student** | ⚠️ | ✅ | ⚠️ | **Moderate** (chat/analytics/profile gaps) |
| **Lecturer** | ⚠️ | ⚠️ | ⚠️ | **Moderate** (session mgmt critical gap) |
| **Admin** | ❌ | ✅ | ✅ | **Good** (UX features untested) |
| **Cross-Cutting** | ⚠️ | — | ⚠️ | **Moderate** (responsive, error E2E gaps) |

---

## 7. Gap Analysis & Prioritization

### 🔴 Critical (Ship-blocking — security/auth risk)

| # | Gap | Impact | Effort |
|---|---|---|---|
| 1 | **JWT Auto-Refresh** — zero tests | Auth silently breaks; users lose access mid-session. The interceptor is client-side only with no automated verification. | Medium |
| 2 | **Session Management** — zero tests + known TypeScript errors | Lecturer session mgmt is broken at type level and untested. Sessions may fail to create/auto-close/activate. | High |

### 🟠 High (Core feature regression risk)

| # | Gap | Impact | Effort |
|---|---|---|---|
| 3 | **Student AI Chat E2E** — no full conversation flow | Most complex student feature. Send → receive streaming → bookmark flow untested. | Medium |
| 4 | **Student Chat Room Real-Time** — Socket.io, AI interventions, auto-close | Real-time features are inherently fragile. No test coverage. | High |
| 5 | **Lecturer AI Settings** — no lecturer-specific route tests | Lecturer-configured AI settings may differ from admin. Only admin route tested. | Low |
| 6 | **Student Profile Edit** — no CRUD tests | Profile edit (avatar upload, password change) untested. | Low |

### 🟡 Medium (UX quality)

| # | Gap | Impact | Effort |
|---|---|---|---|
| 7 | **Chat Spaces** — no dedicated tests | Key navigation layer for student chat. Implicitly covered via other E2E flows but no explicit listing/selection tests. | Low |
| 8 | **Student Dashboard Analytics** — no tests | Dashboard charts untested. | Low |
| 9 | **Lecturer Dashboard** — no tests | Lecturer landing page untested. | Low |
| 10 | **Responsive Design** — only auth pages | Admin/lecturer/student pages may break on mobile. | Medium |

### 🟢 Low (Nice-to-have)

| # | Gap | Impact | Effort |
|---|---|---|---|
| 11 | **Dark Mode** — no tests | UX feature with localStorage persistence. Medium risk of silent breakage. | Low |
| 12 | **Keyboard Shortcuts** — no tests | Productivity feature. Low breakage impact. | Low |
| 13 | **Global Search** — no tests | Navigation feature. Medium breakage impact (may block navigation). | Low |
| 14 | **E2E Error States** — implicit only | Error handling paths (network failures, 500s) not explicitly tested at E2E level. | Medium |

---

## 8. Recommendations

### Immediate (Post-Wave4-Cleanup)
1. **Add JWT auto-refresh integration test** — highest priority. Mock near-expiry token, verify refresh + retry flow.
2. **Add session management feature tests** — cover create, auto-close, activate endpoints. Fix TypeScript errors first (tasks 2.1-2.5).

### Short-Term (Wave 5)
3. **Expand AI Chat E2E** — full send → receive → bookmark conversation flow.
4. **Add chat room real-time tests** — Socket.io message delivery, AI intervention display, session auto-close.
5. **Add responsive tests for admin/lecturer/student pages** — at minimum smoke test all core pages at mobile viewport.

### Medium-Term (Wave 5+)
6. **Add dark mode, keyboard shortcuts, global search tests** — these are being extended to all roles in post-wave4-cleanup. Tests should follow.
7. **Add student profile CRUD tests** — edit, avatar, password.
8. **Add dedicated E2E error state suite** — network offline, API 500, timeout scenarios.

---

## 9. Test File Index

### E2E Tests (`tests/e2e/`)
| File | Coverage |
|---|---|
| `auth.spec.ts` | Login, register, logout, admin login flow, unauthenticated redirect |
| `permission-boundaries.spec.ts` | Role-based route guards (student/lecturer/admin boundaries) |
| `student-flow.spec.ts` | Student courses, AI chat, reflections, profile smoke test |
| `student-group-chat.spec.ts` | Group chat navigation, message input, send, session-closed state |
| `student-reflections.spec.ts` | Reflections list, create form, submit with course/validation |
| `student-goals.spec.ts` | Goals flow (navigation, create, validation feedback) |
| `lecturer-flow.spec.ts` | Lecturer courses, create course page |
| `lecturer-analytics.spec.ts` | Analytics overview, group detail, metrics display |
| `admin-dashboard.spec.ts` | Dashboard, sidebar nav, all admin page navigation |
| `admin-audit-log.spec.ts` | Audit log table, action filter, pagination |
| `admin-master-data.spec.ts` | Master data CRUD, search, tabs |
| `admin-user-management.spec.ts` | User list, search, create user modal |
| `admin-ai-settings.spec.ts` | AI settings, provider list, add button, comparison page |
| `api-integration.spec.ts` | Core API health, AI Engine health/chat/analytics/intervention endpoints |
| `responsive.spec.ts` | Login/register/welcome at mobile + tablet |

### Feature Tests (`tests/Feature/`)
| File | Coverage |
|---|---|
| `AuthControllerTest.php` | Login, register, logout, unauthenticated redirect |
| `MiddlewareTest.php` | JWT auth guard, role middleware, guest middleware |
| `CourseControllerTest.php` | Courses index, show, store, update, delete |
| `GroupControllerTest.php` | Lecturer group index, student group detail |
| `GoalControllerTest.php` | Goals create, store, update, redirect when exists |
| `ReflectionControllerTest.php` | Reflections index, store, update, delete |
| `AnalyticsControllerTest.php` | Analytics course overview, group detail |
| `AiChatControllerTest.php` | AI chat show, 404, timestamp normalization, save, bookmark |
| `AiChatIntegrationTest.php` | AI chat search (cursor), bookmarks, prompt templates |
| `AISettingsControllerTest.php` | AI providers index, store, update, delete |
| `AuditLogControllerTest.php` | Audit log index, API error handling |
| `UserManagementControllerTest.php` | Users index, store, update, delete |
| `MasterDataControllerTest.php` | Master data index, course CRUD, assignment CRUD |

### Unit Tests (`tests/Unit/` + `resources/js/`)
| File | Coverage |
|---|---|
| `static/architecture-guards.test.ts` | BFF boundary rules, no legacy auth imports |
| `components/chat/ChatMessageList.test.tsx` | Loading, empty, reply, AI message states |
| `components/PlanVsDiskusiChart.test.tsx` | Chart rendering with data |
| `components/MetricsRadarChart.test.tsx` | Radar chart metrics display |
| `components/error-boundary.test.tsx` | Error boundary catches + renders fallback |
| `components/ui/ToastNotification.test.tsx` | Toast types, dismiss, auto-close |
| `components/ui/PasswordStrengthMeter.test.tsx` | Password strength indicators |
| `lib/errorHandler.test.ts` | Error normalization, network/API types |
| `lib/csv-utils.test.ts` | CSV export formatting, empty data |
| `lib/sanitize.test.ts` | XSS sanitization |
| `lib/formatAiOutput.test.ts` | Markdown/code block formatting |
| `lib/focus-management.test.ts` | Focus trapping, auto-focus |
| `lib/upload-attachments.test.ts` | File validation, size limits |
| `lib/attachment-url.test.ts` | URL generation for attachments |
| `features/chat/useDragDrop.test.tsx` | Drag & drop state management |
| `features/chat/DropZoneOverlay.test.tsx` | Drop zone visual states |
| `features/chat/summary/AISummaryButton.test.tsx` | Summary button states |
| `features/chat/summary/chat-summary.test.tsx` | Summary text processing |
| `features/chat/optimistic-message.test.ts` | Optimistic update/revert logic |