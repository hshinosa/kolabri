## ADDED Requirements

### Requirement: Core API SHALL resolve runtime provider context for ai-engine requests
The system SHALL make core-api the single runtime source of truth for AI provider resolution. Before invoking ai-engine for AI-backed feature execution, core-api MUST resolve the active provider configuration from platform-managed provider records and build a normalized provider context for the request.

#### Scenario: Core-api resolves active provider for ai-engine execution
- **WHEN** a core-api feature invokes ai-engine for orchestration, summary generation, interventions, goal validation/refinement, RAG, reading recommendations, or analytics AI
- **THEN** core-api resolves the active provider configuration from DB-managed provider records before issuing the ai-engine request

#### Scenario: Provider context includes resolved runtime settings
- **WHEN** core-api sends an ai-engine request that requires LLM execution
- **THEN** the request includes a normalized provider context containing the resolved provider identity and execution settings required for ai-engine to execute the request without independently resolving provider source of truth from its own runtime env

### Requirement: Ai-engine SHALL execute using request-scoped provider context
Ai-engine SHALL use the provider context supplied by core-api for request-time provider execution and SHALL NOT require independently resolved provider base URL or API key env values as the normal runtime source for migrated features.

#### Scenario: Ai-engine uses supplied provider context
- **WHEN** ai-engine receives a migrated feature request with provider context
- **THEN** ai-engine builds or selects the LLM execution client from that provider context for the scope of the request

#### Scenario: Ai-engine does not override migrated request provider with local runtime defaults
- **WHEN** ai-engine receives a migrated feature request with valid provider context
- **THEN** ai-engine MUST NOT replace the supplied provider identity or endpoint configuration with independently resolved local provider env defaults

### Requirement: Provider credentials SHALL remain protected across service boundaries
The system SHALL keep provider credentials encrypted at rest in DB, decrypt only within the control-plane resolution path, and prevent raw secrets from being logged or persisted by ai-engine.

#### Scenario: Provider credential used without unsafe persistence
- **WHEN** core-api prepares provider context for ai-engine
- **THEN** the provider credential is used only for in-memory execution flow and is not persisted by ai-engine as a new source of truth

#### Scenario: Logs redact provider secrets
- **WHEN** core-api or ai-engine logs request metadata for a migrated AI execution path
- **THEN** provider credentials and raw secret values are omitted or redacted from logs
