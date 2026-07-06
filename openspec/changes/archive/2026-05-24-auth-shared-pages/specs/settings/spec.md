## ADDED Requirements

### Requirement: Settings Page Structure
Sistem SHALL menyediakan halaman settings dengan tab navigation.

#### Scenario: Settings page accessed
- **WHEN** user mengakses /settings
- **THEN** sistem menampilkan halaman settings dengan tab: Profile, Notifikasi, Tampilan, Keamanan

#### Scenario: Tab navigation
- **WHEN** user mengklik tab
- **THEN** konten tab tersebut dimuat tanpa page reload

#### Scenario: Deep link to tab
- **WHEN** user mengakses /settings?tab=notifications
- **THEN** sistem langsung menampilkan tab Notifikasi

### Requirement: Profile Settings
Settings SHALL menyediakan form untuk edit profile.

#### Scenario: Profile displayed
- **WHEN** user mengakses tab Profile
- **THEN** sistem menampilkan form dengan data profile saat ini (name, email, avatar)

#### Scenario: Profile updated
- **WHEN** user mengubah nama dan menekan "Simpan"
- **THEN** sistem mengupdate profile dan menampilkan pesan "Profile berhasil diperbarui"

#### Scenario: Email change
- **WHEN** user mengubah email
- **THEN** sistem mengirim verifikasi ke email baru dan menampilkan pesan "Silakan verifikasi email baru Anda"

#### Scenario: Avatar upload
- **WHEN** user mengupload foto profile
- **THEN** sistem mengresize dan menyimpan avatar dengan ukuran maksimal 2MB

### Requirement: Notification Preferences
Settings SHALL menyediakan pengaturan preferensi notifikasi.

#### Scenario: Notification settings displayed
- **WHEN** user mengakses tab Notifikasi
- **THEN** sistem menampilkan toggle untuk setiap jenis notifikasi

#### Scenario: Email notifications toggle
- **WHEN** user menonaktifkan "Notifikasi Email"
- **THEN** sistem berhenti mengirim email notifikasi tetapi tetap menampilkan notifikasi in-app

#### Scenario: Notification types
- **WHEN** user mengakses pengaturan notifikasi
- **THEN** sistem menampilkan toggle untuk: Kursus Baru, Diskusi, Refleksi, Deadline, Pengumuman

#### Scenario: Preferences saved
- **WHEN** user mengubah preferensi dan menekan "Simpan"
- **THEN** sistem mengupdate preferensi dan menampilkan pesan "Preferensi notifikasi berhasil disimpan"

### Requirement: Theme Settings
Settings SHALL menyediakan pengaturan tema (dark/light mode).

#### Theme options displayed
- **WHEN** user mengakses tab Tampilan
- **THEN** sistem menampilkan opsi tema: Terang, Gelap, Ikuti Sistem

#### Scenario: Light mode selected
- **WHEN** user memilih "Terang"
- **THEN** sistem menerapkan light mode dan menyimpan preferensi

#### Scenario: Dark mode selected
- **WHEN** user memilih "Gelap"
- **THEN** sistem menerapkan dark mode dan menyimpan preferensi

#### Scenario: System theme selected
- **WHEN** user memilih "Ikuti Sistem"
- **THEN** sistem mendeteksi preferensi OS dan menyesuaikan tema secara otomatis

#### Scenario: Theme persisted
- **WHEN** user mengubah tema
- **THEN** preferensi tersimpan di localStorage dan database, diterapkan di semua device

### Requirement: Language Settings
Settings SHALL menyediakan pengaturan bahasa.

#### Scenario: Language options displayed
- **WHEN** user mengakses pengaturan bahasa
- **THEN** sistem menampilkan opsi: Bahasa Indonesia, English

#### Scenario: Language changed
- **WHEN** user memilih bahasa baru
- **THEN** sistem mengubah semua teks UI ke bahasa yang dipilih tanpa page reload

#### Scenario: Language persisted
- **WHEN** user mengubah bahasa
- **THEN** preferensi tersimpan di localStorage dan database

### Requirement: Security Settings
Settings SHALL menyediakan pengaturan keamanan.

#### Scenario: Change password
- **WHEN** user mengakses tab Keamanan
- **THEN** sistem menampilkan form untuk mengubah password (current password, new password, confirm password)

#### Scenario: Password changed
- **WHEN** user memasukkan password saat ini yang valid dan password baru
- **THEN** sistem mengupdate password dan menampilkan pesan "Password berhasil diubah"

#### Scenario: Invalid current password
- **WHEN** user memasukkan password saat ini yang salah
- **THEN** sistem menampilkan error "Password saat ini salah"

### Requirement: Account Deletion
Settings SHALL menyediakan opsi untuk menghapus akun.

#### Scenario: Delete account option
- **WHEN** user mengakses tab Keamanan
- **THEN** sistem menampilkan section "Hapus Akun" dengan peringatan

#### Scenario: Delete confirmation
- **WHEN** user mengklik "Hapus Akun"
- **THEN** sistem menampilkan modal konfirmasi dengan input "KETIK HAPUS" untuk konfirmasi

#### Scenario: Account deleted
- **WHEN** user mengetik "KETIK HAPUS" dan mengkonfirmasi
- **THEN** sistem melakukan soft delete, mengirim email notifikasi, dan logout user

#### Scenario: Grace period
- **WHEN** akun dihapus
- **THEN** sistem menyimpan data selama 30 hari sebelum permanent delete

#### Scenario: Account restoration
- **WHEN** user mengakses link restore dari email dalam 30 hari
- **THEN** sistem mengembalikan akun dengan semua data

### Requirement: Settings Validation
Settings SHALL memvalidasi input sebelum menyimpan.

#### Scenario: Required fields
- **WHEN** user mengosongkan field yang required
- **THEN** sistem menampilkan error "Field ini wajib diisi"

#### Scenario: Invalid email format
- **WHEN** user memasukkan email dengan format salah
- **THEN** sistem menampilkan error "Format email tidak valid"

#### Scenario: File size exceeded
- **WHEN** user mengupload file > 2MB
- **THEN** sistem menampilkan error "Ukuran file maksimal 2MB"

### Requirement: Settings Persistence
Settings SHALL menyimpan perubahan secara otomatis atau dengan tombol "Simpan".

#### Scenario: Auto-save enabled
- **WHEN** user mengubah toggle atau dropdown
- **THEN** perubahan tersimpan otomatis tanpa klik "Simpan"

#### Scenario: Manual save required
- **WHEN** user mengubah text input
- **THEN** tombol "Simpan" muncul dan user harus klik untuk menyimpan

#### Scenario: Unsaved changes warning
- **WHEN** user mencoba meninggalkan halaman dengan perubahan belum disimpan
- **THEN** sistem menampilkan konfirmasi "Anda memiliki perubahan yang belum disimpan"
