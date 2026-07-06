## Context
Halaman analytics detail (`lecturer/analytics/show.tsx`) saat ini menampilkan data aggregate. Dosen memerlukan kemampuan drill-down dan benchmarking untuk analisis yang lebih mendalam.

## Goals / Non-Goals
**Goals:**
- Memungkinkan drill-down dari course analytics ke student-level
- Menyediakan trend charts interaktif dengan zoom dan filter
- Export specific analytics dengan shareable links
- Benchmark comparison terhadap rata-rata

**Non-Goals:**
- Tidak mengubah data collection methodology
- Tidak menambah real-time streaming analytics
- Tidak mengubah analytics overview page

## Decisions
### 1. Drill-down menggunakan breadcrumb navigation
Navigasi: Course > Module > Student. Clear path dan mudah back-track.

### 2. Benchmark data dari aggregated anonymous data
Benchmark menggunakan rata-rata departemen yang di-aggregate dari semua kursus. Privacy-safe.

### 3. Share links dengan expiry
Shared reports memiliki expiry date untuk security. Default 7 hari.

### 4. Interactive charts dengan zoom dan pan
Recharts brush component untuk zoom. Memungkinkan fokus pada specific time periods.

## Risks / Mitigations
- **Risiko**: Student-level data bisa sangat besar
  - **Mitigasi**: Pagination, lazy loading, dan caching

- **Risiko**: Benchmark data bisa misleading jika sample kecil
  - **Mitigasi**: Tampilkan sample size, warning jika < 10 courses

## Rollout Plan
1. **Phase 1**: Interactive trend charts dengan zoom
2. **Phase 2**: Student breakdown drill-down
3. **Phase 3**: Export dan share links
4. **Phase 4**: Benchmark comparison
