## Context

Kolabri already has intervention infrastructure in production:
- **Silence intervention**: `runSilenceIntervention()` in `socket/interventions.ts` sends bot nudge messages when a room goes silent.
- **Quality monitoring**: `checkAndIntervenForQuality()` in `socket/index.ts` checks engagement after every N messages and triggers quality nudges.
- **AI Chat escalation flag**: `aiEngineService.orchestratedChat()` returns `should_notify_teacher`; socket handler emits `lecturer_alert` event directly.
- **Notification pipeline**: `services/notification.service.ts` + controller + routes handle notification persistence and delivery.
- **SilenceEvent model**: MongoDB model tracks when silence interventions occur.

What is missing: a **persistent staged escalation model** that connects these pieces. Currently the flow is binary — either a nudge happens OR a lecturer alert fires immediately. There is no state machine tracking whether a nudge was already attempted, whether the issue persisted, or whether escalation should proceed to the next stage.

## Goals / Non-Goals

**Goals:**
- Represent escalation stages explicitly (`nudge` → `probe-blocker` → `flag-lecturer` → `resolved`).
- Persist escalation state per issue context (group discussion inactivity, unresolved blocker, repeated non-response).
- Prevent repeated duplicate lecturer alerts for the same unresolved issue (deduplication).
- Expose escalation history for lecturer review in dashboard.
- Reuse existing intervention infrastructure where possible.

**Non-Goals:**
- Full human workflow/case management system.
- Replacing lecturer judgment with automatic punitive action.
- Rewriting the existing silence/quality intervention logic from scratch.

## Current Infrastructure (Reusable)

| Component | File | Reuse Strategy |
|---|---|---|
| Silence nudge | `socket/interventions.ts` | Wrap with stage check: only nudge if stage is `new` or `nudge` |
| Quality check | `socket/index.ts:708` | After quality intervention, advance stage instead of immediate alert |
| AI Chat `should_notify_teacher` | `socket/index.ts:922` | Use as trigger to advance stage, not direct alert |
| Notification service | `services/notification.service.ts` | Call from stage transition handler, not raw event |
| SilenceEvent model | `models/SilenceEvent.ts` | Keep for audit; add `EscalationState` for stage tracking |

## Decisions

### Model escalation as a state machine
Issue handling moves through explicit stages: `new` → `nudge` → `probe-blocker` → `flag-lecturer` → `resolved`. Each stage has entry conditions, exit actions, and timeout thresholds.

### Track escalation state per issue context
State is scoped to `(courseId, groupId, chatSpaceId, issueType)` — not global per course. Issue types for v1: `silence`, `low_quality`, `unresolved_blocker`.

### Reuse existing nudge infrastructure
Do not rewrite `runSilenceIntervention()` or `checkAndIntervenForQuality()`. Instead, add a stage gate: before firing a nudge, check if an escalation state exists. After firing, advance the state. Before firing lecturer alert, check if stage is `flag-lecturer`.

### Lecturer notifications via stage transition
`lecturer_alert` socket event and notification creation should only happen on explicit `flag-lecturer` stage entry, not on raw `should_notify_teacher` from AI. The AI flag becomes a signal to advance stage, not a direct notification trigger.

### Deduplication by unresolved issue
Once an issue reaches `flag-lecturer`, repeated background checks update `EscalationState.history` (append timestamp + reason) instead of creating duplicate notifications. New notification only on re-entry to `flag-lecturer` from a lower stage.

## Data Model

### EscalationState (MongoDB)
```typescript
interface EscalationState {
    _id: ObjectId;
    courseId: string;
    groupId: string;
    chatSpaceId: string;
    issueType: 'silence' | 'low_quality' | 'unresolved_blocker';
    currentStage: 'new' | 'nudge' | 'probe-blocker' | 'flag-lecturer' | 'resolved';
    history: Array<{
        stage: string;
        enteredAt: Date;
        reason: string;
        triggeredBy: string; // 'silence_timer' | 'quality_check' | 'ai_chat' | 'manual'
    }>;
    lastCheckedAt: Date;
    resolvedAt?: Date;
    resolvedBy?: string;
    notificationSentAt?: Date;
    createdAt: Date;
    updatedAt: Date;
}
```

