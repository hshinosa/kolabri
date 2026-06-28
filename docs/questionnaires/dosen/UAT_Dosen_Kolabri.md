# User Acceptance Testing (UAT) - Kolabri (Dosen)

## Informasi Umum
- **Nama Sistem:** Kolabri
- **Target User:** Dosen (Lecturer)
- **Tanggal Testing:** ____________
- **Tester:** ____________
- **Versi:** ____________

## Petunjuk Pengisian
1. Centang (✓) pada kolom **Lolos** jika fitur berfungsi sesuai ekspektasi
2. Centang (✗) pada kolom **Gagal** jika fitur tidak berfungsi
3. Centang (-) pada kolom **N/A** jika fitur tidak diuji
4. Tulis catatan pada kolom **Keterangan** jika diperlukan

---

## 🎯 Task Scenarios (Alur Utama untuk Dosen)

Ikuti skenario berikut secara berurutan untuk testing yang sistematis:

### Skenario 1: Setup Awal Kelas
**Tujuan:** Membuat kelas baru dan mengatur konfigurasi grup
1. Login sebagai dosen
2. Buat kelas baru dengan kode, nama, dan konfigurasi anggota grup
3. Bagikan kode kelas ke mahasiswa
4. Tunggu mahasiswa join kelas

### Skenario 2: Manajemen Kelas & Materi
**Tujuan:** Mengelola minggu perkuliahan dan materi pembelajaran
5. Akses halaman detail kelas
6. Buat minggu perkuliahan (week)
7. Upload materi (PDF/DOCX/PPTX) ke minggu tertentu
8. Tunggu proses indexing materi selesai (status: ready)
9. Atur ulang urutan minggu dengan drag-and-drop

### Skenario 3: Manajemen Grup
**Tujuan:** Mengatur kelompok mahasiswa dan ruang diskusi
10. Buat grup baru
11. Assign anggota ke grup
12. Buat chat space untuk grup (bind ke week tertentu)
13. Copy kode join grup untuk dibagikan

### Skenario 4: Monitoring Diskusi
**Tujuan:** Memantau jalannya diskusi mahasiswa secara real-time
14. Masuk ke chat room sebagai dosen
15. Kirim pesan sebagai dosen
16. Pantau discussion health widget (HOT%, Lexical Variety, Collaboration)
17. Lihat escalation alerts jika ada
18. Lihat aktivitas mahasiswa di tab Aktivitas

### Skenario 5: Tutup Sesi & Summary
**Tujuan:** Mengakhiri sesi diskusi dan mendapatkan ringkasan
19. Tutup sesi diskusi
20. Lihat summary sesi (auto-generated)
21. Jika summary gagal, sistem auto-retry
22. Buka kembali sesi jika diperlukan

### Skenario 6: Analytics & Evaluasi
**Tujuan:** Menganalisis performa mahasiswa dan kualitas diskusi
23. Akses halaman Analytics Overview
24. Lihat quality scores per kelas (color-coded)
25. Buka detail analytics kelas
26. Lihat radar chart (HOT/Lexical Variety/Collaboration/Reflection)
27. Bandingkan antar kelas (max 3 kelas)
28. Export data analytics ke CSV/PDF

### Skenario 7: AI Settings & Testing
**Tujuan:** Mengkonfigurasi AI dan melakukan testing prompt
29. Akses AI Settings
30. Test prompt dengan AI Preview
31. Buat preset AI configuration
32. Setup A/B testing untuk prompt variants

### Skenario 8: Attendance Tracking
**Tujuan:** Mengelola kehadiran mahasiswa
33. Buat session kehadiran
34. Tandai status kehadiran (absent/present/late/excused)
35. Lihat summary kehadiran per mahasiswa
36. Export data kehadiran ke CSV

---

## 1. Autentikasi & Registrasi

