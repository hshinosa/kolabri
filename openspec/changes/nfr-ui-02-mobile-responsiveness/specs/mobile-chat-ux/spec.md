## ADDED Requirements

### Requirement: Fixed bottom chat input
The chat input SHALL be fixed to the bottom of the viewport on mobile, remaining visible during scroll and keyboard appearance.

#### Scenario: Chat input stays visible while scrolling messages
- **WHEN** the user scrolls through chat messages on mobile
- **THEN** the input bar SHALL remain fixed at the bottom of the screen

#### Scenario: Chat input stays visible when keyboard opens
- **WHEN** the user focuses the chat input and the virtual keyboard appears
- **THEN** the input bar SHALL adjust position to stay above the keyboard

### Requirement: Safe-area aware chat input
The fixed bottom chat input SHALL apply `env(safe-area-inset-bottom)` as additional padding so it is not obscured by the home indicator on notched devices.

#### Scenario: Chat input avoids home indicator
- **WHEN** the chat input renders on an iPhone with home indicator
- **THEN** the input SHALL have bottom padding equal to `env(safe-area-inset-bottom)`

### Requirement: Keyboard handling via visual viewport
The chat input position SHALL use the Visual Viewport API to detect keyboard state and adjust layout accordingly.

#### Scenario: Keyboard pushes input up
- **WHEN** the virtual keyboard appears and `window.visualViewport.height` decreases
- **THEN** the chat input SHALL move up to remain visible above the keyboard

#### Scenario: Visual Viewport fallback
- **WHEN** `window.visualViewport` is not available
- **THEN** the system SHALL fall back to `window.innerHeight` resize detection

### Requirement: Overscroll prevention on chat scroll area
The chat message scroll area SHALL have `overscroll-behavior: contain` to prevent pull-to-refresh and overscroll navigation when the user reaches the top or bottom of the message list.

#### Scenario: Scrolling to top does not trigger pull-to-refresh
- **WHEN** the user scrolls to the top of the chat and continues pulling
- **THEN** no browser pull-to-refresh or overscroll navigation SHALL occur

#### Scenario: Scrolling to bottom does not navigate away
- **WHEN** the user scrolls to the bottom and continues swiping
- **THEN** no browser back/forward navigation SHALL occur
