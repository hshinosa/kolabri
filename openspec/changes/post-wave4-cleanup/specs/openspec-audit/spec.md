## ADDED Requirements

### Requirement: All OpenSpec changes categorized
The system SHALL document the status of all changes in `openspec/changes/`.

#### Scenario: Change status determined
- **WHEN** auditing a change directory
- **THEN** status SHALL be one of: **Complete**, **Archived**, **In-Progress**

#### Scenario: Complete changes identified
- **WHEN** a change has all artifacts done and is implemented in codebase
- **THEN** status SHALL be **Complete**

#### Scenario: Archived changes identified
- **WHEN** a change is superseded, cancelled, or no longer relevant
- **THEN** status SHALL be **Archived**
- **AND** reason for archival SHALL be documented

#### Scenario: In-Progress changes identified
- **WHEN** a change has incomplete artifacts or is not fully implemented
- **THEN** status SHALL be **In-Progress**
- **AND** blocking issues SHALL be documented

### Requirement: Audit results documented
The system SHALL provide a structured audit report in `docs/openspec-audit.md`.

#### Scenario: Audit report structure
- **WHEN** audit is complete
- **THEN** report SHALL contain a table with columns: Change Name, Status, Reason/Notes, Next Steps

#### Scenario: Audit report completeness
- **WHEN** audit report is generated
- **THEN** all 21 changes in `openspec/changes/` SHALL be listed
- **AND** each change SHALL have a status and notes

### Requirement: Incomplete changes have action items
The system SHALL identify next steps for In-Progress changes.

#### Scenario: Blocked change documented
- **WHEN** a change is In-Progress due to blocking issue
- **THEN** blocking issue SHALL be documented
- **AND** resolution path SHALL be proposed
