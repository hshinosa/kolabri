# Architecture Decisions - Kolabri

This document captures the key architectural decisions made during Waves 1-4. Each decision includes context, rationale, and trade-offs.

---

## 1. BFF (Backend-for-Frontend) Architecture

### Decision

The Client App (`Kolabri-client-app`, a Laravel application) acts as a Backend-for-Frontend. It never holds business data. All business logic, authentication, and data persistence live in the Core API (`Kolabri-core-api`, an Express/Node.js application). The Client App is purely a presentation layer that proxies requests, enriches responses, and renders pages.

### Context

Kolabri has three services:
- **Kolabri-core-api** (Express, Prisma/PostgreSQL, MongoDB) -- owns all business logic, auth, data
- **Kolabri-client-app** (Laravel, Inertia.js, React) -- presentation layer, role-based UI
- **Kolabri-ai-engine** (Python/FastAPI, Qdrant) -- AI chat, embeddings, RAG

### Rationale

**Separation of concerns.** The Core API is a headless backend that could serve multiple clients (mobile, CLI, third-party). The Client App is one presentation of that backend, optimized for browser-based role-specific UX.

**Security isolation.** The Core API handles JWT issuance, password hashing, and all data access. The Client App never touches the database directly. Session data (JWT, user profile) is stored in Laravel's encrypted session, not in database tables.

**Independent deployability.** The Core API can be scaled independently of the frontend. Changes to UX (new pages, different layouts) do not require Core API redeployment.

**Multi-role UI from one backend.** A single Core API serves all three roles (student, lecturer, admin). The Client App enforces role-based routing and renders role-specific pages.

### How It Works

```
Browser (student) → /student/courses
    → Laravel route (auth.jwt + role:student middleware)
    → StudentCourseController::index()
    → Http::withToken(session('jwt'))->get('http://localhost:3000/api/courses/enrolled')
    → Core API validates JWT, queries DB, returns JSON
    → Controller returns JSON to browser (AJAX) or Inertia response (page)

Browser (lecturer) → /lecturer/courses
    → Same pattern, different URL prefix, different Core API endpoint
```

### API URL Configuration

```env
# .env
API_BASE_URL=http://localhost:3000
SOCKET_URL=http://localhost:3000
```

The base controller reads this configuration:
```php
protected function apiUrl(): string
{
    return config('services.api.base_url', 'http://localhost:3000');
}
```

### Trade-offs

| Pro | Con |
|-----|-----|
| Clean separation of concerns | Extra network hop per request |
| Independent scaling | Latency overhead for proxy calls |
| Single Core API for all clients | Two codebases to maintain |
| No DB dependency in frontend | Session must sync with JWT expiry |

### Alternative Considered: Direct database access from Laravel

Rejected because it would couple the frontend to the database schema, create duplication of auth logic, and prevent a single source of truth for business rules.

---

## 2. Monorepo Structure

### Decision

The project uses a monorepo with three top-level applications and shared infrastructure:

```
ProjectTA/
├── Kolabri-client-app/     # Laravel + Inertia.js + React (TypeScript)
├── Kolabri-core-api/       # Express + Prisma (TypeScript)
├── Kolabri-ai-engine/      # FastAPI + Python (Python)
├── docker-compose.yml      # All infrastructure and app services
├── openspec/               # OpenSpec change management (shared)
├── docs/                   # Cross-project documentation
└── dev.sh                  # One-command development environment
```

### Rationale

**Single source of truth for configuration.** `docker-compose.yml` defines all services, networks, and volumes in one place. No service can be misconfigured relative to another.

**Shared development workflow.** `dev.sh` starts all services, runs migrations, and watches for changes. New developers clone one repo and run one command.

**Cross-cutting changes.** Features that span layers (e.g., adding a new API endpoint in Core API with its Client App proxy and AI Engine integration) can be tracked as a single change set.

**OpenSpec integration.** `openspec/` tracks changes across all services. A single `openspec/changes/lecturer-session-mgmt/` change can include tasks for Core API, Client App, and AI Engine.

### Service Communication

```
                     ┌─────────────────┐
                     │  Qdrant (6333)  │ ← AI Engine uses for vector search
                     └─────────────────┘
                            ↑
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│ Client App  │──────│  Core API    │──────│  PostgreSQL  │
│ (Laravel)   │ HTTP │  (Express)   │      │  (5432)      │
│ port: 8000  │      │  port: 3000  │      └──────────────┘
└─────────────┘      └──────────────┘
                            ↑              ┌──────────────┐
                     REST API calls        │  MongoDB     │
                     ┌──────────────┐      │  (27017)     │
                     │  AI Engine   │──────│   ← Chat logs│
                     │  (FastAPI)   │      └──────────────┘
                     │  port: 8001  │
                     └──────────────┘
```

All services communicate via HTTP/REST. There is no shared database, no gRPC, no message queue between services. This keeps the architecture simple and debuggable.

