## 1. Backend - AI Preview

- [x] 1.1 Buat endpoint AI preview (sandboxed execution)
- [x] 1.2 Implementasi rate limiting untuk preview calls
- [x] 1.3 Buat endpoint untuk course context selection

## 2. Backend - Presets

- [x] 2.1 Buat tabel `ai_presets` (migration)
- [x] 2.2 Buat API endpoints untuk presets CRUD
- [x] 2.3 Implementasi sharing within department
- [x] 2.4 Buat endpoint preset import/export

## 3. Backend - History

- [x] 3.1 Buat endpoint AI interaction history query
- [x] 3.2 Implementasi filter by course, student, date
- [x] 3.3 Buat archive service untuk data > 90 hari

## 4. Backend - A/B Testing

- [x] 4.1 Buat tabel `ai_ab_tests` dan `ai_ab_test_results` (migration)
- [x] 4.2 Buat API endpoints untuk A/B test CRUD
- [x] 4.3 Implementasi random assignment service
- [x] 4.4 Buat endpoint A/B test statistics

## 5. Frontend - Page Structure

- [x] 5.1 Buat halaman `lecturer/ai-settings/index.tsx`
- [x] 5.2 Buat tab navigation (Preview, Presets, History, A/B Testing)
- [x] 5.3 Implementasi layout dan routing

## 6. Frontend - Preview

- [x] 6.1 Buat komponen `AIPreviewEditor`
- [x] 6.2 Buat komponen `PreviewResponse` (sandboxed display)
- [x] 6.3 Buat komponen `CourseContextSelector`
- [x] 6.4 Tambah rate limit indicator

## 7. Frontend - Presets

- [x] 7.1 Buat komponen `PresetsList`
- [x] 7.2 Buat komponen `PresetEditor` (create/edit)
- [x] 7.3 Buat komponen `PresetShareDialog`
- [x] 7.4 Implementasi preset search

## 8. Frontend - History

- [x] 8.1 Buat komponen `HistoryList` dengan pagination
- [x] 8.2 Buat komponen `HistoryFilters` (course, student, date)
- [x] 8.3 Buat komponen `HistoryDetail` (expandable entry)

## 9. Frontend - A/B Testing

- [x] 9.1 Buat komponen `ABTestCreator`
- [x] 9.2 Buat komponen `ABTestList`
- [x] 9.3 Buat komponen `ABTestResults` dengan comparison charts
- [x] 9.4 Buat komponen `ABTestWinner` (apply winning variant)
