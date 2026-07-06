## Context

Halaman detail course (`/student/courses/[id]`) saat ini menampilkan informasi dasar course dengan daftar materi sederhana. Peningkatan ini merancang ulang halaman menjadi satu sumber informasi pembelajaran yang komprehensif.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **Backend**: Laravel (API), Eloquent ORM
- **Data**: Tabel courses, materials, syllabus, assignments, progress

## Goals / Non-Goals

**Goals:**
- Menyatukan materials, syllabus, progres, dan deadline di satu halaman
- Mengurangi friksi berpindah antar menu untuk mengakses informasi course
- Membantu prioritisasi tugas berdasarkan tenggat
- Memberikan gambaran progres belajar yang granular per modul

**Non-Goals:**
- Tidak menambah fitur authoring materi untuk dosen
- Tidak menambah notifikasi push baru
- Tidak mengubah struktur data kurikulum yang sudah ada

## Decisions

### 1. Struktur halaman bertingkat
- **Header**: Ringkasan course (nama, kode, dosen, progres keseluruhan)
- **Tab Navigation**: Materials | Silabus | Progres | Tenggat
- **Atau** section-based layout (scrollable) tanpa tab
- Keputusan akhir berdasarkan user testing

### 2. Deadline-first insight
- Panel "Tenggat Terdekat" selalu terlihat di bagian atas (sticky)
- Status deadline:
  - **Akan datang**: Lebih dari 24 jam dari sekarang
  - **Hari ini**: Kurang dari 24 jam dari sekarang
  - **Terlewat**: Sudah melewati tenggat
- Warna indikator: Abu-abu (akan datang), Kuning (hari ini), Merah (terlewat)

### 3. Progres per section/modul
- Progres ditampilkan per modul/section agar granular
- Setiap modul menampilkan: jumlah item, item selesai, progress bar
- Progres keseluruhan adalah rata-rata dari semua modul

### 4. Materials terstruktur
- Materi dikelompokkan berdasarkan modul/topik
- Setiap item materi menampilkan: judul, tipe (video/dokumen/quiz), status
- Status: Belum dilihat, Sedang dikerjakan, Selesai

### 5. Syllabus kronologis
- Silabus menampilkan urutan topik dari awal hingga akhir
- Setiap topik menampilkan: nomor, judul, durasi, status (akan datang/sedang berlangsung/selesai)
- Topik yang sedang berlangsung di-highlight

### 6. Konsistensi data
- Data materials dan syllabus berasal dari sumber kurikulum yang sama
- Deadline disusun kronologis ascending
- Validasi konsistensi tanggal di API layer

## Component Architecture

```
student/courses/[id]/
├── index.tsx                    # Halaman detail course
├── components/
│   ├── CourseHeader.tsx         # Ringkasan course + progres keseluruhan
│   ├── DeadlinePanel.tsx        # Panel tenggat terdekat (sticky)
│   │   └── DeadlineItem.tsx     # Item tenggat dengan status
│   ├── TabNavigation.tsx        # Navigasi tab (jika tab-based)
│   ├── MaterialsSection.tsx     # Section materi pembelajaran
│   │   ├── ModuleGroup.tsx      # Grup materi per modul
│   │   └── MaterialItem.tsx     # Item materi dengan status
│   ├── SyllabusSection.tsx      # Section silabus
│   │   └── TopicItem.tsx        # Item topik dengan status
│   └── ProgressSection.tsx      # Section progres per modul
│       └── ModuleProgress.tsx   # Progress bar per modul
└── hooks/
    └── useCourseDetail.ts       # Hook untuk fetch data detail course
```

## API Contracts

### Course Detail
```
GET /api/student/courses/{courseId}
Response: {
  id, name, code, lecturer, category,
  progress: { overall_percentage, modules: [{ id, name, percentage, completed, total }] },
  deadlines: [{ id, title, due_at, status, type }],
  materials: [{ id, module_id, title, type, status, url }],
  syllabus: [{ id, topic_number, title, duration, status }]
}
```

### Materials by Module
```
GET /api/student/courses/{courseId}/materials?module={moduleId}
Response: { materials: [{ id, title, type, status, url, completed_at }] }
```

### Update Material Status
```
PATCH /api/student/courses/{courseId}/materials/{materialId}
Body: { status: "completed" }
Response: { success: true, progress_updated: true }
```

## Data Model

```sql
-- Asumsi tabel sudah ada:
-- courses, course_modules, course_materials, course_syllabus, assignments

-- Tambah kolom pada assignments (jika belum ada)
ALTER TABLE assignments ADD COLUMN due_at TIMESTAMP NULL;
ALTER TABLE assignments ADD COLUMN type VARCHAR(50) DEFAULT 'task';

-- Tabel progress material per mahasiswa
CREATE TABLE student_material_progress (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES users(id),
    material_id BIGINT REFERENCES course_materials(id),
    status VARCHAR(20) DEFAULT 'not_viewed',  -- not_viewed, in_progress, completed
    completed_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(student_id, material_id)
);

-- Index untuk query performant
CREATE INDEX idx_material_progress_student ON student_material_progress(student_id, material_id);
CREATE INDEX idx_assignments_due ON assignments(course_id, due_at);
```

## Risks / Mitigations

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Data deadline tidak sinkron dengan sistem lain | Kebingungan | Validasi konsistensi tanggal di API layer |
| Progres per modul tidak akurat | Kepercayaan turun | Sinkronisasi real-time saat material diselesaikan |
| Halaman terlalu berat untuk course besar | Loading lambat | Lazy load section, virtualisasi list |
| Silabus tidak sesuai dengan materi aktual | Inkonsistensi | Validasi data dari sumber kurikulum |

## Rollout Plan

1. **Spec Review**: Validasi dengan stakeholder akademik
2. **Data Validation**: Pastikan data materials dan syllabus konsisten
3. **Prototype**: Buat prototype UI untuk user testing
4. **Implementation**: Setelah spesifikasi disetujui

## Note

Perubahan ini bersifat **spec-only**. Task breakdown akan dibuat setelah spesifikasi divalidasi oleh stakeholder.
