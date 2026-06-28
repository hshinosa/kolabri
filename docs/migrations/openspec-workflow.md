# Migration Guide: OpenSpec Workflow

This guide explains how to use OpenSpec for managing changes in the Kolabri project. OpenSpec is the change management workflow used across all three services (Client App, Core API, AI Engine).

---

## What is OpenSpec?

OpenSpec is a spec-driven change management tool. Each change goes through a structured lifecycle:

```
Explore → Propose → Apply → Review → Archive
```

Changes live in `openspec/changes/{change-name}/` and contain:
- `design.md` -- architecture and design decisions
- `tasks.md` -- implementation checklist
- `specs/` -- specification files (if applicable)

---

## Change Lifecycle

### 1. Explore: Understanding the Problem

Use `openspec explore` to investigate before proposing:

```bash
openspec explore "Add push notifications for students"
```

This creates a context-rich exploration of the problem space. The agent investigates:
- What already exists (related code, existing endpoints)
- What needs to change (affected files, services)
- Design alternatives and trade-offs

**When to explore:**
- Before proposing any change
- When you are unsure about the scope
- When multiple services are involved

### 2. Propose: Creating the Change

Use `openspec propose` to create the change artifacts:

```bash
openspec propose "Add push notifications for students"
```

This generates:
- `openspec/changes/student-push-notifications/design.md`
- `openspec/changes/student-push-notifications/tasks.md`

The proposal phase automatically suggests the scope (which services to modify) and initial tasks. Review and refine these artifacts before proceeding.

**Design document structure:**
```markdown
# Student Push Notifications

## Problem
Students have no way to get notified about new messages when not on the platform.

## Proposed Solution
Add push notification support via Web Push API...

## Services Affected
- Kolabri-core-api: New notification queue table, push subscription endpoints
- Kolabri-client-app: Service worker registration, notification UI

## Non-Goals
- SMS notifications
- Email notifications (already exists)
```

**Tasks structure:**
```markdown
# Tasks

## 1. Core API - Notification Infrastructure
- [ ] 1.1 Add NotificationSubscription model to Prisma schema
- [ ] 1.2 Create POST /api/notifications/subscribe endpoint
- [ ] 1.3 Create POST /api/notifications/unsubscribe endpoint
- [ ] 1.4 Add notification dispatch to chat message creation

## 2. Client App - Service Worker
- [ ] 2.1 Create service worker for push events
- [ ] 2.2 Register service worker in app.tsx
- [ ] 2.3 Create push subscription hook

## 3. Client App - UI
- [ ] 3.1 Add notification permission prompt
- [ ] 3.2 Add notification settings to profile page
```

### 3. Apply: Implementing the Change

Use `openspec apply` to execute tasks:

```bash
openspec apply student-push-notifications
```

This guides the implementation task by task. The agent reads `tasks.md`, works through items sequentially, and marks them complete.

**Best practices during apply:**
- Work one task at a time
- Run `tsc --noEmit` after TypeScript changes
- Run relevant tests after each task group
- Commit logical units (not every task, but every feature chunk)

### 4. Review: Quality Assurance

After implementation, verify the change:

```bash
openspec review student-push-notifications
```

The review checks:
- All tasks marked complete
- TypeScript compiles without errors
- Tests pass for affected services
- No regressions in existing features

### 5. Archive: Completing the Change

When the change is verified and deployed:

```bash
openspec archive student-push-notifications
```

This moves the change to `openspec/changes/archive/` and updates the audit trail.

---

## Existing Changes (Wave 1-4 Reference)

The following changes were implemented during Waves 1-4. Review these for patterns and examples:

| Change | Services | Summary |
|--------|----------|---------|
| `admin-ux-performance` | Client App | Admin dashboard UX features |
| `auth-shared-pages` | Client App, Core API | Shared auth pages and flows |
| `chat-enhancements` | Client App, Core API | Chat features and enhancements |
| `chat-polish` | Client App | UI polish for chat |
| `jwt-auto-refresh` | Client App | JWT proactive refresh |
| `lecturer-ai-settings` | Client App | AI configuration for lecturers |
| `lecturer-analytics` | Client App, Core API | Lecturer analytics dashboard |
| `lecturer-analytics-detail` | Client App, Core API | Detailed analytics views |
| `lecturer-course-detail` | Client App, Core API | Course detail page |
| `lecturer-courses` | Client App, Core API | Course management |
| `lecturer-session-mgmt` | Client App, Core API | Learning session management |
| `standardize-metrics-scale` | Core API | Standardize analytics metrics |
| `student-ai-chat` | Client App, Core API, AI Engine | AI chat for students |
| `student-chat-room-v2` | Client App, Core API | Chat room redesign |
| `student-chat-spaces` | Client App, Core API | Chat space management |
| `student-course-detail` | Client App, Core API | Course detail for students |
| `student-courses` | Client App, Core API | Course listing/enrollment |
| `student-dashboard-analytics` | Client App, Core API | Student analytics |
| `student-groups` | Client App, Core API | Group management |
| `student-profile` | Client App, Core API | Student profile |
| `student-reflections` | Client App, Core API | Student reflections |
| `verification-wave1-4` | All | Verification and audit |
| `post-wave4-cleanup` | Client App | TypeScript fixes, cleanup |

