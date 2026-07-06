# Design: Make Rate Limiter Truly Lazy

## Overview
Remove the module-level execution of `_init_rate_limiter()` and move the initialization into the FastAPI lifespan handler.

## Current State (Problematic)
```python
# main.py
limiter = _init_rate_limiter()   # ← Executes on every import
```

## Proposed Design

### 1. Remove Top-Level Call
Delete the line:
```python
limiter = _init_rate_limiter()
```

### 2. Add Lifespan Handler
Use FastAPI's lifespan context manager to initialize the limiter when the application starts:

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    global limiter
    limiter = _init_rate_limiter()
    yield
    # Shutdown (optional cleanup)

app = FastAPI(lifespan=lifespan)
```

### 3. Keep the Function
The `_init_rate_limiter()` function remains unchanged and is only called when the app actually starts.

## Runtime Considerations
- **Before lifespan runs**: `limiter` will be `None` (or undefined). No middleware or route should access it during import or before the app starts.
- **Failure during startup**: If `_init_rate_limiter()` raises an exception during lifespan, the application will fail to start (fail-fast). The existing fallback logic inside the function is still preserved.
- **Pre-start access**: There is currently no code path that accesses `limiter` before the lifespan handler runs.

## Benefits
- `import main` becomes completely free of side effects.
- Application startup is the only place where Redis connection is attempted.
- Easier to test and import in isolation.

## Files Changed
- `main.py`
- `tests/test_unit/test_import_main.py` (no logic change needed, just re-verify)

## Risks
- None significant. The behavior at runtime remains identical; only the timing of initialization changes.
