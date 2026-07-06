## ADDED Requirements

### Requirement: AI assistance shall adapt guidance depth by course offering / cohort semester band
The system SHALL vary AI guidance depth according to the course's semester or academic stage band (early vs late scaffolding for the cohort in that offering). Note: this is course-scoped (Course.semester + academicYear), not per-student.

#### Scenario: Early-cohort course receives guided support
- **WHEN** students in an early-semester / early-cohort course request AI help
- **THEN** the system responds using the guidance style configured for that semester/cohort band

#### Scenario: Late-cohort course receives less directive support
- **WHEN** students in a late-semester / late-cohort course request AI help
- **THEN** the system responds using the less directive, more source-oriented style configured for that semester/cohort band

### Requirement: Adaptive behavior must remain bounded by course policy
The system SHALL apply semester-based scaffolding only within the limits of active course AI policy (same surface as guardrails).

#### Scenario: Course policy constrains scaffolding
- **WHEN** a course config limits or disables specific scaffolding behavior (e.g. enabled=false or specific level)
- **THEN** the system applies the semester-based response strategy only within the configured course policy constraints

#### Scenario: "auto" level derives from course offering data
- **WHEN** scaffoldingLevel="auto"
- **THEN** the system maps Course.semester ("Ganjil" → early) + academicYear to the appropriate band and applies the corresponding guidance style

### Requirement: Adaptive response mode must be auditable
The system SHALL record which semester/cohort band policy shaped the response so behavior can be reviewed later.

#### Scenario: Semester policy attribution is recorded
- **WHEN** an adaptive AI response is generated
- **THEN** the system stores which semester/cohort band policy was applied to the interaction (in logs)
