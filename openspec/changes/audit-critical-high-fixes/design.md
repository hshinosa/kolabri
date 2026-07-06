## Context

**Background**: Comprehensive security and quality audit of Kolabri platform (Core-API, AI-Engine, Client-App) identified 26 issues. This design addresses the 10 most critical security and reliability gaps that pose immediate threats to production deployment.

**Current State**:
- JWT tokens stored in browser localStorage (XSS vulnerable)
- Empty catch blocks in WebSocket handlers (silent AI feature failures)
- Unsanitized search inputs (SQL injection vector)
- Missing authorization checks on chat operations (cross-conversation access)
- No MIME validation on file uploads (RCE risk)
- No ownership checks on reflection access (privacy violation)
- Promise.all failures abort entire batch operations (poor UX)
- Silent query failures without logging (debugging impossible)
- Direct AI Engine calls without circuit breaker (cascading failures)
- Wrong environment variable in discussion-direction service (403 errors)

**Constraints**:
- Must maintain backward compatibility with existing API contracts
- No database schema changes or migrations
- Must complete within 23.5 hours (10 issues across 3 services)
- Zero downtime deployment required
- Existing authentication flows must continue working during migration

**Stakeholders**: Backend team (Core-API, Client-App), Frontend team (Client-App UI), DevOps (deployment), Security team (review)

## Goals / Non-Goals

**Goals:**
- Close all critical security vulnerabilities (XSS, SQL injection, RCE, unauthorized access)
- Implement comprehensive error handling with retry logic and user notifications
- Add authorization checks on all cross-resource operations
- Enable graceful degradation for external service failures
- Improve observability through proper error logging
- Maintain 100% backward compatibility with existing APIs

**Non-Goals:**
- Not implementing new features beyond security/reliability fixes
- Not refactoring unrelated code or architecture
- Not addressing the 5 deferred issues (C2, C3, C5, C6, L5)
- Not changing database schemas or data models
- Not modifying AI Engine codebase (integration layer only)

## Decisions

### C1: JWT Token Storage - Remove localStorage, Rely on BFF Session

**Decision**: Remove JWT from browser `localStorage` and rely on the existing Laravel BFF session (server-side, httpOnly session cookie). For WebSocket and other client-side needs, fetch the token on-demand from the existing `/api/auth/token` endpoint.

**Rationale**:
- localStorage is accessible to JavaScript → XSS attacks can steal tokens
- Kolabri-client-app is a BFF: Laravel already manages the JWT in server-side session (`session('jwt')`) protected by an httpOnly session cookie
- No need for Core-API to set a separate JWT cookie; duplicating token storage adds complexity
- Socket.IO `auth` object prevents token leakage in URL query params and browser history
- Industry standard for BFF architectures

**Alternatives Considered**:
1. **Keep localStorage + implement CSP** - Rejected: CSP alone insufficient, doesn't prevent all XSS vectors
2. **SessionStorage** - Rejected: Still accessible to JavaScript, same XSS risk
3. **IndexedDB** - Rejected: More complex, still JavaScript-accessible
4. **Core-API sets httpOnly JWT cookie** - Rejected: Requires CORS/cookie coordination across services; unnecessary because BFF session already provides equivalent protection

**Implementation Approach**:
```typescript
// Client-App Frontend: remove broken localStorage reads
// Two components bypass BFF and read from localStorage (always get null — broken):
// - CourseExportButton.tsx (3 occurrences)
// - DataExportButton.tsx (3 occurrences)
// Replace with getAuthToken() which fetches from /api/auth/token

// Before (broken):
const token = localStorage.getItem('auth_token');  // always null
// After (working):
const token = await getAuthToken();  // fetches from BFF session

// Client-App WebSocket: use Socket.IO auth object instead of URL query param
io(SOCKET_URL, { auth: { token } });

// Client-App Backend: Laravel session already stores JWT via existing login flow
// No changes needed — BFF architecture already correct
```

**Migration Path**:
> Note: "Immediate fix" in IMPLEMENTATION_PRIORITIES.md means deployment starts immediately and the secure BFF session path becomes the default. A short dual-support window prevents breaking users who currently have a cached localStorage token.

