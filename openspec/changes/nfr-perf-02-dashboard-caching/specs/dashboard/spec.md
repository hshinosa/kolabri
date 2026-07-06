## MODIFIED Requirements

### Requirement: Dashboard Performance
Dashboard SHALL dimuat dengan cepat dan responsive, menggunakan server-side caching dan query optimization.

#### Scenario: Fast load
- **WHEN** user mengakses dashboard
- **THEN** halaman fully loaded dalam < 2 detik

#### Scenario: Cached response
- **WHEN** dashboard API menerima request berulang dalam TTL window
- **THEN** response served dari cache tanpa database query execution

#### Scenario: Skeleton loading
- **WHEN** data sedang dimuat
- **THEN** sistem menampilkan skeleton placeholder yang smooth

#### Scenario: Error state
- **WHEN** API request gagal
- **THEN** sistem menampilkan error state dengan tombol "Coba Lagi"
