## MODIFIED Requirements

### Requirement: React key fix
The chat message list SHALL use unique keys for all list items.

#### Scenario: Message list renders
- **WHEN** chat room renders message list
- **THEN** each message element SHALL have a unique `key` prop
- **AND** no React "unique key" warnings SHALL appear in console

### Requirement: Optimistic message display
The chat room SHALL display sent messages immediately before server confirmation.

#### Scenario: User sends message
- **WHEN** user clicks "Kirim" with message text
- **THEN** the message SHALL appear in chat list immediately
- **AND** the message SHALL show a "sending" indicator
- **AND** after server confirms, the indicator SHALL change to "sent"
- **AND** the temporary ID SHALL be replaced with the server-assigned ID

### Requirement: Chat history load more
The chat room SHALL allow loading older messages.

#### Scenario: User scrolls to top of chat
- **WHEN** user scrolls to the first message
- **THEN** a "Load earlier messages" button SHALL appear
- **AND** clicking it SHALL load older messages
- **AND** scroll position SHALL be preserved after loading
- **AND** if no more messages, the button SHALL disappear

### Requirement: Typing indicator cleanup
The typing indicator SHALL reset on socket reconnection.

#### Scenario: Socket reconnects
- **WHEN** socket reconnects after disconnection
- **THEN** all stale typing indicators SHALL be cleared
- **AND** typing state SHALL reset to empty
