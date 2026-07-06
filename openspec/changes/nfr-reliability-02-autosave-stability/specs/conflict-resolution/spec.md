## ADDED Requirements

### Requirement: Message edits SHALL include a version field

The system SHALL include a version number in every edit payload. The version SHALL be an integer starting at 0 for new messages and incremented on each edit.

#### Scenario: First edit of a message
- **WHEN** user edits a message for the first time
- **THEN** the edit payload includes version=1

#### Scenario: Subsequent edit of a message
- **WHEN** user edits a message that is already at version=3
- **THEN** the edit payload includes version=4

### Requirement: Server SHALL reject edits with stale version

The server SHALL reject an edit if the version in the payload does not match the current version of the message on the server. The rejection SHALL include the current server version.

#### Scenario: Edit with matching version accepted
- **WHEN** client sends an edit with version matching the server version
- **THEN** the edit is accepted and the message version is incremented

#### Scenario: Edit with stale version rejected
- **WHEN** client sends an edit with version=2 but the server version is=5
- **THEN** the server rejects the edit with a conflict error containing the current version

### Requirement: Client SHALL handle version conflict by fetching latest

The system SHALL fetch the latest message version from the server when a conflict is detected and present the conflict to the user.

#### Scenario: Conflict detected on edit
- **WHEN** the server rejects an edit due to version mismatch
- **THEN** the client fetches the latest message content from the server
- **AND** shows the user the current server version alongside their attempted edit

### Requirement: Messages without version field SHALL default to version 0

For backward compatibility, messages that lack a version field SHALL be treated as version=0. The first edit on such a message SHALL set version=1.

#### Scenario: Editing a legacy message with no version
- **WHEN** user edits a message that has no version field
- **THEN** the edit payload includes version=1
- **AND** the server accepts it as a valid transition from version=0
