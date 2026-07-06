## Why

The comprehensive security and quality audit identified 26 issues across the Kolabri platform. This change addresses the 10 most critical security and reliability gaps that must be fixed before production deployment. These issues represent immediate threats to data security (XSS token theft, SQL injection, RCE via file uploads), user privacy (unauthorized data access), and system reliability (silent failures, cascading errors). Fixing these now prevents security incidents, data breaches, and service degradation in production.

## What Changes

This change implements 10 critical and high-priority security and reliability fixes:

1. **Secure JWT Token Storage (C1)**: Migrate JWT authentication tokens from localStorage to httpOnly cookies to prevent XSS-based token theft
2. **WebSocket Error Handling (C4)**: Add comprehensive error logging and retry logic for AI intervention and activity tracking to prevent silent failures
3. **Search Hardening (H1)**: Add defense-in-depth BOOLEAN MODE operator sanitization and fix incorrect exception handling in message search (catch blocks catch wrong exception types, making FULLTEXT fallback dead code)
4. **Chat Authorization (H2)**: Add cross-conversation access validation for message operations (search, pin, unpin, delete) to prevent unauthorized message manipulation
5. **File Upload Hardening (H3)**: Verify and strengthen existing MIME type validation, reconcile whitelist with spec, ensure files stored in private disk and served through authenticated endpoints
6. **Reflection Privacy Verification (H4)**: Verify existing ownership validation is comprehensive across all reflection endpoints, add authorization logging for security monitoring
7. **File Batch Recovery (H5)**: Replace Promise.all with Promise.allSettled for partial success when batch uploading files
8. **Query Error Logging (H6)**: Add proper error logging and warning flags when resolveWeekLabelsByIds() fails
9. **Circuit Breaker Expansion (H7)**: Wrap discussion-direction service calls with existing circuit breaker utility (aiEngine.service.ts already uses it). Verify all AI Engine integration points are covered.
10. **Auth Secret Fix (H8)**: Correct environment variable reference from CORE_API_SECRET to AI_ENGINE_SECRET in discussion-direction service

All changes are non-breaking and maintain backward compatibility with existing API contracts.

## Capabilities

### New Capabilities

- `secure-token-storage`: httpOnly cookie-based JWT authentication to prevent XSS token theft
- `comprehensive-error-handling`: Error logging, retry logic, and user notifications for critical async operations
- `input-validation-security`: SQL injection prevention and MIME type validation for file uploads
- `authorization-checks`: Cross-resource access validation for chat messages and student reflections
- `service-resilience`: Circuit breaker patterns, error logging, and graceful degradation for external service calls

### Modified Capabilities

<!-- No existing capabilities are being modified - these are additions/fixes to current implementation -->

## Impact

**Services Affected**:
- Core-API (Node.js/TypeScript): 7 changes (WebSocket, chat auth via REST routes, reflection verification, file batch, query logging, circuit breaker expansion, auth secret)
- Client-App Backend (Laravel): 2 changes (search hardening, file upload verification)
- Client-App Frontend (React/TypeScript): 1 change (remove broken localStorage reads in export components)
- AI-Engine: Integration only (no code changes, receives better error handling from Core-API)

**Related Service-Specific Openspecs**:
- `Kolabri-client-app/openspec/changes/client-app-security-hardening/` — detailed C1 implementation for BFF architecture (localStorage removal, Laravel session, Socket.IO auth object)
- `Kolabri-client-app/openspec/changes/client-app-socket-resilience-and-perf/` — detailed C4 implementation for client-app (timer cleanup, token re-auth, error surfacing)
- `Kolabri-client-app/openspec/changes/client-app-api-reliability/` — M6 timeout/error standardization for Laravel controllers

**Code Areas**:
- Authentication flow: Remove broken localStorage reads in export components (CourseExportButton, DataExportButton)
- Chat message operations (REST): Authorization middleware additions for group membership validation (Mongoose/ChatLog)
- Message search: Defense-in-depth BOOLEAN MODE sanitization + fix incorrect exception types in catch blocks
- File upload controllers: Verify/strengthen MIME validation, ensure private disk storage
- WebSocket handlers: Error handling and retry logic for empty catch blocks
- Reflection endpoints: Verify existing ownership checks, add authorization logging
- Service integration layer: Expand circuit breaker to discussion-direction service
- Configuration: Environment variable corrections (discussion-direction)

**APIs**:
- All APIs maintain backward compatibility
- Response formats unchanged
- Only internal error handling and validation improved

**Dependencies**:
- No new external dependencies required
- Uses existing circuit breaker utility
- Uses existing error logging infrastructure

**Data/Database**:
- No schema changes required
- No migrations needed
- Pure logic and validation improvements

**Testing Scope**:
- Security: XSS prevention, SQL injection, file upload exploits
- Authorization: Cross-resource access attempts
- Reliability: Error scenarios, retry logic, circuit breaker behavior
- Integration: Token propagation, service communication under failure conditions
