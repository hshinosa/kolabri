## ADDED Requirements

### Requirement: Spaces search
Halaman chat spaces SHALL menyediakan pencarian ruang.

#### Scenario: Mahasiswa mencari ruang tertentu
- **WHEN** mahasiswa mengetik kata kunci pada kolom "Cari ruang diskusi"
- **THEN** sistem SHALL menampilkan ruang yang cocok berdasarkan nama dan deskripsi
- **AND** hasil tetap mempertahankan urutan aktif terbaru secara default

#### Scenario: Pencarian dengan filter aktif
- **WHEN** mahasiswa memasukkan kata kunci DAN filter tipe/status aktif
- **THEN** sistem SHALL menampilkan hanya ruang yang cocok dengan kata kunci DAN filter

#### Scenario: Pencarian kosong
- **WHEN** tidak ada ruang yang cocok dengan kata kunci
- **THEN** sistem SHALL menampilkan pesan "Tidak ada ruang yang cocok"
- **AND** menampilkan saran "Coba kata kunci lain atau hapus filter"

#### Scenario: Hapus pencarian
- **WHEN** mahasiswa menghapus isi kolom pencarian
- **THEN** daftar ruang SHALL kembali menampilkan semua ruang sesuai filter aktif

---

### Requirement: Spaces filter
Halaman chat spaces SHALL menyediakan filter daftar ruang.

#### Scenario: Mahasiswa memfilter berdasarkan tipe
- **WHEN** mahasiswa memilih chip filter tipe "Akademik"
- **THEN** daftar ruang SHALL diperbarui hanya menampilkan ruang bertipe Akademik
- **AND** chip "Akademik" tampil dalam state aktif

#### Scenario: Mahasiswa memfilter berdasarkan status
- **WHEN** mahasiswa memilih chip filter status "Aktif"
- **THEN** daftar ruang SHALL diperbarui hanya menampilkan ruang dengan status aktif

#### Scenario: Kombinasi filter
- **WHEN** mahasiswa memilih beberapa chip filter sekaligus
- **THEN** sistem SHALL menampilkan ruang yang memenuhi SEMUA kriteria filter (AND logic)

#### Scenario: Hapus filter
- **WHEN** mahasiswa menekan chip filter yang sudah aktif untuk menonaktifkan
- **THEN** filter tersebut SHALL dihapus dari query
- **AND** daftar ruang diperbarui sesuai filter yang tersisa

#### Scenario: Jumlah hasil per filter
- **WHEN** daftar ruang dimuat
- **THEN** setiap chip filter menampilkan jumlah ruang yang sesuai

---

### Requirement: Spaces sorting
Halaman chat spaces SHALL menyediakan pilihan pengurutan.

#### Scenario: Mahasiswa mengurutkan berdasarkan aktivitas terbaru
- **WHEN** mahasiswa memilih opsi "Terbaru" pada menu "Urutkan"
- **THEN** daftar ruang SHALL diurutkan berdasarkan waktu aktivitas terbaru
- **AND** ruang dengan pesan terbaru muncul di paling atas

#### Scenario: Mahasiswa mengurutkan berdasarkan paling aktif
- **WHEN** mahasiswa memilih opsi "Paling aktif"
- **THEN** daftar ruang SHALL diurutkan berdasarkan jumlah pesan dalam 7 hari terakhir

#### Scenario: Mahasiswa mengurutkan berdasarkan alfabet
- **WHEN** mahasiswa memilih opsi "A-Z"
- **THEN** daftar ruang SHALL diurutkan berdasarkan nama ruang secara alfabetis

#### Scenario: Sort state tersimpan di URL
- **WHEN** mahasiswa memilih opsi pengurutan
- **THEN** pilihan SHALL tersimpan di URL query parameter
- **AND** URL dapat dibagikan dengan pengurutan yang sama

---

### Requirement: Activity preview
Setiap item space SHALL menampilkan preview aktivitas terakhir.

#### Scenario: Daftar space ditampilkan dengan preview
- **WHEN** mahasiswa membuka halaman chat spaces
- **THEN** setiap kartu ruang menampilkan "Aktivitas terakhir"
- **AND** preview menampilkan cuplikan pesan terakhir (maksimal 100 karakter)
- **AND** preview menampilkan waktu relatif (misal: "5 menit lalu")

#### Scenario: Ruang tidak memiliki aktivitas
- **WHEN** ruang belum memiliki pesan
- **THEN** preview menampilkan "Belum ada aktivitas"

#### Scenario: Preview pesan terakhir panjang
- **WHEN** pesan terakhir lebih dari 100 karakter
- **THEN** teks preview SHALL dipotong dengan ellipsis (...)

#### Scenario: Preview dari pengguna lain
- **WHEN** pesan terakhir dikirim oleh pengguna lain
- **THEN** preview menampilkan nama pengirim + cuplikan pesan

---

### Requirement: Contextual empty state
Halaman chat spaces SHALL menampilkan empty state kontekstual.

#### Scenario: Mahasiswa belum memiliki ruang
- **WHEN** mahasiswa membuka halaman dan belum memiliki ruang
- **THEN** sistem menampilkan ilustrasi dan pesan "Anda belum memiliki ruang diskusi"
- **AND** menampilkan tombol "Buat ruang baru" dan "Gabung ruang"

#### Scenario: Hasil filter kosong
- **WHEN** filter aktif menghasilkan 0 ruang
- **THEN** sistem menampilkan pesan "Tidak ada ruang dengan filter ini"
- **AND** menampilkan tombol "Hapus semua filter"

#### Scenario: Hasil pencarian kosong
- **WHEN** pencarian tidak menghasilkan ruang yang cocok
- **THEN** sistem menampilkan pesan "Tidak ada ruang yang cocok dengan pencarian"
- **AND** menampilkan saran "Coba kata kunci lain"

#### Scenario: Loading state
- **WHEN** data ruang sedang dimuat
- **THEN** sistem SHALL menampilkan skeleton loading pada kartu ruang

---

### Requirement: Pagination
Halaman chat spaces SHALL mendukung pagination untuk daftar ruang.

#### Scenario: Mahasiswa membuka halaman dengan banyak ruang
- **WHEN** jumlah ruang melebihi batas per halaman
- **THEN** sistem SHALL menampilkan kontrol pagination di bagian bawah
- **AND** menampilkan informasi "Menampilkan X-Y dari Z ruang"

#### Scenario: Mahasiswa berpindah halaman
- **WHEN** mahasiswa menekan halaman berikutnya
- **THEN** daftar ruang SHALL diperbarui dengan data halaman baru
- **AND** URL query parameter diperbarui dengan nomor halaman

#### Scenario: Filter/sort berubah
- **WHEN** mahasiswa mengubah filter atau sort
- **THEN** sistem SHALL reset ke halaman 1
- **AND** URL query parameter diperbarui