### 1.1 Login
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 1.1.1 | Login dengan email & password valid | 1. Buka halaman login<br>2. Masukkan email dosen valid<br>3. Masukkan password valid<br>4. Klik tombol Login | User berhasil login dan diarahkan ke dashboard dosen | | | | |
| 1.1.2 | Login dengan email tidak valid | 1. Buka halaman login<br>2. Masukkan email tidak valid<br>3. Masukkan password<br>4. Klik tombol Login | Tampil pesan error "Email atau password salah" | | | | |
| 1.1.3 | Login dengan password salah | 1. Buka halaman login<br>2. Masukkan email valid<br>3. Masukkan password salah<br>4. Klik tombol Login | Tampil pesan error "Email atau password salah" | | | | |
| 1.1.4 | Login dengan Google | 1. Buka halaman login<br>2. Klik tombol "Login dengan Google"<br>3. Pilih akun Google<br>4. Berikan izin akses | User berhasil login dengan akun Google | | | | |
| 1.1.5 | Rate limiting login | 1. Coba login dengan password salah 5x berturut-turut | Akun terkunci sementara, tampil pesan "Terlalu banyak percobaan" | | | | |

### 1.2 Registrasi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 1.2.1 | Registrasi dengan data valid | 1. Buka halaman registrasi<br>2. Isi nama, email, password, konfirmasi password<br>3. Klik Daftar | Akun berhasil dibuat, user diarahkan ke halaman verifikasi email | | | | |
| 1.2.2 | Registrasi dengan email sudah terdaftar | 1. Buka halaman registrasi<br>2. Masukkan email yang sudah terdaftar<br>3. Klik Daftar | Tampil pesan error "Email sudah terdaftar" | | | | |

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

## 2. Dashboard Dosen

### 2.1 Dashboard Utama
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 2.1.1 | Melihat dashboard dosen | 1. Login sebagai dosen<br>2. Akses halaman dashboard | Dashboard tampil dengan: stat cards (active classes, total students, groups, courses needing attention), live activity feed, discussion health widget | | | | |
| 2.1.2 | Live activity feed | 1. Di dashboard, perhatikan activity feed | Activity feed update real-time via WebSocket saat ada aktivitas baru | | | | |
| 2.1.3 | Escalation alerts | 1. Jika ada diskusi yang perlu intervensi, lihat escalation alerts | Alert muncul dengan severity level dan tombol dismiss | | | | |
| 2.1.4 | Quick action links | 1. Klik quick action "Create Course" | User diarahkan ke halaman create course | | | | |
| 2.1.5 | Discussion health widget | 1. Lihat discussion health widget | Widget menampilkan status diskusi aktif dengan color-coded quality scores | | | | |

---

## 3. Courses (Kelas)

### 3.1 Daftar Kelas
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 3.1.1 | Melihat daftar kelas | 1. Navigasi ke halaman daftar kelas | Daftar kelas tampil dalam grid dengan kode, nama, dan statistik | | | | |
| 3.1.2 | Search kelas | 1. Ketik keyword di search bar | Kelas di-filter sesuai keyword | | | | |
| 3.1.3 | Filter kelas | 1. Gunakan filter (status, date range) | Kelas di-filter sesuai kriteria | | | | |
| 3.1.4 | Bulk archive kelas | 1. Aktifkan selection mode<br>2. Pilih beberapa kelas<br>3. Klik "Archive"<br>4. Konfirmasi | Kelas terpilih berhasil di-archive | | | | |

### 3.2 Membuat Kelas
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 3.2.1 | Membuat kelas baru | 1. Klik "Buat Kelas"<br>2. Isi kode kelas (auto uppercase)<br>3. Isi nama kelas<br>4. Set min/max anggota per grup<br>5. Klik "Buat" | Kelas berhasil dibuat, user diarahkan ke halaman detail kelas | | | | |
| 3.2.2 | Validasi form | 1. Klik "Buat Kelas"<br>2. Kosongkan field wajib<br>3. Klik "Buat" | Tampil pesan error validasi | | | | |

