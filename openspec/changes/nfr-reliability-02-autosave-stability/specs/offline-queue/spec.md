## ADDED Requirements

### Requirement: Messages SHALL be queued in IndexedDB when offline

The system SHALL intercept outgoing messages when the socket is disconnected and store them in an IndexedDB outbox. Each queued message SHALL include the conversation ID, message content, clientId, and timestamp.

#### Scenario: User sends a message while offline
- **WHEN** user sends a message and the socket is disconnected
- **THEN** the message is stored in the IndexedDB outbox with status "pending"
- **AND** the message appears in the UI with a "pending" indicator

#### Scenario: Multiple messages sent while offline
- **WHEN** user sends multiple messages while offline
- **THEN** all messages are queued in the outbox in chronological order

### Requirement: Outbox SHALL be flushed on reconnect

The system SHALL flush all pending messages from the IndexedDB outbox when the socket reconnects. Messages SHALL be sent in chronological order.

#### Scenario: Socket reconnects with pending messages
- **WHEN** the socket reconnects and the outbox contains pending messages
- **THEN** all pending messages are sent in chronological order
- **AND** each message status is updated from "pending" to "sending" then "sent" or "failed"

#### Scenario: Outbox flush partially fails
- **WHEN** some messages fail during outbox flush
- **THEN** successfully sent messages are removed from the outbox
- **AND** failed messages remain in the outbox for retry on next reconnect

### Requirement: Outbox SHALL be cleared of sent messages

The system SHALL remove messages from the IndexedDB outbox after they are confirmed sent by the server.

#### Scenario: Message confirmed sent after flush
- **WHEN** a queued message receives a sent confirmation from the server
- **THEN** the message is removed from the IndexedDB outbox

### Requirement: Outbox SHALL persist across page reloads

The IndexedDB outbox SHALL survive page reloads and browser restarts. Pending messages SHALL be flushed on the next successful reconnect.

#### Scenario: User reloads page with pending outbox messages
- **WHEN** user reloads the page and the outbox contains pending messages
- **THEN** the pending messages are still in the outbox after reload
- **AND** they are flushed when the socket reconnects
