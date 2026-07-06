## Context
Halaman detail kursus lecturer (`lecturer/courses/show.tsx`) saat ini menampilkan informasi dasar kursus dan daftar mahasiswa. Dosen memerlukan fitur lengkap untuk monitoring dan pengelolaan akademik dari satu halaman.

## Goals / Non-Goals
**Goals:**
- Memungkinkan dosen memantau progress mahasiswa secara real-time
- Menyediakan tools kehadiran yang efisien
- Memberikan grade book untuk input dan monitoring nilai
- Mengelola materi perkuliahan terstruktur

**Non-Goals:**
- Tidak mengubah sistem grading atau rubrik (ada fitur terpisah)
- Tidak mengubah sistem enrollment
- Tidak menambah fitur video conferencing

## Decisions
### 1. Tab-based navigation untuk sub-fitur
Menggunakan tab navigation untuk memisahkan Progress, Attendance, Grades, dan Materials. Memungkinkan dosen fokus pada satu aspek tanpa scrolling berlebihan.

### 2. Attendance menggunakan session-based recording
Setiap sesi kehadiran terikat pada pertemuan. Memungkinkan tracking per-pertemuan dan perhitungan persentase otomatis.

### 3. Grade book dengan inline editing
Dosen dapat mengedit nilai langsung di tabel tanpa perlu modal terpisah. Mempercepat proses input bulk.

### 4. Materials organized by modules
Materi diorganisir berdasarkan module/week. Konsisten dengan struktur kurikulum dan memudahkan navigasi mahasiswa.

## Risks / Mitigations
- **Risiko**: Banyak data (grades, attendance) bisa membebani halaman
  - **Mitigasi**: Lazy loading per tab, pagination untuk data besar

- **Risiko**: Bulk grade entry rentan input error
  - **Mitigasi**: Validation, undo functionality, confirmation sebelum save bulk

## Rollout Plan
1. **Phase 1**: Student progress tracking
2. **Phase 2**: Attendance management
3. **Phase 3**: Grade book
4. **Phase 4**: Materials management
