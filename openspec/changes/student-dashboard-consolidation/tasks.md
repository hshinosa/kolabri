## 1. Backend Updates

- [x] 1.1 Update `StudentCourseController@show` to fetch `myGroup`, `availableGroups`, and `sessions` in single query
- [x] 1.2 Add route redirects in `routes/web.php` for `/student/groups` and `/student/courses/:courseId/chat-spaces`
- [x] 1.3 Update Inertia page props to include `myGroup`, `availableGroups`, `sessions` data
- [x] 1.4 Verify join group endpoint accepts join code and returns updated group membership
- [x] 1.5 Verify create group endpoint returns join code for sharing
- [x] 1.6 Verify `availableGroups` includes `max_members` field from backend

## 2. Frontend - Course Detail Page Structure

- [x] 2.1 Rewrite `resources/js/pages/student/courses/show.tsx` with three-section layout
- [x] 2.2 Implement Section 1: Course header (code badge, name, lecturer) without status badge
- [x] 2.3 Implement Section 2: Group management with conditional rendering (not joined vs joined)
- [x] 2.4 Add "Belum bergabung dengan grup" state with join/create buttons
- [x] 2.5 Add read-only available groups list with member counts
- [x] 2.6 Add group card display for joined students with "Lihat Anggota" button
- [x] 2.7 Implement Section 3: Discussion sessions with search/sort/create controls

## 3. Frontend - Session Management

- [x] 3.1 Add session list rendering with cards (name, status, type, message count, last message, timestamp)
- [x] 3.2 Implement search functionality with client-side filtering
- [x] 3.3 Implement sort dropdown (Terbaru/Paling Aktif/Alfabet) with client-side sorting
- [x] 3.4 Add "Buat Sesi Baru" button that opens create session modal
- [x] 3.5 Add empty state for no sessions with "Buat Sesi Pertama" button
- [x] 3.6 Add empty state for no search results

## 4. Frontend - Modal Components

- [x] 4.1 Adapt `JoinGroupModal` from `groups/index.tsx` for use in unified page
- [x] 4.2 Adapt `CreateGroupModal` from `groups/index.tsx` with join code display on success
- [x] 4.3 Adapt `CreateSessionModal` from `chat-spaces/index.tsx` with week dropdown
- [x] 4.4 Add "Lihat Anggota" modal to display group member list
- [x] 4.5 Ensure all modals refresh page data on successful submission

## 5. Navigation and Routing

- [x] 5.1 Remove "Grup" menu item from student navigation configuration
- [x] 5.2 Remove "Sesi Diskusi" menu item from student navigation configuration
- [x] 5.3 Verify "Mata Kuliah Saya" navigation works correctly
- [x] 5.4 Test route redirects for old `/student/groups` and `/student/courses/:id/chat-spaces` paths

## 6. Testing and Validation

- [x] 6.1 Test course detail page for student not in any group (shows join/create options)
- [x] 6.2 Test course detail page for student in a group (shows group card + sessions)
- [x] 6.3 Test join group flow with valid code
- [x] 6.4 Test join group flow with invalid code (error handling)
- [x] 6.5 Test create group flow (name input, join code generation)
- [x] 6.6 Test create session flow (name, description, week selection)
- [x] 6.7 Test session search functionality
- [x] 6.8 Test session sort functionality
- [x] 6.9 Test empty states (no groups, no sessions, no search results)
- [x] 6.10 Verify route redirects work correctly
- [x] 6.11 Test mobile responsiveness of unified page
- [x] 6.12 Verify no status badge appears in course header

## 7. Loading and Error States

- [x] 7.1 Implement skeleton loader for course header section during initial load
- [x] 7.2 Implement skeleton loader for group section during initial load
- [x] 7.3 Implement skeleton loader for sessions section during initial load
- [x] 7.4 Add error boundary with retry button for failed data fetches
- [x] 7.5 Test loading states with slow network simulation
- [x] 7.6 Test error states by simulating backend failures

## 8. Cleanup

- [x] 8.1 Delete or mark as deprecated `/resources/js/pages/student/groups/index.tsx`
- [x] 8.2 Delete or mark as deprecated `/resources/js/pages/student/chat-spaces/index.tsx`
- [x] 8.3 Remove unused components/hooks from old pages
- [x] 8.4 Update any hardcoded links to old routes in other files
- [x] 8.5 Verify no broken imports after cleanup
