## 1. Backend — Standardisasi API Response

- [x] 1.1 Hapus `/ 100` division pada `lexical_variety` di `analytics.service.ts:50`
- [x] 1.2 Verify API response `qualityBreakdown.lexical_variety` sekarang 0-100

## 2. Frontend — Sesuaikan Display

- [x] 2.1 Hapus `* 100` pada display lexical variety di `analytics/show.tsx:357`
- [x] 2.2 Sesuaikan radar chart formula: `lexicalVariety * 10` → `lexicalVariety / 10`
- [x] 2.3 Verify display menunjukkan nilai yang benar (50%, bukan 0.5% atau 5000%)

## 3. Verification

- [x] 3.1 Restart core-api
- [x] 3.2 Test endpoint `/api/analytics/group/:id` — pastikan `lexical_variety` dalam 0-100
- [x] 3.3 Test frontend — pastikan display dan radar chart benar
