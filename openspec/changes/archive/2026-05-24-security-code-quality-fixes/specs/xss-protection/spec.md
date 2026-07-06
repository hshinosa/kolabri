## ADDED Requirements

### Requirement: User-generated HTML content MUST be sanitized before rendering

The system SHALL sanitize all user-generated HTML content before rendering in the browser to prevent XSS attacks. Direct use of `dangerouslySetInnerHTML` without sanitization is prohibited.

#### Scenario: Malicious script tags removed
- **WHEN** user-generated content contains `<script>` tags
- **THEN** script tags are stripped before rendering

#### Scenario: Event handlers removed
- **WHEN** user-generated content contains inline event handlers (onclick, onerror, etc.)
- **THEN** event handlers are removed before rendering

#### Scenario: Dangerous attributes removed
- **WHEN** user-generated content contains dangerous attributes (href="javascript:", data attributes with code)
- **THEN** dangerous attributes are sanitized or removed

### Requirement: Sanitization MUST use DOMPurify library

The system SHALL use DOMPurify library for HTML sanitization with strict configuration that allows only safe tags and attributes.

#### Scenario: DOMPurify applied to search highlights
- **WHEN** search results include highlighted content
- **THEN** highlighted HTML is sanitized through DOMPurify before rendering

#### Scenario: DOMPurify applied to chat messages
- **WHEN** chat messages include formatted content
- **THEN** content is sanitized through DOMPurify before rendering

### Requirement: Sanitization MUST preserve safe formatting

Sanitization SHALL preserve safe HTML formatting (bold, italic, links, lists) while removing dangerous content.

#### Scenario: Safe formatting preserved
- **WHEN** content includes `<b>`, `<i>`, `<a>`, `<ul>`, `<li>` tags
- **THEN** safe tags are preserved after sanitization

#### Scenario: Safe links preserved
- **WHEN** content includes links with http/https protocols
- **THEN** links are preserved with target="_blank" and rel="noopener noreferrer"
