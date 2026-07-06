## ADDED Requirements

### Requirement: Pool material upload queues knowledge-base via internal API

When a lecturer uploads a course material through the unified Materi hub (Laravel store), the system SHALL call internal core-api to create or update a knowledge-base row linked by `course_material_id`, set queued processing state, and trigger ingest without requiring `week_id` at upload time.

#### Scenario: Upload queues KB

- **WHEN** lecturer upload succeeds and internal secret is configured
- **THEN** a knowledge-base row exists for that `course_material_id` with non-terminal vector status until ingest completes

#### Scenario: Upload without internal secret

- **WHEN** lecturer upload succeeds but internal secret is not configured
- **THEN** the material is stored for students and week assignment and the UI indicates AI indexing is unavailable due to configuration

### Requirement: Knowledge-base list exposes course material link

Knowledge-base list responses used by the lecturer BFF SHALL include `course_material_id` for each row where the link exists, so the Materi hub can join status to material rows.

#### Scenario: BFF includes link id

- **WHEN** lecturer client requests course knowledge-base list
- **THEN** each applicable row includes `course_material_id` for UI join

## MODIFIED Requirements

### Requirement: Knowledge base entries carry week metadata for session RAG

When course material is assigned to a course week, the system SHALL ensure corresponding knowledge-base records include `week_index` and/or `week_id` and `course_material_id`. Reindex or update MUST run when assignment changes. Pool upload MAY create KB rows with null week fields until assignment; assign MUST set week metadata via the existing link flow.

#### Scenario: KB links to course material

- **WHEN** a pool material is queued or assigned to week N
- **THEN** the knowledge-base entry includes `course_material_id` matching that material and `week_index` N when assigned to week N

#### Scenario: Assign triggers metadata

- **WHEN** lecturer assigns a pool material to week N
- **THEN** indexed knowledge for that material reflects week N for retrieval filters

#### Scenario: Move between weeks updates metadata

- **WHEN** lecturer moves a material from week 2 to week 5
- **THEN** knowledge metadata is updated so week 3 sessions no longer retrieve it as week 2 content and week 5 sessions include it at week 5
