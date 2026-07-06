## Why
Halaman detail kursus lecturer saat ini hanya menampilkan informasi dasar. Dosen membutuhkan tools untuk memantau progress mahasiswa, mengelola kehadiran, melihat dan menginput nilai, serta mengelola materi perkuliahan.

## What Changes
- Aktivitas diskusi tracking: total pesan, frekuensi aktif, rata-rata pesan per sesi
- Attendance management (daftar kehadiran, mark present/absent, export)
- Materials management (upload, organize by module, track views)

## Capabilities
### New Capabilities
- `student-activity-tracking`: Tracking aktivitas diskusi mahasiswa
- `attendance-management`: Manajemen kehadiran
- `materials-management`: Manajemen materi perkuliahan

## Impact
- **Frontend**: Tabs baru di halaman course detail: Aktivitas, Attendance, Materials
- **Backend/API**: Endpoint untuk aktivitas diskusi, attendance CRUD, materials upload/management
- **Data**: Tabel `attendance_records`, `course_materials`, kolom `material_views` tracking
- **Breaking changes**: Tidak ada