### 3.3 Detail Kelas
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 3.3.1 | Melihat detail kelas | 1. Klik salah satu kelas | Halaman detail tampil dengan tab (Aktivitas/Attendance/Materials) dan stat cards | | | | |
| 3.3.2 | Lihat kode join mahasiswa | 1. Di halaman detail, cari kode join | Kode join tampil dan bisa di-copy | | | | |
| 3.3.3 | Navigasi ke analytics | 1. Klik link "Analytics" | User diarahkan ke halaman analytics kelas | | | | |

### 3.4 Course Weeks (Minggu Perkuliahan)
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 3.4.1 | Membuat minggu | 1. Klik "Tambah Minggu"<br>2. Isi judul minggu<br>3. Klik "Simpan" | Minggu berhasil dibuat | | | | |
| 3.4.2 | Reorder minggu | 1. Drag-and-drop minggu ke posisi baru | Urutan minggu berhasil diubah | | | | |
| 3.4.3 | Edit minggu | 1. Klik menu minggu<br>2. Pilih "Edit"<br>3. Ubah judul<br>4. Simpan | Minggu berhasil diubah | | | | |
| 3.4.4 | Hapus minggu | 1. Klik menu minggu<br>2. Pilih "Hapus"<br>3. Konfirmasi | Minggu berhasil dihapus | | | | |

### 3.5 Upload & Manajemen Materi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 3.5.1 | Upload materi | 1. Klik "Upload Materi"<br>2. Drag-drop atau pilih file (PDF/DOCX/PPTX/ZIP)<br>3. Klik "Upload" | Materi berhasil diupload, status: pending | | | | |
| 3.5.2 | Multi-file upload | 1. Upload beberapa file sekaligus | Semua file berhasil diupload | | | | |
| 3.5.3 | Monitoring indexing status | 1. Lihat status materi (pending/processing/ready/failed) | Status update real-time sesuai progress indexing | | | | |
| 3.5.4 | Reindex materi | 1. Klik menu materi<br>2. Pilih "Reindex" | Materi di-index ulang | | | | |
| 3.5.5 | Hapus materi | 1. Klik menu materi<br>2. Pilih "Hapus"<br>3. Konfirmasi | Materi berhasil dihapus | | | | |
| 3.5.6 | Lihat KB indexing stats | 1. Lihat statistik indexing | Statistik tampil (total materi, ready, processing, failed) | | | | |

---

## 4. Groups (Kelompok)

### 4.1 Membuat Grup
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.1.1 | Membuat grup baru | 1. Klik "Buat Grup"<br>2. Isi nama grup<br>3. Klik "Buat" | Grup berhasil dibuat | | | | |
| 4.1.2 | Lihat stat cards grup | 1. Di halaman grup, lihat stat cards | Stat cards tampil (total groups, assigned students, unassigned, chat spaces) | | | | |

### 4.2 Assign Anggota
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.2.1 | Assign mahasiswa ke grup | 1. Klik "Assign Members"<br>2. Toggle mahasiswa yang ingin di-assign<br>3. Klik "Save" | Mahasiswa berhasil di-assign ke grup | | | | |
| 4.2.2 | Unassign mahasiswa | 1. Klik "Assign Members"<br>2. Toggle mahasiswa yang sudah di-assign<br>3. Klik "Save" | Mahasiswa berhasil di-unassign | | | | |

### 4.3 Chat Spaces
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 4.3.1 | Buat chat space | 1. Klik "Create Chat Space"<br>2. Isi nama chat space<br>3. Pilih week binding (optional)<br>4. Klik "Create" | Chat space berhasil dibuat | | | | |
| 4.3.2 | Copy join code | 1. Klik tombol copy di samping join code | Join code tersalin ke clipboard | | | | |
| 4.3.3 | Hapus grup | 1. Klik menu grup<br>2. Pilih "Delete"<br>3. Konfirmasi | Grup berhasil dihapus | | | | |

---

## 5. Chat Spaces (Ruang Diskusi)

