# Tasks: Make Rate Limiter Truly Lazy

## Implementation Tasks

### 1. Remove Top-Level Initialization
- [ ] Delete the line `limiter = _init_rate_limiter()` from `main.py`
- [ ] Declare `limiter: Optional[Limiter] = None` at module level (or keep it as a simple assignment inside lifespan)

### 2. Add FastAPI Lifespan Handler
- [ ] Import `asynccontextmanager` and `FastAPI` (if not already)
- [ ] Create an `asynccontextmanager` lifespan function
- [ ] Inside the lifespan, call `limiter = _init_rate_limiter()` during startup
- [ ] Pass the lifespan to `FastAPI(lifespan=...)`

### 3. Verification
- [ ] Run `pytest tests/test_unit/test_import_main.py -q` (must pass)
- [ ] Run relevant rate-limiting related tests (e.g., `test_efficiency*`, endpoint tests that use rate limits)
- [ ] Add or update a startup test that verifies `limiter` is not `None` after app startup (optional but recommended)

## Acceptance Criteria
- `import main` succeeds without any network I/O.
- When the application starts, the rate limiter is correctly initialized (Redis or fallback).
- All existing functionality remains unchanged.

## Estimated Effort
- Small (30–60 minutes)
