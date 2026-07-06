## 1. Contract and control-plane foundation

- [x] 1.1 Define the versioned `provider_context.v1` schema and add validation/contract tests in both core-api and ai-engine
- [x] 1.2 Implement a core-api provider-resolution service that returns authoritative execution config from active `AiProvider` records and current fallback order
- [x] 1.3 Add log-redaction and error-safety guards so raw provider credentials are never written to logs, traces, or persisted payloads

## 2. Ai-engine execution refactor

- [x] 2.1 Refactor ai-engine LLM client creation from singleton env-driven initialization to request-scoped client creation for migrated flows
- [x] 2.2 Update ai-engine request handlers to accept `provider_context` on personal chat, orchestration, interventions, summaries, goals, reading recommendations, RAG, and analytics routes
- [x] 2.3 Add env-driven compatibility flags and legacy execution branches for per-feature rollback during migration

## 3. Core-api caller migration

- [x] 3.1 Update personal chat and personal chat streaming paths to resolve provider context in core-api before calling ai-engine
- [x] 3.2 Update orchestration, intervention, and summary callers to attach authoritative provider context to ai-engine requests
- [x] 3.3 Update goal validation/refinement, reading recommendations, RAG, and analytics AI callers to attach authoritative provider context to ai-engine requests
- [x] 3.4 Implement core-api-owned fallback retry behavior and bounded timeout handling for ai-engine-backed feature families

## 4. Verification, rollout, and cutover

- [x] 4.1 Add end-to-end integration tests proving admin provider changes propagate consistently across all migrated feature families
- [x] 4.2 Add deployment/runbook checks for feature flags, degraded outcomes, compatibility mode, and per-feature rollback
- [x] 4.3 Instrument provider-resolution latency and migrated-flow error metrics, then verify rollout acceptance criteria before disabling legacy env provider sourcing
- [x] 4.4 Remove ai-engine runtime dependence on `OPENAI_API_KEY` and `OPENAI_BASE_URL` as normal provider sources after rollout verification completes
