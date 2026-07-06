## Why

Lecturers want to define course-specific discussion monitoring metrics and rubric-style assessment dimensions instead of relying on one fixed platform scoring model. The need is valid, but the feature is broad and touches pedagogy, analytics, scoring, configuration, and reporting, so it is being documented in detail first and held before implementation.

**Status:** ON HOLD — documented for scoping and implementation planning only, not for immediate execution.

## What Changes

- Define implementation direction for lecturer-configurable monitoring metrics and rubric-based grading dimensions.
- Scope the feature around discussion/session monitoring first, not full academic grading.
- Keep the change explicitly on hold until product scope, metric definitions, and data availability are agreed.

## Capabilities

### New Capabilities
- `custom-grading-metrics`: Define and compute course-specific discussion monitoring metrics and rubric dimensions.

### Modified Capabilities
- `dashboard`: Extend analytics surfaces to show course-specific metrics and rubric outputs when enabled.

## Impact

- `Kolabri-core-api`: rubric models, scoring engine, aggregation logic, export/reporting.
- `Kolabri-ai-engine`: possible metric extraction or interpretation support.
- `Kolabri-client-app`: lecturer rubric builder, analytics visualization, score explanation UI.
