## Why

Student dashboard currently has three separate pages for course management: "Detail Kelas" (course info), "Grup" (group management), and "Sesi Diskusi" (discussion sessions). This fragmentation creates unnecessary complexity—students must navigate between pages to access related information, and the overlap between "Detail Kelas" showing session lists and "Sesi Diskusi" showing the same sessions is redundant. Consolidating these into a single unified page reduces cognitive load, simplifies navigation, and provides better context for students managing their coursework.

## What Changes

- **Merge three pages into one**: Combine "Detail Kelas" (`/student/courses/:id`), "Grup" (`/student/groups`), and "Sesi Diskusi" (`/student/courses/:courseId/chat-spaces`) into a single unified "Detail Kelas" page
- **Remove status badge**: Delete the cosmetic "Berjalan/Selesai/Belum Mulai" status indicator from course detail header (no business logic depends on it)
- **Consolidate group management**: Move "Gabung Grup" and "Buat Grup Baru" functionality into the unified page, showing available groups as read-only reference while maintaining join code requirement (per US-D07 Pak Villy)
- **Integrate session management**: Embed session list with search/sort/create capabilities directly in the course detail page, eliminating the separate "Sesi Diskusi" page
- **Redirect old routes**: Redirect `/student/groups` and `/student/courses/:courseId/chat-spaces` to the unified course detail page
- **Simplify navigation**: Remove "Grup" and "Sesi Diskusi" from student navigation menu, keeping only "Mata Kuliah Saya"

## Capabilities

### New Capabilities
- `student-course-detail-unified`: Unified course detail page that combines course information, group management (join/create), and discussion session management (list/create/search/sort) in a single interface

### Modified Capabilities
- `student-navigation`: Remove "Grup" and "Sesi Diskusi" menu items, simplify to course-centric navigation
- `student-group-join`: Maintain join code flow but integrate into unified course detail page with available groups list as reference

## Impact

- **Backend**: Minor updates to `StudentCourseController@show` to fetch `myGroup`, `availableGroups`, and `sessions` in a single query; no new endpoints or schema changes required
- **Frontend**: Rewrite `/resources/js/pages/student/courses/show.tsx` to include group and session management sections; delete or redirect `/resources/js/pages/student/groups/index.tsx` and `/resources/js/pages/student/chat-spaces/index.tsx`
- **Routes**: Add redirects in `/routes/web.php` for old group and chat-spaces routes; update student navigation configuration
- **Navigation**: Remove "Grup" and "Sesi Diskusi" menu items from student navigation while keeping other items (Dashboard, Refleksi, etc.)
- **User experience**: Students access all course-related information (info, groups, sessions) from one page instead of navigating between three separate pages
