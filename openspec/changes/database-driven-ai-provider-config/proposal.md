## Why

AI Engine currently relies on environment variables (OPENAI_API_KEY, OPENAI_BASE_URL, OPENAI_MODEL) for provider configuration, while Core API already maintains provider configuration in the database (`ai_providers` table) with full admin management UI. This creates inconsistency: admins can update provider settings via UI, but AI Engine won't reflect changes until container restart. We need a single source of truth (database) with AI Engine fetching configuration dynamically.

## What Changes

- **AI Engine**: Add provider repository that fetches active provider config from Core API database
- **AI Engine**: Implement caching layer for provider config (5-minute TTL) to minimize database load
- **Core API**: Add internal endpoint `/internal/ai-provider/active` for AI Engine to fetch active provider
- **Core API**: Add authentication via `X-Internal-Secret` header using existing `CORE_API_SECRET`
- **Configuration**: Enable `UNIFIED_PROVIDER_ENABLED=true` flag in AI Engine
- **Docker Compose**: Remove provider-related env vars from AI Engine service (keep as optional fallback only)
- **Migration**: Support graceful degradation - fallback to env vars if database fetch fails

## Capabilities

### New Capabilities
- `ai-provider-fetch`: AI Engine fetches active provider configuration from Core API database via internal HTTP endpoint
- `ai-provider-caching`: AI Engine caches provider configuration with TTL to reduce database load and improve response time
- `internal-provider-endpoint`: Core API exposes internal-only endpoint for AI Engine to retrieve active provider configuration

### Modified Capabilities
<!-- No existing capabilities are being modified - this is a new feature -->

## Impact

### Affected Components
- **Kolabri-ai-engine**:
  - `app/services/repositories/` - New provider_repository.py
  - `app/services/llm.py` - Update to fetch provider from repository
  - `app/core/config.py` - Update UNIFIED_PROVIDER flags
  - `app/api/routes/` - Update all routes using LLMService

- **Kolabri-core-api**:
  - `src/routes/internal.routes.ts` - New internal endpoint
  - `src/controllers/internal.controller.ts` - New controller
  - `src/middleware/internal-auth.middleware.ts` - New authentication middleware
  - `src/app.ts` - Register internal routes

- **Infrastructure**:
  - `docker-compose.yml` - Update AI Engine env vars (make provider config optional)
  - Documentation - Update setup guides to reflect database-driven approach

### Breaking Changes
None - implementation maintains backward compatibility via fallback to env vars.

### Dependencies
- Requires `ai_providers` table already exists in Core API database (already present)
- Requires `CORE_API_SECRET` shared between services (already configured)
- Optional: `httpx` Python library for HTTP client (already installed in AI Engine)

### Rollout Strategy
Gradual migration with feature flag:
1. Implement fetch infrastructure (flag OFF)
2. Test in development environment
3. Enable flag `UNIFIED_PROVIDER_ENABLED=true`
4. Monitor for errors, keep env vars as emergency fallback
5. After stable period (1 week), deprecate env vars in documentation
