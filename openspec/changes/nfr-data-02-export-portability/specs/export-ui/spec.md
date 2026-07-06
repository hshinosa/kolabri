## ADDED Requirements

### Requirement: Analytics format dropdown
The analytics page SHALL display a format dropdown selector next to the existing export button, allowing lecturers to choose between JSON and CSV before exporting.

#### Scenario: Lecturer selects CSV format and exports
- **WHEN** lecturer selects "CSV" from the format dropdown and clicks export
- **THEN** system downloads the analytics data as a CSV file

#### Scenario: Lecturer selects JSON format and exports
- **WHEN** lecturer selects "JSON" from the format dropdown and clicks export
- **THEN** system downloads the analytics data as a JSON file

#### Scenario: Default format selection
- **WHEN** analytics page loads
- **THEN** format dropdown defaults to "JSON"

### Requirement: Export Course Data button
The analytics page SHALL display an "Export Course Data" button that initiates a full course data export as a zip file. The button SHALL show a loading state while the export is processing and provide feedback on completion.

#### Scenario: Lecturer clicks Export Course Data
- **WHEN** lecturer clicks "Export Course Data" button
- **THEN** system shows loading spinner, initiates POST /api/courses/:id/export, and polls for completion

#### Scenario: Export completes successfully
- **WHEN** course export job completes
- **THEN** system automatically downloads the zip file and shows success notification

#### Scenario: Export fails
- **WHEN** course export job fails
- **THEN** system shows error notification with failure reason

### Requirement: Download Data Saya button for students
The student dashboard SHALL display a "Download Data Saya" button that triggers the user data export endpoint (from nfr-sec-02). This button SHALL only be visible to students.

#### Scenario: Student clicks Download Data Saya
- **WHEN** student clicks "Download Data Saya" button
- **THEN** system calls the user data export endpoint from nfr-sec-02 and downloads the resulting file

#### Scenario: Lecturer does not see Download Data Saya
- **WHEN** lecturer views the dashboard
- **THEN** "Download Data Saya" button is not visible

### Requirement: Export button disabled during processing
All export buttons SHALL be disabled while an export is in progress to prevent duplicate requests.

#### Scenario: Export button disabled during processing
- **WHEN** an export request is in progress
- **THEN** export buttons show disabled state and loading indicator

#### Scenario: Export button re-enabled after completion
- **WHEN** export completes (success or failure)
- **THEN** export buttons return to enabled state
