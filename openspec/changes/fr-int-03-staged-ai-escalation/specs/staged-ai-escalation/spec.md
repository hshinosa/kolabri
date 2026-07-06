## ADDED Requirements

### Requirement: The system shall apply staged AI intervention before lecturer escalation
The system SHALL attempt defined lower-stage AI interventions before escalating an unresolved issue to a lecturer.

#### Scenario: Initial issue triggers AI nudge
- **WHEN** the system detects a discussion issue that qualifies for intervention
- **THEN** the system enters the first escalation stage and delivers the configured AI nudge

#### Scenario: Unresolved issue advances to lecturer escalation
- **WHEN** an issue remains unresolved after configured lower-stage interventions complete or expire
- **THEN** the system transitions the issue to lecturer escalation and triggers lecturer notification

### Requirement: Escalation state must persist across repeated checks
The system SHALL store escalation state for an issue so follow-up processing can advance, resolve, or suppress duplicate alerts correctly.

#### Scenario: Repeated evaluation resumes from current stage
- **WHEN** the system reevaluates an unresolved issue that already has an active escalation state
- **THEN** the system continues from the stored stage instead of restarting the escalation flow

### Requirement: Lecturer escalation history shall be visible for follow-up
The system SHALL expose escalation stage history and current status to lecturer-facing monitoring views.

#### Scenario: Lecturer views escalation trail
- **WHEN** a lecturer opens the relevant monitoring or dashboard view
- **THEN** the system shows the issue's current escalation stage and prior intervention history
