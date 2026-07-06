## ADDED Requirements

### Requirement: Admin can fetch available models from provider

The system SHALL provide an endpoint for administrators to fetch the list of available models from AI providers (OpenAI, Anthropic, Gemini). The system SHALL query provider APIs for current model lists instead of using hardcoded data.

#### Scenario: Fetch OpenAI models

- **WHEN** admin requests models for provider "openai"
- **THEN** system calls OpenAI API `/v1/models`, returns list of models with metadata (id, name, context window)

#### Scenario: Fetch Anthropic models

- **WHEN** admin requests models for provider "anthropic"
- **THEN** system returns list of Anthropic models (hardcoded list since Anthropic has no discovery API)

#### Scenario: Fetch Gemini models

- **WHEN** admin requests models for provider "gemini"
- **THEN** system calls Google AI API `/v1/models`, returns list of Gemini models with metadata

#### Scenario: Unknown provider

- **WHEN** admin requests models for unsupported provider
- **THEN** system returns validation error with list of supported providers

### Requirement: Model metadata includes relevant information

The system SHALL return model metadata including model ID, display name, description (if available), context window size, and pricing (if available). Pricing SHALL include input cost and output cost per token.

#### Scenario: Model metadata structure

- **WHEN** system returns model list
- **THEN** each model includes `{id: string, name: string, description?: string, contextWindow?: number, inputCost?: number, outputCost?: number}`

#### Scenario: Pricing data when available

- **WHEN** provider API exposes pricing (e.g., OpenAI)
- **THEN** system includes pricing in model metadata

#### Scenario: Pricing data not available

- **WHEN** provider API does not expose pricing (e.g., Gemini)
- **THEN** system returns model metadata without pricing fields (null/undefined)

### Requirement: Model lists are cached to respect rate limits

The system SHALL cache model lists in-memory with 1-hour TTL to avoid excessive API calls to provider discovery endpoints. Cache SHALL be per-provider.

#### Scenario: First model fetch

- **WHEN** admin requests models for provider (cache empty)
- **THEN** system fetches from provider API, caches result for 1 hour, returns models

#### Scenario: Subsequent fetch within cache TTL

- **WHEN** admin requests models for provider (cache exists, not expired)
- **THEN** system returns cached models without calling provider API

#### Scenario: Cache expired

- **WHEN** admin requests models for provider (cache exists but expired after 1 hour)
- **THEN** system fetches fresh data from provider API, updates cache, returns models

### Requirement: Cache refresh can be forced

The system SHALL allow administrators to force cache refresh by passing query parameter `refresh=true`. This bypasses cache and fetches fresh data from provider API.

#### Scenario: Force cache refresh

- **WHEN** admin requests models with `?refresh=true` query parameter
- **THEN** system bypasses cache, fetches fresh data from provider API, updates cache, returns models

#### Scenario: Normal fetch uses cache

- **WHEN** admin requests models without refresh parameter
- **THEN** system uses cached data if available and not expired

### Requirement: Graceful degradation on API failure

The system SHALL handle provider API failures gracefully. If model discovery fails, system SHALL return error with fallback message instructing admin to manually enter model ID.

#### Scenario: Provider API returns error

- **WHEN** provider API returns 4xx or 5xx error
- **THEN** system returns error status with message "Unable to fetch models from provider. Please manually enter model ID."

#### Scenario: Provider API timeout

- **WHEN** provider API does not respond within timeout (5 seconds)
- **THEN** system returns timeout error with fallback instruction

#### Scenario: Network failure

- **WHEN** network connection to provider API fails
- **THEN** system returns connection error with fallback instruction

### Requirement: Admin UI presents models in searchable dropdown

The Admin UI SHALL fetch models when provider is selected and present them in searchable dropdown. Text input fallback SHALL be available if model fetch fails.

#### Scenario: Provider selected in admin form

- **WHEN** admin selects provider (e.g., "OpenAI") in provider configuration form
- **THEN** UI fetches models via `/api/ai-providers/models?provider=openai`, displays models in dropdown with loading state

#### Scenario: Model selection from dropdown

- **WHEN** admin searches and selects model from dropdown (e.g., "gpt-4-turbo-2024-04-09")
- **THEN** selected model ID is saved to provider configuration

#### Scenario: Fallback to text input on fetch failure

- **WHEN** model fetch fails (API error, timeout, network issue)
- **THEN** UI displays warning message and falls back to text input for manual model entry

### Requirement: Model dropdown shows contextual metadata

The Admin UI SHALL display model metadata in dropdown to help administrators make informed choices. Each model option SHALL show model name and context window size.

#### Scenario: Model dropdown display format

- **WHEN** admin opens model dropdown
- **THEN** each option shows format "Model Name (context: 128k tokens)" or similar

#### Scenario: Pricing information tooltip

- **WHEN** pricing data is available and admin hovers over model option
- **THEN** tooltip shows input/output cost per token
