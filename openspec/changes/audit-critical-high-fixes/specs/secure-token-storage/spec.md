## ADDED Requirements

### Requirement: JWT tokens MUST NOT be stored in browser localStorage

The authentication system SHALL remove JWT token storage from browser `localStorage` and rely on the existing Laravel BFF session (server-side storage protected by Laravel's httpOnly session cookie). For client-side operations that need the raw JWT (e.g., Socket.IO handshake), the frontend SHALL fetch it on-demand from the existing `/api/auth/token` endpoint.

#### Scenario: Successful login does NOT write token to localStorage
- **WHEN** user successfully authenticates with valid credentials
- **THEN** frontend does NOT call `localStorage.setItem('auth_token', ...)`
- **AND** JWT is stored server-side in Laravel session only
- **AND** response body does NOT include token in JSON payload visible to frontend JS

#### Scenario: Authenticated page requests use Laravel session
- **WHEN** authenticated user makes Inertia/page request to Client-App
- **THEN** Laravel session cookie is sent automatically
- **AND** `JwtAuthMiddleware` validates session and JWT expiry
- **AND** request proceeds with authenticated user context

#### Scenario: JavaScript cannot read JWT from localStorage
- **WHEN** malicious JavaScript runs in the browser
- **THEN** `localStorage.getItem('auth_token')` returns null
- **AND** XSS attack cannot steal authentication token from localStorage

#### Scenario: Token fetched on-demand for WebSocket only
- **WHEN** frontend initializes Socket.IO connection
- **THEN** frontend calls `/api/auth/token` to get a short-lived token reference
- **AND** token is passed via Socket.IO `auth` object (not URL query param)
- **AND** token is NOT persisted in browser storage

---

### Requirement: Backend MUST keep JWT in server-side session

The Client-App backend (Laravel) SHALL continue storing the JWT in server-side session (`session('jwt')`) and SHALL NOT expose it to frontend JavaScript through cookies, headers, or response bodies.

#### Scenario: Laravel session holds JWT
- **WHEN** user logs in via Client-App
- **THEN** Laravel stores JWT in `session('jwt')`
- **AND** session ID is transmitted via Laravel's httpOnly session cookie
- **AND** JWT itself is never sent to browser

#### Scenario: `/api/auth/token` returns token only for server-known contexts
- **WHEN** frontend requests `/api/auth/token` with valid session
- **THEN** endpoint returns token for immediate use (e.g., WebSocket handshake)
- **AND** response is not cached in browser storage

#### Scenario: Missing session returns 401
- **WHEN** request has no valid Laravel session
- **THEN** middleware rejects request with 401 Unauthorized
- **AND** page requests redirect to login, JSON requests return `{'message': 'Unauthenticated'}`

---

### Requirement: Frontend MUST NOT store tokens in localStorage

The Client-App frontend SHALL remove all localStorage token storage and rely on the BFF session for authenticated requests.

#### Scenario: Login removes localStorage token usage
- **WHEN** user logs in successfully
- **THEN** frontend does NOT call `localStorage.setItem('auth_token', ...)`
- **AND** authentication state is managed by session presence only

#### Scenario: API requests do NOT manually add Authorization header
- **WHEN** frontend makes authenticated API request to Client-App BFF
- **THEN** fetch/axios does NOT manually add `Authorization: Bearer` header
- **AND** Laravel session cookie is sent automatically
- **AND** `credentials: 'include'` is enabled for cross-origin requests to BFF

#### Scenario: Logout clears server-side session
- **WHEN** user logs out
- **THEN** frontend calls logout endpoint
- **AND** backend clears Laravel session (including `jwt`, `refresh_token`, `user`)
- **AND** frontend redirects to login page

---

### Requirement: Session configuration MUST prevent common attacks

Session and token handling SHALL follow security best practices to prevent XSS, CSRF, and man-in-the-middle attacks.

#### Scenario: Laravel session cookie is httpOnly
- **WHEN** Laravel session cookie is set
- **THEN** `httpOnly=true` flag is present
- **AND** `document.cookie` does NOT expose session ID value to JavaScript

#### Scenario: Session cookie uses Secure flag in production
- **WHEN** app runs in production
- **THEN** Laravel session cookie has `Secure=true` flag
- **AND** cookie only transmitted over HTTPS connections

#### Scenario: SameSite protection is configured
- **WHEN** Laravel session cookie is set
- **THEN** `SameSite` attribute is configured (Lax or Strict per environment)
- **AND** cookie NOT sent on cross-site requests from untrusted origins

#### Scenario: JWT expiry is enforced
- **WHEN** request reaches `JwtAuthMiddleware`
- **THEN** middleware decodes JWT payload and checks `exp` field
- **AND** expired sessions are cleared and user is redirected to login

---

### Requirement: WebSocket token transmission MUST be secure

Token used for Socket.IO/WebSocket handshake SHALL NOT be exposed in URL query parameters or browser storage.

#### Scenario: Socket.IO uses auth object
- **WHEN** frontend initializes Socket.IO connection
- **THEN** token is passed as `io(url, { auth: { token } })`
- **AND** token does NOT appear in URL or browser history

#### Scenario: Core-API reads token from handshake auth
- **WHEN** Core-API Socket.IO server receives connection
- **THEN** token is read from `socket.handshake.auth.token`
- **AND** token is NOT read from URL query parameters

#### Scenario: Token cache has TTL
- **WHEN** frontend caches token for WebSocket use
- **THEN** cache TTL is aligned with JWT expiry (e.g., 4 minutes for 15-minute JWT)
- **AND** cache is memory-only (not localStorage/sessionStorage)

---

### Requirement: Migration from localStorage MUST be seamless

The transition from localStorage to BFF session SHALL maintain user sessions without requiring re-authentication.

#### Scenario: Frontend removes localStorage writes immediately
- **WHEN** new frontend version deployed
- **THEN** no new tokens are written to localStorage
- **AND** existing Laravel sessions continue working

#### Scenario: Short read fallback for cached tokens
- **WHEN** user has token cached in localStorage from previous session
- **THEN** frontend may read it once during a 1-2 day transition window
- **AND** after transition window, localStorage reads are removed

#### Scenario: After migration window, localStorage is not used
- **WHEN** transition window completes
- **THEN** frontend has zero localStorage token usage
- **AND** monitoring confirms no `localStorage.getItem('auth_token')` calls
