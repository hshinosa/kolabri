# Specification: AI Provider Caching

## ADDED Requirements

### Requirement: Cache provider configuration
AI Engine SHALL cache fetched provider configuration in Redis with 5-minute TTL to minimize database load and ensure consistency across multiple AI Engine instances.

#### Scenario: Cache hit
- **WHEN** LLMService requests provider within 5 minutes of last fetch
- **THEN** system returns cached configuration from Redis without HTTP request

#### Scenario: Cache miss
- **WHEN** LLMService requests provider after 5-minute TTL expires
- **THEN** system fetches fresh configuration from Core API

#### Scenario: First request
- **WHEN** LLMService initializes for the first time
- **THEN** system fetches from Core API and stores in cache

### Requirement: Cache invalidation (Phase 2)
AI Engine SHALL support webhook-based cache invalidation for immediate configuration updates.

#### Scenario: Webhook invalidation (Phase 2)
- **WHEN** Core API sends webhook to `/internal/cache/invalidate-provider` after provider update
- **THEN** system clears cached provider configuration from Redis

#### Scenario: Next request after invalidation
- **WHEN** LLMService requests provider after webhook invalidation
- **THEN** system fetches fresh configuration from Core API

### Requirement: Cache key strategy
AI Engine SHALL use Redis shared cache for active provider configuration with key `kolabri:provider:active`.

#### Scenario: Single cache entry
- **WHEN** system caches provider configuration
- **THEN** cache uses Redis key `kolabri:provider:active` for all LLMService instances

#### Scenario: Cache shared across instances
- **WHEN** multiple AI Engine instances request provider
- **THEN** all instances share same cached configuration from Redis

### Requirement: Cache failure handling
AI Engine SHALL handle cache failures gracefully without blocking requests.

#### Scenario: Cache read error
- **WHEN** cache retrieval fails due to Redis connection error
- **THEN** system logs error and fetches directly from Core API

#### Scenario: Cache write error
- **WHEN** cache storage fails after successful fetch
- **THEN** system logs warning but continues with fetched configuration

### Requirement: Cache monitoring
AI Engine SHALL expose cache metrics for monitoring.

#### Scenario: Cache hit rate
- **WHEN** system receives health check request
- **THEN** response includes cache hit rate percentage

#### Scenario: Cache age
- **WHEN** monitoring queries cache status
- **THEN** system reports seconds since last cache refresh
