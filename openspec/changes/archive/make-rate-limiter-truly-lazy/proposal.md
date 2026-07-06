# Proposal: Make Rate Limiter Truly Lazy

## Problem
After the previous refactor, the rate limiter initialization is still executed at module import time:

```python
# main.py:60
limiter = _init_rate_limiter()
```

Even though the logic is wrapped in a function, the **function call itself** happens at the top level of the module. This means every `import main` (including during pytest collection) will attempt a synchronous Redis connection (`client.ping()`).

This re-introduces the original class of problem we tried to solve.

## Root Cause
The initialization was moved into a function, but the call site was not moved out of module scope. The fundamental issue (performing I/O during import) remains.

## Impact
- `import main` is not safe in environments without Redis.
- Black-box tests and CI can still fail unpredictably.
- Violates the principle that importing a Python module should be side-effect free regarding external services.

## Proposed Solution
Remove the top-level call `limiter = _init_rate_limiter()`. Instead, initialize the limiter inside the FastAPI lifespan event so that it only runs when the application actually starts.

## Scope
- `main.py` (remove top-level initialization, add lifespan handler)
- `tests/test_unit/test_import_main.py` (verify it still passes after the change)

## Success Criteria
- `import main` succeeds instantly without any network call.
- Rate limiting still works correctly when the application is running.
- All existing tests continue to pass.
