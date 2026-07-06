## MODIFIED Requirements

### Requirement: Goal must cohere with week title and week materials

When a student submits a learning goal for a chat space, the system SHALL evaluate coherence against the space week's title and materials assigned to that week. Validation MUST be permissive: varied goals are allowed when still plausibly related to that week corpus. Goal validation and refinement execution SHALL use the platform's unified provider resolution path rather than ai-engine-local provider envs as an independent runtime source of truth.

#### Scenario: Accept coherent goal

- **WHEN** submitted goal relates to week title and/or assigned week materials without being an unrelated topic
- **THEN** the system accepts the goal and proceeds per existing Bloom flow

#### Scenario: Reject with Socratic hint

- **WHEN** submitted goal is not coherent with the week context
- **THEN** the system rejects or requests revision with a Socratic hint that references the student's draft and week context and MUST NOT propose a replacement goal topic unless the draft is severely off-topic

#### Scenario: Severely off-topic

- **WHEN** goal clearly targets another week's topic with no reasonable link to current week materials
- **THEN** the system responds with hints steering back to the current week without supplying a full example goal for a different topic

#### Scenario: Goal validation uses authoritative provider resolution

- **WHEN** the system validates or refines a goal for a chat space
- **THEN** the request is executed using provider configuration resolved from the authoritative platform provider source rather than ai-engine-local provider env defaults

### Requirement: Goal validation response exposed to client

When validation requests revision, the API response SHALL include `status: revise` (or equivalent) and `socratic_hint` text for display on the goal form. The system MUST NOT omit the hint when returning a validation failure.

#### Scenario: Client shows hint on revise

- **WHEN** goal submission fails week coherence validation
- **THEN** the student goal UI displays the Socratic hint and preserves the student's draft content for editing
