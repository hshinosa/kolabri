## ADDED Requirements

### Requirement: Health score computation
The system SHALL compute a discussion health score from 0 to 100 for each chat space using the formula: Health = 0.4 * relevanceRatio + 0.3 * participationBalance + 0.3 * goalProgress, where relevanceRatio is the percentage of relevant messages, participationBalance is Shannon entropy of message distribution normalized to 0-1, and goalProgress is the facilitator's manual assessment if set, otherwise relevanceRatio.

#### Scenario: Balanced, on-topic discussion
- **WHEN** a chat space has 80% relevant messages, even participation (entropy=0.95), and no manual assessment (goalProgress=relevanceRatio=0.8)
- **THEN** health score = 0.4*80 + 0.3*95 + 0.3*80 = 84.5, rounded to 85

#### Scenario: One-person discussion
- **WHEN** a chat space has 100% relevant messages but one member sent all messages (entropy=0.0)
- **THEN** health score = 0.4*100 + 0.3*0 + 0.3*100 = 70

#### Scenario: No messages
- **WHEN** a chat space has zero messages
- **THEN** health score is 0

### Requirement: Health score color coding
The health score SHALL be color coded: green (70-100), yellow (40-69), red (0-39).

#### Scenario: Healthy discussion
- **WHEN** health score is 85
- **THEN** the score displays with a green indicator

#### Scenario: At-risk discussion
- **WHEN** health score is 55
- **THEN** the score displays with a yellow indicator

#### Scenario: Unhealthy discussion
- **WHEN** health score is 25
- **THEN** the score displays with a red indicator

### Requirement: Health score visible in chat space
The health score SHALL be displayed as a card widget in the chat space header area, showing the numeric score and color indicator.

#### Scenario: Viewing health in chat
- **WHEN** a user opens a chat space with an active learning goal
- **THEN** the health score card is visible in the header with the current score and color

#### Scenario: No goal set
- **WHEN** a chat space has no learning goal
- **THEN** the health score card is not displayed

### Requirement: Health score updates in real time
The health score SHALL recalculate whenever a new message is classified or a member sends a message.

#### Scenario: New message changes health
- **WHEN** a new off-topic message is sent in a previously all-relevant discussion
- **THEN** the health score decreases and the color may change
