## Context

Dashboard analytics (`/student/dashboard/analytics`) bertujuan membantu mahasiswa memahami pola belajar, kekuatan, dan area yang perlu perhatian. Visual harus informatif namun tetap sederhana dan mudah dipahami.

Tech stack yang relevan:
- **Frontend**: React 19, TypeScript, Tailwind CSS v4, Inertia.js
- **Chart Library**: Recharts, Chart.js, atau D3.js (belum diputuskan)
- **Backend**: Laravel (API), Eloquent ORM
- **Data**: Agregasi dari tabel courses, assignments, activities, reflections

## Goals / Non-Goals

**Goals:**
- Menyediakan gambaran multi-dimensi capaian belajar
- Menampilkan pola waktu dan konsistensi aktivitas
- Menyajikan tren yang mudah ditindaklanjuti
- Memberikan insight yang actionable untuk perbaikan

**Non-Goals:**
- Tidak membuat prediksi nilai otomatis berbasis AI
- Tidak membangun sistem BI eksternal penuh
- Tidak menambah fitur perbandingan dengan mahasiswa lain (privasi)

## Decisions

### 1. Radar chart kompetensi
- Setiap sumbu mewakili dimensi kompetensi inti:
  - Pengetahuan (quiz/ujian)
  - Keterampilan (tugas praktik)
  - Kolaborasi (kontribusi grup)
  - Refleksi (kualitas refleksi)
  - Konsistensi (streak aktivitas)
  - Partisipasi (kehadiran/engagement)
- Skala dinormalisasi 0-100 untuk perbandingan adil
- Tooltip menampilkan detail per dimensi
- Bisa di-rotate untuk melihat dari perspektif berbeda

### 2. Progress timeline
- Timeline menampilkan milestone penting:
  - Course dimulai/diselesaikan
  - Tugas dikumpulkan
  - Refleksi ditulis
  - Streak tercapai
- Timeline vertikal dengan ikon per jenis milestone
- Filter berdasarkan periode (minggu, bulan, semester)
- Klik milestone untuk detail

### 3. Activity heatmap
- Heatmap memetakan intensitas aktivitas per hari
- Format: 7 kolom (Sen-Min) x N baris (minggu)
- Warna: abu-abu (tidak aktif) → hijau muda → hijau tua (sangat aktif)
- Tooltip menampilkan jumlah aktivitas per hari
- Data dari tabel activity log

### 4. Trend cards
- Metrik utama dengan tren:
  - **Tugas selesai**: jumlah + tren minggu ini vs minggu lalu
  - **Rata-rata nilai**: rata-rata + tren
  - **Streak**: hari berturut-turut + tren
  - **Waktu belajar**: estimasi jam + tren
- Indikator: ▲ hijau (naik), ▼ merah (turun), ─ abu-abu (stabil)
- Narasi singkat interpretasi (misal: "Tugas selesai meningkat 15% dari minggu lalu")

### 5. Responsive layout
- Desktop: grid 2 kolom (radar + heatmap di atas, timeline + trends di bawah)
- Mobile: stack vertikal
- Setiap komponen bisa di-expand/collapse

### 6. Data aggregation
- Data di-aggregate per periode (minggu, bulan, semester)
- Cache hasil aggregate untuk performa
- Update cache setiap jam atau saat ada perubahan data

## Component Architecture

```
student/dashboard/analytics/
├── index.tsx                    # Halaman dashboard analytics
├── components/
│   ├── RadarChart.tsx           # Radar chart kompetensi
│   │   └── RadarAxis.tsx        # Sumbu dengan tooltip
│   ├── ProgressTimeline.tsx     # Timeline progres
│   │   └── TimelineItem.tsx     # Item milestone
│   ├── ActivityHeatmap.tsx      # Heatmap aktivitas
│   │   └── HeatmapCell.tsx      # Sel heatmap dengan tooltip
│   ├── TrendCards.tsx           # Panel tren
│   │   └── TrendCard.tsx        # Kartu tren individual
│   └── PeriodSelector.tsx       # Selector periode analitik
└── hooks/
    ├── useAnalytics.ts          # Hook untuk data analytics
    └── useRadarData.ts          # Hook untuk data radar
```

## API Contracts

### Analytics Overview
```
GET /api/student/dashboard/analytics?period={week|month|semester}
Response: {
  radar: { dimensions: [{ name, score, detail }] },
  timeline: [{ id, type, title, date, description }],
  heatmap: [{ date, count, level }],
  trends: {
    tasks_completed: { current, previous, change_percentage, narrative },
    average_grade: { current, previous, change_percentage, narrative },
    streak: { current, previous, change_percentage, narrative },
    study_hours: { current, previous, change_percentage, narrative }
  }
}
```

### Radar Detail
```
GET /api/student/dashboard/analytics/radar?period={period}
Response: {
  dimensions: [
    { name: "Pengetahuan", score: 85, detail: "Quiz rata-rata 85, Ujian rata-rata 82" },
    { name: "Keterampilan", score: 78, detail: "8 dari 10 tugas praktik selesai" },
    ...
  ]
}
```

### Timeline Events
```
GET /api/student/dashboard/analytics/timeline?period={period}&type={type}
Response: {
  events: [{ id, type, title, date, description, metadata }],
  meta: { total, per_page, current_page }
}
```

### Heatmap Data
```
GET /api/student/dashboard/analytics/heatmap?weeks={n}
Response: {
  data: [{ date: "2026-01-15", count: 5, level: 3 }],
  summary: { total_days_active, current_streak, longest_streak }
}
```

## Data Model

```sql
-- Tabel activity log (jika belum ada)
CREATE TABLE user_activities (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    type VARCHAR(50) NOT NULL,  -- course_started, assignment_submitted, reflection_written, login, etc.
    metadata JSONB NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk heatmap dan timeline
CREATE INDEX idx_user_activities_user_date ON user_activities(user_id, created_at DESC);
CREATE INDEX idx_user_activities_type ON user_activities(user_id, type);

-- Tabel kompetensi (untuk radar chart)
CREATE TABLE user_competency_scores (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    dimension VARCHAR(50) NOT NULL,  -- knowledge, skill, collaboration, reflection, consistency, participation
    score DECIMAL(5,2) DEFAULT 0,
    calculated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, dimension)
);

-- Tabel trend cache
CREATE TABLE analytics_trend_cache (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    metric VARCHAR(50) NOT NULL,
    period VARCHAR(20) NOT NULL,
    current_value DECIMAL(10,2),
    previous_value DECIMAL(10,2),
    change_percentage DECIMAL(5,2),
    cached_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, metric, period)
);
```

## Risks / Mitigations

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Interpretasi visual salah | Keputusan salah | Label, legenda, tooltip yang jelas + narasi interpretasi |
| Komputasi berat untuk banyak data | Loading lambat | Cache hasil aggregate, background job |
| Dimensi kompetensi tidak relevan | Tidak berguna | Validasi dengan stakeholder akademik |
| Heatmap membuat cemas jika jarang aktif | Negatif | Fokus pada tren positif, bukan kekurangan |

## Rollout Plan

1. **Spec Review**: Validasi definisi metrik dengan stakeholder
2. **Visual Prototype**: Buat prototype radar chart dan heatmap
3. **User Testing**: Validasi pemahaman visual dengan mahasiswa
4. **Implementation**: Setelah spesifikasi disetujui

## Note

Perubahan ini bersifat **spec-only**. Task breakdown akan dibuat setelah:
1. Definisi metrik divalidasi stakeholder akademik
2. Pilihan library visualisasi diputuskan
3. Prototype UI diuji dengan mahasiswa
