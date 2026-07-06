## ADDED Requirements

### Requirement: Avatar upload
Halaman profile SHALL menyediakan unggah avatar.

#### Scenario: Mahasiswa mengupload foto profil baru
- **WHEN** mahasiswa menekan tombol "Unggah avatar" dan memilih file
- **THEN** sistem SHALL memvalidasi format (JPEG, PNG, WebP) dan ukuran (maks 2MB)
- **AND** menampilkan preview dengan opsi crop
- **AND** avatar baru tampil setelah menekan "Simpan avatar"

#### Scenario: File tidak valid
- **WHEN** mahasiswa memilih file dengan format atau ukuran tidak valid
- **THEN** sistem menampilkan pesan "Format file tidak didukung" atau "Ukuran file terlalu besar (maks 2MB)"
- **AND** proses upload tidak dilanjutkan

#### Scenario: Crop avatar
- **WHEN** mahasiswa mengupload foto
- **THEN** sistem menampilkan tool crop dengan aspect ratio 1:1
- **AND** mahasiswa bisa menyesuaikan area crop sebelum menyimpan

#### Scenario: Hapus avatar
- **WHEN** mahasiswa menekan "Hapus avatar"
- **THEN** sistem menampilkan konfirmasi "Hapus foto profil?"
- **AND** avatar dihapus dan diganti dengan inisial nama

#### Scenario: Gagal upload
- **WHEN** proses upload gagal karena error server
- **THEN** sistem menampilkan pesan "Gagal mengupload avatar, silakan coba lagi"
- **AND** avatar sebelumnya tetap digunakan

#### Scenario: Avatar ditampilkan di seluruh aplikasi
- **WHEN** avatar berhasil diupload
- **THEN** avatar baru SHALL tampil di header, komentar, chat, dan profil lainnya
- **AND** avatar lama dihapus dari storage

---

### Requirement: Activity statistics
Halaman profile SHALL menampilkan statistik aktivitas.

#### Scenario: Mahasiswa melihat ringkasan aktivitas
- **WHEN** halaman profil dimuat
- **THEN** sistem SHALL menampilkan "Statistik aktivitas"
- **AND** statistik mencakup:
  - Course aktif (jumlah)
  - Tugas selesai (jumlah)
  - Streak aktivitas (hari berturut-turut)
  - Total refleksi (jumlah)

#### Scenario: Streak aktivitas
- **WHEN** mahasiswa mengakses platform setiap hari
- **THEN** sistem menampilkan "Streak: X hari"
- **AND** menampilkan api/ikon untuk streak aktif

#### Scenario: Streak terputus
- **WHEN** mahasiswa tidak mengakses platform selama 1 hari
- **THEN** streak di-reset ke 0
- **AND** statistik menampilkan streak terpanjang

#### Scenario: Statistik diperbarui real-time
- **WHEN** mahasiswa menyelesaikan tugas atau mengakses platform
- **THEN** statistik diperbarui tanpa refresh halaman

#### Scenario: Data statistik kosong
- **WHEN** mahasiswa baru pertama kali mengakses platform
- **THEN** sistem menampilkan statistik dengan nilai 0
- **AND** menampilkan pesan "Mulai belajar untuk melihat statistik"

---

### Requirement: User preferences
Halaman profile SHALL menyediakan pengaturan preferensi.

#### Scenario: Mahasiswa membuka pengaturan preferensi
- **WHEN** mahasiswa membuka bagian "Preferensi"
- **THEN** sistem SHALL menampilkan opsi:
  - Notifikasi (email, push, tugas, chat, grup)
  - Bahasa (Indonesia, English)
  - Tampilan (tema, ukuran font)

#### Scenario: Mengubah preferensi notifikasi
- **WHEN** mahasiswa mengtoggle notifikasi email
- **THEN** sistem menyimpan perubahan
- **AND** notifikasi email diaktifkan/nonaktifkan sesuai pilihan

#### Scenario: Mengubah bahasa
- **WHEN** mahasiswa memilih bahasa "English"
- **THEN** sistem menyimpan preferensi
- **AND** seluruh UI berubah ke bahasa Inggris
- **AND** preferensi diterapkan pada sesi berikutnya

#### Scenario: Mengubah tema
- **WHEN** mahasiswa memilih tema "Dark"
- **THEN** sistem menyimpan preferensi
- **AND** tampilan berubah ke dark mode
- **AND** preferensi diterapkan pada sesi berikutnya

#### Scenario: Preferensi tersimpan otomatis
- **WHEN** mahasiswa mengubah preferensi
- **THEN** sistem menyimpan perubahan secara otomatis (auto-save)
- **AND** menampilkan notifikasi "Preferensi tersimpan"

#### Scenario: Gagal menyimpan preferensi
- **WHEN** proses penyimpanan gagal
- **THEN** sistem menampilkan pesan "Gagal menyimpan preferensi"
- **AND** mengembalikan ke state sebelumnya

---

### Requirement: Profile information display
Halaman profile SHALL menampilkan informasi dasar mahasiswa.

#### Scenario: Informasi dasar ditampilkan
- **WHEN** halaman profil dimuat
- **THEN** sistem menampilkan: nama lengkap, NIM, email, jurusan
- **AND** informasi bersifat read-only (tidak bisa diedit)

#### Scenario: Avatar dengan fallback
- **WHEN** mahasiswa belum mengupload avatar
- **THEN** sistem menampilkan inisial nama dengan background berwarna
- **AND** inisial diambil dari huruf pertama nama depan dan belakang

---

### Requirement: Empty and loading states
Halaman profile SHALL menampilkan state yang sesuai.

#### Scenario: Loading state
- **WHEN** data profil sedang dimuat
- **THEN** sistem menampilkan skeleton loading untuk setiap section

#### Scenario: Error memuat data
- **WHEN** API mengembalikan error
- **THEN** sistem menampilkan pesan "Gagal memuat profil"
- **AND** menampilkan tombol "Coba lagi"

#### Scenario: Upload sedang diproses
- **WHEN** avatar sedang diupload
- **THEN** sistem menampilkan progress indicator
- **AND** tombol upload disabled selama proses
