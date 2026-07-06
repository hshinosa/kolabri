## ADDED Requirements

### Requirement: Analytics response caching
AI Engine analytics endpoints SHALL cache responses in Redis using RedisCache with a 300-second (5 minute) TTL.

#### Scenario: First analytics request populates cache
- **WHEN** an analytics API request arrives and no cached response exists in Redis
- **THEN** the service executes MongoDB aggregations, caches the result under an analytics-scoped key, and returns the result

#### Scenario: Subsequent analytics request served from Redis
- **WHEN** an analytics API request arrives within the 300s TTL window
- **THEN** the service returns the cached Redis response without executing MongoDB aggregations

#### Scenario: Redis cache entry expires after TTL
- **WHEN** a cached analytics response exceeds the 300s TTL
- **THEN** the next request executes fresh aggregations and repopulates the Redis cache

### Requirement: Analytics cache key scoping
Analytics cache keys SHALL be scoped by the query parameters and user context.

#### Scenario: Different parameters produce different cache entries
- **WHEN** two analytics requests have different query parameters (e.g., different date ranges)
- **THEN** each request has its own cache entry and does not return the other's cached data

#### Scenario: Same parameters reuse cache
- **WHEN** two analytics requests have identical query parameters and user context
- **THEN** the second request returns the cached response from the first
