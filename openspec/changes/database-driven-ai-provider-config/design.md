## Context

AI Engine currently relies on environment variables (`OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_MODEL`) for provider configuration. While Core API already maintains provider configuration in the database (`ai_providers` table) with a full admin management UI, AI Engine does not dynamically fetch these settings. This creates a configuration mismatch where UI updates are not reflected in AI Engine without container restarts.

## Goals / Non-Goals

**Goals:**
- Establish Core API as the single source of truth for AI provider configuration.
- Implement dynamic fetching of provider settings in AI Engine.
- Ensure high availability through graceful fallback to environment variables.
- Minimize database load via caching.

**Non-Goals:**
- Full removal of environment variables (retained for bootstrap/emergency fallback).
- Real-time configuration synchronization (5-minute cache TTL is sufficient).
- Multi-provider load balancing (scope for future iteration).

## Decisions

| Decision | Choice | Rationale |
| :--- | :--- | :--- |
| **Architecture** | Pull (AI Engine fetches) | AI Engine retains autonomy; simpler coordination than Core API pushing updates. |
| **Transport** | HTTP REST | Simple, leverages existing `httpx` client in AI Engine. |
| **Caching** | Redis with 5m TTL | Distributed cache, consistent across multiple AI Engine instances. |
| **Response Transform** | Transform in AI Engine | Provider repository transforms Core API response to `{auth, execution}` format expected by LLMService. |
| **Authentication** | Shared Secret (`X-Internal-Secret`) | Simple, secure enough for internal service-to-service communication. |
| **Fallback** | Graceful Degradation | Ensures AI Engine remains functional if Core API is temporarily unavailable. |
| **Rollout** | Global Feature Flag | Simplifies initial deployment; allows granular control later. |

## Risks / Trade-offs

- **Network Latency**: Fetching config on every request is too slow.
  - *Mitigation*: Implement 5-minute TTL Redis cache.
- **Cache Staleness**: Provider updates in UI won't reflect immediately (5-minute delay).
  - *Mitigation*: Immediate invalidation via webhook in Phase 2. For Phase 1, 5-minute TTL is acceptable.
- **Service Coupling**: AI Engine depends on Core API availability.
  - *Mitigation*: Graceful fallback to environment variables.
- **Secret Exposure**: API keys in transit.
  - *Mitigation*: Enforce HTTPS in production; sanitize logs.

## Migration Plan

1. **Phase 1 (Implementation)**: Add repository and internal endpoint. Keep `UNIFIED_PROVIDER_ENABLED=false`.
2. **Phase 2 (Testing)**: Enable flag in development, verify database fetch and fallback behavior.
3. **Phase 3 (Deployment)**: Enable flag in production, monitor for errors.
4. **Rollback**: If issues arise, set `UNIFIED_PROVIDER_ENABLED=false` and restart services.

## Future Enhancements (Phase 2+)

- **Webhook for immediate cache invalidation**: Core API sends webhook to AI Engine on provider update to clear cache immediately (instead of waiting 5 minutes).
- **Granular cache metrics**: Expose cache hit rate, miss rate, and latency metrics for monitoring.
- **Auto-failover**: Support multiple active providers with automatic failover on error.
