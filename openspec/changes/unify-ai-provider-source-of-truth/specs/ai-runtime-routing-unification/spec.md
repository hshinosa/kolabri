## ADDED Requirements

### Requirement: AI-backed features SHALL use a unified provider resolution policy
The system SHALL use one provider resolution policy across personal chat, orchestration, interventions, summaries, goal validation/refinement, RAG, reading recommendations, and analytics AI flows so that admin-managed provider changes apply consistently.

#### Scenario: Admin provider change affects all migrated AI feature families
- **WHEN** an admin activates or updates the authoritative provider configuration
- **THEN** all migrated AI feature families use that resolved provider policy on subsequent requests without requiring per-feature provider reconfiguration

### Requirement: Personal chat SHALL align with the unified provider routing model
Personal chat MUST use the same authoritative provider resolution path as other migrated AI-backed features instead of relying on a separate feature-specific source of truth.

#### Scenario: Personal chat uses authoritative provider routing after migration
- **WHEN** a user sends a personal chat request after the migrated routing model is enabled
- **THEN** provider selection for that request follows the same authoritative provider resolution policy used by other migrated AI-backed features

### Requirement: Migrated ai-engine-backed features SHALL accept phased rollout controls
The system SHALL support phased rollout and rollback controls while migrating feature families from env-driven ai-engine provider resolution to unified provider routing.

#### Scenario: Feature family remains on compatibility mode during rollout
- **WHEN** a feature family has not yet completed migration verification
- **THEN** operators can keep that feature family on an explicit compatibility path without changing the authoritative provider configuration model for already-migrated features

#### Scenario: Feature family rolls back independently
- **WHEN** a migrated AI feature family shows unacceptable regression during rollout
- **THEN** operators can return that feature family to its compatibility path without disabling already-verified migrated feature families
