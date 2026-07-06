## Context

Kolabri is a Next.js app with a Node/Express backend. The only existing export is GET /api/analytics/export/:courseId which returns process mining JSON for lecturers. There is no CSV support, no bulk course export, and no student facing data portability. The backend uses Prisma ORM with a PostgreSQL database. File serving is done via Next.js API routes.

## Goals / Non-Goals

**Goals:**
- Support CSV and JSON export formats for analytics data
- Provide a summary analytics endpoint for aggregated statistics
- Enable full course data export as a zip bundle (enrollments, sessions, interactions, analytics)
- Provide students with a "Download Data Saya" button for personal data portability
- Add export UI controls on analytics page and student dashboard

**Non-Goals:**
- PDF report generation (future consideration)
- Scheduled or automated exports
- Export to external storage (S3, GCS)
- Real time streaming exports for very large datasets
- User data export implementation (covered by nfr-sec-02, this change only references it)

## Decisions

### 1. Format selection via query parameter on existing endpoint

Add `?format=csv|json` to GET /api/analytics/export/:courseId rather than creating separate endpoints. This keeps the API surface small and is backward compatible (defaults to json).

**Alternative considered**: Separate endpoints per format. Rejected because it duplicates route logic and breaks the single resource pattern.

### 2. CSV generation with json2csv

Use the `json2csv` library for CSV serialization. It handles nested objects via flattening, supports custom field selection, and is lightweight.

**Alternative considered**: Manual CSV string building. Rejected because of edge cases with escaping, commas in values, and nested data.

### 3. Course export as zip via archiver

Use `archiver` to create a zip containing multiple JSON/CSV files for the course data bundle. The zip is generated in memory and streamed to the client.

**Alternative considered**: Individual file downloads. Rejected because a single zip is easier for users and preserves data relationships.

### 4. Async job pattern for large exports

For course exports that may take time, use the shared ExportJob model (also used by nfr-sec-02 for user data exports) with `exportType: COURSE_DATA`. POST returns a job ID, client polls GET /api/export/:jobId/status until complete, then downloads. This avoids request timeouts on large datasets and reuses the same job infrastructure as user data exports.

**Alternative considered**: Synchronous generation only. Rejected because courses with many sessions and interactions could exceed request timeouts. Separate job model per export type. Rejected to avoid duplicated infrastructure.

### 5. Student data download references nfr-sec-02

The "Download Data Saya" button triggers the user data export endpoint from nfr-sec-02. This change only adds the UI button and wires it to that endpoint. No duplicate implementation.

## Risks / Trade-offs

- **Large export timeout** → Mitigate with async job pattern for course exports; analytics exports stay synchronous (smaller dataset)
- **Memory pressure from zip generation** → Mitigate with archiver streaming; set max file count and data size limits per export
- **CSV flattening loses nested structure** → Document that JSON format preserves full structure; CSV is for spreadsheet use
- **Concurrent export requests** → Mitigate with rate limiting on export endpoints (e.g., 5 requests per minute per user)
