## ADDED Requirements

### Requirement: Role-based Dashboard
Sistem SHALL menampilkan dashboard yang berbeda berdasarkan role user (student, lecturer, admin).

#### Scenario: Student dashboard
- **WHEN** user dengan role "student" mengakses /dashboard
- **THEN** sistem menampilkan dashboard mahasiswa dengan quick stats, recent courses, dan quick actions

#### Scenario: Lecturer dashboard
- **WHEN** user dengan role "lecturer" mengakses /dashboard
- **THEN** sistem menampilkan dashboard dosen dengan analytics overview, recent groups, dan quick actions

#### Scenario: Admin dashboard
- **WHEN** user dengan role "admin" mengakses /dashboard
- **THEN** sistem menampilkan dashboard admin dengan system stats, user management overview, dan audit log preview

### Requirement: Quick Statistics
Dashboard SHALL menampilkan statistik ringkas yang relevan dengan role user.

#### Scenario: Student stats displayed
- **WHEN** student mengakses dashboard
- **THEN** sistem menampilkan: jumlah kursus aktif, jumlah grup, jumlah refleksi, dan jumlah pesan chat

#### Scenario: Lecturer stats displayed
- **WHEN** lecturer mengakses dashboard
- **THEN** sistem menampilkan: jumlah kursus, jumlah mahasiswa, aktivitas minggu ini, dan completion rate

#### Scenario: Admin stats displayed
- **WHEN** admin mengakses dashboard
- **THEN** sistem menampilkan: total users, active sessions, system uptime, dan pending approvals

#### Scenario: Stats loaded
- **WHEN** dashboard dimuat
- **THEN** statistik diambil dari single aggregated API endpoint dengan caching

### Requirement: Recent Activity
Dashboard SHALL menampilkan aktivitas terbaru.

#### Scenario: Student recent activity
- **WHEN** student mengakses dashboard
- **THEN** sistem menampilkan: kursus terakhir diakses, refleksi terbaru, dan chat terakhir

#### Scenario: Lecturer recent activity
- **WHEN** lecturer mengakses dashboard
- **THEN** sistem menampilkan: submission terbaru, diskusi aktif, dan grup yang perlu perhatian

#### Scenario: Activity clickable
- **WHEN** user mengklik item aktivitas
- **THEN** sistem mengarahkan ke halaman terkait dengan context yang sesuai

### Requirement: Notifications Bell
Dashboard SHALL menampilkan bell notifikasi dengan badge count.

#### Scenario: Notifications displayed
- **WHEN** user memiliki notifikasi baru
- **THEN** bell icon menampilkan badge dengan jumlah notifikasi yang belum dibaca

#### Scenario: Notifications dropdown
- **WHEN** user mengklik bell icon
- **THEN** sistem menampilkan dropdown dengan daftar notifikasi terbaru (max 10)

#### Scenario: Notification clicked
- **WHEN** user mengklik notifikasi
- **THEN** sistem mengarahkan ke halaman terkait dan menandai notifikasi sebagai sudah dibaca

#### Scenario: Mark all read
- **WHEN** user mengklik "Tandai semua sudah dibaca"
- **THEN** semua notifikasi ditandai sudah dibaca dan badge count hilang

### Requirement: Quick Actions
Dashboard SHALL menampilkan shortcut ke aksi yang sering dilakukan.

#### Scenario: Student quick actions
- **WHEN** student mengakses dashboard
- **THEN** sistem menampilkan: "Mulai Diskusi", "Buat Refleksi", "Lihat Kursus", dan "Chat AI"

#### Scenario: Lecturer quick actions
- **WHEN** lecturer mengakses dashboard
- **THEN** sistem menampilkan: "Buat Kursus", "Lihat Analytics", "Kelola Grup", dan "Review Refleksi"

#### Scenario: Admin quick actions
- **WHEN** admin mengakses dashboard
- **THEN** sistem menampilkan: "Kelola User", "Lihat Audit Log", "Pengaturan AI", dan "Master Data"

#### Scenario: Quick action clicked
- **WHEN** user mengklik quick action
- **THEN** sistem mengarahkan ke halaman terkait

### Requirement: Progress Tracking
Dashboard SHALL menampilkan progres belajar atau pengajaran.

#### Scenario: Student progress
- **WHEN** student mengakses dashboard
- **THEN** sistem menampilkan progress bar untuk setiap kursus aktif dengan persentase completion

#### Scenario: Lecturer progress
- **WHEN** lecturer mengakses dashboard
- **THEN** sistem menampilkan overview aktivitas mahasiswa dalam minggu ini

#### Scenario: Progress updated
- **WHEN** ada aktivitas baru (submission, diskusi, refleksi)
- **THEN** progress bar update secara real-time

### Requirement: Welcome Card
Dashboard SHALL menampilkan welcome card dengan greeting personal.

#### Scenario: Personalized greeting
- **WHEN** user mengakses dashboard
- **THEN** sistem menampilkan "Selamat datang kembali, {nama}!" dengan emoji dan subtitle yang relevan

#### Scenario: Time-based greeting
- **WHEN** user mengakses dashboard di waktu yang berbeda
- **THEN** greeting menyesuaikan waktu: "Selamat pagi", "Selamat siang", "Selamat malam"

### Requirement: Dashboard Performance
Dashboard SHALL dimuat dengan cepat dan responsive.

#### Scenario: Fast load
- **WHEN** user mengakses dashboard
- **THEN** halaman fully loaded dalam < 2 detik

#### Scenario: Skeleton loading
- **WHEN** data sedang dimuat
- **THEN** sistem menampilkan skeleton placeholder yang smooth

#### Scenario: Error state
- **WHEN** API request gagal
- **THEN** sistem menampilkan error state dengan tombol "Coba Lagi"