### 5.1 Masuk ke Chat Room
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.1.1 | Masuk ke chat room | 1. Dari halaman grup, klik chat space | Chat room terbuka dengan daftar pesan | | | | |
| 5.1.2 | Koneksi real-time | 1. Masuk ke chat room<br>2. Kirim pesan | Pesan langsung muncul (real-time via WebSocket) | | | | |
| 5.1.3 | Connection banner | 1. Perhatikan banner koneksi | Banner tampil (connected/reconnecting/disconnected) | | | | |

### 5.2 Mengirim Pesan
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.2.1 | Kirim pesan teks | 1. Ketik pesan di input box<br>2. Klik Send atau tekan Enter | Pesan terkirim dan muncul di chat | | | | |
| 5.2.2 | Kirim pesan kosong | 1. Klik Send tanpa mengetik | Pesan tidak terkirim | | | | |
| 5.2.3 | Upload file | 1. Klik ikon attachment<br>2. Pilih file<br>3. Kirim | File berhasil diupload dan muncul di chat | | | | |

### 5.3 Edit & Hapus Pesan
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.3.1 | Edit pesan sendiri | 1. Klik menu pada pesan sendiri<br>2. Pilih "Edit"<br>3. Ubah teks<br>4. Simpan | Pesan berhasil diedit, muncul label "(edited)" | | | | |
| 5.3.2 | Hapus pesan sendiri | 1. Klik menu pada pesan sendiri<br>2. Pilih "Hapus"<br>3. Konfirmasi | Pesan berhasil dihapus | | | | |

### 5.4 Pin Pesan
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.4.1 | Pin pesan | 1. Klik menu pada pesan<br>2. Pilih "Pin" | Pesan di-pin dan muncul di pinned messages | | | | |
| 5.4.2 | Unpin pesan | 1. Klik menu pada pesan yang di-pin<br>2. Pilih "Unpin" | Pesan di-unpin | | | | |
| 5.4.3 | Lihat daftar pinned | 1. Klik ikon pin di header | Daftar pesan yang di-pin tampil | | | | |

### 5.5 Search Pesan
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.5.1 | Search pesan | 1. Klik ikon search<br>2. Ketik keyword<br>3. Enter | Hasil search tampil dengan highlight keyword | | | | |

### 5.6 Tutup & Buka Kembali Sesi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 5.6.1 | Tutup sesi diskusi | 1. Klik "Tutup Sesi"<br>2. Konfirmasi | Sesi ditutup, chat room menjadi read-only | | | | |
| 5.6.2 | Lihat summary sesi | 1. Setelah sesi ditutup, lihat summary | Summary tampil dengan ringkasan diskusi | | | | |
| 5.6.3 | Summary auto-retry | 1. Jika summary gagal di-generate, sistem auto-retry | Toast "Ringkasan sedang dibuat ulang..." muncul, kemudian summary berhasil dibuat | | | | |
| 5.6.4 | Buka kembali sesi | 1. Klik "Buka Kembali Sesi"<br>2. Konfirmasi | Sesi dibuka kembali, chat room aktif | | | | |

---

## 6. Discussion Monitoring (Monitoring Diskusi)

### 6.1 Discussion Health Widget
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 6.1.1 | Lihat discussion health | 1. Di chat room, lihat discussion health widget | Widget menampilkan metrik: HOT%, Lexical Variety, Collaboration, Reflection | | | | |
| 6.1.2 | Color-coded quality | 1. Perhatikan warna quality score | Warna sesuai status (green=good, yellow=warning, red=intervention) | | | | |

### 6.2 Escalation Alerts
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 6.2.1 | Lihat escalation alert | 1. Jika ada diskusi yang perlu intervensi, alert muncul | Alert tampil dengan severity level | | | | |
| 6.2.2 | Dismiss alert | 1. Klik tombol dismiss pada alert | Alert di-dismiss | | | | |

