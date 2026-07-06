## Why

Online discussions in Kolabri lack a measurable sense of direction. Pak Ive's requirement states discussions must "terasa terarah seperti tatap muka" (feel directed like face-to-face). Existing features (lock/unlock, goal setting, AI intervention, escalation) support session control but none give participants or facilitators a clear, real-time signal that the conversation is progressing toward its learning goal. Without this, discussions drift, participants disengage, and the experience feels unstructured compared to classroom interaction.

## What Changes

- Add a **Discussion Progress Indicator** that shows how much of the learning goal has been addressed, computed from the percentage of messages classified as relevant to the goal.
- Add a **Goal Alignment Badge** on each message, labeling it "Relevan" or "Off-topic" based on AI classification against the session's learning goal, with a summary count visible in the chat header.
- Add a **Session Summary on Close** that captures whether the goal was achieved, topics covered, member contributions, and an AI assessment paragraph.
- Add a **Discussion Health Dashboard** that scores each chat space on a 0-100 health scale (color coded) based on relevance ratio, participation balance, and goal progress.

## Capabilities

### New Capabilities
- `discussion-progress`: Progress indicator showing goal coverage percentage derived from message relevance classification
- `goal-alignment-badge`: Per-message relevance label and aggregate count against the session learning goal
- `session-summary`: Structured summary generated when a discussion session closes, covering goal achievement, topics, contributions, and AI assessment
- `discussion-health`: Per-chat-space health score (0-100) with color coding based on relevance, participation, and goal progress

### Modified Capabilities
- `dashboard`: Adding discussion health widget to the existing dashboard

## Impact

- Chat UI components: new progress bar, message badges, summary modal, health widget
- AI service: new relevance classification endpoint, summary generation endpoint, health score computation
- Existing goal-setting and session-lock features feed data into these new capabilities
- Dashboard spec requires a delta for the health widget addition
