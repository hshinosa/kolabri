## ADDED Requirements

### Requirement: Notification center dengan history
Sistem SHALL menyediakan notification center dengan history.

#### Scenario: Bell icon muncul di header
- **WHEN** admin berada di halaman manapun
- **THEN** bell icon muncul di header
- **AND** bell icon menampilkan jumlah unread notifications

#### Scenario: Notification dropdown
- **WHEN** admin mengklik bell icon
- **THEN** dropdown muncul dengan daftar notifications
- **AND** notifications diurutkan dari yang terbaru

#### Scenario: Mark as read
- **WHEN** admin mengklik notification
- **THEN** notification ditandai sebagai read
- **AND** jumlah unread notifications berkurang

#### Scenario: Mark all as read
- **WHEN** admin mengklik "Mark all as read"
- **THEN** semua notifications ditandai sebagai read
- **AND** jumlah unread notifications menjadi 0

#### Scenario: Notification history
- **WHEN** admin membuka notification center
- **THEN** sistem menampilkan notification history
- **AND** history tersimpan di localStorage
