## Why

Lecturers need explicit control over minimum and maximum group size so class collaboration rules match course policy and free-form self-organization does not produce undersized or oversized groups. The current join-code and membership flows allow group participation, but they do not encode or enforce course-level size constraints.

## What Changes

- Add course-level configuration for minimum and maximum members per group.
- Enforce group size constraints when students create, join, or invite members into groups.
- Surface validation feedback in lecturer and student flows when a group violates configured limits.
- Expose current group size policy in relevant UI so students understand allowed membership ranges before joining.

## Capabilities

### New Capabilities
- `group-size-limits`: Define and enforce course group membership limits across configuration and join flows.

### Modified Capabilities
- `input-validation`: Extend validation behavior to reject group operations that would violate configured member limits.

## Impact

- `Kolabri-core-api`: Prisma schema, group/join/invite services, request validation, course/group APIs.
- `Kolabri-client-app`: lecturer course/group settings UI, student group join/create flows, validation/error states.
- Data model/backfill considerations for existing courses and groups.
