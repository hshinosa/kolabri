## Why

Kolabri currently splits AI provider resolution across two runtime paths: core-api resolves DB-managed providers for some features, while ai-engine independently boots with `OPENAI_API_KEY` and `OPENAI_BASE_URL` from environment variables for orchestration and analytics flows. This creates two sources of truth, inconsistent feature behavior after admin provider changes, and production risk because ai-engine startup validity depends on env even when provider settings already exist in the platform.

## What Changes

- Make core-api the single runtime source of truth for AI provider selection, activation, fallback order, base URL, model defaults, and encrypted credentials.
- Introduce a control-plane contract where core-api sends resolved provider/runtime config to ai-engine for execution-oriented flows instead of ai-engine resolving providers from its own runtime env.
- Migrate env-driven ai-engine features to use resolved provider config supplied by core-api, including orchestration, interventions, summary generation, goal validation/refinement, reading recommendations, RAG question answering, and analytics AI flows.
- Preserve current behavior during rollout with a phased compatibility mode and explicit fallback/rollback controls.
- **BREAKING** Remove ai-engine's role as an independent runtime source of truth for provider selection once migration is complete; env values remain only for bootstrap/security primitives that cannot come from DB.

## Capabilities

### New Capabilities
- `ai-provider-control-plane`: Core-api resolves provider configuration and passes a normalized, secure execution config to ai-engine for all AI-backed features.
- `ai-runtime-routing-unification`: AI features use one provider resolution policy across personal chat, orchestration, interventions, summaries, goal workflows, RAG, reading recommendations, and analytics.

### Modified Capabilities
- `reading-recommendations`: Reading recommendation generation must use the unified provider resolution path instead of ai-engine-local provider envs.
- `week-aligned-goal-validation`: Goal validation/refinement must use the unified provider resolution path instead of ai-engine-local provider envs.

## Impact

- Affected systems: `Kolabri-core-api`, `Kolabri-ai-engine`, admin AI provider settings flows, runtime AI orchestration paths, deployment configuration, and operational rollback procedures.
- Affected APIs/contracts: internal core-api → ai-engine request schema, ai-engine runtime bootstrap assumptions, personal chat routing behavior, and feature-level AI execution consistency.
- Affected operational model: provider changes in admin settings become authoritative for all AI features; ai-engine env vars no longer act as a separate runtime provider source after migration.
