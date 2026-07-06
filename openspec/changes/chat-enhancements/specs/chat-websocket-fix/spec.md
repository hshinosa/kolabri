## MODIFIED Requirements

### Requirement: WebSocket transport enabled with fallback
The chat room SHALL use WebSocket transport for real-time messaging with automatic fallback to polling.

#### Scenario: WebSocket connects successfully
- **WHEN** user opens chat room
- **AND** WebSocket upgrade succeeds
- **THEN** socket.io SHALL use WebSocket transport
- **AND** messages SHALL be delivered in real-time

#### Scenario: WebSocket upgrade fails
- **WHEN** WebSocket upgrade fails (e.g., "Invalid frame header")
- **THEN** socket.io SHALL fall back to polling transport
- **AND** chat room SHALL continue to function
- **AND** a console warning SHALL be logged (not error)

#### Scenario: Transport reconnection
- **WHEN** active transport disconnects
- **THEN** socket.io SHALL attempt reconnection with exponential backoff
- **AND** reconnection status SHALL be visible to user
