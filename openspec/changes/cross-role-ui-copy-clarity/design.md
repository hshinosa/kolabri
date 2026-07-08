## Context

Kolabri now has mature lecturer, student, and admin surfaces, but UI text has grown unevenly. Lecturer pages still expose analytics jargon, student pages still mix `grup` and `kelompok`, and admin pages have broad English leakage (`Dashboard`, `User Management`, `Add Provider`, `View Details`, and similar labels). The change is presentational only: copy should become clearer without touching API contracts, enum values, or backend rules.

## Goals / Non-Goals

**Goals:**
- Standardize high-visibility copy in lecturer, student, and admin areas.
- Prefer Indonesian task language over internal product jargon.
- Keep terminology consistent for `analitik`, `kelas`, `kelompok`, and `mahasiswa`.
- Limit implementation to existing rendered text in primary navigation and major workflow pages.

**Non-Goals:**
- Redesign layouts or information architecture.
- Rename backend enums, payload fields, or stored values.
- Audit every low-level tooltip or backend-generated sentence in this change.
- Change access rules, workflow behavior, or page routing.

## Decisions

### Standardize visible labels only
Copy will change only where text is shown to users. Internal identifiers such as route names, object keys, CSV schema columns, and backend enum values remain unchanged.

### Prioritize core workflow surfaces
This change targets primary navigation, hero/section headings, empty states, buttons, modal titles, filter labels, and major helper text in the most-used pages. This yields the biggest clarity win with the smallest diff.

### Use role-appropriate Indonesian
- Lecturer/student academic flows use `kelas`, `mahasiswa`, `kelompok`, and `analitik`.
- Admin flows use Indonesian management language (`Kelola pengguna`, `Pengaturan AI`, `Log audit`), while technical field names that map directly to external providers may remain recognizable when needed (`API key`, `Base URL`, `JSON`).

## UX Copy Decisions

### Cross-role glossary
- `Analytics` → `Analitik`
- `Dashboard` → `Dasbor`
- `User Management` → `Kelola Pengguna`
- `AI Settings` → `Pengaturan AI`
- `Audit Log` → `Log Audit`
- `Master Data Management` → `Data Kelas`
- `group/grup` in learner-facing flows → `kelompok`
- `course/course name` in visible admin UI → `kelas/nama kelas`
- `View Details` → `Lihat detail`
- `Add` / `Create` / `Delete` / `Import` / `Export` button text → Indonesian action verbs

### Student-specific decisions
- `Pre-read` → `Bacaan awal`
- `Chat dengan AI` navigation label → `Asisten AI`
- image controls (`Zoom in/out`, `Reset zoom`) → Indonesian equivalents
- group/session helper text should be simplified around student tasks, not system state

### Admin-specific decisions
- Keep `API key`, `Base URL`, and `JSON` where these map directly to external provider configuration.
- Translate surrounding workflow copy, buttons, section headings, filters, empty states, and modal CTAs.

## Risks / Trade-offs

- Broad copy sweeps can accidentally over-translate technical admin labels. To reduce risk, external-provider terms that directly mirror third-party config stay recognizable.
- Some existing backend data may still emit English text into the UI; this change only covers frontend-owned copy.
- A full app-wide copy normalization would be larger. This change intentionally focuses on high-visibility surfaces first.

## Verification Plan

- Run targeted frontend type checking in `Kolabri-client-app`.
- Run targeted unit tests covering edited shared navigation or existing copy-sensitive components where applicable.
- Manually verify changed text exists in the edited files and no copy-only edit changed behavior.