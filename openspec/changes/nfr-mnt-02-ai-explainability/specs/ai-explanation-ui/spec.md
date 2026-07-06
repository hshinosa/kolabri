## ADDED Requirements

### Requirement: Intervention badge on AI messages
AI chat messages that involved a guardrail or intervention SHALL display a badge indicating the intervention type. Messages with no intervention SHALL NOT display a badge.

#### Scenario: AI message with scaffolding intervention
- **WHEN** an AI message has interventionType "scaffolding"
- **THEN** the message SHALL display a badge with text "Scaffolding"

#### Scenario: AI message with guardrail redirect
- **WHEN** an AI message has guardrailOutcome "redirected"
- **THEN** the message SHALL display a badge with text "Redirected"

#### Scenario: AI message with no intervention
- **WHEN** an AI message has null interventionType and null guardrailOutcome
- **THEN** no badge SHALL be displayed

### Requirement: Explanation tooltip on intervention badges
Hovering or tapping on an intervention badge SHALL display a tooltip with the explanation and scaffolding level.

#### Scenario: Hover on scaffolding badge
- **WHEN** a user hovers over a "Scaffolding" badge on an AI message with interventionReason "student stuck on concept" and scaffoldingLevel "medium"
- **THEN** a tooltip SHALL appear showing "Reason: student stuck on concept" and "Level: medium"

#### Scenario: Tap on badge (mobile)
- **WHEN** a user taps an intervention badge on a mobile device
- **THEN** the tooltip SHALL appear and remain visible until the user taps elsewhere

### Requirement: Student-facing AI helping indicator
When the AI is providing scaffolding or guided help, the student SHALL see an "AI is helping" indicator near the AI message.

#### Scenario: Active scaffolding session
- **WHEN** an AI message has scaffoldingLevel set to any non-null value
- **THEN** the message SHALL display an "AI is helping" indicator

#### Scenario: No scaffolding
- **WHEN** an AI message has null scaffoldingLevel
- **THEN** no "AI is helping" indicator SHALL be displayed
