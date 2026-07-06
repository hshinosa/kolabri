## Why

Core-API currently contains direct LLM adapters (OpenAI, Anthropic, Gemini SDKs) used solely for admin provider testing. This violates architectural boundaries where core-api should orchestrate while ai-engine handles all AI/ML work. Additionally, admins must manually type model names when configuring providers, leading to typos and poor UX. This change eliminates architectural debt and improves admin experience by delegating testing to ai-engine and auto-fetching available models.

## What Changes

- **NEW**: AI-Engine admin testing endpoint - `POST /admin/test-provider` accepts provider config and test prompt, returns success/failure
- **NEW**: AI-Engine model discovery endpoint - `GET /admin/providers/{provider}/models` fetches available models from provider API
- **REMOVE**: Direct LLM adapters from core-api (`ai.service.ts`, `ai-providers/openai-adapter.ts`, `ai-providers/anthropic-adapter.ts`, `ai-providers/gemini-adapter.ts`, `ai-providers/base-adapter.ts`)
- **MODIFY**: `ai-provider.service.ts` to delegate testing to ai-engine instead of local adapters
- **MODIFY**: Admin UI to fetch and display available models in dropdown instead of free-text input
- **DOCUMENT**: Best practices for provider configuration - what belongs in environment variables (shared defaults) vs database (per-provider overrides)

## Capabilities

### New Capabilities

- `admin-provider-testing`: Admin can test AI provider connections (API key validation, connectivity check, latency measurement) via ai-engine endpoint. Testing works even if ai-engine is healthy - removes chicken-and-egg problem by making ai-engine robust enough to test new providers.

- `admin-model-discovery`: Admin can fetch available models from provider APIs (OpenAI models list, Anthropic models, Gemini models) automatically instead of manual typing. Models displayed in dropdown for selection. Reduces configuration errors and improves UX.

### Modified Capabilities

<!-- No existing capabilities require spec-level requirement changes. This is a refactor of implementation, not behavior change. -->

## Impact

**Kolabri-core-api**:
- DELETE: `src/services/ai.service.ts` (294 lines) - LLM orchestration logic
- DELETE: `src/services/ai-providers/` directory (4 adapter files, ~154 lines total)
- MODIFY: `src/services/ai-provider.service.ts` - `testConnection()` method delegates to ai-engine
- MODIFY: `src/services/ai-provider.service.ts` - Add `getAvailableModels()` method calling ai-engine
- MODIFY: `src/controllers/ai-provider.controller.ts` - Add `GET /ai-providers/:id/models` route

**Kolabri-ai-engine**:
- CREATE: `app/api/routes/admin.py` - New admin routes module
- CREATE: `app/services/admin_provider_test.py` - Provider testing service
- CREATE: `app/services/model_discovery.py` - Model fetching service (calls OpenAI, Anthropic, Gemini APIs)
- ADD: Dependencies to `requirements.txt` if needed (likely already have SDK imports)

**Kolabri-client-app** (Admin UI):
- MODIFY: `resources/js/pages/admin/ai-providers/edit.tsx` - Replace model text input with dropdown
- ADD: Model fetching on provider selection change
- ADD: Loading state while fetching models
- MODIFY: Form validation to use selected model from dropdown

**Configuration Documentation**:
- CREATE: `docs/AI_PROVIDER_CONFIG_GUIDE.md` - Explains env vs DB separation (baseURL, apiKey, model patterns)

**Dependencies**:
- No new external dependencies (ai-engine already has OpenAI, Anthropic SDKs)
- Core-API removes OpenAI/Anthropic SDK dependencies from `package.json`

**Migration Path**:
- Existing provider configurations work unchanged (backward compatible)
- Admin re-tests providers after deployment to verify ai-engine delegation works
- No database migration needed
