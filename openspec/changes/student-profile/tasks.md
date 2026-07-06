## 1. Avatar Upload

- [x] 1.1 Buat migration: tambah kolom `avatar_url`, `avatar_thumbnail` pada tabel `users`
- [x] 1.2 Buat controller `ProfileAvatarController` dengan POST/DELETE endpoint
- [x] 1.3 Implement validasi file: format (JPEG, PNG, WebP), ukuran (maks 2MB)
- [x] 1.4 Implement server-side resize ke beberapa ukuran (50x50, 200x200, 500x500)
- [x] 1.5 Simpan file ke storage (S3 atau local)
- [x] 1.6 Hapus avatar lama saat upload baru
- [x] 1.7 Buat komponen `AvatarUpload.tsx` dengan preview dan crop
- [x] 1.8 Implement client-side crop dengan aspect ratio 1:1
- [x] 1.9 Buat komponen `AvatarDisplay.tsx` dengan fallback inisial
- [x] 1.10 Generate inisial dari huruf pertama nama depan dan belakang
- [x] 1.11 Tambah konfirmasi sebelum menghapus avatar
- [x] 1.12 Tampilkan progress indicator saat upload
- [x] 1.13 Update avatar di seluruh aplikasi setelah upload berhasil

## 2. Statistik Aktivitas

- [x] 2.1 Buat controller `ProfileStatsController` dengan endpoint GET
- [x] 2.2 Implement agregasi course aktif dari tabel enrollment
- [x] 2.3 Implement agregasi tugas selesai dari tabel submissions
- [x] 2.4 Buat migration: tabel `user_activity_streak`
- [x] 2.5 Implement tracking streak: catat aktivitas harian
- [x] 2.6 Implement perhitungan streak beruntun
- [x] 2.7 Implement agregasi total refleksi dari tabel reflections
- [x] 2.8 Cache hasil statistik untuk performa
- [x] 2.9 Buat komponen `StatsSection.tsx`
- [x] 2.10 Buat komponen `StatCard.tsx` dengan ikon dan label
- [x] 2.11 Tambah animasi untuk streak aktif (api/ikon)
- [x] 2.12 Update statistik real-time saat data berubah

## 3. Preferensi Pengguna

- [x] 3.1 Buat migration: tabel `user_preferences`
- [x] 3.2 Buat model `UserPreference` dengan relasi ke `User`
- [x] 3.3 Buat controller `ProfilePreferenceController` dengan GET/PATCH endpoint
- [x] 3.4 Seed preferensi default saat user baru dibuat
- [x] 3.5 Buat komponen `PreferencesSection.tsx`
- [x] 3.6 Buat komponen `NotificationPrefs.tsx` dengan toggle
- [x] 3.7 Buat komponen `LanguagePrefs.tsx` dengan dropdown
- [x] 3.8 Buat komponen `ThemePrefs.tsx` dengan pilihan tema
- [x] 3.9 Implement auto-save saat preferensi berubah
- [x] 3.10 Implement penerapan tema saat preferensi berubah
- [x] 3.11 Implement penerapan bahasa saat preferensi berubah
- [x] 3.12 Simpan preferensi ke cookie/localStorage untuk persistensi
- [x] 3.13 Tampilkan notifikasi "Preferensi tersimpan"

## 4. Integrasi & State

- [x] 4.1 Buat custom hook `useProfile.ts` untuk data profil
- [x] 4.2 Buat custom hook `usePreferences.ts` untuk preferensi
- [x] 4.3 Implement caching dan invalidation data
- [x] 4.4 Tambah error handling dan retry mechanism
- [x] 4.5 Pastikan preferensi diterapkan saat login

## 5. Validasi & QA

- [x] 5.1 Uji upload avatar: valid, tidak valid, crop, hapus
- [x] 5.2 Uji statistik: akurasi data, streak, update real-time
- [x] 5.3 Uji preferensi: notifikasi, bahasa, tema, auto-save
- [x] 5.4 Uji fallback avatar: inisial, warna konsisten
- [x] 5.5 Uji empty state untuk semua kondisi
- [x] 5.6 Uji performa pada profil dengan banyak data
- [x] 5.7 Uji responsivitas UI pada mobile dan desktop
- [x] 5.8 Security review: validasi file, otorisasi upload
