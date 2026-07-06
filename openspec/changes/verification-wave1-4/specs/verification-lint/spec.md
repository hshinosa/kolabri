## ADDED Requirements

### Requirement: TypeScript lint check
Sistem SHALL memverifikasi semua file TypeScript tidak ada lint errors.

#### Scenario: All TypeScript files pass lint
- **WHEN** menjalankan `npx tsc --noEmit` pada project
- **THEN** tidak ada TypeScript errors yang dilaporkan
- **AND** exit code 0

#### Scenario: TypeScript errors detected
- **WHEN** ada TypeScript errors ditemukan
- **THEN** sistem SHALL menampilkan daftar errors dengan file path dan line number
- **AND** exit code non-zero

### Requirement: PHP syntax check
Sistem SHALL memverifikasi semua file PHP tidak ada syntax errors.

#### Scenario: All PHP files pass syntax check
- **WHEN** menjalankan `php -l` pada setiap file PHP yang diubah
- **THEN** tidak ada syntax errors yang dilaporkan
- **AND** exit code 0

#### Scenario: PHP syntax errors detected
- **WHEN** ada PHP syntax errors ditemukan
- **THEN** sistem SHALL menampilkan daftar errors dengan file path dan line number
- **AND** exit code non-zero

### Requirement: LSP diagnostics clean
Sistem SHALL memverifikasi LSP diagnostics tidak ada errors pada file yang diubah.

#### Scenario: All changed files have clean diagnostics
- **WHEN** menjalankan LSP diagnostics pada file yang diubah
- **THEN** tidak ada error-level diagnostics
- **AND** warnings boleh ada tapi harus didokumentasikan
