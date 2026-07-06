## Context

Audit identified critical security vulnerabilities and code quality issues:
- **Core API**: TypeScript build failures (import paths, type mismatches), direct `req.body` access without validation
- **Client App**: XSS risk via `dangerouslySetInnerHTML` without sanitization
- **System-wide**: Inconsistent error handling, missing boundary validation, type safety leaks

Current state:
- Zod schemas exist but not enforced consistently
- No HTML sanitization layer
- Controllers access request bodies directly
- Error handling patterns vary across controllers
- TypeScript strict mode not fully leveraged

Constraints:
- Must maintain backward compatibility with existing API contracts
- Cannot break existing client integrations
- Must complete before production release

## Goals / Non-Goals

**Goals:**
- Zero TypeScript compilation errors in Core API
- All API endpoints validate input via Zod schemas
- All user-generated HTML sanitized before rendering
- Consistent error handling with proper logging
- Boundary validation for pagination, uploads, arrays
- End-to-end type safety from schema → controller → service

**Non-Goals:**
- Refactoring existing business logic
- Performance optimization (separate effort)
- Adding new features
- Changing API response formats (except error responses)

## Decisions

### Decision 1: Use Zod for all input validation
**Rationale:** Already in use, provides type inference, composable schemas
**Alternatives considered:**
- Joi: Less TypeScript integration
- class-validator: Requires decorators, more boilerplate
**Implementation:** Create validation middleware that wraps Zod schemas, apply to all routes

### Decision 2: Use DOMPurify for HTML sanitization
**Rationale:** Industry standard, actively maintained, configurable
**Alternatives considered:**
- sanitize-html: Less feature-complete
- Custom regex: Error-prone, incomplete
**Implementation:** Create sanitization utility, apply before all `dangerouslySetInnerHTML` usage

### Decision 3: Standardize error response format
**Rationale:** Consistent client error handling, better debugging
**Format:**
```typescript
{
  status: number,
  message: string,
  errors?: Array<{ field: string, message: string }>, // validation errors
  requestId?: string // for server errors
}
```
**Implementation:** Create error middleware, wrap all controllers

### Decision 4: Fix TypeScript errors at source
**Rationale:** Type safety prevents runtime errors, improves maintainability
**Approach:**
- Fix import paths in `lecturer-ai.controller.ts`
- Add explicit return types to AI service methods
- Fix Zod transform type issues using `.pipe()` instead of `.transform()`
**No type assertions (`as any`) allowed except documented edge cases**

### Decision 5: Add boundary validation to schemas
**Rationale:** Prevent DoS, memory exhaustion, abuse
**Limits:**
- Pagination: max 100 items per page, default 20
- File uploads: max 10MB
- String fields: max 10000 chars (content), max 200 chars (titles)
- Arrays: max 1000 items
**Implementation:** Add constraints to Zod schemas

## Risks / Trade-offs

### Risk: Breaking changes to error responses
**Mitigation:**
- Maintain backward compatibility for success responses
- Only change error response format (clients should already handle errors generically)
- Document new error format in API docs

### Risk: Performance impact of validation/sanitization
**Mitigation:**
- Zod validation is fast (microseconds per request)
- DOMPurify runs client-side, no server impact
- Boundary checks prevent expensive operations (e.g., fetching 999999 items)
**Trade-off:** Slight latency increase acceptable for security

### Risk: TypeScript fixes may reveal hidden bugs
**Mitigation:**
- Fix types incrementally, test after each fix
- Run full test suite after type fixes
- Manual QA on affected endpoints

### Risk: Existing code may bypass new validation
**Mitigation:**
- Audit all controllers for direct `req.body` access
- Add ESLint rule to prevent future bypasses
- Code review checklist includes validation check

## Migration Plan

### Phase 1: Core API Type Safety (P0)
1. Fix TypeScript build errors in `lecturer-ai.controller.ts`
2. Add return types to AI service methods
3. Fix Zod schema transform issues
4. Verify build passes with zero errors

### Phase 2: Input Validation (P0)
1. Create validation middleware wrapper
2. Audit all controllers for direct `req.body` access
3. Add validation middleware to all routes
4. Update error response format
5. Test all endpoints with invalid input

### Phase 3: XSS Protection (P0)
1. Add DOMPurify dependency to client app
2. Create sanitization utility
3. Replace `dangerouslySetInnerHTML` in SearchResults.tsx
4. Audit other components for user-generated content
5. Test with malicious input

### Phase 4: Boundary Validation (P1)
1. Add boundary constraints to Zod schemas
2. Test pagination limits
3. Test file upload limits
4. Test string/array limits

### Phase 5: Error Handling (P1)
1. Create error middleware
2. Wrap all controllers in try-catch
3. Standardize error logging
4. Test error scenarios

### Rollback Strategy
- All changes are additive (validation, sanitization layers)
- Can disable validation middleware per-route if issues found
- TypeScript fixes are safe (compile-time only)
- No database migrations required

### Testing
- Unit tests for validation schemas
- Integration tests for error responses
- Security tests for XSS/injection attempts
- Manual QA on all affected endpoints

## Open Questions

None - design is complete and ready for implementation.
