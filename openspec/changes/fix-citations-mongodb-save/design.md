## Context

**Investigation Summary**: A 2+ hour production investigation (2026-06-26, 05:00-06:14) revealed that AI-generated citations from RAG are being created successfully by the AI engine but are not persisting to MongoDB ChatLog documents. This breaks the structured citation display UI while still allowing AI to mention materials in text responses.

**Evidence Chain**:
- ✅ **AI Engine Layer**: Logs confirm `rag_citations_extracted num_citations=1` and `orchestration_citations_received num_citations=1`
- ✅ **HTTP Response Layer**: Pydantic `OrchestrationResponse` schema includes `citations: List[Dict[str, Any]] = []` at line 403
- ✅ **FastAPI Serialization**: Response model includes field → citations should be in HTTP response body
- ❌ **MongoDB Layer**: Direct query of ChatLog document at timestamp 06:04:11.666Z shows NO `citations` field despite AI engine confirming num_citations=1 for that exact request

**Narrowed Scope**: Issue isolated to core-api socket handler (`socket/index.ts` lines 1327-1400) between receiving HTTP response from `aiEngineService.orchestratedChat()` and saving to MongoDB via `chatLog.save()`. The variable `filteredCitations` is empty at save time despite AI engine returning citations.

**Current State**: Comprehensive diagnostic logging deployed (06:13:08 rebuild) with string interpolation at three critical points:
1. Line 1327: After receiving orchestration response (logs `result.citations` count)
2. Line 1364: Before ChatLog creation (logs `filteredCitations` count)
3. Line 1261: Streaming path alternative (for completeness)

Next test execution will reveal exact failure point.

## Goals / Non-Goals

**Goals**:
- Execute test with deployed logging to capture citation counts at critical points
- Identify exact line/operation where citations are lost (HTTP deserialization, variable assignment, or conditional logic)
- Apply targeted fix (expected 1-5 line change) to restore citation persistence
- Verify citations flow correctly: AI engine → HTTP response → core-api variable → MongoDB document → client
- Maintain diagnostic logging for future observability

**Non-Goals**:
- NOT modifying AI engine RAG logic (already working, proven with logs)
- NOT changing citation display UI (already implemented, just needs data)
- NOT refactoring socket handler architecture (surgical fix only)
- NOT changing database schema or collection structure (likely correct)
- NOT modifying week filtering logic (already fixed in previous session)

## Decisions

### Decision 1: Diagnostic-first approach

**Choice**: Execute test with existing logging before making any code changes.

**Rationale**:
- Evidence strongly points to core-api socket handler lines 1327-1400
- Exact failure point unknown (could be HTTP deserialization at line 1294, variable assignment at line 1367, or conditional logic at line 1386)
- Logging will definitively show if `result.citations` is populated when received, and if `filteredCitations` is populated before save
- 2-minute test execution saves hours of trial-and-error fixes

**Alternatives Considered**:
- **Guess the fix**: Add null checks, type coercion, or fallback logic → Rejected: Risks fixing wrong layer or introducing new bugs
- **Revert to known-good version**: Roll back socket handler → Rejected: Citations never worked, no known-good version exists
- **Add workaround in AI engine**: Re-emit citations in separate event → Rejected: Treats symptom not cause, adds complexity

**Trade-offs**: Requires one test execution before fix (adds ~2 minutes), but eliminates ambiguity and ensures correct fix target.

### Decision 2: Target core-api socket handler variable flow

**Choice**: Focus fix on data preparation between line 1327 (after `orchestratedChat()`) and line 1398 (`chatLog.save()`), specifically the `filteredCitations` variable population and conditional save logic.

**Rationale**:
- AI engine proven working (orchestration logs show citations returned)
- Pydantic schema proven correct (line 403 includes citations field)
- MongoDB save code structure looks correct (line 1386: `citations: filteredCitations.length > 0 ? ...`)
- Process of elimination points to data preparation: `result.citations` → `filteredCitations` → save object

**Most Likely Issue**: Line 1367 sets `filteredCitations = result.citations ?? []`. If `result.citations` is `null`, `undefined`, or already `[]` when received, this would explain empty array at save time.

**Alternatives Considered**:
- **TypeScript type mismatch**: `OrchestrationResponse` type in core-api might not include `citations` → Logging will show if field is missing
- **HTTP deserialization issue**: `response.json()` might drop field → Logging will show if field is missing
- **MongoDB schema constraint**: Mongoose might reject citations field → Less likely, but logging will show if field reaches save call

### Decision 3: Preserve diagnostic logging post-fix

**Choice**: Keep the three logging statements in place after fix is applied.

