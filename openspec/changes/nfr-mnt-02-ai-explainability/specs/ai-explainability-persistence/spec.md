## ADDED Requirements

### Requirement: ChatLog stores AI metadata fields
The ChatLog table SHALL include the following nullable columns: `guardrailReason` (text), `guardrailOutcome` (text), `interventionType` (text), `interventionReason` (text), `scaffoldingLevel` (text), `qualityScore` (integer). All columns SHALL be nullable to maintain compatibility with existing rows.

#### Scenario: New AI chat message with full metadata
- **WHEN** an AI response is saved with guardrail reason "off-topic", guardrail outcome "redirected", intervention type "scaffolding", intervention reason "student off-topic", scaffolding level "medium", and quality score 85
- **THEN** the ChatLog row SHALL contain all six fields with the provided values

#### Scenario: AI chat message with no intervention
- **WHEN** an AI response is saved with no guardrail trigger and no intervention
- **THEN** the ChatLog row SHALL have null values for guardrailReason, guardrailOutcome, interventionType, and interventionReason, and SHALL store the scaffoldingLevel and qualityScore if provided

#### Scenario: Existing chat logs remain valid
- **WHEN** the schema migration runs on an existing ChatLog table
- **THEN** all existing rows SHALL remain intact with null values in the new columns

### Requirement: Socket handler persists AI metadata
The Core API socket handler SHALL extract all metadata fields from the AI orchestration result and pass them to the ChatLog save function. No metadata from the orchestration result SHALL be discarded.

#### Scenario: Orchestration result with metadata
- **WHEN** the AI Engine returns an orchestration result containing content, reason, guardrail_reason, intervention_type, explanation, and rationale
- **THEN** the socket handler SHALL map these fields to the corresponding ChatLog columns and persist them

#### Scenario: Orchestration result with partial metadata
- **WHEN** the AI Engine returns an orchestration result with content and quality score but no guardrail or intervention data
- **THEN** the socket handler SHALL persist the available fields and set unavailable fields to null

### Requirement: ChatLog read APIs return metadata
All API endpoints that return ChatLog data SHALL include the six new metadata fields in their response payloads.

#### Scenario: Fetching chat history
- **WHEN** a client requests chat history for a session
- **THEN** each AI message in the response SHALL include guardrailReason, guardrailOutcome, interventionType, interventionReason, scaffoldingLevel, and qualityScore fields
