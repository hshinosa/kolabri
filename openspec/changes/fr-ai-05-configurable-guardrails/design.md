## Context

Current AI safety controls appear to exist as platform-level primitives, but course staff cannot tune them based on pedagogical context. Some courses may want stricter intervention, others may prefer softer warnings. The feature therefore needs a policy layer above the existing detection mechanisms, connected to course settings and request-time enforcement.

## Goals / Non-Goals

**Goals:**
- Let lecturers configure course-level guardrail policy.
- Apply policy consistently during AI interactions within that course.
- Provide auditable outcomes for blocked, flagged, or rewritten responses.

**Non-Goals:**
- End-user custom policy per student.
- Building entirely new detection models from scratch.
- Replacing platform-wide baseline security controls.

## Decisions

### Store guardrail policy at course scope
Course scope matches the teaching context and allows lecturers to align guardrail strictness with course objectives while preserving common baseline platform protection. The initial policy surface should stay constrained to presets and key toggles rather than a fully custom rule builder.

### Separate baseline safety from lecturer-tunable policy
Critical platform safeguards remain always on, while lecturer policy can tune behavior such as warning-only, block, or escalate for non-critical categories through a constrained preset/toggle model.

### Record structured guardrail outcomes
Each guarded request should produce structured audit metadata so teams can explain why an answer was blocked or modified and improve policy later.

## Risks / Trade-offs

- **Too much configurability may confuse lecturers** → Start with a constrained set of policy profiles and key toggles.
- **Overly strict policy may reduce usefulness** → Preserve preview/explanation messaging and audit visibility.
- **Policy drift across courses may complicate support** → Keep immutable baseline protections and document presets.

## Migration Plan

1. Add course-level policy storage.
2. Define preset/default policy for existing courses.
3. Wire policy into AI orchestration path.
4. Add lecturer configuration UI and audit visibility.

Rollback: revert UI access and ignore course-level policy while retaining baseline global protections.

## Open Questions

- Which categories should be lecturer-tunable vs always enforced globally?
- Which small set of presets and toggles should be supported in v1?