1. Frontend removes localStorage writes in `auth.ts`; keep a read fallback for 1-2 days so existing cached tokens can still be used while the new code rolls out
2. Frontend switches WebSocket auth from URL query param to Socket.IO `auth` object
3. Backend (Laravel) continues to manage JWT in session as before; no Core-API changes needed
4. Monitor for 24-48h to ensure no regressions
5. Remove localStorage read fallback after the transition window

**Breaking Changes**: None during transition - Laravel session auth continues working. After transition window, any client still relying on `localStorage.getItem('auth_token')` must re-login.

**Detailed Implementation**: See `Kolabri-client-app/openspec/changes/client-app-security-hardening/` for file-level tasks and acceptance criteria.

---

### C4: WebSocket Error Handling - Comprehensive Logging + Retry

**Decision**: Replace empty catch blocks with proper error logging, retry logic, and user notifications.

**Rationale**:
- AI interventions are high-value feature → failures must be visible
- Silent failures degrade user experience without indication
- Transient errors (network blips) should auto-retry
- Persistent failures need user notification for transparency

**Alternatives Considered**:
1. **Logging only, no retry** - Rejected: Transient failures would still break features
2. **Exponential backoff with unlimited retries** - Rejected: Could overload AI Engine
3. **Fire-and-forget with no tracking** - Rejected: No visibility into failure rates

**Implementation Approach**:
```typescript
// Replace:
aiEngineService.trackActivity(...).catch(() => {});

// With:
aiEngineService.trackActivity(...).catch(async (err) => {
  logger.error('Activity tracking failed', {
    userId, activityType,
    error: err.message,
    stack: err.stack
  });

  // Retry once after 5s for transient failures
  if (isRetryable(err)) {
    await new Promise(resolve => setTimeout(resolve, 5000));
    return aiEngineService.trackActivity(...).catch(finalErr => {
      logger.error('Activity tracking retry failed', { finalErr });
      // Emit event for monitoring/alerting
    });
  }
});
```

**Retry Strategy**:
- Max 1 retry with 5s delay (simple, predictable)
- Only retry on network errors (503, timeout)
- Not retry on 4xx errors (client fault)

**Breaking Changes**: None - only improves error handling

---

### H1: Search Hardening - Defense-in-Depth + Error Handling Fix

**Decision**: Add BOOLEAN MODE operator sanitization as defense-in-depth layer, and fix incorrect exception types in catch blocks that make the LIKE fallback dead code.

**Current State (from codebase verification)**:
- `MessageSearchController.php` uses **parameterized queries** — `$query . '*'` is a bound parameter (`?`), NOT concatenated into SQL. **Not SQL injectable.**
- LIKE fallback also uses Eloquent parameter binding — safe.
- **Real bug**: Catch blocks catch `ConnectionException`/`RequestException` (HTTP client errors), NOT `QueryException` (database errors). If FULLTEXT index fails, the fallback never triggers.

**Rationale**:
- Defense-in-depth: Even though parameterization prevents injection, stripping BOOLEAN operators adds extra protection
- Wrong exception types mean the LIKE fallback is dead code — needs fixing
- Input validation bounds (min:2, max:100) already exist — adequate

**Implementation Approach**:
```php
// 1. Fix exception types (CRITICAL - makes fallback actually work)
// Replace:
} catch (ConnectionException $e) {
// With:
} catch (\Illuminate\Database\QueryException $e) {

// 2. Add defense-in-depth BOOLEAN MODE sanitization
$booleanOperators = '/[+\-\>\<\(\)\~\*"\@]/';
$sanitizedQuery = preg_replace($booleanOperators, ' ', $query);
$sanitizedQuery = preg_replace('/\s+/', ' ', trim($sanitizedQuery));

// 3. Use sanitized query for FULLTEXT
$messagesQuery->whereRaw(
    'MATCH(content) AGAINST(? IN BOOLEAN MODE)',
    [$sanitizedQuery . '*']  // bound parameter - already safe
);

// 4. LIKE fallback with parameter binding (already safe)
$messagesQuery->where('content', 'LIKE', '%' . $query . '%');
```

**Security Testing**: Verify these payloads are neutralized:
- `test* OR 1=1 --` → BOOLEAN operators removed (defense-in-depth, already safe via parameterization)
- `react.js, AI/ML!` → punctuation preserved (only strip BOOLEAN operators)

**Breaking Changes**: None - adds extra sanitization layer + fixes dead fallback code

---

### H2: Chat Authorization - Cross-Conversation Access Control (REST Routes)

