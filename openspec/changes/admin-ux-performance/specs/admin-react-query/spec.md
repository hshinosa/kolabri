## ADDED Requirements

### Requirement: React Query untuk data caching
Sistem SHALL menggunakan React Query untuk data caching.

#### Scenario: Data di-cache
- **WHEN** admin mengakses data yang sama
- **THEN** sistem menggunakan data dari cache
- **AND** tidak ada API call yang berlebihan

#### Scenario: Cache invalidation
- **WHEN** data berubah
- **THEN** sistem menginvalidate cache
- **AND** data di-refresh dari server

#### Scenario: Background refetch
- **WHEN** admin tidak aktif
- **THEN** sistem melakukan background refetch
- **AND** data selalu up-to-date

#### Scenario: Optimistic updates
- **WHEN** admin mengubah data
- **THEN** sistem menampilkan perubahan sebelum server merespons
- **AND** perbalkan jika server gagal
