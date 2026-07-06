# Design: Fix Redis Exception Handling at Import Time

## Overview
Move rate limiter initialization out of module-level code into a lazy function. Use the stable base exception class `redis.exceptions.RedisError` instead of specific subclasses.

## Architecture Changes

### Before (Problematic)
```python
# main.py
try:
    redis_client = redis.Redis(...)
    redis_client.ping()
    limiter = Limiter(..., storage_uri=...)
except (redis.ConnectionError, redis.TimeoutError) as e:
    limiter = Limiter(key_func=get_remote_address)
```

### After (Recommended)
```python
# main.py
from redis.exceptions import RedisError

def _init_rate_limiter() -> Limiter:
    try:
        client = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            db=settings.REDIS_DB,
        )
        client.ping()
        return Limiter(
            key_func=get_remote_address,
            storage_uri=f"redis://{settings.REDIS_HOST}:{settings.REDIS_PORT}/{settings.REDIS_DB}",
        )
    except RedisError as e:
        logger.warning(f"Redis unavailable, using in-memory rate limiter: {e}")
        return Limiter(key_func=get_remote_address)

# Called lazily inside lifespan or on first request
limiter = None  # Will be initialized on first use
```

## Key Design Decisions

1. **Lazy Initialization**
   - Rate limiter is no longer created at import time.
   - Initialization happens inside FastAPI lifespan event or on first request that needs rate limiting.

2. **Broader Exception Handling**
   - Catch `redis.exceptions.RedisError` (base class) instead of `ConnectionError` + `TimeoutError`.
   - This avoids the import-time TypeError entirely.

3. **Graceful Degradation**
   - When Redis is unavailable, fall back to SlowAPI's default in-memory storage.
   - No application crash or failed import.

4. **Testability**
   - `main.py` can now be imported cleanly in test environments without requiring a running Redis instance.

## Files Changed
- `main.py` — Refactor rate limiter initialization
- `tests/test_unit/test_import_main.py` — New regression test
- `tests/test_blackbox/conftest.py` — Ensure test isolation (optional minor change)

## Risks & Mitigations
- **Risk**: Slight delay on first request that triggers rate limiting.
  - **Mitigation**: Initialization is cheap (single ping) and can be warmed up in lifespan.
- **Risk**: In-memory limiter loses state across restarts.
  - **Mitigation**: Acceptable for development and acceptable degradation in production when Redis is down.

## Alternatives Considered
- Using `try: from redis.exceptions import RedisError except ImportError: RedisError = Exception` — rejected because it hides real import errors.
- Keeping module-level initialization but wrapping in a function that is called later — chosen approach.

## Diagram
```
Import main.py
    │
    ▼
No more risky except clause at module level
    │
    ▼
FastAPI lifespan (or first request)
    │
    ▼
_init_rate_limiter()
    ├── Redis available → Redis-backed Limiter
    └── Redis unavailable → In-memory Limiter (fallback)
```
