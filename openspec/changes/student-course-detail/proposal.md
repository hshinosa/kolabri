## Why

Halaman detail course adalah area utama mahasiswa mengakses materi pembelajaran. Saat ini informasi tersebar di beberapa halaman terpisah: materi di satu tempat, syllabus di tempat lain, dan tidak ada panel progres atau deadline yang terintegrasi. Mahasiswa harus berpindah-pindah untuk mendapatkan gambaran lengkap tentang course mereka.

Permasalahan utama:
- **Fragmentation**: Informasi course tersebar di beberapa halaman
- **Visibility**: Progres belajar dan deadline tidak terlihat di satu tempat
- **Navigation**: Tidak ada cara cepat melihat urutan topik dan statusnya
- **Prioritization**: Tidak ada visibilitas tenggat tugas yang akan datang

## What Changes

### 1. Materials Section
Menampilkan materi pembelajaran secara terstruktur berdasarkan modul/topik dengan status penyelesaian.

### 2. Syllabus Section
Menampilkan silabus course secara berurutan dari awal hingga akhir dengan indikator topik yang sudah dibahas.

### 3. Course Progress Panel
Menampilkan progres keseluruhan course dan rincian progres per modul.

### 4. Deadline Panel
Menampilkan daftar tenggat tugas/aktivitas yang diurutkan dari yang paling dekat dengan status (Akan datang, Hari ini, Terlewat).

## Capabilities

### New Capabilities
- `student-course-detail-materials`: Akses materi pembelajaran terstruktur
- `student-course-detail-syllabus`: Tampilan silabus berurutan
- `student-course-detail-progress`: Panel prokes per modul
- `student-course-detail-deadlines`: Panel tenggat tugas

## User Stories

1. **Sebagai mahasiswa**, saya ingin melihat semua materi course di satu halaman sehingga saya bisa belajar secara terstruktur
2. **Sebagai mahasiswa**, saya ingin melihat silabus berurutan sehingga saya tahu alur pembelajaran
3. **Sebagai mahasiswa**, saya ingin melihat progres per modul sehingga saya tahu bagian mana yang sudah selesai
4. **Sebagai mahasiswa**, saya ingin melihat tenggat tugas yang akan datang sehingga saya bisa memprioritaskan pekerjaan

## Impact

- **Frontend**: Halaman detail course dengan tab/section materials, syllabus, progres, deadline
- **Backend/API**: Endpoint detail course dengan agregasi deadline/progres
- **Data**: Konsistensi data materials dan syllabus dari sumber kurikulum
- **Breaking changes**: Tidak ada

## Note

Perubahan ini bersifat **spec-only** (tanpa `tasks.md`). Spesifikasi ini akan digunakan sebagai panduan untuk implementasi di masa depan setelah stakeholder akademik memvalidasi desain halaman.
