## Context

Halaman Reflections (`/student/reflections`) saat ini menampilkan daftar refleksi dengan editor sederhana. Peningkatan ini menambah template, pencarian, ekspor, dan analitik untuk mendorong kebiasaan refleksi yang lebih konsisten dan terukur.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **Backend**: Laravel (API), Eloquent ORM
- **Editor**: Rich text editor (misal: Tiptap atau Quill)

## Goals / Non-Goals

**Goals:**
- Mempermudah mulai menulis refleksi dengan template
- Menyediakan pencarian untuk menemukan refleksi lama
- Menyediakan ekspor untuk dokumentasi dan portofolio
- Menampilkan analitik tren refleksi untuk umpan balik

**Non-Goals:**
- Tidak menambah sistem penilaian otomatis berbasis AI
- Tidak menambah kolaborasi multi-penulis pada satu refleksi
- Tidak menambah fitur komentar atau review dari dosen

## Decisions

### 1. Template bertingkat
- **Template global**: Dibuat oleh admin, tersedia untuk semua mahasiswa
- **Template personal**: Dibuat oleh mahasiswa, hanya untuk diri sendiri
- Template berisi: judul, deskripsi, kerangka isi (prompt/pertanyaan panduan)
- Kategori template: Harian, Mingguan, Proyek, Evaluasi Diri

### 2. Search full-text
- Pencarian pada judul, isi, dan tag refleksi
- Menggunakan full-text search di server
- Hasil diurutkan berdasarkan relevansi dan recency
- Filter berdasarkan tag dan rentang tanggal

### 3. Export portable
- Format yang didukung: PDF, Markdown, Plain Text
- Ekspor mencakup: judul, tanggal, isi, tag
- Opsi ekspor: single reflection atau batch (beberapa refleksi)
- File sementara dihapus setelah 24 jam

### 4. Analytics pragmatis
- **Frekuensi menulis**: Jumlah refleksi per minggu/bulan
- **Panjang rata-rata**: Rata-rata kata per refleksi
- **Tren waktu**: Grafik frekuensi dan panjang dari waktu ke waktu
- **Konsistensi**: Streak menulis beruntun
- **Tag terpopuler**: Tag yang paling sering digunakan
- Visual menggunakan chart sederhana (bar chart, line chart)

### 5. Tag system
- Refleksi bisa diberi tag untuk kategorisasi
- Tag bersifat free-text dengan auto-suggest dari tag yang sudah ada
- Tag ditampilkan sebagai chip pada daftar refleksi
- Filter berdasarkan tag di halaman daftar

## Component Architecture

```
student/reflections/
├── index.tsx                    # Halaman daftar refleksi
├── [id]/page.tsx                # Halaman detail/edit refleksi
├── components/
│   ├── ReflectionList.tsx       # Daftar refleksi
│   │   └── ReflectionCard.tsx   # Kartu refleksi dengan tag
│   ├── SearchBar.tsx            # Kolom pencarian
│   ├── FilterChips.tsx          # Filter tag dan tanggal
│   ├── TemplatePanel.tsx        # Panel template
│   │   └── TemplateCard.tsx     # Kartu template
│   ├── ExportModal.tsx          # Modal ekspor
│   ├── AnalyticsPanel.tsx       # Panel analitik
│   │   ├── FrequencyChart.tsx   # Grafik frekuensi
│   │   ├── LengthChart.tsx      # Grafik panjang rata-rata
│   │   └── StreakIndicator.tsx  # Indikator streak
│   └── TagInput.tsx             # Input tag dengan auto-suggest
└── hooks/
    ├── useReflections.ts        # Hook untuk data refleksi
    └── useReflectionAnalytics.ts # Hook untuk data analitik
```

## API Contracts

### List Reflections
```
GET /api/student/reflections?q={query}&tag={tag}&from={date}&to={date}&sort={sort}&page={page}
Response: {
  data: [{ id, title, content_preview, tags, word_count, created_at, updated_at }],
  meta: { total, per_page, current_page, last_page }
}
```

### Templates
```
GET    /api/student/reflections/templates?category={cat}
POST   /api/student/reflections/templates           { title, description, content_template, category }
PUT    /api/student/reflections/templates/{id}       { title, description, content_template, category }
DELETE /api/student/reflections/templates/{id}
```

### Export
```
POST /api/student/reflections/export  { reflection_ids: [], format: "pdf"|"markdown"|"text" }
GET  /api/student/reflections/exports/{jobId}
GET  /api/student/reflections/exports/{jobId}/download
```

### Analytics
```
GET /api/student/reflections/analytics?period={week|month|year}
Response: {
  frequency: { current, previous, trend },
  average_length: { current, previous, trend },
  streak: { current, longest },
  tags: [{ name, count }],
  timeline: [{ period, count, avg_length }]
}
```

### Tags
```
GET /api/student/reflections/tags
Response: { tags: [{ name, count }] }
```

## Data Model

```sql
-- Tambah kolom pada reflections (jika belum ada)
ALTER TABLE reflections ADD COLUMN word_count INT DEFAULT 0;
ALTER TABLE reflections ADD COLUMN tags JSONB DEFAULT '[]';

-- Tabel template
CREATE TABLE reflection_templates (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) NULL,  -- NULL = global template
    title VARCHAR(255) NOT NULL,
    description TEXT,
    content_template TEXT NOT NULL,
    category VARCHAR(50),  -- daily, weekly, project, self_evaluation
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabel export job
CREATE TABLE reflection_export_jobs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    format VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    file_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- Index untuk pencarian dan analitik
CREATE INDEX idx_reflections_search ON reflections USING gin(to_tsvector('simple', title || ' ' || content));
CREATE INDEX idx_reflections_tags ON reflections USING gin(tags);
CREATE INDEX idx_reflections_user_date ON reflections(user_id, created_at DESC);
```

## Risks / Mitigasi

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Visual analitik membingungkan | Interpretasi salah | Label narasi ringkas pada setiap metrik |
| Template terlalu banyak | Pilihan berlebihan | Kategori template, limit 30 personal |
| Ekspor PDF kompleks | Bug, timeout | Gunakan library proven, proses asinkron |
| Pencarian lambat pada data besar | UX buruk | Full-text index, debounce, pagination |

## Rollout Plan

1. **Phase 1**: Template + search (kemudahan menulis)
2. **Phase 2**: Ekspor (dokumentasi)
3. **Phase 3**: Analytics (umpan balik)

Setiap phase dilakukan validasi UX dan performa.
