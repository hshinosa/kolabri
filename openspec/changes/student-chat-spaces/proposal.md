## Why

Halaman Chat Spaces adalah entry point utama mahasiswa untuk mengakses ruang diskusi. Saat ini halaman menampilkan daftar ruang secara datar tanpa kemampuan pencarian, filter, atau preview aktivitas. Mahasiswa dengan banyak ruang diskusi kesulitan menemukan ruang yang relevan dan tidak tahu ruang mana yang memiliki aktivitas terbaru.

Permasalahan utama:
- **Navigability**: Tidak ada cara mencari ruang berdasarkan nama atau topik
- **Filtering**: Semua ruang ditampilkan tanpa opsi filter berdasarkan tipe atau status
- **Sorting**: Tidak ada cara mengurutkan ruang berdasarkan aktivitas atau abjad
- **Context**: Tidak ada preview aktivitas terakhir, mahasiswa harus membuka setiap ruang
- **Empty state**: Tampilan kosong tidak memberikan panduan untuk aksi selanjutnya

## What Changes

### 1. Pencarian Chat Space
Menambahkan kolom pencarian di bagian atas halaman untuk mencari ruang berdasarkan nama dan deskripsi.

### 2. Filter Ruang
Menambahkan filter berdasarkan tipe ruang (akademik, proyek, umum) dan status (aktif, tidak aktif).

### 3. Pengurutan
Menambahkan opsi pengurutan: terbaru, alfabet A-Z.

### 4. Preview Aktivitas
Menampilkan ringkasan aktivitas terakhir pada setiap kartu ruang (pesan terbaru, waktu aktivitas).

### 5. Empty State Kontekstual
Menampilkan empty state yang berbeda untuk setiap kondisi: belum punya ruang, hasil filter kosong, hasil pencarian kosong.

## Capabilities

### New Capabilities
- `student-chat-spaces-search`: Pencarian ruang berdasarkan nama dan deskripsi
- `student-chat-spaces-filter`: Filter berdasarkan tipe dan status ruang
- `student-chat-spaces-sort`: Pengurutan berdasarkan abjad
- `student-chat-spaces-preview`: Preview aktivitas terakhir per ruang
- `student-chat-spaces-empty-state`: Empty state kontekstual

## User Stories

1. **Sebagai mahasiswa**, saya ingin mencari ruang diskusi berdasarkan nama sehingga saya bisa menemukan ruang dengan cepat
2. **Sebagai mahasiswa**, saya ingin memfilter ruang berdasarkan tipe sehingga saya bisa fokus pada ruang akademik atau proyek
3. **Sebagai mahasiswa**, saya ingin mengurutkan ruang berdasarkan abjad sehingga saya bisa menemukan ruang dengan mudah
4. **Sebagai mahasiswa**, saya ingin melihat preview aktivitas terakhir sehingga saya tahu ruang mana yang memiliki diskusi baru
5. **Sebagai mahasiswa**, saya ingin melihat panduan saat tidak ada ruang sehingga saya tahu cara membuat atau bergabung ruang

## Impact

- **Frontend**: Halaman daftar spaces, komponen filter/sort/search, kartu ruang dengan preview, empty state
- **Backend/API**: Endpoint list spaces dengan query parameter (q, filter, sort, page)
- **Performance**: Agregasi aktivitas terakhir harus efisien untuk dataset besar
- **Breaking changes**: Tidak ada

## Success Metrics

- Penurunan waktu menemukan ruang yang relevan ≥ 40%
- Peningkatan engagement pada ruang yang sebelumnya jarang diakses ≥ 20%
- Rata-rata klik per sesi berkurang (lebih sedikit ruang yang salah dibuka)
- Empty state menghasilkan aksi (buat/gabung ruang) ≥ 30% dari tampilan