### Trade-offs

| Pro | Con |
|-----|-----|
| One `git clone`, one `docker compose up` | Large repo size |
| Shared config, shared docs | Harder to assign per-service permissions |
| Cross-service PRs trackable | CI must build/test multiple stacks |
| Consistent dependency versions | Lockfile conflicts possible |

---

## 3. TypeScript Strict Mode

### Decision

Both the Client App (`tsconfig.json`) and Core API (`tsconfig.json`) enable TypeScript strict mode with additional checks:

**Client App** (`Kolabri-client-app/tsconfig.json`):
```json
{
    "compilerOptions": {
        "strict": true,
        "noImplicitAny": true,
        "strictNullChecks": true,          // implied by strict
        "forceConsistentCasingInFileNames": true,
        "esModuleInterop": true,
        "isolatedModules": true,
        "noEmit": true,
        "target": "ESNext",
        "module": "ESNext",
        "moduleResolution": "bundler",
        "jsx": "react-jsx",
        "skipLibCheck": true
    }
}
```

**Core API** (`Kolabri-core-api/tsconfig.json`):
```json
{
    "compilerOptions": {
        "strict": true,
        "target": "ES2022",
        "module": "NodeNext",
        "moduleResolution": "NodeNext",
        "forceConsistentCasingInFileNames": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "declaration": true,
        "sourceMap": true
    }
}
```

### Rationale

**Type safety across the stack.** With the BFF pattern, data flows from Core API → Controller → React component. TypeScript strict mode ensures this data flow remains type-safe at both ends. If the Core API changes a field name, TypeScript catches the mismatch in the Client App's type definitions.

**Catch bugs at compile time.** `noImplicitAny` forces explicit typing for all parameters. `strictNullChecks` prevents null reference errors. The Wave 4 verification task (`tsc --noEmit` with zero errors) confirmed no type violations across 20+ pages.

**Shared type definitions.** The Client App maintains TypeScript interfaces that mirror Core API responses:

```typescript
// resources/js/types/index.d.ts
export type UserRole = 'lecturer' | 'student' | 'admin';
export type CourseStatus = 'aktif' | 'selesai' | 'belum_mulai';

export interface Course {
    id: string;
    code: string;
    name: string;
    status?: CourseStatus;
    students_count?: number;
    groups_count?: number;
    // ...
}
```

These types are the contract between Core API responses and React component props. Any mismatch is a compile error.

**Enforcement via CI (Wave 4 verification).** The `verification-wave1-4` change established `tsc --noEmit` as a gate. No deployment is allowed with type errors. This was enforced by fixing all accumulated type errors in Tasks 1-4 of the `post-wave4-cleanup` change.

### Trade-offs

| Pro | Con |
|-----|-----|
| Catch mismatches between API and UI | More verbose type annotations |
| Self-documenting code via interfaces | Steeper learning curve for new contributors |
| Refactoring safety | Some third-party libs have incomplete types |

---

## 4. Session-Based Auth with JWT to Core API

### Decision

Authentication uses Laravel sessions for browser state with JWT tokens forwarded to the Core API:

```
User Login
    ↓
POST /login → AuthController::login()
    ↓
Http::post(CoreAPI + '/api/auth/login') → Core API validates credentials
    ↓
Core API returns JWT + refresh_token + user profile
    ↓
Laravel stores in session: session(['jwt' => $token, 'refresh_token' => $rt, 'user' => $user])
    ↓
All subsequent requests: JwtAuthMiddleware reads session('jwt')
    ↓
Controllers: Http::withToken(session('jwt'))->get(CoreAPI + '/api/...')
```

### Rationale

**Browser-native session management.** Inertia.js works best with cookie/session-based auth. The session survives page reloads, is encrypted by Laravel, and is transparent to React components.

**JWT for API-level auth.** The Core API uses JWT as its primary auth mechanism. The Client App simply stores and forwards the token. This keeps the Core API client-agnostic.

**Proactive refresh.** `JwtAuthMiddleware` detects expired tokens and attempts refresh before the request fails:

```php
if ($exp <= time() && session('refresh_token')) {
    $newToken = $this->proactiveRefresh(session('refresh_token'));
    if ($newToken) {
        session(['jwt' => $newToken]);
    } else {
        session()->forget(['jwt', 'refresh_token', 'user']);
        return redirect()->route('auth.login.index');
    }
}
```

This prevents users from experiencing mid-session timeouts.

---

## 5. Inertia.js over SPA + REST API

### Decision

The Client App uses Inertia.js to bridge Laravel controllers and React components, rather than building a standalone SPA with a REST API.

### Rationale

**Server-side routing.** Laravel handles routing, middleware, and authorization. React components only receive data and render UI. This eliminates the need for client-side auth guards, route protection, and API token management in JavaScript.

**No API duplication.** Without Inertia, every page would need two endpoints: one for the initial HTML render and one for JSON data. Inertia unifies these into a single controller method that returns the same JSON whether it is a full page load or an Inertia visit.

