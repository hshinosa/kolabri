## ADDED Requirements

### Requirement: Residual product surfaces must not remain as live app entry points
The system SHALL NOT expose student analytics dashboard, reflection template/tag management, AI chat bookmark/template management pages, admin course template library, or plan-vs-diskusi UI as live authenticated product routes.

#### Scenario: Student cannot open analytics dashboard as product route
- **WHEN** a student navigates to the former student analytics dashboard path
- **THEN** the application does not render that product feature (route absent or non-product response)

#### Scenario: Admin cannot manage course template library via product UI
- **WHEN** an admin uses master-data product UI
- **THEN** no course-template library management flow is available as a supported product surface

### Requirement: Core collaborative flows remain available
Removing residual Future Works code SHALL NOT remove UC-inti flows (auth, join course/group, session create, pre-read, shared goal, discussion, reflection submit, personal AI chat, lecturer analytics, admin AI config).

#### Scenario: Student personal AI chat remains
- **WHEN** a student opens personal AI chat
- **THEN** they can create a chat and stream messages without requiring bookmark or template-management pages
