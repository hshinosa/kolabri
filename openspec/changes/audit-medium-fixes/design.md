## Context

**Background**: Medium-priority audit issues focus on accessibility compliance (WCAG AA), user experience quality, and operational observability. These are not security threats but significantly impact platform quality, legal compliance, and production readiness.

**Current State**:
- 25+ modals lack accessibility features (no focus trap, no aria attributes, no ESC handler) — confirmed: 5 of 11 modals lack role="dialog", 4 lack Escape key, ALL lack focus trap
- ~199 color contrast violations (43 text-[#9CA3AF] + 156 text-gray-400/text-slate-400 across ~53 files)
- 6 silent error handlers (2 empty catches + 4 console.error-only), especially getAuthToken() failures that silently break pages
- User model has 'password' in $fillable (security anti-pattern)
- Debug logs expose full exception messages in production
- Client-App default timeout (10s) mismatches Core-API timeouts (30-120s)
- No distributed request tracing across 3 services

**Constraints**:
- Must maintain existing modal APIs during refactor
- Color changes must not break dark mode (if implemented)
- Toast notifications must use existing toast system
- Request ID must be backward compatible (optional header)
- 26 hours total across 7 issues

**Stakeholders**: Frontend team (accessibility, color, toasts), Backend team (model security, logging, timeouts, request ID), DevOps (observability)

## Goals / Non-Goals

**Goals:**
- Achieve WCAG AA compliance for all modal dialogs
- Fix all color contrast violations to meet 4.5:1 minimum ratio
- Provide user-visible feedback for all failed operations
- Follow Laravel security best practices for mass assignment
- Enable distributed request tracing across all 3 services
- Align timeout configurations to prevent race conditions

**Non-Goals:**
- Not implementing i18n (only removing misleading language selector in separate change)
- Not implementing dark mode support (separate initiative)
- Not addressing deferred issues (C2, C3, C5, C6, L5)
- Not changing API contracts or response formats
- Not implementing rate limiting (M7 only adds request ID, not rate limits)

## Decisions

### M1: Modal Accessibility - Audit Existing + Incremental Refactor

**Decision**: Audit existing shared modal components first, then build/extend a single accessible BaseModal wrapper and refactor all 25+ existing modals incrementally.

**Rationale**:
- Codebase already has shared modal/dialog components (`ConfirmDialog.tsx`, `GlobalSearchModal.tsx`, `DocumentViewerModal.tsx`, `SessionSummaryModal.tsx`, `KeyboardShortcutsHelpModal.tsx`)
- **IMPORTANT**: Confirmed audit shows ALL existing modals have ZERO focus trap. 5 of 11 lack role="dialog"/aria-modal. 4 lack Escape key handler. Only `DocumentViewerModal.tsx` has good accessibility (role, aria-modal, aria-label, Escape).
- Building accessibility from scratch in BaseModal, not extending existing accessible patterns

**Alternatives Considered**:
1. **Add accessibility to each modal individually** - Rejected: 25+ duplicates, maintenance nightmare
2. **Use third-party library (Radix UI, Headless UI)** - Rejected: Existing modal system works, migration cost high
3. **Build BaseModal from scratch ignoring existing components** - Rejected: Wasteful; existing ConfirmDialog can serve as pattern
4. **Single universal modal** - Rejected: Too complex, poor separation of concerns

**Implementation Approach**:
```typescript
// Step 1: Audit existing shared modals
// - resources/js/components/ui/ConfirmDialog.tsx
// - resources/js/components/ui/GlobalSearchModal.tsx
// - resources/js/components/course/DocumentViewerModal.tsx
// - resources/js/components/chat/SessionSummaryModal.tsx
// - resources/js/components/ui/KeyboardShortcutsHelpModal.tsx

// Step 2: Build or extend BaseModal with full accessibility
interface BaseModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  closeOnOverlayClick?: boolean;
  closeOnEsc?: boolean;
}

const BaseModal: React.FC<BaseModalProps> = ({ isOpen, onClose, title, children, ... }) => {
  // Focus trap: first focusable element on open, return focus on close
  // ESC key handler
  // aria-modal="true", role="dialog", aria-labelledby
  // Overlay click to close
  // Body scroll lock when open
  // Portal rendering for z-index management
};

// Step 3: Specialized components extend BaseModal
// AlertModal (informational, 1 button)
// ConfirmDialog (2 buttons, danger variant) — migrate existing ConfirmDialog to use BaseModal
// FormModal (form handling, validation, submit/cancel)
```

**Refactoring Strategy**:
1. Phase 1: Audit existing modals (1h) — catalog 25+ modals by type and current shared component usage
2. Phase 2: Build BaseModal + migrate existing ConfirmDialog to use it (3h)
3. Phase 3: Refactor 3 duplicate admin FormModals → shared FormModal (2h)
4. Phase 4: Add accessibility to remaining 22+ modals using BaseModal (4h)

**Breaking Changes**: None - new components are additive, old modals replaced incrementally

---

### M2: Color Contrast - Systematic Find & Replace

**Decision**: Replace all low-contrast text colors with WCAG AA compliant alternatives via systematic find & replace, then manually verify non-white backgrounds and dark mode.

**Rationale**:
- text-[#9CA3AF] / text-slate-400 / text-gray-400 on white = ~2.9:1 ratio → FAILS WCAG AA
- text-gray-600 on white = 4.6:1 ratio → PASSES WCAG AA
- Simple find & replace, no logic changes
- Preserves visual hierarchy (still lighter than body text)

**Scope**:
- Actual codebase scan: ~199 matches across ~53 files (43 text-[#9CA3AF] in 14 files + 156 text-gray-400/text-slate-400 in 39 files)
- Top affected areas: analytics pages, admin dashboards (ai-settings: 22+15 instances), profile components, chat UI, course pages
- Note: Some text-gray-400 usage is for icons/decorative elements where lower contrast is acceptable — distinguish text content from decorative use

**Alternatives Considered**:
1. **Custom color palette** - Rejected: Overkill, Tailwind's built-in grays are sufficient
2. **CSS custom properties** - Rejected: Adds complexity for simple fix
3. **Design system audit first** - Rejected: Known issue, fix now, audit later

**Implementation Approach**:
```bash
# Systematic replacements
# Gray-400 (2.9:1) → Gray-600 (4.6:1)
find resources/js -name "*.tsx" -exec sed -i '' 's/text-\[#9CA3AF\]/text-gray-600/g' {} +
find resources/js -name "*.tsx" -exec sed -i '' 's/text-\[#9ca3af\]/text-gray-600/g' {} +
find resources/js -name "*.tsx" -exec sed -i '' 's/text-slate-400/text-gray-600/g' {} +
find resources/js -name "*.tsx" -exec sed -i '' 's/text-gray-400/text-gray-600/g' {} +
```

**Verification**:
- Use axe-core or Lighthouse to scan all pages
- Manual spot check: secondary text still visually distinct from primary
- Manual spot check: elements on non-white backgrounds (cards, dark sections) still pass 4.5:1
- Dark mode check (if implemented): gray-600 maps appropriately on dark backgrounds
- Target: Zero color contrast violations

**Breaking Changes**: None - visual change only, no functional impact

---

### M3: API Error Feedback - Toast Notifications

**Decision**: Replace all console.error() calls with toast.error() notifications that provide user-visible feedback on operation failures.

**Rationale**:
- console.error is invisible to users (only developers see it)
- Users need to know when operations fail
- Toast notifications are non-blocking, dismissible
- Existing toast system (sonner/react-hot-toast) already in use

**Alternatives Considered**:
1. **Error boundary pages** - Rejected: Too heavy for API errors
2. **Inline error messages** - Rejected: Requires UI restructuring per component
3. **Global error modal** - Rejected: Blocks user interaction

**Implementation Approach**:
```typescript
// Replace:
fetch('/api/messages', { ... })
  .catch(err => {
    console.error('Failed to send message:', err);
  });

// With:
fetch('/api/messages', { ... })
  .catch(err => {
    console.error('Failed to send message:', err);  // Keep for dev tools
    toast.error('Failed to send message. Please try again.');
  });
```

**Files to Update** (6 real silent catches):
- `lecturer/dashboard.tsx` L81: `getAuthToken().catch(() => {})` — empty catch
- `student/reflections/index.tsx` L175: tags fetch `.catch(() => {})` — empty catch
- `lecturer/analytics/show.tsx` L304: `getAuthToken().catch(console.error)` — no user feedback
- `lecturer/analytics/index.tsx` L213: `getAuthToken().catch(console.error)` — no user feedback
- `student/chat/room.tsx` L526: `getAuthToken().catch(console.error)` — no user feedback
- `student/chat/index.tsx` L149: `getAuthToken().catch(console.error)` — no user feedback

**Highest impact**: The 4 `getAuthToken()` failures silently break entire pages (WebSocket won't connect, features unavailable).

**Borderline** (graceful degradation, may keep as-is):
- 3 `setWeekOptions([])` catches — dropdown shows empty instead of crashing

**Error Message Guidelines**:
- User-friendly: "Failed to send message" not "TypeError: Cannot read property..."
- Actionable: Include "Please try again" or "Check your connection"
- Contextual: Reference the specific operation that failed

**Breaking Changes**: None - additive UX improvement

---

### M4: Mass Assignment Security - Remove Password from $fillable

**Decision**: Remove 'password' from User model $fillable array. Set password explicitly in controllers.

**Rationale**:
- Having password in $fillable is security anti-pattern
- If any endpoint uses `$request->all()`, password could be mass-assigned
- Controllers already validate password properly, so no functional impact
- Defense-in-depth: prevents future mistakes if new endpoint uses mass assignment

**Alternatives Considered**:
1. **Keep password in $fillable with strict validation** - Rejected: Anti-pattern, relies on developer discipline
2. **Use $guarded instead of $fillable** - Rejected: Bigger refactor, $fillable is more explicit
3. **Add validation middleware** - Rejected: Over-engineered for simple fix

**Implementation Approach**:
```php
// User.php - Remove password from $fillable
protected $fillable = ['name', 'email'];  // 'password' removed

// Controllers that create/update users - set password explicitly
$user = User::create([
    'name' => $request->name,
    'email' => $request->email,
]);
$user->password = Hash::make($request->password);
$user->save();
```

**Breaking Changes**: None - controllers already handle password explicitly

---

### M5: Debug Log Cleanup - Production Log Hygiene

**Decision**: Replace 10 Log::debug() statements with appropriate log levels.

**Current State (from codebase verification)**:
- Only 10 `Log::debug()` instances found, all in 2 files:
  - `ProfileController.php`: Lines 107, 109, 118, 120 (stats fetch failures)
  - `ProfileStatsController.php`: Lines 54, 56, 68, 70, 82, 84 (stats fetch failures)
- 381 total `Log::` statements exist, mostly `Log::error()` — appropriate
- NO `dd()`, `dump()`, `var_dump()`, `error_log()` found anywhere

**Rationale**:
- Log::debug() with full exception messages exposes API structure in production logs
- Production logs should only contain actionable error information
- Small scope: 10 statements in 2 files → ~15 minute fix

**Alternatives Considered**:
1. **Disable debug logs entirely** - Rejected: Loses development debugging capability
2. **Environment-based log levels** - Already configured, just not used consistently
3. **Structured logging library** - Rejected: Over-engineered for this fix

**Implementation Approach**:
```php
// Replace (10 instances in 2 files):
Log::debug('API call failed: ' . $e->getMessage());

// With:
Log::error('External API call failed', [
    'service' => 'core-api',
    'error_code' => $e->getCode(),
    // Do NOT include: full message, stack trace, file paths
]);
```

**Configuration**:
- Production: APP_LOG_LEVEL=error (only error and above)
- Development: APP_LOG_LEVEL=debug (all logs)
- Verify .env has APP_DEBUG=false in production

**Breaking Changes**: None - logging level change only

---

### M6: Timeout Alignment - Prevent Race Conditions

**Decision**: Document timeout matrix and ensure all Client-App HTTP calls to Core-API use timeouts aligned with operation duration.

**Rationale**:
- Client-App default 10s timeout vs Core-API 30-120s for batch operations
- Client times out → user sees error → but server still processing
- Race condition: user retries → duplicate operations
- Documentation prevents future misconfigurations

**Architecture Note**: Kolabri-client-app is a Laravel BFF, not a TypeScript frontend service. Timeouts are configured in PHP (`Controller::apiRequest()` helper) and in the React frontend axios instance. The main coordination is in the Laravel backend.

**Alternatives Considered**:
1. **Increase all timeouts to 120s** - Rejected: Poor UX for simple operations
2. **Remove client timeouts entirely** - Rejected: Leaves client hanging indefinitely
3. **Server-side progress polling** - Rejected: Over-engineered, adds complexity

**Implementation Approach**:
```php
// Laravel BFF: centralized timeout in Controller::apiRequest() helper
// Already exists with timeout=10s, connectTimeout=5s
// Extend per-controller when needed:
protected function apiRequest(string $method, string $path, array $data = [], int $timeout = 10): PendingRequest {
    return Http::withToken(session('jwt'))
        ->timeout($timeout)
        ->connectTimeout(5);
}

// Usage in controllers:
// Standard call: $this->apiRequest('get', '/courses')
// Batch upload: $this->apiRequest('post', '/upload/batch', $data, 120)
// AI call: $this->apiRequest('post', '/ai/analyze', $data, 60)
```

```typescript
// React frontend: axios instance with aligned defaults
const api = axios.create({
  baseURL: '/api',
  timeout: 30_000,  // 30s for standard BFF calls
});

// Batch upload endpoint uses extended timeout
api.post('/upload/batch', formData, {
  timeout: 120_000,
});
```

**Timeout Matrix**:
| Operation | Client-App React | Client-App Laravel → Core-API |
|-----------|------------------|-------------------------------|
| Standard API | 30s | 10s |
| Batch upload | 120s | 120s |
| AI Engine | 60s | 60s |
| Health check | 5s | 5s |

**Missing connectTimeout (found in codebase audit)**:
- `SessionNotificationService.php` — has timeout(10) but NO connectTimeout
- `ActivateScheduledSessions.php` — has timeout(30) but NO connectTimeout
- `AutoCloseInactiveSessions.php` — has timeout(30) but NO connectTimeout
- `BulkSessionOperation.php` — has timeout(60) but NO connectTimeout
- `LecturerMaterialsHubController.php` — has timeout(10) but NO connectTimeout
- Seeders (`MaterialsDemoSeeder`, `AttendanceDemoSeeder`) — NO timeout at all

**Related Openspecs**:
- `Kolabri-client-app/openspec/changes/client-app-api-reliability/` — adds timeout to 11 Laravel controllers + error response standardization
- `Kolabri-client-app/openspec/changes/client-app-jwt-and-auth-timeout-fix/` — adds timeout to AuthController (currently bypasses apiRequest)

**Breaking Changes**: None - configuration change only, improves reliability

---

### M7: Request ID Propagation - Distributed Tracing

**Decision**: Complete X-Request-ID propagation across all 3 services. Core-API and AI-Engine already have middleware; Client-App is missing. Add response header echo and outbound propagation in all services.

**Rationale**:
- Cannot correlate logs across 3 services without request ID
- Production debugging requires tracing request through entire flow
- Industry standard pattern (used by AWS, Google, Stripe)
- Enables distributed tracing tools (Jaeger, Zipkin) integration later

**Current State**:
- **Core-API**: `requestIdMiddleware` exists (`src/middleware/error.middleware.ts`), reads `X-Request-ID` header or generates UUID, stores in `req.requestId`. Missing: response header and outbound propagation to AI-Engine.
- **AI-Engine**: `RequestIDMiddleware` exists (`app/middleware/request_id.py`), registered in `main.py`. Missing: verify header echo and structlog binding.
- **Client-App**: No request ID middleware. Must add Laravel middleware to generate/accept ID and propagate to Core-API.

**Alternatives Considered**:
1. **OpenTelemetry full implementation** - Rejected: Overkill for now, request ID is foundation
2. **Service-specific IDs only** - Rejected: Cannot trace across boundaries
3. **Log aggregation without IDs** - Rejected: Searching by timestamp is unreliable

**Implementation Approach**:
```typescript
// Core-API: extend existing requestIdMiddleware
export function requestIdMiddleware(req: Request, res: Response, next: NextFunction): void {
  const requestId = (req.headers['x-request-id'] as string) || uuidv4();
  (req as any).requestId = requestId;
  res.setHeader('X-Request-ID', requestId);  // ADD: echo in response
  next();
}

// Core-API outbound HTTP client: include X-Request-ID header
const aiEngineResponse = await axios.post(
  `${AI_ENGINE_URL}/analyze`,
  payload,
  { headers: { 'X-Request-ID': req.requestId } }
);
```

```php
// Client-App Laravel: new RequestIdMiddleware
class RequestIdMiddleware {
    public function handle(Request $request, Closure $next): Response {
        $requestId = $request->header('X-Request-ID', Str::uuid()->toString());
        $request->attributes->set('request_id', $requestId);

        $response = $next($request);
        $response->headers->set('X-Request-ID', $requestId);
        return $response;
    }
}

// Propagate to Core-API in apiRequest() helper:
Http::withToken(session('jwt'))
    ->withHeaders(['X-Request-ID' => $requestId])
    ->timeout(...)
    ->get(...);
```

```python
# AI-Engine: already has middleware; verify and complete
# - Accept X-Request-ID from upstream
# - Bind to structlog contextvars
# - Echo in response header
# - Include in global_exception_handler JSON body
# - Include in MongoDB activity logs
```

**Cross-Service Flow**:
```
Client-App (generates X-Request-ID: abc-123)
  → Core-API (receives abc-123, logs with it, echoes in response)
    → AI-Engine (receives abc-123, logs with it, echoes in response)
  ← Core-API (returns X-Request-ID: abc-123)
← Client-App (can reference abc-123 in error reports)
```

**Related Openspecs**:
- `Kolabri-ai-engine/openspec/changes/add-request-id-correlation/` — detailed AI Engine implementation

**Breaking Changes**: None - additive header, clients can ignore

---

## Risks / Trade-offs

### Modal Refactoring (M1)
**Risk**: Large refactor could introduce regressions in existing modal behavior
→ **Mitigation**: Incremental replacement (one modal at a time), test each after refactor

**Risk**: Focus trap might interfere with complex modal interactions (date pickers, dropdowns)
→ **Mitigation**: Test with all modal types, allow focus trap escape for portal-rendered children

### Color Contrast (M2)
**Risk**: Darker gray-600 might look too heavy in some contexts
→ **Mitigation**: Manual spot check after find & replace, adjust specific cases if needed

### Error Toasts (M3)
**Risk**: Too many toast notifications could overwhelm users
→ **Mitigation**: Only show toasts for actual failures (not warnings), auto-dismiss after 5s

### Request ID (M7)
**Risk**: UUID generation adds ~1ms overhead per request
→ **Mitigation**: Negligible impact, crypto.randomUUID() is fast in modern Node.js

**Risk**: Not all services might propagate ID correctly
→ **Mitigation**: Integration tests verify ID flows through entire request chain

---

## Migration Plan

### Phase 1: Pre-Deployment
1. **Code Review**: Frontend team reviews modal refactor, color changes
2. **Testing**: QA validates all modals with keyboard/screen reader
3. **Documentation**: Update component library docs with new modal components

### Phase 2: Deployment (Single Deploy)
1. **Frontend**: Deploy modal refactor, color fixes, error toasts
2. **Backend**: Deploy mass assignment fix, log cleanup, timeout config, request ID middleware
3. **AI-Engine**: Deploy request ID middleware

### Phase 3: Validation
1. **Accessibility**: Run Lighthouse/axe-core, verify zero contrast violations
2. **Modal Testing**: Keyboard navigate all modals, test focus trap
3. **Error Scenarios**: Trigger failures, verify toast notifications appear
4. **Request Tracing**: Make request, verify same X-Request-ID in all 3 service logs

### Rollback Strategy
- All changes are non-breaking and additive
- Rollback: Deploy previous version, no data cleanup needed
- Modal refactor: Can be rolled back incrementally if issues found
- Request ID: Disabling middleware has no impact (header simply absent)
