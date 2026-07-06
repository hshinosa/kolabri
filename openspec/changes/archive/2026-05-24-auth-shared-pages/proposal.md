## Why

Kolabri sudah memiliki halaman auth (login, register), welcome/landing, dashboard (per role), dan struktur dasar settings. Namun, halaman-halaman ini belum memiliki spesifikasi formal yang mendefinisikan fitur-fitur expected seperti "remember me", forgot password, social login, email verification, rate limiting, testimonials, notifications, theme switching, dan account deletion. Tanpa spec, implementasi menjadi inkonsisten dan sulit di-verify. Perubahan ini mendokumentasikan semua expected behavior untuk auth/shared pages agar bisa di-implement dan di-test secara sistematis.

## What Changes

- Menambahkan spec-level requirements untuk 5 halaman shared/auth: login, register, welcome, dashboard, settings
- Mendefinisikan fitur-fitur yang belum ada: forgot password flow, social login, email verification, password strength meter, terms checkbox, rate limiting, feature showcase, testimonials, quick stats, notifications, theme/language preferences, account deletion
- Tidak mengubah kode existing — ini adalah spec-only change

## Capabilities

### New Capabilities

- `login`: Autentikasi pengguna — login form, remember me, forgot password, social login (Google), rate limiting, error handling
- `register`: Registrasi pengguna — form registrasi, email verification, password strength, terms & conditions checkbox, role selection
- `welcome`: Landing page publik — hero section, feature showcase, cara kerja, demo preview, testimonials, CTA, FAQ, dark mode toggle
- `dashboard`: Dasbor per-role (student/lecturer/admin) — quick stats, recent activity, notifications bell, quick actions, progress tracking
- `settings`: Pengaturan akun — notification preferences, theme (dark/light), bahasa, profile edit, account deletion dengan konfirmasi

### Modified Capabilities

_(Tidak ada existing specs yang perlu dimodifikasi — ini adalah initial spec creation)_

## Impact

- **Client App** (`Kolabri-client-app/resources/js/pages/`): Semua halaman auth/*, welcome.tsx, */dashboard.tsx, dan halaman settings yang akan dibuat
- **Routes** (`Kolabri-client-app/routes/web.php`): Penambahan route untuk forgot password, email verification, settings, account deletion
- **Core API** (`Kolabri-core-api/src/routes/auth.routes.ts`): Endpoint tambahan untuk forgot password, email verification, social login callback
- **Database**: Tabel users mungkin perlu kolom tambahan (email_verified_at, theme_preference, language_preference)
- **Dependencies**: Social login memerlukan OAuth package (Laravel Socialite atau equivalent)