### Prisma (PostgreSQL, for lecturer dashboard queries)
```prisma
model EscalationState {
    id          String   @id @default(uuid())
    courseId    String   @map("course_id")
    groupId     String   @map("group_id")
    chatSpaceId String   @map("chat_space_id")
    issueType   String   @map("issue_type")
    currentStage String  @map("current_stage")
    history     Json     @default("[]")
    lastCheckedAt DateTime @map("last_checked_at")
    resolvedAt  DateTime? @map("resolved_at")
    resolvedBy  String?  @map("resolved_by")
    notificationSentAt DateTime? @map("notification_sent_at")
    createdAt   DateTime @default(now()) @map("created_at")
    updatedAt   DateTime @updatedAt @map("updated_at")

    @@index([courseId, currentStage])
    @@index([groupId, currentStage])
    @@index([chatSpaceId, issueType, currentStage])
    @@map("escalation_states")
}
```

## Stage Transitions

| From | To | Trigger | Action |
|---|---|---|---|
| `new` | `nudge` | Silence timer fires OR quality check fails | Run existing nudge intervention, record state |
| `nudge` | `probe-blocker` | Silence persists after nudge timeout (e.g., 10 min) OR quality still low after nudge | Send probe message ("Ada blocker?"), record state |
| `probe-blocker` | `flag-lecturer` | Blocker confirmed OR no response after probe timeout (e.g., 15 min) OR `should_notify_teacher=true` from AI chat | Create notification, emit `lecturer_alert`, record state |
| `flag-lecturer` | `resolved` | Lecturer marks resolved OR discussion resumes (new messages + quality OK) | Update state, log resolution |
| Any | `resolved` | Manual resolution by lecturer | Immediate resolution |

## Risks / Trade-offs

- **Heuristics may escalate too aggressively** → Start with conservative timeouts (nudge: 5 min silence, probe: 10 min, flag: 15 min). Make thresholds configurable per course.
- **State modeling adds complexity** → Keep v1 to 3 issue types and 5 stages. No sub-states.
- **Students may feel over-monitored** → Use transparent wording for nudges. Do not expose stage names to students.
- **Backward compatibility** → Existing `should_notify_teacher` path must be gated behind stage check. Add feature flag to disable staged escalation and fall back to current binary behavior.

## Migration Plan

1. **Add `EscalationState` model** (MongoDB + Prisma) with indexes.
2. **Create `EscalationService`** — `findOrCreateState()`, `advanceStage()`, `resolveState()`, `shouldNotifyLecturer()`.
3. **Wrap existing interventions**:
   - `runSilenceIntervention()`: check state before nudging, advance to `nudge` after.
   - `checkAndIntervenForQuality()`: check state, nudge if `new`, probe if `nudge`, flag if `probe-blocker`.
   - AI Chat `should_notify_teacher`: advance state to `flag-lecturer` instead of direct alert.
4. **Update notification flow**: Move `lecturer_alert` emit + notification creation into `EscalationService.advanceStage('flag-lecturer')`.
5. **Add lecturer dashboard endpoint**: `GET /api/lecturer/escalations?courseId=...` — list active + history.
6. **Add resolution endpoint**: `POST /api/lecturer/escalations/:id/resolve` — lecturer manually resolves.
7. **Add tests**: Stage progression, deduplication, timeout thresholds, resolution.
8. **Add feature flag**: `STAGED_ESCALATION_ENABLED` env var. Default false until tested.

Rollback: set `STAGED_ESCALATION_ENABLED=false` — system falls back to current binary nudge/alert behavior.

## Open Questions

- [x] What exact timeout values per stage? → Default: nudge 5min, probe 10min, flag 15min. Configurable per course via `course.aiEscalationConfig` JSON field (same pattern as `aiGuardrailConfig`).
- [ ] Should `unresolved_blocker` issue type be detected by AI chat analysis or by explicit student report?
- [ ] Should lecturer dashboard show escalation history per group or per course aggregate?
