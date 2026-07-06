## ADDED Requirements

### Requirement: Per-message relevance badge
The system SHALL display a badge on each message indicating whether it is "Relevan" (relevant) or "Off-topic" relative to the session learning goal. The badge SHALL be a colored dot next to the message timestamp with a tooltip showing the label.

#### Scenario: Relevant message
- **WHEN** a message is classified as relevant to the session goal
- **THEN** a green dot appears next to the message timestamp with tooltip "Relevan"

#### Scenario: Off-topic message
- **WHEN** a message is classified as off-topic relative to the session goal
- **THEN** a red dot appears next to the message timestamp with tooltip "Off-topic"

#### Scenario: Pending classification
- **WHEN** a message has been sent but not yet classified
- **THEN** a gray dot appears next to the message timestamp with tooltip "Menunggu..."

#### Scenario: Classification failure
- **WHEN** the AI classification call fails for a message
- **THEN** the message defaults to "Relevan" and shows a green dot

### Requirement: Aggregate relevance count in chat header
The system SHALL display a summary count of relevant vs. off-topic messages in the chat space header.

#### Scenario: Summary display
- **WHEN** a chat space has 10 messages with 7 relevant and 3 off-topic
- **THEN** the header shows "7 Relevan, 3 Off-topic"

#### Scenario: No goal set
- **WHEN** the chat space has no learning goal
- **THEN** no aggregate count is displayed

### Requirement: Badge only shown when goal is active
The per-message badge SHALL only appear when the chat space has an active learning goal. Messages in a goal-less chat space SHALL NOT display any relevance badge.

#### Scenario: Chat space without goal
- **WHEN** a chat space has no learning goal
- **THEN** messages display no relevance dot or tooltip
