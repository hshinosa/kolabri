# User Acceptance Testing (UAT) - Kolabri (Mahasiswa)

## Informasi Umum
- **Nama Sistem:** Kolabri
- **Target User:** Mahasiswa
- **Tanggal Testing:** ____________
- **Tester:** ____________
- **Versi:** ____________

## Petunjuk Pengisian
1. Centang (✓) pada kolom **Lolos** jika fitur berfungsi sesuai ekspektasi
2. Centang (✗) pada kolom **Gagal** jika fitur tidak berfungsi
3. Centang (-) pada kolom **N/A** jika fitur tidak diuji
4. Tulis catatan pada kolom **Keterangan** jika diperlukan

---

## 1. Autentikasi & Registrasi

### 1.1 Login
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 1.1.1 | Login dengan email & password valid | 1. Buka halaman login<br>2. Masukkan email valid<br>3. Masukkan password valid<br>4. Klik tombol Login | User berhasil login dan diarahkan ke dashboard | | | | |
| 1.1.2 | Login dengan email tidak valid | 1. Buka halaman login<br>2. Masukkan email tidak valid<br>3. Masukkan password<br>4. Klik tombol Login | Tampil pesan error "Email atau password salah" | | | | |
| 1.1.3 | Login dengan password salah | 1. Buka halaman login<br>2. Masukkan email valid<br>3. Masukkan password salah<br>4. Klik tombol Login | Tampil pesan error "Email atau password salah" | | | | |
| 1.1.4 | Login dengan Google | 1. Buka halaman login<br>2. Klik tombol "Login dengan Google"<br>3. Pilih akun Google<br>4. Berikan izin akses | User berhasil login dengan akun Google | | | | |
| 1.1.5 | Rate limiting login | 1. Coba login dengan password salah 5x berturut-turut | Akun terkunci sementara, tampil pesan "Terlalu banyak percobaan" | | | | |

### 1.2 Registrasi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 1.2.1 | Registrasi dengan data valid | 1. Buka halaman registrasi<br>2. Isi nama, email, password, konfirmasi password<br>3. Klik Daftar | Akun berhasil dibuat, user diarahkan ke halaman verifikasi email | | | | |
| 1.2.2 | Registrasi dengan email sudah terdaftar | 1. Buka halaman registrasi<br>2. Masukkan email yang sudah terdaftar<br>3. Klik Daftar | Tampil pesan error "Email sudah terdaftar" | | | | |
| 1.2.3 | Validasi password tidak cocok | 1. Buka halaman registrasi<br>2. Masukkan password dan konfirmasi yang berbeda<br>3. Klik Daftar | Tampil pesan error "Password tidak cocok" | | | | |

### 1.3 Forgot Password
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 1.3.1 | Request reset password | 1. Klik "Lupa password"<br>2. Masukkan email terdaftar<br>3. Klik "Kirim Link Reset" | Email reset terkirim, tampil pesan konfirmasi | | | | |
| 1.3.2 | Reset password dengan token valid | 1. Buka link dari email<br>2. Masukkan password baru<br>3. Klik "Reset Password" | Password berhasil direset, user bisa login dengan password baru | | | | |

### 1.4 Logout
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 1.4.1 | Logout dari sistem | 1. Klik profil/avatar<br>2. Klik "Logout" | User berhasil logout dan diarahkan ke halaman login | | | | |

---

## 2. Dashboard

### 2.1 Dashboard Utama
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 2.1.1 | Melihat dashboard | 1. Login sebagai mahasiswa<br>2. Akses halaman dashboard | Dashboard tampil dengan informasi: daftar kelas, aktivitas terbaru, notifikasi | | | | |
| 2.1.2 | Navigasi ke kelas | 1. Di dashboard, klik salah satu kelas | User diarahkan ke halaman detail kelas | | | | |
| 2.1.3 | Melihat notifikasi | 1. Klik ikon notifikasi di header | Dropdown notifikasi muncul dengan daftar notifikasi terbaru | | | | |
| 2.1.4 | Menandai notifikasi sudah dibaca | 1. Buka dropdown notifikasi<br>2. Klik salah satu notifikasi | Notifikasi ditandai sebagai sudah dibaca | | | | |

