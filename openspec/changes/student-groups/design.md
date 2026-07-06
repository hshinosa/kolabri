## Context

Halaman Groups (`/student/groups`) dipakai mahasiswa untuk kerja tim pada tugas dan proyek. Peningkatan fokus pada visibilitas aktivitas, pengelolaan anggota, dan kontrol pengaturan dasar.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **Backend**: Laravel (API), Eloquent ORM
- **Real-time**: Socket.io untuk notifikasi aktivitas (opsional)

## Goals / Non-Goals

**Goals:**
- Cari anggota dengan cepat berdasarkan nama atau identifier
- Lihat aktivitas grup terbaru untuk awareness koordinasi
- Kelola pengaturan dasar grup (nama, deskripsi, kebijakan akses)

**Non-Goals:**
- Tidak menambah fitur video meeting atau voice chat
- Tidak menambah workflow persetujuan multi-level
- Tidak menambah fitur manajemen tugas lengkap (sudah ada di tempat lain)

## Decisions

### 1. Member search berbasis nama/identifier
- Pencarian mendukung nama lengkap dan email/ID kampus
- Pencarian dilakukan di server untuk menangani grup besar
- Hasil menampilkan: nama, foto, peran dalam grup, status online

### 2. Activity feed terurut waktu
- Feed menampilkan event penting:
  - Anggota bergabung/keluar
  - Tugas dikumpulkan
  - Komentar baru pada dokumen
  - Update dokumen/file
  - Perubahan pengaturan grup
- Feed diurutkan dari yang paling baru
- Pagination untuk feed yang panjang
- Filter berdasarkan jenis aktivitas (opsional)

### 3. Settings minimum viable
- Pengaturan mencakup:
  - Nama grup (wajib)
  - Deskripsi grup (opsional)
  - Kebijakan akses (terbuka/tertutup)
  - Ikon/foto grup (opsional)
- Hanya admin/owner yang bisa mengubah pengaturan
- Perubahan dicatat di activity feed

### 4. Permission model
- **Owner**: Bisa mengubah semua pengaturan, mengelola anggota
- **Admin**: Bisa mengubah sebagian pengaturan, mengelola anggota
- **Member**: Bisa melihat, mencari, berkontribusi
- Peran ditampilkan pada profil anggota

### 5. Real-time activity (opsional)
- Aktivitas baru bisa di-push via Socket.io untuk awareness real-time
- Badge "baru" pada item feed yang belum dibaca

## Component Architecture

```
student/groups/[id]/
├── index.tsx                    # Halaman grup
├── components/
│   ├── GroupHeader.tsx          # Header grup dengan info dasar
│   ├── MemberSearch.tsx         # Kolom pencarian anggota
│   ├── MemberList.tsx           # Daftar anggota dengan filter
│   │   └── MemberCard.tsx       # Kartu anggota dengan peran
│   ├── ActivityFeed.tsx         # Feed aktivitas grup
│   │   └── ActivityItem.tsx     # Item aktivitas dengan ikon
│   └── GroupSettings.tsx        # Halaman pengaturan grup
│       └── SettingsForm.tsx     # Form pengaturan
└── hooks/
    ├── useGroupMembers.ts       # Hook untuk data anggota
    └── useActivityFeed.ts       # Hook untuk data aktivitas
```

## API Contracts

### Search Members
```
GET /api/student/groups/{groupId}/members?q={query}&role={role}
Response: { members: [{ id, name, email, avatar, role, is_online }] }
```

### Activity Feed
```
GET /api/student/groups/{groupId}/activities?cursor={id}&limit={n}&type={type}
Response: {
  activities: [{ id, type, description, performed_by, created_at, metadata }],
  next_cursor
}
```

### Group Settings
```
GET /api/student/groups/{groupId}/settings
Response: { name, description, access_policy, avatar_url }

PATCH /api/student/groups/{groupId}/settings
Body: { name?, description?, access_policy? }
Response: { success: true, group: {...} }
```

### Update Member Role
```
PATCH /api/student/groups/{groupId}/members/{memberId}
Body: { role: "admin"|"member" }
Response: { success: true }
Authorization: Owner only
```

## Data Model

```sql
-- Tambah kolom pada groups (jika belum ada)
ALTER TABLE groups ADD COLUMN description TEXT NULL;
ALTER TABLE groups ADD COLUMN access_policy VARCHAR(20) DEFAULT 'open';  -- open, closed
ALTER TABLE groups ADD COLUMN avatar_url VARCHAR(500) NULL;

-- Tabel activity log
CREATE TABLE group_activities (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT REFERENCES groups(id),
    type VARCHAR(50) NOT NULL,  -- member_joined, member_left, task_submitted, comment_added, document_updated, settings_changed
    description TEXT NOT NULL,
    performed_by BIGINT REFERENCES users(id),
    metadata JSONB NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk feed performant
CREATE INDEX idx_group_activities_group ON group_activities(group_id, created_at DESC);
CREATE INDEX idx_group_activities_type ON group_activities(group_id, type);
```

## Risks / Mitigations

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Feed terlalu ramai untuk grup aktif | Informasi berlebihan | Filter jenis aktivitas, pagination |
| Search anggota lambat untuk grup besar | UX buruk | Index pada nama dan email, debounce |
| Perubahan pengaturan tanpa notifikasi | Kebingungan | Catat di activity feed, notifikasi ke anggota |
| Peran tidak jelas | Konflik | Tampilkan peran pada profil, batasi aksi berdasarkan peran |

## Rollout Plan

1. **Phase 1**: Member search + member list dengan peran
2. **Phase 2**: Activity feed dengan filter
3. **Phase 3**: Group settings dengan validasi peran

Setiap phase dilakukan validasi UX dan permission testing.
