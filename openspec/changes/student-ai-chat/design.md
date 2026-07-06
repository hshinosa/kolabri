## Context

Halaman AI Chat (`/student/ai-chat`) saat ini menampilkan sidebar riwayat sesi dan area chat utama dengan streaming response. Peningkatan ini menambah lima fitur baru tanpa mengubah engine inferensi AI atau arsitektur chat inti.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **State**: Zustand untuk state lokal halaman
- **Backend**: Laravel (API), Eloquent ORM
- **Real-time**: Socket.io untuk streaming AI

## Goals / Non-Goals

**Goals:**
- Mahasiswa bisa menemukan isi percakapan dengan cepat melalui pencarian
- Mahasiswa bisa menyimpan prompt dan jawaban penting
- Mahasiswa bisa mengekspor hasil percakapan untuk dokumentasi
- Mahasiswa bisa mengorganisasi percakapan berdasarkan kategori
- Mahasiswa bisa memulai percakapan dari template yang sudah terbukti efektif

**Non-Goals:**
- Tidak membangun model AI baru atau mengubah engine inferensi
- Tidak menambahkan fitur kolaborasi multi-user pada sesi chat
- Tidak menambah fitur voice input atau speech-to-text
- Tidak mengubah desain dasar layout halaman AI chat

## Decisions

### 1. Pencarian berindeks teks di server
- Pencarian dilakukan di server menggunakan full-text index pada kolom `title`, `content` (pesan user), dan `content` (pesan assistant)
- Menggunakan PostgreSQL `tsvector` atau MySQL `FULLTEXT` index
- Response menyertakan snippet dengan highlighted keyword
- Pagination dengan cursor-based untuk performa pada dataset besar
- Debounce 300ms pada input pencarian untuk mengurangi request

### 2. Kategori sebagai metadata sesi
- Kategori disimpan sebagai array tag pada tabel `chat_sessions` (kolom `category_tags` JSON)
- Satu sesi bisa memiliki beberapa tag untuk fleksibilitas topik
- Tag memiliki warna dan ikon untuk identifikasi visual cepat
- Filter kategori menggunakan chip multi-select di sidebar

### 3. Template prompt reusable
- Template disimpan di tabel `prompt_templates` dengan kolom: `title`, `description`, `prompt_body`, `category`, `is_global`
- Template global (dibuat admin) dan template personal (dibuat mahasiswa)
- Panel template muncul sebagai drawer/modal di sisi input chat
- Mahasiswa bisa langsung mengedit prompt setelah memilih template

### 4. Bookmark level pesan
- Bookmark diterapkan pada pesan tertentu (prompt atau jawaban)
- Tabel `chat_bookmarks` dengan FK ke `chat_messages` dan `users`
- Filter "Ditandai" tersedia di sidebar riwayat
- Bookmark disinkronkan saat refresh halaman

### 5. Ekspor asinkron dengan job queue
- Ekspor diproses di background menggunakan Laravel Queue
- Tabel `chat_export_jobs` menyimpan status: pending, processing, completed, failed
- Format yang didukung: plain text (ringkasan) dan Markdown (detail)
- Notifikasi di UI saat ekspor selesai dengan tombol unduh
- File sementara dihapus otomatis setelah 24 jam

## Component Architecture

```
student/ai-chat/
├── index.tsx                    # Halaman utama (existing)
├── components/
│   ├── ChatSidebar.tsx          # Sidebar riwayat (enhanced)
│   │   ├── SearchBar.tsx        # Kolom pencarian baru
│   │   ├── CategoryFilter.tsx   # Filter kategori chip
│   │   ├── BookmarkFilter.tsx   # Toggle "Ditandai"
│   │   └── SessionList.tsx      # Daftar sesi (enhanced)
│   ├── ChatArea.tsx             # Area chat utama (existing)
│   │   ├── MessageItem.tsx      # Item pesan (enhanced)
│   │   │   └── BookmarkButton.tsx # Tombol bookmark
│   │   └── ChatInput.tsx        # Input chat (enhanced)
│   │       └── TemplatePanel.tsx # Panel template prompt
│   ├── ExportModal.tsx          # Modal ekspor baru
│   ├── CategoryManager.tsx      # Modal kelola kategori
│   └── TemplateManager.tsx      # Modal kelola template
└── stores/
    └── aiChatStore.ts           # Zustand store (enhanced)
```

## API Contracts

### Search
```
GET /api/student/ai-chat/sessions?q={query}&category={tag}&bookmarked={bool}&cursor={id}&limit={n}
Response: { sessions: [...], next_cursor, total }
```

### Categories
```
GET    /api/student/ai-chat/categories
POST   /api/student/ai-chat/categories         { name, color, icon }
DELETE /api/student/ai-chat/categories/{id}
PATCH  /api/student/ai-chat/sessions/{id}/tags  { tags: [] }
```

### Templates
```
GET    /api/student/ai-chat/templates?category={cat}
POST   /api/student/ai-chat/templates           { title, description, prompt_body, category }
PUT    /api/student/ai-chat/templates/{id}       { title, description, prompt_body, category }
DELETE /api/student/ai-chat/templates/{id}
```

### Bookmarks
```
POST   /api/student/ai-chat/messages/{id}/bookmark
DELETE /api/student/ai-chat/messages/{id}/bookmark
GET    /api/student/ai-chat/bookmarks?cursor={id}&limit={n}
```

### Export
```
POST   /api/student/ai-chat/sessions/{id}/export  { format: "summary"|"detail" }
GET    /api/student/ai-chat/exports/{jobId}
GET    /api/student/ai-chat/exports/{jobId}/download
```

## Data Model

```sql
-- Tambah kolom pada chat_sessions
ALTER TABLE chat_sessions ADD COLUMN category_tags JSON DEFAULT '[]';

-- Tabel bookmark
CREATE TABLE chat_bookmarks (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    message_id BIGINT REFERENCES chat_messages(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, message_id)
);

-- Tabel template
CREATE TABLE prompt_templates (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) NULL,  -- NULL = global template
    title VARCHAR(255) NOT NULL,
    description TEXT,
    prompt_body TEXT NOT NULL,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabel export job
CREATE TABLE chat_export_jobs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    session_id BIGINT REFERENCES chat_sessions(id),
    format VARCHAR(20) NOT NULL,  -- 'summary' | 'detail'
    status VARCHAR(20) DEFAULT 'pending',
    file_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);
```

## Risks / Mitigations

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Pencarian lambat pada riwayat besar | UX buruk | Full-text index, debounce, pagination |
| Ekspor terlalu besar untuk sesi panjang | Timeout | Batasi rentang data, proses asinkron |
| Template spam oleh mahasiswa | Data kotor | Batasi jumlah template per user (max 50) |
| Bookmark terlalu banyak | UI ramai | Pagination pada daftar bookmark |
| Kategori tidak konsisten | Kebingungan | Sediakan kategori default + validasi nama |

## Rollout Plan

1. **Phase 1**: Pencarian + Bookmark (fitur paling dicari)
2. **Phase 2**: Kategori + Filter (organisasi percakapan)
3. **Phase 3**: Template prompt (efisiensi penulisan)
4. **Phase 4**: Ekspor percakapan (dokumentasi)

Setiap phase dilakukan validasi performa dan UX sebelum lanjut ke phase berikutnya.
