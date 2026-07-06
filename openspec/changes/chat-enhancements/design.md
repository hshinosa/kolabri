## Context

Chat room Kolabri menggunakan socket.io untuk real-time messaging. Saat ini:
- WebSocket transport disabled (polling only) karena "Invalid frame header" error
- Socket.io server di Core API (port 3000) dengan CORS untuk localhost:8000 + :5173
- Frontend React via Inertia.js dengan `useSocketRoom` hook
- Chat room component di `student/chat/room.tsx` (~2400 baris)
- Messages stored di MongoDB, group/course data di PostgreSQL

**Constraints:**
- Core API menggunakan socket.io v4.8, client v4.8
- Vite dev server di port 5173, Laravel di port 8000
- "Invalid frame header" terjadi saat WebSocket upgrade — perlu investigasi apakah Vite HMR proxy yang intercept

## Goals / Non-Goals

**Goals:**
- WebSocket transport bisa dipakai untuk real-time messaging
- Error dari server terlihat di UI dengan jelas
- React console bersih dari warnings
- User tahu status socket (connecting/reconnecting/disconnected)
- Pesan terkirim lebih cepat (optimistic update)
- Bisa load chat history lebih lama

**Non-Goals:**
- Offline-first architecture
- Message encryption
- Read receipts (delivery status hanya sending → sent, bukan read)
- File upload di chat (sudah ada fitur terpisah)

## Decisions

### 1. WebSocket Fix Strategy

**Pilihan**: Investigasi root cause "Invalid frame header" di WebSocket upgrade.

**Approach**:
- Test WebSocket upgrade dari browser langsung tanpa socket.io client
- Cek apakah Vite dev server intercept WebSocket connections
- Jika masalah CORS, tambah Origin header yang benar
- Jika masalah Vite proxy, konfigurasi Vite untuk forward WebSocket

**Alternatif ditolak:**
- Paksa polling only (sudah dilakukan, tapi nggak real-time)
- Ganti ke native WebSocket (hilang fitur socket.io seperti rooms, reconnection)

### 2. Optimistic UI

**Pilihan**: Render pesan langsung dengan temporary ID, update setelah server confirm.

**Approach**:
- Generate client-side UUID untuk temporary message ID
- Tambah status field: `sending` → `sent` → `failed`
- Jika gagal, tampilkan error di message bubble + retry button
- Server response update temporary ID ke real ID

### 3. Chat History Pagination

**Pilihan**: Load older messages via socket event, bukan HTTP API.

**Approach**:
- Tambah "Load earlier messages" button di atas chat
- Emit `load_more_messages` ke server dengan cursor (oldest message ID)
- Server return older messages + hasMore flag
- Prepend ke message list tanpa scroll jump

### 4. Reconnection UX

**Pilihan**: Banner inline di atas chat area.

**Approach**:
- `reconnecting` state dari socket.io reconnect events
- Tampilkan banner "Menyambungkan kembali..." saat reconnecting
- Auto-dismiss saat connected
- Jika gagal setelah max attempts, tampilkan "Koneksi terputus. Refresh halaman."

### 5. Error Handling

**Pilihan**: Toast notification untuk error, inline untuk message failures.

**Approach**:
- `server_error` → toast notification (non-blocking)
- `send_message` failure → inline di message bubble (retry available)
- Connection error → banner (persistent sampai resolve)

## Risks / Trade-offs

- **Optimistic UI complexity** — perlu handle ID mapping, status tracking, retry logic
- **WebSocket fix** — root cause mungkin di luar kontrol (browser, Vite, network)
- **Performance** — optimistic UI bisa race condition dengan real server messages
- **Memory** — load more messages menambah DOM nodes
