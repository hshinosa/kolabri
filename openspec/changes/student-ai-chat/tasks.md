## 1. Search Percakapan AI

- [x] 1.1 Buat migration: tambah full-text index pada tabel `chat_sessions` dan `chat_messages`
- [x] 1.2 Buat controller `AiChatSearchController` dengan endpoint `GET /api/student/ai-chat/sessions`
- [x] 1.3 Implement logika pencarian dengan full-text search dan filter (bookmarked)
- [x] 1.4 Tambah komponen `SearchBar.tsx` di `ChatSidebar`
- [x] 1.5 Implement debounce 300ms dan loading state pada pencarian
- [x] 1.6 Tambah komponen `SearchResultItem.tsx` dengan highlighted snippet
- [x] 1.7 Tampilkan empty state "Tidak ada percakapan yang cocok" jika hasil kosong
- [x] 1.8 Sinkronkan state pencarian dengan URL query parameter

## 2. Template Prompt

- [x] 2.1 Buat migration: tabel `prompt_templates`
- [x] 2.2 Buat model `PromptTemplate` dengan relasi ke `User`
- [x] 2.3 Buat controller `AiChatTemplateController` dengan CRUD endpoint
- [x] 2.4 Seed template global default dari admin
- [x] 2.5 Buat komponen `TemplatePanel.tsx` (drawer di sisi input chat)
- [x] 2.6 Buat komponen `TemplateCard.tsx` dengan aksi gunakan/edit/hapus
- [x] 2.7 Buat komponen `TemplateManager.tsx` (modal buat/edit template)
- [x] 2.8 Implement auto-fill input chat saat template dipilih
- [x] 2.9 Tambah validasi: maksimal 50 template personal per user

## 3. Bookmark Pesan

- [x] 3.1 Buat migration: tabel `chat_bookmarks` dengan unique constraint
- [x] 3.2 Buat model `ChatBookmark` dengan relasi ke `ChatMessage` dan `User`
- [x] 3.3 Buat controller `AiChatBookmarkController` dengan CRUD endpoint
- [x] 3.4 Buat komponen `BookmarkButton.tsx` (ikon bintang) pada pesan AI
- [x] 3.5 Buat komponen `BookmarkPanel.tsx` (drawer daftar bookmark)
- [x] 3.6 Implement navigasi: klik bookmark → scroll ke pesan asli
- [x] 3.7 Tambah filter "Hanya bookmarked" di sidebar
- [x] 3.8 Tambah highlight visual pada pesan yang dibookmark

## 4. Integrasi & Testing

- [x] 4.1 Integrasi semua komponen baru ke halaman AI chat
- [x] 4.2 Update socket handler untuk sinkronisasi real-time
- [x] 4.3 Tambah loading state untuk setiap aksi
- [x] 4.4 Tambah error handling dan toast notification
- [x] 4.5 Test integrasi: search → klik hasil → navigasi ke sesi
- [x] 4.6 Test integrasi: template → auto-fill → kirim pesan
- [x] 4.7 Test integrasi: bookmark → panel → navigasi ke pesan
- [x] 4.8 Test edge case: search dengan hasil kosong
- [x] 4.9 Test edge case: bookmark pesan yang sudah dihapus
