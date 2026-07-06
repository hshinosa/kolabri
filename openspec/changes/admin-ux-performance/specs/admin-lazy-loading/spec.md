## ADDED Requirements

### Requirement: Lazy loading untuk images
Sistem SHALL menggunakan lazy loading untuk images.

#### Scenario: Images lazy load
- **WHEN** halaman admin memiliki banyak images
- **THEN** images dimuat secara lazy
- **AND** hanya images yang terlihat yang dimuat

#### Scenario: Placeholder muncul
- **WHEN** images belum dimuat
- **THEN** placeholder muncul
- **AND** placeholder menyerupai layout images

#### Scenario: Images muncul setelah dimuat
- **WHEN** images selesai dimuat
- **THEN** images muncul di halaman
- **AND** placeholder hilang