### 6.3 Tab Aktivitas
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 6.3.1 | Lihat tab aktivitas | 1. Di halaman detail kelas, klik tab "Aktivitas" | Tab aktivitas tampil dengan summary stats | | | | |
| 6.3.2 | Sort tabel mahasiswa | 1. Klik header kolom (total messages/frequency/last activity) | Tabel di-sort sesuai kolom | | | | |
| 6.3.3 | Search mahasiswa | 1. Ketik nama di search filter | Mahasiswa di-filter sesuai nama | | | | |
| 6.3.4 | Lihat activity indicator | 1. Lihat activity indicator bars | Bars menampilkan level aktivitas per mahasiswa | | | | |

---

## 7. Attendance (Kehadiran)

### 7.1 Membuat Session Kehadiran
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 7.1.1 | Buat session kehadiran | 1. Klik tab "Attendance"<br>2. Klik "Create Session"<br>3. Isi judul, tanggal, nomor sesi<br>4. Klik "Create" | Session kehadiran berhasil dibuat | | | | |

### 7.2 Menandai Kehadiran
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 7.2.1 | Toggle status kehadiran | 1. Klik session<br>2. Toggle status mahasiswa (absent/present/late/excused) | Status berubah dengan chip styling yang sesuai | | | | |

### 7.3 Summary & Export
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 7.3.1 | Lihat summary kehadiran | 1. Klik view mode "Summary" | Summary per mahasiswa tampil | | | | |
| 7.3.2 | Export kehadiran | 1. Klik "Export CSV" | File CSV berhasil di-download | | | | |

---

## 8. Session Management (Manajemen Sesi)

### 8.1 Daftar Sesi
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 8.1.1 | Lihat daftar sesi | 1. Navigasi ke halaman session management | Daftar sesi tampil dengan status badges (active/scheduled/template) | | | | |
| 8.1.2 | Filter sesi | 1. Klik tab filter (active/scheduled/templates) | Sesi di-filter sesuai tab | | | | |
| 8.1.3 | Search sesi | 1. Ketik keyword di search bar | Sesi di-filter sesuai keyword | | | | |

### 8.2 Bulk Actions
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 8.2.1 | Bulk close sesi | 1. Pilih beberapa sesi<br>2. Klik action dropdown "Close"<br>3. Konfirmasi | Sesi terpilih berhasil ditutup | | | | |
| 8.2.2 | Bulk archive sesi | 1. Pilih beberapa sesi<br>2. Klik action dropdown "Archive"<br>3. Konfirmasi | Sesi terpilih berhasil di-archive | | | | |

### 8.3 Session Templates
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 8.3.1 | Buat template | 1. Klik tab "Templates"<br>2. Klik "Create Template"<br>3. Isi nama dan konfigurasi<br>4. Klik "Save" | Template berhasil dibuat | | | | |
| 8.3.2 | Edit template | 1. Klik template<br>2. Klik "Edit"<br>3. Ubah konfigurasi<br>4. Klik "Save" | Template berhasil diubah | | | | |
| 8.3.3 | Hapus template | 1. Klik template<br>2. Klik "Delete"<br>3. Konfirmasi | Template berhasil dihapus | | | | |

---

## 9. Analytics (Analitik)

### 9.1 Analytics Overview
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.1.1 | Lihat overview | 1. Navigasi ke Analytics Overview | Daftar kelas tampil sebagai cards dengan quality badges (color-coded) | | | | |
| 9.1.2 | Attention flags | 1. Perhatikan kelas yang perlu perhatian | Attention flags muncul pada kelas dengan quality rendah | | | | |

### 9.2 Course Analytics
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.2.1 | Lihat detail analytics | 1. Klik salah satu kelas | Halaman detail analytics tampil dengan date range picker dan trend charts | | | | |
| 9.2.2 | Filter date range | 1. Pilih date range atau preset (week/month/semester) | Analytics di-filter untuk periode terpilih | | | | |
| 9.2.3 | Toggle benchmark | 1. Toggle benchmark on/off | Benchmark comparison tampil/hilang | | | | |
| 9.2.4 | Lihat trend chart | 1. Perhatikan trend chart | Chart menampilkan metrik (quality/HOT%/engagement/lexical variety) | | | | |
| 9.2.5 | Drill-down ke mahasiswa | 1. Klik mahasiswa di breakdown list | Halaman analytics mahasiswa tampil | | | | |

