## Context

Interview evidence from Pak Dana Lanjutan points to configurable metrics for discussion monitoring, such as participation, engagement, or self-regulated learning indicators, potentially visualized in radar charts. The request is not for a full LMS-gradebook replacement; it is for flexible observation dimensions that fit different courses. Because this area has high implementation and product-definition complexity, the feature is intentionally on hold while implementation details are documented.

## Goals / Non-Goals

**Goals:**
- Capture a feasible technical shape for configurable course metrics and rubric dimensions.
- Limit v1 scope to discussion/session monitoring rather than institution-wide grading.
- Identify dependencies and complexity before commitment.

**Non-Goals:**
- Immediate implementation.
- Full exam/assignment grading replacement.
- Unbounded formula-builder complexity in v1.

## Decisions

### Start with rubric templates plus weighted metric slots
V1 should favor a constrained configuration model: lecturers choose or edit a small set of rubric dimensions and optional weights instead of building arbitrary formulas. This reduces authoring complexity and improves explainability.

### Separate raw signals from scoring interpretation
The system should collect reusable raw signals (message count, reply depth, response latency, intervention rate, participation distribution, etc.) and map them into course-defined rubric dimensions through a scoring layer. This avoids recomputing analytics logic for each course.

### Keep scoring focused on monitoring first
The first supported outcome should be monitoring-oriented scores and charts, not official grade submission. That matches the interview evidence and limits policy risk.

### Put the feature on hold pending metric taxonomy agreement
Before coding, product and academic stakeholders need agreement on which raw signals are valid proxies for engagement, collaboration quality, and related constructs.

## Risks / Trade-offs

- **Metric validity may be disputed pedagogically** → Require agreed rubric templates before implementation.
- **Configuration UX can become too complex** → Start with constrained templates and weighted dimensions.
- **Course comparability may drop** → Preserve optional default rubric templates for cross-course baselines.
- **Scoring may be mistaken for official grading truth** → Label outputs as monitoring/decision-support unless explicit grading workflow is later added.

## Migration Plan

1. Keep change on hold.
2. Validate metric taxonomy and rubric templates with academic stakeholders.
3. Inventory available raw signals from discussion and analytics systems.
4. Re-open with scoped implementation only after taxonomy and UX boundaries are approved.

## Open Questions

- Which raw signals are already reliable enough for rubric scoring?
- Which rubric dimensions are mandatory platform-wide vs course-specific?
- Does v1 output only charts/monitoring, or also assessment-ready summaries?
