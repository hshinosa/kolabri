## Why

UI copy across lecturer, student, and admin areas is inconsistent. The product still mixes Indonesian and English terms, exposes internal product language in user-facing screens, and uses different vocabulary for the same concept (`grup`/`kelompok`, `course`/`kelas`, `Analytics`/`Analitik`). This lowers clarity and makes the interface feel unfinished.

## What Changes

- Standardize high-visibility UI copy across lecturer, student, and admin surfaces.
- Localize major English labels, buttons, headings, empty states, and helper text into consistent Indonesian.
- Keep backend contracts, stored values, and API payloads unchanged.
- Scope implementation to primary navigation and core workflow pages first.

## Capabilities

### New Capabilities
- `cross-role-ui-copy-clarity`: Users across lecturer, student, and admin areas understand core actions and page intent through consistent Indonesian copy.

### Modified Capabilities
- `dashboard`: Clarify dashboard terminology in student and admin areas.
- `settings`: Clarify admin AI settings wording without changing provider logic.
- `lecturer-courses`: Clarify lecturer course-management language.
- `student-course-detail`: Clarify student group/session/pre-read language.
- `admin-ux-performance`: Clarify admin management wording without changing admin workflows.

## Impact

- `Kolabri-client-app`: update visible copy in shared navigation plus lecturer, student, and admin pages.
- No API changes.
- No database changes.
- No behavioral changes besides user-visible wording.