**Rationale**:
- Provides production observability for citation data flow
- Enables quick diagnosis of future regressions
- Minimal performance impact (~3 log lines per AI response, string interpolation)
- Already validated safe (deployed for >1 hour without issues)

**Trade-offs**:
- (+) Future debugging will be trivial (logs show exact citation counts at each layer)
- (-) Slight increase in log volume (~30 bytes per AI message)
- Net: Acceptable trade-off for production system with complex data flow

## Risks / Trade-offs

### [Risk] Logging reveals issue is in TypeScript type definitions
**Impact**: `result.citations` field missing from deserialized object despite being in JSON
**Mitigation**: Update `OrchestrationResponse` type in `aiEngine.service.ts` to explicitly include `citations: Array<any>` field. Verify against AI engine schema at `app/api/schemas.py:403`.

### [Risk] Issue is in HTTP deserialization library
**Impact**: `response.json()` silently drops citations field
**Mitigation**: Add explicit JSON parsing with field validation, or use type-safe deserialization library. Consider adding runtime assertion to catch field drops.

### [Risk] MongoDB schema doesn't allow citations field
**Impact**: Save succeeds but field is dropped by Mongoose
**Likelihood**: Low (schema likely permits dynamic fields)
**Mitigation**: Verify Mongoose `ChatLog` schema explicitly allows or defines citations field. Add if missing.

### [Risk] Fix breaks existing null/undefined handling
**Impact**: Adding citations causes errors in downstream code expecting undefined
**Mitigation**: Review client-side code for null safety. The spec requires graceful handling of empty citations (`citations: []` or omitted field).

### [Trade-off] Diagnostic logging increases log volume
**Impact**: +30 bytes per AI message, ~1-2MB per 10k messages
**Benefit**: Instant visibility into citation data flow, prevents future multi-hour investigations
**Decision**: Accept trade-off, log volume increase is negligible vs. debugging value

## Migration Plan

### Phase 1: Diagnostic Test Execution
1. Authenticate to production session (https://kolabri.web.id/student/discussion-sessions/45e208ae-7006-416c-aa32-cfc172ef1d7a)
2. Send test message: "@ai jelaskan cara kerja K-Means clustering secara singkat"
3. Wait 15 seconds for AI response
4. Capture logs from core-api container: `docker logs --since 1m kolabri-core-api | grep "DEBUG citations"`
5. Capture logs from ai-engine container: `docker logs --since 1m kolabri-ai-engine | grep "citations_extracted\|citations_received"`

**Expected Log Pattern (if citations returned by AI)**:
```
ai-engine: rag_citations_extracted num_citations=1
ai-engine: orchestration_citations_received num_citations=1
core-api: [DEBUG citations non-streaming] session=... count=1
core-api: [DEBUG citations pre-save] filteredCount=1 willSave=true
```

**Failure Interpretation**:
- If `count=0` at non-streaming → HTTP response issue (fix in aiEngineService)
- If `count=1` at non-streaming, `filteredCount=0` at pre-save → variable flow issue (fix between line 1327-1364)
- If `filteredCount=1` but MongoDB missing → save logic issue (fix at line 1386 or schema)

### Phase 2: Apply Targeted Fix
Based on logs, apply 1-5 line fix at identified failure point:
- **If HTTP response issue**: Update type definition or add explicit field extraction
- **If variable flow issue**: Fix assignment or conditional logic at line 1367
- **If save logic issue**: Update conditional at line 1386 or Mongoose schema

Deploy via: `scp socket/index.ts → rebuild core-api → restart`

### Phase 3: Verification Test
1. Repeat test message
2. Verify logs show citations at all three checkpoints
3. Query MongoDB directly: `db.chatlogs.find({sessionDiscussionId: "...", senderType: "ai"}).sort({createdAt: -1}).limit(1)`
4. Confirm `citations` field present with expected data
5. Verify UI displays citation chips

### Phase 4: Rollback Strategy (if needed)
- Logging is already safe (deployed >1 hour)
- If fix causes issues, revert specific change only (1-5 lines targeted)
- ChatLog schema changes (if any) are additive, no migration needed
- Full rollback: `git revert <commit>` → rebuild → restart

**Rollback Decision Criteria**: If fix causes new errors OR citations still missing after fix, revert and investigate alternative hypothesis.

## Open Questions

None. Investigation is complete. Only awaiting test execution to pinpoint exact line for surgical fix.

**Post-Fix Questions** (to address after implementation):
- Should we add integration test to prevent regression? (Recommended: yes, add to core-api test suite)
- Should we backfill missing citations for historical messages? (Probably no - RAG context from past sessions is stale)
- Should we add Sentry alerting for "citations created but not saved" condition? (Consider for future observability enhancement)
