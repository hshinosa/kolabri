# Student Chat Spaces - Search, Filter, Sort, Preview, Empty State

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add search, filter, sort, activity preview, empty states, and pagination to the student chat spaces page.

**Architecture:** Server-side filtering/sorting/pagination in Kolabri-core-api (Prisma + Express), consumed by Laravel controller, rendered by React/Inertia frontend.

**Tech Stack:** Prisma ORM, Express.js (core-api), Laravel PHP (client-app), React 19, TypeScript, Tailwind CSS v4, Inertia.js

---

## Context

### Current State
- Frontend components (SearchBar, FilterChips, SortDropdown, SpaceCard, ActivityPreview, EmptyState, Pagination) all exist and are wired up
- `useSpaceFilters` hook exists with 300ms debounce and URL sync
- Main page (`index.tsx`) does **client-side** filtering on `group.chatSpaces` array
- Backend `GroupService.getChatSpaces()` returns only `{ id, name, description, isDefault }` - no type, status, lastMessage, filtering, sorting, or pagination
- Prisma ChatSpace model has NO `type` or `status` columns

### Key Gaps
1. Prisma schema missing `type` and `status` columns on ChatSpace
2. External API returns flat array with no filtering/sorting/pagination
3. API response missing lastMessage fields, type, status, closedAt, createdAt
4. Frontend falls back to client-side filtering (works but won't scale)

---

## File Structure

### Files to Modify (Kolabri-core-api)
- `prisma/schema.prisma` - Add type/status columns to ChatSpace
- `prisma/migrations/` - New migration for type/status columns
- `src/services/group.service.ts` - Update getChatSpaces with filtering/sorting/pagination/lastMessage
- `src/controllers/group.controller.ts` - Pass query params to service

### Files to Modify (Kolabri-client-app)
- `resources/js/pages/student/chat-spaces/index.tsx` - Use server-side data when available, keep client-side fallback

### Files Already Complete (No Changes Needed)
- `resources/js/components/chat-spaces/SearchBar.tsx` - Already has search input, clear button, Cmd+K
- `resources/js/components/chat-spaces/FilterChips.tsx` - Already has type/status chips with counts
- `resources/js/components/chat-spaces/SortDropdown.tsx` - Already has terbaru/paling-aktif/alfabet
- `resources/js/components/chat-spaces/SpaceCard.tsx` - Already renders card with ActivityPreview
- `resources/js/components/chat-spaces/ActivityPreview.tsx` - Already shows last message, relative time
- `resources/js/components/chat-spaces/EmptyState.tsx` - Already has 3 variants (no-spaces, no-filter-results, no-search-results)
- `resources/js/components/chat-spaces/Pagination.tsx` - Already has page navigation
- `resources/js/hooks/useSpaceFilters.ts` - Already has debounce, URL sync, all filter methods

---

## Implementation Steps

### Phase 1: Database Schema (Prisma)

#### Step 1.1: Add type and status columns to ChatSpace
**File:** `Kolabri-core-api/prisma/schema.prisma`

Add to ChatSpace model:
```prisma
type     String? @map("type")     // 'Akademik' | 'Proyek' | 'Umum'
status   String? @map("status")   // 'Aktif' | 'Tidak aktif' (derived from closedAt, but stored for filtering)
```

#### Step 1.2: Create Prisma migration
```bash
cd Kolabri-core-api
npx prisma migrate dev --name add_type_status_to_chat_spaces
```

#### Step 1.3: Generate Prisma client
```bash
npx prisma generate
```

---

### Phase 2: Backend API (GroupService)

#### Step 2.1: Update getChatSpaces signature to accept query params
**File:** `Kolabri-core-api/src/services/group.service.ts`

Change signature from:
```typescript
static async getChatSpaces(groupId: string, userId: string, userRole: string)
```
To:
```typescript
static async getChatSpaces(
  groupId: string,
  userId: string,
  userRole: string,
  query?: {
    q?: string;
    type?: string | string[];
    status?: string | string[];
    sort?: string;
    page?: number;
    per_page?: number;
  }
)
```

#### Step 2.2: Implement filtering logic
Add Prisma `where` clause building:
- `q`: Filter by name contains (case-insensitive) OR description contains
- `type`: Filter by type IN array
- `status`: Derive from closedAt - 'Aktif' = closedAt IS NULL, 'Tidak aktif' = closedAt IS NOT NULL

#### Step 2.3: Implement sorting logic
Add Prisma `orderBy`:
- `terbaru` (default): orderBy lastMessageAt DESC NULLS LAST, then createdAt DESC
- `paling-aktif`: orderBy lastMessageAt DESC NULLS LAST
- `alfabet`: orderBy name ASC

#### Step 2.4: Implement pagination
Use Prisma `skip` and `take`:
```typescript
const page = query?.page || 1;
const perPage = query?.per_page || 12;
const skip = (page - 1) * perPage;
```

#### Step 2.5: Include lastMessage data
Add to Prisma include:
```typescript
include: {
  messages: {
    orderBy: { createdAt: 'desc' },
    take: 1,
    include: { sender: { select: { name: true } } },
  },
}
```

#### Step 2.6: Return paginated response format
Change return from flat array to:
```typescript
{
  data: chatSpaces.map(cs => ({
    id: cs.id,
    name: cs.name,
    description: cs.description,
    isDefault: cs.isDefault,
    isClosed: !!cs.closedAt,
    closedAt: cs.closedAt,
    createdAt: cs.createdAt,
    type: cs.type,
    status: cs.closedAt ? 'Tidak aktif' : 'Aktif',
    lastMessage: cs.messages[0]?.content?.substring(0, 100) || null,
    lastMessageAt: cs.messages[0]?.createdAt || null,
    lastMessageSender: cs.messages[0]?.sender?.name || null,
  })),
  pagination: {
    total,
    per_page: perPage,
    current_page: page,
    last_page: Math.ceil(total / perPage),
  }
}
```

---

### Phase 3: Backend Controller

#### Step 3.1: Update getChatSpaces controller to pass query params
**File:** `Kolabri-core-api/src/controllers/group.controller.ts`

```typescript
static async getChatSpaces(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  try {
    const groupId = req.params.id;
    const chatSpaces = await GroupService.getChatSpaces(
      groupId,
      req.user!.userId,
      req.user!.role,
      req.query  // Pass query params
    );
    res.json(chatSpaces); // Already includes { data, pagination }
  } catch (error) {
    next(error);
  }
}
```

---

### Phase 4: Frontend Integration

#### Step 4.1: Update main page to prefer server-side data
**File:** `Kolabri-client-app/resources/js/pages/student/chat-spaces/index.tsx`

The page already has the logic to use `chatSpaceMeta?.data` when available. Key changes:
- When `chatSpaceMeta?.data` exists, use it directly (server already filtered/sorted/paginated)
- When `chatSpaceMeta?.data` is null/undefined, fall back to client-side filtering
- Update `showEmptyState` to check `totalItems === 0` when using server data
- Update type/status counts to use server response or client-side calculation

#### Step 4.2: Ensure filter chips show correct counts
The FilterChips component already accepts `typeCounts` and `statusCounts` props. When using server-side data, these counts should come from the API response or be calculated client-side from the full dataset.

---

### Phase 5: QA & Verification

#### Step 5.1: Run Prisma migration
```bash
cd Kolabri-core-api
npx prisma migrate dev
```

#### Step 5.2: Run TypeScript compilation
```bash
cd Kolabri-core-api
npm run build
```

#### Step 5.3: Run existing tests
```bash
cd Kolabri-core-api
npm test
```

#### Step 5.4: Run LSP diagnostics on changed files
Check for type errors in all modified files.

---

## Design Decisions

1. **Server-side vs Client-side**: Implement server-side filtering in the API for scalability, but keep client-side fallback in frontend for when API doesn't return paginated data (backward compatibility).

2. **Status derivation**: `status` is derived from `closedAt` field - if `closedAt` is null, status is 'Aktif', otherwise 'Tidak aktif'. No need to store separately.

3. **Type field**: Added as optional string column on ChatSpace. Default null (spaces without type won't match type filters).

4. **Last message**: Computed from ChatMessage relation (most recent message per space). Included in API response for activity preview.

5. **Pagination**: Server-side pagination with configurable per_page (default 12). Frontend shows pagination controls when totalPages > 1.

---

## OpenSpec Tasks Coverage

This plan implements:
- Tasks 1.1-1.12 (Search / Filter / Sort) → Steps 1.1-2.6, 3.1, 4.1
- Tasks 2.1-2.8 (Preview Aktivitas) → Steps 2.5, 2.6
- Tasks 3.1-3.6 (Empty State) → Step 4.1 (already implemented in frontend)
- Tasks 4.1-4.4 (Pagination) → Steps 2.4, 2.6, 4.1
- Tasks 5.1-5.4 (Integrasi & State) → Steps 3.1, 4.1, 4.2
- Tasks 6.1-6.6 (QA) → Steps 5.1-5.4
