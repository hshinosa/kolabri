## ADDED Requirements

### Requirement: Automatic HTTP token refresh on 401
The system SHALL automatically refresh the JWT access token when the Core API returns 401 Unauthorized, without requiring user interaction.

#### Scenario: Token expired during normal API call
- **WHEN** user makes a request to Core API and receives 401 Unauthorized response
- **AND** valid refresh token exists in Laravel session
- **THEN** Laravel SHALL call Core API `/api/auth/refresh` with the refresh token
- **AND** store the new access token in session
- **AND** retry the original request with the new access token
- **AND** return the successful response to the user

#### Scenario: Refresh token also expired
- **WHEN** user makes a request to Core API and receives 401 Unauthorized
- **AND** refresh token is also expired or invalid
- **THEN** Laravel SHALL clear the session (jwt, refresh_token, user)
- **AND** return 401 to the frontend
- **AND** frontend SHALL redirect to login page

#### Scenario: Refresh token revoked
- **WHEN** Laravel calls Core API `/api/auth/refresh` with a revoked refresh token
- **AND** Core API returns 401
- **THEN** Laravel SHALL clear the session
- **AND** return 401 to the frontend

### Requirement: Explicit token refresh endpoint
The system SHALL provide a Laravel endpoint that frontend can call to explicitly refresh the JWT token.

#### Scenario: Frontend requests token refresh
- **WHEN** frontend calls `GET /api/auth/refresh-token`
- **AND** valid refresh token exists in session
- **THEN** Laravel SHALL call Core API `/api/auth/refresh` with the refresh token
- **AND** store the new access token in session
- **AND** return the new token in response

#### Scenario: No refresh token in session
- **WHEN** frontend calls `GET /api/auth/refresh-token`
- **AND** no refresh token exists in session
- **THEN** Laravel SHALL return 401 with error "No refresh token"

### Requirement: JwtAuthMiddleware graceful expiry handling
The system SHALL NOT immediately destroy the session when JWT expires. Instead, it SHALL allow the request to proceed so that TokenRefreshMiddleware can attempt recovery.

#### Scenario: JWT expired but refresh token valid
- **WHEN** JwtAuthMiddleware detects expired JWT
- **AND** refresh token exists in session
- **THEN** JwtAuthMiddleware SHALL allow the request to proceed
- **AND** TokenRefreshMiddleware SHALL attempt refresh

#### Scenario: JWT expired and no refresh token
- **WHEN** JwtAuthMiddleware detects expired JWT
- **AND** no refresh token exists in session
- **THEN** JwtAuthMiddleware SHALL clear session and redirect to login
