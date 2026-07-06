## ADDED Requirements

### Requirement: Search inputs MUST be sanitized as defense-in-depth

FULLTEXT BOOLEAN MODE search queries SHALL sanitize BOOLEAN MODE operators as an additional security layer. Note: queries are already parameterized (not SQL injectable), so this is defense-in-depth only.

#### Scenario: Alphanumeric search terms pass through safely
- **WHEN** user searches for "react hooks tutorial"
- **THEN** system executes FULLTEXT query with sanitized input
- **AND** query returns relevant messages containing those keywords

#### Scenario: Boolean operators are stripped from input (defense-in-depth)
- **WHEN** user searches for "test* OR 1=1 --"
- **THEN** system removes BOOLEAN MODE operators: `*`, `+`, `-`, `@`, `>`, `<`, `(`, `)`, `~`, `"`
- **AND** sanitized input becomes "test OR 1=1 "
- **AND** parameterized query executes safely (already safe via bound parameters)

#### Scenario: Special characters are neutralized
- **WHEN** user searches for "+urgent -spam @recent"
- **THEN** system sanitizes to "urgent spam recent" (removes +, -, @)
- **AND** BOOLEAN MODE operators cannot be injected
- **AND** normal punctuation (.,!?:;/) is preserved

#### Scenario: Indonesian/English punctuation is preserved
- **WHEN** user searches for "react.js, AI/ML!"
- **THEN** system keeps punctuation: `.`, `,`, `/`, `!`
- **AND** only BOOLEAN MODE operators are removed
- **AND** search returns relevant results

#### Scenario: LIKE fallback uses correct exception handling
- **WHEN** FULLTEXT query fails (e.g., index not available)
- **THEN** catch block catches `QueryException` (NOT `ConnectionException`/`RequestException`)
- **AND** LIKE fallback executes with parameterized query
- **AND** fallback is NOT dead code

#### Scenario: Empty search input is handled gracefully
- **WHEN** user submits empty or whitespace-only search
- **THEN** system returns empty result set (not database error)
- **AND** does NOT execute query against database

---

### Requirement: File uploads MUST validate MIME types (verify existing)

Course knowledge base file uploads ALREADY enforce MIME type whitelist via Laravel `mimetypes:` rule. This requirement verifies the existing validation is comprehensive and reconciles the whitelist.

#### Scenario: Allowed document types upload successfully (EXISTING)
- **WHEN** user uploads PDF, DOCX, XLSX, PPTX, TXT, images, or ZIP file
- **THEN** Laravel `mimetypes:` validation accepts file
- **AND** file is stored securely
- **AND** response includes file URL

#### Scenario: Executable files are rejected (EXISTING)
- **WHEN** user attempts to upload .php, .sh, .exe, or .js file
- **THEN** Laravel validation rejects upload with 422 status
- **AND** no file is written to storage

#### Scenario: Whitelist is reconciled between code and spec
- **WHEN** reviewing allowed MIME types
- **THEN** whitelist includes ALL of: PDF, DOC/DOCX, XLS/XLSX, PPT/PPTX, TXT, Markdown, images (png/jpeg/gif/webp), ZIP
- **AND** older Office formats (application/msword, application/vnd.ms-excel, application/vnd.ms-powerpoint) are included
- **AND** any other MIME type is rejected

---

### Requirement: Files MUST be stored in private disk

Uploaded knowledge base files SHALL be stored in Laravel private storage (not public) to prevent direct URL access.

#### Scenario: Files stored in private disk
- **WHEN** validated file is accepted
- **THEN** system stores using: `->storeAs('knowledge-base', $name, 'private')`
- **AND** file is NOT accessible via direct URL (http://domain.com/storage/file.pdf)
- **AND** file can only be served through authenticated endpoint

#### Scenario: Public disk is NOT used for uploads
- **WHEN** reviewing storage configuration
- **THEN** knowledge base files use 'private' disk
- **AND** 'public' disk is NOT used for user-uploaded content
- **AND** prevents direct file execution via web server

#### Scenario: File serving requires authentication
- **WHEN** user requests to view/download knowledge base file
- **THEN** request goes through authenticated controller endpoint
- **AND** system validates user has access to the course
- **AND** file is streamed through Laravel (not direct web server access)

---

### Requirement: Input sanitization MUST be defense-in-depth

Multiple validation layers SHALL be applied to prevent bypasses through single-point failures.

#### Scenario: Search input has both sanitization AND parameterization
- **WHEN** search query is processed
- **THEN** input is sanitized first (remove special chars)
- **AND** sanitized input is passed through parameterized query
- **AND** both layers provide protection (defense-in-depth)

#### Scenario: File upload has both extension AND MIME checks
- **WHEN** file is uploaded
- **THEN** Laravel validates file extension (mimes: rule)
- **AND** additional code validates MIME type from content
- **AND** both checks must pass (redundant security)

#### Scenario: Validation failure does NOT expose internal details
- **WHEN** input validation fails
- **THEN** error message is generic: "Invalid input" or "Invalid file type"
- **AND** does NOT reveal: database structure, file paths, server details
- **AND** sensitive error details logged server-side only

---

### Requirement: Validation errors MUST be tested with attack payloads

Security validation SHALL be verified against known attack vectors before deployment.

#### Scenario: SQL injection payloads are blocked
- **WHEN** testing search input validation
- **THEN** system MUST successfully block these payloads:
  - `test* OR 1=1 --` → BOOLEAN operators removed, parameterized query safe
  - `'; DROP TABLE messages; --` → parameterized query prevents injection
  - `+malicious -benign` → BOOLEAN operators removed
  - `test'; UPDATE users SET admin=1 WHERE 1=1; --` → parameterized query prevents injection
- **AND** no database modification occurs
- **AND** queries execute safely or fail gracefully

#### Scenario: RCE file uploads are rejected
- **WHEN** testing file upload validation
- **THEN** system MUST successfully reject these file types:
  - `shell.php` (PHP script)
  - `exploit.sh` (shell script)
  - `malware.exe` (Windows executable)
  - `malicious.php.pdf` (double extension)
- **AND** no file is written to storage
- **AND** validation error is returned

#### Scenario: Path traversal is prevented
- **WHEN** testing file upload with malicious filename
- **THEN** filename "../../../etc/passwd" is sanitized
- **AND** file is stored with safe filename only
- **AND** path traversal attack is neutralized
