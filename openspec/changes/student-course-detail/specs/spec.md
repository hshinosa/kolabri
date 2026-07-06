## ADDED Requirements

### Requirement: Materials section
Halaman detail course SHALL menampilkan materi pembelajaran secara terstruktur.

#### Scenario: Mahasiswa membuka materi berdasarkan modul
- **WHEN** mahasiswa membuka detail course
- **THEN** sistem SHALL menampilkan bagian "Materi pembelajaran"
- **AND** materi dikelompokkan berdasarkan modul/topik
- **AND** setiap modul menampilkan jumlah materi dan status penyelesaian

#### Scenario: Mahasiswa mengakses materi tertentu
- **WHEN** mahasiswa menekan item materi
- **THEN** sistem SHALL membuka materi tersebut
- **AND** status materi berubah menjadi "Sedang dikerjakan"

#### Scenario: Mahasiswa menyelesaikan materi
- **WHEN** mahasiswa menyelesaikan materi (misal: menonton video, membaca dokumen)
- **THEN** sistem SHALL mengupdate status menjadi "Selesai"
- **AND** progres modul dan course diperbarui secara real-time

#### Scenario: Materi dengan tipe berbeda
- **WHEN** daftar materi ditampilkan
- **THEN** setiap item menampilkan ikon tipe (video, dokumen, quiz, link)
- **AND** durasi estimasi ditampilkan jika tersedia

#### Scenario: Modul kosong
- **WHEN** modul belum memiliki materi
- **THEN** sistem menampilkan pesan "Belum ada materi untuk modul ini"

---

### Requirement: Syllabus section
Halaman detail course SHALL menampilkan syllabus berurutan.

#### Scenario: Mahasiswa melihat alur topik
- **WHEN** mahasiswa membuka bagian "Silabus"
- **THEN** sistem SHALL menampilkan urutan topik dari awal hingga akhir
- **AND** setiap topik menampilkan nomor, judul, dan durasi

#### Scenario: Topik sedang berlangsung
- **WHEN** topik sedang dibahas saat ini
- **THEN** sistem SHALL meng-highlight topik tersebut
- **AND** menampilkan label "Sedang berlangsung"

#### Scenario: Topik sudah selesai
- **WHEN** topik sudah dibahas sebelumnya
- **THEN** sistem SHALL menampilkan centang pada topik
- **AND** status menampilkan "Selesai"

#### Scenario: Topik akan datang
- **WHEN** topik belum dibahas
- **THEN** sistem SHALL menampilkan topik dalam state normal (tidak di-highlight)
- **AND** status menampilkan "Akan datang"

#### Scenario: Silabus belum tersedia
- **WHEN** dosen belum mengisi silabus
- **THEN** sistem menampilkan pesan "Silabus belum tersedia"
- **AND** menampilkan kontak dosen pengampu

---

### Requirement: Course progress
Halaman detail course SHALL menampilkan progres keseluruhan dan per modul.

#### Scenario: Mahasiswa memantau progres keseluruhan
- **WHEN** data progres tersedia
- **THEN** sistem SHALL menampilkan "Progres course" dalam persen
- **AND** progress bar visual menampilkan kemajuan keseluruhan

#### Scenario: Mahasiswa melihat progres per modul
- **WHEN** mahasiswa membuka section "Progres"
- **THEN** sistem SHALL menampilkan rincian progres per modul
- **AND** setiap modul menampilkan: nama, jumlah item, item selesai, progress bar

#### Scenario: Progres diperbarui real-time
- **WHEN** mahasiswa menyelesaikan materi
- **THEN** progres modul dan course SHALL diperbarui tanpa refresh halaman

#### Scenario: Course belum dimulai
- **WHEN** mahasiswa belum memulai course
- **THEN** sistem menampilkan "Belum mulai" dengan progress bar 0%
- **AND** menampilkan CTA "Mulai belajar"

#### Scenario: Course selesai 100%
- **WHEN** mahasiswa menyelesaikan semua materi
- **THEN** sistem menampilkan "Selesai" dengan progress bar 100%
- **AND** menampilkan pesan selamat dan opsi sertifikat (jika ada)

---

### Requirement: Deadline panel
Halaman detail course SHALL menampilkan daftar tenggat aktivitas.

#### Scenario: Mahasiswa melihat tenggat terdekat
- **WHEN** mahasiswa membuka panel "Tenggat"
- **THEN** daftar tenggat SHALL diurutkan dari yang paling dekat
- **AND** setiap item menampilkan: judul, tanggal tenggat, dan status

#### Scenario: Status "Akan datang"
- **WHEN** tenggat masih lebih dari 24 jam dari sekarang
- **THEN** item menampilkan status "Akan datang" dengan warna abu-abu

#### Scenario: Status "Hari ini"
- **WHEN** tenggat kurang dari 24 jam dari sekarang
- **THEN** item menampilkan status "Hari ini" dengan warna kuning
- **AND** menampilkan sisa waktu (misal: "5 jam lagi")

#### Scenario: Status "Terlewat"
- **WHEN** tenggat sudah melewati batas waktu
- **THEN** item menampilkan status "Terlewat" dengan warna merah
- **AND** menampilkan keterlambatan (misal: "Terlambat 2 hari")

#### Scenario: Tidak ada tenggat
- **WHEN** course tidak memiliki tugas dengan tenggat
- **THEN** panel menampilkan pesan "Tidak ada tenggat yang akan datang"

#### Scenario: Mahasiswa menekan item tenggat
- **WHEN** mahasiswa menekan item tenggat
- **THEN** sistem SHALL navigasi ke halaman detail tugas tersebut

---

### Requirement: Empty and loading states
Halaman detail course SHALL menampilkan state yang sesuai.

#### Scenario: Loading state
- **WHEN** data course sedang dimuat
- **THEN** sistem SHALL menampilkan skeleton loading untuk setiap section

#### Scenario: Course tidak ditemukan
- **WHEN** ID course tidak valid atau mahasiswa tidak terdaftar
- **THEN** sistem menampilkan pesan "Course tidak ditemukan"
- **AND** menampilkan tombol "Kembali ke daftar course"

#### Scenario: Error memuat data
- **WHEN** API mengembalikan error
- **THEN** sistem menampilkan pesan "Gagal memuat data"
- **AND** menampilkan tombol "Coba lagi"
