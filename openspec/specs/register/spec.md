# register Specification

## Purpose
TBD - created by archiving change auth-shared-pages. Update Purpose after archive.
## Requirements
### Requirement: Registration Form
Sistem SHALL menampilkan form registrasi dengan field name, email, password, password confirmation, dan role selection.

#### Scenario: Successful registration
- **WHEN** user mengisi semua field dengan valid dan menekan "Buat Akun"
- **THEN** sistem membuat akun baru, mengirim email verifikasi, dan menampilkan pesan "Akun berhasil dibuat! Silakan cek email Anda untuk verifikasi"

#### Scenario: Duplicate email
- **WHEN** user mendaftar dengan email yang sudah terdaftar
- **THEN** sistem menampilkan pesan "Email sudah terdaftar. Silakan login atau gunakan email lain"

#### Scenario: Password mismatch
- **WHEN** password dan password confirmation tidak cocok
- **THEN** sistem menampilkan pesan "Password tidak cocok"

### Requirement: Role Selection
Sistem SHALL menyediakan opsi role selection antara "Mahasiswa" dan "Dosen" saat registrasi.

#### Scenario: Student registration
- **WHEN** user memilih role "Mahasiswa"
- **THEN** sistem membuat akun dengan role "student" dan mengarahkan ke student dashboard setelah verifikasi

#### Scenario: Lecturer registration
- **WHEN** user memilih role "Dosen"
- **THEN** sistem membuat akun dengan role "lecturer" dan mengarahkan ke lecturer dashboard setelah verifikasi

#### Scenario: Default role
- **WHEN** user tidak memilih role
- **THEN** sistem menggunakan role default "student"

### Requirement: Email Verification
Sistem SHALL mengirim email verifikasi setelah registrasi. User MUST verify email sebelum bisa mengakses dashboard.

#### Scenario: Verification email sent
- **WHEN** registrasi berhasil
- **THEN** sistem mengirim email dengan link verifikasi yang valid selama 24 jam

#### Scenario: Verification link clicked
- **WHEN** user mengklik link verifikasi dari email
- **THEN** sistem mengupdate status email_verified dan mengarahkan ke login dengan pesan "Email berhasil diverifikasi! Silakan login"

#### Scenario: Verification link expired
- **WHEN** user mengklik link verifikasi yang sudah expired (>24 jam)
- **THEN** sistem menampilkan pesan "Link verifikasi sudah tidak berlaku" dan opsi untuk resend

#### Scenario: Resend verification
- **WHEN** user mengklik "Kirim ulang verifikasi" di halaman login
- **THEN** sistem mengirim ulang email verifikasi dengan token baru

#### Scenario: Unverified user login attempt
- **WHEN** user mencoba login dengan email yang belum diverifikasi
- **THEN** sistem menampilkan pesan "Silakan verifikasi email Anda terlebih dahulu" dengan link resend

### Requirement: Password Strength
Sistem SHALL menampilkan password strength meter dan memvalidasi kekuatan password.

#### Scenario: Weak password
- **WHEN** user memasukkan password kurang dari 8 karakter
- **THEN** sistem menampilkan strength meter merah dengan pesan "Password terlalu pendek (minimal 8 karakter)"

#### Scenario: Medium password
- **WHEN** user memasukkan password 8+ karakter tapi hanya huruf atau angka saja
- **THEN** sistem menampilkan strength meter kuning dengan pesan "Tambahkan angka atau simbol untuk password lebih kuat"

#### Scenario: Strong password
- **WHEN** user memasukkan password dengan kombinasi huruf, angka, dan simbol
- **THEN** sistem menampilkan strength meter hijau dengan pesan "Password kuat"

#### Scenario: Password requirements not met
- **WHEN** user mengirim form dengan password yang tidak memenuhi requirement
- **THEN** sistem menampilkan error "Password harus minimal 8 karakter"

### Requirement: Terms and Conditions
Sistem SHALL menampilkan checkbox persetujuan syarat dan ketentuan yang MUST dicentang sebelum registrasi.

#### Scenario: Terms not accepted
- **WHEN** user mengirim form tanpa mencentang checkbox syarat dan ketentuan
- **THEN** sistem menampilkan error "Anda harus menyetujui syarat dan ketentuan"

#### Scenario: Terms link
- **WHEN** user mengklik link "Syarat dan Ketentuan"
- **THEN** sistem membuka halaman syarat dan ketentuan di tab baru

#### Scenario: Terms accepted
- **WHEN** user mencentang checkbox syarat dan ketentuan
- **THEN** checkbox berubah menjadi checked dan error hilang

### Requirement: Registration Rate Limiting
Sistem SHALL membatasi percobaan registrasi untuk mencegah spam.

#### Scenario: Rate limit exceeded
- **WHEN** ada 5 percobaan registrasi dari IP yang sama dalam 1 jam
- **THEN** sistem memblokir registrasi dari IP tersebut selama 1 jam dengan pesan "Terlalu banyak percobaan registrasi"

#### Scenario: Rate limit per email
- **WHEN** ada 3 percobaan registrasi dengan email yang sama dalam 24 jam
- **THEN** sistem memblokir registrasi untuk email tersebut selama 24 jam
