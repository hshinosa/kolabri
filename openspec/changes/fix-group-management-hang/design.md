## Context

Kolabri uses a 3-tier architecture: Laravel client-app → Core-API (Node/Prisma) → PostgreSQL. Group management operations (`POST /api/courses/:id/groups` and `POST /api/courses/:id/groups/:groupId/members`) flow through this chain. On VPS production, these operations hang indefinitely — the request never returns success or error, leaving the Inertia form stuck in `processing: true` state.

**Current state:**
- `Controller.php` `apiRequest()` default: 10s request timeout, 5s connect timeout
- Prisma `DATABASE_URL`: no connection pool parameters (defaults: 10 connections, no query timeout, no pool timeout)
- Failures are silent — user sees stuck UI with no error feedback

**Root cause chain:**
1. Multiple concurrent group operations exhaust the 10-connection Prisma pool
2. New queries wait indefinitely for an available connection (no `pool_timeout` → infinite wait)
3. If a query does start, it can run slowly (no `connect_timeout`, no `statement_timeout`)
4. Laravel HTTP client hits 10s timeout, but Inertia `processing` state isn't properly cleared on timeout errors
5. User sees stuck UI with no error feedback

## Goals / Non-Goals

**Goals:**
- Group creation completes or fails within a defined time bound (not hangs)
- Member assignment completes or fails within a defined time bound (not hangs)
- Clear error messages shown to lecturer when operations timeout or fail
- Fix works on production VPS without breaking local development

**Non-Goals:**
- Redesigning the group management API or business logic
- Adding retry logic (user should retry manually)
- Implementing async/background processing for group operations
- Changing Prisma connection pooling strategy at the infrastructure level (e.g., PgBouncer)
- Modifying the group management UI layout or components

## Decisions

### Decision 1: Prisma connection pool configuration via DATABASE_URL query params

**Choice:** Add `connection_limit=20&pool_timeout=20&connect_timeout=10` to DATABASE_URL

**Rationale:** Prisma supports these as URL parameters — no code changes needed in the Prisma client or service layer. Values chosen:
- `connection_limit=20`: Double the default (10) to handle concurrent group operations. Conservative — won't overwhelm PostgreSQL.
- `pool_timeout=20`: Max 20s to wait for an available connection. Prevents infinite wait while giving operations time to queue.
- `connect_timeout=10`: Max 10s to establish a new DB connection. Catches network issues quickly.

**Alternatives considered:**
- PgBouncer as connection pooler → better for high-scale but adds infrastructure complexity. Overkill for current load.
- Environment variable for pool size → more flexible but requires code changes in Prisma config. URL params are zero-code.
- `connection_limit=50` → too aggressive for current VPS resources (1 vCPU, 2GB RAM).

### Decision 2: HTTP timeout increase for group operations only

**Choice:** Override `apiRequest()` with `timeout: 30, connectTimeout: 10` for `store()` and `addMembers()` methods only.

**Rationale:** These operations are heavier than typical API calls (transaction + multiple queries + `getGroupById()` fetch). 30s gives enough headroom for production latency while still bounding the wait. Other operations keep the default 10s — they don't have the same pool contention issue.

**Alternatives considered:**
- Increase default timeout globally → bad — masks issues in other endpoints that should be fast.
- Keep 10s → too short for production under load, would cause false timeouts.
- 60s → too long — user already frustrated after 30s, better to show error and let them retry.

### Decision 3: Error handling strategy — catch and re-throw with clear message

**Choice:** Keep existing `ConnectionException | RequestException` catch pattern. Don't add retry logic.

**Rationale:** Retry logic for create/assign operations risks duplicate groups or duplicate memberships if the request actually succeeded server-side but timed out on the client. Better to fail clearly and let the lecturer retry manually.

**Alternatives considered:**
- Idempotency keys + auto-retry → requires server-side changes to Core-API, out of scope.
- Silent retry with exponential backoff → risk of duplicate data, confusing UX if first attempt eventually succeeds.

## Risks / Trade-offs

**[Risk] Pool size 20 still insufficient under high load** → Mitigation: If hangs persist, increase to 30 or introduce PgBouncer.

**[Risk] 30s timeout too short for very slow production DB** → Mitigation: If timeouts are frequent, investigate DB performance rather than increasing timeout.

**[Risk] Production-only DATABASE_URL change doesn't fix local dev** → Mitigation: Document the params in `.env.example` so developers can opt-in. Local typically has single-user load so pool exhaustion is unlikely.

**[Trade-off] No retry logic means user must manually retry** → Acceptable: Lecturer sees clear error message, can click again. Better than silent duplicate operations.

**[Trade-off] URL param configuration is less visible than code-level config** → Acceptable: Document in `.env.example` and this design doc. Prisma URL params are the standard way to configure pools.

## Migration Plan

1. Update `Kolabri-core-api/.env.production` DATABASE_URL with pool params
2. Update `Kolabri-client-app/app/Http/Controllers/GroupController.php` with timeout overrides
3. Restart core-api container (picks up new DATABASE_URL)
4. Rebuild + restart client-app container (picks up PHP changes)
5. Verify: Create group, assign members

**Rollback:** Revert DATABASE_URL to original (no pool params) and GroupController to default timeout. Restart containers.
