## MODIFIED Requirements

### Requirement: AI Thread Summary
The chat room SHALL provide AI-powered summary of conversations.

#### Scenario: User requests summary
- **WHEN** user clicks "Ringkas percakapan" button
- **THEN** a summary card SHALL appear with AI-generated summary
- **AND** the summary SHALL cover key points from visible messages
- **AND** a loading indicator SHALL show while generating

#### Scenario: Summary already exists
- **WHEN** user requests summary and one already exists
- **THEN** the existing summary SHALL be displayed
- **AND** a "Refresh" button SHALL allow regeneration
