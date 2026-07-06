## 1. Analytics Overview

- [x] 1.1 Buat endpoint aggregasi analytics (total students, total courses, avg engagement)
- [x] 1.2 Buat komponen `AnalyticsCard` untuk menampilkan metrics
- [x] 1.3 Buat komponen `CoursesAnalyticsOverview` yang menampilkan summary cards
- [x] 1.4 Integrasikan analytics cards di halaman courses index

## 2. Search & Filter

- [x] 2.1 Buat komponen `CourseSearchBar` dengan debounced search
- [x] 2.2 Buat komponen `CourseFilters` (semester, status)
- [x] 2.3 Implementasi client-side filtering logic
- [x] 2.4 Tambahkan URL params untuk filter state persistence

## 3. Bulk Actions

- [x] 3.1 Tambahkan selection mode dengan checkbox pada course cards
- [x] 3.2 Buat komponen `BulkActionBar` yang muncul saat ada selection
- [x] 3.3 Implementasi bulk archive dengan konfirmasi dialog
- [x] 3.4 Tambah select all / deselect all functionality

## 4. Integrasi & Testing

- [x] 4.1 Integrasi semua komponen ke halaman courses
- [x] 4.2 Update API integration dengan React Query
- [x] 4.3 Tambah loading state untuk setiap aksi
- [x] 4.4 Tambah error handling dan toast notification
- [x] 4.5 Test integrasi: search → filter → hasil
- [x] 4.6 Test integrasi: select → bulk action → konfirmasi
- [x] 4.7 Test edge case: bulk action dengan 0 selection
