## ADDED Requirements

### Requirement: Member search
Halaman groups SHALL menyediakan pencarian anggota.

#### Scenario: Mahasiswa mencari anggota berdasarkan nama
- **WHEN** mahasiswa mengetik di kolom "Cari anggota"
- **THEN** sistem SHALL menampilkan anggota yang cocok berdasarkan nama
- **AND** hasil menampilkan nama, foto, dan peran

#### Scenario: Mahasiswa mencari anggota berdasarkan email
- **WHEN** mahasiswa mengetik email di kolom pencarian
- **THEN** sistem SHALL menampilkan anggota yang cocok berdasarkan email
- **AND** hasil menampilkan informasi lengkap anggota

#### Scenario: Filter berdasarkan peran
- **WHEN** mahasiswa memilih filter peran "Admin"
- **THEN** sistem SHALL menampilkan hanya anggota dengan peran admin
- **AND** filter dapat digabungkan dengan pencarian nama

#### Scenario: Pencarian kosong
- **WHEN** tidak ada anggota yang cocok dengan kata kunci
- **THEN** sistem SHALL menampilkan pesan "Tidak ada anggota yang cocok"

#### Scenario: Status online anggota
- **WHEN** daftar anggota ditampilkan
- **THEN** setiap anggota menampilkan indikator status online/offline

---

### Requirement: Activity feed
Halaman groups SHALL menampilkan feed aktivitas grup.

#### Scenario: Mahasiswa membuka feed aktivitas
- **WHEN** halaman grup dimuat
- **THEN** sistem SHALL menampilkan "Aktivitas terbaru"
- **AND** aktivitas diurutkan dari yang paling baru
- **AND** setiap item menampilkan: jenis aktivitas, deskripsi, pelaku, waktu

#### Scenario: Jenis aktivitas ditampilkan
- **WHEN** aktivitas ditampilkan
- **THEN** sistem SHALL menampilkan ikon berdasarkan jenis:
  - Anggota bergabung/keluar
  - Tugas dikumpulkan
  - Komentar baru
  - Dokumen diupdate
  - Pengaturan berubah

#### Scenario: Filter berdasarkan jenis aktivitas
- **WHEN** mahasiswa memilih filter "Tugas"
- **THEN** feed hanya menampilkan aktivitas terkait tugas

#### Scenario: Pagination feed
- **WHEN** feed memiliki banyak aktivitas
- **THEN** sistem SHALL menampilkan kontrol "Muat lebih banyak"
- **AND** memuat 20 aktivitas per halaman

#### Scenario: Aktivitas baru (real-time)
- **WHEN** ada aktivitas baru di grup
- **THEN** sistem SHALL menampilkan badge "Baru" pada item feed
- **AND** menampilkan notifikasi ringan di UI

#### Scenario: Feed kosong
- **WHEN** grup belum memiliki aktivitas
- **THEN** sistem menampilkan pesan "Belum ada aktivitas di grup ini"

---

### Requirement: Group settings
Halaman groups SHALL menyediakan pengaturan dasar grup.

#### Scenario: Admin membuka pengaturan
- **WHEN** pengguna dengan peran admin/owner menekan "Pengaturan grup"
- **THEN** sistem SHALL menampilkan form pengaturan dengan data saat ini

#### Scenario: Mengubah nama grup
- **WHEN** admin mengubah nama grup dan menekan "Simpan"
- **THEN** sistem SHALL memvalidasi nama (wajib, maksimal 100 karakter)
- **AND** nama grup diperbarui di seluruh sistem
- **AND** perubahan dicatat di activity feed

#### Scenario: Mengubah deskripsi grup
- **WHEN** admin mengubah deskripsi dan menekan "Simpan"
- **THEN** sistem SHALL memperbarui deskripsi grup
- **AND** deskripsi ditampilkan di halaman grup

#### Scenario: Mengubah kebijakan akses
- **WHEN** admin mengubah kebijakan akses (terbuka/tertutup)
- **THEN** sistem SHALL memperbarui kebijakan
- **AND** menampilkan konfirmasi sebelum mengubah kebijakan

#### Scenario: Non-admin mencoba mengubah pengaturan
- **WHEN** anggota biasa mencoba mengakses pengaturan
- **THEN** sistem SHALL menampilkan pesan "Hanya admin yang bisa mengubah pengaturan"
- **AND** tombol pengaturan tidak tersedia

#### Scenario: Validasi nama kosong
- **WHEN** admin mengosongkan nama grup
- **THEN** sistem menampilkan error "Nama grup wajib diisi"
- **AND** perubahan tidak disimpan

---

### Requirement: Member management
Halaman groups SHALL menampilkan daftar anggota dengan informasi peran.

#### Scenario: Melihat daftar anggota
- **WHEN** mahasiswa membuka tab "Anggota"
- **THEN** sistem SHALL menampilkan daftar semua anggota
- **AND** setiap anggota menampilkan: nama, foto, peran, status online

#### Scenario: Mengubah peran anggota
- **WHEN** owner menekan "Ubah peran" pada anggota
- **THEN** sistem SHALL menampilkan opsi peran (admin, member)
- **AND** perubahan disimpan setelah konfirmasi
- **AND** perubahan dicatat di activity feed

#### Scenario: Menghapus anggota
- **WHEN** admin menekan "Hapus dari grup" pada anggota
- **THEN** sistem SHALL menampilkan konfirmasi "Hapus [nama] dari grup?"
- **AND** anggota dihapus setelah konfirmasi
- **AND** penghapusan dicatat di activity feed

#### Scenario: Owner tidak bisa dihapus
- **WHEN** admin mencoba menghapus owner grup
- **THEN** sistem menampilkan pesan "Owner grup tidak dapat dihapus"

---

### Requirement: Empty and loading states
Halaman groups SHALL menampilkan state yang sesuai.

#### Scenario: Loading state
- **WHEN** data grup sedang dimuat
- **THEN** sistem SHALL menampilkan skeleton loading

#### Scenario: Grup tidak ditemukan
- **WHEN** ID grup tidak valid
- **THEN** sistem menampilkan pesan "Grup tidak ditemukan"
- **AND** menampilkan tombol "Kembali ke daftar grup"

#### Scenario: Error memuat data
- **WHEN** API mengembalikan error
- **THEN** sistem menampilkan pesan "Gagal memuat data"
- **AND** menampilkan tombol "Coba lagi"
