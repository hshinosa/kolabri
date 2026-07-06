## 1. Data Mapping & API (Tanpa Schema Baru)
- [x] 1.1 Mapping konsep "Minggu" ke data `Group` yang ada
- [x] 1.2 Mapping konsep "Sesi Diskusi" ke data `ChatSpace` yang ada
- [x] 1.3 Pastikan endpoint `/courses/:id/groups` bisa dipakai untuk list "Minggu"
- [x] 1.4 Pastikan endpoint `/groups/:id/chat-spaces` bisa dipakai untuk list "Sesi"
- [x] 1.5 Cek apakah ada field `created_at` atau sequence di `ChatSpace` untuk urutan sesi

## 2. Halaman Utama (Course Detail)
- [x] 2.1 Buat halaman `student-course-detail` (menggantikan halaman lama)
- [x] 2.2 Tambahkan ringkasan course (Nama, Dosen)
- [x] 2.3 Tampilkan list "Minggu" (berdasarkan data `Group` yang relevan)
- [x] 2.4 Tiap "Minggu" bisa diklik untuk melihat daftar "Sesi" (`ChatSpace`)

## 3. Komponen Sesi Diskusi
- [x] 3.1 Tampilkan list `ChatSpace` sebagai "Sesi Diskusi" dalam tiap "Minggu"
- [x] 3.2 Tampilkan status partisipasi (cek dari data `messages` atau `participants` di `ChatSpace`)
    - Belum ada aktivitas = "Belum Berpartisipasi"
    - Sudah ada aktivitas = "Sudah Berpartisipasi"
- [x] 3.3 Hitung progres per "Minggu" (berapa `ChatSpace` yang sudah aktif dibanding total)

## 4. UX & Polish
- [x] 4.1 Pastikan layout responsif
- [x] 4.2 Tambahkan state kosong jika belum ada `Group`
- [x] 4.3 Hilangkan referensi "Materi", "Deadline", "Silabus"
- [x] 4.4 Fokus tampilan hanya ke:
    - List Minggu
    - List Sesi
    - Status Partisipasi

## 5. Verifikasi
- [x] 5.1 Tes tampilan dengan 1 Group (Minggu)
- [x] 5.2 Tes tampilan dengan beberapa Group (Minggu)
- [x] 5.3 Tes status partisipasi berdasarkan data `ChatSpace`
- [x] 5.4 Pastikan tidak ada fitur "Materi" atau "Deadline" yang muncul
