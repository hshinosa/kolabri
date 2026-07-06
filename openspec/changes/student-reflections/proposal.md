## Why

Halaman Reflections memungkinkan mahasiswa menulis evaluasi diri tentang proses belajar mereka. Saat ini mahasiswa sering kesulitan memulai refleksi karena tidak ada panduan, tidak bisa mencari refleksi lama, dan tidak bisa melihat tren perkembangan kualitas refleksi mereka.

Permasalahan utama:
- **Writer's block**: Mahasiswa tidak tahu harus menulis apa tanpa template atau panduan
- **Retrieval**: Refleksi lama sulit ditemukan karena tidak ada pencarian
- **Insight**: Tidak ada analitik yang menunjukkan tren kualitas dan frekuensi refleksi

## What Changes

### 1. Template Refleksi
Menambahkan katalog template refleksi yang bisa digunakan sebagai kerangka penulisan.

### 2. Pencarian Refleksi
Menambahkan pencarian berdasarkan judul, isi, dan tag refleksi.

### 3. Analitik Refleksi
Menambahkan panel analitik yang menampilkan tren frekuensi, panjang, dan konsistensi menulis.

## Capabilities

### New Capabilities
- `student-reflections-templates`: Template refleksi untuk memulai penulisan
- `student-reflections-search`: Pencarian refleksi berdasarkan konten
- `student-reflections-analytics`: Analitik tren refleksi

## User Stories

1. **Sebagai mahasiswa**, saya ingin menggunakan template refleksi sehingga saya bisa mulai menulis dengan panduan
2. **Sebagai mahasiswa**, saya ingin mencari refleksi lama sehingga saya bisa menemukan catatan yang pernah saya buat
3. **Sebagai mahasiswa**, saya ingin melihat tren refleksi sehingga saya tahu seberapa konsisten saya menulis

## Impact

- **Frontend**: Halaman reflections, panel template, panel analitik, komponen ekspor
- **Backend/API**: Query pencarian, endpoint ekspor, agregasi analitik
- **Data**: Template refleksi, metadata analitik
- **Breaking changes**: Tidak ada

## Success Metrics

- Peningkatan frekuensi menulis refleksi ≥ 30%
- Penggunaan template ≥ 50% dari refleksi baru
- Peningkatan panjang rata-rata refleksi ≥ 20%
- Ekspor berhasil tanpa error ≥ 99%
