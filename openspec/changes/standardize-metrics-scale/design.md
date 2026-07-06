## Context

API analytics Kolabri mengembalikan metrik dengan skala tidak konsisten:
- `lexical_variety`: 0-1 (dibagi 100 di `analytics.service.ts:50`)
- `hot_percentage`: 0-100
- `qualityScore`: 0-100
- `engagementDistribution`: 0-100
- `participation`: 0-100

Frontend melakukan konversi manual: `lexicalVariety * 100` untuk display, `lexicalVariety * 10` untuk radar chart.

## Goals / Non-Goals

**Goals:**
- Semua metrik di API response menggunakan skala 0-100
- Frontend tidak perlu konversi manual untuk display
- Konsistensi memudahkan developer baru

**Non-Goals:**
- Mengubah internal calculation di `chatAnalytics.service.ts` (tetap 0-100)
- Mengubah formula quality score (sudah konsisten 0-100)
- Mengubah radar chart scale (tetap 0-10, hanya sesuaikan rumus)

## Decisions

### 1. Standardisasi di layer API response, bukan internal calculation

**Rationale**: `chatAnalytics.service.ts` sudah menghitung dalam 0-100. Konversi ke 0-1 terjadi di `analytics.service.ts` saat membangun response. Lebih baik hapus konversi ini daripada mengubah seluruh pipeline.

**Alternatif considered**:
- Ubah internal calculation ke 0-1: Terlalu banyak perubahan, berisiko break quality score formula
- Biarkan saja: Tidak konsisten, membingungkan developer

### 2. Frontend sesuaikan rumus, bukan tambah konversi

**Rationale**: Karena API sudah 0-100, frontend tinggal pakai langsung untuk display. Radar chart tetap 0-10, rumus diubah dari `* 10` ke `/ 10`.

## Risks / Trade-offs

- **[Breaking change]** API response berubah → Mitigasi: Update frontend bersamaan
- **[Cached data]** Client mungkin cache response lama → Mitigasi: Restart server, clear browser cache

## Migration Plan

1. Update `analytics.service.ts` — hapus `/ 100` pada `lexical_variety`
2. Update `analytics/show.tsx` — sesuaikan display dan radar chart formula
3. Restart core-api
4. Verify di browser
