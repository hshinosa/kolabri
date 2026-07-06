## MODIFIED Requirements

### Requirement: All controller methods MUST use try-catch blocks

The system SHALL wrap all controller logic in try-catch blocks to handle unexpected errors gracefully. Unhandled exceptions SHALL NOT propagate to the client as 500 errors without context. The system SHALL also handle offline and retry states as recoverable conditions rather than terminal errors.

#### Scenario: Database error caught and logged
- **WHEN** database operation fails
- **THEN** error is caught, logged with context, and user receives appropriate error response

#### Scenario: Service error caught and transformed
- **WHEN** external service call fails
- **THEN** error is caught, transformed to user-friendly message, and returned with appropriate status code

#### Scenario: Send failure triggers auto-retry instead of immediate error
- **WHEN** message send fails due to transient network error
- **THEN** the system auto-retries with backoff before showing a terminal error

#### Scenario: Offline state shown as recoverable
- **WHEN** the socket is disconnected
- **THEN** the UI shows a "reconnecting" indicator rather than an error state
