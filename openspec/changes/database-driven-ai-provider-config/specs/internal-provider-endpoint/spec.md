# Specification: Internal Provider Endpoint

## ADDED Requirements

### Requirement: Internal endpoint exposure
Core API SHALL expose internal-only endpoint for AI Engine to retrieve active provider configuration.

#### Scenario: Endpoint accessibility
- **WHEN** AI Engine sends GET request to `/internal/ai-provider/active`
- **THEN** Core API returns active provider configuration

#### Scenario: Public access blocked
- **WHEN** external client attempts to access `/internal/*` routes
- **THEN** Core API returns 401 Unauthorized (missing internal secret)

### Requirement: Authentication via shared secret
Core API SHALL authenticate internal requests using `X-Internal-Secret` header.

#### Scenario: Valid secret
- **WHEN** request includes header `X-Internal-Secret: <CORE_API_SECRET>`
- **THEN** Core API processes request and returns provider

#### Scenario: Missing secret
- **WHEN** request lacks `X-Internal-Secret` header
- **THEN** Core API returns 401 with error message

#### Scenario: Invalid secret
- **WHEN** request includes incorrect secret value
- **THEN** Core API returns 401 and logs security warning

### Requirement: Active provider selection
Core API SHALL return provider with `isActive=true` and lowest `fallbackOrder`.

#### Scenario: Single active provider
- **WHEN** database has one provider with `isActive=true`
- **THEN** endpoint returns that provider

#### Scenario: Multiple active providers
- **WHEN** database has multiple providers with `isActive=true`
- **THEN** endpoint returns provider with lowest `fallbackOrder` value

#### Scenario: No active provider
- **WHEN** database has no providers with `isActive=true`
- **THEN** endpoint returns 404 Not Found with message

### Requirement: Response format
Core API SHALL return provider configuration in structured JSON format.

#### Scenario: Complete provider data
- **WHEN** active provider exists
- **THEN** response includes: `id`, `name`, `displayName`, `apiKey`, `baseUrl`, `config` (model, temperature, maxTokens)

#### Scenario: Encrypted API key
- **WHEN** provider has encrypted `apiKey` in database
- **THEN** response includes decrypted `apiKey` value

#### Scenario: Missing optional fields
- **WHEN** provider has no `baseUrl` (null)
- **THEN** response includes `baseUrl: null`

### Requirement: Performance
Core API SHALL respond to internal provider requests within 100ms (p95).

#### Scenario: Fast database query
- **WHEN** endpoint receives request
- **THEN** system executes query with index on `isActive` and `fallbackOrder`

#### Scenario: Response time monitoring
- **WHEN** endpoint processes request
- **THEN** system logs response time for performance tracking

### Requirement: Error handling
Core API SHALL return appropriate HTTP status codes for error conditions.

#### Scenario: Database connection error
- **WHEN** PostgreSQL connection fails
- **THEN** endpoint returns 503 Service Unavailable

#### Scenario: Database query timeout
- **WHEN** query exceeds 5 second timeout
- **THEN** endpoint returns 504 Gateway Timeout

#### Scenario: Decryption failure
- **WHEN** `apiKey` decryption fails due to missing encryption key
- **THEN** endpoint returns 500 Internal Server Error and logs critical alert
