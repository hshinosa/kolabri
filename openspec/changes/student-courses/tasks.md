## 1. Search dan Filter

- [x] 1.1 ~~Buat migration: tambah full-text index pada kolom `name` dan `code`~~ (BFF pattern: courses data dari external API, search dilakukan di controller via local filtering)
- [x] 1.2 Buat controller `CourseController` dengan endpoint GET list (enhanced)
- [x] 1.3 Implement query parameter: `q`, `filter[status]`, `page`
- [x] 1.4 Implement logika filter dengan Eloquent scope (local filtering di controller karena BFF pattern)
- [x] 1.5 Buat komponen `SearchBar.tsx` dengan debounce 300ms
- [x] 1.6 Buat komponen `FilterChips.tsx` (chip multi-select status)
- [x] 1.7 Implement hook `useCourseFilters.ts` untuk state management
- [x] 1.8 Sinkronkan state filter/search dengan URL query parameter
- [x] 1.9 Tambah jumlah hasil pada setiap chip filter

## 2. Integrasi & State

- [x] 2.1 Buat custom hook `useCourses.ts` untuk fetch data dengan React Query
- [x] 2.2 Implement caching dan invalidation data
- [x] 2.3 Tambah error handling dan retry mechanism
- [x] 2.4 Pastikan state konsisten saat navigasi

## 3. Validasi & QA

- [x] 3.1 Uji pencarian: keyword, kombinasi filter, empty result
- [x] 3.2 Uji filter: status, kombinasi, hapus filter
- [x] 3.3 Uji pagination: next, prev, reset saat filter berubah
- [x] 3.4 Uji state persistence: filter/search tetap saat kembali ke halaman
