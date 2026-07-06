## 1. Lint & Type Check

- [x] 1.1 Jalankan `npx tsc --noEmit` untuk TypeScript check
- [x] 1.2 Jalankan `php -l` pada semua file PHP yang diubah
- [x] 1.3 Jalankan LSP diagnostics pada semua file yang diubah
- [x] 1.4 Fix semua errors yang ditemukan
- [x] 1.5 Dokumentasikan warnings yang ditemukan

## 2. Build Verification

- [x] 2.1 Jalankan `npm run build` untuk frontend build
- [x] 2.2 Jalankan `php artisan cache:clear` dan `php artisan config:clear`
- [x] 2.3 Jalankan `php artisan route:clear` dan `php artisan route:list`
- [x] 2.4 Fix semua build errors yang ditemukan
- [x] 2.5 Verifikasi routes terdaftar dengan benar

## 3. Database Verification

- [x] 3.1 Jalankan `php artisan migrate` untuk verifikasi migrations
- [x] 3.2 Jalankan `php artisan migrate:rollback` untuk verifikasi rollback
- [x] 3.3 Jalankan `php artisan migrate` lagi untuk restore
- [x] 3.4 Verifikasi tidak ada migration conflicts

## 4. Functional Testing - Student Pages

- [x] 4.1 Test halaman `/student/courses` — search, filter
- [x] 4.2 Test halaman `/student/chat-spaces` — nested under `/student/courses/{id}/chat-spaces`
- [x] 4.3 Test halaman `/student/ai-chat` — search, templates, bookmarks
- [x] 4.4 Test halaman `/student/reflections` — search, templates, analytics
- [x] 4.5 Test halaman `/student/groups` — nested under `/student/courses/{id}/groups`
- [x] 4.6 Test halaman `/student/profile` — avatar, preferences
- [x] 4.7 Test halaman `/student/chat/room/{id}` — nested under `/student/courses/{id}/chat/{chatSpace}`

## 5. Functional Testing - Lecturer Pages

- [x] 5.1 Test halaman `/lecturer/courses` — analytics, bulk actions, search
- [x] 5.2 Test halaman `/lecturer/courses/{id}` — tabs, aktivitas, attendance, materials
- [x] 5.3 Test halaman `/lecturer/analytics` — export, date filter
- [x] 5.4 Test halaman `/lecturer/analytics/{id}` — nested under `/lecturer/courses/{id}/analytics/detail`
- [x] 5.5 Test halaman `/lecturer/ai-settings` — preview, presets
- [x] 5.6 Test halaman `/lecturer/session-mgmt` — scheduling, auto-close, templates

## 6. Functional Testing - Auth Pages

- [x] 6.1 Test halaman `/login` — form, forgot password, remember me
- [x] 6.2 Test halaman `/register` — form, password strength, terms
- [x] 6.3 Test halaman `/` — welcome page, dark mode
- [x] 6.4 Test halaman `/dashboard` — redirects to role-based dashboard (student→/student/courses, lecturer→/lecturer/courses)

## 7. API Testing

- [x] 7.1 Test endpoint `PATCH /api/student/chat/rooms/{roomId}/messages/{messageId}`
- [x] 7.2 Test endpoint `DELETE /api/student/chat/rooms/{roomId}/messages/{messageId}`
- [x] 7.3 Test endpoint `GET /api/student/chat/rooms/{roomId}/messages/search`
- [x] 7.4 Test endpoint `POST /api/student/chat/rooms/{roomId}/messages/{messageId}/pin`
- [x] 7.5 Test endpoint `DELETE /api/student/chat/rooms/{roomId}/messages/{messageId}/pin`
- [x] 7.6 Test endpoint `POST /api/student/profile/avatar`
- [x] 7.7 Test endpoint `PATCH /api/student/profile/preferences`
- [x] 7.8 Test endpoint `GET /api/lecturer/analytics/export`
- [x] 7.9 Test endpoint `POST /api/lecturer/sessions/{id}/schedule`

## 8. Integration Testing

- [x] 8.1 Test login flow — login, redirect, dashboard
- [x] 8.2 Test chat flow — send message, real-time update
- [x] 8.3 Test socket connection — room_joined, send button
- [x] 8.4 Test AI chat — send message, AI response
- [x] 8.5 Test dark mode — toggle, persistence
- [x] 8.6 Verifikasi tidak ada console errors

## 9. Performance Testing

- [x] 9.1 Ukur page load time untuk halaman utama (< 2s)
- [x] 9.2 Ukur API response time untuk endpoint kritis (< 500ms)
- [x] 9.3 Ukur database query performance (< 100ms)
- [x] 9.4 Verifikasi tidak ada N+1 queries
- [x] 9.5 Verifikasi bundle size acceptable (< 500KB gzipped)
- [x] 8.7 Verifikasi tidak ada broken UI elements
