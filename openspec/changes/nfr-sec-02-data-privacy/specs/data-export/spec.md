## ADDED Requirements

### Requirement: Initiate data export
The system SHALL expose POST /api/user/data-export that triggers an async job to bundle all user data into a JSON zip archive. Returns 202 with jobId.

#### Scenario: Start export successfully
- **WHEN** authenticated user sends POST /api/user/data-export
- **THEN** system creates an export job, returns 202 with { jobId, status: "pending" }

#### Scenario: Export already in progress
- **WHEN** user requests export while a pending/processing job exists
- **THEN** system returns 409 with the existing jobId

### Requirement: Export rate limiting
The system SHALL limit data export requests to 1 per 24 hours per user.

#### Scenario: Rate limit exceeded
- **WHEN** user requests a second export within 24 hours
- **THEN** system returns 429 with retry-after header

### Requirement: Export data contents
The export bundle SHALL include: user profile, journal entries, AI chat sessions and messages, reflections, goals, consent records, and privacy preferences.

#### Scenario: Export bundle completeness
- **WHEN** export job completes
- **THEN** zip contains JSON files for each data category with all user-owned records

### Requirement: Export download
The system SHALL expose GET /api/user/data-export/:jobId returning the completed zip file, or job status if still processing.

#### Scenario: Download completed export
- **WHEN** user sends GET /api/user/data-export/:jobId and job is complete
- **THEN** system returns 200 with zip file and Content-Disposition header

#### Scenario: Download in-progress export
- **WHEN** user sends GET /api/user/data-export/:jobId and job is processing
- **THEN** system returns 202 with { status: "processing", progress percentage }

#### Scenario: Download expired export
- **WHEN** user requests export older than 48 hours
- **THEN** system returns 410 with "export expired" message

### Requirement: Export auto-expiry
The system SHALL automatically delete export files 48 hours after generation.

#### Scenario: Auto-cleanup
- **WHEN** 48 hours have passed since export generation
- **THEN** system deletes the zip file and marks job as expired
