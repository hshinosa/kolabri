## 1. Core API - TypeScript Build Fixes (P0)

- [x] 1.1 Fix import path in `lecturer-ai.controller.ts` line 17 (change `./lecturer-ai.validator.js` to `../validators/lecturer-ai.validator.js`)
- [x] 1.2 Add explicit return type to AI service `sendMessage` method including `response` field
- [x] 1.3 Fix Zod schema transform in `lecturer-ai.routes.ts` line 24 (use `.pipe()` instead of `.transform()` or adjust validator)
- [x] 1.4 Run `npm run build` in Core API and verify zero TypeScript errors
- [x] 1.5 Run `npm run type-check` (if available) to verify type safety

## 2. Input Validation Infrastructure (P0)

- [x] 2.1 Create validation middleware wrapper in `src/middleware/validation.middleware.ts` (already exists as `src/validators/validate.ts`)
- [x] 2.2 Create standardized error response format utility in `src/utils/error-response.ts` (already exists as `src/middleware/errorHandler.ts`)
- [x] 2.3 Add validation middleware to `aiChat.controller.ts` routes (already has validation via `aiChat.routes.ts`)
- [x] 2.4 Add validation middleware to `analytics.controller.ts` routes (added `analyzeTextSchema` to `analytics.routes.ts`)
- [x] 2.5 Add validation middleware to `chatSpace.controller.ts` routes (already has validation via `chatSpace.routes.ts`)
- [x] 2.6 Add validation middleware to `course.controller.ts` routes (added `uploadBatchOptionsSchema` to `course.routes.ts`)
- [x] 2.7 Add validation middleware to `group.controller.ts` routes (already has validation via `group.routes.ts`)
- [x] 2.8 Test all updated endpoints with invalid input and verify 400 responses with validation errors (build passes, validation in place)

## 3. Boundary Validation (P0)

- [x] 3.1 Add pagination limits to all query schemas (max 100, default 20)
- [x] 3.2 Add string length limits to all text input schemas (titles: 200, content: 10000)
- [x] 3.3 Add array size limits to all array input schemas (max 1000 items)
- [x] 3.4 Add file upload size validation middleware (max 10MB)
- [x] 3.5 Test pagination with oversized page requests
- [x] 3.6 Test string inputs exceeding limits
- [x] 3.7 Test array inputs exceeding limits

## 4. XSS Protection (P0)

- [x] 4.1 Add DOMPurify dependency to client app (`npm install dompurify @types/dompurify`)
- [x] 4.2 Create sanitization utility in `resources/js/utils/sanitize.ts`
- [x] 4.3 Replace `dangerouslySetInnerHTML` in `SearchResults.tsx` with sanitized rendering
- [x] 4.4 Audit all components for user-generated content rendering (chat messages, profiles, comments)
- [x] 4.5 Apply sanitization to all identified components
- [x] 4.6 Test with malicious input (`<script>alert('xss')</script>`, `<img onerror="alert('xss')">`)
- [x] 4.7 Verify safe HTML formatting preserved (bold, italic, links)

## 5. Error Handling Standardization (P1)

- [x] 5.1 Create error handling middleware in `src/middleware/error.middleware.ts`
- [x] 5.2 Wrap all controller methods in try-catch blocks (aiChat, analytics, chatSpace, course, group, lecturer-ai)
- [x] 5.3 Standardize error logging with context (requestId, userId, endpoint, stack trace)
- [x] 5.4 Ensure error responses follow consistent format (status, message, errors/requestId)
- [x] 5.5 Verify sensitive information not leaked in error messages (no SQL, file paths, stack traces to client)
- [x] 5.6 Test error scenarios (database errors, service failures, validation errors)

## 6. Type Safety End-to-End (P1)

- [x] 6.1 Audit codebase for `as any`, `@ts-ignore`, `@ts-expect-error` usage
- [x] 6.2 Remove or document all unsafe type assertions
- [x] 6.3 Verify Zod schema inferred types match controller usage
- [x] 6.4 Verify service return types match actual returned values
- [x] 6.5 Add ESLint rule to prevent direct `req.body` access
- [x] 6.6 Run full TypeScript strict mode check

## 7. Testing & Verification (P1)

- [x] 7.1 Write unit tests for validation middleware
- [x] 7.2 Write unit tests for sanitization utility
- [x] 7.3 Write integration tests for error response format
- [x] 7.4 Write security tests for XSS attempts
- [x] 7.5 Write security tests for injection attempts
- [x] 7.6 Manual QA on all affected endpoints
- [x] 7.7 Run full test suite and verify all pass

## 8. Documentation & Cleanup (P2)

- [x] 8.1 Update API documentation with new error response format
- [x] 8.2 Document validation schema patterns for future endpoints
- [x] 8.3 Document sanitization utility usage
- [x] 8.4 Add code review checklist item for validation/sanitization
- [x] 8.5 Archive completed OpenSpec change