---

## 3. Courses (Kelas)

### 3.1 Daftar Kelas
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 3.1.1 | Melihat daftar kelas yang diikuti | 1. Navigasi ke /student/courses | Daftar kelas yang diikuti tampil | | | | |
| 3.1.2 | Melihat detail kelas | 1. Klik salah satu kelas dari daftar | Halaman detail kelas tampil dengan informasi: grup, sesi diskusi, materi | | | | |

### 3.2 Join Kelas
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 3.2.1 | Join kelas dengan kode valid | 1. Klik "Join Kelas"<br>2. Masukkan kode kelas valid<br>3. Klik "Join" | User berhasil bergabung dengan kelas | | | | |
| 3.2.2 | Join kelas dengan kode tidak valid | 1. Klik "Join Kelas"<br>2. Masukkan kode kelas tidak valid<br>3. Klik "Join" | Tampil pesan error "Kode kelas tidak valid" | | | | |

### 3.3 Course Weeks (Minggu Perkuliahan)
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 3.3.1 | Melihat daftar minggu | 1. Di halaman detail kelas, navigasi ke tab Minggu | Daftar minggu perkuliahan tampil | | | | |
| 3.3.2 | Melihat materi per minggu | 1. Klik salah satu minggu | Daftar materi untuk minggu tersebut tampil | | | | |

---

## 4. Groups (Kelompok)

### 4.1 Membuat Grup
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.1.1 | Membuat grup baru | 1. Di halaman detail kelas, klik "Buat Grup"<br>2. Isi nama grup<br>3. Klik "Buat" | Grup berhasil dibuat, user otomatis menjadi ketua | | | | |
| 4.1.2 | Validasi nama grup kosong | 1. Klik "Buat Grup"<br>2. Kosongkan nama grup<br>3. Klik "Buat" | Tampil pesan error "Nama grup wajib diisi" | | | | |

### 4.2 Join Grup
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.2.1 | Join grup dengan kode undangan | 1. Klik "Join Grup"<br>2. Masukkan kode undangan valid<br>3. Klik "Join" | User berhasil bergabung dengan grup | | | | |
| 4.2.2 | Join grup dengan kode tidak valid | 1. Klik "Join Grup"<br>2. Masukkan kode tidak valid<br>3. Klik "Join" | Tampil pesan error "Kode undangan tidak valid" | | | | |

### 4.3 Detail Grup
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.3.1 | Melihat detail grup | 1. Navigasi ke halaman grup | Detail grup tampil: nama, anggota, ketua, kode undangan | | | | |
| 4.3.2 | Melihat daftar anggota | 1. Di halaman grup, scroll ke bagian anggota | Daftar anggota grup tampil dengan nama dan role | | | | |
| 4.3.3 | Copy kode undangan | 1. Klik tombol copy di samping kode undangan | Kode undangan tersalin ke clipboard | | | | |

### 4.4 Manajemen Anggota (Ketua Grup)
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.4.1 | Mengubah role anggota | 1. Sebagai ketua, klik menu anggota<br>2. Ubah role anggota | Role anggota berhasil diubah | | | | |
| 4.4.2 | Mengeluarkan anggota (kick) | 1. Sebagai ketua, klik menu anggota<br>2. Klik "Keluarkan" pada anggota | Anggota berhasil dikeluarkan dari grup | | | | |
| 4.4.3 | Mengundang anggota baru | 1. Sebagai ketua, klik "Undang Anggota"<br>2. Masukkan email anggota<br>3. Klik "Undang" | Undangan terkirim ke email anggota | | | | |

### 4.5 Keluar dari Grup
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.5.1 | Keluar dari grup (anggota biasa) | 1. Klik "Keluar dari Grup"<br>2. Konfirmasi | User berhasil keluar dari grup | | | | |
| 4.5.2 | Ketua tidak bisa keluar | 1. Sebagai ketua, cek tombol "Keluar dari Grup" | Tombol tidak tersedia atau ada peringatan harus menunjuk ketua baru | | | | |

