## 1. AI-Engine: Add Admin Routes Module

- [ ] 1.1 Create `app/api/routes/admin.py` with FastAPI router for admin endpoints
- [ ] 1.2 Add `/admin/test-provider` POST endpoint accepting `{name, apiKey, baseUrl, model, testPrompt}` and returning `{success, response, latencyMs, model, error?}`
- [ ] 1.3 Add `/admin/providers/{provider}/models` GET endpoint with optional `?refresh=true` query param
- [ ] 1.4 Register admin router in `app/api/__init__.py` or main app
- [ ] 1.5 Add admin route tests in `tests/test_admin_routes.py`

## 2. AI-Engine: Provider Testing Service

- [ ] 2.1 Create `app/services/admin_provider_test.py` with `test_provider(name, apiKey, baseUrl, model, testPrompt)` function
- [ ] 2.2 Implement OpenAI provider testing (instantiate client, send prompt, measure latency)
- [ ] 2.3 Implement Anthropic provider testing
- [ ] 2.4 Implement Gemini provider testing
- [ ] 2.5 Add error handling for invalid API keys, timeouts, network failures
- [ ] 2.6 Add unit tests in `tests/test_unit/test_admin_provider_test.py` with mocked provider APIs

## 3. AI-Engine: Model Discovery Service

- [ ] 3.1 Create `app/services/model_discovery.py` with `fetch_models(provider: str, force_refresh: bool)` function
- [ ] 3.2 Implement OpenAI model discovery (call `/v1/models` API, parse response)
- [ ] 3.3 Implement Anthropic model discovery (return hardcoded list: claude-3-opus, claude-3-sonnet, claude-3-haiku, claude-2.1)
- [ ] 3.4 Implement Gemini model discovery (call Google AI `/v1/models` API)
- [ ] 3.5 Add in-memory caching with 1-hour TTL (use `cachetools.TTLCache` or similar)
- [ ] 3.6 Return model metadata: `{id, name, description?, contextWindow?, inputCost?, outputCost?}`
- [ ] 3.7 Add unit tests with mocked provider APIs in `tests/test_unit/test_model_discovery.py`

## 4. AI-Engine: Deploy & Verify

- [ ] 4.1 Add environment variables if needed (AI_ENGINE_ADMIN_SECRET for admin endpoint auth)
- [ ] 4.2 Run full test suite: `pytest tests/` - verify all pass
- [ ] 4.3 Deploy to ai-engine (staging/dev environment first)
- [ ] 4.4 Manual test: `curl -X POST http://localhost:8001/admin/test-provider` with valid OpenAI key
- [ ] 4.5 Manual test: `curl http://localhost:8001/admin/providers/openai/models` - verify returns models
- [ ] 4.6 Check logs for errors or unexpected behavior

## 5. Core-API: Update AI Provider Service

- [ ] 5.1 Read `src/services/ai-provider.service.ts` - verify only `testConnection()` uses `ai.service.ts`
- [ ] 5.2 Update `testConnection()` method to call ai-engine `POST /admin/test-provider` via fetch/axios
- [ ] 5.3 Add error handling for ai-engine unavailable (return graceful error to admin)
- [ ] 5.4 Add `getAvailableModels(providerName: string)` method calling ai-engine `GET /admin/providers/{provider}/models`
- [ ] 5.5 Update `ai-provider.service.test.ts` - mock ai-engine endpoints instead of direct LLM calls
- [ ] 5.6 Verify tests pass: `npm test -- ai-provider.service.test.ts`

## 6. Core-API: Add Model Discovery Route

- [ ] 6.1 Add `GET /api/ai-providers/models` route in `src/routes/ai-provider.routes.ts`
- [ ] 6.2 Add `getProviderModels()` controller method in `src/controllers/ai-provider.controller.ts` (delegates to ai-provider.service)
- [ ] 6.3 Add query param validation: `provider` required, `refresh` optional boolean
- [ ] 6.4 Add route to router with admin authentication middleware
- [ ] 6.5 Add integration test in `src/controllers/ai-provider.controller.test.ts`

## 7. Core-API: Remove Direct LLM Logic

- [ ] 7.1 Grep for all imports of `ai.service.ts`: `grep -r "from './ai.service" src/` - verify only 1 file
- [ ] 7.2 Grep for all imports of `ai-providers/`: `grep -r "ai-providers" src/` - verify only used by `ai.service.ts`
- [ ] 7.3 Delete `src/services/ai.service.ts` (294 lines)
- [ ] 7.4 Delete `src/services/ai-providers/openai-adapter.ts`
- [ ] 7.5 Delete `src/services/ai-providers/anthropic-adapter.ts`
- [ ] 7.6 Delete `src/services/ai-providers/gemini-adapter.ts`
- [ ] 7.7 Delete `src/services/ai-providers/base-adapter.ts`
- [ ] 7.8 Remove `src/services/ai-providers/` directory if empty

