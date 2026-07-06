## Why

Lecturers want Kolabri to do more than answer ad hoc questions: the AI should also recommend relevant follow-up readings from the course knowledge base so students can deepen understanding independently. Current RAG behavior can answer from uploaded material, but it does not produce structured reading recommendations tailored to discussion context.

## What Changes

- Add a structured reading recommendation capability that selects relevant course materials from the knowledge base.
- Return recommendation items with source attribution, reason for recommendation, and suggested next action.
- Surface recommendations in student-facing AI or course discussion flows where they can be acted on directly.
- Add fallbacks when the knowledge base has insufficient relevant material.

## Capabilities

### New Capabilities
- `reading-recommendations`: Generate structured follow-up reading recommendations from course knowledge sources.

### Modified Capabilities
- `input-validation`: Validate recommendation request inputs and return actionable feedback for unsupported or incomplete requests.

## Impact

- `Kolabri-ai-engine`: retrieval/ranking logic, structured output shaping.
- `Kolabri-core-api`: recommendation endpoint/orchestration, validation, response contract.
- `Kolabri-client-app`: recommendation UI in relevant student/lecturer flows.
