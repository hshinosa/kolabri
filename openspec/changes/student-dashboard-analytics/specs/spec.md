## ADDED Requirements

### Requirement: Radar chart analytics
Dashboard personal SHALL menampilkan radar chart kompetensi.

#### Scenario: Mahasiswa melihat ringkasan kompetensi
- **WHEN** mahasiswa membuka dashboard analytics
- **THEN** sistem SHALL menampilkan "Radar kompetensi"
- **AND** radar menampilkan 6 dimensi: Pengetahuan, Keterampilan, Kolaborasi, Refleksi, Konsistensi, Partisipasi
- **AND** setiap dimensi memiliki skala 0-100 yang dinormalisasi

#### Scenario: Detail per dimensi
- **WHEN** mahasiswa mengarahkan kursor ke salah satu sumbu radar
- **THEN** sistem SHALL menampilkan tooltip dengan:
  - Nama dimensi
  - Skor (0-100)
  - Detail perhitungan (misal: "Quiz rata-rata 85, Ujian rata-rata 82")

#### Scenario: Radar berdasarkan periode
- **WHEN** mahasiswa memilih periode (minggu, bulan, semester)
- **THEN** radar SHALL diperbarui menampilkan data dari periode tersebut

#### Scenario: Dimensi tanpa data
- **WHEN** mahasiswa belum memiliki data untuk salah satu dimensi
- **THEN** dimensi tersebut menampilkan skor 0
- **AND** tooltip menampilkan "Belum ada data"

#### Scenario: Radar menunjukkan kekuatan
- **WHEN** salah satu dimensi memiliki skor ≥ 80
- **THEN** dimensi tersebut di-highlight dengan warna hijau
- **AND** tooltip menampilkan "Kekuatan Anda"

#### Scenario: Radar menunjukkan area perbaikan
- **WHEN** salah satu dimensi memiliki skor < 50
- **THEN** dimensi tersebut di-highlight dengan warna oranye
- **AND** tooltip menampilkan "Area yang perlu ditingkatkan"

---

### Requirement: Progress timeline
Dashboard personal SHALL menampilkan timeline progres belajar.

#### Scenario: Mahasiswa meninjau perkembangan waktu
- **WHEN** mahasiswa membuka bagian "Timeline progres"
- **THEN** sistem SHALL menampilkan milestone berdasarkan urutan waktu
- **AND** setiap milestone menampilkan: ikon, judul, tanggal, deskripsi

#### Scenario: Jenis milestone ditampilkan
- **WHEN** timeline ditampilkan
- **THEN** sistem menampilkan ikon berdasarkan jenis:
  - Course dimulai/diselesaikan
  - Tugas dikumpulkan
  - Refleksi ditulis
  - Streak tercapai

#### Scenario: Filter timeline berdasarkan periode
- **WHEN** mahasiswa memilih periode (minggu, bulan, semester)
- **THEN** timeline hanya menampilkan milestone dari periode tersebut

#### Scenario: Filter berdasarkan jenis
- **WHEN** mahasiswa memilih filter "Tugas"
- **THEN** timeline hanya menampilkan milestone terkait tugas

#### Scenario: Klik milestone
- **WHEN** mahasiswa menekan salah satu milestone
- **THEN** sistem menampilkan detail milestone
- **AND** menavigasi ke halaman terkait jika ada

#### Scenario: Timeline kosong
- **WHEN** tidak ada milestone dalam periode yang dipilih
- **THEN** sistem menampilkan pesan "Tidak ada milestone dalam periode ini"
- **AND** menampilkan saran "Mulai belajar untuk membuat milestone"

---

### Requirement: Activity heatmap
Dashboard personal SHALL menampilkan heatmap aktivitas.

#### Scenario: Mahasiswa melihat pola konsistensi
- **WHEN** mahasiswa membuka bagian "Heatmap aktivitas"
- **THEN** sistem SHALL menampilkan grid 7 kolom (Sen-Min) x N baris (minggu)
- **AND** setiap sel menampilkan warna berdasarkan intensitas aktivitas

#### Scenario: Level intensitas
- **WHEN** heatmap ditampilkan
- **THEN** sistem menggunakan skala warna:
  - Abu-abu: Tidak ada aktivitas
  - Hijau muda: 1-2 aktivitas
  - Hijau sedang: 3-5 aktivitas
  - Hijau tua: ≥ 6 aktivitas

#### Scenario: Tooltip per hari
- **WHEN** mahasiswa mengarahkan kursor ke sel heatmap
- **THEN** sistem menampilkan tooltip:
  - Tanggal
  - Jumlah aktivitas
  - Jenis aktivitas

#### Scenario: Heatmap berdasarkan jumlah minggu
- **WHEN** mahasiswa memilih jumlah minggu (4, 8, 12)
- **THEN** heatmap diperbarui menampilkan data sesuai jumlah minggu

