## MODIFIED Requirements

### Requirement: Settings Page Structure
Sistem SHALL menyediakan halaman settings dengan tab navigation.

#### Scenario: Settings page accessed
- **WHEN** user mengakses /settings
- **THEN** sistem menampilkan halaman settings dengan tab: Profile, Notifikasi, Tampilan, Keamanan, Retensi Data

#### Scenario: Tab navigation
- **WHEN** user mengklik tab
- **THEN** konten tab tersebut dimuat tanpa page reload

#### Scenario: Deep link to tab
- **WHEN** user mengakses /settings?tab=retensi-data
- **THEN** sistem langsung menampilkan tab Retensi Data

## ADDED Requirements

### Requirement: Retention Policy Management UI
The settings page SHALL provide a "Retensi Data" tab (admin-only) with a table listing all DataRetentionPolicy records. Each row shows: dataType, retentionDays, archiveAfterDays, autoPurge toggle, and action buttons (edit, delete).

#### Scenario: Admin views retention policies
- **WHEN** an admin user accesses the Retensi Data tab
- **THEN** the system displays a table with all retention policies sorted by dataType

#### Scenario: Non-admin cannot see tab
- **WHEN** a non-admin user views the settings page
- **THEN** the Retensi Data tab is not visible

#### Scenario: Admin edits policy inline
- **WHEN** an admin clicks the edit button on a policy row
- **THEN** the row becomes editable with input fields for retentionDays, archiveAfterDays, and a toggle for autoPurge

#### Scenario: Admin saves policy change
- **WHEN** an admin modifies a policy field and clicks "Simpan"
- **THEN** the system updates the policy via API and shows a success toast

#### Scenario: Admin creates new policy
- **WHEN** an admin clicks "Tambah Kebijakan" and a dataType is available with no existing policy
- **THEN** a new row appears in the table with editable fields

#### Scenario: Admin deletes policy
- **WHEN** an admin clicks the delete button on a policy row
- **THEN** the system shows a confirmation dialog, and on confirm, deletes the policy

#### Scenario: Auto-purge toggle
- **WHEN** an admin toggles the autoPurge switch
- **THEN** the system updates the policy immediately with auto-save (no "Simpan" button needed)