### 9.3 Group Analytics
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.3.1 | Lihat group analytics | 1. Klik salah satu grup | Halaman group analytics tampil dengan quality score dan label | | | | |
| 9.3.2 | Lihat radar chart | 1. Perhatikan radar chart | Radar chart menampilkan 6 metrik (HOT/Lexical Variety/Forethought/Performance/Collaboration/Reflection) | | | | |
| 9.3.3 | Lihat engagement distribution | 1. Perhatikan engagement breakdown | Engagement distribution per tipe tampil | | | | |
| 9.3.4 | Lihat recent activity | 1. Scroll ke recent activity | Activity stream tampil dengan intervention flags | | | | |

### 9.4 Radar Chart Page
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.4.1 | Akses radar chart | 1. Navigasi ke Radar Chart page | Halaman radar chart tampil dengan scope tabs (class/group/student/session) | | | | |
| 9.4.2 | Switch scope | 1. Klik tab scope (class/group/student/session) | Selector sidebar update sesuai scope | | | | |
| 9.4.3 | Select entity | 1. Pilih entity dari sidebar | Radar chart update untuk entity terpilih | | | | |
| 9.4.4 | Toggle comparison mode | 1. Toggle comparison mode | Bisa pilih multiple entities untuk dibandingkan | | | | |
| 9.4.5 | Sort entities | 1. Pilih sort option (default/score-desc/score-asc/name) | Entities di-sort sesuai pilihan | | | | |
| 9.4.6 | Lihat metric breakdown table | 1. Lihat tabel di bawah radar chart | Tabel menampilkan detail metrik per entity | | | | |

### 9.5 Comparison
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.5.1 | Bandingkan kelas | 1. Navigasi ke Comparison page<br>2. Pilih max 3 kelas<br>3. Klik "Compare" | Comparison chart tampil dengan metrics side-by-side | | | | |
| 9.5.2 | Filter date range | 1. Pilih date range | Comparison di-filter untuk periode terpilih | | | | |

### 9.6 Export
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 9.6.1 | Export ke CSV | 1. Klik "Export CSV" | File CSV berhasil di-download | | | | |
| 9.6.2 | Export ke PDF | 1. Klik "Export PDF" | File PDF berhasil di-download | | | | |
| 9.6.3 | Export summary | 1. Klik "Export Summary" | Summary analytics berhasil di-download | | | | |

---

## 10. AI Settings (Pengaturan AI)

### 10.1 AI Preview
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 10.1.1 | Akses AI Preview | 1. Navigasi ke AI Settings<br>2. Klik tab "Preview" | Form preview tampil dengan fields (system prompt, user prompt, course context, temperature, max tokens) | | | | |
| 10.1.2 | Test prompt | 1. Isi system prompt dan user prompt<br>2. Klik "Test" | Response AI tampil dengan rate limit info | | | | |
| 10.1.3 | Adjust parameters | 1. Ubah temperature dan max tokens<br>2. Klik "Test" | Response update sesuai parameter | | | | |

### 10.2 AI Presets
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 10.2.1 | Buat preset | 1. Klik tab "Presets"<br>2. Klik "Create Preset"<br>3. Isi nama dan konfigurasi<br>4. Klik "Save" | Preset berhasil dibuat | | | | |
| 10.2.2 | Set default preset | 1. Klik preset<br>2. Toggle "Set as Default" | Preset ditandai sebagai default | | | | |
| 10.2.3 | Edit preset | 1. Klik preset<br>2. Klik "Edit"<br>3. Ubah konfigurasi<br>4. Klik "Save" | Preset berhasil diubah | | | | |
| 10.2.4 | Import preset | 1. Klik "Import"<br>2. Pilih file preset<br>3. Klik "Import" | Preset berhasil di-import | | | | |
| 10.2.5 | Export preset | 1. Klik preset<br>2. Klik "Export" | File preset berhasil di-download | | | | |
| 10.2.6 | Hapus preset | 1. Klik preset<br>2. Klik "Delete"<br>3. Konfirmasi | Preset berhasil dihapus | | | | |