**Decision**: Add group membership validation to REST API chat message operations (search, pin, unpin) in `routes/chat.routes.ts`. Socket.IO already has room-based auth (`socket.rooms.has(roomId)`).

**Current State (from codebase verification)**:
- **Socket.IO** (`socket/messages.ts`): Already validates room membership (line 34) and sender ownership for delete (line 51). ✅ SECURE
- **REST API** (`routes/chat.routes.ts`): Message search, pin, unpin endpoints query ChatLog directly WITHOUT verifying the user is a member of the group that owns that chatSpace. ❌ VULNERABLE

**Rationale**:
- REST routes accept `conversation_id` from request body but never validate ownership
- Codebase uses **Mongoose** (ChatLog model), not Prisma
- Any authenticated user can search/pin/unpin messages across all groups

**Implementation Approach**:
```typescript
// In routes/chat.routes.ts - add authorization middleware
// Uses Mongoose patterns (NOT Prisma)

async function assertChatMembership(req: Request, res: Response, next: NextFunction) {
    const { messageId } = req.params;
    const userId = req.user.userId;

    // Find message with chatSpace and group population
    const message = await ChatLog.findById(messageId)
        .populate({
            path: 'chatSpaceId',
            populate: {
                path: 'groupId',
                populate: { path: 'members' }
            }
        });

    if (!message) {
        return res.status(404).json({ message: 'Message not found' });
    }

    const group = message.chatSpaceId?.groupId;
    const isMember = group?.members?.some(
        (m: any) => m.userId?.toString() === userId
    );

    if (!isMember) {
        return res.status(403).json({ message: 'Not authorized to access this chat' });
    }

    next();
}

// Apply to REST endpoints:
router.get('/messages/search', assertChatMembership, searchHandler);
router.post('/messages/:id/pin', assertChatMembership, pinHandler);
router.post('/messages/:id/unpin', assertChatMembership, unpinHandler);
```

**Apply to Operations** (REST only — Socket.IO already secured):
- GET /messages/search
- POST /messages/:messageId/pin
- POST /messages/:messageId/unpin
- PATCH /messages/:messageId/topic

**Schema Verification Required**: Before implementation, confirm Mongoose schema has:
- `ChatLog.chatSpaceId` → ref to ChatSpace
- `ChatSpace.groupId` → ref to Group
- `Group.members` → array with userId
If relations differ, adjust populate query accordingly.

**Testing**: Attempt cross-conversation access with Student A's token on Student B's messages via REST endpoints

**Breaking Changes**: None - only adds authorization checks (legitimate requests unchanged)

---

### H3: File Upload Hardening - Verify & Strengthen Existing Validation

**Decision**: Verify existing MIME type validation is comprehensive, reconcile whitelist with spec, ensure private disk storage and authenticated file serving.

**Current State (from codebase verification)**:
- `CourseController.php` **ALREADY has** MIME type whitelist validation (line 241-258):
  ```php
  $allowedMimetypes = [
      'application/pdf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain', 'text/markdown',
      'image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp',
      'application/zip', 'application/x-zip-compressed',
  ];
  // 'files.*' => 'file|mimetypes:' . implode(',', $allowedMimetypes) . '|max:51200'
  ```
- `ChatUploadController.php` and `ProfileAvatarController.php` also have validation ✅

**Remaining Work**:
1. **Reconcile whitelist**: Code includes `image/*`, `text/markdown`, `application/zip` (not in spec). Spec includes older Office formats `application/msword`, `application/vnd.ms-excel` (not in code).
2. **Verify private disk**: Confirm files stored with `'private'` disk, not `'public'`
3. **Verify authenticated serving**: Confirm file download endpoint requires auth + course membership check

**Implementation Approach**:
```php
// RECONCILED whitelist (union of code + spec):
$allowedMimetypes = [
    'application/pdf',
    'application/msword',  // ADD: older .doc
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',  // ADD: older .xls
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',  // ADD: older .ppt
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain',
    'text/markdown',  // KEEP from code
    'image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp',  // KEEP from code
    'application/zip', 'application/x-zip-compressed',  // KEEP from code
];

// VERIFY storage disk:
$file->storeAs('knowledge-base', $sanitizedName, 'private');  // NOT 'public'
```

**Breaking Changes**: None - strengthens existing validation

---

