## Why

Kolabri only has one export endpoint (GET /api/analytics/export/:courseId) that outputs process mining JSON for lecturers. There is no CSV export, no user facing data portability, and no bulk download. limits lecturers from using analytics data in external tools like spreadsheets or BI platforms.

## What Changes

- Add CSV and JSON format options to the existing analytics export endpoint
- Add a summary analytics export endpoint for aggregated course statistics
- Add a course data export endpoint (POST /api/courses/:id/export) that bundles full course data as a downloadable zip
- Add a student facing "Download Data Saya" feature for personal data portability (references nfr-sec-02)
- Add export UI controls: format dropdown on analytics page, "Export Course Data" button for lecturers, "Download Data Saya" button for students

## Capabilities

### New Capabilities
- `analytics-export-enhancement`: CSV and JSON format support for analytics export, plus summary endpoint
- `course-data-export`: Full course data bundle export as zip (enrollments, sessions, interactions, analytics)
- `export-ui`: Frontend export controls (format dropdown, export buttons for lecturers and students)

### Modified Capabilities
<!-- No existing spec level behavior changes required -->

## Impact

- **API**: New endpoints POST /api/courses/:id/export, GET /api/analytics/export/:courseId/summary; modified GET /api/analytics/export/:courseId to accept format param
- **Backend**: New export service layer, zip generation (archiver), CSV serialization (json2csv or similar)
- **Frontend**: Analytics page gets format dropdown and export buttons; student dashboard gets "Download Data Saya" button
- **Dependencies**: archiver (zip), json2csv or papaparse (CSV), potential file size limits and async job handling for large exports
- **Cross reference**: User data export (if any) is covered in nfr-sec-02; this change references it for the student download feature
