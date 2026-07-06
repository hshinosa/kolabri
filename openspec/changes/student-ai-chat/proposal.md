## Why

Halaman AI Chat mahasiswa saat ini memiliki keterbatasan signifikan dalam pengelolaan percakapan belajar. Mahasiswa kesulitan menemukan kembali jawaban penting dari percakapan panjang, tidak bisa mengelompokkan percakapan berdasarkan topik mata kuliah, dan harus mengetik ulang prompt yang sama berulang kali. Ekspor percakapan untuk dokumentasi tugas atau portofolio juga belum tersedia.

Permasalah utama:
- **Discoverability**: Percakapan lama hilang di antara ratusan sesi tanpa cara mencari
- **Reusability**: Prompt yang efektif harus diketik ulang setiap kali
- **Organization**: Pesan penting sulit ditemukan kembali

## What Changes

### 1. Pencarian Percakapan AI
Menambahkan kolom pencarian di sidebar riwayat yang mencari berdasarkan judul sesi, isi prompt pengguna, dan jawaban AI. Hasil diurutkan berdasarkan relevansi dan recency.

### 2. Template Prompt
Menambahkan panel template prompt siap pakai yang bisa disimpan, diorganisasi, dan digunakan ulang dengan satu klik.

### 3. Bookmark Pesan
Menambahkan kemampuan menandai pesan atau jawaban penting untuk akses cepat di kemudian hari.

## Capabilities

### New Capabilities
- `student-ai-chat-search`: Pencarian isi percakapan AI berdasarkan kata kunci
- `student-ai-chat-templates`: Manajemen dan penggunaan template prompt
- `student-ai-chat-bookmarks`: Penandaan dan navigasi konten penting

## User Stories

1. **Sebagai mahasiswa**, saya ingin mencari percakapan lama tentang materi tertentu sehingga saya bisa menemukan jawaban yang pernah diberikan AI
2. **Sebagai mahasiswa**, saya ingin menggunakan template prompt sehingga saya tidak perlu mengetik ulang prompt yang sama
3. **Sebagai mahasiswa**, saya ingin menandai jawaban penting sehingga saya bisa menemukannya dengan cepat

## Impact

- **Frontend**: Halaman AI chat mahasiswa, state filter/pencarian, komponen bookmark/template, panel kategori
- **Backend/API**: Endpoint daftar percakapan terfilter, ekspor asinkron, metadata kategori/bookmark, CRUD template
- **Data**: Tambahan metadata kategori dan bookmark pada tabel chat, tabel baru untuk template dan export job
- **Performance**: Indeks teks pada kolom pencarian, caching template
- **Breaking changes**: Tidak ada

## Success Metrics

- Penurunan waktu rata-rata menemukan percakapan lama ≥ 50%
- Penggunaan template prompt ≥ 30% dari sesi baru
- Rata-rata bookmark per mahasiswa ≥ 5 dalam bulan pertama
- Ekspor berhasil tanpa error ≥ 99%
