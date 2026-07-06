## ADDED Requirements

### Requirement: Join group via code in unified page
The system SHALL allow students to join groups using join codes from the unified course detail page.

#### Scenario: Join group with valid code
- **WHEN** student is not in any group and clicks "Gabung Grup" button
- **THEN** system displays modal with join code input field
- **WHEN** student enters valid join code and submits
- **THEN** system adds student to the group
- **THEN** system refreshes page to show group membership section
- **THEN** system displays group card with member information

#### Scenario: Join group with invalid code
- **WHEN** student enters invalid or expired join code
- **THEN** system displays error message "Kode tidak valid atau sudah kadaluarsa"
- **THEN** system keeps modal open for retry

#### Scenario: Join group when at capacity
- **WHEN** student tries to join a group that has reached max capacity
- **THEN** system displays error message "Grup sudah penuh"
- **THEN** system prevents joining

### Requirement: Create new group in unified page
The system SHALL allow students to create new groups from the unified course detail page.

#### Scenario: Create new group
- **WHEN** student is not in any group and clicks "Buat Grup Baru" button
- **THEN** system displays modal with group name input field
- **WHEN** student enters group name and submits
- **THEN** system creates new group with student as first member
- **THEN** system generates unique join code for the group
- **THEN** system displays join code in success message for sharing with peers

#### Scenario: Create group with duplicate name
- **WHEN** student tries to create group with name that already exists in the course
- **THEN** system displays error message "Nama grup sudah digunakan"
- **THEN** system keeps modal open for retry

### Requirement: Available groups list as reference
The system SHALL display a read-only list of available groups for students who have not joined.

#### Scenario: View available groups
- **WHEN** student is not in any group and views course detail
- **THEN** system displays list of all groups in the course
- **THEN** each group shows: name and member count (e.g., "Grup A (3/5 anggota)")
- **THEN** groups at full capacity are visually indicated (e.g., grayed out or marked "Penuh")
- **THEN** list is read-only (no join buttons on individual groups)
