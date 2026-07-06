## Context

**Current State:**

Kolabri has an architectural violation where `Kolabri-core-api` contains direct LLM provider adapters (OpenAI, Anthropic, Gemini SDKs) in `src/services/ai-providers/`. These are used exclusively for admin provider testing via `ai-provider.service.ts`.

**Why It Exists:**

Admin provider testing was designed to work independently of ai-engine health. If ai-engine crashes due to bad provider config, admins can still test new provider credentials via core-api's direct LLM access to fix the issue (chicken-and-egg problem).

**Current Pain Points:**

1. **Architectural Debt**: Core-API duplicates LLM logic that belongs in ai-engine
2. **Maintenance Burden**: Provider changes require updates in 2 places (core-api AND ai-engine)
3. **Poor Admin UX**: Admins manually type model names ("gpt-4-turbo", "claude-3-sonnet") leading to typos
4. **No Model Discovery**: Admins must know model names; no dropdown or auto-fetch from provider APIs

**Stakeholders:**
- **Admins**: Need reliable provider testing + better model selection UX
- **Developers**: Want clean architecture without duplicate LLM logic
- **System Operators**: Need clear separation of env vs DB config

## Goals / Non-Goals

**Goals:**
- Move all LLM SDK imports and direct API calls to ai-engine
- Admin provider testing delegates to ai-engine via HTTP
- Auto-fetch available models from provider APIs (OpenAI, Anthropic, Gemini)
- Admin UI presents models in dropdown instead of text input
- Document best practices for provider config (env vs DB separation)
- Maintain backward compatibility for existing provider configs

**Non-Goals:**
- Change provider configuration data model (schema remains unchanged)
- Implement provider-specific features beyond testing and model discovery
- Auto-configure providers from environment variables (still admin-managed in DB)
- Provider cost tracking or quota management (separate concern)
- Multi-tenant provider isolation (single-tenant admin config)

## Decisions

### Decision 1: AI-Engine Admin Routes Namespace

**Choice**: Add `/admin/*` route namespace in ai-engine for admin-only operations.

**Rationale**:
- Separates admin tooling from production AI features
- Clear intent: `/admin/test-provider` vs `/ask` (production)
- Allows different auth/rate-limiting for admin operations
- Consistent with REST conventions for admin resources

**Alternatives Considered**:
- Reuse existing routes (e.g., `/ask` with special flag) → Rejected: Mixes concerns, confusing API surface
- Create separate admin service → Rejected: Overkill for 2-3 endpoints

### Decision 2: Provider Testing Flow

**Choice**: Core-API delegates testing to ai-engine; ai-engine instantiates LLM clients transiently.

**Flow**:
```
Admin clicks "Test"
→ Core-API POST /api/ai-providers/:id/test (core-api route)
→ Core-API calls ai-engine POST /admin/test-provider with {name, apiKey, baseUrl, model, testPrompt}
→ AI-Engine instantiates provider client (OpenAI/Anthropic/Gemini)
→ AI-Engine sends test prompt, measures latency
→ AI-Engine returns {success, response, latency, error}
→ Core-API returns result to admin
```

**Rationale**:
- Removes LLM logic from core-api
- AI-Engine owns all provider integrations (single source of truth)
- Transient client instantiation (not persistent) keeps testing lightweight

**Trade-off**: AI-Engine must be healthy to test providers. Mitigation: Make ai-engine resilient with circuit breakers and error handling.

**Alternatives Considered**:
- Keep direct access in core-api for independence → Rejected: Violates architecture, maintenance burden
- Persistent provider clients in ai-engine → Rejected: Unnecessary memory overhead for admin testing

### Decision 3: Model Discovery Approach

**Choice**: AI-Engine fetches models from provider APIs on-demand, caches results for 1 hour.

**Implementation**:
- `GET /admin/providers/{provider}/models` endpoint in ai-engine
- Calls provider-specific APIs:
  - OpenAI: `GET /v1/models` (list models)
  - Anthropic: Hardcoded list (no discovery API yet)
  - Gemini: `GET /v1/models` (Google AI API)
- Cache results in-memory (TTL: 1 hour) to avoid rate limits
- Return model metadata: `{id, name, description, contextWindow, inputCost, outputCost}`

**Rationale**:
- Eliminates manual model typing (better UX)
- Admin always sees current model list (no stale docs)
- Caching reduces API calls and respects rate limits

**Alternatives Considered**:
- Hardcode model lists in ai-engine → Rejected: Stale quickly, maintenance burden
- Store models in database → Rejected: Requires migration, staleness issue
- No caching → Rejected: Rate limit risk

### Decision 4: Admin UI Model Selection

**Choice**: Replace text input with searchable dropdown, fetch models on provider change.

**UX Flow**:
1. Admin selects provider (OpenAI/Anthropic/Gemini) from dropdown
2. Client calls `GET /api/ai-providers/models?provider={name}` (core-api proxy)
3. Core-API delegates to ai-engine `GET /admin/providers/{provider}/models`
4. UI renders models in searchable dropdown (react-select or similar)
5. Admin selects model from list (e.g., "gpt-4-turbo-2024-04-09")
6. Form saves selected model ID

**Rationale**:
- Prevents typos (validation at selection time)
- Shows model metadata (context window, cost) to inform choice
- Familiar UX pattern for admins

**Alternatives Considered**:
- Keep text input with autocomplete → Rejected: Still allows typos
- Show all provider models upfront → Rejected: Slow initial load, unnecessary for unused providers

### Decision 5: Provider Config Separation (Env vs DB)

**Choice**: Document clear pattern for provider configuration:

