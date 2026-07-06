## Context
Halaman analytics lecturer (`lecturer/analytics/index.tsx` dan `overview.tsx`) saat ini menampilkan data dasar tanpa filtering atau export. Dosen memerlukan tools analisis yang lebih powerful untuk evaluasi dan pelaporan.

## Goals / Non-Goals
**Goals:**
- Memungkinkan export data analytics ke PDF/CSV
- Menyediakan date range filtering yang fleksibel
- Memungkinkan perbandingan antar kursus dan semester
- Visualisasi trend data untuk insight yang lebih baik

**Non-Goals:**
- Tidak mengubah data collection atau tracking system
- Tidak menambah predictive analytics
- Tidak mengubah dashboard utama lecturer

## Decisions
### 1. Chart library menggunakan Recharts
Recharts sudah digunakan di project (RadarChartPage). Konsisten dan mudah di-maintain.

### 2. Export menggunakan server-side generation
PDF export dilakukan di backend untuk formatting yang konsisten dan handling data besar. CSV export bisa client-side.

### 3. Date presets sesuai konteks akademik
Presets: "Minggu Ini", "Bulan Ini", "Semester Ini", "Tahun Ajaran Ini". Lebih relevan dibanding generic presets.

### 4. Comparison view menggunakan overlay charts
Data perbandingan ditampilkan sebagai overlay pada chart yang sama. Memudahkan visual comparison.

## Risks / Mitigations
- **Risiko**: Export data besar bisa timeout
  - **Mitigasi**: Async export dengan email notification, atau limit data range

- **Risiko**: Comparison view dengan banyak data bisa cluttered
  - **Mitigasi**: Limit max 3 items per comparison, interaktif toggle visibility

## Rollout Plan
1. **Phase 1**: Date filter dan trend charts
2. **Phase 2**: Export reports (CSV, PDF)
3. **Phase 3**: Comparison view
