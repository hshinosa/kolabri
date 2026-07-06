## ADDED Requirements

### Requirement: AI chat search
Halaman AI chat SHALL menyediakan pencarian percakapan berdasarkan kata kunci.

#### Scenario: Mahasiswa mencari percakapan lama
- **WHEN** mahasiswa memasukkan kata kunci pada kolom "Cari percakapan"
- **THEN** sistem SHALL menampilkan sesi dan pesan yang relevan
- **AND** hasil diurutkan berdasarkan relevansi dan recency
- **AND** kata kunci disorot pada cuplikan hasil

#### Scenario: Pencarian dengan filter kategori
- **WHEN** mahasiswa memasukkan kata kunci DAN memilih kategori
- **THEN** sistem SHALL menampilkan hanya hasil yang sesuai dengan kata kunci DAN kategori

#### Scenario: Pencarian kosong
- **WHEN** tidak ada hasil yang cocok dengan kata kunci
- **THEN** sistem SHALL menampilkan pesan "Tidak ada percakapan yang cocok"
- **AND** menampilkan saran "Coba kata kunci lain atau hapus filter"

#### Scenario: Pencarian bookmarked
- **WHEN** mahasiswa mengaktifkan filter "Ditandai"
- **THEN** sistem SHALL menampilkan hanya sesi yang memiliki pesan bookmarked

---

### Requirement: Conversation export
Halaman AI chat SHALL menyediakan ekspor hasil percakapan.

#### Scenario: Mahasiswa mengekspor ringkasan
- **WHEN** mahasiswa menekan tombol "Ekspor percakapan" dan memilih format "Ringkasan"
- **THEN** sistem SHALL membuat pekerjaan ekspor asinkron
- **AND** mahasiswa melihat status "Menyiapkan file ekspor"
- **AND** saat selesai mahasiswa dapat menekan "Unduh"

#### Scenario: Mahasiswa mengekspor detail lengkap
- **WHEN** mahasiswa memilih format "Detail lengkap"
- **THEN** sistem SHALL mengekspor semua pesan dengan metadata (waktu, role)
- **AND** format file berupa Markdown yang mudah dibaca

#### Scenario: Ekspor gagal
- **WHEN** proses ekspor gagal karena error sistem
- **THEN** sistem SHALL menampilkan pesan "Ekspor gagal, silakan coba lagi"
- **AND** menyediakan tombol "Coba lagi"

#### Scenario: Ekspor sesi panjang
- **WHEN** sesi memiliki lebih dari 500 pesan
- **THEN** sistem SHALL memproses ekspor secara bertahap
- **AND** menampilkan progress indicator

---

### Requirement: Conversation categories
Mahasiswa SHALL dapat mengelompokkan sesi percakapan ke dalam kategori.

#### Scenario: Mahasiswa mengatur kategori pada sesi
- **WHEN** mahasiswa memilih kategori pada sesi chat
- **THEN** sesi SHALL tersimpan dengan kategori yang dipilih
- **AND** kategori terlihat sebagai chip warna pada item sesi di sidebar

#### Scenario: Mahasiswa menambah kategori baru
- **WHEN** mahasiswa menekan "Tambah kategori" dan mengisi nama
- **THEN** sistem SHALL membuat kategori baru
- **AND** kategori langsung tersedia untuk digunakan

#### Scenario: Mahasiswa menghapus kategori
- **WHEN** mahasiswa menghapus kategori
- **THEN** sistem SHALL menghapus kategori dari semua sesi terkait
- **AND** menampilkan konfirmasi sebelum menghapus

#### Scenario: Filter berdasarkan kategori
- **WHEN** mahasiswa memilih chip kategori di sidebar
- **THEN** daftar sesi SHALL diperbarui hanya menampilkan sesi dengan kategori tersebut

---

### Requirement: Prompt templates
Mahasiswa SHALL dapat menggunakan template prompt untuk memulai percakapan.

#### Scenario: Mahasiswa memilih template
- **WHEN** mahasiswa membuka panel "Template prompt" dan memilih template
- **THEN** isi template SHALL terisi pada input chat
- **AND** mahasiswa tetap dapat mengedit sebelum mengirim

#### Scenario: Mahasiswa membuat template baru
- **WHEN** mahasiswa menekan "Buat template" dan mengisi form
- **THEN** sistem SHALL menyimpan template baru
- **AND** template langsung muncul di panel template

#### Scenario: Mahasiswa mengedit template
- **WHEN** mahasiswa menekan "Edit" pada template miliknya
- **THEN** sistem SHALL menampilkan form edit
- **AND** perubahan tersimpan setelah menekan "Simpan"

#### Scenario: Mahasiswa menghapus template
- **WHEN** mahasiswa menekan "Hapus" pada template miliknya
- **THEN** sistem SHALL menampilkan konfirmasi
- **AND** template dihapus setelah konfirmasi

#### Scenario: Template global tersedia
- **WHEN** mahasiswa membuka panel template
- **THEN** sistem SHALL menampilkan template global (dari admin) DAN template personal
- **AND** template global ditandai dengan label "Template umum"

---

### Requirement: Message bookmarks
Mahasiswa SHALL dapat menandai pesan penting.

#### Scenario: Mahasiswa menyimpan bookmark
- **WHEN** mahasiswa menekan aksi "Simpan penanda" pada satu pesan
- **THEN** pesan SHALL masuk ke daftar "Ditandai"
- **AND** ikon bookmark berubah menjadi aktif pada pesan tersebut

#### Scenario: Mahasiswa menghapus bookmark
- **WHEN** mahasiswa menekan aksi "Hapus penanda" pada pesan yang sudah dibookmark
- **THEN** pesan SHALL dihapus dari daftar "Ditandai"
- **AND** ikon bookmark kembali ke state tidak aktif

#### Scenario: Mahasiswa melihat daftar bookmark
- **WHEN** mahasiswa mengaktifkan filter "Ditandai" di sidebar
- **THEN** sistem SHALL menampilkan hanya sesi yang memiliki pesan bookmarked
- **AND** saat sesi dibuka, pesan bookmarked ditandai secara visual

#### Scenario: Bookmark sinkron saat refresh
- **WHEN** mahasiswa me-refresh halaman
- **THEN** status bookmark pada semua pesan SHALL tetap konsisten dengan data server

---

### Requirement: Empty and loading states
Halaman AI chat SHALL menampilkan state yang sesuai untuk setiap kondisi.

#### Scenario: Loading pencarian
- **WHEN** mahasiswa mengetik di kolom pencarian dan sistem memproses
- **THEN** sistem SHALL menampilkan skeleton loading pada daftar sesi

#### Scenario: Loading ekspor
- **WHEN** ekspor sedang diproses
- **THEN** sistem SHALL menampilkan progress indicator dengan estimasi waktu

#### Scenario: Tidak ada template
- **WHEN** mahasiswa membuka panel template dan belum ada template personal
- **THEN** sistem SHALL menampilkan pesan "Belum ada template personal"
- **AND** menampilkan tombol "Buat template pertama"

#### Scenario: Tidak ada bookmark
- **WHEN** mahasiswa mengaktifkan filter "Ditandai" tetapi belum ada bookmark
- **THEN** sistem SHALL menampilkan pesan "Belum ada pesan yang ditandai"
- **AND** menampilkan penjelasan cara menandai pesan
