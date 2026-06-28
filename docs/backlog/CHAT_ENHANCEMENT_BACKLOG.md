# Chat Enhancement Backlog

Daftar enhancement yang belum dikerjakan, disimpan untuk referensi masa depan.

## High Impact — Core UX

### 1. Message Threading
- Balasan spesifik ke satu pesan, bukan semua ke bawah
- Side thread panel dengan parent message, reply count
- "Show in room" / broadcast toggle untuk jawaban penting
- **References**: [Slack threads](https://slack.com/help/articles/115000769927-Use-threads-to-organize-discussions), [Discord threads](https://docs.discord.com/developers/topics/threads)
- **Effort**: High
- **Impact**: High

### 2. Message Search
- Cari pesan berisi keyword/tanggal/author
- Search bar di header chat
- Highlight hasil pencarian di message list
- **Effort**: Medium
- **Impact**: High

### 3. Message Edit/Delete
- Edit atau hapus pesan yang sudah terkirim
- Tampilkan "edited" label jika sudah diedit
- Toast notifikasi saat pesan dihapus
- **Effort**: Medium
- **Impact**: High

### 4. Emoji Reactions
- React pesan dengan emoji (👍, ❤️, 💡, 🎯)
- Tampilkan reaction count di bawah pesan
- Toggle reaction dengan klik
- **Effort**: Medium
- **Impact**: High

### 5. Message Pinning
- Pin pesan penting (syarat, materi, tugas)
- Pinned messages panel di sidebar
- Notifikasi saat ada pesan baru di-pin
- **Effort**: Low-Medium
- **Impact**: Medium

## Medium Impact — Educational Features

### 6. Unread Badge
- Notif jumlah pesan belum dibaca per course
- Badge di sidebar navigation
- Clear on visit
- **Effort**: Medium
- **Impact**: Medium

### 7. Message Forward
- Forward pesan ke grup lain
- Modal pilih grup tujuan
- Copy pesan asli dengan attribution
- **Effort**: Medium
- **Impact**: Medium

### 8. Code Block Syntax Highlighting
- Render code dengan highlight sesuai bahasa
- Copy code button
- Language detection atau manual selection
- **Effort**: Low
- **Impact**: Medium

### 9. Link Preview
- Preview URL yang dishare (og:image, title, description)
- Card-style preview di bawah pesan
- Caching untuk performa
- **Effort**: Medium
- **Impact**: Medium

## Low Impact — Polish & Accessibility

### 10. Keyboard Shortcuts
- Cmd+K: Search
- Cmd+R: Reply
- Esc: Cancel
- **Effort**: Low
- **Impact**: Low

### 11. Message Timestamp Hover
- Hover untuk lihat waktu lengkap
- Relative time (2 menit lalu) + absolute time
- **Effort**: Trivial
- **Impact**: Low

### 12. Compact View Toggle
- Mode hemat ruang untuk chat panjang
- Sembunyikan avatars, rapatkan spacing
- **Effort**: Low
- **Impact**: Low

## Technical Debt

### 13. Service Worker Cache
- Cache chat history untuk offline read
- Background sync untuk pesan baru
- **Effort**: High
- **Impact**: Low (mobile-first)

### 14. Message Batch Rendering
- Render messages in chunks untuk list panjang
- Intersection Observer untuk lazy loading
- **Effort**: Medium
- **Impact**: Low (sudah ada virtualization)

---

*Last updated: 2026-05-23*
