## Context

Kolabri is a Next.js collaborative learning platform with Tailwind CSS. Chat spaces already support goal setting, session lock/unlock, AI intervention, and escalation. The AI service (OpenAI-compatible provider) can already read session goals and message history. However, no existing component measures or communicates whether a discussion is "terarah" (directed toward its goal). Participants have no visual cue of progress, and facilitators have no quick health readout.

The four new capabilities (discussion-progress, goal-alignment-badge, session-summary, discussion-health) all depend on one shared operation: classifying message relevance against the session learning goal. This shared dependency drives the core design decision.

## Goals / Non-Goals

**Goals:**
- Give participants a real-time sense that the discussion is moving toward its goal
- Give facilitators a quick health readout per chat space
- Produce a structured summary when sessions close
- Reuse the existing AI service and goal data model

**Non-Goals:**
- Replacing the existing AI intervention or escalation flows
- Building a custom ML model for relevance classification (use the existing OpenAI-compatible AI service)
- Real-time streaming classification (batch on message send is sufficient)
- Cross-session analytics or historical trend dashboards

## Decisions

### D1: Relevance classification via existing AI service

Classify each message as "Relevan" or "Off-topic" by sending the message text plus the session goal to the OpenAI-compatible AI service. Store the result as a boolean field `isRelevant` on the message document. Classification is triggered on message send but debounced and batched: new messages accumulate for up to 5 seconds, then a single batch request classifies all pending messages against the session goal. This reduces API calls and cost compared to per-message classification.

**Why**: The AI service already exists and already reads session goals. Adding a classification prompt avoids a new dependency. Batching every 5s balances responsiveness with API cost. Alternative (keyword matching) would be too brittle for natural language discussion. Per-message fire-and-forget would be too expensive at scale.

### D2: Progress percentage computed from stored relevance flags

Progress = (relevant message count / total message count) * 100. Computed client-side from the message list already loaded in the chat space.

**Why**: No extra backend endpoint needed. The data is already in memory. Alternative (server-side aggregation) adds latency and a new endpoint for data the client already has.

### D3: Health score as a weighted composite

Health = 0.4 * relevanceRatio + 0.3 * participationBalance + 0.3 * goalProgress, scaled to 0-100.

- relevanceRatio: same as progress percentage above
- participationBalance: entropy of message distribution across members (1.0 = perfectly even, 0.0 = one person dominates)
- goalProgress: facilitator's manual assessment if set, otherwise falls back to relevanceRatio

**Why**: A single relevance metric is too narrow. A discussion can be on-topic but dominated by one person, which still feels undirected. The composite captures both alignment and inclusivity.

### D4: Session summary generated on close event

When a facilitator closes a session, trigger a single AI call that takes the full message history, goal, and relevance stats, and returns a structured JSON summary (goalAchieved boolean, topics string[], contributions map, assessment string).

**Why**: One call at close time is cheaper and more coherent than accumulating partial summaries. The close event already exists in the session lifecycle.

### D5: Badge rendered inline, summary and health in separate widgets

Per-message badge: small colored dot + tooltip ("Relevan" / "Off-topic") next to the timestamp. Health score: card widget in the chat space header. Progress bar: thin bar below the header. Summary: modal dialog triggered on session close.

**Why**: Keeps the message list clean. A text label on every message would clutter. The dot is subtle but scannable.

## Risks / Trade-offs

- [AI classification latency] → Classify asynchronously in batches (every 5s); show "..." badge until result arrives. If classification fails, default to "Relevan" to avoid penalizing messages.
- [AI API cost per message] → Batch classification: classify only new messages since last check (every 5 seconds or on message send), not the full history each time.
- [Subjective health score] → The participationBalance metric uses Shannon entropy, which is objective. The goalProgress component falls back to relevanceRatio when no manual assessment exists, keeping the score grounded.
- [Badge fatigue] → The dot is intentionally minimal. If users find it distracting, it can be toggled off in settings.
- **ChatLog schema coordination**: This change adds an `isRelevant` field to ChatLog (MongoDB). Other changes also modify ChatLog: nfr-mnt-02 adds 6 nullable fields, nfr-reliability-02 adds `version`, nfr-data-01 changes `isDeleted` → `deletedAt`. All ChatLog schema changes MUST be applied in a single consolidated migration. Execution order: DATA-01 migration first (breaking change), then MNT-02 + RELIABILITY-02 + USABILITY-04 additive fields together.
