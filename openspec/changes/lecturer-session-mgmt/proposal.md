## Why
Dosen memerlukan tools untuk mengelola chat/collaboration sessions secara efisien. Saat ini tidak ada fitur untuk menjadwalkan sessions, auto-close inactive sessions, menggunakan template, atau operasi bulk.

## What Changes
- Scheduled sessions dengan auto-activate
- Auto-close inactive sessions setelah timeout configurable
- Session templates untuk konsistensi konfigurasi
- Bulk operations (close, archive, delete beberapa session sekaligus)

## Capabilities
### New Capabilities
- `session-scheduling`
- `session-auto-close`
- `session-templates`
- `session-bulk-ops`

## Impact
- **Frontend**: Halaman baru `lecturer/session-mgmt` dengan tabs: Active, Scheduled, Templates
- **Backend/API**: Endpoint untuk scheduling, auto-close service, templates CRUD, bulk operations
- **Data**: Tabel `session_templates`, kolom `scheduled_at` dan `auto_close_at` pada sessions
- **Breaking changes**: Tidak ada
