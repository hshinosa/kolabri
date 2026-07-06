## 1. Backend - Aktivitas Diskusi

- [x] 1.1 Buat endpoint untuk mengambil data aktivitas diskusi per mahasiswa per course
- [x] 1.2 Implementasi agregasi: total pesan, frekuensi aktif (hari per minggu), rata-rata pesan per sesi
- [x] 1.3 Tambah last_activity tracking pada enrollment
- [x] 1.4 Buat endpoint export aktivitas diskusi CSV

## 2. Backend - Attendance

- [x] 2.1 Buat tabel `attendance_records` (migration)
- [x] 2.2 Buat API endpoints untuk attendance CRUD
- [x] 2.3 Buat endpoint export attendance CSV
- [x] 2.4 Implementasi attendance percentage calculation

## 3. Backend - Materials

- [x] 3.1 Buat tabel `course_materials` (migration)
- [x] 3.2 Buat API endpoints untuk materials CRUD
- [x] 3.3 Implementasi file upload service
- [x] 3.4 Tambah material view tracking

## 4. Frontend - Tab Navigation

- [x] 4.1 Buat komponen `CourseDetailTabs` (Aktivitas, Attendance, Materials)
- [x] 4.2 Implementasi lazy loading per tab
- [x] 4.3 Tambah URL routing per tab

## 5. Frontend - Aktivitas Diskusi

- [x] 5.1 Buat komponen `StudentActivityList`
- [x] 5.2 Buat komponen `ActivityIndicator` (total pesan, frekuensi)
- [x] 5.3 Implementasi sorting by aktivitas dan last activity
- [x] 5.4 Tambah search/filter mahasiswa

## 6. Frontend - Attendance

- [x] 6.1 Buat komponen `AttendanceTable`
- [x] 6.2 Buat komponen `AttendanceMarking` (present/absent toggle)
- [x] 6.3 Implementasi attendance percentage display
- [x] 6.4 Tambah export button dengan download

## 7. Frontend - Materials

- [x] 7.1 Buat komponen `MaterialsList` per module
- [x] 7.2 Buat komponen `MaterialUpload`
- [x] 7.3 Buat komponen `ModuleManager` (create, reorder)
- [x] 7.4 Tambah material views counter
