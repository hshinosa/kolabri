## Why

Audit identified critical security vulnerabilities (XSS, input validation bypass), TypeScript build failures in Core API, and code quality issues that block deployment and expose the application to security risks. These issues must be resolved before production release.

## What Changes

- Fix TypeScript build errors in Core API (import paths, type mismatches)
- Sanitize HTML content to prevent XSS attacks
- Add schema validation to all request body access points
- Implement boundary validation (pagination, file uploads, string lengths)
- Standardize error handling patterns across controllers
- Add null/undefined guards for optional fields
- Implement transaction handling for race-prone operations

## Capabilities

### New Capabilities
- `input-validation`: Comprehensive request validation using Zod schemas across all API endpoints
- `xss-protection`: HTML sanitization for user-generated content rendering
- `boundary-validation`: Limits enforcement for pagination, uploads, and data sizes
- `error-handling`: Standardized error handling patterns with proper logging and user feedback
- `type-safety`: End-to-end type safety from schema → controller → service

### Modified Capabilities
<!-- No existing capabilities being modified - these are new security/quality additions -->

## Impact

**Core API:**
- `src/controllers/lecturer-ai.controller.ts` - Fix import paths and type definitions
- `src/routes/lecturer-ai.routes.ts` - Fix Zod schema transform issues
- `src/controllers/*.controller.ts` - Add validation middleware to all endpoints
- `src/services/ai.service.ts` - Add proper return type definitions

**Client App:**
- `resources/js/pages/student/chat/room/components/SearchResults.tsx` - Replace dangerouslySetInnerHTML with sanitized rendering
- All components using user-generated content - Add sanitization layer

**Infrastructure:**
- Add DOMPurify dependency for client-side sanitization
- Add validation middleware layer in Core API
- Update error response format for consistency
