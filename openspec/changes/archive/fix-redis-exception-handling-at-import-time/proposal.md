# Proposal: Fix Redis Exception Handling at Import Time

## Problem
When `main.py` is imported (for example during `pytest` collection in `tests/test_blackbox/conftest.py`), the following code at module level causes a `TypeError`:

```python
except (redis.ConnectionError, redis.TimeoutError) as e:
```

**Error message:**
```
TypeError: catching classes that do not inherit from BaseException is not allowed
```

### Root Cause
The root cause is a subtle exception class hierarchy issue. `redis.exceptions.TimeoutError` (and `redis.exceptions.ConnectionError`) are **not** the same as `builtins.TimeoutError` / `builtins.ConnectionError`. When Python evaluates the clause

```python
except (redis.ConnectionError, redis.TimeoutError) as e:
```

at **import time**, it fails with `TypeError: catching classes that do not inherit from BaseException is not allowed` under certain combinations of Python environment, `redis` 7.x, and pytest collection phase.

This is not a runtime Redis connectivity problem — it is an import-time failure that prevents the entire application from being loaded.

### Impact
- All black-box tests fail to even load (`test_blackbox/conftest.py` does `from main import app`).
- Production startup becomes unreliable when Redis is temporarily down.
- Violates the principle that importing a module should not execute risky side effects.

### Why This Matters
The current implementation mixes infrastructure initialization (Redis rate limiter) with module import, which is an anti-pattern. It also uses overly specific exception classes instead of the stable base class `redis.exceptions.RedisError`.

## Proposed Solution
Refactor the rate limiter initialization to be lazy and use defensive exception handling that does not depend on specific Redis exception subclasses at import time.

## Scope
- `main.py` (rate limiter initialization)
- `tests/test_unit/test_import_main.py` (new regression test)
- `tests/test_blackbox/conftest.py` (minor adjustment for test isolation)

## Non-Goals
- Changing the underlying rate limiting library (SlowAPI)
- Adding new rate limiting features

## Success Criteria
- `import main` succeeds even when Redis is unavailable.
- All existing tests continue to pass.
- New regression test verifies import-time safety.
