## 1. Edit & Hapus Pesan

- [x] 1.1 Buat migration: tambah kolom `edited_at`, `is_deleted`, `deleted_at` pada tabel `chat_messages`
- [x] 1.2 Buat migration: tabel `chat_message_audit`
- [x] 1.3 Buat model `ChatMessageAudit` dengan relasi
- [x] 1.4 Buat controller `MessageController` dengan endpoint PATCH (edit) dan DELETE (hapus)
- [x] 1.5 Implement validasi kepemilikan: hanya pengirim yang bisa edit
- [x] 1.6 Implement batas waktu edit: 24 jam setelah pengiriman
- [x] 1.7 Implement validasi moderator: bisa hapus pesan orang lain
- [x] 1.8 Buat audit trail untuk setiap edit dan hapus
- [x] 1.9 Buat komponen `MessageActions.tsx` (toolbar edit/hapus/pin)
- [x] 1.10 Buat komponen `MessageEditor.tsx` (editor inline)
- [x] 1.11 Implement soft delete: ganti konten dengan "[Pesan telah dihapus]"
- [x] 1.12 Tambah label "Diedit" pada pesan yang sudah diedit
- [x] 1.13 Broadcast perubahan ke semua user di room via Socket.io

## 2. Pencarian Pesan

- [x] 2.1 Buat migration: tambah full-text index pada kolom `content` tabel `chat_messages`
- [x] 2.2 Buat controller `MessageSearchController` dengan endpoint GET
- [x] 2.3 Implement logika pencarian dengan full-text search
- [x] 2.4 Implement pagination cursor-based
- [x] 2.5 Buat komponen `SearchBar.tsx` di header chat room
- [x] 2.6 Buat komponen `SearchResults.tsx` dengan highlighted snippet
- [x] 2.7 Implement debounce 300ms pada input pencarian
- [x] 2.8 Implement scroll-to-message saat hasil diklik
- [x] 2.9 Tambah highlight sementara pada pesan yang ditemukan

## 3. Pinning Pesan

- [x] 3.1 Buat migration: tabel `pinned_messages`
- [x] 3.2 Buat model `PinnedMessage` dengan relasi
- [x] 3.3 Buat controller `PinnedMessageController` dengan endpoint POST (pin) dan DELETE (unpin)
- [x] 3.4 Implement batas maksimal 10 pin per ruang
- [x] 3.5 Implement validasi: hanya moderator dan owner yang bisa pin
- [x] 3.6 Buat komponen `PinnedMessages.tsx` (panel expandable di atas)
- [x] 3.7 Tambah tombol "Pin" pada menu aksi pesan
- [x] 3.8 Tambah tombol "Unpin" pada panel pesan dipin
- [x] 3.9 Broadcast event pin/unpin ke semua user di room
- [x] 3.10 Tambah animasi saat panel dibuka/ditutup

## 4. Integrasi & Testing

- [x] 4.1 Integrasi semua komponen ke halaman `room.tsx`
- [x] 4.2 Update socket handler untuk edit_message, delete_message, pin_message, unpin_message
- [x] 4.3 Tambah loading state untuk setiap aksi
- [x] 4.4 Tambah error handling dan toast notification
- [x] 4.5 Test integrasi: edit → broadcast → semua user melihat perubahan
- [x] 4.6 Test integrasi: search → klik hasil → scroll ke pesan
- [x] 4.7 Test integrasi: pin → panel muncul → unpin → panel hilang
- [x] 4.8 Test edge case: edit pesan yang sudah dihapus
- [x] 4.9 Test edge case: pin lebih dari 10 pesan
- [x] 4.10 Test edge case: search dengan hasil kosong
