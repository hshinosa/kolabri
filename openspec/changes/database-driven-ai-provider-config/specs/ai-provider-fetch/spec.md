# Specification: AI Provider Fetch

## ADDED Requirements

### Requirement: Fetch active provider from database
AI Engine SHALL fetch active provider configuration from Core API database via HTTP request to internal endpoint.

#### Scenario: Successful fetch
- **WHEN** AI Engine initializes LLMService
- **THEN** system fetches active provider from Core API endpoint `/internal/ai-provider/active`

#### Scenario: Multiple active providers
- **WHEN** multiple providers have `isActive=true`
- **THEN** system selects provider with lowest `fallbackOrder` value

#### Scenario: Network timeout
- **WHEN** HTTP request to Core API times out after 10 seconds
- **THEN** system logs error and falls back to environment variables

### Requirement: Fallback to environment variables
AI Engine SHALL use environment variables as fallback when database fetch fails.

#### Scenario: Core API unreachable
- **WHEN** Core API endpoint returns connection error
- **THEN** system uses `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_MODEL` from environment

#### Scenario: No active provider in database
- **WHEN** Core API returns empty response (no active provider)
- **THEN** system uses environment variable configuration

#### Scenario: Invalid response format
- **WHEN** Core API returns malformed JSON response
- **THEN** system logs error and falls back to environment variables

### Requirement: Provider configuration validation
AI Engine SHALL validate fetched provider configuration before use.

#### Scenario: Missing required fields
- **WHEN** fetched provider lacks `apiKey` or `baseUrl`
- **THEN** system rejects provider and attempts fallback

#### Scenario: Empty API key
- **WHEN** fetched provider has empty string for `apiKey`
- **THEN** system logs warning and falls back to environment variables

#### Scenario: Invalid base URL format
- **WHEN** fetched provider `baseUrl` is not a valid HTTP/HTTPS URL
- **THEN** system rejects provider and falls back

### Requirement: Retry mechanism
AI Engine SHALL retry failed fetch attempts with exponential backoff.

#### Scenario: Transient network error
- **WHEN** first fetch attempt fails with connection error
- **THEN** system retries after 1 second delay

#### Scenario: Multiple consecutive failures
- **WHEN** fetch fails 3 times consecutively
- **THEN** system uses fallback and logs alert for investigation

#### Scenario: Retry success
- **WHEN** second retry attempt succeeds
- **THEN** system uses fetched provider configuration

### Requirement: Bootstrap initialization
AI Engine SHALL fetch provider configuration during application startup.

#### Scenario: Startup fetch
- **WHEN** AI Engine application starts
- **THEN** system fetches provider before accepting first request

#### Scenario: Startup fetch failure
- **WHEN** provider fetch fails during startup
- **THEN** system logs warning but continues with environment variable configuration
