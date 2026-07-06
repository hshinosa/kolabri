## 1. Diagnostic Investigation

- [ ] 1.1 Authenticate to production session and execute test message with deployed logging
- [ ] 1.2 Capture core-api logs for all three DEBUG citations checkpoints (non-streaming, pre-save, streaming)
- [ ] 1.3 Capture ai-engine logs for rag_citations_extracted and orchestration_citations_received
- [ ] 1.4 Analyze log output to identify exact failure point: HTTP deserialization (count=0 at non-streaming), variable flow (count=1 at non-streaming but filteredCount=0 at pre-save), or save logic (filteredCount=1 but MongoDB missing)

## 2. Root Cause Fix

- [ ] 2.1 Based on diagnostic logs, identify specific line/operation where citations are lost
- [ ] 2.2 Review code at identified failure point (HTTP response parsing, variable assignment, or conditional save logic)
- [ ] 2.3 Apply targeted surgical fix (expected 1-5 line change in socket/index.ts, aiEngine.service.ts, or ChatLog schema)
- [ ] 2.4 If TypeScript type issue: Update OrchestrationResponse interface in aiEngine.service.ts to include citations field
- [ ] 2.5 If variable flow issue: Fix filteredCitations assignment at line 1367 or conditional logic
- [ ] 2.6 If save logic issue: Update conditional at line 1386 or verify Mongoose ChatLog schema allows citations

## 3. Deployment & Verification

- [ ] 3.1 Deploy fix to production VPS (scp modified file + docker compose build + restart container)
- [ ] 3.2 Execute verification test with same query that revealed issue
- [ ] 3.3 Verify diagnostic logs show citations present at all three checkpoints (non-streaming count > 0, pre-save filteredCount > 0)
- [ ] 3.4 Query MongoDB directly to confirm citations field exists in latest AI ChatLog document with expected data structure
- [ ] 3.5 Test UI in browser to verify citation chips render correctly and link to course materials

## 4. Quality Assurance & Documentation

- [ ] 4.1 Add integration test to core-api test suite to prevent regression (test that citations from AI engine are persisted to MongoDB)
- [ ] 4.2 Update RUNTIME_AUDIT_STUDENT_ROLE_2026-06-26.md with fix details and resolution timestamp
- [ ] 4.3 Decide whether to preserve or remove diagnostic logging statements (recommendation: preserve for production observability)
- [ ] 4.4 Test with multiple query phrasings to verify RAG success remains query-dependent but citations persist when RAG succeeds
- [ ] 4.5 Verify no new errors or regressions introduced by fix (check error logs, test adjacent functionality)

## Notes

**Critical Path**: Task 1.4 → 2.1 → 2.3 → 3.4. Cannot proceed to fix without diagnostic results.

**Expected Timeline**:
- Phase 1 (Diagnostic): ~5 minutes (test execution + log capture)
- Phase 2 (Fix): ~10 minutes (1-5 line change + review)
- Phase 3 (Deploy/Verify): ~15 minutes (build + restart + comprehensive verification)
- Phase 4 (QA): ~30 minutes (test writing + documentation)
- **Total**: ~1 hour for complete fix with verification

**Rollback Plan**: If fix introduces new issues, revert specific change (targeted 1-5 lines). Diagnostic logging is already deployed and safe. No schema migrations needed unless MongoDB schema issue identified.

**Success Criteria** (from spec):
- AI engine logs `rag_citations_extracted num_citations=N` where N > 0
- MongoDB ChatLog has `citations` array with length N
- Socket.io emits citations to client
- UI displays N citation chips
