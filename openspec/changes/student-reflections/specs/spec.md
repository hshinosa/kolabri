## ADDED Requirements

### Requirement: Reflection templates
Halaman reflections SHALL menyediakan template refleksi.

#### Scenario: Mahasiswa memilih template global
- **WHEN** mahasiswa membuka panel "Template" dan memilih template global
- **THEN** editor SHALL terisi kerangka refleksi dari template
- **AND** mahasiswa dapat menyesuaikan isi sebelum menyimpan

#### Scenario: Mahasiswa membuat template personal
- **WHEN** mahasiswa menekan "Buat template" dan mengisi form
- **THEN** sistem SHALL menyimpan template baru
- **AND** template langsung tersedia di panel template

#### Scenario: Mahasiswa mengedit template personal
- **WHEN** mahasiswa menekan "Edit" pada template miliknya
- **THEN** sistem SHALL menampilkan form edit
- **AND** perubahan tersimpan setelah menekan "Simpan"

#### Scenario: Mahasiswa menghapus template personal
- **WHEN** mahasiswa menekan "Hapus" pada template miliknya
- **THEN** sistem SHALL menampilkan konfirmasi
- **AND** template dihapus setelah konfirmasi

#### Scenario: Template berdasarkan kategori
- **WHEN** mahasiswa memilih kategori template (Harian, Mingguan, Proyek, Evaluasi Diri)
- **THEN** panel template hanya menampilkan template dari kategori tersebut

#### Scenario: Template global ditandai
- **WHEN** mahasiswa melihat daftar template
- **THEN** template global ditandai dengan label "Template umum"
- **AND** template global tidak bisa dihapus atau diedit oleh mahasiswa

---

### Requirement: Reflections export
Halaman reflections SHALL menyediakan ekspor data refleksi.

#### Scenario: Mahasiswa mengekspor satu refleksi
- **WHEN** mahasiswa menekan tombol "Ekspor" pada satu refleksi
- **THEN** sistem SHALL menampilkan pilihan format (PDF, Markdown, Text)
- **AND** setelah memilih format, sistem memproses ekspor

#### Scenario: Mahasiswa mengekspor beberapa refleksi
- **WHEN** mahasiswa memilih beberapa refleksi dan menekan "Ekspor terpilih"
- **THEN** sistem SHALL mengekspor semua refleksi yang dipilih
- **AND** file ekspor berisi semua refleksi dengan separator

#### Scenario: Ekspor PDF
- **WHEN** mahasiswa memilih format PDF
- **THEN** sistem SHALL menghasilkan PDF dengan formatting yang rapi
- **AND** PDF mencakup judul, tanggal, isi, dan tag

#### Scenario: Ekspor Markdown
- **WHEN** mahasiswa memilih format Markdown
- **THEN** sistem SHALL menghasilkan file .md dengan syntax Markdown
- **AND** file bisa dibuka di editor Markdown apapun

#### Scenario: Status ekspor
- **WHEN** ekspor sedang diproses
- **THEN** sistem menampilkan status "Menyiapkan file"
- **AND** saat selesai menampilkan tombol "Unduh"

#### Scenario: Ekspor gagal
- **WHEN** proses ekspor gagal
- **THEN** sistem menampilkan pesan "Ekspor gagal, silakan coba lagi"
- **AND** menyediakan tombol "Coba lagi"

---

### Requirement: Reflections search
Halaman reflections SHALL menyediakan pencarian refleksi.

#### Scenario: Mahasiswa mencari berdasarkan kata kunci
- **WHEN** mahasiswa mengetik kata kunci di kolom "Cari refleksi"
- **THEN** sistem SHALL menampilkan refleksi yang cocok berdasarkan judul dan isi
- **AND** kata kunci disorot pada cuplikan hasil

#### Scenario: Filter berdasarkan tag
- **WHEN** mahasiswa memilih tag "Kuliah"
- **THEN** sistem hanya menampilkan refleksi dengan tag "Kuliah"

#### Scenario: Filter berdasarkan rentang tanggal
- **WHEN** mahasiswa memilih rentang tanggal
- **THEN** sistem hanya menampilkan refleksi dalam rentang tersebut

