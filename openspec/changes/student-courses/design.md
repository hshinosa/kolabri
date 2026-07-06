## Context

Halaman Courses (`/student/courses`) saat ini menampilkan daftar mata kuliah sebagai kartu sederhana dengan nama dan dosen pengampu. Peningkatan ini menambah pencarian, filter, kategori, dan pelacakan progres untuk membantu mahasiswa mengelola pembelajaran.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **Backend**: Laravel (API), Eloquent ORM
- **State**: URL query parameter untuk filter/search

## Goals / Non-Goals

**Goals:**
- Pencarian course cepat berdasarkan nama dan kode
- Filter berdasarkan status dan kategori
- Kategori course terlihat konsisten di setiap kartu
- Progres tiap course mudah dipahami dari halaman daftar

**Non-Goals:**
- Tidak mendesain ulang kurikulum atau struktur mata kuliah
- Tidak menambah engine rekomendasi personal
- Tidak mengubah sistem enrollment mata kuliah

## Decisions

### 1. Progress model sederhana
- Progres dihitung dari rasio materi/aktivitas yang sudah selesai
- Formula: `(jumlah_item_selesai / total_item) * 100`
- Status: "Belum mulai" (0%), "Berjalan" (1-99%), "Selesai" (100%)
- Data progres di-aggregate dari tabel progress tracking yang sudah ada

### 2. Kategori sebagai facet filter
- Kategori ditampilkan sebagai chip filter di bagian atas
- Multi-select diizinkan untuk fleksibilitas
- Kategori juga ditampilkan sebagai label berwarna pada kartu mata kuliah
- Data kategori dari tabel `courses.category`

### 3. Search + filter komposabel
- Search berjalan bersama filter kategori/status
- State disimpan di URL agar bisa dibagikan
- Reset ke halaman 1 saat filter/search berubah

### 4. Kartu mata kuliah enhanced
- Kartu menampilkan: nama, kode, dosen, kategori, progress bar, status
- Progress bar berwarna sesuai status (abu-abu, biru, hijau)
- Klik kartu masuk ke halaman detail course

### 5. Default sort by status
- Urutan default: Berjalan → Belum mulai → Selesai
- Opsi sort tambahan: nama A-Z, progres terendah/tertinggi

## Component Architecture

```
student/courses/
├── index.tsx                    # Halaman utama (enhanced)
├── components/
│   ├── SearchBar.tsx            # Kolom pencarian baru
│   ├── FilterChips.tsx          # Chip filter status/kategori
│   ├── SortDropdown.tsx         # Dropdown pengurutan
│   ├── CourseCard.tsx           # Kartu mata kuliah (enhanced)
│   │   ├── CategoryBadge.tsx    # Label kategori
│   │   └── ProgressBar.tsx      # Progress bar
│   ├── CourseGrid.tsx           # Grid daftar mata kuliah
│   └── EmptyState.tsx           # Empty state
└── hooks/
    └── useCourseFilters.ts      # Hook untuk state filter/search
```

## API Contracts

### List Courses
```
GET /api/student/courses?q={query}&filter[status]={status}&filter[category]={cat}&sort={sort}&page={page}
Response: {
  data: [
    {
      id, name, code, lecturer, category, status,
      progress: { percentage, completed_items, total_items, status_label }
    }
  ],
  meta: { total, per_page, current_page, last_page }
}
```

### Categories
```
GET /api/student/courses/categories
Response: { categories: [{ name, count }] }
```

## Data Model

```sql
-- Tambah kolom pada courses (jika belum ada)
ALTER TABLE courses ADD COLUMN category VARCHAR(100) NULL;

-- Tabel progress (asumsi sudah ada atau perlu dibuat)
CREATE TABLE student_course_progress (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES users(id),
    course_id BIGINT REFERENCES courses(id),
    completed_items INT DEFAULT 0,
    total_items INT DEFAULT 0,
    percentage DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'not_started',
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(student_id, course_id)
);

-- Index untuk pencarian dan filter
CREATE INDEX idx_courses_category ON courses(category);
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_search ON courses USING gin(to_tsvector('simple', name || ' ' || code));
```

## Risks / Mitigasi

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Perbedaan definisi progres antar course | Inkonsistensi | Formula standar berdasarkan rasio item selesai |
| Agregasi progres berat untuk banyak course | API lambat | Cache hasil progres, update saat ada perubahan |
| Kategori tidak konsisten | Kebingungan | Sediakan kategori default dari admin |
| Progress 0% membuat mahasiswa cemas | UX buruk | Tampilkan "Belum mulai" bukan angka 0% |

## Rollout Plan

1. **Phase 1**: Search + filter + kategori (navigasi dasar)
2. **Phase 2**: Progress tracking + status (pelacakan kemajuan)
3. **Phase 3**: Sort dan optimasi performa

Setiap phase dilakukan validasi data progres dan UX.