### 10.3 A/B Testing
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 10.3.1 | Buat A/B test | 1. Klik tab "A/B Testing"<br>2. Klik "Create Test"<br>3. Isi nama test<br>4. Buat 2+ variants<br>5. Klik "Create" | A/B test berhasil dibuat | | | | |
| 10.3.2 | Lihat A/B test stats | 1. Klik A/B test | Stats tampil (usage per variant, performance metrics) | | | | |
| 10.3.3 | Assign variant | 1. Klik A/B test<br>2. Assign variant ke course | Variant berhasil di-assign | | | | |
| 10.3.4 | Hapus A/B test | 1. Klik A/B test<br>2. Klik "Delete"<br>3. Konfirmasi | A/B test berhasil dihapus | | | | |

### 10.4 History
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 10.4.1 | Lihat history | 1. Klik tab "History" | History AI interactions tampil dengan pagination | | | | |
| 10.4.2 | Archive history | 1. Pilih history items<br>2. Klik "Archive" | History berhasil di-archive | | | | |

---

## 11. Profile (Profil Dosen)

### 11.1 Melihat Profil
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 11.1.1 | Melihat profil | 1. Navigasi ke halaman profil | Halaman profil tampil dengan informasi user | | | | |
| 11.1.2 | Melihat statistik | 1. Klik tab "Statistik" | Statistik user tampil (jumlah kelas, mahasiswa, dll) | | | | |

### 11.2 Edit Profil
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 11.2.1 | Edit nama | 1. Klik "Edit Profil"<br>2. Ubah nama<br>3. Simpan | Nama berhasil diubah | | | | |
| 11.2.2 | Upload avatar | 1. Klik avatar<br>2. Pilih file gambar<br>3. Upload | Avatar berhasil diupload | | | | |
| 11.2.3 | Hapus avatar | 1. Klik avatar<br>2. Pilih "Hapus Avatar" | Avatar dihapus, kembali ke default | | | | |

### 11.3 Preferences
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 11.3.1 | Ubah preferensi notifikasi | 1. Navigasi ke preferensi<br>2. Ubah setting notifikasi<br>3. Simpan | Preferensi berhasil diubah | | | | |

---

## 12. Global Search

### 12.1 Pencarian Global
| No | Skenario | Langkah | Hasil yang Diharapkan | Lolos | Gagal | N/A | Keterangan |
|----|----------|---------|----------------------|-------|-------|-----|------------|
| 12.1.1 | Search dari header | 1. Klik ikon search di header<br>2. Ketik keyword | Hasil search dari berbagai sumber (kelas, grup, mahasiswa) tampil | | | | |
| 12.1.2 | Filter hasil search | 1. Klik filter (kelas/grup/mahasiswa) | Hasil di-filter sesuai kategori | | | | |

---

## Ringkasan Testing

| Modul | Total Test | Lolos | Gagal | N/A |
|-------|------------|-------|-------|-----|
| 1. Autentikasi & Registrasi | 10 | | | |
| 2. Dashboard Dosen | 5 | | | |
| 3. Courses | 21 | | | |
| 4. Groups | 9 | | | |
| 5. Chat Spaces | 17 | | | |
| 6. Discussion Monitoring | 9 | | | |
| 7. Attendance | 5 | | | |
| 8. Session Management | 9 | | | |
| 9. Analytics | 24 | | | |
| 10. AI Settings | 18 | | | |
| 11. Profile | 7 | | | |
| 12. Global Search | 2 | | | |
| **TOTAL** | **136** | | | |

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
