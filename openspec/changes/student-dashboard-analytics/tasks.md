## 1. Kebutuhan data & metrik

- [x] 1.1 Tentukan metrik dasar:
  - minggu aktif
  - sesi diikuti
  - rata-rata partisipasi
- [x] 1.2 Tentukan sumber data aktivitas terakhir
- [x] 1.3 Tentukan tren sederhana:
  - naik
  - turun
  - stabil
- [x] 1.4 Hindari fitur berat:
  - heatmap
  - prediksi
  - analisis kompleks

## 2. API & agregasi data

- [x] 2.1 Tambahkan endpoint ringkasan aktivitas mahasiswa
- [x] 2.2 Tambahkan endpoint tren partisipasi sederhana
- [x] 2.3 Hitung jumlah sesi yang sudah diikuti
- [x] 2.4 Hitung jumlah minggu aktif
- [x] 2.5 Hitung rata-rata partisipasi
- [x] 2.6 Pastikan data bisa dipakai untuk radar sederhana

## 3. UI dashboard analytics

- [x] 3.1 Buat halaman `student-dashboard-analytics`
- [x] 3.2 Buat komponen ringkasan aktivitas
- [x] 3.3 Buat komponen tren partisipasi:
  - ▲ naik
  - ▼ turun
  - ─ stabil
- [x] 3.4 Buat komponen timeline aktivitas
- [x] 3.5 Buat komponen aktivitas terakhir
- [x] 3.6 Jangan tampilkan:
  - sesi berikutnya
  - kegiatan terdekat

## 4. Radar sederhana

- [x] 4.1 Gunakan 4 dimensi:
  - Konsistensi
  - Partisipasi Diskusi
  - Refleksi
  - Keterlibatan Mingguan
- [x] 4.2 Hitung skor per dimensi
- [x] 4.3 Normalisasi skor ke 0-100
- [x] 4.4 Tampilkan tooltip sederhana per dimensi
- [x] 4.5 Hindari label teknis berat

## 5. Timeline aktivitas

- [x] 5.1 Tampilkan event terbaru:
  - ikut sesi diskusi
  - buka minggu baru
  - selesaikan semua sesi dalam 1 minggu
- [x] 5.2 Tambahkan filter periode jika diperlukan
- [x] 5.3 Hubungkan item timeline ke halaman terkait bila memungkinkan

## 6. Polish UI & UX

- [x] 6.1 Pastikan responsif di mobile dan desktop
- [x] 6.2 Pastikan bahasa ringan dan jelas
- [x] 6.3 Hindari istilah berat:
  - kompetensi lintas dimensi
  - performa multidimensi
  - indeks capaian
- [x] 6.4 Tambahkan state kosong:
  - belum ada aktivitas
  - belum ada data partisipasi
- [x] 6.5 Pastikan chart tidak berat di mobile

## 7. Verifikasi

- [x] 7.1 Tes ringkasan aktivitas dengan data minim
- [x] 7.2 Tes ringkasan aktivitas dengan data cukup banyak
- [x] 7.3 Tes tren partisipasi naik/turun/stabil
- [x] 7.4 Tes timeline aktivitas terbaru
- [x] 7.5 Tes radar dengan dimensi kosong
- [x] 7.6 Pastikan tidak ada fitur terlarang:
  - sesi berikutnya
  - kegiatan terdekat
  - heatmap
- [x] 7.7 Review akhir kesesuaian dengan konsep final
