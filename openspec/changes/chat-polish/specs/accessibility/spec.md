## MODIFIED Requirements

### Requirement: Keyboard Navigation
The chat room SHALL be fully navigable via keyboard.

#### Scenario: Tab navigation
- **WHEN** user presses Tab
- **THEN** focus SHALL move through interactive elements in logical order
- **AND** focus indicator SHALL be visible

#### Scenario: Escape to close
- **WHEN** user presses Escape while modal/dropdown is open
- **THEN** the modal/dropdown SHALL close
- **AND** focus SHALL return to trigger element

### Requirement: Screen Reader Support
The chat room SHALL provide proper ARIA labels.

#### Scenario: Message list
- **WHEN** screen reader encounters message list
- **THEN** it SHALL announce "Chat messages, N messages"
- **AND** each message SHALL have proper role and label

#### Scenario: Send button
- **WHEN** screen reader encounters send button
- **THEN** it SHALL announce "Kirim pesan"

### Requirement: Focus Management
Focus SHALL be managed correctly for dynamic content.

#### Scenario: New message arrives
- **WHEN** new message arrives and user is at bottom
- **THEN** focus SHALL NOT move to new message
- **AND** screen reader MAY announce new message

#### Scenario: Modal opens
- **WHEN** modal opens
- **THEN** focus SHALL move to first focusable element in modal
