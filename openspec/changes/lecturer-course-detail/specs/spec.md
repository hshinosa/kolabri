## ADDED Requirements

### Requirement: Student Progress Tracking
Halaman detail kursus SHALL menampilkan progress setiap mahasiswa termasuk progress bar, statistik completion, dan timestamp aktivitas terakhir.

#### Scenario: Melihat progress mahasiswa
- **WHEN** Dosen membuka tab Progress pada detail kursus
- **THEN** Sistem menampilkan daftar mahasiswa dengan progress bar per mahasiswa
- **AND** Setiap entry menunjukkan persentase completion dan waktu aktivitas terakhir

#### Scenario: Mengurutkan berdasarkan progress
- **WHEN** Dosen mengklik header kolom progress
- **THEN** Daftar mahasiswa diurutkan berdasarkan persentase completion
- **AND** Dapat diurutkan ascending atau descending

### Requirement: Attendance Management
Dosen SHALL dapat mengelola kehadiran mahasiswa termasuk menandai hadir/tidak hadir, melihat persentase kehadiran, dan mengekspor data.

#### Scenario: Membuka daftar kehadiran
- **WHEN** Dosen membuka tab Attendance
- **THEN** Sistem menampilkan daftar pertemuan dengan status kehadiran mahasiswa
- **AND** Persentase kehadiran per mahasiswa ditampilkan

#### Scenario: Menandai kehadiran
- **WHEN** Dosen memilih mahasiswa dan menandai "Hadir"
- **THEN** Status kehadiran di-update secara real-time
- **AND** Persentase kehadiran dihitung ulang

#### Scenario: Export data kehadiran
- **WHEN** Dosen klik "Export" pada tab Attendance
- **THEN** Sistem menggenerate file CSV dengan data kehadiran lengkap
- **AND** File otomatis di-download

### Requirement: Grade Book
Dosen SHALL dapat melihat dan menginput nilai mahasiswa dengan bulk entry dan melihat distribusi nilai.

#### Scenario: Melihat grade book
- **WHEN** Dosen membuka tab Grades
- **THEN** Sistem menampilkan tabel dengan mahasiswa di baris dan assignments di kolom
- **AND** Nilai yang sudah ada ditampilkan

#### Scenario: Bulk grade entry
- **WHEN** Dosen menginput nilai untuk beberapa mahasiswa sekaligus
- **THEN** Sistem menyimpan semua nilai setelah konfirmasi
- **AND** Distribusi nilai di-update otomatis

#### Scenario: Melihat distribusi nilai
- **WHEN** Dosen klik "View Distribution"
- **THEN** Sistem menampilkan chart distribusi nilai (histogram)
- **AND** Statistik (mean, median, min, max) ditampilkan

### Requirement: Materials Management
Dosen SHALL dapat mengupload dan mengelola materi perkuliahan yang diorganisir berdasarkan module.

#### Scenario: Upload materi
- **WHEN** Dosen klik "Upload Material" pada module tertentu
- **THEN** Sistem menampilkan file picker
- **AND** File di-upload dan muncul di daftar materi module tersebut

#### Scenario: Mengorganisir materi by module
- **WHEN** Dosen membuat module baru
- **THEN** Module baru muncul di daftar
- **AND** Dapat drag-and-drop materi antar module

#### Scenario: Melihat material views
- **WHEN** Dosen melihat daftar materi
- **THEN** Setiap materi menunjukkan jumlah views dari mahasiswa
