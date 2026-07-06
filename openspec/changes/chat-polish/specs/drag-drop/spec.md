## MODIFIED Requirements

### Requirement: Drag & Drop File Upload
The chat room SHALL support drag & drop file upload.

#### Scenario: User drags file over chat area
- **WHEN** user drags a file over the chat message area
- **THEN** a drop zone overlay SHALL appear with visual feedback
- **AND** the overlay SHALL show "Drop file di sini" text
- **AND** the overlay SHALL have a dashed border animation

#### Scenario: User drops file
- **WHEN** user drops a file on the drop zone
- **THEN** the file SHALL be added to pending files
- **AND** the drop zone SHALL disappear
- **AND** file preview SHALL appear in the input area

#### Scenario: User drags multiple files
- **WHEN** user drops multiple files at once
- **THEN** all files SHALL be added to pending files
- **AND** each file SHALL have its own preview

#### Scenario: Invalid file type
- **WHEN** user drops an unsupported file type
- **THEN** an error message SHALL appear
- **AND** the file SHALL NOT be added to pending files
