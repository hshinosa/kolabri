## ADDED Requirements

### Requirement: Simplified student navigation menu
The system SHALL display a simplified navigation menu for students with course-centric structure.

#### Scenario: Student navigation menu items
- **WHEN** student views any page in the student portal
- **THEN** system displays navigation menu with existing items (Dashboard, Mata Kuliah Saya, Refleksi, etc.)
- **THEN** system does NOT display separate "Grup" menu item
- **THEN** system does NOT display separate "Sesi Diskusi" menu item

#### Scenario: Navigate to course detail
- **WHEN** student clicks "Mata Kuliah Saya" in navigation
- **THEN** system navigates to `/student/courses` showing list of enrolled courses
- **WHEN** student clicks on a course card
- **THEN** system navigates to unified course detail page at `/student/courses/:id`

### Requirement: Route redirects for removed pages
The system SHALL redirect old routes to the unified course detail page.

#### Scenario: Redirect from old groups page
- **WHEN** student navigates to `/student/groups`
- **THEN** system redirects to `/student/courses` with appropriate message

#### Scenario: Redirect from old chat-spaces page
- **WHEN** student navigates to `/student/courses/:courseId/chat-spaces`
- **THEN** system redirects to `/student/courses/:courseId` (unified detail page)
