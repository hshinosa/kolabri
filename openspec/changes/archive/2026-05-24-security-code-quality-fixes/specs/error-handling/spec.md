## ADDED Requirements

### Requirement: All controller methods MUST use try-catch blocks

The system SHALL wrap all controller logic in try-catch blocks to handle unexpected errors gracefully. Unhandled exceptions SHALL NOT propagate to the client as 500 errors without context.

#### Scenario: Database error caught and logged
- **WHEN** database operation fails
- **THEN** error is caught, logged with context, and user receives appropriate error response

#### Scenario: Service error caught and transformed
- **WHEN** external service call fails
- **THEN** error is caught, transformed to user-friendly message, and returned with appropriate status code

### Requirement: Error responses MUST follow consistent format

The system SHALL return errors in consistent JSON format with status code, message, and optional details field.

#### Scenario: Validation error format
- **WHEN** validation fails
- **THEN** response format is `{ status: 400, message: "Validation failed", errors: [...] }`

#### Scenario: Not found error format
- **WHEN** resource not found
- **THEN** response format is `{ status: 404, message: "Resource not found", resource: "..." }`

#### Scenario: Server error format
- **WHEN** unexpected error occurs
- **THEN** response format is `{ status: 500, message: "Internal server error", requestId: "..." }`

### Requirement: Errors MUST be logged with context

The system SHALL log all errors with sufficient context for debugging including request ID, user ID, endpoint, and stack trace.

#### Scenario: Error logged with request context
- **WHEN** error occurs during request processing
- **THEN** log includes requestId, userId, method, path, and error details

#### Scenario: Stack traces logged for server errors
- **WHEN** unexpected error occurs
- **THEN** full stack trace is logged (but NOT sent to client)

### Requirement: User-facing error messages MUST NOT leak sensitive information

Error messages returned to clients SHALL NOT include stack traces, database queries, file paths, or other sensitive implementation details.

#### Scenario: Database error sanitized
- **WHEN** database constraint violation occurs
- **THEN** client receives generic "Invalid data" message, not SQL error

#### Scenario: File path not exposed
- **WHEN** file operation fails
- **THEN** client receives generic error, not file system path
