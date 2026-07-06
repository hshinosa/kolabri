## Why
Dosen memerlukan kontrol atas AI features di Kolabri. Saat ini tidak ada halaman untuk preview/test AI responses, mengelola prompt presets, melihat history interaksi AI, atau melakukan A/B testing untuk optimasi prompt.

## What Changes
- Preview/test AI responses sebelum deploy ke mahasiswa
- Presets management (simpan, load, share prompt presets)
- History interaksi AI dengan filter
- A/B testing untuk membandingkan prompt variants

## Capabilities
### New Capabilities
- `ai-preview-test`
- `ai-presets-management`
- `ai-interaction-history`
- `ai-ab-testing`

## Impact
- **Frontend**: Halaman baru `lecturer/ai-settings` dengan tabs: Preview, Presets, History, A/B Testing
- **Backend/API**: Endpoint untuk AI preview, presets CRUD, history query, A/B test management
- **Data**: Tabel `ai_presets`, `ai_ab_tests`, `ai_ab_test_results`
- **Breaking changes**: Tidak ada
