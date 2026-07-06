# Implementation Tasks - Low Priority

## 1. Remove Language Selector (L1)

- [x] 1.1 Remove `LanguagePrefs` component import from `PreferencesSection.tsx`
- [x] 1.2 Remove `<LanguagePrefs>` usage from preferences UI JSX
- [x] 1.3 Remove `language` field from `PreferencesData` interface in `PreferencesSection.tsx`
- [x] 1.4 Remove `language` field from `PreferencesData` interface in `usePreferences.ts`
- [x] 1.5 Remove `language` from PATCH `/student/profile/preferences` request body (PreferencesSection)
- [x] 1.6 Remove `language` from PATCH `/student/profile/preferences` request body (usePreferences)
- [x] 1.7 Remove language selector from `settings/index.tsx`
- [x] 1.8 Remove language selector from `settings/components/AppearanceTab.tsx`
- [x] 1.9 Delete `LanguagePrefs.tsx` component file (no longer needed)
- [ ] 1.10 Test preferences page: verify language selector gone
- [ ] 1.11 Test other preferences still work: theme, notifications, font_size
- [ ] 1.12 Test settings page: verify language selector gone, theme still works
- [ ] 1.13 Verify preferences layout not broken after removal

---

## 2. Add Breadcrumbs (L2) — 5 pages

### Course Detail Page
- [x] 2.1 Import Breadcrumbs from `@/components/dashboard/Breadcrumbs` in `courses/show.tsx`
- [x] 2.2 Add trail: `[{ label: 'Kelas', href: student.courses.index.url() }, { label: course.name }]` (Breadcrumbs component already renders Home/Dashboard link)
- [x] 2.3 Place Breadcrumbs at top of page content (inside AppLayout, before main div)
- [x] 2.4 Test: breadcrumb links navigate correctly

### Group Detail Page (replace existing back-link)
- [x] 2.5 Import Breadcrumbs in `groups/show.tsx`
- [x] 2.6 Add trail: `[{ label: 'Kelas', href: student.courses.index.url() }, { label: group.course.name, href: student.courses.show.url(group.course.id) }, { label: group.name }]`
- [x] 2.7 **Remove** existing ArrowLeft back-link button ("Kembali ke Detail Kelas")
- [x] 2.8 Place Breadcrumbs at top of page content
- [x] 2.9 Test: breadcrumb links navigate correctly, back-link gone

### Chat Room Page
- [x] 2.10 Import Breadcrumbs in `chat/room.tsx`
- [x] 2.11 Add trail: `[{ label: 'Kelas', href: student.courses.index.url() }, { label: course.name, href: student.courses.show.url(course.id) }, { label: group.name, href: student.groups.show.url(group.id) }, { label: chatSpace.name }]`
- [x] 2.12 Place Breadcrumbs at top of page content
- [x] 2.13 Test: breadcrumb links navigate correctly

### Reflections Page
- [x] 2.14 Import Breadcrumbs in `reflections/index.tsx`
- [x] 2.15 Add trail: `[{ label: 'Refleksi Saya' }]` (Breadcrumbs component already renders Home/Dashboard link)
- [x] 2.16 Place Breadcrumbs at top of page content
- [x] 2.17 Test: breadcrumb links navigate correctly

### AI Chat Page
- [x] 2.18 Import Breadcrumbs in `ai-chat/index.tsx`
- [x] 2.19 Add trail: `[{ label: 'Chat dengan AI' }]` (Breadcrumbs component already renders Home/Dashboard link)
- [x] 2.20 Place Breadcrumbs at top of page content
- [x] 2.21 Test: breadcrumb links navigate correctly

### Responsive Testing
- [ ] 2.22 Test breadcrumbs on narrow screens (truncate long labels)
- [ ] 2.23 Verify breadcrumbs do not overflow container
- [ ] 2.24 Test all 5 pages on mobile viewport

---

## 3. Verify & Fix Empty States (L3)

### Verification Phase (do this FIRST)
- [x] 3.1 Confirm dashboard ActivityFeed imports EmptyState (`components/dashboard/ActivityFeed.tsx`)
- [x] 3.2 Confirm course list has EmptyState wrapper (`pages/student/courses/components/EmptyState.tsx`)
- [x] 3.3 Confirm chat space has EmptyState wrapper (`components/chat-spaces/EmptyState.tsx`)
- [x] 3.4 Confirm reflection list imports EmptyState (`pages/student/reflections/index.tsx`)
- [ ] 3.5 Test dashboard ActivityFeed with fresh account (no activity) — does EmptyState render?
- [ ] 3.6 Test course list with no enrolled courses — does EmptyState render?
- [ ] 3.7 Test chat space with no messages — does EmptyState render?
- [ ] 3.8 Test reflection list with no reflections — does EmptyState render?
- [ ] 3.9 Document which locations show blank screens vs working EmptyState

### Fix Phase (only for locations that fail verification)
- [ ] 3.10 For each blank screen: check conditional rendering logic (if data.length === 0)
- [ ] 3.11 Fix rendering condition to show EmptyState component
- [ ] 3.12 Verify EmptyState props match context (icon, title, description, action)

### Consistency Check
- [ ] 3.13 Verify all EmptyState components use same visual style
- [ ] 3.14 Verify icon + title + description + action pattern
- [ ] 3.15 Verify spacing and typography match design system

---

## 4. HTTP/2 Connection Pooling (L4)

- [x] 4.1 Open `app/Providers/AppServiceProvider.php`
- [x] 4.2 Add `Http::globalOptions()` in `boot()` with HTTP/2 + keepalive config
- [x] 4.3 Use `'version' => '2.0'` per Guzzle docs
- [x] 4.4 Add CURLOPT_TCP_KEEPALIVE = 1, CURLOPT_TCP_KEEPIDLE = 120, CURLOPT_TCP_KEEPINTVL = 60
- [ ] 4.5 Test outbound HTTP calls via `$this->apiRequest()` still work
- [ ] 4.6 Test outbound HTTP calls via `$this->coreApiRequest()` still work
- [ ] 4.7 Test CoreApiInternalClient calls still work
- [ ] 4.8 Verify HTTP/2 used when server supports it (check response headers)
- [ ] 4.9 Verify fallback to HTTP/1.1 when HTTP/2 not available

---

## 5. Integration & Verification

- [ ] 5.1 Run frontend TypeScript type check: npx tsc --noEmit
- [ ] 5.2 Run frontend tests: npm test
- [ ] 5.3 Run backend PHP tests: php artisan test
- [ ] 5.4 Run lsp_diagnostics on all modified files
- [ ] 5.5 Test full user journey: login → preferences → courses → chat → reflections
- [ ] 5.6 Verify breadcrumbs appear on all 5 pages
- [ ] 5.7 Verify empty states render on dashboards/lists with no data (not blank screens)
- [ ] 5.8 Review all 4 issues marked as resolved in SECURITY_AUDIT_REPORT.md
- [ ] 5.9 Update documentation with new navigation patterns and empty state usage
