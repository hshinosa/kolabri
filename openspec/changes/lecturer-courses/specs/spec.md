## ADDED Requirements

### Requirement: Analytics Overview Cards
Halaman courses SHALL menampilkan cards analytics yang menunjukkan total mahasiswa aktif, rata-rata engagement score, dan completion rate per kursus.

#### Scenario: Melihat analytics overview
- **WHEN** Dosen membuka halaman courses
- **THEN** Sistem menampilkan analytics cards di bagian atas halaman
- **AND** Setiap card menunjukkan nilai numerik dan trend indicator (naik/turun/stabil)

#### Scenario: Analytics data kosong
- **WHEN** Dosen belum memiliki kursus aktif
- **THEN** Sistem menampilkan placeholder dengan nilai 0 dan pesan "Belum ada data"

### Requirement: Bulk Actions
Dosen SHALL dapat memilih beberapa kursus sekaligus dan melakukan operasi massal (archive, publish, export).

#### Scenario: Memilih kursus untuk bulk action
- **WHEN** Dosen mengaktifkan selection mode
- **THEN** Checkbox muncul di setiap kartu kursus
- **AND** Toolbar bulk actions muncul di bagian bawah halaman

#### Scenario: Melakukan bulk archive
- **WHEN** Dosen memilih 3 kursus dan klik "Archive"
- **THEN** Sistem menampilkan konfirmasi dengan jumlah kursus yang dipilih
- **AND** Setelah konfirmasi, semua kursus terpilih di-archive dan dihapus dari tampilan utama

#### Scenario: Membatalkan selection
- **WHEN** Dosen klik "Cancel" atau uncheck semua
- **THEN** Selection mode dinonaktifkan dan toolbar menghilang

### Requirement: Search & Filter
Dosen SHALL dapat mencari kursus berdasarkan nama atau kode dan memfilter berdasarkan semester, status, dan kategori.

#### Scenario: Mencari kursus berdasarkan nama
- **WHEN** Dosen mengetik "Pemrograman" di search bar
- **THEN** Daftar kursus difilter secara real-time menunjukkan hanya kursus yang mengandung kata "Pemrograman"

#### Scenario: Filter berdasarkan semester
- **WHEN** Dosen memilih filter semester "Ganjil 2025"
- **THEN** Hanya kursus semester Ganjil 2025 yang ditampilkan

#### Scenario: Kombinasi search dan filter
- **WHEN** Dosen mencari "Web" dan memfilter status "Aktif"
- **THEN** Hanya kursus aktif yang mengandung kata "Web" yang ditampilkan

### Requirement: Course Templates
Dosen SHALL dapat menyimpan struktur kursus sebagai template dan menerapkan template saat membuat kursus baru.

#### Scenario: Menyimpan kursus sebagai template
- **WHEN** Dosen klik "Simpan sebagai Template" pada kursus yang ada
- **THEN** Sistem menyimpan struktur modules, assignments, dan settings
- **AND** Template muncul di daftar template milik dosen

#### Scenario: Membuat kursus dari template
- **WHEN** Dosen memilih template saat membuat kursus baru
- **THEN** Sistem mengisi form pembuatan kursus dengan data dari template
- **AND** Dosen dapat mengubah sebelum menyimpan

#### Scenario: Menghapus template
- **WHEN** Dosen menghapus template yang sudah tidak diperlukan
- **THEN** Sistem menghapus template dan menampilkan konfirmasi