### H4: Reflection Privacy - Verify Existing Ownership Validation

**Decision**: Verify existing ownership validation is comprehensive, add authorization logging for security monitoring.

**Current State (from codebase verification)**:
- `reflection.controller.ts` **ALREADY passes** `req.user.userId` and `req.user.role` to service (line 47-50)
- `reflection.service.ts` `getGoalReflections` (line 156-205) validates group membership before returning data ✅
- `getMyReflections` filters by userId ✅
- `createReflection` verifies group membership (line 34-37) ✅

**Existing security is already properly implemented.** The remaining work is:
1. **Verify** all reflection access paths are secured (including edge cases)
2. **Add authorization logging** for unauthorized access attempts (security monitoring)
3. **Add integration tests** to prove ownership checks work

**Implementation Approach**:
```typescript
// ADD: Authorization logging for security monitoring
// In reflection.service.ts - getGoalReflections()

// If user is NOT authorized, log the attempt BEFORE returning empty/404
if (!isAuthorized) {
    logger.warn('Unauthorized reflection access attempt', {
        requestingUserId: userId,
        targetGoalId: goalId,
        userRole: role,
        timestamp: new Date().toISOString(),
        label: 'unauthorized_reflection_access',
    });
    throw new ApiError(404, 'Reflection not found or not authorized');
}
```

**Testing**: Write integration tests proving:
- Student A cannot access Student B's reflections (returns 404)
- Student A cannot update/delete Student B's reflections
- Lecturer can access reflections for their groups

**Breaking Changes**: None - adds logging and tests to existing secure implementation

---

### H5: File Batch Recovery - Partial Success

**Decision**: Replace Promise.all with Promise.allSettled for file batch operations where applicable.

**Current State (from codebase verification)**:
- `Promise.all` used in 28 locations across Core-API, but primarily for **database queries and analytics** (not file uploads)
- File uploads are proxied through BFF (Laravel) to Core-API one-at-a-time
- `aiEngine.service.ts` line 493: `Promise.all` for file buffer processing — closest match
- `socket/index.ts` line 81: `Promise.all` for batch room updates

**Scope Clarification**: No dedicated batch file upload endpoint found. The most relevant application is `aiEngine.service.ts` file buffer processing. If a batch upload feature is added later, Promise.allSettled should be used from the start.

**Implementation Approach**:
```typescript
// Replace:
const results = await Promise.all(uploadPromises);

// With:
const settledResults = await Promise.allSettled(uploadPromises);

const successful: string[] = [];
const failed: Array<{ fileName: string; error: string }> = [];

settledResults.forEach((result, index) => {
  if (result.status === 'fulfilled') {
    successful.push(result.value.fileUrl);
  } else {
    failed.push({
      fileName: fileNames[index],
      error: result.reason.message,
    });
  }
});

return res.status(207).json({  // 207 Multi-Status
  message: `Uploaded ${successful.length}/${settledResults.length} files`,
  successful,
  failed,
});
```

**Response Format** (207 Multi-Status):
```json
{
  "message": "Uploaded 4/5 files",
  "successful": ["file1.pdf", "file2.docx", "file3.xlsx", "file4.pptx"],
  "failed": [
    { "fileName": "file5.txt", "error": "Network timeout" }
  ]
}
```

**Frontend Handling**: Show partial success notification + retry button for failed files

**Breaking Changes**: Response format changes from 200 to 207, but frontend can handle both

---

### H6: Query Error Logging - Visibility

**Decision**: Add comprehensive error logging to resolveWeekLabelsByIds() with warning flags. Also fix assertCourseWeekBelongsToCourse() silent error masking.

**Rationale**:
- Silent failures make debugging impossible
- Empty catch block hides database errors, data inconsistencies
- `assertCourseWeekBelongsToCourse` returns dummy data on error — masks real failures

**Current State (from codebase verification)**:
```typescript
// group.service.ts line 60-62:
catch {
    // course_weeks lives in client-app MySQL  ← EMPTY CATCH
}

// group.service.ts line 39-42:
catch (e) {
    if (e instanceof ApiError) throw e;
    return { id: weekId, course_id: courseId, week_index: 0, title: '' };  ← DUMMY DATA
}
```

**Alternatives Considered**:
1. **Throw errors instead of silent catch** - Rejected: Would break entire response for minor data issue
2. **Return error objects in response** - Rejected: Exposes internal details to client
3. **Metrics only, no logging** - Rejected: Insufficient for debugging specific failures

