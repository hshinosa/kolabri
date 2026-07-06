## Context

Kolabri uses an optimistic send pattern: messages move through sending/sent/failed states. On failure, users see a "Coba lagi" button for manual retry. Socket reconnection caps at 5 attempts with a flat 1s delay. There is no draft persistence, no offline queue, and no conflict resolution beyond simple clientId matching. The NFR reliability audit identified these gaps as data-loss risks.

## Goals / Non-Goals

**Goals:**
- Prevent message loss on navigation, connection drop, or send failure
- Recover automatically from transient failures without user intervention
- Improve socket reconnection resilience for long-running sessions
- Detect and reject conflicting edits

**Non-Goals:**
- End-to-end encryption or message signing
- Server-side message persistence changes
- Multi-device sync or cross-tab coordination
- UI redesign of error/retry indicators beyond minimal status changes

## Decisions

### 1. localStorage for drafts, IndexedDB for outbox

localStorage is synchronous and sufficient for a single draft per conversation (small string, fast read/write). IndexedDB handles the outbox because queued messages may accumulate during extended offline periods and exceed localStorage size limits. IndexedDB is async but supports structured storage and indexing by conversation and timestamp.

Alternatives considered:
- IndexedDB for both: unnecessary complexity for a single draft string
- In-memory only: defeats the purpose (lost on navigation/close)

### 2. Debounce draft save at 1s

1s debounce balances write frequency against localStorage thrash. Users typing faster than 1s intervals won't trigger excessive writes. On unmount (navigation), flush the pending draft immediately before the component unmounts.

### 3. Exponential backoff with jitter for retry and reconnection

Backoff formula: `min(base * 2^attempt, maxDelay) + random(0, jitter)`. Retry: base=1s, max=4s, 3 attempts. Reconnect: base=1s, max=30s, infinite attempts. Jitter prevents thundering herd on server recovery.

Alternatives considered:
- Fixed delay: causes synchronized retry storms
- Linear backoff: slower convergence to stable state

### 4. Version field for conflict resolution on edits

Each message edit increments a server-side version number. Client sends the version it last saw. Server rejects if current version differs. Client fetches latest and shows conflict UI. This is simpler than operational transformation and sufficient for Kolabri's edit volume.

Alternatives considered:
- Last-write-wins: silent data loss
- OT/CRDT: massive overkill for this use case

### 5. Outbox flush on reconnect, not on timer

Flushing the outbox on socket reconnect event is simpler and more reliable than polling. The reconnect event is the exact moment the server is available again.

## Risks / Trade-offs

- [localStorage quota] → Draft keys are small (per-conversation, cleared on send). Low risk.
- [IndexedDB complexity] → Wrap in a thin repository class with clear CRUD methods. Test with simulated offline scenarios.
- [Backoff delay perception] → Users may perceive auto-retry as slow. Show subtle "retrying..." indicator so they know it's happening.
- [Version field migration] → Existing messages have no version field. Default to version=0, first edit sets version=1. Server must handle missing version gracefully.
- [Infinite reconnect] → Could drain battery on mobile. Cap reconnect delay at 30s and add visibility-based pause (stop reconnecting when tab is hidden).
- **ChatLog schema coordination**: This change adds a `version` field to ChatLog (MongoDB). Other changes also modify ChatLog: nfr-mnt-02 adds 6 nullable columns, nfr-data-01 changes `isDeleted` → `deletedAt`, nfr-usability-04 adds `isRelevant`. All ChatLog schema changes MUST be applied in a single consolidated migration to avoid conflicting migrations. Execution order: DATA-01 migration first (breaking change), then MNT-02 + RELIABILITY-02 + USABILITY-04 additive fields together.
