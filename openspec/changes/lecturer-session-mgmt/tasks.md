## 1. Backend - Session Scheduling

- [x] 1.1 Tambah kolom `scheduled_at` pada tabel sessions (migration)
- [x] 1.2 Buat background scheduler job untuk activate scheduled sessions
- [x] 1.3 Buat endpoint untuk schedule session
- [x] 1.4 Buat endpoint untuk cancel scheduled session

## 2. Backend - Auto-Close

- [x] 2.1 Tambah kolom `auto_close_at` dan `last_activity_at` pada sessions (migration)
- [x] 2.2 Buat background job untuk check dan close inactive sessions
- [x] 2.3 Implementasi grace period logic
- [x] 2.4 Buat notifikasi service untuk auto-close warning

## 3. Backend - Templates

- [x] 3.1 Buat tabel `session_templates` (migration)
- [x] 3.2 Buat API endpoints untuk templates CRUD
- [x] 3.3 Implementasi template apply logic

## 4. Backend - Bulk Operations

- [x] 4.1 Buat endpoint bulk close sessions
- [x] 4.2 Buat endpoint bulk archive sessions
- [x] 4.3 Buat endpoint bulk delete sessions
- [x] 4.4 Implementasi queue processing untuk bulk ops

## 5. Frontend - Page Structure

- [x] 5.1 Buat halaman `lecturer/session-mgmt/index.tsx`
- [x] 5.2 Buat tab navigation (Active, Scheduled, Templates)
- [x] 5.3 Implementasi layout dan routing

## 6. Frontend - Scheduled Sessions

- [x] 6.1 Buat komponen `ScheduledSessionsList`
- [x] 6.2 Buat komponen `ScheduleSessionForm` dengan datetime picker
- [x] 6.3 Buat komponen `CancelScheduleDialog`

## 7. Frontend - Auto-Close

- [x] 7.1 Buat komponen `AutoCloseConfig` (timeout selector)
- [x] 7.2 Tambah warning indicator pada sessions yang akan auto-close
- [x] 7.3 Implementasi grace period countdown display

## 8. Frontend - Templates

- [x] 8.1 Buat komponen `TemplatesList`
- [x] 8.2 Buat komponen `TemplateEditor` (create/edit)
- [x] 8.3 Buat komponen `TemplateSelector` pada session creation form
- [x] 8.4 Implementasi template preview

## 9. Frontend - Bulk Operations

- [x] 9.1 Tambah selection mode dengan checkbox pada session list
- [x] 9.2 Buat komponen `BulkActionBar`
- [x] 9.3 Implementasi bulk close dengan konfirmasi
- [x] 9.4 Implementasi bulk archive dan delete
- [x] 9.5 Tambah select all / deselect all