**Progressive enhancement.** Pages that need dynamic data (search, filtering, pagination) use React Query to call JSON API endpoints. Pages that only show static content use server-rendered Inertia props. Both patterns coexist.

**Shared session state.** Flash messages, auth user, and CSRF token are shared to every page via `HandleInertiaRequests::share()`. No need for a global state manager.

### Comparison

| Pattern | When to Use |
|---------|-------------|
| `Inertia::render('page', [props])` | Page loads with server-fetched data |
| React Query + axios to BFF endpoint | Dynamic data: search, filter, paginate, real-time updates |
| `usePage<SharedData>().props` | Access session data (auth, flash) in any component |

```tsx
// Server-rendered props: simple, static data
export default function LecturerCourses({ courses, analytics }: Props) {
    // courses and analytics come from controller, no client fetching needed
}

// React Query: dynamic, user-driven data
function StudentCourses() {
    const { data } = useQuery({
        queryKey: ['courses', searchQuery, page],
        queryFn: () => axios.get('/student/courses', { params: { q: searchQuery, page } }),
    });
}
```

---

## 6. Role-Based Route Isolation

### Decision

Routes are organized by role prefix with separate middleware chains, navigation components, and page directories. No shared dashboard. No shared sidebar.

### Rationale

**Prevent cross-role access by design.** A student cannot accidentally render a lecturer page because the `role:student` middleware rejects requests to `/lecturer/*` and vice versa. This is defense in depth: even if a link is wrong, the middleware blocks it.

**Clear mental model.** Each role's routes are in one contiguous block:

```php
// Admin routes
Route::middleware('role:admin')->prefix('admin')->name('admin.')->group(function () {
    // All admin routes here
});

// Lecturer routes
Route::middleware('role:lecturer')->prefix('lecturer')->name('lecturer.')->group(function () {
    // All lecturer routes here
});

// Student routes
Route::middleware('role:student')->prefix('student')->name('student.')->group(function () {
    // All student routes here
});
```

Developers working on one role never need to look at another role's routes.

**Independent UX evolution.** Each role can evolve its navigation, layout, and page structure independently. Changes to admin UX (e.g., adding a keyboard shortcut) do not affect student or lecturer pages.

---

## 7. Core API as Single Backend for All Roles

### Decision

The Core API serves all three roles from a single Express application. Role-based access control is implemented at the API level (not at the BFF level).

### Rationale

**Single source of truth.** All business logic (auth, courses, groups, reflections, analytics) lives in one codebase. If a bug is found in course enrollment logic, it is fixed once in the Core API and all roles benefit.

**Shared data model.** Prisma schema defines the database structure. All roles read and write the same tables. There is no risk of data inconsistency between role-specific backends.

**Cross-role features.** Features like notifications, audit logging, and analytics aggregate data across roles. A single backend simplifies these cross-cutting concerns.

---

## 8. Component Organization by Feature, Not Role

### Decision

React components are organized by feature function, not by which role uses them:

```
resources/js/components/
├── dashboard/          # Breadcrumbs, NotificationCenter, ActivityFeed
├── navigation/         # admin-nav, student-nav, lecturer-nav
├── ui/                 # Reusable UI primitives (Dropdown, Dialog, SearchModal, etc.)
├── admin/              # Admin-specific components
├── chat/               # Chat-related components (shared by student/lecturer)
├── Welcome/            # Landing page components
└── error-boundary.tsx  # Global error boundary
```

### Rationale

**Reuse across roles.** `dashboard/Breadcrumbs` is used by all three roles. `dashboard/NotificationCenter` is used by student and lecturer. Putting these in role-specific directories would cause either duplication or confusing imports.

**Clear dependency direction.** Feature components (admin, chat) depend on UI primitives. UI primitives never depend on feature components. This prevents circular dependencies.

**Testability.** Components in `ui/` can be tested in isolation without mocking role-specific context. Feature components can be tested with their specific data shapes.

---

## 9. Testing Strategy

### Decision

Tests live alongside the service they test, not in a shared test directory:

| Service | Test Framework | Location |
|---------|---------------|----------|
| Client App | PHPUnit (Laravel) | `Kolabri-client-app/tests/` |
| Client App | Vitest + Playwright | `Kolabri-client-app/tests/` + `playwright.config.ts` |
| Core API | Vitest | `Kolabri-core-api/tests/` |
| AI Engine | pytest | `Kolabri-ai-engine/tests/` |

### Rationale

**Independence.** Each service can run its own test suite without depending on other services. The Client App can mock Core API responses. The Core API can use test databases.

**Appropriate tools.** PHPUnit is the standard Laravel test runner. Vitest is the Vite-native test runner for TypeScript/React. pytest is the Python standard.

**Coverage documentation.** `docs/test-coverage-wave1-4.md` documents the test matrix across all roles and features, identifying gaps for future test development.