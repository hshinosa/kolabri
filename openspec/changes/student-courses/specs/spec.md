## ADDED Requirements

### Requirement: Courses search
Halaman courses SHALL menyediakan pencarian mata kuliah.

#### Scenario: Mahasiswa mencari mata kuliah
- **WHEN** mahasiswa mengetik kata kunci pada kolom "Cari mata kuliah"
- **THEN** sistem SHALL menampilkan daftar course yang cocok berdasarkan nama dan kode
- **AND** hasil diurutkan berdasarkan relevansi

#### Scenario: Pencarian dengan filter aktif
- **WHEN** mahasiswa memasukkan kata kunci DAN filter status/kategori aktif
- **THEN** sistem SHALL menampilkan hanya course yang cocok dengan kata kunci DAN filter

#### Scenario: Pencarian kosong
- **WHEN** tidak ada course yang cocok dengan kata kunci
- **THEN** sistem SHALL menampilkan pesan "Tidak ada mata kuliah yang cocok"
- **AND** menampilkan saran "Coba kata kunci lain atau hapus filter"

#### Scenario: Hapus pencarian
- **WHEN** mahasiswa menghapus isi kolom pencarian
- **THEN** daftar course SHALL kembali menampilkan semua course sesuai filter aktif

---

### Requirement: Courses filter
Halaman courses SHALL menyediakan filter berdasarkan status dan kategori.

#### Scenario: Mahasiswa memfilter berdasarkan status
- **WHEN** mahasiswa memilih chip filter status "Berjalan"
- **THEN** daftar course SHALL diperbarui hanya menampilkan course dengan status "Berjalan"
- **AND** chip "Berjalan" tampil dalam state aktif

#### Scenario: Mahasiswa memfilter berdasarkan kategori
- **WHEN** mahasiswa memilih chip filter kategori "Informatika"
- **THEN** daftar course SHALL diperbarui hanya menampilkan course dengan kategori "Informatika"

#### Scenario: Kombinasi filter
- **WHEN** mahasiswa memilih beberapa chip filter sekaligus
- **THEN** sistem SHALL menampilkan course yang memenuhi SEMUA kriteria filter (AND logic)

#### Scenario: Hapus filter
- **WHEN** mahasiswa menekan chip filter yang sudah aktif untuk menonaktifkan
- **THEN** filter tersebut SHALL dihapus dari query
- **AND** daftar course diperbarui sesuai filter yang tersisa

---

### Requirement: Courses categories
Setiap course SHALL menampilkan kategori.

#### Scenario: Daftar course ditampilkan dengan kategori
- **WHEN** mahasiswa membuka halaman courses
- **THEN** setiap kartu course menampilkan label "Kategori" dengan warna yang sesuai
- **AND** kategori ditampilkan sebagai badge kecil pada kartu

#### Scenario: Course tanpa kategori
- **WHEN** course tidak memiliki kategori
- **THEN** kartu course tidak menampilkan label kategori
- **AND** tidak ada error atau placeholder yang ditampilkan

#### Scenario: Filter kategori tersedia
- **WHEN** mahasiswa membuka menu filter kategori
- **THEN** sistem SHALL menampilkan daftar kategori yang tersedia
- **AND** setiap kategori menampilkan jumlah course yang sesuai

---

### Requirement: Progress tracking
Halaman courses SHALL menampilkan progres per course.

#### Scenario: Mahasiswa melihat kemajuan belajar
- **WHEN** daftar course dimuat
- **THEN** setiap kartu menampilkan "Progres belajar" dalam persen
- **AND** progress bar menampilkan visual kemajuan
- **AND** status ditampilkan sebagai "Belum mulai", "Berjalan", atau "Selesai"

#### Scenario: Course belum dimulai
- **WHEN** mahasiswa belum memulai course
- **THEN** kartu menampilkan "Belum mulai" dengan progress bar kosong (abu-abu)
- **AND** persen menampilkan 0%

#### Scenario: Course sedang berjalan
- **WHEN** mahasiswa sedang mengerjakan course
- **THEN** kartu menampilkan "Berjalan" dengan progress bar biru
- **AND** persen menampilkan angka antara 1-99%

#### Scenario: Course selesai
- **WHEN** mahasiswa telah menyelesaikan semua item course
- **THEN** kartu menampilkan "Selesai" dengan progress bar hijau
- **AND** persen menampilkan 100%

#### Scenario: Sort berdasarkan progres
- **WHEN** mahasiswa memilih opsi sort "Progres terendah"
- **THEN** daftar course SHALL diurutkan dari progres terendah ke tertinggi
- **AND** course dengan progres 0% muncul di paling atas

---

### Requirement: Sorting
Halaman courses SHALL menyediakan opsi pengurutan.

#### Scenario: Sort berdasarkan status default
- **WHEN** mahasiswa membuka halaman courses pertama kali
- **THEN** daftar course SHALL diurutkan: Berjalan → Belum mulai → Selesai

#### Scenario: Sort berdasarkan nama
- **WHEN** mahasiswa memilih opsi "Nama A-Z"
- **THEN** daftar course SHALL diurutkan berdasarkan nama secara alfabetis

#### Scenario: Sort berdasarkan progres
- **WHEN** mahasiswa memilih opsi "Progres tertinggi"
- **THEN** daftar course SHALL diurutkan dari progres tertinggi ke terendah

---

### Requirement: Empty and loading states
Halaman courses SHALL menampilkan state yang sesuai.

#### Scenario: Loading state
- **WHEN** data course sedang dimuat
- **THEN** sistem SHALL menampilkan skeleton loading pada kartu course

#### Scenario: Tidak ada course
- **WHEN** mahasiswa tidak memiliki mata kuliah
- **THEN** sistem menampilkan pesan "Anda belum memiliki mata kuliah"
- **AND** menampilkan CTA "Hubungi admin untuk mendaftar mata kuliah"

#### Scenario: Hasil filter kosong
- **WHEN** filter aktif menghasilkan 0 course
- **THEN** sistem menampilkan pesan "Tidak ada mata kuliah dengan filter ini"
- **AND** menampilkan tombol "Hapus semua filter"
