## ADDED Requirements

### Requirement: Week-capped session RAG excludes chunks without week_index

When group student chat retrieval applies a session week cap (`max_week_index` or equivalent), the system SHALL exclude retrieved chunks whose metadata does not include a numeric `week_index`. Chunks ingested from pool-only uploads before week assignment MUST NOT be eligible for session-scoped RAG until week metadata is set on assign/re-ingest.

#### Scenario: Pool-only ingest before assign

- **WHEN** a material was ingested with null week metadata and has not been assigned to a course week
- **THEN** its chunks MUST NOT appear in RAG results for a chat session bound to week N with week cap active

#### Scenario: After assign to week N

- **WHEN** the same material is assigned to week N and knowledge metadata reflects week N
- **THEN** its chunks MAY appear in RAG for sessions capped at week index ≥ N per existing cap rules
