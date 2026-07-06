## ADDED Requirements

### Requirement: Citations persisted from AI engine to MongoDB

When the AI engine returns citations in the orchestration response, the core-api socket handler SHALL persist those citations to the MongoDB ChatLog document before emitting the message to the client. The `citations` field SHALL contain the complete array of citation objects returned by the AI engine, preserving all metadata fields including `course_material_id`, `source`, `page`, and any additional context.

The system SHALL NOT silently drop citations due to serialization issues, type mismatches, or empty array handling. If the AI engine returns citations (`citations.length > 0`), those citations MUST appear in the MongoDB document.

#### Scenario: AI engine returns citations, MongoDB persists them

- **WHEN** AI engine orchestration response includes `citations` array with one or more citation objects
- **THEN** the MongoDB ChatLog document SHALL have a `citations` field containing the same array with all objects and metadata preserved

#### Scenario: Citations flow through to client

- **WHEN** MongoDB ChatLog document has a `citations` field with citation objects
- **THEN** the socket.io `receive_message` event emitted to the client SHALL include the `citations` field with the same data

#### Scenario: Empty citations handled correctly

- **WHEN** AI engine returns empty citations array (`citations: []`)
- **THEN** the MongoDB ChatLog document SHALL either omit the `citations` field OR store an empty array, but SHALL NOT store `undefined` or `null` that would cause client errors

#### Scenario: RAG retrieval success correlates with citation presence

- **WHEN** AI engine logs indicate successful RAG retrieval with `num_sources > 0`
- **THEN** the MongoDB ChatLog document for that AI response SHALL have a non-empty `citations` field

#### Scenario: Citation count matches between layers

- **WHEN** AI engine logs `rag_citations_extracted num_citations=N` where N > 0
- **THEN** the MongoDB ChatLog document SHALL have `citations` array with length N
- **AND** the socket.io event SHALL emit the same N citations to the client

## Context

This requirement addresses a production bug where citations were being created by the AI engine's RAG system (verified with logging showing `num_citations=1`) but were not appearing in MongoDB ChatLog documents (verified with direct query). Investigation revealed the data flow from AI engine → core-api → MongoDB was broken, preventing the citation chips UI from displaying source references.

The root cause was narrowed to the core-api socket handler between receiving the HTTP response and saving to MongoDB. This spec makes the persistence layer explicit and testable to prevent regression.