| Config | Storage | Purpose | Example |
|--------|---------|---------|---------|
| **Default Provider** | `.env` | System-wide default when no provider specified | `DEFAULT_AI_PROVIDER=openai` |
| **Provider Credentials** | Database | Per-provider API keys (encrypted) | `apiKey: encrypt("sk-...")` |
| **Provider Base URL** | Database (nullable) | Per-provider custom endpoint (optional) | `baseUrl: "https://custom.openai.com/v1"` |
| **Default Model** | Database | Per-provider default model | `config: {defaultModel: "gpt-4-turbo"}` |
| **Fallback Order** | Database | Provider priority for fallback | `fallbackOrder: 1, 2, 3` |

**Rationale**:
- Environment variables: System-wide config, not per-provider
- Database: Per-provider config, admin-managed, dynamic
- Clear separation prevents confusion

**Documentation**: Create `docs/AI_PROVIDER_CONFIG_GUIDE.md` with examples and best practices.

## Risks / Trade-offs

### Risk 1: AI-Engine Dependency for Admin Testing

**Risk**: If ai-engine is down, admins cannot test provider configs.

**Mitigation**:
- Make ai-engine robust with circuit breakers, proper error handling
- Admin testing is infrequent (configuration changes are rare)
- AI-Engine health monitoring alerts operators before admin needs to test
- Rollback plan: Keep old adapters in git history if emergency revert needed

**Accepted Trade-off**: Prioritize clean architecture over independent admin testing. The chicken-and-egg problem is addressed by making ai-engine resilient, not by duplicating logic.

### Risk 2: Provider API Rate Limits

**Risk**: Fetching models from provider APIs may hit rate limits if admins spam requests.

**Mitigation**:
- Cache model lists for 1 hour (in-memory TTL)
- Rate limit admin endpoints (10 requests/minute per admin)
- Graceful degradation: If model fetch fails, fall back to text input with warning

### Risk 3: Provider API Changes

**Risk**: Provider model APIs may change (new models, deprecated models, API schema changes).

**Mitigation**:
- Cache insulates from temporary API issues
- Model discovery is best-effort: If API fails, admins can still manually enter model ID
- Document provider API versions in code comments
- Monitor provider API health

### Risk 4: Breaking Change for Core-API Dependencies

**Risk**: Removing `ai.service.ts` may break other core-api code.

**Mitigation**:
- Grep for all `ai.service.ts` imports before deletion (verify only `ai-provider.service.ts` uses it)
- Run full test suite after removal
- Check no import statements reference deleted files

**Already Verified**: Only 1 file (`ai-provider.service.ts`) imports `ai.service.ts`.

## Migration Plan

### Phase 1: Add AI-Engine Endpoints (No Breaking Changes)

1. **Deploy to ai-engine**:
   - Add `app/api/routes/admin.py` with test-provider and model-discovery endpoints
   - Add `app/services/admin_provider_test.py` for testing logic
   - Add `app/services/model_discovery.py` for model fetching
   - Deploy and verify endpoints work via manual testing

2. **Verify**:
   - `POST /admin/test-provider` returns success for valid OpenAI key
   - `GET /admin/providers/openai/models` returns model list
   - Check logs for errors

### Phase 2: Update Core-API to Delegate (Breaking Change)

3. **Deploy to core-api**:
   - Modify `ai-provider.service.ts` to call ai-engine endpoints
   - Remove `ai.service.ts` and `ai-providers/` directory
   - Add `GET /api/ai-providers/models` proxy route
   - Update `package.json` to remove OpenAI/Anthropic dependencies
   - Run full test suite

4. **Verify**:
   - Admin can test providers via UI
   - Provider testing still works (now delegating to ai-engine)
   - No imports reference deleted files

### Phase 3: Update Admin UI (UX Improvement)

5. **Deploy to client-app**:
   - Replace model text input with dropdown in `ai-providers/edit.tsx`
   - Add model fetching on provider selection
   - Add loading state and error handling
   - Update form validation

6. **Verify**:
   - Dropdown shows models for each provider
   - Model selection saves correctly
   - Graceful fallback if model fetch fails

### Rollback Strategy

If issues arise:
- **Phase 1**: Safe to rollback ai-engine (endpoints not yet used)
- **Phase 2**: Revert core-api deployment (restore `ai.service.ts` from git history)
- **Phase 3**: Revert client-app deployment (restore text input)

**Critical Path**: Phase 2 is the breaking change. Deploy ai-engine first, verify endpoints work, then deploy core-api.

## Open Questions

**Q1**: Should model discovery include pricing metadata?

**A**: Yes, if provider APIs expose it (OpenAI does). Include `{inputCost, outputCost}` in model metadata to help admins make informed choices. Make it optional (nullable) for providers without pricing APIs.

**Q2**: How to handle new providers (e.g., Google Gemini variants, Mistral)?

**A**: Model discovery is provider-agnostic. Add new provider cases in `model_discovery.py` as needed. Pattern is extensible:
```python
if provider == "openai": fetch_openai_models()
elif provider == "anthropic": fetch_anthropic_models()
elif provider == "gemini": fetch_gemini_models()
```

**Q3**: Should we support custom provider URLs for model discovery?

**A**: No. Model discovery uses standard provider APIs. Custom base URLs are for completion endpoints, not model listing. If admin uses custom proxy, they must manually enter models.

**Q4**: Cache invalidation strategy for model lists?

**A**: 1-hour TTL is sufficient. Admins can manually refresh if needed. Consider adding "Refresh Models" button in UI that forces cache bypass (query param: `?refresh=true`).
