## ADDED Requirements

### Requirement: Viewport fit cover
The viewport meta tag SHALL include `viewport-fit=cover` so content extends into safe area insets on notched devices.

#### Scenario: iPhone with notch renders full screen
- **WHEN** the app loads on an iPhone with a notch
- **THEN** content extends to the edges of the screen, with safe-area insets available for padding

### Requirement: Safe-area inset CSS custom properties
The application SHALL define CSS custom properties mapping `env(safe-area-inset-top)`, `env(safe-area-inset-right)`, `env(safe-area-inset-bottom)`, and `env(safe-area-inset-left)` to reusable tokens.

#### Scenario: Custom properties resolve on notched device
- **WHEN** the app renders on a device with safe area insets
- **THEN** CSS custom properties `--safe-top`, `--safe-right`, `--safe-bottom`, `--safe-left` SHALL resolve to the device's inset values

#### Scenario: Custom properties fallback on non-notched device
- **WHEN** the app renders on a device without safe area insets
- **THEN** all safe-area custom properties SHALL resolve to 0

### Requirement: Layout containers use safe-area padding
Fixed and sticky elements (header, sidebar, bottom bar, modals) SHALL apply safe-area inset padding so content is not clipped by notch, home indicator, or rounded corners.

#### Scenario: Fixed bottom bar avoids home indicator
- **WHEN** a fixed bottom bar renders on an iPhone with home indicator
- **THEN** the bar SHALL add bottom padding equal to `env(safe-area-inset-bottom)`

#### Scenario: Header avoids notch
- **WHEN** a fixed header renders on a notched device in landscape
- **THEN** the header SHALL add left/right padding equal to `env(safe-area-inset-left)` and `env(safe-area-inset-right)`
