## Why

Halaman Courses adalah pusat navigasi pembelajaran mahasiswa. Saat ini eksplorasi daftar mata kuliah terbatas karena tidak ada pencarian, filter, atau pelacakan progres. Mahasiswa harus membuka setiap course satu per satu untuk mengetahui status kemajuan belajar mereka.

Permasalahan utama:
- **Discoverability**: Tidak ada cara mencari mata kuliah berdasarkan nama atau kode
- **Filtering**: Semua mata kuliah ditampilkan tanpa opsi filter berdasarkan status

## What Changes

### 1. Pencarian Courses
Menambahkan kolom pencarian di bagian atas halaman untuk mencari mata kuliah berdasarkan nama dan kode.

### 2. Filter Courses
Menambahkan filter berdasarkan status (aktif, selesai, belum mulai).

## Capabilities

### New Capabilities
- `student-courses-search`: Pencarian mata kuliah berdasarkan nama dan kode
- `student-courses-filter`: Filter berdasarkan status

## User Stories

1. **Sebagai mahasiswa**, saya ingin mencari mata kuliah berdasarkan nama sehingga saya bisa menemukannya dengan cepat
2. **Sebagai mahasiswa**, saya ingin memfilter mata kuliah berdasarkan status sehingga saya bisa fokus pada mata kuliah yang sedang berjalan

## Impact

- **Frontend**: Halaman daftar courses, komponen filter/search, kartu dengan progress bar
- **Backend/API**: Query list courses terfilter + agregasi progres
- **Data**: Metadata kategori dan perhitungan progres belajar
- **Performance**: Agregasi progres harus efisien untuk banyak mata kuliah
- **Breaking changes**: Tidak ada

## Success Metrics

- Penurunan waktu menemukan mata kuliah tertentu ≥ 50%
- Peningkatan engagement pada mata kuliah yang progresnya terlihat rendah ≥ 15%
- Mahasiswa lebih sering mengakses mata kuliah berdasarkan kategori
- Rata-rata klik untuk menemukan mata kuliah berkurang
