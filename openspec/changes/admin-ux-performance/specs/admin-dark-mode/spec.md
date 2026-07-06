## ADDED Requirements

### Requirement: Dark mode toggle
Sistem SHALL menyediakan dark mode toggle.

#### Scenario: Toggle muncul di header
- **WHEN** admin berada di halaman manapun
- **THEN** dark mode toggle muncul di header
- **AND** toggle bisa diklik untuk mengubah tema

#### Scenario: Dark mode aktif
- **WHEN** admin mengaktifkan dark mode
- **THEN** semua halaman admin berubah ke tema gelap
- **AND** preferensi tersimpan di localStorage

#### Scenario: Dark mode nonaktif
- **WHEN** admin menonaktifkan dark mode
- **THEN** semua halaman admin berubah ke tema terang
- **AND** preferensi tersimpan di localStorage

#### Scenario: Preferensi tersimpan
- **WHEN** admin mengakses halaman admin lagi
- **THEN** sistem membaca preferensi dari localStorage
- **AND** tema sesuai dengan preferensi yang tersimpan
