## ADDED Requirements

### Requirement: Course data export as zip
The system SHALL provide POST /api/courses/:id/export endpoint that generates a zip file containing the full course data bundle: course metadata, enrollments, sessions, interactions, and analytics summary. The endpoint SHALL only be accessible by the course lecturer.

#### Scenario: Lecturer initiates course export
- **WHEN** lecturer sends POST /api/courses/:id/export
- **THEN** system creates an export job and returns 202 with jobId and status "pending"

#### Scenario: Export job contains all course data
- **WHEN** export job completes
- **THEN** the generated zip SHALL contain files: course.json, enrollments.csv, sessions.csv, interactions.csv, analytics-summary.json

#### Scenario: Non-lecturer attempts course export
- **WHEN** student or non-owner lecturer sends POST /api/courses/:id/export
- **THEN** system returns 403 Forbidden

### Requirement: Export job status polling
The system SHALL provide GET /api/export/:jobId/status endpoint that returns the current status of an export job (pending, processing, completed, failed). When completed, the response SHALL include a download URL.

#### Scenario: Poll pending job
- **WHEN** user requests GET /api/export/:jobId/status while job is pending
- **THEN** system returns 200 with status "pending" or "processing" and progress percentage

#### Scenario: Poll completed job
- **WHEN** user requests GET /api/export/:jobId/status after job completes
- **THEN** system returns 200 with status "completed" and downloadUrl field

#### Scenario: Poll failed job
- **WHEN** export job fails due to error
- **THEN** system returns 200 with status "failed" and error message

#### Scenario: Access another user's export job
- **WHEN** user requests status for a jobId they did not create
- **THEN** system returns 404 Not Found

### Requirement: Export download
The system SHALL provide GET /api/export/:jobId/download endpoint that serves the generated zip file. The endpoint SHALL only be accessible by the user who created the export job.

#### Scenario: Download completed export
- **WHEN** user requests GET /api/export/:jobId/download for a completed job they own
- **THEN** system returns zip file with Content-Type application/zip and Content-Disposition header with filename pattern `course-{courseId}-{timestamp}.zip`

#### Scenario: Download incomplete export
- **WHEN** user requests download for a job that is not completed
- **THEN** system returns 409 Conflict with message indicating export is not ready

### Requirement: Export rate limiting
The system SHALL limit export requests to 5 per minute per user to prevent abuse.

#### Scenario: Rate limit exceeded
- **WHEN** user submits more than 5 export requests within 1 minute
- **THEN** system returns 429 Too Many Requests with Retry-After header
