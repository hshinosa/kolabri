## Context

The Kolabri AI Engine orchestrates responses through a pipeline that produces rich metadata: guardrail reasons, intervention types, scaffolding levels, quality scores, and human-readable explanations. Currently, the socket handler in the Core API extracts only `content` from the orchestration result and persists that to ChatLog. All other metadata is discarded. The audit subsystem logs guardrail triggers but ignores normal AI responses. This means the system has no record of why the AI responded the way it did, students can't understand AI interventions, and lecturers can't review escalation context.

## Goals / Non-Goals

**Goals:**
- Persist all AI metadata alongside chat messages so every AI response is traceable
- Audit log every AI response (not just guardrail hits) with full metadata
- Show students why the AI intervened (intervention reason, scaffolding level)
- Give lecturers visibility into escalation reasons and AI behavior patterns
- Satisfy NFR-MNT-02 (AI explainability)

**Non-Goals:**
- Changing the AI Engine's orchestration logic or metadata format
- Real-time streaming of metadata (metadata is available at response time)
- Student-facing quality scores (internal metric only)
- Retroactive backfill of historical chat logs with metadata
- New API endpoints for metadata queries (use existing ChatLog read APIs)

## Decisions

**1. Schema extension via nullable columns on ChatLog**

Add 6 nullable columns to the existing `ChatLog` table rather than creating a separate metadata table.

Rationale: The metadata is 1:1 with each chat message. A separate table adds join complexity for no normalization benefit. Nullable columns avoid migration risk for existing rows. Alternative considered: separate `ChatLogMetadata` table with foreign key. Rejected because the relationship is always 1:1 and the fields are small (strings and an integer).

**2. Extract metadata server-side in socket handler**

The socket handler already receives the full orchestration result. Extract metadata fields and pass them to the ChatLog save function. No client-side changes needed.

Rationale: Metadata is already available in the handler. Extracting server-side keeps the wire protocol unchanged and avoids frontend changes for persistence. Alternative: send metadata from client. Rejected because the server already has it.

**3. Audit log entry type `ai_response_generated`**

Add a new audit event type `ai_response_generated` that fires for every AI response, containing the same metadata fields. Existing `guardrail_triggered` events continue unchanged.

Rationale: Guardrail events only cover blocked/modified responses. Normal responses (no guardrail hit) also need audit trails for explainability. Using a separate event type keeps the audit log clean and queryable.

**4. UI: badge + tooltip on AI messages**

Show a small badge on AI messages that had interventions (guardrail or scaffolding). Badge text shows intervention type. Tooltip on hover shows the explanation and scaffolding level. No badge on normal AI responses with no intervention.

Rationale: Keeps the chat UI clean while making interventions discoverable. Alternative: always-visible explanation text. Rejected because it clutters the chat for the majority of messages that have no intervention.

**5. Escalation reason in dashboard + student indicator**

Lecturer dashboard: add escalation reason column to the session monitoring view. Student view: show "AI is helping" indicator when scaffolding is active.

Rationale: Lecturers need the reason for escalation decisions. Students need to know the AI is providing guided help, not just a generic response.

## Risks / Trade-offs

- **Schema migration on large ChatLog table** → Nullable columns with no defaults; migration is additive only, no data rewrite
- **Increased storage per chat message** → 6 extra columns per row; minimal overhead since most are short strings or null
- **Audit log volume increase** → Every AI response now creates an audit entry; acceptable for compliance, monitor storage growth
- **Badge UI clutter on high-intervention sessions** → Badge only shows when intervention occurred; tooltip keeps detail on demand
- **ChatLog schema coordination**: This change adds 6 nullable fields to ChatLog (MongoDB). Other changes also modify ChatLog: nfr-reliability-02 adds `version`, nfr-data-01 changes `isDeleted` → `deletedAt`, nfr-usability-04 adds `isRelevant`. All ChatLog schema changes MUST be applied in a single consolidated migration. Execution order: DATA-01 migration first (breaking change), then MNT-02 + RELIABILITY-02 + USABILITY-04 additive fields together.
