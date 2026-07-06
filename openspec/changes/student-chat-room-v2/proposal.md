## Why

Chat room mahasiswa saat ini hanya mendukung pengiriman pesan satu arah — pesan yang sudah dikirim tidak bisa diubah atau dihapus. Diskusi akademik sering mengandung blok kode dan tautan referensi yang sulit dibaca dalam format teks biasa. Pesan penting yang perlu dirujuk kembali tenggelam di antara ratusan pesan lain.

Permasalahan utama:
- **Immutability**: Pesan yang salah ketik atau tidak akurat tidak bisa diperbaiki
- **Navigability**: Tidak ada cara mencari pesan spesifik dalam diskusi panjang
- **Discoverability**: Pesan penting/pin tidak tersedia, semua pesan memiliki bobot sama

## What Changes

### 1. Edit Pesan
Mahasiswa bisa mengedit pesan miliknya sendiri. Pesan yang diedit menampilkan status "Diedit" dengan timestamp edit terakhir.

### 2. Hapus Pesan
Mahasiswa bisa menghapus pesan miliknya. Moderator/owner ruang bisa menghapus pesan untuk moderasi. Sistem menyimpan jejak audit.

### 3. Pencarian Pesan
Pencarian server-side di dalam ruang chat dengan highlighted keyword pada hasil.

### 4. Pinning Pesan
Pesan penting bisa dipin dan ditampilkan di panel khusus di bagian atas ruang.

### EXCLUDED: Reactions
Fitur reaksi/emoticon pada pesan TIDAK termasuk dalam lingkup perubahan ini.

## Capabilities

### New Capabilities
- `student-chat-room-v2-edit-delete`: Edit dan hapus pesan milik sendiri
- `student-chat-room-v2-search`: Pencarian pesan dalam ruang chat
- `student-chat-room-v2-pinning`: Pin dan panel pesan penting

## User Stories

1. **Sebagai mahasiswa**, saya ingin mengedit pesan yang salah ketik sehingga informasi yang diberikan tetap akurat
2. **Sebagai mahasiswa**, saya ingin menghapus pesan yang tidak relevan sehingga diskusi tetap bersih
3. **Sebagai mahasiswa**, saya ingin mencari pesan tertentu dalam diskusi sehingga saya bisa menemukan topik yang pernah dibahas
4. **Sebagai mahasiswa**, saya ingin memin pesan penting sehingga saya bisa menemukannya dengan cepat

## Impact

- **Frontend**: Komponen daftar pesan, toolbar aksi, komponen preview link, panel pin, editor inline
- **Backend/API**: Endpoint edit/hapus/pin, query pencarian pesan, metadata fetcher untuk link preview
- **Security**: Sanitasi konten, validasi otorisasi edit/hapus, audit trail
- **Performance**: Cache metadata link preview, lazy load syntax highlighter
- **Breaking changes**: Tidak ada

## Success Metrics

- Rata-rata waktu menemukan pesan spesifik berkurang ≥ 60%
- Penggunaan fitur edit ≥ 10% dari total pesan terkirim
- Link preview dimanfaatkan ≥ 20% dari pesan berisi URL
- Tidak ada insiden keamanan terkait edit/hapus pesan
