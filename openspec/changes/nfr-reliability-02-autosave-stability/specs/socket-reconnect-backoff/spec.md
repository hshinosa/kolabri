## ADDED Requirements

### Requirement: Socket reconnection SHALL use exponential backoff with infinite attempts

The system SHALL attempt socket reconnection indefinitely with exponential backoff. The base delay SHALL be 1s, doubling each attempt, capped at 30s maximum. Random jitter of up to 1s SHALL be added to each delay.

#### Scenario: First reconnection attempt
- **WHEN** socket disconnects
- **THEN** the system attempts reconnection after approximately 1s + jitter

#### Scenario: Subsequent reconnection attempts
- **WHEN** a reconnection attempt fails
- **THEN** the next attempt occurs after approximately min(1s * 2^attempt, 30s) + jitter

#### Scenario: Reconnection succeeds
- **WHEN** a reconnection attempt succeeds
- **THEN** the backoff counter resets to the base delay

### Requirement: Socket reconnection SHALL pause when tab is hidden

The system SHALL pause reconnection attempts when the browser tab is hidden (document.hidden) and resume when the tab becomes visible again.

#### Scenario: Tab hidden during reconnection
- **WHEN** the browser tab becomes hidden while reconnection is in progress
- **THEN** reconnection attempts pause

#### Scenario: Tab becomes visible
- **WHEN** the browser tab becomes visible again
- **THEN** reconnection attempts resume immediately

### Requirement: Socket reconnection state SHALL be observable

The system SHALL expose the current reconnection state (connected, reconnecting, disconnected) so the UI can reflect connection status to the user.

#### Scenario: UI shows reconnecting state
- **WHEN** socket is disconnected and reconnection attempts are in progress
- **THEN** the UI displays a "reconnecting" indicator

#### Scenario: UI shows connected state
- **WHEN** socket connection is established
- **THEN** the UI displays a "connected" indicator
