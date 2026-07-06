## ADDED Requirements

### Requirement: Transparent tap highlight with active states
The application SHALL set `webkit-tap-highlight-color: transparent` globally and replace the default tap highlight with explicit `active:` state styles on interactive elements.

#### Scenario: No blue flash on tap
- **WHEN** a user taps an interactive element on iOS Safari
- **THEN** no default blue/gray tap highlight SHALL appear

#### Scenario: Active state provides feedback
- **WHEN** a user presses an interactive element
- **THEN** the element SHALL show a visible active state (opacity change, scale, or background shift)

### Requirement: Touch action standardization
The application SHALL apply `touch-action: manipulation` globally, preventing double-tap zoom and reducing click delay. Elements requiring different touch behavior SHALL override locally.

#### Scenario: No double-tap zoom on interactive elements
- **WHEN** a user double-taps a button quickly
- **THEN** no zoom SHALL occur, and both taps SHALL register as clicks

### Requirement: User-select control on interactive elements
Interactive non-text elements (buttons, icons, cards) SHALL have `user-select: none` to prevent accidental text selection during interaction.

#### Scenario: Button press does not select text
- **WHEN** a user taps and drags slightly on a button
- **THEN** no text or element content SHALL be selected
