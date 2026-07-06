## ADDED Requirements

### Requirement: Minimum touch target size
All interactive elements (buttons, links, inputs, toggles, icons with click handlers) SHALL have a minimum touch target of 44x44px. Elements visually smaller than 44px SHALL use padding or a wrapper to expand the hit area without changing visual size.

#### Scenario: Small icon button meets touch target
- **WHEN** a button contains a 20x20px icon with no text
- **THEN** the button's clickable area SHALL be at least 44x44px via padding or wrapper

#### Scenario: Inline link in text
- **WHEN** a text link appears inside a paragraph
- **THEN** the link SHALL have minimum vertical padding of 44px total height or use a tap target wrapper

### Requirement: Global touch-manipulation
The application SHALL apply `touch-action: manipulation` globally to eliminate the 300ms click delay on touch devices.

#### Scenario: Tap on button responds without delay
- **WHEN** a user taps a button on a touch device
- **THEN** the click event fires without the 300ms delay

#### Scenario: Pinch-zoom elements override global rule
- **WHEN** an element requires pinch-zoom (e.g., image viewer, map)
- **THEN** that element SHALL override `touch-action` locally to allow pinch-zoom

### Requirement: Active press feedback
All interactive elements SHALL provide visual feedback on press via `active:scale-95` or equivalent active state styling.

#### Scenario: Button shows press feedback
- **WHEN** a user presses a button on mobile
- **THEN** the button SHALL visually scale down or change appearance to indicate the pressed state
