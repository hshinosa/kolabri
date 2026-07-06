## Context

Kolabri currently has two independent AI runtime configuration paths. Core-api stores encrypted provider records in PostgreSQL and uses them for lecturer preview, provider testing, and personal chat when active providers exist. Ai-engine, however, initializes its own LLM clients from `OPENAI_API_KEY` and `OPENAI_BASE_URL` environment variables and uses those clients for orchestration, interventions, summaries, goal validation/refinement, reading recommendations, RAG, and analytics AI flows. This divergence means admin changes in AI settings do not propagate to many production features and ai-engine can fail startup even when valid provider settings already exist in the platform database.

The migration spans two services, touches security-sensitive provider credentials, and changes an internal service contract between core-api and ai-engine. The design must preserve feature availability during rollout, avoid exposing raw secrets in logs or persistence, and allow rollback if any ai-engine execution path regresses.

## Goals / Non-Goals

**Goals:**
- Establish core-api plus the `AiProvider` table as the single runtime source of truth for provider selection, activation, fallback ordering, base URL, model defaults, and encrypted credentials.
- Introduce a normalized internal execution contract so ai-engine receives resolved provider/runtime config from core-api for AI-backed features.
- Unify provider routing across personal chat, orchestration, interventions, summaries, goal validation/refinement, reading recommendations, RAG, and analytics AI flows.
- Keep rollout safe with compatibility mode, per-feature migration sequencing, observability, and rollback controls.
- Reduce ai-engine startup dependency on provider-specific env vars so env remains only for bootstrap and security primitives.

**Non-Goals:**
- Replacing the existing `AiProvider` encryption approach or adding an external secrets manager in this migration.
- Redesigning prompt content, guardrail policy semantics, scaffolding logic, or citation filtering behavior.
- Changing admin UX for provider CRUD beyond what is required to support unified routing.
- Supporting multi-tenant provider ownership beyond current platform-wide active provider semantics.

## Decisions

### 1. Core-api becomes the control plane for all provider resolution
Core-api will resolve the active provider, fallback chain, base URL, model defaults, and decrypted execution credentials for every AI-backed request before calling ai-engine. This keeps one authoritative source of truth and aligns with the existing DB-backed provider model already used by `ai.service.ts`.

**Why this over letting ai-engine read DB directly?**
- Core-api already owns admin provider settings, activation rules, and fallback logic.
- Direct ai-engine DB reads would duplicate business rules and create cross-service coupling to core-api's persistence model.
- Centralizing resolution in core-api makes auditability, rollout, and future provider policy changes easier.

### 2. Ai-engine becomes an execution/orchestration plane, not a provider resolver
Ai-engine will accept a normalized `provider_context` payload on internal requests and use it to instantiate or select its LLM client for the request being processed. Ai-engine must stop treating `OPENAI_API_KEY` and `OPENAI_BASE_URL` as the authoritative runtime provider source once migration completes.

**Why this over keeping hybrid routing?**
- Hybrid routing produces inconsistent behavior across features after admin provider changes.
- It creates production risk because ai-engine boot validity can diverge from runtime provider validity.
- A single control-plane contract makes cross-feature behavior predictable.

### 3. Provider context is an explicit, versioned request contract
The migration will introduce a versioned internal contract shared by core-api and ai-engine. The initial contract is `provider_context.v1` and is attached to migrated ai-engine requests while feature-specific payloads such as week context, chat history, guardrail policy, and citation scope remain separate.

Example shape:

```json
{
  "version": "1.0",
  "provider": {
    "name": "openai",
    "displayName": "OpenAI GPT"
  },
  "execution": {
    "baseUrl": "https://api.openai.com/v1",
    "model": "gpt-4o-mini",
    "temperature": 0.4,
    "maxTokens": 1024
  },
  "auth": {
    "type": "api-key",
    "credential": "<raw provider credential>"
  },
  "metadata": {
    "featureFamily": "orchestration",
    "requestId": "<uuid>",
    "resolvedAt": "<iso-8601>"
  }
}
```

