## Context

**Background**: Low-priority audit issues focus on UX polish and performance. These are quality improvements that make the platform feel more professional and responsive.

**Current State**:
- Language selector in preferences does nothing (no i18n framework)
- 6+ deep pages lack breadcrumb navigation
- Charts/dashboards show blank screens when empty
- HTTP client creates new TCP connection for each request

**Constraints**:
- Must use existing Breadcrumbs and EmptyState components
- Must not break existing navigation patterns
- Must preserve localStorage for other preferences (not just language)
- 7 hours total

## Goals / Non-Goals

**Goals:**
- Remove misleading non-functional UI elements
- Add breadcrumb navigation to all deep pages
- Show helpful empty states when no data exists
- Improve HTTP performance with connection pooling

**Non-Goals:**
- Not implementing i18n (future initiative)
- Not redesigning navigation (just adding breadcrumbs)
- Not creating custom illustrations (using existing components)
- Not implementing full HTTP/2 server push

## Decisions

### L1: Remove Language Selector - Eliminate Misleading UX

**Decision**: Remove LanguagePrefs component, language-related UI, and language field from preferences data model.

**Rationale**:
- Language selector does nothing → misleading to users
- No i18n framework wired → no actual functionality
- No plans for multi-language support
- Better to remove than show non-functional UI

**Alternatives Considered**:
1. **Implement i18n now** - Rejected: Large scope, separate initiative, no plans
2. **Disable selector with tooltip** - Rejected: Still confusing, worse UX
3. **Keep as-is** - Rejected: Misleading, audit finding

**Implementation Approach**:
```typescript
// 1. Remove LanguagePrefs component import and usage from PreferencesSection
// 2. Remove 'language' field from PreferencesData interface in PreferencesSection.tsx
// 3. Remove 'language' field from PreferencesData interface in usePreferences.ts
// 4. Stop sending 'language' in PATCH /student/profile/preferences request body
//    (send only { notifications, theme, font_size })
// 5. Remove language selector from settings/index.tsx state and AppearanceTab props
// 6. Remove language selector UI from settings/components/AppearanceTab.tsx
// 7. Backend: language key in preferences JSON becomes dead data — leave as-is (no migration needed)
```

**Breaking Changes**: None - removing non-functional feature

---

### L2: Breadcrumbs - Navigation Context

**Decision**: Add existing Breadcrumbs component to 5 pages with appropriate navigation trails.

**Rationale**:
- Users lose context in deep navigation flows
- Breadcrumbs component already exists and works
- Standard UX pattern for hierarchical navigation
- Quick win with high user value

**Alternatives Considered**:
1. **Custom breadcrumb per page** - Rejected: Duplicated effort
2. **Sidebar navigation** - Rejected: Different pattern, larger change
3. **Back button only** - Rejected: Doesn't show hierarchy

**Implementation Approach**:
```typescript
// Breadcrumbs component already renders a Home icon link to /dashboard internally
// Each page only defines additional items AFTER the dashboard link
const breadcrumbs = [
  { label: 'Kelas', href: student.courses.index.url() },
  { label: course.name }, // current page (no link)
];

<Breadcrumbs items={breadcrumbs} />
```

**Pages to Update** (5 pages — chat-spaces excluded, deprecated):
1. courses/show — items: Kelas > [Course Name]
2. groups/show — items: Kelas > [Course Name] > [Group Name]. **Replace** existing ArrowLeft back-link ("Kembali ke Detail Kelas") with proper breadcrumbs
3. chat/room — items: Kelas > [Course Name] > [Group Name] > [Chat Name]
4. reflections — items: Refleksi Saya
5. ai-chat — items: Chat dengan AI

**Breaking Changes**: None - additive navigation aid

---

### L3: Empty States - Verify Before Implementation

**Decision**: Verify existing EmptyState components render correctly before adding new ones. Components already exist in codebase.

