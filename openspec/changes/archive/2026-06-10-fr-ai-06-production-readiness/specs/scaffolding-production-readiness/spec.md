## ADDED Requirements

### Requirement: Automated tests for early/late scaffolding behavior
The system SHALL include automated tests that verify early vs late scaffolding_level selection and outcome based on course aiScaffoldingConfig.

#### Scenario: Early cohort receives guided scaffolding
- **WHEN** a course has scaffoldingLevel=early and enabled=true
- **THEN** the orchestrated response returns scaffolding_level=early and scaffolding_outcome=applied

#### Scenario: Late cohort receives independent scaffolding
- **WHEN** a course has scaffoldingLevel=late and enabled=true
- **THEN** the orchestrated response returns scaffolding_level=late and scaffolding_outcome=applied

#### Scenario: Disabled config produces disabled outcome
- **WHEN** a course has enabled=false
- **THEN** the orchestrated response returns scaffolding_outcome=disabled regardless of level

### Requirement: Official migration applied in clean environments
The system SHALL apply the 20260610_add_course_ai_scaffolding_config migration via `prisma migrate dev` or `prisma migrate deploy` in any clean checkout.

#### Scenario: Clean checkout migration succeeds
- **WHEN** a fresh checkout runs `npx prisma migrate dev`
- **THEN** the migration is recorded in _prisma_migrations with finished_at and the column exists with correct data

### Requirement: Real RAG data path verified
The system SHALL exercise the full scaffolding injection path with populated Qdrant collections (≥10 points, not empty demo collections).

#### Scenario: Scaffolding with real RAG data
- **WHEN** a course has ≥10 real points in its Qdrant collection and scaffolding enabled
- **THEN** the response contains correct scaffolding_level/outcome and action_taken reflects actual RAG fetch

### Requirement: Monitoring for scaffolding logs
The system SHALL provide a query or alert that detects anomalies in scaffolding_level/outcome distribution in mongo activity_logs. Threshold SHALL be configurable via environment variable `SCAFFOLDING_ALERT_THRESHOLD` (default 80%).

#### Scenario: Monitoring query returns recent activity
- **WHEN** an operator runs the scaffolding monitoring aggregation
- **THEN** it returns counts of early/late/applied/disabled in the last 24h

#### Scenario: Alert triggers on high disabled rate
- **WHEN** disabled outcome exceeds `SCAFFOLDING_ALERT_THRESHOLD`
- **THEN** alert is sent (email/Slack) with current distribution

### Requirement: Deployment runbook updated
The system SHALL include updated deployment documentation covering migration, test gate, RAG population, and monitoring setup. Runbook SHALL be located at `docs/deployment/runbook-scaffolding.md`.

#### Scenario: Runbook contains production steps
- **WHEN** a developer follows the production-readiness runbook
- **THEN** they can execute clean migration + test + monitoring enablement without manual intervention