The schema must be validated by both services and covered by contract tests before feature migration begins.

### 4. Use phased compatibility mode with feature-by-feature migration
The migration will proceed in phases. Core-api will gain the new execution contract first, then selected ai-engine-backed features will opt into it one by one. During compatibility mode, ai-engine may still keep bootstrap fallback behavior for explicitly gated rollback scenarios, but those paths must be observable and removable.

**Why this over a big-bang cutover?**
- Ai-engine touches many feature families with different payload shapes and operational sensitivity.
- Phased rollout reduces blast radius and allows per-feature verification.
- Existing personal chat and orchestration flows can serve as validation checkpoints before moving lower-risk background features.

### 5. Preserve encrypted-at-rest secrets; decrypt only in core-api request path
Provider secrets remain encrypted in PostgreSQL. Core-api decrypts them only when building the internal `provider_context` for ai-engine or when directly invoking DB-backed adapters. The internal contract must avoid logging raw credentials and should transmit only what ai-engine needs for in-memory execution.

This migration chooses **raw credential transport over the internal service boundary** during compatibility and steady-state unified execution.

**Why this over token exchange?**
- Token exchange adds another round trip and makes core-api a blocking secret fetch dependency for every LLM call.
- Raw credential transport is simpler to implement and matches the current ai-engine execution model, which already expects a directly usable API key when building the provider client.
- This keeps provider-resolution ownership centralized without introducing a second callback protocol in the same migration.

**Why this over moving secrets into ai-engine env or DB caches?**
- It preserves the current trust boundary: DB stores encrypted secrets; core-api owns decryption.
- It avoids reintroducing a second source of truth in ai-engine env.
- It limits secret handling to transient in-memory internal requests.

**Required protections:**
- Provider credentials MUST be redacted from logs and traces in both services.
- Ai-engine MUST NOT persist `provider_context` or cache raw credentials beyond request scope.
- Failed requests MUST NOT echo credentials in error payloads.

### 6. Keep provider fallback policy in core-api
Fallback ordering and retry policy remain controlled by core-api. Ai-engine executes one resolved provider per request and must not independently choose another provider. If fallback is required for ai-engine-executed features, core-api retries the ai-engine request with a newly resolved `provider_context` for the next provider.

**Why this over ai-engine-managed fallback?**
- Fallback order is already a core-api concern encoded in `AiProvider` and tested in `ai.service.ts`.
- Duplicating fallback policy in ai-engine would reintroduce split-brain behavior.

**Timeout rule:**
- Core-api MUST enforce a bounded total timeout budget for synchronous flows when retrying ai-engine-backed requests across providers.
- Ai-engine request retries MUST respect feature-specific timeout budgets so fallback does not multiply latency without bound.

### 7. Compatibility flags are env-driven and per feature family
Migration rollout flags live in service environment configuration for the initial migration. They are evaluated with a global kill switch and explicit per-feature switches.

Example flags:
- `UNIFIED_PROVIDER_ENABLED`
- `UNIFIED_PROVIDER_PERSONAL_CHAT`
- `UNIFIED_PROVIDER_ORCHESTRATION`
- `UNIFIED_PROVIDER_INTERVENTIONS`
- `UNIFIED_PROVIDER_SUMMARIES`
- `UNIFIED_PROVIDER_GOALS`
- `UNIFIED_PROVIDER_RAG`
- `UNIFIED_PROVIDER_ANALYTICS`
- `UNIFIED_PROVIDER_COMPATIBILITY_MODE`

Evaluation order:
1. Global kill switch disabled → legacy behavior
2. Feature flag disabled → legacy behavior for that feature family
3. Feature flag enabled → use unified provider routing

