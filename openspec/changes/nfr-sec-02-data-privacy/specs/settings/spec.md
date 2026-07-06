## MODIFIED Requirements

### Requirement: Settings Page Structure
Sistem SHALL menyediakan halaman settings dengan tab navigation.

#### Scenario: Settings page accessed
- **WHEN** user mengakses /settings
- **THEN** sistem menampilkan halaman settings dengan tab: Profile, Notifikasi, Tampilan, Keamanan, Privasi

#### Scenario: Tab navigation
- **WHEN** user mengklik tab
- **THEN** konten tab tersebut dimuat tanpa page reload

#### Scenario: Deep link to tab
- **WHEN** user mengakses /settings?tab=privacy
- **THEN** sistem langsung menampilkan tab Privasi

## ADDED Requirements

### Requirement: Privacy Tab in Settings
Settings SHALL menyediakan tab Privasi dengan privacy preferences dan consent management.

#### Scenario: Privacy tab displayed
- **WHEN** user mengakses tab Privasi
- **THEN** sistem menampilkan toggle untuk analyticsVisibility, aiInteractionConsent, dataSharingConsent, dan link ke privacy policy

#### Scenario: Privacy preferences updated from settings
- **WHEN** user mengubah toggle privacy preference di tab Privasi
- **THEN** sistem menyimpan perubahan secara otomatis (auto-save) dan menampilkan pesan konfirmasi
