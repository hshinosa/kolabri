## Why
Halaman detail analytics lecturer saat ini terbatas. Dosen membutuhkan drill-down dari level kursus ke individual mahasiswa, trend charts interaktif, export per analytics, dan benchmark comparison untuk evaluasi yang lebih mendalam.

## What Changes
- Interactive trend charts dengan drill-down capability
- Student breakdown dari course-level ke individual analytics
- Export specific analytics sebagai PDF/CSV dengan share link
- Benchmark comparison terhadap rata-rata departemen/semester

## Capabilities
### New Capabilities
- `analytics-detail-trend-charts`
- `analytics-student-breakdown`
- `analytics-detail-export`
- `analytics-benchmark`

## Impact
- **Frontend**: Penambahan drill-down charts, student detail view, benchmark overlay pada halaman analytics detail
- **Backend/API**: Endpoint untuk student-level data, benchmark aggregation, shareable report links
- **Data**: Tabel `shared_reports` untuk share links
- **Breaking changes**: Tidak ada
