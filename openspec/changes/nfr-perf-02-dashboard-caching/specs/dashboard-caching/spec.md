## ADDED Requirements

### Requirement: Dashboard response caching
Dashboard service SHALL cache API responses in-memory using SimpleCache with a 30-second TTL.

#### Scenario: First request populates cache
- **WHEN** a dashboard API request arrives and no cached response exists
- **THEN** the service executes queries, caches the response under a user-scoped key, and returns the result

#### Scenario: Subsequent request served from cache
- **WHEN** a dashboard API request arrives within the 30s TTL window
- **THEN** the service returns the cached response without executing database queries

#### Scenario: Cache entry expires after TTL
- **WHEN** a cached dashboard response exceeds the 30s TTL
- **THEN** the next request executes fresh queries and repopulates the cache

### Requirement: Event-driven cache invalidation
Dashboard cache SHALL be invalidated on specific user actions to reduce staleness.

#### Scenario: Cache invalidated on message send
- **WHEN** a user sends a message via send_message
- **THEN** the dashboard cache entry for that user is cleared

#### Scenario: Cache invalidated on group membership change
- **WHEN** a user joins or leaves a group
- **THEN** the dashboard cache entry for that user is cleared

#### Scenario: Cache invalidated on new reflection submission
- **WHEN** a user submits a reflection
- **THEN** the dashboard cache entry for that user is cleared

### Requirement: Cache-Control response headers
Cached dashboard endpoints SHALL include Cache-Control headers.

#### Scenario: Cache-Control header set on cached response
- **WHEN** a dashboard API response is served from cache
- **THEN** the response includes `Cache-Control: private, max-age=30`

#### Scenario: Cache-Control header set on fresh response
- **WHEN** a dashboard API response is computed fresh (cache miss)
- **THEN** the response includes `Cache-Control: private, max-age=30`
