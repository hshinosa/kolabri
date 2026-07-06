## ADDED Requirements

### Requirement: Dark mode available in all roles
The system SHALL provide dark mode toggle in admin, student, and lecturer roles.

#### Scenario: Dark mode toggle in student layout
- **WHEN** student navigates to any student page
- **THEN** dark mode toggle SHALL be accessible in navigation
- **AND** theme preference SHALL persist across sessions

#### Scenario: Dark mode toggle in lecturer layout
- **WHEN** lecturer navigates to any lecturer page
- **THEN** dark mode toggle SHALL be accessible in navigation
- **AND** theme preference SHALL persist across sessions

#### Scenario: Dark mode state synchronized
- **WHEN** user toggles dark mode in one role
- **THEN** preference SHALL apply to all roles for that user

### Requirement: Keyboard shortcuts available in all roles
The system SHALL provide keyboard shortcuts in admin, student, and lecturer roles.

#### Scenario: Keyboard shortcuts in student pages
- **WHEN** student presses shortcut key (e.g., `Ctrl+K` for search)
- **THEN** corresponding action SHALL execute
- **AND** shortcut help modal SHALL be accessible via `?` key

#### Scenario: Keyboard shortcuts in lecturer pages
- **WHEN** lecturer presses shortcut key
- **THEN** corresponding action SHALL execute
- **AND** shortcut help modal SHALL be accessible via `?` key

#### Scenario: Role-specific shortcuts
- **WHEN** user is in a specific role
- **THEN** shortcuts SHALL be relevant to that role's features
- **AND** conflicting shortcuts SHALL be avoided

### Requirement: Global search available in all roles
The system SHALL provide global search in admin, student, and lecturer roles.

#### Scenario: Global search in student pages
- **WHEN** student presses `Ctrl+K` or clicks search icon
- **THEN** global search modal SHALL open
- **AND** search SHALL cover student-relevant entities (courses, groups, reflections)

#### Scenario: Global search in lecturer pages
- **WHEN** lecturer presses `Ctrl+K` or clicks search icon
- **THEN** global search modal SHALL open
- **AND** search SHALL cover lecturer-relevant entities (courses, students, sessions, analytics)

#### Scenario: Search results role-scoped
- **WHEN** user performs global search
- **THEN** results SHALL only include entities accessible to that role
- **AND** results SHALL link to role-appropriate pages

### Requirement: Shared UX components role-agnostic
The system SHALL implement UX features via shared, role-agnostic components.

#### Scenario: ThemeProvider shared across roles
- **WHEN** any role layout is rendered
- **THEN** `ThemeProvider` context SHALL be used
- **AND** role-specific theme config SHALL be passed as prop

#### Scenario: KeyboardShortcutProvider shared across roles
- **WHEN** any role layout is rendered
- **THEN** `KeyboardShortcutProvider` context SHALL be used
- **AND** role-specific shortcut map SHALL be passed as prop

#### Scenario: GlobalSearchModal shared across roles
- **WHEN** global search is triggered in any role
- **THEN** `GlobalSearchModal` component SHALL be used
- **AND** role-specific search endpoint SHALL be passed as prop
