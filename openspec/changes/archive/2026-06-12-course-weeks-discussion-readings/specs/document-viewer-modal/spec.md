## ADDED Requirements

### Requirement: Single in-app document viewer modal

The system SHALL open course materials and citation targets in one shared in-app modal viewer from the chat room and pre-read flows. The default action MUST NOT open a new browser tab.

#### Scenario: Open from citation chip

- **WHEN** student clicks an inline citation chip on an AI message
- **THEN** the document viewer modal opens for that material within week access cap

#### Scenario: Open from materials panel

- **WHEN** student clicks a material in the week materials panel or pre-read list
- **THEN** the same document viewer modal opens for that file
