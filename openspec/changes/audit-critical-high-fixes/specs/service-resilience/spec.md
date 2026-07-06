## ADDED Requirements

### Requirement: discussion-direction service MUST use existing circuit breaker

The discussion-direction service SHALL be wrapped with the existing `aiEngineCircuitBreaker` (already used by aiEngine.service.ts). Configuration: failureThreshold=5, cooldownMs=30000.

#### Scenario: Closed circuit allows normal operation (EXISTING for aiEngine.service.ts)
- **WHEN** AI Engine is healthy
- **THEN** circuit breaker state is CLOSED
- **AND** all requests pass through to AI Engine (aiEngine.service.ts already uses it)
- **AND** discussion-direction service also passes through

#### Scenario: discussion-direction wrapped with circuit breaker (NEW)
- **WHEN** discussion-direction service calls AI Engine
- **THEN** call is wrapped in `aiEngineCircuitBreaker.execute()`
- **AND** uses same circuit breaker instance as aiEngine.service.ts

#### Scenario: Open circuit fails fast after repeated failures (EXISTING)
- **WHEN** 5 consecutive AI Engine calls fail (from any service)
- **THEN** circuit breaker opens
- **AND** subsequent requests fail immediately without calling AI Engine
- **AND** response time is <10ms (fast-fail vs 30s timeout)

#### Scenario: Half-open circuit tests recovery (EXISTING)
- **WHEN** circuit has been open for 30 seconds
- **THEN** circuit breaker transitions to HALF-OPEN state
- **AND** next request is allowed through to test AI Engine health

#### Scenario: Circuit breaker configuration is consistent (EXISTING)
- **WHEN** reviewing circuit breaker instances
- **THEN** all use same configuration: failureThreshold=5, cooldownMs=30000, name='ai-engine'
- **AND** single `aiEngineCircuitBreaker` instance shared across services
- **AND** behavior is predictable across all AI Engine integrations

#### Scenario: Open circuit returns graceful fallback
- **WHEN** circuit is OPEN and request is blocked
- **THEN** system returns default/fallback response instead of error
- **AND** user experience degrades gracefully (feature disabled, not broken)
- **AND** logs indicate circuit breaker triggered fallback

---

### Requirement: Failed query operations MUST log with context

Database query failures SHALL be logged with comprehensive context (query params, error, stack trace) instead of silent catch blocks.

#### Scenario: resolveWeekLabelsByIds failure is logged
- **WHEN** resolveWeekLabelsByIds() query fails
- **THEN** error is logged with: weekIds array, error message, stack trace, timestamp
- **AND** log level is ERROR
- **AND** enables debugging of production issues

#### Scenario: Empty result sets are distinguished from errors
- **WHEN** query succeeds but returns no results
- **THEN** empty map is returned without error log
- **AND** warnings array in API response indicates "Week data unavailable"
- **AND** logs do NOT show error (expected behavior)

#### Scenario: Query logging does not expose sensitive data
- **WHEN** error includes database connection details
- **THEN** logged error sanitizes connection strings, passwords
- **AND** only includes: query params, error message, operation name
- **AND** sensitive data is redacted

---

### Requirement: Batch operations MUST support partial success

File upload batch operations SHALL use Promise.allSettled to allow partial success instead of all-or-nothing failure.

#### Scenario: Successful uploads return 207 Multi-Status
- **WHEN** 4 out of 5 files upload successfully
- **THEN** response status is 207 Multi-Status
- **AND** response includes successful array (4 file URLs)
- **AND** response includes failed array (1 file with error message)

#### Scenario: All successful uploads return 200
- **WHEN** all files in batch upload successfully
- **THEN** response status is 200 OK
- **AND** response includes all file URLs
- **AND** failed array is empty

#### Scenario: All failed uploads return 500
- **WHEN** all files in batch fail to upload
- **THEN** response status is 500 Internal Server Error
- **AND** failed array includes all files with error details
- **AND** successful array is empty

#### Scenario: Frontend can retry only failed files
- **WHEN** partial success response (207) is returned
- **THEN** frontend displays: "Uploaded 4/5 files"
- **AND** shows retry button for failed file only
- **AND** successful files are not re-uploaded

