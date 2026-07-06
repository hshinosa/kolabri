## ADDED Requirements

### Requirement: Socket.io reconnect with refreshed token
The system SHALL automatically refresh the JWT token before attempting to reconnect Socket.io after an authentication error.

#### Scenario: Socket auth error triggers token refresh
- **WHEN** Socket.io connection fails with authentication error (unauthorized, expired, token, auth)
- **THEN** frontend SHALL call `GET /api/auth/refresh-token` to refresh the token
- **AND** frontend SHALL update the socket auth with the new token
- **AND** frontend SHALL attempt to reconnect Socket.io

#### Scenario: Refresh fails during socket reconnect
- **WHEN** Socket.io auth error occurs
- **AND** `GET /api/auth/refresh-token` returns 401 (session expired)
- **THEN** frontend SHALL set connection error "Session expired. Please refresh the page."
- **AND** frontend SHALL NOT attempt further reconnection

#### Scenario: Socket reconnect succeeds after refresh
- **WHEN** Socket.io reconnects with refreshed token
- **AND** server accepts the connection
- **THEN** frontend SHALL emit `join_room` event
- **AND** frontend SHALL set `isConnected` to true

### Requirement: Frontend token fetch handles expired session
The system SHALL handle 401 responses from `/api/auth/token` gracefully by redirecting to login.

#### Scenario: Token endpoint returns 401
- **WHEN** frontend calls `GET /api/auth/token`
- **AND** Laravel returns 401 (session expired)
- **THEN** frontend SHALL redirect to `/login` page

#### Scenario: Token endpoint returns valid token
- **WHEN** frontend calls `GET /api/auth/token`
- **AND** Laravel returns 200 with token
- **THEN** frontend SHALL cache the token for 4 minutes
- **AND** return the token for use

### Requirement: Single refresh attempt per socket session
The system SHALL attempt token refresh only once per socket connection lifecycle to prevent infinite refresh loops.

#### Scenario: Multiple auth errors in sequence
- **WHEN** Socket.io auth error occurs
- **AND** token refresh is attempted
- **AND** reconnect still fails with auth error
- **THEN** frontend SHALL NOT attempt another refresh
- **AND** frontend SHALL set connection error message
