## Context

Kolabri adalah platform pembelajaran kolaboratif berbasis AI untuk pendidikan tinggi (Telkom University). Tech stack:
- **Client**: Laravel 11 + Inertia.js + React 18 + TypeScript + Tailwind CSS + Framer Motion
- **API**: Node.js + Express + Prisma + PostgreSQL
- **Auth**: JWT-based (custom implementation, bukan Laravel Breeze/Sanctum)

Halaman-halaman yang sudah ada:
- `auth/login.tsx` — form login dengan email/password, remember me, CSRF refresh
- `auth/register.tsx` — form registrasi dengan role selection (student/lecturer), password strength meter
- `welcome.tsx` — landing page dengan hero, statistik, fitur, cara kerja, FAQ, CTA
- `student/dashboard.tsx` — welcome card, quick stats (courses, groups, reflections, chat messages), recent courses
- `lecturer/dashboard.tsx` — dashboard dosen
- `admin/dashboard.tsx` — dashboard admin

**Belum ada**: forgot password flow, social login, email verification, settings page, account deletion, notification preferences, theme/language persistence.

## Goals / Non-Goals

**Goals:**
- Mendefinisikan spec untuk semua auth/shared pages agar bisa di-implement secara konsisten
- Menambahkan fitur keamanan: rate limiting, email verification, password strength validation
- Menambahkan UX improvements: forgot password, social login, theme/language preferences
- Mendefinisikan settings page untuk manajemen akun pengguna

**Non-Goals:**
- Tidak mengubah arsitektur auth yang sudah ada (tetap JWT-based)
- Tidak menambahkan fitur baru di luar auth/shared pages (misal: course management, AI chat)
- Tidak mengubah desain visual existing — hanya menambah fitur
- Tidak membuat admin panel baru

## Decisions

### 1. Forgot Password: Email-based Reset Link

**Decision**: Menggunakan email-based password reset dengan token yang expired dalam 60 menit.

**Alternatives considered**:
- SMS-based reset → Lebih mahal, memerlukan integrasi SMS gateway
- Security questions → Kurang aman, mudah di-guess
- Admin-initiated reset → Tidak scalable, user tidak bisa self-service

**Rationale**: Email-based adalah standar industri, mudah di-implement dengan Laravel's built-in Mail, dan user sudah memiliki email terdaftar.

### 2. Social Login: Google OAuth 2.0

**Decision**: Mengimplementasi Google OAuth 2.0 sebagai satu-satunya social login provider.

**Alternatives considered**:
- Multiple providers (GitHub, Microsoft) → Over-engineering untuk MVP, bisa ditambah nanti
- Firebase Auth → Vendor lock-in, menambah dependency
- Laravel Socialite → Terlalu banyak abstraction untuk single provider

**Rationale**: Sebagian besar mahasiswa Telkom University menggunakan akun Google. Google OAuth 2.0 bisa di-implement langsung dengan `googleapis` package tanpa dependency berat.

### 3. Email Verification: Required Before Access

**Decision**: User harus verify email sebelum bisa mengakses dashboard. Email verifikasi dikirim otomatis setelah registrasi.

**Alternatives considered**:
- Optional verification → Risiko akun fake, kurang aman
- Delayed verification (akses terbatas) → Menambah complexity, user bingung

**Rationale**: Untuk platform akademik, integritas data user sangat penting. Email verification memastikan user memiliki akses ke email yang terdaftar.

### 4. Dashboard Stats: API Aggregation

**Decision**: Quick stats di dashboard diambil dari single aggregated API endpoint, bukan multiple parallel requests.

**Alternatives considered**:
- Multiple parallel requests → Lebih fleksibel tapi menambah network overhead
- Client-side aggregation → Tidak real-time, data bisa stale
- WebSocket streaming → Over-engineering untuk stats yang jarang berubah

**Rationale**: Single aggregated endpoint mengurangi network round-trips, memudahkan caching, dan lebih mudah di-maintain.

### 5. Theme/Language: Client-side Storage + Server Sync

**Decision**: Theme dan language preference disimpan di localStorage (client) dan di-sync ke database saat user login.

**Alternatives considered**:
- Server-only → Memerlukan request setiap kali ganti theme, lambat
- Client-only → Tidak persist di device lain
- Cookie-based → Limited storage, security concerns

**Rationale**: Hybrid approach memberikan instant response (localStorage) dan cross-device sync (database). Sync dilakukan saat login untuk menghindari frequent API calls.

### 6. Account Deletion: Soft Delete dengan Grace Period

**Decision**: Account deletion menggunakan soft delete dengan 30 hari grace period. User bisa restore dalam periode tersebut.

**Alternatives considered**:
- Hard delete → Data hilang permanen, tidak bisa recovery, compliance issues
- No deletion → Melanggar GDPR/privacy best practices
- Immediate soft delete → Tidak ada waktu untuk recovery

**Rationale**: 30 hari grace period adalah standar industri (Google, GitHub). Memberikan waktu untuk recovery jika user berubah pikiran atau akun di-hack.

### 7. Settings Page: Single Page dengan Tabs

**Decision**: Settings page menggunakan single page dengan tab navigation (Profile, Notifications, Theme, Security).

**Alternatives considered**:
- Multiple separate pages → Menambah routing complexity, user harus navigate bolak-balik
- Single scrollable page → Terlalu panjang, overwhelming
- Modal-based → Tidak cocok untuk settings yang kompleks

**Rationale**: Tab navigation familiar untuk user, setiap tab bisa di-load lazily, dan URL bisa di-share (`/settings?tab=notifications`).

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Social login bisa di-abuse untuk spam registration | Implementasi rate limiting per IP dan per email, CAPTCHA setelah 3 failed attempts |
| Email verification bisa block legitimate user | Provide "resend verification" button, support contact untuk edge cases |
| Soft delete memerlukan storage untuk data terhapus | Implementasi cleanup job setelah 30 hari, monitoring storage usage |
| Theme sync bisa conflict jika user buka di multiple device | Last-write-wins strategy, sync hanya saat login |
| Forgot password bisa di-abuse untuk email bombing | Rate limiting per email (max 3 request per hour), CAPTCHA |

## Open Questions

1. **Social login provider expansion**: Apakah perlu menambah provider lain (GitHub, Microsoft) dalam fase berikutnya?
2. **Email service**: Menggunakan Laravel Mail dengan SMTP atau transactional email service (SendGrid, Mailgun)?
3. **Password policy**: Apakah perlu enforce password complexity yang lebih ketat (misal: harus ada special character)?
4. **Session management**: Apakah perlu menambah fitur "active sessions" di settings untuk manage device yang ter-login?
