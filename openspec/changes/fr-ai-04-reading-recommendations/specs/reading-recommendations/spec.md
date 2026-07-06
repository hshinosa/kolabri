## ADDED Requirements

### Requirement: The system shall generate structured reading recommendations from course knowledge sources
The system SHALL produce a ranked list of recommended readings from the active course knowledge base when a valid recommendation request is made.

#### Scenario: Relevant recommendations are returned
- **WHEN** a student or system requests reading recommendations for a topic with matching course material
- **THEN** the system returns one or more ranked recommendation items sourced from the course knowledge base

#### Scenario: Recommendations use approved course sources only
- **WHEN** recommendations are generated
- **THEN** each recommendation is derived from course-approved knowledge sources for that course

### Requirement: Each recommendation must explain why it was selected
The system SHALL return structured metadata for each recommendation including source identity and recommendation rationale.

#### Scenario: Recommendation item includes rationale
- **WHEN** the system returns a recommendation item
- **THEN** the item includes source title, relevance rationale, and a suggested next reading action

### Requirement: The system must handle low-relevance cases safely
The system SHALL avoid low-confidence recommendations and provide fallback guidance when the course knowledge base does not contain sufficient matching material.

#### Scenario: No relevant material found
- **WHEN** the course knowledge base does not contain material relevant to the requested topic
- **THEN** the system returns a no-result response with guidance to refine the topic or ask the lecturer to upload additional material
