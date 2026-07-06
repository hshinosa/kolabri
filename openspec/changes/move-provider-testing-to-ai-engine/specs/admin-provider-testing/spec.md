## ADDED Requirements

### Requirement: Admin can test AI provider connection

The system SHALL provide an endpoint for administrators to test AI provider connectivity and validate API credentials. The test SHALL send a simple prompt to the provider and return success/failure with latency metrics.

#### Scenario: Successful provider test

- **WHEN** admin submits test request with valid provider credentials (name, API key, base URL, model)
- **THEN** system sends test prompt to provider API, receives response, and returns success status with response content and latency

#### Scenario: Invalid API key

- **WHEN** admin submits test request with invalid API key
- **THEN** system returns failure status with error message indicating authentication failure

#### Scenario: Provider API timeout

- **WHEN** admin submits test request but provider API does not respond within timeout
- **THEN** system returns failure status with timeout error and elapsed time

#### Scenario: Unsupported provider

- **WHEN** admin submits test request for provider not supported by system
- **THEN** system returns validation error listing supported providers

### Requirement: AI-Engine handles provider testing

The AI-Engine service SHALL accept provider test requests via `/admin/test-provider` endpoint and instantiate provider clients transiently for testing. Core-API SHALL NOT instantiate LLM clients directly.

#### Scenario: AI-Engine receives test request

- **WHEN** Core-API delegates provider test to AI-Engine
- **THEN** AI-Engine instantiates provider client (OpenAI/Anthropic/Gemini), sends test prompt, measures latency, and returns result

#### Scenario: Core-API delegates to AI-Engine

- **WHEN** admin triggers provider test via Core-API admin UI
- **THEN** Core-API sends HTTP POST to AI-Engine `/admin/test-provider` with provider config and test prompt

### Requirement: Test results include diagnostic information

The system SHALL return structured test results including success status, response content (if successful), error message (if failed), latency in milliseconds, and provider model used.

#### Scenario: Test result structure for success

- **WHEN** provider test succeeds
- **THEN** system returns `{success: true, response: string, latencyMs: number, model: string}`

#### Scenario: Test result structure for failure

- **WHEN** provider test fails
- **THEN** system returns `{success: false, error: string, latencyMs: number}`

### Requirement: Custom test prompts are supported

The system SHALL allow administrators to specify custom test prompts. If no custom prompt provided, system SHALL use default prompt "Hello".

#### Scenario: Custom test prompt

- **WHEN** admin provides custom test prompt "Explain quantum computing"
- **THEN** system sends custom prompt to provider and returns provider's response

#### Scenario: Default test prompt

- **WHEN** admin does not provide test prompt
- **THEN** system uses default prompt "Hello" for testing

### Requirement: Provider base URL override is supported

The system SHALL allow administrators to test providers with custom base URLs (for proxy or custom endpoints). If no base URL provided, system SHALL use provider's default endpoint.

#### Scenario: Custom base URL

- **WHEN** admin provides custom base URL "https://custom.openai.com/v1"
- **THEN** system sends test request to custom URL instead of default OpenAI endpoint

#### Scenario: Default base URL

- **WHEN** admin does not provide base URL
- **THEN** system uses provider's default API endpoint (e.g., "https://api.openai.com/v1" for OpenAI)
