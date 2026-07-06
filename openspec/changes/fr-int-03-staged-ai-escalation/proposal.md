## Why

Current AI intervention and notification behavior can flag issues, but it does not support the staged escalation flow described in the interviews: AI should first nudge, then probe for blockers, then escalate to the lecturer only when lower-cost interventions fail. A staged escalation model is needed to avoid both under-intervention and noisy lecturer alerts.

## What Changes

- Add a staged AI escalation policy for unresolved discussion issues and inactivity.
- Track escalation state across successive interventions so repeated problems move through defined stages.
- Notify lecturers only after configured lower stages have been attempted or exceeded.
- Surface escalation history for audit and follow-up.
- Reuse existing intervention infrastructure (silence nudge, quality check, notification pipeline) — add stage gates on top rather than rewrite.

## Capabilities

### New Capabilities
- `staged-ai-escalation`: Apply multi-step AI intervention before lecturer escalation.

### Modified Capabilities
- `dashboard`: Extend lecturer visibility to show escalation state and intervention history.

## Impact

- `Kolabri-core-api`: escalation state model, stage-gate wrappers for existing interventions, notification pipeline updates, lecturer dashboard endpoints.
- `Kolabri-ai-engine`: no code changes required — core-api wraps AI engine calls with stage logic; `should_notify_teacher` flag becomes a stage-advance signal instead of direct alert trigger.
- `Kolabri-client-app`: lecturer dashboard escalation panel with resolve action.
