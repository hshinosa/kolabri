## Why

Users lose unsent messages when navigating away or losing connection. The current optimistic send pattern has no safety net: no draft persistence, no offline queue, no auto-retry, and socket reconnection uses a flat 1s delay with only 5 attempts. This violates the NFR reliability requirement for autosave and data-loss prevention.

## What Changes

- Add draft autosave to localStorage with 1s debounce, restore on component load, clear on successful send
- Add offline message queue using IndexedDB as an outbox, flushing queued messages on reconnect
- Replace manual-only retry with auto-retry using exponential backoff (max 3 attempts, 1s/2s/4s with jitter)
- Improve socket reconnection to infinite attempts with exponential backoff and jitter
- Add conflict resolution via version field on edits, rejecting stale updates on mismatch

## Capabilities

### New Capabilities
- `draft-autosave`: Persist unsent message drafts to localStorage, restore on load, clear on send
- `offline-queue`: Queue messages in IndexedDB outbox when offline, flush on reconnect
- `auto-retry-backoff`: Automatic retry of failed sends with exponential backoff and jitter
- `socket-reconnect-backoff`: Improved socket reconnection with infinite attempts and exponential backoff
- `conflict-resolution`: Version-based conflict detection on edits, reject stale updates

### Modified Capabilities
- `error-handling`: Retry and offline states change error presentation from manual-only to automatic recovery

## Impact

- Chat/message components: draft save/restore lifecycle, send flow changes
- Socket service: reconnection logic rewrite
- Message store/state: offline queue integration, retry state tracking
- IndexedDB: new outbox database and object store
- localStorage: new draft storage keys per conversation
- API/protocol: version field added to edit payloads
