## ADDED Requirements

### Requirement: Inline citation chips on AI scaffolding messages

AI scaffolding responses in group chat SHALL include inline citation chips adjacent to or within the answer text. Each chip MUST reference an allowed material (`week_index ≤ session week`) and open the document viewer modal when activated.

#### Scenario: Render citations

- **WHEN** an AI scaffolding message is delivered with citation metadata
- **THEN** the client renders one or more citation chips linked to `course_material_id` and optional page/section

### Requirement: Citations use canonical course material id

Citation metadata persisted and returned to the client MUST use `course_material_id` (Laravel `course_materials.id`) so the document viewer modal and week cap enforcement use the same identifier as the materials panel.

#### Scenario: Reject citations for future-week materials

- **WHEN** the model or engine proposes a citation to a material assigned only to a week greater than the session week
- **THEN** the system MUST NOT expose that citation in the message or chips shown to the student

#### Scenario: Accumulate cited sources in sidebar

- **WHEN** new AI messages cite materials in the allowed set
- **THEN** the system adds deduplicated entries to the "Dikutip dalam diskusi" section at the bottom of the sidebar without moving week material sections down in priority order

#### Scenario: Dedupe with week material lists

- **WHEN** a cited material is already listed in the session week N or earlier-week material sections
- **THEN** the system MUST NOT duplicate a second card in "Dikutip dalam diskusi" for the same material id (chips in message remain available)
