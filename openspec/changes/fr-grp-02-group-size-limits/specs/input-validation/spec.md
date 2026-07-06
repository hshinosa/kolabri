## ADDED Requirements

### Requirement: Group size policy inputs must be validated consistently
The system SHALL validate course group size policy inputs and membership mutation requests with rules that preserve valid member limits and actionable error responses.

#### Scenario: Invalid minimum and maximum limits are rejected
- **WHEN** a client submits group size settings where the minimum is less than 1 or the maximum is less than the minimum
- **THEN** the system rejects the request with structured validation errors describing the invalid fields

#### Scenario: Membership request returns policy-aware validation feedback
- **WHEN** a create, join, invite, or leave request fails because it would violate configured group limits
- **THEN** the system returns an error payload that identifies the policy violation and the allowed member range