### 8. Ai-engine bootstrap env remains only for infrastructure and service security
After migration, ai-engine env stays responsible only for bootstrap and infrastructure concerns that cannot come from provider DB state, such as service-to-service authentication secrets, encryption/master keys, MongoDB/Redis/Qdrant URLs, runtime timeout/circuit-breaker settings, and migration compatibility flags.

`OPENAI_API_KEY` and `OPENAI_BASE_URL` cease to be the normal runtime provider source once unified routing is enabled for a feature family.

### 9. Deployment sequencing is fixed to support safe rollout and rollback
The deployment order is:
1. Deploy ai-engine with request-scoped `provider_context` support and compatibility mode still enabled.
2. Deploy core-api with the ability to resolve and attach `provider_context`, but leave feature-family flags disabled.
3. Enable feature flags one family at a time.
4. Observe latency, error rate, provider distribution, and degraded outcomes.
5. Disable compatibility mode only after all migrated feature families are verified.

## Risks / Trade-offs

- **[Internal contract complexity]** → Mitigation: define a single normalized `provider_context` schema, version it, and add contract tests in both services.
- **[Secret exposure in logs or traces]** → Mitigation: explicitly redact provider context logging, prohibit raw credential serialization, and add regression tests for log-safe paths.
- **[Feature regressions during phased migration]** → Mitigation: migrate feature families incrementally, add feature-level fallback flags, and verify route-by-route behavior before enabling globally.
- **[Latency increase from core-api pre-resolution]** → Mitigation: reuse existing provider resolution code paths, minimize additional DB queries, instrument `provider_resolution_ms`, and keep acceptance criteria for synchronous flows within agreed budgets.
- **[Rollback ambiguity]** → Mitigation: keep compatibility mode and rollback toggles per feature until all critical flows pass smoke and integration verification; document exact rollback steps and deployment sequencing.
- **[Core-api becomes a harder dependency]** → Mitigation: keep compatibility mode available during migration, surface structured degraded outcomes when provider context is missing or invalid, and monitor core-api reachability as part of ai-engine readiness.

## Migration Plan

1. **Define and test the contract**
   - Add a versioned internal `provider_context` schema shared by core-api and ai-engine.
   - Add validation and contract tests in both services.

2. **Prepare core-api control-plane layer**
   - Extract reusable provider resolution logic from current DB-backed adapter paths.
   - Add a service that resolves the active provider/fallback plan for both direct core-api AI calls and ai-engine-backed calls.

3. **Add ai-engine request-scoped execution support**
   - Refactor ai-engine LLM client creation from singleton env-driven initialization to request-scoped client creation for migrated flows.
   - Teach ai-engine endpoints to accept `provider_context` and build request-scoped LLM clients from it.
   - Keep temporary compatibility mode for env-based provider resolution behind an explicit rollback flag.

4. **Migrate feature families incrementally**
   - Phase 1: personal chat alignment, including the streaming path, and shared provider resolution utilities.
   - Phase 2: orchestration, interventions, summaries.
   - Phase 3: goal validation/refinement, reading recommendations, RAG, analytics AI.

5. **Cut over and remove split runtime truth**
   - Switch all ai-engine-backed core-api callers to send resolved provider context.
   - Remove ai-engine dependence on `OPENAI_API_KEY` / `OPENAI_BASE_URL` as normal runtime provider sources.

6. **Rollback strategy**
   - Disable specific `UNIFIED_PROVIDER_<FEATURE>` flag to revert one feature family to compatibility mode.
   - Disable `UNIFIED_PROVIDER_ENABLED` to revert all migrated flows to legacy behavior.
   - Preserve current env bootstrap values until all migrated flows pass verification in production-like environments.

## Open Questions

- Do we want to unify direct core-api provider execution behind ai-engine later, or keep some DB-backed direct adapter flows (for example lecturer preview/testing) in core-api permanently?
- Should core-api cache resolved active-provider snapshots for a short TTL to reduce repetitive DB reads on high-volume ai-engine-backed flows?
