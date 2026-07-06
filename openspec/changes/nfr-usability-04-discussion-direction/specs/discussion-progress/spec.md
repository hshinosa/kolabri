## ADDED Requirements

### Requirement: Progress bar displays goal coverage percentage
The system SHALL display a progress bar in the chat space header that shows the percentage of messages classified as relevant to the session learning goal. The percentage SHALL be computed as (relevant message count / total message count) * 100.

#### Scenario: Discussion with relevant messages
- **WHEN** a chat space has 8 messages and 6 are classified as relevant
- **THEN** the progress bar shows 75%

#### Scenario: No messages yet
- **WHEN** a chat space has zero messages
- **THEN** the progress bar shows 0% with a neutral state

### Requirement: Progress updates in real time
The progress bar SHALL update whenever a new message is classified or an existing message's relevance changes.

#### Scenario: New message classified as relevant
- **WHEN** a new message is sent and classified as relevant
- **THEN** the progress bar percentage increases accordingly

#### Scenario: New message classified as off-topic
- **WHEN** a new message is sent and classified as off-topic
- **THEN** the progress bar percentage decreases accordingly

### Requirement: Progress bar requires an active learning goal
The progress bar SHALL only appear when the chat space has an active learning goal set. If no goal is set, the progress bar SHALL be hidden.

#### Scenario: Chat space with no goal
- **WHEN** a chat space has no learning goal
- **THEN** the progress bar is not displayed

#### Scenario: Goal set after discussion started
- **WHEN** a facilitator sets a learning goal on a chat space that already has messages
- **THEN** the progress bar appears and shows the percentage based on existing message classifications
