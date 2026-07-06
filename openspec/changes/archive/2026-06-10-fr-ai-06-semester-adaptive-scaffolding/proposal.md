## Why

Pak Ive's interview highlights that AI assistance should not feel identical for every student level: beginner students may need more guided scaffolding, while advanced students should be pushed toward independent reasoning and source-based learning. Current AI support appears course-aware but not semester-adaptive, so the same interaction style risks being either too spoon-feeding or too hands-off.

**Clarification (adjusted 2026-06-10):** Semester context is provided at the *course offering* level (Course.semester + academicYear, e.g. "Ganjil 2024/2025"). This serves as a cohort-level proxy for maturity/scaffolding needs of students in that offering. No per-student academic stage data exists in User/CourseStudent models.

**Config & Band Definition (tweaked for concreteness):**
- New course JSONB: `aiScaffoldingConfig` = `{ "scaffoldingLevel": "early" | "late" | "auto", "enabled": boolean }`.
- "early": more guided, step-by-step scaffolding.
- "late": less directive, source-based, independent reasoning.
- "auto": derive from Course.semester ("Ganjil" = early) + academicYear.
- Lecturer can override via settings (parallel to aiGuardrailConfig UI).

## What Changes

- Add semester-aware AI scaffolding behavior at course-cohort level.
- Adjust prompt strategy, response style, and intervention depth based on the course's semester band (early/late in the offering or program stage).
- Keep adaptation bounded by lecturer/course policy rather than fully opaque personalization.
- Make the adaptation behavior auditable and predictable.

## Capabilities

### New Capabilities
- `semester-adaptive-scaffolding`: Adjust AI guidance depth based on course offering semester / cohort band.

### Modified Capabilities
- `settings`: Extend AI-related course settings to define or constrain semester-based scaffolding behavior (parallel to ai_guardrail_*; new `aiScaffoldingConfig` with scaffoldingLevel + enabled).

## Impact

- `Kolabri-core-api`: pass course semester/academicYear (already on Course model) + policy/config support alongside existing guardrail_policy injection.
- `Kolabri-ai-engine`: prompt orchestration and response policy by semester/cohort band (reuse guardrail_context + prompt_styles pattern).
- `Kolabri-client-app`: lecturer settings visibility (mirror guardrail UI) and possibly student-facing explanation of AI guidance style.
