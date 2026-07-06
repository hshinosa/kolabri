# session-week-binding Specification

## Purpose
TBD - created by archiving change course-weeks-discussion-readings. Update Purpose after archive.
## Requirements
### Requirement: Chat space bound to course week

The system SHALL require each student discussion chat space to reference exactly one `week_id` for the course. Multiple chat spaces MAY share the same `week_id` (many sessions per week).

#### Scenario: Create session with week

- **WHEN** student or lecturer creates a new chat space for a course group
- **THEN** the system requires selection of a course week and stores `week_id` on the chat space

#### Scenario: Display week context

- **WHEN** student views chat space list, pre-read, goal creation, or chat room for a space
- **THEN** the UI MUST show the week title (and week index) for that space's `week_id`
