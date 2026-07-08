## ADDED Requirements

### Requirement: Core UI copy uses consistent Indonesian terminology
The system SHALL present primary navigation labels, major headings, and core workflow actions in consistent Indonesian across lecturer, student, and admin areas.

#### Scenario: navigation labels are localized consistently
- **WHEN** a user opens the lecturer, student, or admin interface
- **THEN** major navigation labels use Indonesian terminology such as `Analitik`, `Dasbor`, `Kelola Pengguna`, `Pengaturan AI`, and `Log Audit`
- **AND** no primary navigation entry mixes English and Indonesian for the same concept.

### Requirement: Academic collaboration terms stay consistent in learner flows
The system SHALL use consistent learner-facing terminology for academic collaboration concepts.

#### Scenario: student and lecturer collaboration wording matches
- **WHEN** a lecturer or student sees course, group, session, or pre-read surfaces
- **THEN** visible collaboration wording uses `kelas`, `kelompok`, and `mahasiswa` consistently where appropriate
- **AND** learner-facing copy does not switch between `grup` and `kelompok` within the same workflow without reason.

### Requirement: Admin management copy is localized without altering technical configuration meaning
The system SHALL localize admin workflow copy while preserving external-provider technical field meaning.

#### Scenario: AI provider management remains recognizable
- **WHEN** an admin manages AI providers
- **THEN** workflow labels, actions, and headings are presented in Indonesian
- **AND** technical field names that directly map to external provider configuration may retain recognizable terms such as `API key`, `Base URL`, and `JSON`
- **AND** no API contract or configuration payload changes because of the copy update.

### Requirement: Frontend-only copy refinement does not alter behavior
The system SHALL keep existing frontend behavior, routes, and request payloads intact while updating copy.

#### Scenario: copy changes do not affect workflows
- **WHEN** a user performs an unchanged action such as joining a class, creating a group, filtering users, or testing an AI provider
- **THEN** the workflow behavior remains unchanged
- **AND** only visible text differs from the prior version.