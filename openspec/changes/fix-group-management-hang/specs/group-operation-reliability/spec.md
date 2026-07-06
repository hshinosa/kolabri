## ADDED Requirements

### Requirement: Database Connection Pool Configuration
The Core API MUST configure Prisma with explicit connection pool parameters to prevent pool exhaustion under concurrent group operations.

#### Scenario: Production DATABASE_URL includes pool parameters
- **WHEN** the Core API starts in production environment
- **THEN** the DATABASE_URL MUST include `connection_limit=20&pool_timeout=20&connect_timeout=10` parameters
- **AND** Prisma MUST enforce a maximum of 20 concurrent database connections

#### Scenario: Connection wait timeout
- **WHEN** all 20 connections are in use and a new query is requested
- **THEN** the query MUST wait up to 20 seconds for an available connection
- **AND** if no connection becomes available within 20 seconds, the query MUST fail with a timeout error
- **AND** the error MUST be returned to the client (not hang indefinitely)

### Requirement: Group Operation HTTP Timeout
The system MUST complete or fail group management operations within defined time bounds.

#### Scenario: Create group request timeout
- **WHEN** a lecturer submits a group creation request
- **THEN** the HTTP request MUST timeout after 30 seconds if no response is received
- **AND** the lecturer MUST receive an error response (not hang indefinitely)

#### Scenario: Add members request timeout
- **WHEN** a lecturer assigns students to an existing group
- **THEN** the HTTP request MUST timeout after 30 seconds if no response is received
- **AND** the lecturer MUST receive an error response (not hang indefinitely)

#### Scenario: Inertia form state cleanup on failure
- **WHEN** any group operation fails or times out
- **THEN** the Inertia form processing state MUST be cleared
- **AND** the lecturer MUST be able to retry immediately

### Requirement: Error Messages
When group operations fail, the system MUST provide clear error feedback to the lecturer.

#### Scenario: Timeout or connection error
- **WHEN** a group operation fails due to timeout or connection issues
- **THEN** the lecturer MUST see a user-friendly error message
- **AND** the message SHOULD indicate the operation can be retried
