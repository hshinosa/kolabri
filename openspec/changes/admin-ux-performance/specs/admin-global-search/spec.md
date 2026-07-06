## ADDED Requirements

### Requirement: Global search untuk users, courses, settings
Sistem SHALL menyediakan global search yang bisa mencari users, courses, dan settings secara bersamaan.

#### Scenario: Search bar muncul di header
- **WHEN** admin berada di halaman manapun
- **THEN** search bar muncul di header
- **AND** search bar bisa diklik untuk mulai search

#### Scenario: Search users
- **WHEN** admin mengetik nama user di search bar
- **THEN** sistem menampilkan hasil search users
- **AND** hasil search bisa diklik untuk navigasi ke user detail

#### Scenario: Search courses
- **WHEN** admin mengetik nama course di search bar
- **THEN** sistem menampilkan hasil search courses
- **AND** hasil search bisa diklik untuk navigasi ke course detail

#### Scenario: Search settings
- **WHEN** admin mengetik nama setting di search bar
- **THEN** sistem menampilkan hasil search settings
- **AND** hasil search bisa diklik untuk navigasi ke setting page

#### Scenario: Debouncing
- **WHEN** admin mengetik di search bar
- **THEN** sistem menunggu 300ms sebelum melakukan search
- **AND** tidak ada API call yang berlebihan
