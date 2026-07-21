## Why

Product scope (UC-inti SRS 2026-07-20) menempatkan beberapa surface sebagai **Future Works** atau non-klaim: student analytics dashboard, reflection templates/tags, AI chat bookmarks/template management pages, admin course templates, plan-vs-diskusi UI. Routes product untuk item tersebut sudah dinonaktifkan di Client App, tetapi **file controller/page/model/API residual** dan sebagian endpoint Core API masih ada. Cleanup total file/backend harus lewat OpenSpec dan dikerjakan agent lain — bukan hard-delete ad-hoc di sesi analisis SRS.

## What Changes

- Hapus / arsip dead code Client App yang tidak lagi di-route untuk: student dashboard analytics, reflection templates/tags/analytics pages, AI chat bookmarks + templates CRUD pages, saved materials, PlanVsDiskusi page/chart, admin course template library UI methods.
- Bersihkan Core API (bila ada) endpoints/models yang hanya melayani surface di atas, setelah audit dependency.
- Hapus atau skip test unit yang hanya menutupi surface tersebut; update Wayfinder/Ziggy/types yang pecah.
- **Tidak** menambah implementasi Future Works (analitik mahasiswa, notifikasi penuh, process mining UI, consent stack, dsb.).

## Capabilities

### Removed / Cleanup Capabilities
- `student-dashboard-analytics` UI surface (Future Works)
- `reflection-templates-tags` UI surface
- `ai-chat-bookmarks-templates-pages` (inline prompt di chatbox tetap boleh bila sudah ada di room)
- `admin-course-templates` library
- `plan-vs-diskusi` experimental UI

### Modified Capabilities
- `admin-master-data`: tanpa template library
- `student-reflections`: submit + history only
- `student-ai-chat`: personal chat only (no bookmark/template page)

## Impact

- `Kolabri-client-app`: delete dead controllers/pages; fix imports; optional seeder residual
- `Kolabri-core-api`: optional cleanup course-templates / bookmarks APIs after dependency check
- Tests, OpenAPI, seeders
- Docs already updated in SRS Future Works; this change is **code residual only**

## Non-Goals

- Implementasikan Future Works
- Hapus fitur dosen analytics / UC-inti
- Privacy/consent stack (sudah ada change terpisah `remove-privacy-and-consent-stack`)