**Implementation Approach**:
```typescript
async resolveWeekLabelsByIds(weekIds: string[]) {
  try {
    const weeks = await prisma.courseWeek.findMany({
      where: { id: { in: weekIds } },
      select: { id: true, weekIndex: true, title: true },
    });

    return weeks.reduce((map, week) => {
      map[week.id] = {
        weekIndex: week.weekIndex,
        weekTitle: week.title,
      };
      return map;
    }, {} as Record<string, { weekIndex: number; weekTitle: string }>);

  } catch (error) {
    logger.error('Failed to resolve week labels', {
      weekIds,
      error: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString(),
    });

    // Return empty map + set warning flag
    return {};
  }
}

// In calling code (chat space list response):
const weekLabels = await groupService.resolveWeekLabelsByIds(weekIds);

return res.json({
  chatSpaces,
  weekLabels,
  warnings: Object.keys(weekLabels).length === 0 ? ['Week data unavailable'] : [],
});
```

**Monitoring**: Set up alerts for repeated errors (indicates systemic issue)

**Breaking Changes**: None - adds optional warnings field to response

---

### H7: Circuit Breaker Expansion - Cover discussion-direction Service

**Decision**: Expand existing circuit breaker to discussion-direction service. The aiEngine.service.ts already uses circuit breaker correctly.

**Current State (from codebase verification)**:
- `circuitBreaker.ts`: Full CircuitBreaker class with CLOSED/OPEN/HALF_OPEN states ✅
- `aiEngineCircuitBreaker` already configured: `failureThreshold: 5, cooldownMs: 30000` ✅
- `aiEngine.service.ts` line 261: Already uses `aiEngineCircuitBreaker.execute()` ✅
- `withRetry` and `isRetryableError` helpers already exist ✅
- **discussion-direction.service.ts**: Does NOT use circuit breaker ❌ — this is the remaining work

**Config Note**: Code uses `cooldownMs: 30000` (30s), not 60s. Keep 30s for faster recovery.

**Implementation Approach**:
```typescript
// Import EXISTING circuit breaker utility (already used by aiEngine.service.ts)
import { aiEngineCircuitBreaker } from '@utils/circuitBreaker';

// Wrap discussion-direction calls with SAME circuit breaker
async getDiscussionDirection(chatSpaceId: string, context: any) {
  return aiEngineCircuitBreaker.execute(async () => {
    const response = await axios.post(
      `${process.env.AI_ENGINE_URL}/discussion-direction`,
      { chatSpaceId, context },
      {
        headers: { 'X-API-Key': process.env.AI_ENGINE_SECRET },
        timeout: 10000,
      }
    );
    return response.data;
  });
}
```

**Circuit States** (from existing implementation):
- **CLOSED**: Normal operation, requests pass through
- **OPEN**: After 5 failures, fast-fail for 30s (no requests sent)
- **HALF-OPEN**: After 30s, try one request to test recovery

**Graceful Degradation**: When circuit is OPEN, return default response:
```typescript
catch (error) {
  if (error.message === 'Circuit breaker is OPEN') {
    logger.warn('AI Engine circuit breaker open, using fallback');
    return { direction: 'continue', confidence: 0 };  // Neutral fallback
  }
  throw error;
}
```

**Breaking Changes**: None - transparent to API consumers

---

### H8: Auth Secret Fix - Environment Variable

**Decision**: Correct AI_ENGINE_SECRET reference in discussion-direction service.

**Rationale**:
- Code references process.env.CORE_API_SECRET (wrong variable)
- Should be process.env.AI_ENGINE_SECRET (correct variable)
- Causes 403 Forbidden errors on AI Engine requests
- Simple typo fix with immediate impact

**Alternatives Considered**:
None - this is a straightforward bug fix.

**Implementation Approach**:
```typescript
// Replace:
headers: { 'X-API-Key': process.env.CORE_API_SECRET }

// With:
headers: { 'X-API-Key': process.env.AI_ENGINE_SECRET }
```

**Verification**:
- Check .env.example has AI_ENGINE_SECRET documented
- Verify production .env has variable set
- Test API call returns 200 instead of 403

**Breaking Changes**: None - fixes broken functionality

---

## Risks / Trade-offs

