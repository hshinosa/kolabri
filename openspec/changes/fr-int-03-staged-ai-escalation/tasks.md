## 1. Escalation State Modeling

- [x] 1.1 Add `EscalationState` MongoDB model + Prisma schema with indexes (reuse existing `SilenceEvent` pattern)
- [x] 1.2 Run `prisma db push` to sync `EscalationState` + `aiEscalationConfig` field on `Course` model
- [x] 1.3 Create `EscalationService` with `findOrCreateState()`, `advanceStage()`, `resolveState()`, `shouldNotifyLecturer()`
- [x] 1.4 Add feature flag `STAGED_ESCALATION_ENABLED` (default false, fallback to current binary behavior)

## 2. Wrap Existing Interventions with Stage Gates

- [x] 2.1 Update `runSilenceIntervention()` (`socket/interventions.ts`) — check state before nudging, advance to `nudge` after
- [x] 2.2 Update `checkAndIntervenForQuality()` (`socket/index.ts:708`) — stage-aware: nudge if `new`, probe if `nudge`, flag if `probe-blocker`; skip if `flag-lecturer` (already escalated); auto-resolve if `resolved`
- [x] 2.3 Update AI Chat `should_notify_teacher` handler (`socket/index.ts:1015`) — advance to `flag-lecturer` instead of direct `lecturer_alert` emit
- [x] 2.4 Add message listener to auto-resolve escalation when discussion resumes (new student messages + quality OK → set `resolved`)

## 3. Notification and Visibility

- [x] 3.1 Move `lecturer_alert` emit + notification creation into `EscalationService.advanceStage('flag-lecturer')` with deduplication
- [x] 3.2 Add `GET /api/lecturer/escalations?courseId=...` endpoint — list active + history per course
- [x] 3.3 Add `POST /api/lecturer/escalations/:id/resolve` endpoint — lecturer manual resolution
- [x] 3.4 Add escalation panel to `resources/js/pages/lecturer/dashboard.tsx` — list active escalations with resolve button, filter by course/group

## 4. Verification

- [x] 4.1 Add tests for stage progression (`new` → `nudge` → `probe-blocker` → `flag-lecturer` → `resolved`)
- [x] 4.2 Add tests for duplicate-notification suppression (same issue should not spam alerts)
- [x] 4.3 Add tests for timeout thresholds (silence persists → stage advances)
- [x] 4.4 Add tests for feature flag fallback (when disabled, use current binary behavior)
- [x] 4.5 Validate lecturer-facing views reflect current escalation state accurately
