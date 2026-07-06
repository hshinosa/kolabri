## Why

API analytics mengembalikan metrik dengan skala yang tidak konsisten: `lexical_variety` menggunakan 0-1, sementara `hot_percentage`, `qualityScore`, dan metrik lainnya menggunakan 0-100. Ini membingungkan developer dan rawan bug saat integrasi frontend-backend.

## What Changes

- Standardisasi semua metrik di API response ke skala 0-100
- `lexical_variety` diubah dari 0-1 ke 0-100 (dikalikan 100 di backend)
- Frontend menyesuaikan: hapus konversi `* 100` untuk display, sesuaikan rumus radar chart
- **BREAKING**: API response `qualityBreakdown.lexical_variety` berubah dari 0-1 ke 0-100

## Capabilities

### New Capabilities

- `metrics-standardization`: Standardisasi skala metrik analytics ke 0-100 di seluruh stack

### Modified Capabilities

_(tidak ada spec existing yang perlu diubah)_

## Impact

- **Backend**: `analytics.service.ts` (line 50) — hapus `/ 100` division
- **Frontend**: `analytics/show.tsx` — sesuaikan display dan radar chart formula
- **API**: Response `qualityBreakdown.lexical_variety` berubah scale
