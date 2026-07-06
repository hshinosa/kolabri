## Why

Group creation and member assignment operations hang indefinitely on VPS production, preventing lecturers from organizing students into collaborative learning groups. Investigation revealed Prisma connection pool exhaustion, missing query timeouts, and insufficient HTTP timeouts causing operations to never complete or fail gracefully.

## What Changes

- Add Prisma connection pool configuration parameters to DATABASE_URL (pool size, connection timeout, query timeout)
- Increase HTTP client timeout for group operations from 10s to 30s in Laravel GroupController
- Add explicit error handling with user-friendly messages for timeout scenarios


## Capabilities

### New Capabilities

- `group-operation-reliability`: Defines timeout requirements, connection pool sizing, and error handling behavior for group management operations to ensure they complete or fail gracefully within defined time bounds

### Modified Capabilities

<!-- No existing spec requirements are changing - this introduces new non-functional requirements -->

## Impact

**Affected Code:**
- `Kolabri-core-api/.env.production` - DATABASE_URL connection parameters
- `Kolabri-client-app/app/Http/Controllers/GroupController.php` - HTTP timeout configuration for `store()` and `addMembers()` methods

**Affected APIs:**
- `POST /api/courses/{courseId}/groups` - Create group (internal)
- `POST /api/courses/{courseId}/groups/{groupId}/members` - Add members (internal)

**Dependencies:**
- Prisma ORM connection pool configuration
- Laravel HTTP client timeout behavior
- PostgreSQL connection handling

**Systems:**
- Production VPS environment (primary fix target)
- Local development environment (compatibility required)
- All environments benefit from improved reliability
