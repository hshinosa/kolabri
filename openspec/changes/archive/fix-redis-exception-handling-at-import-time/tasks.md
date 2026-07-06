# Tasks: Fix Redis Exception Handling at Import Time

## Implementation Tasks

### 1. Refactor Rate Limiter Initialization
- [ ] Create function `_init_rate_limiter()` in `main.py`
- [ ] Replace the module-level `try/except` block with lazy initialization
- [ ] Use `redis.exceptions.RedisError` as the caught exception
- [ ] Ensure `limiter` is initialized inside FastAPI lifespan event

### 2. Add Regression Test for Import Safety
- [ ] Create new test file: `tests/test_unit/test_import_main.py`
- [ ] The test must reproduce the previous failure mode (attempting `import main` during collection/import without a running Redis instance)
- [ ] Assert that the import now succeeds cleanly without raising `TypeError`

### 3. Update Black-box Test Configuration (if needed)
- [ ] Review `tests/test_blackbox/conftest.py`
- [ ] Ensure Redis mock (if any) is set up before `from main import app`
- [ ] Add comment explaining why import must succeed without Redis

### 4. Verification & Quality
- [ ] Run `pytest tests/test_unit/test_import_main.py -q`
- [ ] Run full test suite: `pytest tests/ -q --tb=no`
- [ ] Specifically run black-box tests: `pytest tests/test_blackbox/ -q --tb=no`
- [ ] Verify no `TypeError` appears during collection or execution
- [ ] Manually test startup with Redis stopped (should use in-memory limiter)

### 5. Documentation (Optional but Recommended)
- [ ] Add short comment in `main.py` explaining the lazy initialization pattern
- [ ] Update `.env.example` if any new environment variable is introduced (none expected)

## Acceptance Criteria
- `import main` succeeds in an environment without Redis.
- All existing tests continue to pass.
- New regression test is added and passes.
- Application gracefully falls back to in-memory rate limiting when Redis is unavailable.

## Estimated Effort
- Small (1–2 hours)

## Dependencies
- None (pure refactoring + test addition)
