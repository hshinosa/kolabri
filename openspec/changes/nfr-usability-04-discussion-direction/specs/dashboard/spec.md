## ADDED Requirements

### Requirement: Discussion Health Widget
Dashboard SHALL menampilkan discussion health widget yang menampilkan daftar chat spaces aktif beserta health score masing-masing.

#### Scenario: Lecturer sees health widget
- **WHEN** lecturer mengakses dashboard dan memiliki chat spaces aktif dengan learning goal
- **THEN** sistem menampilkan widget "Kesehatan Diskusi" berisi daftar chat spaces dengan health score (0-100) dan color indicator (green/yellow/red)

#### Scenario: No active discussions
- **WHEN** lecturer mengakses dashboard dan tidak ada chat spaces aktif dengan learning goal
- **THEN** widget "Kesehatan Diskusi" menampilkan pesan "Tidak ada diskusi aktif"

#### Scenario: Health widget clickable
- **WHEN** lecturer mengklik item di health widget
- **THEN** sistem mengarahkan ke chat space terkait

#### Scenario: Health score updates
- **WHEN** health score berubah di salah satu chat space
- **THEN** widget update secara real-time tanpa refresh halaman
