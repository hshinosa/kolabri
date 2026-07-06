## ADDED Requirements

### Requirement: Export Reports
Dosen SHALL dapat mengekspor data analytics sebagai PDF atau CSV.

#### Scenario: Export sebagai CSV
- **WHEN** Dosen klik "Export CSV" pada halaman analytics
- **THEN** Sistem menggenerate file CSV dengan data analytics yang sedang ditampilkan
- **AND** File otomatis di-download

#### Scenario: Export sebagai PDF
- **WHEN** Dosen klik "Export PDF"
- **THEN** Sistem menggenerate PDF dengan charts dan data terformat
- **AND** PDF di-download atau dikirim ke email

### Requirement: Date Filter
Dosen SHALL dapat memfilter data analytics berdasarkan custom date range atau presets.

#### Scenario: Menggunakan date preset
- **WHEN** Dosen memilih preset "Semester Ini"
- **THEN** Data analytics difilter menampilkan hanya data semester berjalan
- **AND** Range dates ter-update di date picker

#### Scenario: Custom date range
- **WHEN** Dosen memilih tanggal mulai dan akhir secara manual
- **THEN** Data analytics difilter sesuai range yang dipilih
- **AND** Charts dan statistik di-update

### Requirement: Comparison View
Dosen SHALL dapat membandingkan data analytics antar kursus, semester, atau kelompok mahasiswa.

#### Scenario: Membandingkan antar kursus
- **WHEN** Dosen memilih 2-3 kursus untuk dibandingkan
- **THEN** Sistem menampilkan charts dengan data setiap kursus sebagai overlay
- **AND** Setiap kursus memiliki warna berbeda

#### Scenario: Membandingkan antar semester
- **WHEN** Dosen memilih semester "Ganjil 2024" dan "Ganjil 2025"
- **THEN** Sistem menampilkan trend comparison antara kedua semester
- **AND** Perubahan persentase ditampilkan

### Requirement: Trend Charts
Halaman analytics SHALL menampilkan charts trend untuk engagement, completion, dan attendance.

#### Scenario: Melihat engagement trend
- **WHEN** Dosen membuka halaman analytics
- **THEN** Sistem menampilkan line chart engagement score over time
- **AND** Data points per minggu/bulan tergantung range

#### Scenario: Melihat completion trend
- **WHEN** Dosen memilih metric "Completion Rate"
- **THEN** Chart menampilkan trend completion rate dari waktu ke waktu
- **AND** Target line ditampilkan jika ada
