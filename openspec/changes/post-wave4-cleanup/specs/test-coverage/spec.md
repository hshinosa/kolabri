## ADDED Requirements

### Requirement: Test coverage documented for Wave 1-4 features
The system SHALL provide a test coverage matrix in `docs/test-coverage-wave1-4.md`.

#### Scenario: Coverage matrix structure
- **WHEN** coverage document is generated
- **THEN** matrix SHALL have rows for each Wave 1-4 feature
- **AND** columns SHALL be: Feature, Unit Tests, Integration Tests, E2E Tests, Notes

#### Scenario: Coverage status indicated
- **WHEN** a feature's test coverage is assessed
- **THEN** status SHALL be one of: ✅ (covered), ⚠️ (partial), ❌ (missing)

#### Scenario: Test file links provided
- **WHEN** a feature has tests
- **THEN** coverage matrix SHALL link to test files

### Requirement: Coverage gaps identified
The system SHALL identify features with missing or partial test coverage.

#### Scenario: Missing unit tests flagged
- **WHEN** a feature has no unit tests
- **THEN** status SHALL be ❌ in Unit Tests column
- **AND** notes SHALL explain why tests are missing

#### Scenario: Partial coverage flagged
- **WHEN** a feature has some but not all critical paths tested
- **THEN** status SHALL be ⚠️
- **AND** notes SHALL list untested paths

### Requirement: Wave 1-4 features enumerated
The system SHALL list all features implemented in Wave 1-4.

#### Scenario: Auth features listed
- **WHEN** coverage document is generated
- **THEN** auth features SHALL include: login, logout, JWT refresh, role-based access

#### Scenario: Student features listed
- **WHEN** coverage document is generated
- **THEN** student features SHALL include: courses, groups, reflections, AI chat, profile

#### Scenario: Lecturer features listed
- **WHEN** coverage document is generated
- **THEN** lecturer features SHALL include: courses, session mgmt, analytics, AI settings

#### Scenario: Admin features listed
- **WHEN** coverage document is generated
- **THEN** admin features SHALL include: user mgmt, master data, audit log, UX features (breadcrumb, pagination, skeleton, dark mode, keyboard shortcuts, global search, notification center)
