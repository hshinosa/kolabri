## Why

Chat room di Kolabri punya beberapa masalah UX dan keamanan yang perlu diperbaiki:
1. WebSocket transport disabled — chat cuma pakai polling, nggak real-time
2. `server_error` dari socket.io nggak di-handle dengan baik di UI
3. React key warning di message list (console error setiap render)
4. Typing indicator bisa stale setelah reconnect
5. Nggak ada message delivery status (sent/delivered)
6. Send message harus nunggu server echo (nggak ada optimistic update)
7. Chat history cuma load 100 message terakhir, nggak ada "load more"
8. Reconnection nggak ada UX indicator

## What Changes

- **Re-enable WebSocket transport** — fix root cause "Invalid frame header" yang menyebabkan WebSocket gagal, lalu aktifkan `['polling', 'websocket']` transport order
- **Server error handling** — handle `server_error` event dengan toast/snackbar + auto-retry untuk recoverable errors
- **React key fix** — tambah unique key di message list items
- **Typing indicator cleanup** — reset typing state saat reconnect
- **Message delivery status** — tambah visual indicator (sending → sent) di message bubble
- **Optimistic UI** — pesan muncul langsung di UI saat dikirim, sebelum server response
- **Chat history pagination** — tambah "load more" button untuk load message lebih lama
- **Reconnection UX** — tambah "Reconnecting..." indicator saat socket reconnect

## Capabilities

### Modified Capabilities
- `chat-room`: Chat room UI dengan WebSocket, error handling, optimistic UI, pagination, dan reconnection indicator
- `socket-events`: Server event handling dengan proper error display

## Impact

- **Frontend JS**: `useSocketRoom.ts`, `room.tsx`, chat components
- **Core API**: `socket/index.ts` — WebSocket transport config
- **Dependencies**: Tidak ada dependency baru
- **Breaking changes**: Tidak ada