See `docs/openspec-audit.md` for the complete audit of these changes.

---

## Creating a Change That Spans Multiple Services

Most Kolabri changes touch multiple services. Follow this structure:

### Task Organization

```markdown
## 1. Core API Changes
- [ ] 1.1 Add new endpoint /api/feature-X
- [ ] 1.2 Add Prisma migration for new table
- [ ] 1.3 Add validation schemas

## 2. Client App - Backend (Laravel)
- [ ] 2.1 Add BFF proxy route for /api/feature-X
- [ ] 2.2 Create controller with proxy logic
- [ ] 2.3 Add wayfinder route definitions

## 3. Client App - Frontend (React)
- [ ] 3.1 Create page component
- [ ] 3.2 Add TypeScript interfaces
- [ ] 3.3 Add navigation item
- [ ] 3.4 Create React Query hooks

## 4. AI Engine (if applicable)
- [ ] 4.1 Add new endpoint
- [ ] 4.2 Update embedding pipeline

## 5. Verification
- [ ] 5.1 Run tsc --noEmit
- [ ] 5.2 Run Core API tests
- [ ] 5.3 Run Client App tests
- [ ] 5.4 Run AI Engine tests
- [ ] 5.5 Manual smoke test across roles
```

### Implementation Order

1. **Core API first** -- endpoints must exist before the BFF can proxy them
2. **Client App backend** -- routes and controllers before UI
3. **Client App frontend** -- pages and components use the routes
4. **AI Engine** -- if needed, can be done in parallel with steps 2-3
5. **Verification** -- always last

---

## Project Structure for OpenSpec

```
ProjectTA/
├── openspec/
│   ├── config.yaml          # OpenSpec configuration
│   ├── specs/               # Generated specifications
│   └── changes/
│       ├── student-ai-chat/      # Active/in-progress change
│       │   ├── design.md
│       │   └── tasks.md
│       └── archive/              # Completed changes
│           └── auth-shared-pages/
│               ├── design.md
│               └── tasks.md
├── Kolabri-client-app/
│   └── openspec/            # Service-local openspec (optional)
├── Kolabri-core-api/
│   └── openspec/
└── Kolabri-ai-engine/
    └── openspec/
```

The top-level `openspec/` is the authoritative source. Service-local `openspec/` directories are for service-specific tooling or additional context.

---

## Quick Reference: Common OpenSpec Commands

```bash
# Start a new change
openspec explore "Brief problem description"
openspec propose "Change name"

# Track implementation
openspec apply change-name

# View status
openspec status change-name
openspec list                # List all active changes

# Verify and archive
openspec review change-name
openspec archive change-name

# Navigate
openspec show change-name    # Show change details
```

---

## Tips for Effective OpenSpec Usage

1. **Small, focused changes.** A change should be completable in 1-3 days. If it is larger, split into sub-changes.

2. **Write clear task descriptions.** Each task should be a single action: "Add endpoint X", "Create component Y", "Add test for Z". Avoid vague tasks like "Improve performance".

3. **Include verification tasks.** Every change should end with verification: type checking, test runs, manual smoke tests.

4. **Reference existing patterns.** When proposing, check `docs/implementation-patterns.md` and `docs/architecture-decisions.md` for established patterns to follow.

5. **Document decisions.** If you make a significant architectural choice during implementation, add it to `docs/architecture-decisions.md`.

6. **Update audits.** After archiving a change, update `docs/openspec-audit.md` if one exists for that wave.

---

## Migration from Ad-hoc Development to OpenSpec

If you are working on a feature that was not started with OpenSpec:

1. **Document what exists:** Run `openspec explore` to understand the current state
2. **Create a retrospective change:** `openspec propose "Document existing feature X"`
3. **Fill in the design document:** Describe what was built and why
4. **Mark tasks as done:** Check off tasks that are already implemented
5. **Complete remaining tasks:** Use `openspec apply` for remaining work
6. **Archive:** Once fully documented and complete, archive

This approach ensures existing features are documented and new work follows the workflow.