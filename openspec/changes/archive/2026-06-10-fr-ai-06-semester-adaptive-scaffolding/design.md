## Context

The requested behavior is not general personalization for its own sake; it is pedagogical scaffolding that changes by academic maturity. Existing AI infrastructure can likely answer questions and intervene, but it does not appear to incorporate student semester as a first-class input to response shaping.

**Adjusted (2026-06-10):** Semester data exists only on Course (semester: "Ganjil"|"Genap", academicYear). No per-student semester/progress field on User or CourseStudent. Context is course-scoped (same pattern as aiGuardrailConfig). The offering's semester/academicYear (or lecturer-selected cohort level) acts as the band for the students in that course. This change needs course context propagation (already partially present for guardrails), policy controls, and deterministic prompt behavior by semester/cohort band.

## Goals / Non-Goals

**Goals:**
- Adjust AI guidance depth based on course offering semester / cohort band (early vs late scaffolding needs).
- Keep adaptation explainable and bounded by course policy.
- Allow lecturer to constrain or override via course settings (same surface as guardrails).

**Non-Goals:**
- Fully personalized long-term student modeling or per-student semester tracking.
- Replacing all AI prompt strategies with a new tutoring framework.
- Adding student profile fields for academic stage.

## Decisions

### Use course-offering semester/cohort bands rather than per-student opaque scoring
Course.semester + academicYear (or explicit lecturer "cohortLevel" in settings) is the available, simple, institutionally understandable signal. This matches the guardrail policy pattern (course-scoped JSON) and avoids needing new student data. Traceable to interview evidence at cohort level.

### Apply adaptation at prompt policy level (reuse guardrail injection)
The first implementation should change the AI's prompting/response style (extend prompt_styles + orchestration context) rather than branch into separate product flows. Reuse the exact guardrail_policy passing mechanism (socket → aiEngine.service → orchestration kwargs → rag/guardrails).

### Keep lecturer/course policy in the loop
Add course-level scaffolding config (parallel to aiGuardrailConfig) so courses can constrain or disable specific bands. Baseline safety always on.

### Scaffolding Config Shape (mirrors guardrail pattern)
Use a JSONB column `aiScaffoldingConfig` on Course (same as `aiGuardrailConfig`).
Example shape:
```json
{
  "scaffoldingLevel": "early" | "late" | "auto",
  "enabled": true
}
```
- `scaffoldingLevel`: "early" = more guided/step-by-step; "late" = source-based/independent; "auto" = derive from Course.semester + academicYear (Ganjil/early year → early, Genap/later → late).
- `enabled`: master toggle (false = fall back to uniform behavior for this course).
- Lecturer can override via settings UI (same surface as guardrails).

## Risks / Trade-offs

- **Semester is an imperfect proxy for skill** → Start with broad bands and allow policy override.
- **Too much scaffolding may encourage dependence** → Use bounded prompt templates and bias later semesters toward source-based guidance.
- **Too little scaffolding may frustrate beginners** → Ensure early-semester bands include clearer stepwise support.

## Migration Plan

1. Ensure course semester + academicYear (or derived band) context is available in AI orchestration inputs (piggyback on existing course fetch + guardrail_policy path in socket/index.ts and aiEngine.service.ts; see handleAIQuestion for the exact fetch + orchestratedChat call site).
2. Define semester/cohort bands (early/late + auto) and associated response policies (new or extended prompt styles/templates in ai-engine).
3. Add course-level policy visibility/constraints: add `aiScaffoldingConfig` JSONB (parallel migration to guardrail), update validator/service (course.validator.ts + course.service.ts), UI mirroring guardrails in lecturer/courses/show.tsx + CourseController + course.service.ts.
4. Record band/policy used in logs (reuse mongo activity log + AuditLog patterns; include in OrchestrationResult).
5. Test behavior across representative prompts for early- and late-cohort courses (unit + integration through orchestrated chat).

Rollback: disable adaptive policy and fall back to current uniform AI behavior.

## Open Questions (resolved/adjusted)

- Bands: "early" (guided, step-by-step, more scaffolding) vs "late" (source-based, independent reasoning). "auto" derives from Course.semester ("Ganjil" → early) + academicYear progression or lecturer override in settings.
- Key off: course semester/cohort level (not per-student). Role/course level already partially available via existing context.
- Config stored as `aiScaffoldingConfig` JSONB on Course (exact parallel to `aiGuardrailConfig`).
