## Context

Kolabri menggunakan arsitektur BFF (Backend for Frontend):
- **Laravel** (port 8000): serving frontend + proxy ke Core API
- **Core API** (port 3000): Express/Node.js API + Socket.io server
- **Frontend**: React via Inertia.js, socket.io-client untuk real-time

Auth flow saat ini:
1. User login → Core API return accessToken (15m) + refreshToken (7d)
2. Laravel store kedua token di session
3. Frontend GET `/api/auth/token` → ambil accessToken dari session
4. Socket.io pakai accessToken untuk connect

**Masalah**: Tidak ada auto-refresh. Access token expired setelah 15 menit → user forced logout atau chat room mati.

**Constraint**: Core API sudah punya endpoint `/api/auth/refresh` yang berfungsi. Redis sudah jalan untuk token revocation.

## Goals / Non-Goals

**Goals:**
- User tidak perlu login ulang hanya karena idle > 15 menit
- Chat room tetap bisa reconnect setelah token expired
- Refresh terjadi tanpa diketahui user (seamless)
- Semua perubahan di Laravel layer — Core API tidak diubah

**Non-Goals:**
- Refresh token rotation (nice to have, tapi bukan sekarang)
- Custom token expiry configuration
- Perubahan di Core API
- WebSocket transport fix (masalah terpisah)

## Decisions

### 1. Server-side refresh via Laravel middleware

**Pilihan**: Auto-refresh dilakukan di Laravel middleware, bukan di frontend.

**Alternatif yang ditolak**:
- Frontend-triggered refresh → lebih kompleks, harus handle race condition antar tabs
- Background interval refresh → boros, tidak event-driven

**Alasan**: Laravel sudah jadi BFF, punya akses ke refresh token di session, dan bisa intercept 401 response dari Core API. Ini pattern yang umum untuk BFF architecture.

### 2. TokenRefreshMiddleware (new) + modifikasi JwtAuthMiddleware

**Pilihan**: Buat middleware baru `TokenRefreshMiddleware` yang handle auto-retry, dan modifikasi `JwtAuthMiddleware` agar tidak langsung hapus session saat expired.

**Alasan**:
- `JwtAuthMiddleware` sekarang membersihkan session saat token expired → ini terlalu agresif
- `TokenRefreshMiddleware` bisa intercept 401 dari Core API dan refresh dulu
- Pemisahan concern: JwtAuth = validasi, TokenRefresh = recovery

### 3. Explicit refresh endpoint untuk frontend

**Pilihan**: Tambah route `GET /api/auth/refresh-token` yang trigger refresh dan return token baru.

**Alasan**: Socket.io hook perlu minta refresh secara explicit sebelum reconnect. Tidak bisa mengandalkan middleware karena socket connection tidak melewati Laravel HTTP layer.

### 4. Socket hook: refresh-before-reconnect

**Pilihan**: Pada `connect_error` auth, minta Laravel refresh dulu, baru reconnect.

**Alternatif yang ditolak**:
- Reconnect langsung dengan token lama → token tetap expired
- Polling token baru → boros, tidak realistis

**Alasan**: Socket.io connect langsung ke Core API (bukan lewat Laravel), jadi harus pastikan token di session sudah fresh sebelum reconnect.

## Risks / Trade-offs

- **Race condition**: Multiple concurrent requests saat token expired bisa trigger multiple refresh → mitigasi: gunakan mutex/lock di Laravel
- **Refresh token expired**: Kalau user idle > 7 hari, refresh gagal → user harus login ulang (ini acceptable)
- **Session inconsistency**: Kalau refresh berhasil tapi session write gagal → mitigasi: refresh token baru langsung di-save ke session
- **Performance**: Extra request ke Core API saat refresh → mitigasi: refresh hanya trigger saat 401, jarang terjadi
