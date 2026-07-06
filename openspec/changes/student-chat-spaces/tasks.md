## 1. Search / Filter / Sort

- [x] 1.1 Buat migration: tambah kolom `type`, `status`, `last_message_at` pada tabel `chat_rooms`
- [x] 1.2 Buat migration: tambah full-text index dan composite index
- [x] 1.3 Buat controller `ChatSpaceController` dengan endpoint GET list
- [x] 1.4 Implement query parameter: `q`, `filter[type]`, `filter[status]`, `sort`, `page`
- [x] 1.5 Implement logika filter dengan Eloquent scope
- [x] 1.6 Implement logika sorting (terbaru, alfabet)
- [x] 1.7 Buat komponen `SearchBar.tsx` dengan debounce 300ms
- [x] 1.8 Buat komponen `FilterChips.tsx` (chip multi-select tipe/status)
- [x] 1.9 Buat komponen `SortDropdown.tsx`
- [x] 1.10 Implement hook `useSpaceFilters.ts` untuk state management
- [x] 1.11 Sinkronkan state filter/sort/search dengan URL query parameter
- [x] 1.12 Tambah jumlah hasil pada setiap chip filter

## 2. Preview Aktivitas

- [x] 2.1 Tambah kolom `last_message_at` pada tabel `chat_rooms` (jika belum ada)
- [x] 2.2 Buat service `ActivityPreviewService` untuk mengambil pesan terakhir
- [x] 2.3 Implement aggregate data aktivitas dengan query efisien
- [x] 2.4 Tambah field `last_activity` pada response API list spaces
- [x] 2.5 Buat komponen `ActivityPreview.tsx` dengan waktu relatif
- [x] 2.6 Implement potong teks preview maksimal 100 karakter dengan ellipsis
- [x] 2.7 Tampilkan "Belum ada aktivitas" untuk ruang tanpa pesan
- [x] 2.8 Tambah nama pengirim pada preview jika pesan dari orang lain

## 3. Empty State

- [x] 3.1 Buat komponen `EmptyState.tsx` dengan props konteks
- [x] 3.2 Implement empty state "Belum ada ruang" dengan ilustrasi dan CTA
- [x] 3.3 Implement empty state "Hasil filter kosong" dengan CTA hapus filter
- [x] 3.4 Implement empty state "Hasil pencarian kosong" dengan saran
- [x] 3.5 Tambah skeleton loading pada kartu ruang saat data dimuat
- [x] 3.6 Tampilkan informasi pagination "Menampilkan X-Y dari Z ruang"

## 4. Pagination

- [x] 4.1 Implement cursor-based atau offset pagination di API
- [x] 4.2 Buat komponen `Pagination.tsx`
- [x] 4.3 Reset ke halaman 1 saat filter/sort berubah
- [x] 4.4 Sinkronkan halaman dengan URL query parameter

## 5. Integrasi & State

- [x] 5.1 Buat custom hook `useSpaces.ts` untuk fetch data dengan React Query
- [x] 5.2 Implement caching dan invalidation data
- [x] 5.3 Tambah error handling dan retry mechanism
- [x] 5.4 Pastikan state konsisten saat navigasi

## 6. Validasi & QA

- [x] 6.1 Uji pencarian: keyword, kombinasi filter, empty result
- [x] 6.2 Uji filter: single, multi, hapus filter
- [x] 6.3 Uji sorting: terbaru, alfabet
- [x] 6.4 Uji preview: pesan terakhir, ruang kosong, teks panjang
- [x] 6.5 Uji empty state: semua kondisi
- [x] 6.6 Uji pagination: navigasi halaman, reset saat filter berubah