#### Scenario: Summary heatmap
- **WHEN** heatmap ditampilkan
- **THEN** sistem menampilkan ringkasan:
  - Total hari aktif
  - Streak saat ini
  - Streak terpanjang

#### Scenario: Tidak ada aktivitas
- **WHEN** mahasiswa belum memiliki aktivitas
- **THEN** heatmap menampilkan semua sel abu-abu
- **AND** menampilkan pesan "Mulai belajar untuk melihat pola aktivitas"

---

### Requirement: Performance trends
Dashboard personal SHALL menampilkan tren metrik utama.

#### Scenario: Mahasiswa membaca tren performa
- **WHEN** data periode tersedia
- **THEN** sistem SHALL menampilkan panel "Tren performa"
- **AND** panel menampilkan 4 kartu tren:
  - Tugas selesai
  - Rata-rata nilai
  - Streak
  - Waktu belajar

#### Scenario: Tren naik
- **WHEN** metrik meningkat dari periode sebelumnya
- **THEN** kartu menampilkan:
  - Nilai saat ini
  - Indikator ▲ hijau
  - Persentase perubahan
  - Narasi: "Meningkat X% dari [periode] lalu"

#### Scenario: Tren turun
- **WHEN** metrik menurun dari periode sebelumnya
- **THEN** kartu menampilkan:
  - Nilai saat ini
  - Indikator ▼ merah
  - Persentase perubahan
  - Narasi: "Menurun X% dari [periode] lalu"

#### Scenario: Tren stabil
- **WHEN** metrik tidak berubah signifikan (< 5%)
- **THEN** kartu menampilkan:
  - Nilai saat ini
  - Indikator ─ abu-abu
  - Narasi: "Stabil dibanding [periode] lalu"

#### Scenario: Data periode sebelumnya tidak ada
- **WHEN** tidak ada data dari periode sebelumnya
- **THEN** kartu menampilkan nilai saat ini
- **AND** menampilkan "Baru" sebagai indikator

#### Scenario: Pilih periode tren
- **WHEN** mahasiswa memilih periode (minggu, bulan, semester)
- **THEN** semua kartu tren diperbarui membandingkan dengan periode yang sama sebelumnya

---

### Requirement: Period selector
Dashboard analytics SHALL menyediakan selector periode.

#### Scenario: Mahasiswa memilih periode
- **WHEN** mahasiswa memilih periode (Minggu, Bulan, Semester)
- **THEN** semua komponen analytics SHALL diperbarui menampilkan data dari periode tersebut

#### Scenario: Default periode
- **WHEN** mahasiswa pertama kali membuka dashboard
- **THEN** sistem menampilkan data dengan periode default "Bulan"

#### Scenario: Periode tersimpan di URL
- **WHEN** mahasiswa memilih periode
- **THEN** pilihan tersimpan di URL query parameter
- **AND** URL dapat dibagikan dengan periode yang sama

---

### Requirement: Responsive layout
Dashboard analytics SHALL mendukung tampilan responsif.

#### Scenario: Tampilan desktop
- **WHEN** mahasiswa mengakses dari desktop
- **THEN** sistem menampilkan layout grid 2 kolom:
  - Kolom kiri: Radar chart + Heatmap
  - Kolom kanan: Timeline + Trend cards

#### Scenario: Tampilan mobile
- **WHEN** mahasiswa mengakses dari mobile
- **THEN** sistem menampilkan layout stack vertikal:
  - Radar chart
  - Heatmap
  - Timeline
  - Trend cards

#### Scenario: Expand/collapse komponen
- **WHEN** mahasiswa menekan tombol expand/collapse pada komponen
- **THEN** komponen tersebut diperluas atau diciutkan
- **AND** state tersimpan di localStorage

---

### Requirement: Empty and loading states
Dashboard analytics SHALL menampilkan state yang sesuai.

#### Scenario: Loading state
- **WHEN** data analytics sedang dimuat
- **THEN** sistem menampilkan skeleton loading untuk setiap komponen

#### Scenario: Belum ada data analytics
- **WHEN** mahasiswa baru pertama kali mengakses platform
- **THEN** sistem menampilkan pesan "Mulai belajar untuk melihat analytics"
- **AND** menampilkan CTA ke halaman courses

#### Scenario: Error memuat data
- **WHEN** API mengembalikan error
- **THEN** sistem menampilkan pesan "Gagal memuat analytics"
- **AND** menampilkan tombol "Coba lagi"

#### Scenario: Data tidak lengkap
- **WHEN** beberapa dimensi tidak memiliki data
- **THEN** sistem menampilkan komponen yang tersedia
- **AND** komponen tanpa data menampilkan "Belum ada data"
