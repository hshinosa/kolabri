## 1. Core API Implementation

- [x] 1.1 Create internal authentication middleware (`src/middleware/internal-auth.middleware.ts`)
- [x] 1.2 Implement internal provider controller (`src/controllers/internal.controller.ts`)
- [x] 1.3 Register internal routes (`src/routes/internal.routes.ts`)
- [x] 1.4 Register internal routes in `src/app.ts`

## 2. AI Engine Implementation

- [x] 2.1 Implement provider repository with HTTP client (`app/services/repositories/provider_repository.py`)
- [x] 2.2 Implement Redis cache layer for provider config (5-minute TTL, key: `kolabri:provider:active`)
- [x] 2.3 Implement response transform: Core API format → `{auth, execution}` format
- [x] 2.4 Update `app/core/config.py` to include `UNIFIED_PROVIDER_ENABLED` flag
- [x] 2.5 Update `app/services/llm.py` to fetch provider config from repository on initialization
- [x] 2.6 Implement fallback to environment variables when fetch fails
- [x] 2.7 Update all route handlers to enable provider context when flag is true

## 3. Infrastructure & Configuration

- [x] 3.1 Update `docker-compose.yml` to set `UNIFIED_PROVIDER_ENABLED=false` (default)
- [x] 3.2 Update `Kolabri-ai-engine/.env.example` with new configuration keys
- [x] 3.3 Update documentation (README, setup guides)

## 4. Verification & Testing

- [ ] 4.1 Test internal endpoint with valid/invalid secrets (Core API)
- [ ] 4.2 Verify AI Engine fetches provider config correctly from Core API
- [ ] 4.3 Verify response transform (`{auth, execution}` format)
- [ ] 4.4 Verify Redis caching behavior (TTL 5min, cache hit/miss)
- [ ] 4.5 Verify fallback to environment variables when Core API is down
- [ ] 4.6 Test with multiple AI Engine instances (cache shared via Redis)
- [ ] 4.7 Enable `UNIFIED_PROVIDER_ENABLED=true` and test end-to-end in dev environment

## 5. Phase 2 Preparation (Not Implemented Yet)

- [x] 5.1 Document webhook invalidation design for Phase 2
- [x] 5.2 Add TODO comments for webhook endpoint in AI Engine
- [x] 5.3 Add TODO comments for webhook sender in Core API AiProviderService
