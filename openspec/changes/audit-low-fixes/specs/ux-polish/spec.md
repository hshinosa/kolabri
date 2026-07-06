## ADDED Requirements

### Requirement: Non-functional language selector MUST be removed

The language preference UI SHALL be removed from the preferences section to eliminate misleading non-functional features.

#### Scenario: Language selector not visible in preferences
- **WHEN** user navigates to preferences/settings page
- **THEN** language selector component is NOT rendered
- **AND** LanguagePrefs component is not imported
- **AND** `language` field is removed from PreferencesData interface

#### Scenario: Language field not sent to backend
- **WHEN** preferences are saved via PATCH request
- **THEN** `language` field is NOT included in request body
- **AND** other preference fields (theme, notifications, font_size) still sent correctly

#### Scenario: Other preferences remain functional
- **WHEN** language selector is removed
- **THEN** theme preference still works
- **AND** notification preferences still work
- **AND** preferences layout is not broken

#### Scenario: Language localStorage keys cleaned up
- **WHEN** application initializes
- **THEN** no code reads language-related localStorage keys
- **AND** old language keys are not referenced anywhere
- **AND** backend `preferences` JSON may still contain dead `language` key (acceptable, no migration)

---

### Requirement: Deep pages MUST have breadcrumb navigation

All pages beyond top-level navigation SHALL display breadcrumbs showing the user's location in the hierarchy. Breadcrumb links use `/student/` prefix to match existing codebase routes.

#### Scenario: Course detail page shows breadcrumbs
- **WHEN** user navigates to /student/courses/:id
- **THEN** breadcrumbs show: Dashboard > [Course Name]
- **AND** Dashboard is a clickable link to `/student/dashboard`
- **AND** Course Name is plain text (current page)

#### Scenario: Group detail page shows breadcrumbs
- **WHEN** user navigates to /student/groups/:id
- **THEN** breadcrumbs show: Dashboard > [Course Name] > [Group Name]
- **AND** Dashboard links to `/student/dashboard`
- **AND** Course Name links to `/student/courses/:courseId`
- **AND** the existing ArrowLeft back-link ("Kembali ke Detail Kelas") is REPLACED by breadcrumbs

#### Scenario: Chat room shows breadcrumbs
- **WHEN** user navigates to /student/courses/:course/chat/:chatSpace
- **THEN** breadcrumbs show: Dashboard > [Course Name] > [Chat Name]
- **AND** Dashboard links to `/student/dashboard`
- **AND** Course Name links to `/student/courses/:courseId`

#### Scenario: Reflections page shows breadcrumbs
- **WHEN** user navigates to /student/reflections
- **THEN** breadcrumbs show: Dashboard > Refleksi Saya
- **AND** Dashboard links to `/student/dashboard`

#### Scenario: AI Chat page shows breadcrumbs
- **WHEN** user navigates to /student/ai-chat
- **THEN** breadcrumbs show: Dashboard > Chat dengan AI
- **AND** Dashboard links to `/student/dashboard`

#### Scenario: Breadcrumbs are responsive
- **WHEN** viewing on narrow screen
- **THEN** long breadcrumb labels are truncated
- **AND** breadcrumbs do not overflow container
- **AND** navigation remains functional

---

### Requirement: Empty data states MUST be verified before modification

EmptyState components already exist in the codebase for dashboard, courses, chat-spaces, and reflections. Implementation SHALL verify existing components render correctly before adding new ones.

#### Scenario: Verify dashboard chart empty state renders
- **WHEN** user has no activity data in ActivityFeed
- **THEN** existing EmptyState component is rendered (not blank screen)
- **AND** includes icon, title, description, and optional action button
- **IF NOT**: fix conditional rendering logic

#### Scenario: Verify course list empty state renders
- **WHEN** user has no enrolled courses
- **THEN** existing courses EmptyState wrapper is rendered
- **AND** message includes action to browse courses
- **IF NOT**: fix conditional rendering logic

#### Scenario: Verify message history empty state renders
- **WHEN** chat space has no messages
- **THEN** existing chat-spaces EmptyState wrapper is rendered
- **AND** shows appropriate "no messages" variant
- **IF NOT**: fix conditional rendering logic

#### Scenario: Verify reflection list empty state renders
- **WHEN** user has no reflections
- **THEN** existing EmptyState component is rendered
- **AND** includes action button to create reflection
- **IF NOT**: fix conditional rendering logic

#### Scenario: EmptyState component is consistent
- **WHEN** EmptyState is used across pages
- **THEN** visual style is consistent (icon + title + description + optional action)
- **AND** uses existing EmptyState component (not custom per-page)
- **AND** spacing and typography match design system
