## Context

Halaman Chat Spaces (`/student/chat/spaces`) saat ini menampilkan daftar ruang sebagai kartu sederhana. Peningkatan ini menambah kemampuan navigasi dan orientasi cepat tanpa mengubah arsitektur chat room inti.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **Backend**: Laravel (API), Eloquent ORM
- **State**: URL query parameter untuk filter/sort/search

## Goals / Non-Goals

**Goals:**
- Memudahkan pencarian ruang berdasarkan nama dan deskripsi
- Menyediakan filter berdasarkan tipe dan status ruang
- Menyediakan opsi pengurutan yang jelas
- Menampilkan preview aktivitas terakhir pada kartu ruang
- Menyediakan empty state yang membantu pengguna melakukan aksi

**Non-Goals:**
- Tidak membangun sistem rekomendasi AI untuk ruang
- Tidak mengubah arsitektur chat room inti
- Tidak menambah fitur pembuatan ruang dari halaman ini (sudah ada)

## Decisions

### 1. Query list terstandar
- Menggunakan parameter: `q` (search), `filter[type]`, `filter[status]`, `sort`, `page`
- Response menyertakan metadata pagination (total, per_page, current_page)
- State disimpan di URL agar bisa dibagikan dan di-bookmark

### 2. Preview aktivitas terakhir
- Menampilkan pesan terakhir atau aktivitas terbaru per space
- Batasi panjang preview maksimal 100 karakter
- Tampilkan waktu relatif (misal: "5 menit lalu", "Kemarin")
- Data aktivitas di-aggregate dari tabel chat_messages

### 3. Empty state berbasis konteks
- **Belum punya ruang**: Tampilkan ilustrasi + "Anda belum memiliki ruang diskusi" + CTA "Buat ruang baru" dan "Gabung ruang"
- **Hasil filter kosong**: Tampilkan "Tidak ada ruang dengan filter ini" + CTA "Hapus filter"
- **Hasil pencarian kosong**: Tampilkan "Tidak ada ruang yang cocok" + CTA "Coba kata kunci lain"

### 4. Sort deterministik
- **Default**: Aktivitas terbaru (berdasarkan waktu pesan terakhir)
- **Paling aktif**: Berdasarkan jumlah pesan dalam 7 hari terakhir
- **Alfabet A-Z**: Berdasarkan nama ruang

### 5. Chip filter multi-select
- Filter tipe: Akademik, Proyek, Umum
- Filter status: Aktif, Tidak aktif
- Chip bisa di-toggle dan multi-select
- Jumlah hasil per filter ditampilkan pada chip

## Component Architecture

```
student/chat/spaces/
├── index.tsx                     # Halaman utama (enhanced)
├── components/
│   ├── SearchBar.tsx             # Kolom pencarian baru
│   ├── FilterChips.tsx           # Chip filter tipe/status
│   ├── SortDropdown.tsx          # Dropdown pengurutan
│   ├── SpaceCard.tsx             # Kartu ruang (enhanced)
│   │   └── ActivityPreview.tsx   # Preview aktivitas terakhir
│   ├── SpaceGrid.tsx             # Grid daftar ruang
│   └── EmptyState.tsx            # Empty state kontekstual
└── hooks/
    └── useSpaceFilters.ts        # Hook untuk state filter/sort/search
```

## API Contracts

### List Spaces
```
GET /api/student/chat/spaces?q={query}&filter[type]={type}&filter[status]={status}&sort={sort}&page={page}
Response: {
  data: [
    {
      id, name, description, type, status, member_count,
      last_activity: { message_preview, timestamp, user_name }
    }
  ],
  meta: { total, per_page, current_page, last_page }
}
```

### Aggregate Activity
```
GET /api/student/chat/spaces/activity-summary?days={n}
Response: { spaces: [{ space_id, message_count, last_message_at }] }
```

## Data Model

```sql
-- Tambah kolom pada chat_rooms (jika belum ada)
ALTER TABLE chat_rooms ADD COLUMN type VARCHAR(50) DEFAULT 'general';
ALTER TABLE chat_rooms ADD COLUMN status VARCHAR(20) DEFAULT 'active';
ALTER TABLE chat_rooms ADD COLUMN last_message_at TIMESTAMP NULL;

-- Index untuk pencarian dan sorting
CREATE INDEX idx_chat_rooms_type_status ON chat_rooms(type, status);
CREATE INDEX idx_chat_rooms_last_message ON chat_rooms(last_message_at DESC);

-- Full-text index untuk pencarian
CREATE INDEX idx_chat_rooms_search ON chat_rooms USING gin(to_tsvector('simple', name || ' ' || COALESCE(description, '')));
```

## Risks / Mitigations

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Daftar space besar memperlambat render | Loading lambat | Pagination + skeleton loading |
| Agregasi aktivitas berat | API lambat | Cache hasil aggregate, update saat ada pesan baru |
| Filter kombinasi menghasilkan 0 hasil | UX buruk | Empty state kontekstual + saran hapus filter |
| Preview pesan terakhir mengandung konten sensitif | Privasi | Batasi preview pada 100 karakter, sanitasi |

## Rollout Plan

1. **Phase 1**: Search + filter + sort (navigasi dasar)
2. **Phase 2**: Preview aktivitas terakhir (konteks ruang)
3. **Phase 3**: Empty state kontekstual (panduan aksi)

Setiap phase dilakukan validasi UX dan performa.
