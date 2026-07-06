## 1. Schema and Persistence

- [ ] 1.1 Create Prisma migration adding 6 nullable columns to ChatLog: guardrailReason, guardrailOutcome, interventionType, interventionReason, scaffoldingLevel, qualityScore
- [ ] 1.2 Update ChatLog Prisma model with the 6 new fields (all optional)
- [ ] 1.3 Update ChatLog create/save functions to accept and persist the new metadata fields
- [ ] 1.4 Update ChatLog read API responses to include the 6 new fields

## 2. Socket Handler Metadata Extraction

- [ ] 2.1 Map orchestration result metadata (reason, guardrail_reason, intervention_type, explanation, rationale) to ChatLog fields in the socket handler
- [ ] 2.2 Pass mapped metadata to ChatLog save function alongside content
- [ ] 2.3 Handle partial metadata gracefully (null for missing fields)

## 3. Audit Logging

- [ ] 3.1 Create `ai_response_generated` audit event type
- [ ] 3.2 Emit audit entry on every AI response with full metadata (sessionId, chatLogId, guardrail fields, scaffoldingLevel, qualityScore, timestamp)
- [ ] 3.3 Ensure existing `guardrail_triggered` audit entries remain unchanged
- [ ] 3.4 Add query endpoint or extend existing audit query to filter by sessionId and event type

## 4. User-Facing Explanation UI

- [ ] 4.1 Add intervention badge component that renders when interventionType or guardrailOutcome is non-null
- [ ] 4.2 Badge text shows intervention type (e.g. "Scaffolding", "Redirected")
- [ ] 4.3 Add tooltip on badge hover/tap showing interventionReason and scaffoldingLevel
- [ ] 4.4 Add "AI is helping" indicator when scaffoldingLevel is non-null
- [ ] 4.5 No badge or indicator when all intervention fields are null

## 5. Dashboard Escalation Visibility

- [ ] 5.1 Add escalation reason column to lecturer session monitoring table
- [ ] 5.2 Display interventionType and interventionReason in session detail view for each AI message
- [ ] 5.3 Handle sessions with no escalation (empty or "None" display)
