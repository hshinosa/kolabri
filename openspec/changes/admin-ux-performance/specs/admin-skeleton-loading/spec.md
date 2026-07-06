## ADDED Requirements

### Requirement: Skeleton loading saat data loading
Sistem SHALL menampilkan skeleton loading saat data loading.

#### Scenario: Skeleton muncul saat loading
- **WHEN** halaman admin sedang memuat data
- **THEN** skeleton loading muncul
- **AND** skeleton menyerupai layout konten yang akan dimuat

#### Scenario: Skeleton hilang setelah loading
- **WHEN** data selesai dimuat
- **THEN** skeleton loading hilang
- **AND** konten yang sebenarnya muncul

#### Scenario: Animasi shimmer
- **WHEN** skeleton loading muncul
- **THEN** animasi shimmer berjalan
- **AND** admin tahu bahwa konten sedang dimuat
