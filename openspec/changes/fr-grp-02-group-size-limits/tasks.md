## 1. Data Model and API Contract

- [x] 1.1 Add course-level minimum and maximum group member fields in Prisma schema and create the migration/backfill strategy for existing courses
- [x] 1.2 Update core API validation schemas and DTOs for course group size settings input and policy-aware error responses

## 2. Membership Rule Enforcement

- [x] 2.1 Enforce configured member limits in group creation flows
- [x] 2.2 Enforce configured member limits in join and invite-based membership flows, including over-capacity rejection
- [x] 2.3 Enforce minimum-member policy for leave or removal flows without auto-deleting existing groups

## 3. Lecturer and Student UX

- [x] 3.1 Add lecturer UI to view and edit course group size limits
- [x] 3.2 Show current allowed member range in student group discovery, creation, and join flows
- [x] 3.3 Surface actionable validation messages when a group action violates course policy

## 4. Verification and Rollout

- [x] 4.1 Add tests for valid and invalid limit configuration plus membership edge cases
- [x] 4.2 Verify existing courses/groups continue to work with default backfilled limits and document any manual cleanup needs

Notes:
- Migration backfills existing courses with non-breaking defaults (`min_members_per_group = 1`, `max_members_per_group = 1000`), so no manual cleanup is required for existing groups during rollout.
