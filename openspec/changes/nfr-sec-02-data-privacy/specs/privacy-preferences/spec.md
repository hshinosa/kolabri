## ADDED Requirements

### Requirement: Privacy preference fields
The system SHALL add privacy preference fields to user settings: analyticsVisibility (boolean), aiInteractionConsent (boolean), dataSharingConsent (boolean).

#### Scenario: Default privacy preferences
- **WHEN** a new user is created
- **THEN** analyticsVisibility defaults to false, aiInteractionConsent defaults to false, dataSharingConsent defaults to false

### Requirement: Update privacy preferences
The system SHALL expose PUT /api/user/privacy-preferences accepting analyticsVisibility, aiInteractionConsent, and dataSharingConsent as boolean fields.

#### Scenario: Update privacy preferences
- **WHEN** authenticated user sends PUT /api/user/privacy-preferences with valid boolean values
- **THEN** system updates the preferences and returns 200 with updated values

#### Scenario: Invalid preference value
- **WHEN** user sends a non-boolean value for any preference field
- **THEN** system returns 400 with validation error

### Requirement: Get privacy preferences
The system SHALL expose GET /api/user/privacy-preferences returning the current privacy preferences for the authenticated user.

#### Scenario: Fetch privacy preferences
- **WHEN** authenticated user sends GET /api/user/privacy-preferences
- **THEN** system returns 200 with analyticsVisibility, aiInteractionConsent, dataSharingConsent values

### Requirement: Consent check before AI interaction
The system SHALL check aiInteractionConsent before processing AI chat requests. If consent is not granted, the system SHALL return 403 with a message directing the user to grant consent.

#### Scenario: AI interaction with consent
- **WHEN** user sends AI chat request and aiInteractionConsent is true
- **THEN** system processes the request normally

#### Scenario: AI interaction without consent
- **WHEN** user sends AI chat request and aiInteractionConsent is false
- **THEN** system returns 403 with message "AI interaction consent required. Update privacy preferences to enable."
