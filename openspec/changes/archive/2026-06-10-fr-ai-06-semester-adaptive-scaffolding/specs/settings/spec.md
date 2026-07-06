## ADDED Requirements

### Requirement: Course AI settings must expose semester-adaptive scaffolding controls
The system SHALL expose relevant course-level settings that define or constrain semester-adaptive scaffolding behavior (parallel to ai_guardrail_* controls).

#### Scenario: Lecturer views semester-adaptive policy settings
- **WHEN** a lecturer opens the relevant course AI settings
- **THEN** the system shows the active semester-adaptive scaffolding configuration or policy constraints (e.g. scaffoldingLevel "early"|"late"|"auto", enabled toggle) for that course

#### Scenario: Lecturer overrides band for a course
- **WHEN** a lecturer sets scaffoldingLevel to "early" (or "late") with enabled=true
- **THEN** all AI interactions in that course use the corresponding guidance depth, regardless of the course's semester value

**Note (adjusted):** Settings are course-scoped. No per-student semester configuration. Config stored as `aiScaffoldingConfig` JSONB (shape: `{scaffoldingLevel, enabled}`). "auto" derives from Course.semester + academicYear.
