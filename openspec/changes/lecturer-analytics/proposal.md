## Why
Halaman analytics lecturer saat ini menampilkan data terbatas. Dosen membutuhkan kemampuan export reports, filtering by date range, perbandingan antar kursus/semester, dan visualisasi trend untuk pengambilan keputusan berbasis data.

## What Changes
- Export reports (PDF/CSV) dengan scheduled reports
- Date filter dengan custom range dan presets
- Comparison view antar kursus, semester, dan kelompok mahasiswa
- Trend charts untuk engagement, completion, dan attendance

## Capabilities
### New Capabilities
- `analytics-export-reports`
- `analytics-date-filter`
- `analytics-comparison-view`
- `analytics-trend-charts`

## Impact
- **Frontend**: Penambahan filter bar, comparison selector, trend chart components, export button
- **Backend/API**: Endpoint untuk export, aggregasi data by date range, comparison data
- **Data**: Tabel `saved_reports` untuk scheduled reports
- **Breaking changes**: Tidak ada
