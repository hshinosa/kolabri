## ADDED Requirements

### Requirement: Unified course detail page layout
The system SHALL display a single unified page at `/student/courses/:id` containing three sections: course header, group management, and discussion sessions.

#### Scenario: Student views course detail
- **WHEN** student navigates to `/student/courses/:id`
- **THEN** system displays course header (code, name, lecturer name) without status badge
- **THEN** system displays group management section below header
- **THEN** system displays discussion sessions section below group management

### Requirement: Course header without status badge
The system SHALL display course information (code, name, lecturer) without any status indicator badge.

#### Scenario: Header display
- **WHEN** student views course detail page
- **THEN** system shows course code in a badge
- **THEN** system shows course name as heading
- **THEN** system shows lecturer name
- **THEN** system does NOT show "Berjalan/Selesai/Belum Mulai" status badge

### Requirement: Group management for non-joined students
The system SHALL display group join options when student has not joined any group in the course.

#### Scenario: Student not in any group
- **WHEN** student views course detail AND is not a member of any group in the course
- **THEN** system displays "Belum bergabung dengan grup" message
- **THEN** system displays "Gabung Grup" button that opens join modal
- **THEN** system displays "Buat Grup Baru" button that opens create modal
- **THEN** system displays read-only list of available groups with member count (e.g., "Grup A (3/5 anggota)")

#### Scenario: Student clicks Gabung Grup
- **WHEN** student clicks "Gabung Grup" button
- **THEN** system opens modal with join code input field
- **WHEN** student enters valid join code and submits
- **THEN** system joins the group and refreshes the page to show group membership

#### Scenario: Student clicks Buat Grup Baru
- **WHEN** student clicks "Buat Grup Baru" button
- **THEN** system opens modal with group name input field
- **WHEN** student enters name and submits
- **THEN** system creates new group, auto-joins student, and displays join code for sharing

### Requirement: Group management for joined students
The system SHALL display group details and session management when student has joined a group.

#### Scenario: Student already in a group
- **WHEN** student views course detail AND is a member of a group
- **THEN** system displays group card with group name and member count
- **THEN** system displays "Lihat Anggota" button to view group members
- **THEN** system displays discussion sessions section below group card

### Requirement: Discussion session management
The system SHALL display discussion sessions with search, sort, and create capabilities.

#### Scenario: View session list
- **WHEN** student is in a group and views course detail
- **THEN** system displays list of discussion sessions for the group
- **THEN** each session card shows: name, status badge (Aktif/Tidak Aktif), type badge (Akademik/Proyek/Umum), message count, last message preview (truncated), last message timestamp (relative format), and "Masuk ke Diskusi" link

#### Scenario: Search sessions
- **WHEN** student types in search box
- **THEN** system filters session list to show only sessions matching the search query

#### Scenario: Sort sessions
- **WHEN** student selects sort option (Terbaru/Paling Aktif/Alfabet)
- **THEN** system reorders session list according to selected criteria

#### Scenario: Create new session
- **WHEN** student clicks "Buat Sesi Baru" button
- **THEN** system opens modal with fields: session name (required), description (optional), week selection (required from dropdown)
- **WHEN** student fills form and submits
- **THEN** system creates new session and refreshes session list

### Requirement: Empty states for sessions
The system SHALL display appropriate empty states when no sessions are available.

#### Scenario: No sessions in group
- **WHEN** student is in a group but group has no sessions
- **THEN** system displays "Belum ada sesi diskusi di grup ini" message with "Buat Sesi Pertama" button

#### Scenario: No search results
- **WHEN** student searches for sessions but no matches found
- **THEN** system displays "Tidak ada sesi yang cocok" message

### Requirement: Loading and error states
The system SHALL display loading indicators during data fetch and error messages on failure.

#### Scenario: Loading state
- **WHEN** page is fetching course/group/session data
- **THEN** system displays skeleton loader or spinner for each section

#### Scenario: Error state
- **WHEN** data fetch fails
- **THEN** system displays error message "Gagal memuat data. Coba lagi nanti." with retry button

#### Scenario: No groups available
- **WHEN** course has no groups defined
- **THEN** system displays "Belum ada grup untuk mata kuliah ini. Hubungi dosen untuk membuat grup." message
