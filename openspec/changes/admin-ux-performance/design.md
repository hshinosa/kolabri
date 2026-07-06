## Context

Admin pages sudah berfungsi dengan baik, tetapi UX dan performanya bisa ditingkatkan. Saat ini:
- Tidak ada breadcrumb navigation
- Search terbatas per halaman
- Tidak ada notification center
- Tidak ada dark mode
- Tidak ada keyboard shortcuts
- Data loading tanpa pagination
- Tidak ada skeleton loading
- Images langsung load tanpa lazy loading
- Tidak ada data caching

## Goals / Non-Goals

**Goals:**
- Tambah breadcrumb di semua halaman admin
- Implementasi global search
- Tambah notification center dengan history
- Implementasi dark mode toggle
- Tambah keyboard shortcuts
- Implementasi pagination dan infinite scroll
- Tambah skeleton loading
- Implementasi lazy loading untuk images
- Implementasi React Query untuk data caching

**Non-Goals:**
- Tidak mengubah backend API
- Tidak mengubah database schema
- Tidak menambah fitur baru (selain UX/performance)

## Decisions

### 1. Breadcrumb Implementation
- Gunakan komponen `Breadcrumbs` yang sudah ada
- Tambah di setiap halaman admin
- Auto-generate dari route path

### 2. Global Search
- Tambah search bar di header
- Search users, courses, settings secara bersamaan
- Gunakan debouncing untuk performa

### 3. Notification Center
- Tambah bell icon di header dengan dropdown
- Simpan notification history di localStorage
- Tambah mark as read/unread

### 4. Dark Mode
- Tambah toggle di header
- Simpan preferensi di localStorage
- Gunakan CSS variables untuk tema

### 5. Keyboard Shortcuts
- Tambah shortcuts untuk navigasi (Ctrl+K untuk search)
- Tambah shortcuts untuk actions (Ctrl+N untuk new)
- Gunakan library `react-hotkeys-hook`

### 6. Pagination
- Tambah pagination di semua tabel
- Gunakan infinite scroll untuk data besar
- Tambah "Load more" button sebagai fallback

### 7. Skeleton Loading
- Tambah skeleton component untuk setiap page
- Gunakan library `react-loading-skeleton`
- Tambah animasi shimmer effect

### 8. Lazy Loading
- Gunakan `loading="lazy"` untuk images
- Tambah placeholder saat loading
- Gunakan Intersection Observer untuk custom lazy loading

### 9. React Query
- Install `@tanstack/react-query`
- Tambah QueryClient provider
- Implementasi caching untuk semua API calls

## Risks / Trade-offs

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Dark mode mungkin tidak konsisten | UX buruk | Test di semua halaman |
| Keyboard shortcuts mungkin conflict | Shortcut tidak jalan | Cek conflict sebelum implement |
| React Query mungkin over-engineering | Kompleksitas tinggi | Mulai dengan fitur sederhana |
| Pagination mungkin break existing UI | UI berubah | Test di semua halaman |
