## Context
Halaman courses lecturer (`lecturer/courses/index.tsx`) saat ini hanya menampilkan daftar kursus dengan navigasi ke detail. Dosen memerlukan tools yang lebih powerful untuk mengelola multiple mata kuliah secara efisien.

## Goals / Non-Goals
**Goals:**
- Memberikan overview analytics langsung di halaman courses
- Memungkinkan operasi massal pada beberapa kursus sekaligus
- Menyediakan pencarian dan filtering yang comprehensive
- Memungkinkan dosen membuat dan menggunakan template kursus

**Non-Goals:**
- Tidak mengubah struktur halaman course detail (ada change terpisah)
- Tidak mengubah sistem enrollment mahasiswa
- Tidak menambah fitur collaboration baru

## Decisions
### 1. Client-side filtering untuk search & filter
Filtering dilakukan di frontend untuk response cepat pada dataset kursus yang relatif kecil per dosen. Backend tetap menyediakan data teraggregasi untuk analytics.

### 2. Bulk actions menggunakan selection mode
Menggunakan pattern checkbox selection dengan toolbar muncul di bagian bawah saat ada item terpilih. UX yang familiar dan intuitif.

### 3. Template disimpan sebagai JSON structure
Template kursus menyimpan struktur modules, assignments, dan settings dalam format JSON. Memungkinkan fleksibilitas tanpa schema changes yang kompleks.

### 4. Analytics cards menggunakan data teraggregasi
Analytics overview menampilkan pre-aggregated data dari backend untuk performa optimal. Data di-cache dan di-refresh periodik.

## Risks / Mitigations
- **Risiko**: Bulk operations pada banyak kursus bisa membebani database
  - **Mitigasi**: Implementasi batch processing dengan progress indicator, limit maksimal 50 kursus per operasi

- **Risiko**: Template bisa menjadi tidak relevan jika struktur kursus berubah
  - **Mitigasi**: Version checking saat apply template, graceful handling untuk field yang sudah tidak ada

## Rollout Plan
1. **Phase 1**: Search & filter, analytics overview cards
2. **Phase 2**: Bulk actions dengan selection mode
3. **Phase 3**: Course templates (create, save, apply)
