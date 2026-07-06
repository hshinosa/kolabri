## ADDED Requirements

### Requirement: Swipe right to open sidebar
On mobile viewports, the user SHALL be able to swipe right from the left edge to open the sidebar drawer. The swipe SHALL only trigger when the horizontal delta exceeds 50px and the horizontal movement is greater than vertical (to avoid conflicting with scroll).

#### Scenario: Swipe right opens sidebar
- **WHEN** the sidebar is closed and the user swipes right from the left 20px edge with horizontal delta > 50px
- **THEN** the sidebar SHALL open with a smooth animation

#### Scenario: Short swipe does not open sidebar
- **WHEN** the user swipes right with horizontal delta < 50px
- **THEN** the sidebar SHALL NOT open

#### Scenario: Vertical scroll does not trigger sidebar
- **WHEN** the user scrolls vertically near the left edge
- **THEN** the sidebar SHALL NOT open (vertical delta > horizontal delta)

### Requirement: Swipe left to close sidebar
On mobile viewports, the user SHALL be able to swipe left on the sidebar to close it. The swipe SHALL trigger when horizontal delta exceeds 50px.

#### Scenario: Swipe left closes sidebar
- **WHEN** the sidebar is open and the user swipes left with horizontal delta > 50px
- **THEN** the sidebar SHALL close with a smooth animation

#### Scenario: Short swipe does not close sidebar
- **WHEN** the user swipes left with horizontal delta < 50px
- **THEN** the sidebar SHALL NOT close

### Requirement: Swipe gesture uses pointer events
The swipe detection SHALL use pointer events (pointerdown, pointermove, pointerup) for cross-device compatibility (touch, mouse, pen).

#### Scenario: Mouse drag opens sidebar
- **WHEN** the user clicks and drags right from the left edge on a desktop browser
- **THEN** the sidebar SHALL open (same as touch behavior)
