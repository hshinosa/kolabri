## ADDED Requirements

### Requirement: Draft text SHALL be persisted to localStorage on debounce

The system SHALL save the current message draft to localStorage with a 1s debounce after the last keystroke. The storage key SHALL be scoped per conversation (e.g., `draft:<conversationId>`).

#### Scenario: User types a message and pauses
- **WHEN** user types in the message input and stops for 1 second
- **THEN** the draft text is written to localStorage under the conversation-scoped key

#### Scenario: User types rapidly
- **WHEN** user types multiple characters within 1 second
- **THEN** only one localStorage write occurs, 1 second after the last keystroke

### Requirement: Draft SHALL be flushed on component unmount

The system SHALL flush any pending debounced draft save immediately when the message input component unmounts (e.g., user navigates away).

#### Scenario: User navigates away with unsent text
- **WHEN** user navigates to a different conversation or page with text in the input
- **THEN** the draft is saved to localStorage before the component unmounts

### Requirement: Draft SHALL be restored on component load

The system SHALL read the draft from localStorage when the message input component mounts and populate the input field with the saved text.

#### Scenario: User returns to a conversation with a saved draft
- **WHEN** user opens a conversation that has a saved draft in localStorage
- **THEN** the message input field is pre-filled with the saved draft text

#### Scenario: User opens a conversation with no saved draft
- **WHEN** user opens a conversation with no draft in localStorage
- **THEN** the message input field is empty

### Requirement: Draft SHALL be cleared on successful send

The system SHALL remove the draft from localStorage immediately after the message is successfully sent.

#### Scenario: User sends a message successfully
- **WHEN** the message send completes with a sent status
- **THEN** the draft for that conversation is removed from localStorage

### Requirement: Draft SHALL NOT be cleared on send failure

The system SHALL preserve the draft in localStorage if the message send fails, so the user does not lose their input.

#### Scenario: Message send fails
- **WHEN** the message send results in a failed status
- **THEN** the draft remains in localStorage for that conversation
