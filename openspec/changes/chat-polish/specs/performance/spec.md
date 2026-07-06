## MODIFIED Requirements

### Requirement: Typing Indicator Debounce
Typing indicator events SHALL be debounced.

#### Scenario: User types continuously
- **WHEN** user types characters rapidly
- **THEN** typing indicator SHALL only send after 300ms pause
- **AND** stop typing SHALL send after 1000ms pause

### Requirement: Message Memoization
Message components SHALL be memoized to prevent unnecessary re-renders.

#### Scenario: Other messages update
- **WHEN** one message's delivery status changes
- **THEN** only that message component SHALL re-render
- **AND** other message components SHALL remain unchanged

### Requirement: Expensive Computation Memoization
Expensive computations SHALL be memoized with useMemo.

#### Scenario: Messages list changes
- **WHEN** messages array updates
- **THEN** filtered/sorted/processed message lists SHALL use useMemo
- **AND** computation SHALL only run when dependencies change
