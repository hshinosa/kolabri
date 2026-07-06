## Why

Dashboard and analytics endpoints have zero caching despite cache infrastructure already existing in the codebase. `SimpleCache` (in-memory, 5min TTL) sits unused in `src/utils/cache.ts`, and `RedisCache` in the AI Engine has an `analytics: 300` TTL defined but analytics routes bypass it entirely. Every dashboard request triggers 14 parallel Prisma queries plus a 5000-message fetch for in-memory filtering, making the TTI far exceed the NFR target of < 2s.

## What Changes

- Wire `SimpleCache` into `dashboard.service.ts` with 30s TTL and event-driven invalidation
- Wire `RedisCache` into AI Engine analytics routes with 5min TTL
- Replace the 5000-message fetch in dashboard with a Prisma aggregation query
- Add cache invalidation hooks triggered by `send_message`, user join/leave events
- Add `Cache-Control` response headers for cached endpoints

## Capabilities

### New Capabilities
- `dashboard-caching`: In-memory caching layer for dashboard service with TTL and event-based invalidation
- `analytics-caching`: Redis-backed caching for AI Engine analytics endpoints with TTL
- `dashboard-query-optimization`: Replace bulk message fetch with DB-level aggregation

### Modified Capabilities
- `dashboard`: Performance requirement now mandates server-side caching and query optimization to meet TTI < 2s

## Impact

- **Backend (Next.js API)**: `dashboard.service.ts`, `src/utils/cache.ts`, cache invalidation middleware
- **AI Engine (Python)**: `app/core/redis_cache.py`, analytics route handlers
- **API contracts**: No breaking changes. Response payloads unchanged. Added `Cache-Control` headers.
- **Dependencies**: No new packages. Uses existing `SimpleCache` and `RedisCache`.
- **Infrastructure**: Redis already deployed for AI Engine. No new infra needed.
