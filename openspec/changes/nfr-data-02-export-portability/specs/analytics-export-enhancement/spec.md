## ADDED Requirements

### Requirement: Analytics export format selection
The system SHALL support `format` query parameter on GET /api/analytics/export/:courseId with values `json` (default) and `csv`. When format is `json`, the response SHALL return the existing process mining JSON structure. When format is `csv`, the response SHALL return a CSV file with Content-Disposition header for download.

#### Scenario: Export analytics as JSON (default)
- **WHEN** lecturer requests GET /api/analytics/export/:courseId without format parameter
- **THEN** system returns JSON response identical to current behavior with Content-Type application/json

#### Scenario: Export analytics as JSON (explicit)
- **WHEN** lecturer requests GET /api/analytics/export/:courseId?format=json
- **THEN** system returns JSON response with Content-Type application/json

#### Scenario: Export analytics as CSV
- **WHEN** lecturer requests GET /api/analytics/export/:courseId?format=csv
- **THEN** system returns CSV file with Content-Type text/csv and Content-Disposition header with filename pattern `analytics-{courseId}-{timestamp}.csv`

#### Scenario: Invalid format parameter
- **WHEN** lecturer requests GET /api/analytics/export/:courseId?format=pdf
- **THEN** system returns 400 with error message indicating supported formats are json and csv

### Requirement: Analytics summary export
The system SHALL provide GET /api/analytics/export/:courseId/summary endpoint that returns aggregated course statistics (total sessions, average attendance, interaction counts, completion rates). The endpoint SHALL support the same `format` query parameter (json/csv).

#### Scenario: Summary export as JSON
- **WHEN** lecturer requests GET /api/analytics/export/:courseId/summary?format=json
- **THEN** system returns aggregated statistics as JSON with fields: totalSessions, avgAttendance, interactionCounts, completionRate

#### Scenario: Summary export as CSV
- **WHEN** lecturer requests GET /api/analytics/export/:courseId/summary?format=csv
- **THEN** system returns aggregated statistics as CSV with Content-Type text/csv and Content-Disposition header

### Requirement: Export authorization
Both analytics export and summary endpoints SHALL enforce lecturer only access. Students and unauthenticated users SHALL receive 403.

#### Scenario: Student accesses export
- **WHEN** student requests GET /api/analytics/export/:courseId
- **THEN** system returns 403 Forbidden

#### Scenario: Unauthenticated user accesses export
- **WHEN** unauthenticated user requests GET /api/analytics/export/:courseId
- **THEN** system returns 401 Unauthorized
