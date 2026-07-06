## ADDED Requirements

### Requirement: Pre-read gate after session before goal

The system SHALL show a pre-read step after a chat space exists and before the student can create or submit a learning goal for that space. The pre-read MUST list materials allowed for the space's week per week-material-access rules.

#### Scenario: Redirect to pre-read

- **WHEN** student navigates to goal creation or chat for a space that has not completed pre-read
- **THEN** the system redirects or blocks until pre-read is shown

#### Scenario: Continue after pre-read

- **WHEN** student clicks "Lanjut" on pre-read
- **THEN** the system marks pre-read complete for that user and space and allows navigation to goal creation

#### Scenario: Order of flows

- **WHEN** student creates a new chat space with week selected
- **THEN** the next step MUST be pre-read, not goal creation or chat room directly

### Requirement: Pre-read completion is per user per chat space

The system SHALL record pre-read completion per authenticated user per chat space.

#### Scenario: New space requires pre-read again

- **WHEN** student completed pre-read for space A and opens space B for the first time
- **THEN** pre-read is required for space B before goal or chat
