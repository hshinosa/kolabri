## ADDED Requirements

### Requirement: Knowledge base entries carry week metadata for session RAG

When course material is assigned to a course week, the system SHALL ensure corresponding knowledge base records used for retrieval include `week_index` and/or `week_id` for that assignment and SHALL link the KB row to the Laravel material via `course_material_id` when applicable. Reindex or update MUST run when assignment changes.

#### Scenario: KB links to course material

- **WHEN** a pool material is ingested or assigned to week N
- **THEN** the knowledge base entry used for retrieval includes `course_material_id` matching that material and `week_index` N

#### Scenario: Assign triggers metadata

- **WHEN** lecturer assigns a pool material to week N
- **THEN** indexed knowledge for that material reflects week N for retrieval filters

#### Scenario: Move between weeks updates metadata

- **WHEN** lecturer moves a material from week 2 to week 5
- **THEN** knowledge metadata is updated so week 3 sessions no longer retrieve it as week 2 content and week 5 sessions include it at week 5
