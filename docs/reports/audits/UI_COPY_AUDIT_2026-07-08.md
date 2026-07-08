# UI Copy Audit — 2026-07-08

## Scope
- Lecturer area audit summary
- Student area audit summary
- Admin area audit summary
- Cross-role consistency recommendations

## Lecturer Summary

### Main findings
- Lecturer pages still mix formal Indonesian with English product terms such as `Analytics`, `Refresh`, `Live`, `Offline`, and `breakdown`.
- Several labels are too technical or system-oriented for lecturers, especially around analytics and AI settings.
- `grup` / `kelompok` and `siswa` / `mahasiswa` are inconsistent across lecturer-facing pages.

### High-priority lecturer copy issues
- `Analytics` should be localized to `Analitik`.
- `Orkestrasi Grup Mahasiswa` is too sophisticated; use `Kelola Kelompok Mahasiswa`.
- `grup siswa` should become `kelompok mahasiswa`.
- Analytics labels such as `Engagement`, `Completion Rate`, `Refresh`, `Live`, and `Offline` should use Indonesian equivalents.

## Student Summary

### Main findings
- Student core pages are mostly understandable, but still contain mixed terminology and several untranslated interface terms.
- `grup` / `kelompok` is inconsistent across course, group, and goal flows.
- English or semi-technical terms still appear in student-facing paths, especially chat, pre-read, and image controls.

### High-priority student copy issues
- `Pre-read` in page titles should use Indonesian wording.
- `grup` labels should be standardized with `kelompok` in student-facing UI.
- Image controls such as `Zoom in`, `Zoom out`, and `Reset zoom` should be translated.
- `Chat dengan AI` is understandable, but a simpler assistant-oriented label is more natural for navigation.
- Several helper texts can be shortened to task-oriented language instead of system language.

### Student surfaces reviewed
- `resources/js/components/navigation/student-nav.tsx`
- `resources/js/pages/student/dashboard.tsx`
- `resources/js/pages/student/courses/index.tsx`
- `resources/js/pages/student/courses/show.tsx`
- `resources/js/pages/student/groups/show.tsx`
- `resources/js/pages/student/pre-read/show.tsx`
- `resources/js/pages/student/ai-chat/index.tsx`
- `resources/js/pages/student/profile/components/AvatarUpload.tsx`

## Admin Summary

### Main findings
- Admin UI currently has the heaviest English leakage in the product.
- Navigation, page titles, buttons, filters, tables, modals, and empty states mix English nouns with Indonesian explanatory text.
- Some admin labels are understandable for the team but still too tool-like or implementation-oriented for admin operators.

### High-priority admin copy issues
- Navigation labels remain English: `Dashboard`, `User Management`, `AI Settings`, `Audit Log`, `Master Data`.
- Primary buttons and modal titles are mixed-language: `Add Provider`, `Create User`, `Import Users from CSV`, `Delete AI Provider`, `Test Connection`, `Add Course`.
- Table labels and filter controls remain English in user/course management pages.
- Master data page still uses `course` in many visible labels; this should align with `kelas` in Indonesian UI.

### Admin surfaces reviewed
- `resources/js/components/navigation/admin-nav.tsx`
- `resources/js/pages/admin/dashboard.tsx`
- `resources/js/pages/admin/user-management.tsx`
- `resources/js/pages/admin/master-data.tsx`
- `resources/js/pages/admin/ai-settings.tsx`
- `resources/js/pages/admin/audit-log.tsx`

## Cross-Role Consistency Recommendations

### Terminology
- Use `Analitik`, not `Analytics`.
- Use `kelompok` in learner/lecturer-facing collaboration flows.
- Use `mahasiswa` in lecturer/student academic contexts; avoid `siswa`.
- Use `kelas` in visible UI where backend/admin currently says `course`, except where raw CSV/schema labels are intentionally preserved.

### Interaction wording
- Use sentence case for labels and CTA text.
- Prefer task language over system language:
  - `Muat ulang`, not `Refresh`
  - `Tersambung` / `Tidak tersambung`, not `Live` / `Offline`
  - `Rincian`, not `breakdown`
  - `Lihat detail`, not `View Details`

### Translation policy
- Translate user-facing labels, button text, empty states, modal titles, and helper text.
- Keep backend contract values, enum keys, CSV column names, and technical payload structures unchanged unless a dedicated backend change is planned.

## Recommended implementation scope

### Phase 1
- Update primary navigation and landing surfaces for lecturer, student, and admin.
- Fix major mixed-language buttons, headings, and empty states on core workflow pages.
- Standardize `Analitik`, `kelompok`, `mahasiswa`, and `kelas` across visible UI.

### Phase 2
- Sweep secondary dialogs, advanced tables, CSV helper text, and deeper component-level tooltips.
- Audit backend-provided recommendation text separately if it is AI-generated or stored externally.
