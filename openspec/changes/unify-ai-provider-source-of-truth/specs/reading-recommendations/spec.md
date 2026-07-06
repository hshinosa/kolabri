## MODIFIED Requirements

### Requirement: Course-page reading recommendations remain separate from session week materials

The existing course-level reading recommendation capability (topic-based request on student course page) SHALL remain available as a distinct entry point. Session chat week materials and pre-read flows MUST NOT depend on that endpoint for listing assigned week materials. Reading recommendation generation itself SHALL use the platform's unified provider resolution path rather than ai-engine-local provider envs as an independent runtime source of truth.

#### Scenario: Session materials not from topic recommendation API

- **WHEN** student views pre-read or chat materials panel
- **THEN** materials are loaded from week assignment data, not from the topic-based reading recommendation response alone

#### Scenario: Reading recommendation request uses authoritative provider resolution

- **WHEN** the system generates topic-based reading recommendations
- **THEN** the request is executed using provider configuration resolved from the authoritative platform provider source rather than ai-engine-local provider env defaults
