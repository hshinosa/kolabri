## ADDED Requirements

### Requirement: Chat sidebar shows week materials without separate recommendation section

The chat room right panel SHALL list (1) materials for session week N, (2) optional collapsible materials from earlier weeks ≤ N, and (3) "Dikutip dalam diskusi" for AI-cited sources in the current session. The panel MUST NOT include a separate "rekomendasi bacaan" section distinct from week material lists.

#### Scenario: Panel sections order

- **WHEN** student opens the chat sidebar
- **THEN** week N materials appear above earlier-week materials and the "Dikutip dalam diskusi" section appears below all week material blocks

#### Scenario: Replace placeholder resources

- **WHEN** chat room loads for a space with `week_id`
- **THEN** the system MUST NOT show hardcoded placeholder shared resources; it MUST load real week-scoped materials
