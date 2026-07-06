## MODIFIED Requirements

### Requirement: Lecturer assigns pool materials to weeks

The system SHALL keep course materials in a course-level pool (upload without mandatory week). Week and assignment data SHALL be authoritative in Laravel `course_materials` and week pivot tables. The lecturer MUST assign and unassign materials to course weeks and reorder materials within a week from the **unified Materi hub** only. The unassigned pool SHALL include any course material not linked to a week, **regardless of** `module_id`. The system MUST NOT require material modules as a prerequisite for upload or week assignment.

#### Scenario: Assign material to week

- **WHEN** lecturer assigns an existing pool material to week N from the Materi hub
- **THEN** the material appears in that week's list and is eligible for student access rules for week N and sessions capped at N

#### Scenario: Move material between weeks

- **WHEN** lecturer moves a material from week 2 to week 5
- **THEN** student access for session week 3 MUST NOT include that material until session week is ≥ 5

#### Scenario: Pool upload without module or week

- **WHEN** lecturer uploads a new file from the Materi hub without selecting a module or week
- **THEN** the material is stored and listed in the unassigned pool and is assignable to weeks