### 4.6 Aktivitas Grup
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.6.1 | Melihat aktivitas grup | 1. Navigasi ke tab Aktivitas di halaman grup | Daftar aktivitas grup tampil (join, leave, create chat space, dll) | | | | |

---

## 5. Chat Spaces (Ruang Diskusi)

### 5.1 Masuk ke Chat Room
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.1.1 | Masuk ke chat room | 1. Dari halaman kelas/grup, klik chat space | Chat room terbuka dengan daftar pesan | | | | |
| 5.1.2 | Koneksi real-time | 1. Masuk ke chat room<br>2. Kirim pesan | Pesan langsung muncul di chat room (real-time) | | | | |
| 5.1.3 | Connection banner | 1. Masuk ke chat room<br>2. Cek status koneksi | Banner koneksi tampil (connected/reconnecting/disconnected) | | | | |

### 5.2 Mengirim Pesan
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.2.1 | Kirim pesan teks | 1. Ketik pesan di input box<br>2. Klik Send atau tekan Enter | Pesan terkirim dan muncul di chat | | | | |
| 5.2.2 | Kirim pesan kosong | 1. Klik Send tanpa mengetik apapun | Pesan tidak terkirim, input tetap kosong | | | | |
| 5.2.3 | Upload file | 1. Klik ikon attachment<br>2. Pilih file<br>3. Kirim | File berhasil diupload dan muncul di chat | | | | |
| 5.2.4 | Upload file terlalu besar | 1. Upload file > 10MB | Tampil pesan error "File terlalu besar" | | | | |

### 5.3 Edit & Hapus Pesan
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.3.1 | Edit pesan sendiri | 1. Klik menu pada pesan sendiri<br>2. Pilih "Edit"<br>3. Ubah teks<br>4. Simpan | Pesan berhasil diedit, muncul label "(edited)" | | | | |
| 5.3.2 | Hapus pesan sendiri | 1. Klik menu pada pesan sendiri<br>2. Pilih "Hapus"<br>3. Konfirmasi | Pesan berhasil dihapus | | | | |
| 5.3.3 | Tidak bisa edit pesan orang lain | 1. Klik menu pada pesan orang lain | Opsi "Edit" tidak tersedia | | | | |

### 5.4 Pin Pesan
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.4.1 | Pin pesan | 1. Klik menu pada pesan<br>2. Pilih "Pin" | Pesan di-pin dan muncul di bagian pinned messages | | | | |
| 5.4.2 | Unpin pesan | 1. Klik menu pada pesan yang sudah di-pin<br>2. Pilih "Unpin" | Pesan di-unpin dan hilang dari pinned messages | | | | |
| 5.4.3 | Melihat daftar pinned messages | 1. Klik ikon pin di header chat | Daftar pesan yang di-pin tampil | | | | |

### 5.5 Search Pesan
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.5.1 | Search pesan | 1. Klik ikon search<br>2. Ketik keyword<br>3. Enter | Hasil search tampil dengan pesan yang mengandung keyword | | | | |
| 5.5.2 | Search dengan keyword tidak ada | 1. Search dengan keyword yang tidak ada di chat | Tampil pesan "Tidak ada hasil ditemukan" | | | | |

### 5.6 Tutup Sesi Diskusi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.6.1 | Tutup sesi diskusi | 1. Klik "Tutup Sesi"<br>2. Konfirmasi | Sesi ditutup, chat room menjadi read-only | | | | |
| 5.6.2 | Lihat summary sesi | 1. Setelah sesi ditutup, klik "Lihat Summary" | Summary sesi tampil dengan ringkasan diskusi | | | | |

---

## 6. Pre-read (Materi Sebelum Sesi)

### 6.1 Melihat Pre-read
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 6.1.1 | Akses pre-read | 1. Dari halaman kelas, klik sesi yang memiliki pre-read | Halaman pre-read tampil dengan daftar materi | | | | |
| 6.1.2 | Buka materi PDF | 1. Klik materi PDF | PDF viewer terbuka dengan dokumen | | | | |
| 6.1.3 | Buka materi video | 1. Klik materi video | Video player terbuka | | | | |

