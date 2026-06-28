# Code Review Checklist

Use this checklist when reviewing code changes to ensure quality, security, and consistency.

## Security

- [ ] **Input validation**: All user inputs validated with Zod schemas (see [Validation Patterns](../Kolabri-core-api/docs/validation-patterns.md))
- [ ] **Output sanitization**: User-generated content sanitized before rendering (see [Sanitization Guide](../Kolabri-client-app/docs/sanitization-guide.md))
- [ ] **Authentication**: Protected routes require valid JWT tokens
- [ ] **Authorization**: Role checks enforce access control (admin, lecturer, student)
- [ ] **SQL injection**: Prisma/Mongoose used correctly (no raw queries with user input)
- [ ] **XSS prevention**: No `dangerouslySetInnerHTML` without sanitization
- [ ] **CSRF protection**: State-changing operations use POST/PUT/DELETE with CSRF tokens
- [ ] **Secrets**: No hardcoded credentials, API keys, or tokens
- [ ] **Rate limiting**: API endpoints have appropriate rate limits
- [ ] **Error messages**: No sensitive information leaked in error responses

## Validation & Data Integrity

- [ ] **Schema validation**: Request bodies validated with Zod schemas
- [ ] **Boundary limits**: String lengths, array sizes, numeric ranges enforced
- [ ] **Type safety**: TypeScript types match runtime validation schemas
- [ ] **Required fields**: All required fields marked and validated
- [ ] **Optional fields**: Optional fields have sensible defaults or null handling
- [ ] **UUID validation**: IDs validated as proper UUIDs
- [ ] **Enum validation**: Fixed value sets use enums, not string literals
- [ ] **Regex patterns**: Codes/identifiers validated with appropriate patterns

## Error Handling

- [ ] **Consistent format**: Errors follow standard format (see [API Error Responses](../Kolabri-core-api/docs/API_ERROR_RESPONSES.md))
- [ ] **HTTP status codes**: Correct status codes used (400, 401, 403, 404, 500)
- [ ] **Validation errors**: Field-level errors provided for validation failures
- [ ] **Error logging**: Server errors logged with context (requestId, user, action)
- [ ] **User-friendly messages**: Error messages are clear and actionable
- [ ] **No stack traces**: Production errors don't expose stack traces

## Testing

- [ ] **Unit tests**: Core logic has unit test coverage
- [ ] **Integration tests**: API endpoints have integration tests
- [ ] **Boundary tests**: Edge cases tested (min, max, empty, null)
- [ ] **Error cases**: Failure scenarios tested (invalid input, auth failures)
- [ ] **Test data**: Tests use realistic data, not just happy paths
- [ ] **Tests pass**: All tests pass locally before review

## Code Quality

- [ ] **Naming**: Variables, functions, types have clear, descriptive names
- [ ] **DRY**: No unnecessary duplication (extract reusable functions/schemas)
- [ ] **Single responsibility**: Functions do one thing well
- [ ] **Type safety**: No `any` types (use proper TypeScript types)
- [ ] **Error handling**: Try-catch blocks where needed, errors propagated correctly
- [ ] **Comments**: Complex logic explained, but code is self-documenting
- [ ] **Formatting**: Code follows project style (ESLint/Prettier)
- [ ] **Imports**: Clean imports, no unused imports

## Performance

- [ ] **Database queries**: Efficient queries, proper indexes used
- [ ] **N+1 queries**: Avoided (use `include` or batch queries)
- [ ] **Pagination**: Large result sets paginated (max 100 items)
- [ ] **Caching**: Appropriate use of caching for expensive operations
- [ ] **Bulk operations**: Limited to reasonable sizes (max 1000 items)
- [ ] **Memory leaks**: Event listeners cleaned up, connections closed

## API Design

- [ ] **RESTful**: Endpoints follow REST conventions
- [ ] **Versioning**: Breaking changes versioned appropriately
- [ ] **Backwards compatibility**: Existing clients not broken
- [ ] **Documentation**: API changes documented
- [ ] **Response format**: Consistent response structure
- [ ] **Query parameters**: Pagination, sorting, filtering supported

## Frontend (Client App)

- [ ] **Sanitization**: User content sanitized with `sanitizeHtml()` or `sanitizeText()`
- [ ] **Loading states**: UI shows loading indicators for async operations
- [ ] **Error states**: Errors displayed to users clearly
- [ ] **Accessibility**: ARIA labels, keyboard navigation, screen reader support
- [ ] **Responsive**: Works on mobile, tablet, desktop
- [ ] **Performance**: No unnecessary re-renders, lazy loading where appropriate

## Database

- [ ] **Migrations**: Schema changes have migrations (Prisma/Laravel)
- [ ] **Rollback**: Migrations can be rolled back safely
- [ ] **Data integrity**: Foreign keys, constraints, indexes defined
- [ ] **Seed data**: Development seed data updated if needed
- [ ] **Backup**: Critical data changes have backup plan

## Documentation

- [ ] **README**: Updated if setup/usage changed
- [ ] **API docs**: New endpoints documented
- [ ] **Comments**: Complex logic explained
- [ ] **Changelog**: User-facing changes noted
- [ ] **Migration guide**: Breaking changes have migration instructions

## Deployment

- [ ] **Environment variables**: New env vars documented in `.env.example`
- [ ] **Dependencies**: New dependencies justified and documented
- [ ] **Build**: Code builds without errors
- [ ] **Linting**: No linting errors
- [ ] **Type checking**: TypeScript compiles without errors
- [ ] **Docker**: Docker build succeeds if applicable

## Specific to This Project

- [ ] **Validation schemas**: Follow patterns in `validation-patterns.md`
- [ ] **Error responses**: Follow format in `API_ERROR_RESPONSES.md`
- [ ] **Sanitization**: Follow guide in `sanitization-guide.md`
- [ ] **AI Engine integration**: Requests proxied correctly through Core API
- [ ] **Real-time**: Socket.IO events handled properly
- [ ] **Audit logging**: Admin actions logged to audit trail

## Before Merging

- [ ] All checklist items addressed or marked N/A
- [ ] Tests pass in CI/CD pipeline
- [ ] Code reviewed by at least one other developer
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Branch up to date with main/master

---

## Notes

- Not all items apply to every PR. Use judgment.
- Mark items N/A if not applicable.
- Add project-specific items as needed.
- Review this checklist periodically and update.
