## Why
Halaman courses lecturer saat ini hanya menampilkan daftar kursus dasar. Dosen membutuhkan overview analytics, kemampuan bulk actions, pencarian/filter yang lebih baik, dan fitur template kursus untuk efisiensi pengelolaan mata kuliah.

## What Changes
- Menambahkan analytics overview (total mahasiswa, total courses, rata-rata engagement)
- Implementasi bulk actions dengan selectable list (archive beberapa kursus sekaligus)
- Search & filter berdasarkan nama/kode, semester, status

## Capabilities
### New Capabilities
- `course-analytics-overview`: Summary cards analytics
- `course-bulk-actions`: Selectable list dengan bulk actions
- `course-search-filter`: Search dan filter courses

## Impact
- **Frontend**: Penambahan komponen analytics cards, bulk action toolbar dengan checkbox, search/filter bar di halaman courses index
- **Backend/API**: Endpoint baru untuk bulk operations, analytics aggregation
- **Breaking changes**: Tidak ada