### 6.2 Menyelesaikan Pre-read
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 6.2.1 | Tandai pre-read selesai | 1. Setelah melihat semua materi, klik "Selesai" | Pre-read ditandai selesai, user bisa lanjut ke sesi diskusi | | | | |
| 6.2.2 | Pre-read belum selesai | 1. Coba akses sesi diskusi tanpa menyelesaikan pre-read | User diarahkan kembali ke halaman pre-read | | | | |

---

## 7. Goals (Tujuan Pembelajaran)

### 7.1 Membuat Goal
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 7.1.1 | Membuat goal baru | 1. Dari chat space, klik "Buat Tujuan"<br>2. Isi tujuan pembelajaran<br>3. Klik "Simpan" | Goal berhasil dibuat dan tersimpan | | | | |
| 7.1.2 | Edit goal | 1. Klik goal yang sudah dibuat<br>2. Ubah teks<br>3. Simpan | Goal berhasil diubah | | | | |

---

## 8. Reflections (Refleksi)

### 8.1 Membuat Refleksi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 8.1.1 | Membuat refleksi baru | 1. Navigasi ke /student/reflections<br>2. Klik "Refleksi Baru"<br>3. Isi judul dan konten<br>4. Klik "Simpan" | Refleksi berhasil disimpan | | | | |
| 8.1.2 | Refleksi dengan template | 1. Klik "Refleksi Baru"<br>2. Pilih template<br>3. Isi sesuai template<br>4. Simpan | Refleksi tersimpan dengan struktur template | | | | |
| 8.1.3 | Tambah tag pada refleksi | 1. Buat refleksi<br>2. Tambah tag (misal: "belajar", "diskusi")<br>3. Simpan | Tag tersimpan dan muncul di refleksi | | | | |

### 8.2 Melihat Daftar Refleksi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 8.2.1 | Melihat semua refleksi | 1. Navigasi ke /student/reflections | Daftar semua refleksi tampil | | | | |
| 8.2.2 | Filter refleksi berdasarkan tag | 1. Klik tag di filter | Refleksi dengan tag tersebut tampil | | | | |
| 8.2.3 | Search refleksi | 1. Ketik keyword di search box | Refleksi yang mengandung keyword tampil | | | | |

### 8.3 Template Refleksi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 8.4.1 | Membuat template refleksi | 1. Navigasi ke tab "Template"<br>2. Klik "Template Baru"<br>3. Isi nama dan pertanyaan<br>4. Simpan | Template berhasil dibuat | | | | |
| 8.4.2 | Edit template | 1. Klik template yang ada<br>2. Klik "Edit"<br>3. Ubah pertanyaan<br>4. Simpan | Template berhasil diubah | | | | |
| 8.4.3 | Hapus template | 1. Klik template<br>2. Klik "Hapus"<br>3. Konfirmasi | Template berhasil dihapus | | | | |

---

## 9. AI Chat

### 9.1 Percakapan AI
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.1.1 | Membuat chat baru | 1. Navigasi ke /student/ai-chat<br>2. Klik "Chat Baru" | Chat baru dibuat dan siap untuk percakapan | | | | |
| 9.1.2 | Kirim pesan ke AI | 1. Ketik pertanyaan di input box<br>2. Klik Send | AI membalas dengan streaming response | | | | |
| 9.1.3 | Streaming response | 1. Kirim pesan ke AI<br>2. Perhatikan response | Response muncul secara streaming (typewriter effect) | | | | |
| 9.1.4 | Response dengan markdown | 1. Tanya sesuatu yang butuh formatting (list, code, table) | Response AI ter-render dengan markdown yang benar | | | | |

