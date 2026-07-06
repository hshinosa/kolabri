## Context

Wave 1-4 implementation completed core features (auth, student/lecturer pages, admin UX) but left technical debt:
- Admin UX/performance agents introduced TypeScript errors (17 total) from incomplete pagination component integration and missing route definitions
- UX features (dark mode, keyboard shortcuts, global search) only exist in admin role, creating inconsistent experience
- OpenSpec changes directory has 21 changes with unclear status (complete/in-progress/abandoned)
- No systematic test coverage tracking for Wave 1-4 features

Current state:
- Frontend builds successfully despite TypeScript errors (esbuild more permissive than tsc)
- Skeleton loading extended to all roles, but other UX features remain admin-only
- All Wave 1-4 functional requirements met, but quality/consistency gaps exist

Constraints:
- Must maintain backward compatibility - no breaking changes to existing features
- Must preserve existing admin UX behavior while extending to other roles
- Must complete before Wave 5 (advanced analytics, real-time features)

Stakeholders:
- Frontend developers (type safety, maintainability)
- End users (consistent UX across roles)
- QA team (test coverage visibility)

## Goals / Non-Goals

**Goals:**
- Achieve zero TypeScript compilation errors across entire frontend codebase
- Establish consistent UX patterns (dark mode, keyboard shortcuts, global search) across all three roles (admin, student, lecturer)
- Document status of all OpenSpec changes with clear categorization (complete/archived/in-progress)
- Identify and document test coverage gaps for Wave 1-4 features
- Create migration guide for future developers working on similar cross-role features

**Non-Goals:**
- Not adding new features beyond UX consistency (no new analytics, no new pages)
- Not refactoring existing working code unless required for type safety
- Not changing existing admin UX behavior (only extending to other roles)
- Not implementing missing tests (only documenting gaps - implementation is separate effort)
- Not optimizing performance beyond fixing type errors

## Decisions

### Decision 1: Fix TypeScript errors in-place vs. refactor components

**Choice:** Fix in-place with minimal changes

**Rationale:**
- Errors are localized to specific components (pagination, session mgmt routes, student pages)
- Refactoring risks introducing regressions in working features
- In-place fixes preserve git blame history and reduce review surface area

**Alternatives considered:**
- Full component refactor: Higher risk, longer timeline, no user-facing benefit
- Suppress errors with `@ts-ignore`: Technical debt, defeats purpose of TypeScript

**Implementation:**
- Admin pagination: Import `AdminPagination` component properly, destructure `start/end/total` from meta object
- Session mgmt routes: Add missing route definitions to `resources/js/routes/lecturer.ts`
- Student pages: Fix variable scoping (move `broadcast` declaration before usage), align prop types with component interfaces

### Decision 2: Extend UX features via shared components vs. role-specific implementations

**Choice:** Shared components with role-aware configuration

**Rationale:**
- Admin UX components already built and tested
- Shared components ensure consistent behavior and reduce maintenance burden
- Role-specific config allows customization (e.g., different keyboard shortcuts per role)

**Alternatives considered:**
- Copy-paste to student/lecturer: Code duplication, divergent behavior over time
- Monolithic component with role switches: Complex, hard to test, violates separation of concerns

**Implementation:**
- Extract admin-specific logic from components (e.g., `useDarkMode`, `useKeyboardShortcuts`, `useGlobalSearch`)
- Create role-agnostic hooks in `resources/js/hooks/`
- Import and configure in student/lecturer layouts
- Dark mode: Shared `ThemeProvider` context, role-specific default themes
- Keyboard shortcuts: Shared `KeyboardShortcutProvider`, role-specific shortcut maps
- Global search: Shared `GlobalSearchModal`, role-specific search endpoints

### Decision 3: OpenSpec audit approach - manual vs. automated

**Choice:** Manual audit with structured documentation

**Rationale:**
- Only 21 changes to audit - automation overhead not justified
- Manual review provides context on why changes incomplete/abandoned
- Structured markdown output serves as living documentation

**Alternatives considered:**
- Automated script parsing `.openspec.yaml`: Misses context, can't determine "why" incomplete
- No audit: Technical debt accumulates, unclear what's safe to delete

**Implementation:**
- For each change in `openspec/changes/`:
  - Check `openspec status --change <name>`
  - Read proposal.md to understand intent
  - Categorize: **Complete** (all artifacts done, implemented), **Archived** (superseded/cancelled), **In-Progress** (blocked/incomplete)
  - Document in `docs/openspec-audit.md` with status, reason, next steps

### Decision 4: Test coverage documentation format

**Choice:** Markdown table with coverage matrix

**Rationale:**
- Simple, readable, version-controllable
- Aligns with existing OpenSpec documentation patterns
- Easy to update as tests are added

**Alternatives considered:**
- Code coverage tool (Istanbul/NYC): Measures lines covered, not feature coverage
- Spreadsheet: Not version-controlled, harder to review in PRs

**Implementation:**
- Create `docs/test-coverage-wave1-4.md`
- Matrix: Feature × Test Type (Unit/Integration/E2E)
- Mark: ✅ (covered), ⚠️ (partial), ❌ (missing)
- Link to test files where they exist

## Risks / Trade-offs

**Risk:** Extending UX features to student/lecturer increases bundle size
**Mitigation:** Use code splitting, lazy load modals (dark mode toggle, global search), measure bundle impact before/after

**Risk:** Shared components break existing admin UX
**Mitigation:** Add regression tests for admin pages before refactoring, use feature flags to enable student/lecturer gradually

**Risk:** OpenSpec audit reveals more incomplete work than expected
**Mitigation:** Prioritize by user impact, defer low-priority incomplete changes to backlog

**Risk:** TypeScript fixes introduce runtime errors
**Mitigation:** Run full test suite after each fix, manual smoke test affected pages

**Trade-off:** Fixing TypeScript errors now vs. later
**Decision:** Now - prevents errors from compounding, improves developer experience immediately

**Trade-off:** Consistent UX vs. role-specific optimization
**Decision:** Consistent UX - reduces cognitive load for users with multiple roles, simplifies maintenance
