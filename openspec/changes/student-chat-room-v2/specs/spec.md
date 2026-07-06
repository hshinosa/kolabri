## ADDED Requirements

### Requirement: Message editing
Sistem SHALL mengizinkan pengguna mengedit pesan miliknya.

#### Scenario: Mahasiswa memperbaiki pesan
- **WHEN** mahasiswa menekan aksi "Ubah pesan" pada pesan sendiri
- **THEN** sistem SHALL menampilkan editor inline pada posisi pesan
- **AND** setelah simpan, pesan tampil dengan label "Diedit" dan timestamp edit

#### Scenario: Edit melebihi batas waktu
- **WHEN** mahasiswa mencoba mengedit pesan yang dikirim lebih dari 24 jam lalu
- **THEN** sistem SHALL menampilkan pesan "Pesan tidak dapat diedit setelah 24 jam"
- **AND** aksi edit tidak tersedia pada menu pesan

#### Scenario: Edit oleh non-pengirim
- **WHEN** pengguna mencoba mengedit pesan milik orang lain
- **THEN** sistem SHALL menolak aksi dengan pesan "Anda hanya bisa mengedit pesan sendiri"

#### Scenario: Edit pesan yang sudah dihapus
- **WHEN** pengguna mencoba mengedit pesan yang sudah dihapus
- **THEN** sistem SHALL menolak aksi karena pesan sudah tidak memiliki konten

---

### Requirement: Message deletion
Sistem SHALL mengizinkan pengguna menghapus pesan miliknya.

#### Scenario: Mahasiswa menghapus pesan sendiri
- **WHEN** mahasiswa menekan aksi "Hapus pesan" dan mengonfirmasi
- **THEN** konten pesan SHALL diganti dengan "[Pesan telah dihapus]"
- **AND** sistem menyimpan jejak audit penghapusan

#### Scenario: Moderator menghapus pesan
- **WHEN** moderator atau owner ruang menekan "Hapus pesan" pada pesan orang lain
- **THEN** sistem SHALL menghapus pesan dan menyimpan audit
- **AND** pengirim pesan menerima notifikasi "Pesan Anda dihapus oleh moderator"

#### Scenario: Konfirmasi penghapusan
- **WHEN** mahasiswa menekan "Hapus pesan"
- **THEN** sistem SHALL menampilkan dialog konfirmasi "Hapus pesan ini? Tindakan tidak dapat dibatalkan."

---

### Requirement: Message search
Sistem SHALL menyediakan pencarian pesan di dalam ruang chat.

#### Scenario: Mahasiswa mencari topik diskusi
- **WHEN** mahasiswa mengetik kata kunci di kolom "Cari pesan"
- **THEN** sistem SHALL menampilkan pesan yang relevan
- **AND** kata kunci disorot pada cuplikan hasil
- **AND** hasil diurutkan berdasarkan relevansi

#### Scenario: Pencarian dengan hasil banyak
- **WHEN** hasil pencarian lebih dari 20 pesan
- **THEN** sistem SHALL menampilkan pagination
- **AND** menampilkan total jumlah hasil

#### Scenario: Pencarian kosong
- **WHEN** tidak ada pesan yang cocok dengan kata kunci
- **THEN** sistem SHALL menampilkan pesan "Tidak ada pesan yang cocok"

#### Scenario: Klik hasil pencarian
- **WHEN** mahasiswa menekan salah satu hasil pencarian
- **THEN** sistem SHALL scroll ke posisi pesan tersebut di timeline
- **AND** pesan tersebut di-highlight sementara

---

### Requirement: Code highlighting
Sistem SHALL merender blok kode dengan syntax highlighting.

