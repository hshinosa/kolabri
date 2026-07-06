## ADDED Requirements

### Requirement: Failed sends SHALL auto-retry with exponential backoff

The system SHALL automatically retry failed message sends up to 3 times with exponential backoff. The delay sequence SHALL be approximately 1s, 2s, 4s with random jitter of up to 500ms added to each delay.

#### Scenario: First send failure triggers auto-retry
- **WHEN** a message send fails
- **THEN** the system automatically retries after approximately 1s + jitter

#### Scenario: Second failure triggers second retry
- **WHEN** the first retry fails
- **THEN** the system automatically retries after approximately 2s + jitter

#### Scenario: Third failure triggers final retry
- **WHEN** the second retry fails
- **THEN** the system automatically retries after approximately 4s + jitter

#### Scenario: All retries exhausted
- **WHEN** all 3 retries have been exhausted and the message still fails
- **THEN** the message status is set to "failed"
- **AND** the "Coba lagi" button is shown for manual retry

### Requirement: Auto-retry SHALL show status indicator

The system SHALL display a subtle "retrying..." indicator during auto-retry so the user knows the system is attempting recovery.

#### Scenario: Auto-retry in progress
- **WHEN** a message is being auto-retried
- **THEN** the message shows a "retrying..." status indicator

### Requirement: Manual retry SHALL reset the retry counter

The system SHALL reset the retry counter when the user manually retries via the "Coba lagi" button, allowing another 3 auto-retry attempts.

#### Scenario: User clicks manual retry after exhausted auto-retries
- **WHEN** user clicks "Coba lagi" after auto-retries are exhausted
- **THEN** the retry counter resets and 3 more auto-retry attempts begin
