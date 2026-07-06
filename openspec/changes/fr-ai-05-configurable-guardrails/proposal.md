## Why

Kolabri already has AI safety primitives such as toxicity, prompt-injection, or sensitive-content filtering, but lecturers cannot configure them per course. Different courses need different tolerance and intervention policies, so AI guardrails must become course-configurable rather than fixed globally.

## What Changes

- Add lecturer-configurable per-course AI guardrail settings.
- Apply configured guardrail policy during AI requests for that course.
- Show clear outcomes when content is blocked, rewritten, or flagged.
- Record guardrail decisions for auditing and later tuning.

## Capabilities

### New Capabilities
- `course-ai-guardrails`: Configure and enforce per-course AI guardrail policy.

### Modified Capabilities
- `settings`: Extend settings behavior to support course-level AI safety configuration.
- `input-validation`: Validate guardrail configuration payloads and policy-aware AI request outcomes.

## Impact

- `Kolabri-core-api`: course settings models/endpoints, AI request orchestration, audit logging.
- `Kolabri-ai-engine`: policy-aware moderation/guardrail execution.
- `Kolabri-client-app`: lecturer settings UI and blocked/flagged state presentation.
