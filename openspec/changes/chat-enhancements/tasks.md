## 1. WebSocket Transport Fix

- [x] 1.1 Investigate root cause "Invalid frame header" — test WebSocket upgrade directly from browser
- [x] 1.2 Fix WebSocket upgrade issue (CORS Origin header, Vite proxy config, or transport negotiation)
- [x] 1.3 Re-enable `['polling', 'websocket']` transport order in `useSocketRoom.ts`
- [x] 1.4 Verify WebSocket connects and `room_joined` fires via WebSocket

## 2. Server Error Handling

- [x] 2.1 Create `Toast` component for non-blocking notifications
- [x] 2.2 Handle `server_error` socket event → show toast notification
- [x] 2.3 Add "failed" indicator + retry button on message bubble for send failures
- [x] 2.4 Implement retry logic for failed message send

## 3. Connection Status UX

- [x] 3.1 Track `reconnecting` state from socket.io reconnection events
- [x] 3.2 Create connection status banner component (reconnecting / disconnected)
- [x] 3.3 Show "Menyambungkan kembali..." banner during reconnection
- [x] 3.4 Show "Koneksi terputus" banner after max reconnection attempts with refresh button

## 4. React Key Fix + Typing Cleanup

- [x] 4.1 Add unique `key` prop to all message list items in `room.tsx`
- [x] 4.2 Reset typing indicator state on socket reconnect

## 5. Optimistic UI

- [x] 5.1 Generate client-side temporary ID for new messages
- [x] 5.2 Add message status field: `sending` → `sent` → `failed`
- [x] 5.3 Render sending indicator (spinner) on message bubble
- [x] 5.4 Update temporary message with server response (ID + timestamp)
- [x] 5.5 Handle failed send: show error state + retry button

## 6. Chat History Pagination

- [x] 6.1 Add `load_more_messages` socket event handler in `useSocketRoom.ts`
- [x] 6.2 Create "Load earlier messages" button component
- [x] 6.3 Implement scroll position preservation after loading older messages
- [x] 6.4 Hide button when no more messages available

## 7. Core API Socket Changes

- [x] 7.1 Add `load_more_messages` event handler in `socket/index.ts`
- [x] 7.2 Implement message cursor-based pagination in MongoDB query
- [x] 7.3 Fix WebSocket transport config if needed for "Invalid frame header" fix
