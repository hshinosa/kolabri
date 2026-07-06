## 1. Template Refleksi

- [x] 1.1 Buat migration: tabel `reflection_templates`
- [x] 1.2 Buat model `ReflectionTemplate` dengan relasi
- [x] 1.3 Buat controller `ReflectionTemplateController` dengan CRUD endpoint
- [x] 1.4 Seed template global default (Harian, Mingguan, Proyek, Evaluasi Diri)
- [x] 1.5 Buat komponen `TemplatePanel.tsx` dengan filter kategori
- [x] 1.6 Buat komponen `TemplateCard.tsx` dengan aksi gunakan/edit/hapus
- [x] 1.7 Buat modal buat/edit template dengan form
- [x] 1.8 Implement auto-fill editor saat template dipilih
- [x] 1.9 Tambah validasi: maksimal 30 template personal per user
- [x] 1.10 Tandai template global dengan label "Template umum"

## 2. Search Refleksi

- [x] 2.1 Buat migration: tambah full-text index pada kolom `title` dan `content`
- [x] 2.2 Update controller `ReflectionController` dengan parameter search
- [x] 2.3 Implement full-text search dengan filter tag dan tanggal
- [x] 2.4 Implement highlight snippet pada hasil pencarian
- [x] 2.5 Buat komponen `SearchBar.tsx` dengan debounce
- [x] 2.6 Buat komponen `FilterChips.tsx` untuk filter tag dan tanggal
- [x] 2.7 Sinkronkan state search/filter dengan URL query parameter
- [x] 2.8 Tampilkan empty state "Tidak ada refleksi yang cocok"

## 3. Analitik Refleksi

- [x] 3.1 Buat controller `ReflectionAnalyticsController` dengan endpoint GET
- [x] 3.2 Implement agregasi frekuensi menulis per periode
- [x] 3.3 Implement agregasi panjang rata-rata refleksi
- [x] 3.4 Implement perhitungan streak menulis beruntun
- [x] 3.5 Implement agregasi tag terpopuler
- [x] 3.6 Implement data timeline untuk grafik
- [x] 3.7 Buat komponen `AnalyticsPanel.tsx`
- [x] 3.8 Buat komponen `FrequencyChart.tsx` (bar chart)
- [x] 3.9 Buat komponen `LengthChart.tsx` (line chart)
- [x] 3.10 Buat komponen `StreakIndicator.tsx`
- [x] 3.11 Tambah pilihan periode (minggu, bulan, tahun)
- [x] 3.12 Tambah label narasi pada setiap metrik

## 4. Tag System

- [x] 4.1 Buat migration: tambah kolom `tags` JSONB pada tabel `reflections`
- [x] 4.2 Buat endpoint `GET /api/student/reflections/tags` untuk daftar tag
- [x] 4.3 Buat komponen `TagInput.tsx` dengan autocomplete
- [x] 4.4 Buat komponen `TagBadge.tsx` dengan warna berdasarkan frekuensi
- [x] 4.5 Implement filter berdasarkan tag
- [x] 4.6 Tambah validasi: maksimal 10 tag per refleksi

## 5. Integrasi & Testing

- [x] 5.1 Integrasi semua komponen ke halaman reflections
- [x] 5.2 Update API integration dengan React Query
- [x] 5.3 Tambah loading state untuk setiap aksi
- [x] 5.4 Tambah error handling dan toast notification
- [x] 5.5 Test integrasi: template → tulis → simpan
- [x] 5.6 Test integrasi: search → filter → hasil
- [x] 5.7 Test integrasi: analytics → chart → data
- [x] 5.8 Test edge case: search dengan hasil kosong
- [x] 5.9 Test edge case: tag duplicate
