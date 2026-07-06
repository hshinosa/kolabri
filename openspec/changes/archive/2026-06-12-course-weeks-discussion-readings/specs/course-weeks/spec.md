## ADDED Requirements

### Requirement: Lecturer manages course weeks with title only

The system SHALL allow a lecturer to create, update, reorder, and delete course weeks for a course. Each week MUST have `week_index` (positive integer, unique per course) and `title`. The system MUST NOT require a separate long description field for a week.

#### Scenario: Create week

- **WHEN** lecturer submits a new week with `week_index` and `title` for a course they own
- **THEN** the system persists the week and returns it in the course weeks list

#### Scenario: Delete week

- **WHEN** lecturer deletes a week that has assigned materials
- **THEN** the system removes week-material links and MUST NOT delete pool materials unless explicitly requested by a separate delete-material action

### Requirement: Lecturer assigns pool materials to weeks

The system SHALL keep course materials in a course-level pool (upload without mandatory week). Week and assignment data SHALL be authoritative in the Laravel materials store (existing `course_materials` / modules evolution). The lecturer MUST be able to assign and unassign pool materials to any course week and reorder materials within a week.

#### Scenario: Assign material to week

- **WHEN** lecturer assigns an existing pool material to week N
- **THEN** the material appears in that week's list and is eligible for student access rules for week N and later sessions capped at N

#### Scenario: Move material between weeks

- **WHEN** lecturer moves a material from week 2 to week 5
- **THEN** student access for session week 3 MUST NOT include that material until session week is ≥ 5
