## MODIFIED Requirements

### Requirement: Course AI settings must expose semester-adaptive scaffolding controls
The system SHALL expose course-level AI policy controls with lecturer-facing copy that explains the pedagogical effect of each option.

#### Scenario: Lecturer views current course AI policy settings
- **WHEN** a lecturer opens course settings for AI policy management
- **THEN** the system shows the currently active guardrail and scaffolding configuration for that course
- **AND** visible labels use formal Bahasa Indonesia that describe teaching-policy intent rather than internal AI terminology

#### Scenario: Lecturer reads guardrail rewrite policy
- **WHEN** a lecturer views the guardrail rewrite toggle
- **THEN** the system labels the control as allowing the AI to adjust responses into a safe form
- **AND** helper text explains that the AI will provide guidance, steps, or concept summaries instead of direct answers when needed

#### Scenario: Lecturer reads light-violation handling policy
- **WHEN** a lecturer views the flag-only toggle
- **THEN** the system labels the control as warning without blocking for ringan violations
- **AND** helper text explains that the interaction remains visible but is marked for attention

#### Scenario: Lecturer disables adaptive scaffolding
- **WHEN** a lecturer turns off adaptive scaffolding for the course
- **THEN** the system hides the scaffolding level selector
- **AND** the last selected scaffolding level remains preserved for later reuse

#### Scenario: Lecturer enables adaptive scaffolding
- **WHEN** a lecturer turns on adaptive scaffolding for the course
- **THEN** the system shows the scaffolding level selector
- **AND** the selector options are presented in formal Bahasa Indonesia describing the depth of guidance
