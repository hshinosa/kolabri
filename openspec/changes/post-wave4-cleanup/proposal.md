## Why

Wave 1-4 implementation introduced TypeScript errors from incomplete admin UX/performance features (pagination, session mgmt routes), inconsistent UX patterns across roles (skeleton loading, dark mode, keyboard shortcuts only in admin), and missing OpenSpec change tracking. This cleanup ensures type safety, consistent UX across all roles, and proper change documentation before moving to Wave 5.

## What Changes

- Fix 17 TypeScript errors from admin UX/performance implementation (pagination component imports, route definitions, variable scoping)
- Audit and document status of all OpenSpec changes (identify incomplete, in-progress, archived)
- Extend admin UX features to student/lecturer roles (dark mode, keyboard shortcuts, global search)
- Add missing test coverage for Wave 1-4 features
- Document Wave 1-4 implementation patterns and decisions

## Capabilities

### New Capabilities
- `typescript-error-fixes`: Fix all TypeScript compilation errors from admin pagination, session mgmt routes, and student pages
- `openspec-audit`: Audit all changes in `openspec/changes/`, categorize by status, identify gaps
- `ux-consistency`: Extend dark mode, keyboard shortcuts, global search from admin to student/lecturer roles
- `test-coverage`: Add missing unit/integration tests for Wave 1-4 features
- `documentation`: Document implementation patterns, architectural decisions, migration guides

### Modified Capabilities
<!-- No existing spec requirements changing - this is cleanup/extension work -->

## Impact

**Affected Code:**
- `resources/js/pages/admin/master-data.tsx` - pagination fixes
- `resources/js/pages/admin/user-management.tsx` - pagination fixes
- `resources/js/components/session-mgmt/` - route definition fixes
- `resources/js/pages/student/ai-chat/index.tsx` - variable scoping fix
- `resources/js/pages/student/chat/room.tsx` - prop type fix
- `resources/js/pages/student/**/*.tsx` - dark mode, keyboard shortcuts, global search extension
- `resources/js/pages/lecturer/**/*.tsx` - dark mode, keyboard shortcuts, global search extension

**APIs:**
- No breaking API changes
- Session mgmt routes need proper registration in Laravel routes

**Dependencies:**
- No new dependencies
- Existing admin UX components reused for student/lecturer

**Systems:**
- Frontend build must pass TypeScript check
- All roles must have consistent UX patterns
- OpenSpec change tracking must be complete
