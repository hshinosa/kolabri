## ADDED Requirements

### Requirement: Admin pagination TypeScript errors resolved
The system SHALL compile without TypeScript errors in admin pagination components.

#### Scenario: AdminPagination component imported correctly
- **WHEN** `master-data.tsx` or `user-management.tsx` is compiled
- **THEN** TypeScript SHALL NOT report "Cannot find name 'AdminPagination'" error

#### Scenario: Pagination meta variables destructured correctly
- **WHEN** pagination meta object is used in admin pages
- **THEN** TypeScript SHALL NOT report "Cannot find name 'start/end/total'" errors

### Requirement: Session management route TypeScript errors resolved
The system SHALL compile without TypeScript errors in session management components.

#### Scenario: autoCloseUpdate route exists
- **WHEN** `AutoCloseConfig.tsx` references `lecturer.sessions.autoCloseUpdate`
- **THEN** TypeScript SHALL NOT report "Property 'autoCloseUpdate' does not exist" error

#### Scenario: activate route exists
- **WHEN** `ScheduledSessionsList.tsx` references `lecturer.sessions.activate`
- **THEN** TypeScript SHALL NOT report "Property 'activate' does not exist" error

### Requirement: Student page TypeScript errors resolved
The system SHALL compile without TypeScript errors in student pages.

#### Scenario: broadcast variable scoped correctly
- **WHEN** `student/ai-chat/index.tsx` is compiled
- **THEN** TypeScript SHALL NOT report "Block-scoped variable 'broadcast' used before its declaration" error

#### Scenario: PinnedMessages prop types aligned
- **WHEN** `student/chat/room.tsx` passes props to `PinnedMessages` component
- **THEN** TypeScript SHALL NOT report "Property 'canPin' does not exist" error

### Requirement: Zero TypeScript compilation errors
The system SHALL pass `tsc --noEmit` with zero errors.

#### Scenario: Full TypeScript check passes
- **WHEN** `npm run tsc --noEmit` is executed
- **THEN** exit code SHALL be 0
- **AND** output SHALL contain no "error TS" lines
