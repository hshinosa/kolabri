## ADDED Requirements

### Requirement: Scheduled Sessions
Dosen SHALL dapat menjadwalkan sessions untuk waktu tertentu dengan auto-activate.

#### Scenario: Menjadwalkan session
- **WHEN** Dosen membuat session baru dan mengatur waktu mulai
- **THEN** Sistem menyimpan session dengan status "Scheduled"
- **AND** Session otomatis aktif pada waktu yang dijadwalkan

#### Scenario: Melihat scheduled sessions
- **WHEN** Dosen membuka tab "Scheduled"
- **THEN** Sistem menampilkan daftar sessions yang belum aktif
- **AND** Setiap entry menunjukkan waktu aktifasi yang dijadwalkan

#### Scenario: Membatalkan scheduled session
- **WHEN** Dosen membatalkan scheduled session
- **THEN** Session di-cancel dan tidak jadi aktif
- **AND** Notifikasi terkait dibatalkan

### Requirement: Auto-Close
Sistem SHALL secara otomatis menutup sessions yang tidak aktif setelah timeout yang dikonfigurasi.

#### Scenario: Session auto-close terpicu
- **WHEN** Session tidak ada aktivitas selama timeout period
- **THEN** Sistem mengubah status session menjadi "Closed"
- **AND** Peserta mendapat notifikasi bahwa session ditutup

#### Scenario: Mengkonfigurasi auto-close timeout
- **WHEN** Dosen mengatur auto-close timeout saat membuat session
- **THEN** Sistem menggunakan timeout tersebut
- **AND** Default timeout digunakan jika tidak diatur

#### Scenario: Grace period sebelum auto-close
- **WHEN** Session akan auto-close dalam 5 menit
- **THEN** Sistem mengirim warning ke peserta
- **AND** Aktivitas apapun mereset timer

### Requirement: Session Templates
Dosen SHALL dapat menyimpan dan menggunakan template untuk session configuration.

#### Scenario: Menyimpan session sebagai template
- **WHEN** Dosen klik "Save as Template" pada session yang ada
- **THEN** Sistem menyimpan konfigurasi session sebagai template
- **AND** Template muncul di daftar templates

#### Scenario: Membuat session dari template
- **WHEN** Dosen memilih template saat membuat session baru
- **THEN** Form diisi dengan konfigurasi dari template
- **AND** Dosen dapat mengubah sebelum menyimpan

#### Scenario: Mengedit template
- **WHEN** Dosen mengedit template yang ada
- **THEN** Perubahan disimpan
- **AND** Template yang sudah digunakan tidak terpengaruh

### Requirement: Bulk Operations
Dosen SHALL dapat melakukan operasi massal pada beberapa sessions sekaligus.

#### Scenario: Bulk close sessions
- **WHEN** Dosen memilih beberapa sessions dan klik "Close All"
- **THEN** Sistem menampilkan konfirmasi dengan jumlah sessions
- **AND** Setelah konfirmasi, semua sessions terpilih di-close

#### Scenario: Bulk archive sessions
- **WHEN** Dosen memilih sessions dan klik "Archive"
- **THEN** Sessions di-archive dan dihapus dari active view
- **AND** Data sessions tetap tersedia di archive

#### Scenario: Bulk delete sessions
- **WHEN** Dosen memilih sessions dan klik "Delete"
- **THEN** Sistem menampilkan konfirmasi dengan peringatan permanen
- **AND** Setelah konfirmasi, sessions dihapus permanen
