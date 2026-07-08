## MODIFIED Requirements

### Requirement: Notification bell visibility
The system SHALL allow notification data and preferences to exist without requiring the bell-style notification entry point to be visible in the lecturer or student interface.

#### Scenario: Notification bell hidden temporarily
- **WHEN** a lecturer or student page includes the shared `NotificationsBell` component
- **THEN** the component renders no visible bell button
- **AND** no API contract or preferences payload is changed by this visibility rule
