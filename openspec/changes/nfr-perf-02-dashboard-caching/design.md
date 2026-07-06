## Context

Kolabri has two separate cache implementations that are barely used. `SimpleCache` in `src/utils/cache.ts` provides in-memory caching with configurable TTL but only `course.service.ts` calls it. `RedisCache` in the AI Engine (`app/core/redis_cache.py`) has an `analytics: 300` TTL mapping defined, yet analytics route handlers skip the cache entirely and run raw MongoDB aggregations on every request.

The dashboard service (`dashboard.service.ts`) is the worst offender. Each request fires 14 parallel Prisma queries and fetches up to 5000 chat messages into Node.js memory for filtering. This makes dashboard TTI far exceed the 2s NFR target, especially under concurrent load.

## Goals / Non-Goals

**Goals:**
- Reduce dashboard API response time to meet TTI < 2s
- Reuse existing cache infrastructure (no new packages or services)
- Add event-driven cache invalidation so stale data windows are bounded
- Replace the 5000-message fetch with a single Prisma aggregation
- Add `Cache-Control` headers so CDNs and browsers can participate

**Non-Goals:**
- Full HTTP caching layer (Varnish, CDN config) beyond response headers
- Pre-aggregated materialized views or cron-based rollups (future work)
- Caching for non-dashboard, non-analytics endpoints
- Client-side caching or service worker strategies

## Decisions

### D1: SimpleCache for Dashboard, RedisCache for Analytics

**Choice**: Use `SimpleCache` (in-memory) for dashboard service, `RedisCache` (Redis) for AI Engine analytics.

**Rationale**: Dashboard data is user-scoped and changes frequently (messages, activity). A 30s in-memory TTL gives fast reads with bounded staleness. Analytics data is less volatile and already has a Redis TTL mapping (`analytics: 300`). Redis also allows cache sharing across AI Engine workers.

**Alternatives considered**:
- Redis for dashboard: Adds network hop per request. Overkill for 30s TTL on user-scoped data.
- No caching, just query optimization: Helps but alone won't meet 2s TTI under load.

### D2: 30s TTL for Dashboard, 300s TTL for Analytics

**Choice**: Dashboard cache TTL = 30s, Analytics cache TTL = 300s (5min).

**Rationale**: Dashboard shows near-real-time activity (messages, progress). 30s is a reasonable staleness window that users won't notice. Analytics data (aggregated stats, trends) changes slowly, so 5min is safe and matches the existing `redis_cache.py` config.

### D3: Event-Driven Invalidation over TTL-Only

**Choice**: Invalidate cache on `send_message`, `user_joined`, `user_left` events in addition to TTL expiry.

**Rationale**: A user sending a message expects it to appear immediately. TTL-only would mean up to 30s of stale dashboard data after a user action. Event-driven invalidation clears the specific user's cache key so the next request fetches fresh data.

**Alternatives considered**:
- Write-through cache (update cache on mutation): More complex, risk of cache/db inconsistency.
- Shorter TTL (5s): More DB load, diminishing returns.

### D4: Prisma Aggregation Replacing Bulk Fetch

**Choice**: Replace `prisma.message.findMany({ take: 5000 })` with a targeted Prisma aggregation using `groupBy` and `count`.

**Rationale**: The current approach loads up to 5000 rows into Node.js memory for filtering that the DB can do natively. A Prisma aggregation pushes the computation to PostgreSQL, reducing memory usage and query time.

**Alternatives considered**:
- Raw SQL query: Faster but loses type safety and Prisma schema alignment.
- Cursor-based pagination: Doesn't solve the aggregation need.

## Risks / Trade-offs

- **Stale data window**: Up to 30s for dashboard, 5min for analytics between invalidation events. → Acceptable per NFR. Users can manually refresh.
- **Memory pressure from SimpleCache**: In-memory cache grows with concurrent users. → SimpleCache already has a max-entries cap. 30s TTL keeps entries short-lived.
- **Cache invalidation misses**: If new mutation paths are added without invalidation hooks, stale data persists until TTL. → Document the invalidation contract. Add integration test that verifies invalidation on known events.
- **Prisma aggregation compatibility**: `groupBy` has limitations on complex queries. → Validate the aggregation query against the actual schema before implementation. Fall back to a raw SQL query if needed.
