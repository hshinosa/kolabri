## ADDED Requirements

### Requirement: Login Form
Sistem SHALL menampilkan form login dengan field email dan password. Form MUST memiliki validasi client-side dan server-side.

#### Scenario: Successful login
- **WHEN** user memasukkan email dan password yang valid
- **THEN** sistem mengarahkan user ke dashboard sesuai role (student/lecturer/admin)

#### Scenario: Invalid credentials
- **WHEN** user memasukkan email atau password yang salah
- **THEN** sistem menampilkan pesan error "Email atau password salah" tanpa mengungkap field mana yang salah

#### Scenario: Empty fields
- **WHEN** user mengirim form dengan email atau password kosong
- **THEN** sistem menampilkan pesan validasi "Email tidak boleh kosong" atau "Password tidak boleh kosong"

### Requirement: Remember Me
Sistem SHALL menyediakan opsi "Ingat saya" di form login. Jika dicentang, session MUST persist selama 30 hari.

#### Scenario: Remember me checked
- **WHEN** user login dengan checkbox "Ingat saya" dicentang
- **THEN** sistem menyimpan persistent token yang valid selama 30 hari

#### Scenario: Remember me unchecked
- **WHEN** user login tanpa mencentang "Ingat saya"
- **THEN** session berakhir saat browser ditutup (session cookie)

#### Scenario: Remember me token expired
- **WHEN** persistent token sudah lebih dari 30 hari
- **THEN** sistem mengarahkan user ke halaman login dengan pesan "Session Anda telah berakhir"

### Requirement: Forgot Password
Sistem SHALL menyediakan link "Lupa password?" yang mengarahkan ke halaman reset password.

#### Scenario: Request password reset
- **WHEN** user memasukkan email terdaftar di halaman lupa password
- **THEN** sistem mengirim email dengan link reset password yang valid selama 60 menit

#### Scenario: Invalid email for reset
- **WHEN** user memasukkan email yang tidak terdaftar
- **THEN** sistem tetap menampilkan pesan "Jika email terdaftar, Anda akan menerima link reset" (tidak mengungkap apakah email terdaftar)

#### Scenario: Reset link clicked
- **WHEN** user mengklik link reset password dari email
- **THEN** sistem menampilkan form untuk memasukkan password baru dengan konfirmasi

#### Scenario: Reset link expired
- **WHEN** user mengklik link reset password yang sudah expired (>60 menit)
- **THEN** sistem menampilkan pesan "Link reset password sudah tidak berlaku" dan opsi untuk request baru

#### Scenario: Password reset successful
- **WHEN** user memasukkan password baru yang valid dan mengkonfirmasi
- **THEN** sistem mengupdate password, menginvalidasi semua session existing, dan mengarahkan ke login

### Requirement: Social Login - Google
Sistem SHALL menyediakan opsi login dengan Google OAuth 2.0.

#### Scenario: First-time Google login
- **WHEN** user mengklik "Masuk dengan Google" dan belum memiliki akun
- **THEN** sistem membuat akun baru dengan data dari Google (name, email, avatar) dan mengarahkan ke dashboard

#### Scenario: Existing user Google login
- **WHEN** user mengklik "Masuk dengan Google" dan sudah memiliki akun dengan email yang sama
- **THEN** sistem mengaitkan akun Google dan mengarahkan ke dashboard

#### Scenario: Google login failed
- **WHEN** proses OAuth Google gagal (user cancel atau error)
- **THEN** sistem mengarahkan kembali ke halaman login dengan pesan "Login dengan Google dibatalkan"

### Requirement: Rate Limiting
Sistem SHALL membatasi percobaan login untuk mencegah brute force attack.

#### Scenario: Rate limit exceeded
- **WHEN** user gagal login 5 kali dalam 5 menit dari IP yang sama
- **THEN** sistem memblokir percobaan login dari IP tersebut selama 15 menit dengan pesan "Terlalu banyak percobaan. Coba lagi dalam 15 menit."

#### Scenario: Rate limit per email
- **WHEN** satu email gagal login 10 kali dalam 1 jam
- **THEN** sistem memblokir percobaan login untuk email tersebut selama 1 jam

#### Scenario: Rate limit reset
- **WHEN** user berhasil login setelah rate limit
- **THEN** sistem mereset counter percobaan gagal untuk IP dan email tersebut

### Requirement: Login Error Handling
Sistem SHALL menangani error dengan graceful dan memberikan feedback yang jelas.

#### Scenario: Network error
- **WHEN** request login gagal karena network error
- **THEN** sistem menampilkan pesan "Koneksi bermasalah. Silakan coba lagi."

#### Scenario: Server error
- **WHEN** request login gagal karena server error (5xx)
- **THEN** sistem menampilkan pesan "Terjadi kesalahan. Silakan coba beberapa saat lagi."

#### Scenario: CSRF token expired
- **WHEN** CSRF token expired saat form disubmit
- **THEN** sistem secara otomatis me-refresh CSRF token dan me-retry request
