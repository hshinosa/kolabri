## MODIFIED Requirements

### Requirement: Server error display
The system SHALL display server errors to the user via toast notifications.

#### Scenario: Server emits server_error event
- **WHEN** server emits `server_error` event with a message
- **THEN** a toast notification SHALL appear with the error message
- **AND** the toast SHALL auto-dismiss after 5 seconds
- **AND** the toast SHALL be dismissible by clicking

#### Scenario: Message send failure
- **WHEN** user sends a message and server returns error
- **THEN** the message bubble SHALL show a "failed" indicator (red icon)
- **AND** a retry button SHALL appear on the failed message
- **AND** clicking retry SHALL attempt to resend the message

### Requirement: Connection status visibility
The system SHALL show connection status to the user.

#### Scenario: Socket reconnecting
- **WHEN** socket is in reconnecting state
- **THEN** a banner "Menyambungkan kembali..." SHALL appear above chat messages
- **AND** the banner SHALL auto-dismiss when connected

#### Scenario: Connection permanently failed
- **WHEN** socket fails to reconnect after max attempts
- **THEN** a banner "Koneksi terputus. Refresh halaman." SHALL appear
- **AND** a refresh button SHALL be available
