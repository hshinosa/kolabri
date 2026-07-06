## ADDED Requirements

### Requirement: Client-App timeout MUST align with server processing times

Client-App (Laravel BFF + React frontend) SHALL use timeout values that account for Core-API processing durations to prevent race conditions.

#### Scenario: Laravel BFF uses centralized timeout helper
- **WHEN** Client-App backend calls Core-API
- **THEN** `Controller::apiRequest()` helper applies timeout=10s and connectTimeout=5s by default
- **AND** per-operation overrides are supported (batch=120s, ai=60s, health=5s)
- **AND** `AuthController` login/register/logout use the helper (currently bypass it)

#### Scenario: React frontend default timeout increased to 30 seconds
- **WHEN** Client-App frontend makes standard API request to BFF
- **THEN** axios timeout is 30_000ms (was 10_000ms)
- **AND** sufficient for BFF + Core-API standard operations

#### Scenario: Batch operations use extended timeout
- **WHEN** Client-App makes batch file upload request
- **THEN** request-specific timeout is 120_000ms on both frontend and backend
- **AND** accounts for processing multiple files

#### Scenario: AI Engine calls use appropriate timeout
- **WHEN** Client-App or Core-API calls AI Engine
- **THEN** timeout is 60_000ms
- **AND** accounts for AI model inference time

#### Scenario: Timeout matrix is documented
- **WHEN** reviewing timeout configuration
- **THEN** `docs/TIMEOUTS.md` (or README) documents all timeout values
- **AND** includes matrix for React frontend and Laravel backend
- **AND** future developers reference this file

---

### Requirement: All services MUST propagate X-Request-ID

All 3 services (Core-API, Client-App, AI-Engine) SHALL generate, propagate, and log X-Request-ID for distributed request tracing. Core-API and AI-Engine already have middleware; this requirement completes them and adds Client-App middleware.

#### Scenario: Core-API and AI-Engine middleware already exist
- **WHEN** reviewing existing code
- **THEN** Core-API has `requestIdMiddleware` in `src/middleware/error.middleware.ts`
- **AND** AI-Engine has `RequestIDMiddleware` in `app/middleware/request_id.py`
- **AND** both read X-Request-ID header or generate UUID

#### Scenario: Service generates request ID if not present
- **WHEN** service receives request without X-Request-ID header
- **THEN** middleware generates new UUID
- **AND** stores ID in request context

#### Scenario: Service uses existing request ID if present
- **WHEN** service receives request with X-Request-ID header
- **THEN** middleware uses existing ID (does not generate new one)
- **AND** preserves ID from upstream caller

#### Scenario: Request ID returned in response headers
- **WHEN** service sends response
- **THEN** response includes X-Request-ID header
- **AND** client can reference ID for error reports

#### Scenario: Request ID included in all log statements
- **WHEN** service logs any message during request processing
- **THEN** log entry includes requestId field
- **AND** log aggregation can filter by requestId
- **AND** all logs for one request share same ID

#### Scenario: Request ID propagated to downstream services
- **WHEN** Client-App calls Core-API or Core-API calls AI-Engine
- **THEN** outbound HTTP request includes X-Request-ID header
- **AND** downstream service receives and uses same ID
- **AND** tracing works across service boundaries

#### Scenario: Client-App adds missing middleware
- **WHEN** Client-App receives request
- **THEN** new Laravel middleware generates or accepts X-Request-ID
- **AND** stores ID in request attributes
- **AND** propagates ID to Core-API via `Controller::apiRequest()`
- **AND** echoes ID in response header

---

### Requirement: Request tracing MUST enable cross-service debugging

With X-Request-ID propagation, operators SHALL be able to trace a single request through all services.

#### Scenario: Single request traceable in log aggregation
- **WHEN** operator searches logs for specific requestId
- **THEN** results show entries from Client-App, Core-API, AND AI-Engine
- **AND** chronological order shows request flow
- **AND** can identify which service failed

#### Scenario: Error reports include request ID
- **WHEN** frontend catches API error
- **THEN** error notification includes X-Request-ID from response
- **AND** user can provide ID to support team
- **AND** support can look up full request trace

#### Scenario: Request ID works with existing monitoring
- **WHEN** monitoring tools (Sentry, DataDog) capture errors
- **THEN** X-Request-ID is included as tag/metadata
- **AND** can be used to correlate with server logs