---

### Requirement: Environment configuration MUST be correct

Service authentication SHALL use correct environment variable references to prevent 403 authorization failures.

#### Scenario: Discussion-direction uses AI_ENGINE_SECRET
- **WHEN** Core-API calls discussion-direction service
- **THEN** X-API-Key header uses process.env.AI_ENGINE_SECRET
- **AND** NOT process.env.CORE_API_SECRET (incorrect variable)

#### Scenario: .env.example documents all required secrets
- **WHEN** reviewing environment configuration template
- **THEN** .env.example includes AI_ENGINE_SECRET with description
- **AND** deployment checklist verifies variable is set

#### Scenario: Missing environment variable fails at startup
- **WHEN** server starts without AI_ENGINE_SECRET defined
- **THEN** startup validation fails with clear error message
- **AND** server does NOT start (fail-fast principle)
- **AND** error indicates which variable is missing

#### Scenario: Correct secret allows successful AI Engine calls
- **WHEN** AI_ENGINE_SECRET is correctly set and used
- **THEN** discussion-direction calls return 200 success
- **AND** AI Engine authenticates request
- **AND** no 403 Forbidden errors occur

---

### Requirement: Resilience patterns MUST be observable

Circuit breaker state changes and retry attempts SHALL be logged for monitoring and alerting.

#### Scenario: Circuit state transitions are logged
- **WHEN** circuit breaker opens due to failures
- **THEN** log records: service name, state transition (CLOSED → OPEN), failure count, timestamp
- **AND** monitoring system can alert ops team

#### Scenario: Circuit remaining open is logged periodically
- **WHEN** circuit stays open for >5 minutes
- **THEN** system logs reminder every 60 seconds
- **AND** ops team has visibility into prolonged outage

#### Scenario: Circuit recovery is logged
- **WHEN** circuit transitions from OPEN → HALF-OPEN → CLOSED
- **THEN** log records successful recovery with timestamp
- **AND** ops team can measure downtime duration

#### Scenario: Fallback usage is measurable
- **WHEN** reviewing system behavior under AI Engine outage
- **THEN** logs enable calculation of fallback rate (fallbacks / total requests)
- **AND** can measure user impact (% of requests degraded)

---

### Requirement: Graceful degradation MUST maintain core functionality

When AI Engine is unavailable, core features SHALL continue working with reduced AI functionality.

#### Scenario: Chat continues without AI intervention
- **WHEN** AI Engine circuit is OPEN
- **AND** user sends chat message
- **THEN** message is stored and delivered successfully
- **AND** AI intervention is skipped (fallback)
- **AND** users can continue discussion without AI features

#### Scenario: File uploads work without AI analysis
- **WHEN** AI Engine circuit is OPEN
- **AND** user uploads course material
- **THEN** file is validated, stored, and made available
- **AND** AI-powered analysis is skipped
- **AND** core upload functionality remains operational

#### Scenario: Discussion direction defaults to neutral
- **WHEN** circuit breaker prevents discussion-direction call
- **THEN** system returns default: { direction: 'continue', confidence: 0 }
- **AND** discussion proceeds without AI guidance
- **AND** no error is shown to user (transparent degradation)

---

### Requirement: Error recovery MUST be automatic

Transient failures SHALL auto-recover through retries and circuit breaker reset without manual intervention.

#### Scenario: Transient network error auto-recovers via retry
- **WHEN** AI Engine call fails with ETIMEDOUT
- **THEN** system retries after 5 seconds
- **AND** retry succeeds
- **AND** no manual intervention required

#### Scenario: Circuit breaker auto-recovers after timeout
- **WHEN** circuit opens due to failures
- **AND** AI Engine recovers after 60 seconds
- **THEN** circuit automatically transitions to HALF-OPEN
- **AND** successful test request closes circuit
- **AND** full functionality restored automatically

#### Scenario: Persistent failures require ops intervention
- **WHEN** circuit remains open for >30 minutes
- **THEN** monitoring alerts ops team
- **AND** ops investigates AI Engine health
- **AND** manual fix may be required (but circuit continues testing recovery)
