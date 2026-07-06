## 1. Dependencies & Setup

- [ ] 1.1 Install json2csv and archiver packages
- [ ] 1.2 Create export service module at services/export.service.ts

## 2. Analytics Export Enhancement

- [ ] 2.1 Add format query parameter parsing to GET /api/analytics/export/:courseId (default json, accept csv)
- [ ] 2.2 Implement CSV serialization for analytics data using json2csv
- [ ] 2.3 Set Content-Type and Content-Disposition headers based on format
- [ ] 2.4 Add 400 validation for unsupported format values
- [ ] 2.5 Create GET /api/analytics/export/:courseId/summary endpoint with aggregated stats
- [ ] 2.6 Add format parameter support (json/csv) to summary endpoint
- [ ] 2.7 Verify lecturer only authorization on both endpoints

## 3. Course Data Export

- [ ] 3.1 Use shared ExportJob model from nfr-sec-02 (id, userId, exportType [USER_DATA|COURSE_DATA], courseId nullable, status, createdAt, completedAt, filePath) — do NOT create a separate model
- [ ] 3.2 Implement POST /api/courses/:id/export endpoint that creates an export job and returns 202 with jobId
- [ ] 3.3 Implement export job processor that generates zip with course.json, enrollments.csv, sessions.csv, interactions.csv, analytics-summary.json
- [ ] 3.4 Implement GET /api/export/:jobId/status endpoint returning job status and downloadUrl when complete
- [ ] 3.5 Implement GET /api/export/:jobId/download endpoint serving the zip file
- [ ] 3.6 Add job ownership check (404 if not the creator)
- [ ] 3.7 Add 409 response for download when job not completed
- [ ] 3.8 Add rate limiting middleware (5 requests/minute per user) on export endpoints

## 4. Export UI

- [ ] 4.1 Add format dropdown (JSON/CSV) to analytics page next to export button
- [ ] 4.2 Wire format dropdown to analytics export API call with format query parameter
- [ ] 4.3 Add "Export Course Data" button to analytics page for lecturers
- [ ] 4.4 Implement loading state and polling for course export job completion
- [ ] 4.5 Implement auto download on export completion with success notification
- [ ] 4.6 Implement error notification on export failure
- [ ] 4.7 Add "Download Data Saya" button to student dashboard (calls nfr-sec-02 user data export endpoint)
- [ ] 4.8 Hide "Download Data Saya" from lecturer view
- [ ] 4.9 Disable export buttons during active export with loading indicator
