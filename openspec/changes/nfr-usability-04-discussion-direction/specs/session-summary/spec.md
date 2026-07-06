## ADDED Requirements

### Requirement: Summary generated on session close
The system SHALL generate a structured summary when a facilitator closes a discussion session. The summary SHALL include: goalAchieved (boolean), topics (list of strings), contributions (map of member ID to contribution summary), and assessment (AI-generated paragraph).

#### Scenario: Session closed with goal achieved
- **WHEN** a facilitator closes a session where the relevance percentage is above 70%
- **THEN** the summary shows goalAchieved=true, lists covered topics, shows each member's contribution count, and includes an AI assessment paragraph

#### Scenario: Session closed with goal not achieved
- **WHEN** a facilitator closes a session where the relevance percentage is below 70%
- **THEN** the summary shows goalAchieved=false, lists topics that were covered, and the AI assessment notes what was missing

#### Scenario: Session with no messages
- **WHEN** a facilitator closes a session that has zero messages
- **THEN** the summary shows goalAchieved=false, empty topics, empty contributions, and assessment states "Tidak ada pesan dalam diskusi"

### Requirement: Summary displayed in a modal
The session summary SHALL be displayed in a modal dialog that appears when the session is closed. The modal MUST be dismissible by the facilitator.

#### Scenario: Modal appears on close
- **WHEN** a facilitator closes a session
- **THEN** a modal appears showing the full structured summary

#### Scenario: Facilitator dismisses modal
- **WHEN** the facilitator clicks the close button on the summary modal
- **THEN** the modal closes and the chat space shows the session as ended

### Requirement: Summary persisted
The session summary SHALL be stored and retrievable after the session ends. Participants SHALL be able to view the summary of any closed session they were part of.

#### Scenario: Viewing past session summary
- **WHEN** a participant opens a closed session
- **THEN** the summary is available for viewing via a "Lihat Ringkasan" button