## 8. Core-API: Update Dependencies

- [ ] 8.1 Remove `openai` package from `package.json` dependencies
- [ ] 8.2 Remove `@anthropic-ai/sdk` package from `package.json` dependencies
- [ ] 8.3 Remove `@google/generative-ai` or Gemini SDK if present
- [ ] 8.4 Run `npm install` to update lock file
- [ ] 8.5 Verify no import errors: `npx tsc --noEmit`

## 9. Core-API: Deploy & Verify

- [ ] 9.1 Run full test suite: `npm test` - verify all tests pass
- [ ] 9.2 Run linter: `npm run lint` - verify no errors
- [ ] 9.3 Deploy to core-api (staging/dev environment)
- [ ] 9.4 Manual test: Admin UI → AI Providers → Click "Test Connection" - verify works
- [ ] 9.5 Check network tab: Verify calls go to ai-engine, not direct LLM APIs
- [ ] 9.6 Check server logs: Verify no errors related to missing ai.service imports

## 10. Client-App: Update Admin Provider Form

- [ ] 10.1 Locate `resources/js/pages/admin/ai-providers/edit.tsx` (or similar path)
- [ ] 10.2 Replace model text input with `<Select>` component (react-select or similar)
- [ ] 10.3 Add `useEffect` to fetch models when provider changes: `GET /api/ai-providers/models?provider={name}`
- [ ] 10.4 Add loading state while fetching models (show spinner in dropdown)
- [ ] 10.5 Populate dropdown options from fetched models: `{value: model.id, label: model.name + context info}`
- [ ] 10.6 Add error handling: If fetch fails, show warning and fall back to text input
- [ ] 10.7 Add "Refresh Models" button that calls API with `?refresh=true` param

## 11. Client-App: Enhance Model Display

- [ ] 11.1 Format dropdown options to show model name and context window: `"GPT-4 Turbo (128k tokens)"`
- [ ] 11.2 Add tooltip showing pricing if available (hover over option shows cost per token)
- [ ] 11.3 Add search/filter capability in dropdown (react-select default behavior)
- [ ] 11.4 Update form validation: Model field required, must be from dropdown (or text input if fallback)
- [ ] 11.5 Test form submission: Verify selected model ID saves correctly to database

## 12. Client-App: Deploy & Verify

- [ ] 12.1 Build frontend: `npm run build` - verify no TypeScript errors
- [ ] 12.2 Deploy to client-app (staging/dev environment)
- [ ] 12.3 Manual test: Admin UI → AI Providers → Select "OpenAI" → Verify dropdown populates with models
- [ ] 12.4 Manual test: Select model from dropdown → Save → Verify model ID saved correctly
- [ ] 12.5 Manual test: Trigger error (disable ai-engine) → Verify fallback to text input works
- [ ] 12.6 Manual test: Click "Refresh Models" → Verify dropdown updates

## 13. Documentation

- [ ] 13.1 Create `docs/AI_PROVIDER_CONFIG_GUIDE.md` with env vs DB config patterns
- [ ] 13.2 Document baseURL usage: When to use env vars vs DB overrides
- [ ] 13.3 Document apiKey encryption: How keys are stored, encrypted, and retrieved
- [ ] 13.4 Document model selection: How model discovery works, cache TTL, fallback behavior
- [ ] 13.5 Add examples for each provider (OpenAI, Anthropic, Gemini) with screenshots or code snippets
- [ ] 13.6 Update main README.md or architecture docs to reference new guide

## 14. Integration Testing

- [ ] 14.1 End-to-end test: Configure new OpenAI provider via admin UI → Test connection → Verify success
- [ ] 14.2 End-to-end test: Select model from dropdown → Save → Use provider in production chat → Verify works
- [ ] 14.3 Test fallback: Kill ai-engine → Admin tries to test provider → Verify graceful error message
- [ ] 14.4 Test cache: Fetch models → Wait 1 hour → Fetch again → Verify cache refresh
- [ ] 14.5 Load test: Multiple admins fetching models simultaneously → Verify no rate limit errors (cache working)

## 15. Cleanup & Finalization

- [ ] 15.1 Search codebase for any remaining references to deleted files: `grep -r "ai-providers" .`
- [ ] 15.2 Remove orphaned test files related to deleted services
- [ ] 15.3 Update CHANGELOG.md with breaking changes and new features
- [ ] 15.4 Update openspec change status: Mark as complete
- [ ] 15.5 Create PR with all changes, link to openspec proposal for context
- [ ] 15.6 Request code review focusing on: Architecture cleanliness, error handling, admin UX
