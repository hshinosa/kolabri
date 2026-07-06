## Context

Currently, students navigate between three separate pages to manage their coursework:
- `/student/courses/:id` (Detail Kelas) - shows course info + groups + sessions overview
- `/student/groups` (Grup) - detailed group management with join/create
- `/student/courses/:courseId/chat-spaces` (Sesi Diskusi) - detailed session list with filter/sort/create

This fragmentation creates cognitive overhead and redundant navigation. The unified page will consolidate all functionality into a single course-centric view.

**Current tech stack:**
- Frontend: React + TypeScript with Inertia.js
- Styling: Tailwind CSS with custom LiquidGlassCard components
- State: React hooks (useState, useEffect)
- Data fetching: Direct fetch() calls to Laravel backend

## Goals / Non-Goals

**Goals:**
- Reduce student navigation steps from 3 pages to 1 page for course management
- Maintain all existing functionality (join group, create group, create session, search/sort sessions)
- Simplify mental model: one page = one course = everything you need
- Preserve join code requirement per US-D07 (Pak Villy)

**Non-Goals:**
- Creating new backend endpoints or changing database schema (only minor controller query optimization)
- Adding new features beyond consolidation
- Modifying lecturer dashboard or admin interfaces
- Implementing real-time updates (existing polling is sufficient)

## Decisions

### 1. Component Composition Strategy

**Decision:** Use a three-section layout within the existing `courses/show.tsx` page:
```
┌─────────────────────────────────────┐
│ Section 1: Course Header            │
│ - Code badge, name, lecturer        │
│ - NO status badge                   │
├─────────────────────────────────────┤
│ Section 2: Group Management         │
│ - Conditional: join/create OR       │
│   group details                     │
│ - Read-only available groups list   │
├─────────────────────────────────────┤
│ Section 3: Discussion Sessions      │
│ - Search + sort controls            │
│ - Session cards list                │
│ - Create session button             │
└─────────────────────────────────────┘
```

**Rationale:**
- Maintains visual hierarchy (course → group → sessions)
- Each section is conditionally rendered based on student's group membership
- Reuses existing LiquidGlassCard and modal patterns
- Easier to maintain than nested routes or tabs

**Alternatives considered:**
- Tabs (Grup | Sesi): rejected because group and sessions are related, not parallel
- Nested routes: rejected because adds complexity without benefit
- Separate components with shared state: rejected because over-engineering for this scope

### 2. State Management Approach

**Decision:** Use local React state with `useState` hooks, organized by section:
```typescript
// Group section state
const [showJoinModal, setShowJoinModal] = useState(false);
const [showCreateGroupModal, setShowCreateGroupModal] = useState(false);
const [myGroup, setMyGroup] = useState<Group | null>(null);
const [availableGroups, setAvailableGroups] = useState<Group[]>([]);

// Session section state
const [sessions, setSessions] = useState<ChatSpace[]>([]);
const [searchQuery, setSearchQuery] = useState('');
const [sortBy, setSortBy] = useState<'terbaru' | 'aktif' | 'alfabet'>('terbaru');
const [showCreateSessionModal, setShowCreateSessionModal] = useState(false);
```

**Rationale:**
- Consistent with existing patterns in `courses/show.tsx`
- No need for global state (Zustand/Redux) since data is page-scoped
- Simple to debug and test
- Avoids prop drilling

**Alternatives considered:**
- Context API: rejected because overkill for page-scoped state
- URL params for filters: rejected because adds complexity without benefit (no deep linking needed)
- Server-side state: rejected because client-side filtering/sorting is fast enough

### 3. Data Fetching Strategy

**Decision:** Fetch all required data in a single page load using existing Laravel controller:
```php
// StudentCourseController@show
public function show($courseId) {
    $course = Course::findOrFail($courseId);
    $myGroup = $course->groups()->whereHas('members', fn($q) => $q->where('user_id', auth()->id()))->first();
    $availableGroups = $course->groups()->withCount('members')->get();
    $sessions = $myGroup ? $myGroup->chatSpaces()->with('lastMessage')->get() : [];

    return Inertia::render('student/courses/show', [
        'course' => $course,
        'myGroup' => $myGroup,
        'availableGroups' => $availableGroups,
        'sessions' => $sessions,
    ]);
}
```

**Rationale:**
- Single round-trip for all page data
- Leverages existing Eloquent relationships
- No need for separate API endpoints
- Fast initial load (<500ms based on existing performance)

**Alternatives considered:**
- Lazy loading sessions: rejected because sessions are core functionality, not optional
- Separate API calls: rejected because adds complexity and multiple round-trips
- GraphQL: rejected because overkill and not in current stack

### 4. Route Redirect Strategy

**Decision:** Add redirects in `routes/web.php`:
```php
// Redirect old routes to unified page
Route::get('/student/groups', fn() => redirect('/student/courses'));
Route::get('/student/courses/{course}/chat-spaces', fn($course) => redirect("/student/courses/{$course}"));
```

**Rationale:**
- Preserves existing bookmarks and links
- Clear migration path for users
- Simple to implement and remove later if needed

**Alternatives considered:**
- Client-side redirects: rejected because server-side is faster and more SEO-friendly
- 404 pages: rejected because breaks existing links and confuses users
- Keep old routes with deprecated warnings: rejected because adds maintenance burden

### 5. Modal Reuse Strategy

**Decision:** Reuse existing modal components from `chat-spaces/index.tsx` and `groups/index.tsx`:
- `CreateSessionModal` component
- `JoinGroupModal` component
- `CreateGroupModal` component

**Rationale:**
- Proven, tested components
- Consistent UX patterns
- Reduces code duplication
- Faster implementation

**Alternatives considered:**
- Build new modals from scratch: rejected because reinventing the wheel
- Use generic modal wrapper: rejected because existing modals have specific logic worth preserving

## Risks / Trade-offs

**Risk: Page becomes too long/complex**
- Mitigation: Use clear visual sections with LiquidGlassCard boundaries; consider collapsible sections if needed in future
- Monitoring: User feedback on page length; analytics on scroll depth

**Risk: Loss of deep linking to specific groups/sessions**
- Mitigation: Use anchor links (`#group-section`, `#sessions-section`) for direct navigation if needed
- Trade-off: Slightly more complex routing, but acceptable for better UX

**Risk: Performance degradation with many sessions**
- Mitigation: Implement pagination for sessions list (>20 sessions); use virtualized list if needed
- Monitoring: Page load time; session list render time

**Risk: Confusion about group join flow**
- Mitigation: Clear visual distinction between "not in group" and "in group" states; prominent join/create buttons
- Testing: User testing with students who haven't joined groups yet

**Trade-off: No separate "Grup" page means less visibility into group details**
- Mitigation: "Lihat Anggota" button opens modal with full member list
- Acceptance: Group details are secondary to sessions, so embedding is acceptable