### Cookie Authentication Migration (C1)
**Risk**: Two export components (CourseExportButton, DataExportButton) currently read from localStorage and always get null — they are broken relics
→ **Mitigation**: Migrate to getAuthToken() or remove entirely if unused

### WebSocket Retry Logic (C4)
**Risk**: Retry storms if AI Engine is down (many clients retrying simultaneously)
→ **Mitigation**: Single retry with 5s delay, exponential backoff not used (simpler, bounded)

**Risk**: User not notified if both attempts fail
→ **Mitigation**: Emit WebSocket event for frontend toast notification

### Search Hardening (H1)
**Risk**: Boolean operator stripping might affect legitimate search queries
→ **Mitigation**: Only strip BOOLEAN MODE operators, keep alphanumeric + spaces. Queries already parameterized (not injectable), this is defense-in-depth only.

**Risk**: Wrong exception types in catch blocks mean LIKE fallback is dead code
→ **Mitigation**: Fix catch to use QueryException instead of ConnectionException/RequestException

### Authorization Checks (H2, H4)
**Risk**: REST API chat routes lack group membership validation
→ **Mitigation**: Add assertChatMembership middleware to REST endpoints. Socket.IO already has room-based auth.

**Risk**: Reflection service already secured — risk is false positive
→ **Mitigation**: Verify with integration tests, add authorization logging for monitoring

### MIME Type Validation (H3)
**Risk**: Whitelist mismatch between code and spec
→ **Mitigation**: Reconcile whitelist (union of both). Code already validates — just ensuring completeness.

### Promise.allSettled (H5)
**Risk**: Batch file upload endpoint may not exist as described
→ **Mitigation**: Apply to aiEngine.service.ts file processing. If batch upload feature added later, use Promise.allSettled from start.

### Circuit Breaker (H7)
**Risk**: discussion-direction service bypasses existing circuit breaker
→ **Mitigation**: Wrap with same `aiEngineCircuitBreaker` instance used by aiEngine.service.ts. Config: failureThreshold=5, cooldownMs=30000.

---

## Migration Plan

### Phase 1: Pre-Deployment (Day 0)
1. **Code Review**: Security team reviews all authorization checks, input validation, error handling
2. **Testing**: QA validates all 10 fixes in staging environment
3. **Documentation**: Update API docs with new error responses (207 Multi-Status, warning flags)
4. **Monitoring Setup**: Configure alerts for circuit breaker state changes, retry failures, unauthorized access attempts

### Phase 2: Deployment (Day 1)
1. **Database**: No schema changes required
2. **Backend Deploy**:
   - Core-API: Deploy with cookie auth (support both localStorage + cookie for 2 weeks)
   - Client-App Backend: Deploy with SQL sanitization and MIME validation
3. **Frontend Deploy**:
   - Remove localStorage token usage
   - Add handlers for 207 Multi-Status responses
   - Add toast notifications for async operation failures
4. **Configuration**: Verify AI_ENGINE_SECRET is set in all environments

### Phase 3: Validation (Day 1-2)
1. **Smoke Tests**: Login flow, file uploads, chat operations, reflection access
2. **Security Tests**: Verify XSS token theft prevented, SQL injection blocked, unauthorized access denied
3. **Performance**: Monitor latency impact of authorization checks (<100ms acceptable)
4. **Error Rates**: Track 403/404 error rates for authorization checks (should be near zero for legitimate users)

### Phase 4: Monitoring (Day 2-14)
1. **Cookie Migration**: Monitor localStorage vs cookie authentication usage
2. **Circuit Breaker**: Track AI Engine circuit state (should stay CLOSED under normal load)
3. **Batch Uploads**: Measure partial success rates (target: >95% full success)
4. **Error Logging**: Review logs for unexpected query failures, retry patterns

### Phase 5: Cleanup (Day 15)
1. **Remove localStorage Support**: Core-API drops token-from-header authentication
2. **Documentation**: Update developer guides with new security patterns
3. **Retrospective**: Review security fix impact, identify additional improvements

### Rollback Strategy
- All changes are additive (authorization checks, validation layers)
- Rollback: Deploy previous version, no data cleanup needed
- Cookie migration: If critical issues, re-enable localStorage in frontend temporarily
- No database changes means instant rollback capability

---

## Open Questions

None - all implementation decisions finalized and approved.