**Rationale**:
- EmptyState components already exist for dashboard (ActivityFeed), courses, chat-spaces, and reflections
- Blank screens may indicate conditional rendering bugs, not missing components
- Verification-first prevents duplicate work
- Only add/fix where actually broken

**Current State** (from codebase exploration):
1. Dashboard charts: `components/dashboard/ActivityFeed.tsx` imports EmptyState ✅
2. Course list: `pages/student/courses/components/EmptyState.tsx` domain wrapper ✅
3. Message history: `components/chat-spaces/EmptyState.tsx` domain wrapper ✅
4. Reflection list: `pages/student/reflections/index.tsx` imports EmptyState ✅

**Implementation Approach**:
```typescript
// STEP 1: Verify each location renders EmptyState when data is empty
// - Test with fresh account (no courses, no reflections, no messages)
// - Check conditional rendering logic (if data.length === 0)

// STEP 2: Fix only locations that don't show EmptyState
// - Check if EmptyState is imported but not rendered
// - Fix conditional rendering logic if needed
// - Ensure EmptyState props match context (icon, title, description, action)
```

**Breaking Changes**: None - verification and potential fixes only

---

### L4: HTTP/2 Connection Pooling - Performance

**Decision**: Enable HTTP/2 and connection pooling globally for Laravel HTTP client.

**Rationale**:
- Each request creates new TCP connection → overhead
- HTTP/2 multiplexing reduces connection count
- Connection pooling reuses connections
- Performance best practice

**Current State** (3 separate HTTP patterns in codebase):
1. Base Controller: `$this->apiRequest()` / `$this->coreApiRequest()` — per-call timeout
2. CoreApiInternalClient: Separate timeout/headers for internal calls
3. JwtAuthMiddleware: Direct `Http::` calls for JWT refresh

**Implementation Approach**:
```php
// In app/Providers/AppServiceProvider.php boot() method
use Illuminate\Http\Client\PendingRequest;

Http::globalRequest(function (PendingRequest $request) {
    $request->withOptions([
        'version' => '2.0',  // HTTP/2 (Guzzle uses 'version', not 'http_version')
        'curl' => [
            CURLOPT_TCP_KEEPALIVE => 1,
            CURLOPT_TCP_KEEPIDLE => 120,
            CURLOPT_TCP_KEEPINTVL => 60,
        ],
    ]);
});

// This global config layers with existing per-call config:
// - apiRequest() timeout settings still work
// - coreApiRequest() timeout settings still work
// - Global HTTP/2 + keepalive applied automatically
```

**Breaking Changes**: None - performance optimization, transparent to application

---

## Risks / Trade-offs

### Language Selector Removal (L1)
**Risk**: Backend preferences JSON still contains dead `language` key
→ **Mitigation**: Acceptable — dead data, no functional impact, no migration needed

### Breadcrumbs (L2)
**Risk**: Breadcrumbs might overflow on narrow screens
→ **Mitigation**: Truncate long labels, use responsive component

### Empty States (L3)
**Risk**: Components exist but don't render (conditional rendering bug)
→ **Mitigation**: Verify-first approach catches bugs before adding new code

### HTTP/2 (L4)
**Risk**: HTTP/2 not supported by all endpoints
→ **Mitigation**: Client falls back to HTTP/1.1 automatically

---

## Migration Plan

### Deployment
1. Deploy frontend changes (L1, L2, L3) together
2. Deploy backend change (L4) independently
3. No coordination required (independent changes)

### Validation
1. Verify language selector removed from preferences
2. Navigate all 5 pages, verify breadcrumbs appear with correct `/student/` paths
3. Verify groups/show breadcrumbs replaced old ArrowLeft back-link
4. View empty dashboards/lists, verify empty states render (not blank screens)
5. Monitor HTTP performance metrics (optional)

### Rollback
- All changes additive or removal of non-functional UI
- Rollback: Deploy previous version
- No data migration needed
