## 1. Draft Autosave

- [ ] 1.1 Create `useDraftAutosave` hook with 1s debounced localStorage write per conversation
- [ ] 1.2 Add draft restore logic on component mount (read localStorage, populate input)
- [ ] 1.3 Add draft flush on component unmount (cancel debounce timer, write immediately)
- [ ] 1.4 Add draft clear on successful message send
- [ ] 1.5 Ensure draft is NOT cleared on send failure
- [ ] 1.6 Write unit tests for save, restore, flush, and clear behaviors

## 2. Offline Message Queue

- [ ] 2.1 Create IndexedDB outbox schema (database: `kolabri-outbox`, store: `messages`, indexes: `conversationId`, `timestamp`)
- [ ] 2.2 Implement `OutboxRepository` class with add, getAll, remove, and removeMany methods
- [ ] 2.3 Intercept outgoing messages when socket is disconnected and route to outbox
- [ ] 2.4 Implement outbox flush on socket reconnect event (send in chronological order, update statuses)
- [ ] 2.5 Handle partial flush failure (remove sent messages, keep failed in outbox)
- [ ] 2.6 Verify outbox persistence across page reloads
- [ ] 2.7 Write integration tests for offline queue and flush scenarios

## 3. Auto-retry with Exponential Backoff

- [ ] 3.1 Implement `retryWithBackoff` utility (max 3 attempts, delays: 1s/2s/4s + jitter up to 500ms)
- [ ] 3.2 Integrate auto-retry into the message send flow (retry on failure, exhaust before showing "Coba lagi")
- [ ] 3.3 Add "retrying..." status indicator in the message UI during auto-retry
- [ ] 3.4 Reset retry counter on manual "Coba lagi" click
- [ ] 3.5 Write unit tests for backoff calculation and retry flow

## 4. Socket Reconnection Improvement

- [ ] 4.1 Replace flat 5-attempt reconnection with infinite exponential backoff (base 1s, max 30s, jitter up to 1s)
- [ ] 4.2 Add visibility-based pause (stop reconnecting when `document.hidden`, resume on visibility change)
- [ ] 4.3 Reset backoff counter on successful reconnection
- [ ] 4.4 Expose reconnection state (connected, reconnecting, disconnected) for UI binding
- [ ] 4.5 Update UI to show connection status indicator (connected, reconnecting)
- [ ] 4.6 Write tests for backoff calculation, visibility pause, and state transitions

## 5. Conflict Resolution

- [ ] 5.1 Add `version` field to message edit payload (default 0 for legacy messages)
- [ ] 5.2 Implement server-side version check: reject edit if payload version != current version
- [ ] 5.3 Return conflict error with current server version on rejection
- [ ] 5.4 Implement client-side conflict handler: fetch latest message, show conflict UI
- [ ] 5.5 Handle legacy messages without version field (treat as version=0)
- [ ] 5.6 Write tests for version matching, conflict rejection, and legacy compatibility
