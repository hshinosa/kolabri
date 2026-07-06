## 1. Dashboard Service Caching

- [x] 1.1 Import SimpleCache into dashboard.service.ts and wrap the main dashboard query method with cache get/set using user-scoped key (e.g., `dashboard:{userId}`)
- [x] 1.2 Set cache TTL to 30 seconds on the SimpleCache instance used by dashboard service
- [x] 1.3 Add Cache-Control header (`private, max-age=30`) to dashboard API route response

## 2. Dashboard Query Optimization

- [x] 2.1 Identify the 5000-message fetch in dashboard.service.ts and replace with a Prisma `count()` or `groupBy()` aggregation query
- [x] 2.2 Limit any remaining message list queries to max 50 rows with `orderBy: { createdAt: 'desc' }` and `take: 50`
- [x] 2.3 Verify dashboard response payload is unchanged after query optimization (run existing tests)

## 3. Cache Invalidation Hooks

- [x] 3.1 Add cache invalidation call in the send_message handler to clear `dashboard:{userId}` for the message sender
- [x] 3.2 Add cache invalidation in user join/leave group handlers to clear the affected user's dashboard cache
- [x] 3.3 Add cache invalidation in reflection submission handler to clear the submitting user's dashboard cache
- [x] 3.4 Write integration test verifying cache is cleared after each invalidation event

## 4. AI Engine Analytics Caching

- [x] 4.1 Import RedisCache into analytics route handlers in the AI Engine
- [x] 4.2 Wrap each analytics endpoint with RedisCache get/set using a key scoped by query parameters and user context
- [x] 4.3 Set analytics cache TTL to 300 seconds (matching existing `analytics: 300` config in redis_cache.py)
- [x] 4.4 Verify analytics response payload is unchanged after caching (run existing AI Engine tests)

## 5. Verification

- [x] 5.1 Benchmark dashboard API response time before and after changes, confirm TTI < 2s
- [x] 5.2 Verify dashboard returns fresh data within one request after invalidation events
- [x] 5.3 Verify analytics endpoints return cached data on repeated identical requests
- [x] 5.4 Run full test suite to confirm no regressions