### 9.2 Manajemen Chat
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.2.1 | Lihat riwayat chat | 1. Klik ikon menu/hamburger di AI chat | Sidebar riwayat chat muncul dengan daftar chat lama | | | | |
| 9.2.2 | Buka chat lama | 1. Klik salah satu chat di sidebar | Chat lama terbuka dengan riwayat percakapan | | | | |
| 9.2.3 | Rename chat | 1. Klik menu pada chat<br>2. Pilih "Rename"<br>3. Ubah nama<br>4. Simpan | Nama chat berhasil diubah | | | | |
| 9.2.4 | Hapus chat | 1. Klik menu pada chat<br>2. Pilih "Hapus"<br>3. Konfirmasi | Chat berhasil dihapus | | | | |

### 9.3 Saved Materials (Materi Tersimpan)
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.3.1 | Simpan materi dari AI response | 1. AI memberikan response dengan sitasi materi<br>2. Klik ikon bookmark pada sitasi | Materi tersimpan, ikon berubah menjadi filled | | | | |
| 9.3.2 | Lihat daftar materi tersimpan | 1. Klik ikon bookmark di header AI chat | Panel materi tersimpan terbuka dengan daftar materi | | | | |
| 9.3.3 | Buka materi tersimpan | 1. Di panel materi tersimpan, klik salah satu materi | Materi terbuka di tab baru | | | | |
| 9.3.4 | Hapus materi tersimpan | 1. Di panel materi tersimpan, klik ikon trash pada materi | Materi dihapus dari daftar tersimpan | | | | |

### 9.4 Search di AI Chat
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.4.1 | Search percakapan AI | 1. Klik ikon search di AI chat<br>2. Ketik keyword<br>3. Enter | Hasil search tampil dengan percakapan yang mengandung keyword | | | | |

---

## 10. Profile (Profil)

### 10.1 Melihat Profil
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 10.1.1 | Melihat profil | 1. Navigasi ke /student/profile | Halaman profil tampil dengan informasi user | | | | |
| 10.1.2 | Melihat statistik | 1. Klik tab "Statistik" di profil | Statistik user tampil (jumlah refleksi, chat, dll) | | | | |

### 10.2 Edit Profil
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 10.2.1 | Edit nama | 1. Klik "Edit Profil"<br>2. Ubah nama<br>3. Simpan | Nama berhasil diubah | | | | |
| 10.2.2 | Upload avatar | 1. Klik avatar/foto profil<br>2. Pilih file gambar<br>3. Upload | Avatar berhasil diupload dan tampil | | | | |
| 10.2.3 | Hapus avatar | 1. Klik avatar<br>2. Pilih "Hapus Avatar" | Avatar dihapus, kembali ke default | | | | |

### 10.3 Preferences
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 10.3.1 | Ubah preferensi notifikasi | 1. Navigasi ke preferensi<br>2. Ubah setting notifikasi<br>3. Simpan | Preferensi notifikasi berhasil diubah | | | | |

---

## 11. Global Search

### 11.1 Pencarian Global
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 11.1.1 | Search dari header | 1. Klik ikon search di header<br>2. Ketik keyword | Hasil search dari berbagai sumber (kelas, grup, refleksi, dll) tampil | | | | |
| 11.1.2 | Filter hasil search | 1. Setelah search, klik filter (kelas/grup/refleksi) | Hasil di-filter sesuai kategori | | | | |

---

## Ringkasan Testing

| Modul | Total Test | Lolos | Gagal | N/A |
|-------|------------|-------|-------|-----|
| 1. Autentikasi & Registrasi | 10 | | | |
| 2. Dashboard | 4 | | | |
| 3. Courses | 6 | | | |
| 4. Groups | 12 | | | |
| 5. Chat Spaces | 15 | | | |
| 6. Pre-read | 5 | | | |
| 7. Goals | 2 | | | |
| 8. Reflections | 9 | | | |
| 9. AI Chat | 12 | | | |
| 10. Profile | 7 | | | |
| 11. Global Search | 2 | | | |
| **TOTAL** | **84** | | | |

## Catatan & Rekomendasi
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________

## Tanda Tangan

| | Nama | Tanggal | Tanda Tangan |
|--|------|---------|--------------|
| Tester | | | |
| Developer | | | |
| Product Owner | | | |
