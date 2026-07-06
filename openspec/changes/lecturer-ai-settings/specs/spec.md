## ADDED Requirements

### Requirement: AI Preview & Test
Dosen SHALL dapat preview dan test AI responses sebelum mengaktifkan untuk mahasiswa.

#### Scenario: Test AI prompt
- **WHEN** Dosen mengetik prompt di preview editor
- **THEN** Sistem menjalankan AI dengan prompt tersebut
- **AND** Response ditampilkan dalam sandbox view

#### Scenario: Preview dengan context
- **WHEN** Dosen memilih course context untuk preview
- **THEN** AI menggunakan context kursus tersebut dalam response
- **AND** Preview menunjukkan response yang relevan dengan kursus

### Requirement: Presets Management
Dosen SHALL dapat menyimpan, memuat, dan berbagi prompt presets.

#### Scenario: Menyimpan preset
- **WHEN** Dosen klik "Save as Preset" dengan prompt dan settings
- **THEN** Sistem menyimpan preset dengan nama yang diberikan
- **AND** Preset muncul di daftar presets

#### Scenario: Memuat preset
- **WHEN** Dosen memilih preset dari daftar
- **THEN** Prompt dan settings di-load ke editor
- **AND** Dosen dapat mengubah sebelum menggunakan

#### Scenario: Berbagi preset
- **WHEN** Dosen klik "Share" pada preset
- **THEN** Preset tersedia untuk dosen lain di departemen yang sama
- **AND** Preset shared muncul dengan label "Shared"

### Requirement: AI Interaction History
Dosen SHALL dapat melihat history interaksi AI dengan filter berdasarkan course, student, dan date.

#### Scenario: Melihat history
- **WHEN** Dosen membuka tab History
- **THEN** Sistem menampilkan daftar interaksi AI terbaru
- **AND** Setiap entry menunjukkan timestamp, prompt, response, dan context

#### Scenario: Filter history
- **WHEN** Dosen memfilter berdasarkan course "Pemrograman Web"
- **THEN** Hanya interaksi terkait kursus tersebut yang ditampilkan
- **AND** Filter dapat dikombinasikan dengan date range

### Requirement: A/B Testing
Dosen SHALL dapat membuat dan mengelola A/B test untuk membandingkan prompt variants.

#### Scenario: Membuat A/B test
- **WHEN** Dosen membuat test dengan variant A dan variant B
- **THEN** Sistem menyimpan kedua variant
- **AND** Test siap untuk di-assign ke mahasiswa

#### Scenario: Melihat hasil A/B test
- **WHEN** Dosen membuka hasil A/B test
- **THEN** Sistem menampilkan metrics per variant (engagement, completion)
- **AND** Statistik signifikansi ditampilkan

#### Scenario: Mengakhiri A/B test
- **WHEN** Dosen mengakhiri A/B test
- **THEN** Winning variant di-highlight
- **AND** Dosen dapat apply winning variant sebagai default
