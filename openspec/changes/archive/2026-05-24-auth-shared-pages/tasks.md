## 1. Login Page Enhancements

- [x] 1.1 Implement forgot password flow - route, controller, email template, reset form page
- [x] 1.2 Add Google OAuth 2.0 social login - backend OAuth callback, frontend button, account linking
- [x] 1.3 Implement rate limiting - 5 attempts/5min per IP, 10 attempts/hour per email, 15min cooldown
- [x] 1.4 Improve error handling - network error, server error, CSRF auto-refresh messages in Indonesian
- [x] 1.5 Update login form with proper remember me token management (30-day persistent cookie)

## 2. Register Page Enhancements

- [x] 2.1 Implement email verification flow - verification email template, verify endpoint, resend button
- [x] 2.2 Add terms & conditions checkbox with link to T&C page
- [x] 2.3 Enhance password strength meter - enforce minimum 8 characters, visual feedback (merah/kuning/hijau)
- [x] 2.4 Add registration rate limiting - 5 attempts/hour per IP, 3 attempts/24h per email
- [x] 2.5 Handle duplicate email and unverified user login attempts gracefully

## 3. Welcome/Landing Page

- [x] 3.1 Build hero section with headline, subheadline, parallax scroll animation, and CTA button
- [x] 3.2 Build feature showcase section - 4+ feature cards with icons, hover effects, and descriptions
- [x] 3.3 Build statistics section with animated counting numbers (users, discussions, satisfaction, universities)
- [x] 3.4 Build "Cara Kerja" section with 3-4 step cards and click-to-expand details
- [x] 3.5 Build demo preview section with video/interactive preview and CTA
- [x] 3.6 Build testimonials section - carousel with 3+ testimonials, name, role, photo, rating
- [x] 3.7 Build FAQ section - accordion with 5+ questions grouped by category
- [x] 3.8 Build CTA section at bottom with persuasive headline and "Daftar Gratis" button
- [x] 3.9 Implement dark mode toggle with localStorage persistence and OS preference detection
- [x] 3.10 Ensure responsive design - mobile hamburger menu, tablet 2-col, desktop multi-col
- [x] 3.11 Optimize performance - lazy loading images, WebP format, FCP < 1.5s

## 4. Dashboard Pages

- [x] 4.1 Create aggregated stats API endpoint in core-api for each role (student/lecturer/admin)
- [x] 4.2 Build student dashboard - quick stats cards (courses, groups, reflections, messages)
- [x] 4.3 Build lecturer dashboard - analytics overview, recent groups, quick actions
- [x] 4.4 Build admin dashboard - system stats, user management overview, audit log preview
- [x] 4.5 Implement recent activity feed per role with clickable items linking to relevant pages
- [x] 4.6 Implement notifications bell with badge count, dropdown list (max 10), mark-all-read
- [x] 4.7 Implement quick actions grid per role with navigation shortcuts
- [x] 4.8 Add progress tracking - student course progress bars, lecturer student activity overview
- [x] 4.9 Add time-based personalized welcome card ("Selamat pagi/siang/malam, {nama}!")
- [x] 4.10 Implement skeleton loading states and error states with retry button

## 5. Settings Page

- [x] 5.1 Create settings page structure with tab navigation (Profile, Notifikasi, Tampilan, Keamanan)
- [x] 5.2 Build profile settings tab - edit name, email, avatar upload (max 2MB), re-verification for email change
- [x] 5.3 Build notification preferences tab - toggles for Kursus Baru, Diskusi, Refleksi, Deadline, Pengumuman
- [x] 5.4 Build theme settings tab - Terang/Gelap/Ikuti Sistem with instant preview, localStorage + DB sync
- [x] 5.5 Build language settings tab - Bahasa Indonesia/English with instant UI switch
- [x] 5.6 Build security tab - change password form (current + new + confirm)
- [x] 5.7 Implement account deletion - "KETIK HAPUS" confirmation modal, soft delete, email notification
- [x] 5.8 Implement 30-day grace period with restoration link in email
- [x] 5.9 Add form validation - required fields, email format, file size limits
- [x] 5.10 Implement auto-save for toggles/dropdowns, manual save for text inputs, unsaved changes warning

## 6. Database & API

- [x] 6.1 Add Prisma migration for users table - email_verified_at, theme_preference, language_preference, deleted_at
- [x] 6.2 Create password reset tokens table and API endpoints (request, verify, reset)
- [x] 6.3 Create email verification tokens table and API endpoints (verify, resend)
- [x] 6.4 Create notifications table and API endpoints (list, mark-read, mark-all-read)
- [x] 6.5 Create user preferences API endpoints (get, update)
- [x] 6.6 Create aggregated dashboard stats API endpoint
- [x] 6.7 Create account deletion API endpoint with soft delete logic

## 7. Testing & Verification

- [x] 7.1 Write tests for login flow - valid/invalid credentials, remember me, rate limiting
- [x] 7.2 Write tests for register flow - validation, email verification, terms checkbox
- [x] 7.3 Write tests for forgot password flow - request, reset, expiry
- [x] 7.4 Write tests for dashboard stats API - correct aggregation per role
- [x] 7.5 Write tests for settings - profile update, preferences save, account deletion
- [x] 7.6 Write E2E tests for complete auth flows (register → verify → login → dashboard)
- [x] 7.7 Verify all user-facing text is in Indonesian
