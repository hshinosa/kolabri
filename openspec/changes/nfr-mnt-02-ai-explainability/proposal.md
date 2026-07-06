## Why

The AI Engine returns rich metadata (guardrail reasons, intervention types, quality scores, explanations) for every response, but the system discards all of it at the persistence layer. ChatLog only stores `content`. Audit logs capture guardrail triggers but skip normal AI responses. Students never see why the AI intervened, and lecturers can't trace escalation reasons. This violates NFR-MNT-02 (AI explainability) and makes the AI's behavior opaque to all stakeholders.

## What Changes

- Extend ChatLog schema with six explanation fields: `guardrailReason`, `guardrailOutcome`, `interventionType`, `interventionReason`, `scaffoldingLevel`, `qualityScore`
- Persist full AI metadata from orchestration results in the socket handler (no longer drop metadata on save)
- Add audit log entries for all AI responses (not just guardrail triggers), including metadata
- Surface explanation to users via badge/tooltip on AI messages showing intervention reason and scaffolding level
- Make escalation reasons visible: show in lecturer dashboard, show "AI helping" indicator to students

## Capabilities

### New Capabilities
- `ai-explainability-persistence`: Schema extension and socket handler changes to persist AI metadata with chat logs
- `ai-response-audit`: Audit logging for all AI responses with full metadata
- `ai-explanation-ui`: User-facing explanation display (badges, tooltips, intervention indicators)

### Modified Capabilities
- `dashboard`: Lecturer dashboard gains escalation reason visibility and AI metadata inspection

## Impact

- **Database**: ChatLog table migration adding 6 nullable columns
- **API**: Socket handler payload unchanged (metadata extracted server-side), but ChatLog read APIs return new fields
- **Frontend**: Chat message components need badge/tooltip rendering; dashboard needs escalation reason column
- **Audit**: New `ai_response_generated` event type alongside existing guardrail events
- **Dependencies**: No new packages required
