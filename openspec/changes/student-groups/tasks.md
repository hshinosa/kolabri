## 1. Member Search

- [x] 1.1 Buat controller `GroupMemberController` dengan endpoint GET search
- [x] 1.2 Implement pencarian berdasarkan nama dan email
- [x] 1.3 Tambah filter berdasarkan peran (admin, member)
- [x] 1.4 Tambah indikator status online/offline
- [x] 1.5 Buat komponen `MemberSearch.tsx` dengan debounce
- [x] 1.6 Buat komponen `MemberCard.tsx` dengan info lengkap
- [x] 1.7 Tampilkan empty state "Tidak ada anggota yang cocok"
- [x] 1.8 Implement pagination untuk daftar anggota besar

## 2. Activity Feed

- [x] 2.1 Buat migration: tabel `group_activities` (handled by external API)
- [x] 2.2 Buat model `GroupActivity` dengan relasi (handled by external API)
- [x] 2.3 Buat controller `GroupActivityController` dengan endpoint GET
- [x] 2.4 Definisikan jenis aktivitas: member_joined, member_left, task_submitted, comment_added, document_updated, settings_changed
- [x] 2.5 Implement logging aktivitas di setiap aksi terkait (proxied to API)
- [x] 2.6 Implement pagination cursor-based untuk feed
- [x] 2.7 Tambah filter berdasarkan jenis aktivitas
- [x] 2.8 Buat komponen `ActivityFeed.tsx` dengan desain timeline
- [x] 2.9 Buat komponen `ActivityItem.tsx` dengan ikon berdasarkan jenis
- [x] 2.10 Implement "Muat lebih banyak" untuk pagination
- [x] 2.11 Tambah badge "Baru" untuk aktivitas yang belum dibaca
- [x] 2.12 Tampilkan empty state "Belum ada aktivitas"

## 3. Group Settings

- [x] 3.1 Buat migration: tambah kolom `description`, `access_policy`, `avatar_url` pada tabel `groups` (handled by external API)
- [x] 3.2 Buat controller `GroupSettingsController` dengan GET/PATCH endpoint
- [x] 3.3 Implement validasi: hanya admin/owner yang bisa mengubah
- [x] 3.4 Implement validasi nama: wajib, maksimal 100 karakter
- [x] 3.5 Buat komponen `GroupSettings.tsx` dengan form
- [x] 3.6 Buat komponen `SettingsForm.tsx` dengan validasi client-side
- [x] 3.7 Tambah konfirmasi sebelum mengubah kebijakan akses
- [x] 3.8 Catat perubahan pengaturan di activity feed (proxied to API)
- [x] 3.9 Tampilkan pesan error untuk validasi yang gagal
- [x] 3.10 Tampilkan pesan sukses setelah penyimpanan

## 4. Member Management

- [x] 4.1 Buat controller `GroupMemberManagementController` dengan PATCH/DELETE endpoint
- [x] 4.2 Implement validasi: hanya owner yang bisa mengubah peran
- [x] 4.3 Implement validasi: hanya admin/owner yang bisa menghapus anggota
- [x] 4.4 Buat komponen `MemberManagement.tsx` dengan aksi
- [x] 4.5 Implement konfirmasi sebelum menghapus anggota
- [x] 4.6 Batasi: owner tidak bisa dihapus atau diubah perannya
- [x] 4.7 Catat perubahan peran dan penghapusan di activity feed (proxied to API)

## 5. Integrasi & State

- [x] 5.1 Buat custom hook `useGroupMembers.ts` untuk data anggota
- [x] 5.2 Buat custom hook `useActivityFeed.ts` untuk data aktivitas
- [x] 5.3 Implement caching dan invalidation data (via @tanstack/react-query)
- [x] 5.4 Tambah error handling dan retry mechanism
- [x] 5.5 Pastikan permission check konsisten di frontend dan backend

## 6. Validasi & QA

- [x] 6.1 Uji pencarian anggota: nama, email, peran, empty result
- [x] 6.2 Uji activity feed: semua jenis aktivitas, filter, pagination
- [x] 6.3 Uji pengaturan: validasi nama, deskripsi, kebijakan akses
- [x] 6.4 Uji manajemen anggota: ubah peran, hapus anggota, permission
- [x] 6.5 Uji empty state untuk semua kondisi
- [x] 6.6 Uji permission: admin vs member vs owner
- [x] 6.7 Uji performa pada grup besar (>50 anggota, >100 aktivitas)
- [x] 6.8 Uji responsivitas UI pada mobile dan desktop
