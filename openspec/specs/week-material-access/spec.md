# week-material-access Specification

## Purpose
TBD - created by archiving change course-weeks-discussion-readings. Update Purpose after archive.
## Requirements
### Requirement: Progressive material cap by session week

For a chat space with session week index N, the system SHALL allow access only to materials assigned to course weeks where `week_index ≤ N`. Materials assigned to weeks with `week_index > N` MUST NOT be viewable or downloadable.

#### Scenario: Deny future week material

- **WHEN** student requests view or download for a material assigned only to week N+1 while their chat space is week N
- **THEN** the system returns forbidden or not found and does not serve the file

#### Scenario: Allow cumulative access

- **WHEN** student session is week 4
- **THEN** the system allows materials assigned to weeks 1, 2, 3, and 4

### Requirement: UI prioritizes current week materials

The system SHALL present week N materials as the primary list and week 1…N−1 as secondary (collapsible) where the UI lists materials for a session.

#### Scenario: Pre-read and panel ordering

- **WHEN** student opens pre-read or chat materials panel for week N
- **THEN** week N materials are shown first and earlier weeks are shown in a collapsible section below the primary list
