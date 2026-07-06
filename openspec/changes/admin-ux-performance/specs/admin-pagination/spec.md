## ADDED Requirements

### Requirement: Pagination dan infinite scroll
Sistem SHALL menyediakan pagination dan infinite scroll untuk data loading.

#### Scenario: Pagination muncul di tabel
- **WHEN** admin melihat tabel dengan banyak data
- **THEN** pagination muncul di bawah tabel
- **AND** admin bisa klik halaman untuk navigasi

#### Scenario: Infinite scroll
- **WHEN** admin scroll ke bawah
- **THEN** sistem memuat data berikutnya secara otomatis
- **AND** tidak ada halaman yang perlu di-refresh

#### Scenario: Load more button
- **WHEN** infinite scroll tidak tersedia
- **THEN** "Load more" button muncul
- **AND** admin bisa klik button untuk memuat data berikutnya

#### Scenario: Loading indicator
- **WHEN** sistem sedang memuat data
- **THEN** loading indicator muncul
- **AND** admin tahu bahwa data sedang dimuat