#### Scenario: Kombinasi filter
- **WHEN** mahasiswa menggunakan kata kunci, tag, dan tanggal sekaligus
- **THEN** sistem SHALL menampilkan refleksi yang cocok dengan SEMUA kriteria

#### Scenario: Pencarian kosong
- **WHEN** tidak ada refleksi yang cocok
- **THEN** sistem menampilkan pesan "Tidak ada refleksi yang cocok"
- **AND** menampilkan saran "Coba kata kunci lain atau hapus filter"

#### Scenario: Hapus pencarian
- **WHEN** mahasiswa menghapus isi kolom pencarian
- **THEN** daftar refleksi SHALL kembali menampilkan semua refleksi sesuai filter

---

### Requirement: Reflections analytics
Halaman reflections SHALL menampilkan analitik perkembangan.

#### Scenario: Mahasiswa membuka panel analitik
- **WHEN** mahasiswa membuka bagian "Analitik refleksi"
- **THEN** sistem SHALL menampilkan metrik berikut:
  - Frekuensi menulis per periode
  - Rata-rata panjang refleksi (kata)
  - Streak menulis beruntun
  - Tag terpopuler
  - Tren waktu

#### Scenario: Tren frekuensi
- **WHEN** data periode tersedia
- **THEN** sistem menampilkan grafik frekuensi menulis per minggu/bulan
- **AND** menampilkan indikator naik/turun dibanding periode sebelumnya

#### Scenario: Tren panjang rata-rata
- **WHEN** data tersedia
- **THEN** sistem menampilkan grafik panjang rata-rata refleksi
- **AND** menampilkan perbandingan dengan periode sebelumnya

#### Scenario: Streak menulis
- **WHEN** mahasiswa menulis refleksi secara beruntun
- **THEN** sistem menampilkan "Streak: X hari"
- **AND** menampilkan streak terpanjang

#### Scenario: Tag terpopuler
- **WHEN** mahasiswa memiliki refleksi dengan berbagai tag
- **THEN** sistem menampilkan daftar tag yang paling sering digunakan
- **AND** menampilkan jumlah refleksi per tag

#### Scenario: Pilih periode analitik
- **WHEN** mahasiswa memilih periode (minggu, bulan, tahun)
- **THEN** sistem SHALL memperbarui semua metrik sesuai periode

#### Scenario: Belum ada data analitik
- **WHEN** mahasiswa baru mulai menulis refleksi
- **THEN** sistem menampilkan pesan "Mulai menulis untuk melihat analitik"
- **AND** menampilkan template untuk memulai

---

### Requirement: Tag system
Refleksi SHALL mendukung sistem tag untuk kategorisasi.

#### Scenario: Mahasiswa menambahkan tag
- **WHEN** mahasiswa mengetik di input tag
- **THEN** sistem menampilkan auto-suggest dari tag yang sudah ada
- **AND** mahasiswa bisa memilih dari suggest atau membuat tag baru

#### Scenario: Mahasiswa menghapus tag
- **WHEN** mahasiswa menekan tombol hapus pada tag
- **THEN** tag SHALL dihapus dari refleksi

#### Scenario: Tag ditampilkan di daftar
- **WHEN** daftar refleksi ditampilkan
- **THEN** setiap refleksi menampilkan tag sebagai chip
- **AND** chip bisa diklik untuk filter berdasarkan tag tersebut

---

### Requirement: Empty and loading states
Halaman reflections SHALL menampilkan state yang sesuai.

#### Scenario: Loading state
- **WHEN** data refleksi sedang dimuat
- **THEN** sistem menampilkan skeleton loading

#### Scenario: Belum ada refleksi
- **WHEN** mahasiswa belum memiliki refleksi
- **THEN** sistem menampilkan pesan "Mulai perjalanan refleksi Anda"
- **AND** menampilkan CTA "Gunakan template" dan "Tulis refleksi baru"

#### Scenario: Hasil filter kosong
- **WHEN** filter aktif menghasilkan 0 refleksi
- **THEN** sistem menampilkan pesan "Tidak ada refleksi dengan filter ini"
- **AND** menampilkan tombol "Hapus semua filter"