#### Scenario: Pesan berisi fenced code block
- **WHEN** pesan mengandung blok kode dengan syntax ```language
- **THEN** sistem SHALL menampilkan format kode berwarna sesuai bahasa
- **AND** blok kode memiliki tombol "Salin kode"

#### Scenario: Pesan berisi inline code
- **WHEN** pesan mengandung inline code dengan syntax `code`
- **THEN** sistem SHALL menampilkan teks dengan format monospace dan background berbeda

#### Scenario: Konten kode berbahaya
- **WHEN** blok kode mengandung script HTML/JavaScript
- **THEN** sistem SHALL menampilkan sebagai teks biasa (bukan execute)
- **AND** konten tetap aman dari XSS

#### Scenario: Bahasa tidak dikenali
- **WHEN** blok kode tidak memiliki label bahasa
- **THEN** sistem SHALL melakukan auto-detection atau menampilkan tanpa highlight

---

### Requirement: Link preview
Sistem SHALL menampilkan pratinjau tautan secara otomatis.

#### Scenario: Pesan berisi URL valid
- **WHEN** URL valid dikirim dalam pesan
- **THEN** sistem SHALL menampilkan kartu "Pratinjau tautan" di bawah pesan
- **AND** kartu menampilkan title, description singkat, dan gambar (jika ada)

#### Scenario: Metadata gagal dimuat
- **WHEN** fetch metadata URL gagal atau timeout
- **THEN** sistem SHALL menampilkan URL biasa tanpa kartu preview
- **AND** tidak ada error yang ditampilkan ke pengguna

#### Scenario: URL dalam teks biasa
- **WHEN** URL tertulis sebagai bagian dari kalimat
- **THEN** sistem SHALL tetap mendeteksi dan menampilkan preview
- **AND** URL tetap clickable sebagai link

#### Scenario: Multiple URL dalam satu pesan
- **WHEN** pesan mengandung beberapa URL
- **THEN** sistem SHALL menampilkan preview untuk setiap URL (maksimal 3)

---

### Requirement: Message pinning
Sistem SHALL mengizinkan pin pesan penting.

#### Scenario: Moderator memin pesan
- **WHEN** moderator atau owner menekan aksi "Sematkan pesan"
- **THEN** pesan SHALL muncul di panel "Pesan dipin"
- **AND** pesan tetap berada di posisi aslinya pada timeline

#### Scenario: Unpin pesan
- **WHEN** moderator menekan "Lepas sematan" pada pesan yang dipin
- **THEN** pesan SHALL dihapus dari panel "Pesan dipin"

#### Scenario: Batas pin tercapai
- **WHEN** moderator mencoba memin pesan ke-11
- **THEN** sistem SHALL menampilkan pesan "Batas maksimal 10 pesan dipin"
- **AND** meminta moderator melepas sematan salah satu pin terlebih dahulu

#### Scenario: Klik pesan di panel pin
- **WHEN** mahasiswa menekan pesan di panel "Pesan dipin"
- **THEN** sistem SHALL scroll ke posisi pesan tersebut di timeline
- **AND** pesan di-highlight sementara

---

### Requirement: No reactions in scope
Perubahan ini SHALL tidak mencakup fitur reactions.

#### Scenario: Pengguna membuka menu aksi pesan
- **WHEN** menu aksi pesan ditampilkan
- **THEN** tidak ada opsi "Tambah reaksi" atau ikon reaksi

#### Scenario: API tidak memiliki endpoint reaksi
- **WHEN** aplikasi memanggil API terkait pesan
- **THEN** tidak ada field atau endpoint terkait reaksi dalam response

---

### Requirement: Empty and loading states
Sistem SHALL menampilkan state yang sesuai untuk setiap kondisi.

#### Scenario: Loading pencarian
- **WHEN** mahasiswa mengetik di kolom pencarian
- **THEN** sistem SHALL menampilkan skeleton loading pada hasil

#### Scenario: Tidak ada pesan dipin
- **WHEN** tidak ada pesan yang dipin di ruang
- **THEN** panel "Pesan dipin" tidak ditampilkan atau menampilkan "Belum ada pesan dipin"

#### Scenario: Edit inline
- **WHEN** mahasiswa mengedit pesan
- **THEN** sistem SHALL menampilkan editor dengan konten asli dan tombol "Simpan" dan "Batal"
