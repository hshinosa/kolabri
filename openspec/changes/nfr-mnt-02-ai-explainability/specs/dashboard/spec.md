## MODIFIED Requirements

### Requirement: Lecturer can monitor session activity
The lecturer dashboard SHALL display escalation reasons alongside session monitoring data. When a session has an escalation with a recorded reason, the reason SHALL be visible in the session list and detail views.

#### Scenario: Session with escalation reason
- **WHEN** a lecturer views the session monitoring dashboard and a session has an escalation with interventionReason "student repeatedly off-topic"
- **THEN** the dashboard SHALL display "student repeatedly off-topic" in the escalation reason column

#### Scenario: Session with no escalation
- **WHEN** a lecturer views the session monitoring dashboard and a session has no escalation
- **THEN** the escalation reason column SHALL be empty or show "None"

#### Scenario: Session detail view
- **WHEN** a lecturer opens a session detail view
- **THEN** each AI message in the session SHALL display its intervention type and reason if present
