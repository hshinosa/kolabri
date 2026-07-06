## Context

Kolabri already supports lecturer-managed courses, student groups, join codes, and membership management, but group size policy is implicit and unenforced. Interview evidence shows lecturers need explicit minimum and maximum member constraints so courses can prevent undersized groups, oversized groups, and ambiguous self-organization outcomes. The change affects relational data, API validation, service-layer membership rules, and both lecturer/student UI flows.

## Goals / Non-Goals

**Goals:**
- Add course-level `minMembers` and `maxMembers` policy with sensible defaults.
- Enforce the policy consistently during group creation, join, and invite/accept flows.
- Show current policy and actionable validation feedback in lecturer and student UI.
- Preserve existing course/group behavior for courses that do not customize limits.

**Non-Goals:**
- Automatic group balancing or reassignment.
- Instructor approval workflows for over-capacity exceptions.
- Retroactive forced deletion of existing groups that temporarily violate a newly edited policy.

## Decisions

### Store limits on the course record
Group size constraints will live at the course level, not per-group, because the requirement is a course policy and should apply uniformly across all groups in the class. This keeps configuration simple and avoids inconsistent rules between groups in the same course.

**Alternatives considered:**
- Per-group limits: rejected because it increases lecturer setup complexity and weakens course-wide consistency.
- Global platform defaults only: rejected because interview evidence asks for lecturer/course control.

### Enforce limits in service layer and validation layer
Request validation will verify numeric shape and basic invariants (`minMembers >= 1`, `maxMembers >= minMembers`). Service-layer enforcement will verify live membership counts before create/join/invite mutations complete. This splits static input validation from runtime state validation.

**Alternatives considered:**
- Validation-only approach: rejected because request schema cannot determine current member counts.
- Database-only constraints: rejected because cross-row membership capacity checks need clearer domain errors and UI feedback.

### Use non-breaking defaults for existing courses
Existing courses will receive defaults that preserve current behavior as closely as possible, with limits set wide enough to avoid immediate disruption while still enabling future enforcement. This avoids breaking active courses during rollout.

**Alternatives considered:**
- Require lecturers to configure all existing courses manually: rejected due to rollout friction.
- Hard migration based on current group sizes: rejected because historical data may be inconsistent.

### Block operations that would worsen violations, but do not auto-fix old data
If a course policy changes and an existing group is already outside the target range, the system will not silently delete members or dissolve groups. Instead, new operations that would worsen the violation will be blocked, and lecturer/student UI can surface the mismatch for manual correction.

**Alternatives considered:**
- Auto-remove extra members: rejected as unsafe and user-hostile.
- Ignore old violations entirely: rejected because policy would become non-credible.

## Risks / Trade-offs

- **Existing data may already violate new limits** → Use conservative defaults and prevent worsening changes rather than auto-migrating membership.
- **Multiple join attempts may race past max capacity** → Re-check capacity in transactional service logic before commit.
- **Student confusion about why join failed** → Return domain-specific error messages and show allowed range in UI before the action.
- **Lecturer sets unrealistic limits** → Validation must reject impossible values and UI should explain effects clearly.

## Migration Plan

1. Add nullable or defaulted course-level limit fields in Prisma migration.
2. Backfill existing courses with safe default values.
3. Update create/update course flows so lecturers can manage the policy.
4. Enforce limits in group create/join/invite services.
5. Surface limits and validation feedback in lecturer and student UI.
6. Monitor for courses/groups with violations after rollout and correct manually if needed.

Rollback: remove service enforcement first if the migration is retained; if full rollback is needed, revert UI usage and Prisma fields in a reverse migration after data review.

## Open Questions

- What default range best matches current institutional expectation (for example 2–5 vs 3–5)?
- Should lecturers be allowed to save a new policy that conflicts with existing groups, or should the update itself be blocked until groups are corrected?
- Which join flows exist today beyond direct join code (invite accept, manual assignment, group creation), and should all of them fail symmetrically with the same error shape?
