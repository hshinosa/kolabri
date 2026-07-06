## Why

Kolabri menggunakan arsitektur BFF (Laravel → Core API) dengan JWT access token (15 menit) dan refresh token (7 hari). Saat ini **tidak ada mekanisme auto-refresh** — begitu access token expired, user langsung logout atau chat room mati. Untuk production, user tidak boleh terganggu hanya karena token expired setelah 15 menit idle.

## What Changes

- **Tambah `TokenRefreshMiddleware`** di Laravel yang otomatis retry request ke Core API kalau dapat 401, dengan cara refresh token dulu lalu retry
- **Tambah `/api/auth/refresh-token` endpoint** di Laravel yang trigger refresh ke Core API dan update session
- **Update `getAuthToken()`** di frontend untuk handle 401 dari Laravel (session expired total) gracefully
- **Update socket hook `useSocketRoom`** agar minta Laravel refresh token sebelum reconnect, bukan cuma re-fetch token yang sama
- **Update `JwtAuthMiddleware`** agar tidak langsung hapus session saat token expired — biarkan `TokenRefreshMiddleware` yang handle

## Capabilities

### New Capabilities
- `jwt-auto-refresh-http`: Auto-refresh JWT access token di HTTP layer Laravel saat Core API return 401
- `jwt-auto-refresh-socket`: Auto-refresh JWT untuk koneksi Socket.io dengan mekanisme reconnect yang benar

### Modified Capabilities

_(none — ini capability baru)_

## Impact

- **Laravel Backend**: Tambah middleware baru, tambah route endpoint, modifikasi JwtAuthMiddleware
- **Frontend JS**: Modifikasi `getAuthToken.ts` dan `useSocketRoom.ts`
- **Core API**: Tidak ada perubahan — endpoint `/api/auth/refresh` sudah ada
- **Dependencies**: Tidak ada dependency baru
- **Breaking changes**: Tidak ada — semua perubahan additive
