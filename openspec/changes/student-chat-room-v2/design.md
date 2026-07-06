## Context

Chat room (`/student/chat/room/[id]`) saat ini menampilkan daftar pesan real-time dengan Socket.io, input chat, dan attachment. Peningkatan V2 menambah kontrol pesan dan alat navigasi tanpa memperluas ke fitur reaksi.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **Real-time**: Socket.io untuk messaging real-time
- **Backend**: Laravel (API), Eloquent ORM
- **Storage**: Laravel Storage untuk file attachment

## Goals / Non-Goals

**Goals:**
- Pengguna bisa edit/hapus pesan sendiri dengan jejak audit
- Pengguna bisa mencari isi diskusi dengan cepat
- Pesan penting bisa dipin untuk akses cepat

**Non-Goals:**
- Reactions/emoticon reaction pada pesan
- Thread bercabang per pesan (nested replies)
- Voice/video chat
- Edit history yang bisa di-rollback

## Decisions

### 1. Edit/hapus berbasis kebijakan kepemilikan
- Hanya pengirim pesan yang boleh edit/hapus pesannya
- Moderator dan owner ruang bisa menghapus pesan untuk moderasi
- Edit memiliki batas waktu (24 jam setelah pengiriman) untuk mencegah manipulasi
- Hapus mengganti konten dengan "[Pesan telah dihapus]" bukan hard delete

### 2. Pencarian server-side
- Pencarian dilakukan di server untuk menangani riwayat besar
- Menggunakan full-text search pada kolom `content`
- Menyediakan pagination dengan cursor-based
- Highlight snippet pada hasil pencarian
- Tidak mencari pesan yang sudah dihapus

### 3. Pinning terbatas
- Pin dibatasi maksimal 10 pesan per ruang agar tetap relevan
- Panel "Pesan dipin" tersedia di bagian atas ruang chat (expandable)
- Pin/unpin hanya bisa dilakukan oleh moderator dan owner ruang
- Pin tidak mengubah posisi pesan di timeline

### 4. Reactions dikecualikan secara eksplisit
- Tidak ada UI untuk menambah reaksi pada pesan
- Tidak ada API endpoint untuk reaksi
- Tidak ada data model untuk reaksi

## Component Architecture

```
student/chat/room/
├── room.tsx                       # Halaman utama (existing)
├── components/
│   ├── MessageList.tsx            # Daftar pesan (enhanced)
│   │   ├── MessageItem.tsx        # Item pesan (enhanced)
│   │   │   ├── MessageActions.tsx # Toolbar aksi (edit/hapus/pin)
│   │   │   └── MessageEditor.tsx  # Editor inline untuk edit
│   │   └── PinnedMessages.tsx     # Panel pesan dipin
│   ├── ChatInput.tsx              # Input chat (existing)
│   ├── SearchBar.tsx              # Kolom pencarian
│   └── SearchResults.tsx          # Hasil pencarian
└── hooks/
    ├── useSocketRoom.ts           # Socket handler (existing, enhanced)
    ├── useMessageSearch.ts        # Hook pencarian pesan
    └── usePinnedMessages.ts       # Hook pesan dipin
```

## API Contracts

### Edit Message
```
PATCH /api/student/chat/rooms/{roomId}/messages/{messageId}
Body: { content: "pesan yang diedit" }
Response: { message: {...}, edited_at }
Authorization: Hanya pengirim pesan, dalam 24 jam
```

### Delete Message
```
DELETE /api/student/chat/rooms/{roomId}/messages/{messageId}
Response: { success: true }
Authorization: Pengirim pesan, moderator, atau owner ruang
```

### Search Messages
```
GET /api/student/chat/rooms/{roomId}/messages/search?q={query}&cursor={id}&limit={n}
Response: { messages: [...], next_cursor, total }
```

### Pin Message
```
POST   /api/student/chat/rooms/{roomId}/messages/{messageId}/pin
DELETE /api/student/chat/rooms/{roomId}/messages/{messageId}/pin
Response: { success: true }
Authorization: Moderator atau owner ruang
```

### Get Pinned Messages
```
GET /api/student/chat/rooms/{roomId}/pinned-messages
Response: { messages: [...] }
```

## Data Model

```sql
-- Tambah kolom pada chat_messages
ALTER TABLE chat_messages ADD COLUMN edited_at TIMESTAMP NULL;
ALTER TABLE chat_messages ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE chat_messages ADD COLUMN deleted_at TIMESTAMP NULL;

-- Tabel audit trail
CREATE TABLE chat_message_audit (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT REFERENCES chat_messages(id),
    action VARCHAR(20) NOT NULL,  -- 'edit' | 'delete'
    old_content TEXT,
    new_content TEXT,
    performed_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabel pin
CREATE TABLE chat_pinned_messages (
    id BIGSERIAL PRIMARY KEY,
    room_id BIGINT REFERENCES chat_rooms(id),
    message_id BIGINT REFERENCES chat_messages(id),
    pinned_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(room_id, message_id)
);
```

## Risks / Mitigations

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Penyalahgunaan edit setelah diskusi berjalan | Kebingungan | Batas waktu 24 jam + audit trail |
| Pin berlebihan | Panel ramai | Batasi 10 pin per ruang |
| Pencarian pada room besar | Performa | Full-text index, pagination, debounce |

## Rollout Plan

1. **Phase 1**: Edit/hapus pesan + audit trail
2. **Phase 2**: Pencarian pesan server-side
3. **Phase 3**: Pinning pesan + panel pesan dipin

Setiap phase dilakukan security review sebelum deploy.
