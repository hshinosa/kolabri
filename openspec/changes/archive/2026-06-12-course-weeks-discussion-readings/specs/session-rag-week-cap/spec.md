## ADDED Requirements

### Requirement: Student session chat RAG capped at session week

Retrieval for AI answers in a student group chat space with session week N MUST use only knowledge chunks from materials with `week_index ≤ N`. Chunks from weeks greater than N MUST NOT be retrieved for that chat context.

#### Scenario: No future week retrieval

- **WHEN** student asks AI in a week 2 session
- **THEN** retrieval MUST NOT return chunks indexed only for week 3 or later

### Requirement: RAG prioritizes current week with score exception for older weeks

Retrieval MUST rank chunks from week N highest by default. Chunks from weeks 1…N−1 MAY be included only when their relevance score exceeds the best-scoring candidate from week N according to configured threshold logic.

#### Scenario: Prefer session week chunk

- **WHEN** similar content exists in week N and week 1 with comparable scores
- **THEN** week N chunk is preferred in the context assembly passed to the model

### Requirement: RAG uses knowledge metadata from week assignment

Session chat retrieval MUST filter using `week_index` (or equivalent) stored on knowledge base records when materials are assigned to weeks, as defined in knowledge-week-metadata.

#### Scenario: Filter uses indexed week

- **WHEN** group chat AI retrieval runs for session week 3
- **THEN** only chunks with `week_index ≤ 3` in knowledge metadata are eligible
