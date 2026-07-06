## ADDED Requirements

### Requirement: Message count aggregation via database
Dashboard service SHALL use a Prisma aggregation query instead of bulk message fetching to compute message counts.

#### Scenario: Message count fetched via aggregation
- **WHEN** dashboard service needs message count for a user
- **THEN** the service uses Prisma `groupBy` or `count` aggregation to compute the count in the database
- **THEN** the service does NOT fetch individual message rows into application memory

#### Scenario: Aggregation returns correct count
- **WHEN** a user has N messages in the database
- **THEN** the aggregation query returns N as the count

### Requirement: Eliminate bulk message fetch
Dashboard service SHALL NOT fetch more than 100 message rows for any single dashboard request.

#### Scenario: No 5000-row fetch
- **WHEN** dashboard service processes a request
- **THEN** no query fetches more than 100 message rows from the database

#### Scenario: Recent messages limited
- **WHEN** dashboard service needs recent messages for display
- **THEN** the query is limited to at most 50 rows with appropriate ordering
