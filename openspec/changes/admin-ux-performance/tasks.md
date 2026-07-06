## 1. Setup & Dependencies

- [x] 1.1 Install React Query (`@tanstack/react-query`)
- [x] 1.2 Install keyboard shortcuts library (`react-hotkeys-hook`)
- [x] 1.3 Install skeleton loading library (`react-loading-skeleton`)
- [x] 1.4 Setup QueryClient provider di app layout

## 2. Breadcrumb Implementation

- [x] 2.1 Buat komponen `AdminBreadcrumb` yang reusable
- [x] 2.2 Tambah breadcrumb di halaman dashboard
- [x] 2.3 Tambah breadcrumb di halaman user management
- [x] 2.4 Tambah breadcrumb di halaman master data
- [x] 2.5 Tambah breadcrumb di halaman AI settings
- [x] 2.6 Tambah breadcrumb di halaman audit log
- [x] 2.7 Tambah breadcrumb di halaman templates

## 3. Global Search

- [x] 3.1 Buat komponen `GlobalSearch` dengan modal
- [x] 3.2 Implementasi debouncing (300ms)
- [x] 3.3 Tambah search untuk users
- [x] 3.4 Tambah search untuk courses
- [x] 3.5 Tambah search untuk settings
- [x] 3.6 Tambah navigasi ke hasil search
- [x] 3.7 Tambah keyboard shortcut Ctrl+K

## 4. Notification Center

- [x] 4.1 Buat komponen `NotificationCenter` dengan dropdown
- [x] 4.2 Tambah bell icon di header
- [x] 4.3 Implementasi mark as read/unread
- [x] 4.4 Implementasi mark all as read
- [x] 4.5 Simpan notification history di localStorage
- [x] 4.6 Tambah notifikasi untuk event penting

## 5. Dark Mode

- [x] 5.1 Buat komponen `DarkModeToggle`
- [x] 5.2 Tambah toggle di header
- [x] 5.3 Implementasi CSS variables untuk tema
- [x] 5.4 Simpan preferensi di localStorage
- [x] 5.5 Terapkan tema di semua halaman admin

## 6. Keyboard Shortcuts

- [x] 6.1 Buat komponen `KeyboardShortcutsHelp`
- [x] 6.2 Implementasi Ctrl+K untuk search
- [x] 6.3 Implementasi Ctrl+N untuk new
- [x] 6.4 Implementasi Escape untuk close
- [x] 6.5 Implementasi Ctrl+? untuk help
- [x] 6.6 Tambah shortcuts untuk navigasi (Ctrl+1-6)

## 7. Pagination & Infinite Scroll

- [x] 7.1 Buat komponen `Pagination` yang reusable
- [x] 7.2 Buat komponen `InfiniteScroll` yang reusable
- [x] 7.3 Tambah pagination di tabel users
- [x] 7.4 Tambah pagination di tabel master data
- [x] 7.5 Tambah pagination di tabel audit log
- [x] 7.6 Tambah infinite scroll untuk data besar
- [x] 7.7 Tambah "Load more" button sebagai fallback

## 8. Skeleton Loading

- [x] 8.1 Buat komponen `SkeletonDashboard`
- [x] 8.2 Buat komponen `SkeletonTable`
- [x] 8.3 Buat komponen `SkeletonCard`
- [x] 8.4 Tambah skeleton di halaman dashboard
- [x] 8.5 Tambah skeleton di halaman user management
- [x] 8.6 Tambah skeleton di halaman master data
- [x] 8.7 Tambah skeleton di halaman AI settings
- [x] 8.8 Tambah skeleton di halaman audit log

## 9. Lazy Loading

- [x] 9.1 Tambah `loading="lazy"` di semua images
- [x] 9.2 Buat placeholder untuk images
- [x] 9.3 Implementasi Intersection Observer untuk custom lazy loading
- [x] 9.4 Test lazy loading di semua halaman

## 10. React Query Integration

- [x] 10.1 Setup QueryClient dengan default options
- [x] 10.2 Implementasi caching untuk dashboard stats
- [x] 10.3 Implementasi caching untuk users list
- [x] 10.4 Implementasi caching untuk master data
- [x] 10.5 Implementasi caching untuk AI settings
- [x] 10.6 Implementasi caching untuk audit logs
- [x] 10.7 Tambah cache invalidation untuk mutations
- [x] 10.8 Tambah background refetch
- [x] 10.9 Tambah optimistic updates untuk edit
