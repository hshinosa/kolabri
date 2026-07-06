## Why

Halaman Groups mahasiswa saat ini menampilkan daftar grup secara sederhana tanpa kemampuan pencarian anggota, ringkasan aktivitas, atau pengaturan yang memadai. Untuk kerja tim yang efektif, mahasiswa membutuhkan visibilitas aktivitas grup, kemampuan mencari anggota, dan pengaturan dasar yang jelas.

Permasalahan utama:
- **Member visibility**: Tidak ada cara mencari anggota dalam grup besar
- **Activity awareness**: Tidak ada feed aktivitas yang menunjukkan apa yang terjadi di grup
- **Group management**: Pengaturan grup terbatas, tidak bisa mengubah nama atau deskripsi
- **Coordination**: Mahasiswa tidak tahu siapa yang sudah mengerjakan apa

## What Changes

### 1. Pencarian Anggota Grup
Menambahkan kolom pencarian di halaman grup untuk mencari anggota berdasarkan nama dan identifier.

### 2. Activity Feed Grup
Menambahkan feed aktivitas yang menampilkan event penting: anggota bergabung, kirim tugas, komentar, update dokumen.

### 3. Pengaturan Grup
Menambahkan halaman pengaturan untuk mengubah nama, deskripsi, dan kebijakan akses dasar grup.

## Capabilities

### New Capabilities
- `student-groups-member-search`: Pencarian anggota dalam grup
- `student-groups-activity-feed`: Feed aktivitas terbaru grup
- `student-groups-settings`: Pengaturan dasar grup

## User Stories

1. **Sebagai mahasiswa**, saya ingin mencari anggota dalam grup sehingga saya bisa menemukan kontak dengan cepat
2. **Sebagai mahasiswa**, saya ingin melihat aktivitas terbaru grup sehingga saya tahu perkembangan kerja tim
3. **Sebagai mahasiswa**, saya ingin mengubah pengaturan grup sehingga informasi grup tetap akurat
4. **Sebagai mahasiswa**, saya ingin melihat siapa yang sudah mengumpulkan tugas sehingga saya bisa mengkoordinasikan pekerjaan

## Impact

- **Frontend**: Halaman groups, komponen feed dan settings, panel pencarian anggota
- **Backend/API**: Endpoint member search, activity feed, group settings update
- **Data**: Tabel activity log, kolom pengaturan grup
- **Breaking changes**: Tidak ada

## Success Metrics

- Penurunan waktu menemukan anggota dalam grup ≥ 60%
- Peningkatan awareness aktivitas grup ≥ 40%
- Penggunaan fitur pengaturan ≥ 20% dari grup aktif
- Rata-rata koordinasi tugas kelompok lebih efisien
