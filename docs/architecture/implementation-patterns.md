# Implementation Patterns - Kolabri Client App

This document describes the recurring implementation patterns used across Waves 1-4. Understanding these patterns is essential for extending the application consistently.

---

## 1. BFF Proxy Pattern (Route → Controller → Core API)

The Client App acts as a Backend-for-Frontend (BFF). It never owns business data. Instead, controllers proxy requests to the Core API (Express backend on `http://localhost:3000`), enrich responses, and render Inertia pages.

### Architecture Flow

```
Browser → routes/web.php → Controller → Http::withToken() → Core API (Express)
                                                                    ↓
Browser ← Inertia Response ← Controller    ←    JSON Response
```

### Base Controller (`app/Http/Controllers/Controller.php`)

Every controller extends the base `Controller` which provides three helpers:

```php
abstract class Controller
{
    // Reads API_BASE_URL from .env, defaults to localhost:3000
    protected function apiUrl(): string
    {
        return config('services.api.base_url', 'http://localhost:3000');
    }

    // Creates an HTTP client with JWT bearer token from session
    protected function apiRequest(int $timeout = 10, int $connectTimeout = 5)
    {
        return Http::withToken(session('jwt'))
            ->timeout($timeout)
            ->connectTimeout($connectTimeout);
    }

    // Forwards raw Core API response as JSON (used for AJAX endpoints)
    protected function proxyResponse(Response $response): JsonResponse
    {
        if ($response->status() === 401) {
            session()->forget(['jwt', 'refresh_token', 'user']);
        }
        return response()->json($response->json(), $response->status());
    }
}
```

### Example: Student Course Listing

**Laravel Route** (`routes/web.php`):
```php
Route::middleware('auth.jwt')->middleware('role:student')
    ->prefix('student')->name('student.')->group(function () {
        Route::get('/courses', [StudentCourseController::class, 'index'])
            ->name('courses.index');
    });
```

**Controller** (`app/Http/Controllers/StudentCourseController.php`):
```php
class StudentCourseController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'q' => 'nullable|string|max:100',
            'filter.status' => 'nullable|string|in:aktif,selesai,belum_mulai',
            'page' => 'nullable|integer|min:1',
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);

        try {
            $response = $this->apiRequest()->get(
                $this->apiUrl() . '/api/courses/enrolled',
                array_filter($validated, fn($v) => $v !== null && $v !== '')
            );

            if ($response->successful()) {
                return $this->proxyResponse($response);
            }

            return response()->json([
                'data' => [], 'error' => 'Failed to fetch courses'
            ], $response->status());
        } catch (\Exception $e) {
            Log::error('StudentCourseController: fetch failed', [
                'error' => $e->getMessage()
            ]);
            return response()->json([
                'data' => [], 'error' => 'Service unavailable'
            ], 503);
        }
    }
}
```

### Pattern Rules

1. Always validate input before sending to Core API
2. Always wrap API calls in try/catch with fallback responses
3. Use `$this->apiRequest()` for authenticated calls, `$this->coreApiRequest()` for anonymous calls
4. JWT is stored in session (`session('jwt')`) and attached automatically by `apiRequest()`
5. On 401 responses, `proxyResponse()` clears the session (force re-login)

### Controller Organization

Controllers are organized by feature, not by role:

| Directory | Purpose |
|-----------|---------|
| `app/Http/Controllers/` | Shared/auth controllers (AuthController, DashboardController) |
| `app/Http/Controllers/Student/` | Student-specific controllers (Profile, Messages, etc.) |
| `app/Http/Controllers/Lecturer/` | Lecturer-specific controllers (Sessions, Attendance, etc.) |

Shared controllers handle role-based behavior via method dispatch:

```php
// DashboardController - serves different data per role
public function index(): InertiaResponse|RedirectResponse
{
    $user = session('user');
    if ($user['role'] === 'admin') {
        return redirect()->route('admin.dashboard');
    }
    if ($user['role'] === 'lecturer') {
        return $this->lecturerDashboard();
    }
    return $this->studentDashboard();
}
```

---

## 2. Inertia.js Page Pattern (Controller → Props → React Component)

Kolabri uses Inertia.js to bridge Laravel controllers and React components without building a separate SPA API.

### How It Works

```
Laravel Controller
    ↓  Inertia::render('path/to/page', [...props...])
Inertia Middleware
    ↓  JSON response with component name + props
Inertia Client (React)
    ↓  Mounts React component, hydrates props
Browser renders React page
```

### Laravel-Side: Rendering Pages

**Simple page render** (no data needed):
```php
// routes/web.php
Route::get('/radar-chart', function () {
    return Inertia::render('lecturer/RadarChartPage');
})->name('radar-chart');
```

**Page with server-fetched data**:
```php
// CourseController - fetches data from Core API then renders
public function index(): Response
{
    try {
        $response = $this->apiRequest()->get($this->apiUrl() . '/api/courses');
        $courses = $response->successful() ? $response->json('data', []) : [];
    } catch (\Exception $e) {
        Log::error('CourseController: fetch failed', ['error' => $e->getMessage()]);
        $courses = [];
    }

    $analytics = $this->computeAnalytics($courses);

    return Inertia::render('lecturer/courses/index', [
        'courses' => $courses,
        'analytics' => $analytics,
    ]);
}
```

### React-Side: Page Components

Pages live under `resources/js/pages/{role}/` and receive props via function arguments:

```tsx
// resources/js/pages/student/dashboard.tsx
interface StudentStats {
    enrolledCourses: number;
    activeGroups: number;
    reflections: number;
    chatMessages: number;
}

interface Props {
    enrolledCourses?: unknown[];
    stats?: StudentStats;
    recentActivity?: ActivityItem[];
}

export default function StudentDashboard({ stats, recentActivity = [] }: Props) {
    const { auth } = usePage<SharedData>().props;
    const navItems = useStudentNav('courses');

    return (
        <AppLayout title="Dashboard Mahasiswa" navItems={navItems}>
            <Head title="Dashboard Mahasiswa" />
            {/* page content */}
        </AppLayout>
    );
}
```

### Shared Data

`HandleInertiaRequests` middleware shares session data to every page as props:

```php
public function share(Request $request): array
{
    return [
        ...parent::share($request),
        'name' => config('app.name', 'Kolabri'),
        'auth' => [
            'user' => session('user'),
        ],
        'flash' => [
            'success' => fn() => $request->session()->get('success'),
            'error' => fn() => $request->session()->get('error'),
        ],
    ];
}
```

Access shared data in any React component:
```tsx
const { auth, flash } = usePage<SharedData>().props;
```

### TypeScript Type Definitions

All shared types are in `resources/js/types/index.d.ts`:

```typescript
export type UserRole = 'lecturer' | 'student' | 'admin';

export interface User {
    id: string;
    name: string;
    email: string;
    role: UserRole;
    avatar?: string;
    created_at: string;
    updated_at: string;
}

export interface SharedData {
    auth: { user: User | null };
    flash: { success?: string; error?: string };
}
```

### AJAX Data Fetching (React Query Pattern)

Pages that need dynamic/filtered data use React Query + the BFF API endpoints:

```tsx
// Pages call BFF JSON endpoints (not Core API directly)
const { data, isLoading } = useQuery({
    queryKey: ['courses', searchQuery, statusFilter, page],
    queryFn: async () => {
        const response = await axios.get('/student/courses', {
            params: { q: searchQuery, filter: { status: statusFilter }, page }
        });
        return response.data;
    },
});
```

The Inertia route hits `StudentCourseController::enrolled()` (renders the page), then React Query calls `StudentCourseController::index()` (JSON API) via the same `/student/courses` path but with `Accept: application/json`.

### Page Directory Structure

```
resources/js/pages/
├── welcome.tsx              # Landing page (unauthenticated)
├── PlanVsDiskusiPage.tsx    # Shared analytics page
├── auth/                    # Login, register, forgot password
├── student/
│   ├── dashboard.tsx
│   ├── courses/             # Course listing, detail, join
│   ├── groups/              # Group management
│   ├── reflections/         # Student reflections
│   ├── chat-spaces/         # Chat space views
│   ├── chat/                # Chat room (Socket.io)
│   ├── ai-chat/             # AI chat interface
│   ├── goals/               # Learning goals
│   └── profile/             # Student profile
├── lecturer/
│   ├── dashboard.tsx
│   ├── courses/             # Course management
│   ├── groups/              # Group overview
│   ├── session-mgmt/        # Learning session management
│   ├── analytics/           # Analytics dashboards
│   ├── ai-settings.tsx      # AI configuration
│   └── RadarChartPage.tsx   # Radar visualization
├── admin/
│   ├── dashboard.tsx
│   ├── master-data.tsx      # Course master data
│   ├── user-management.tsx  # User CRUD
│   ├── audit-log.tsx        # Audit trail viewer
│   ├── ai-settings.tsx      # Platform AI settings
│   ├── ai-comparison.tsx    # AI model comparison
│   └── templates.tsx        # Course templates
└── settings/                # User settings (shared)
```

---

## 3. Role-Based Routing Pattern (Middleware, Route Files, Navigation)

### Architecture

Kolabri has three user roles: `student`, `lecturer`, `admin`. Each role has isolated pages, routes, and navigation, enforced at multiple layers.

### Layer 1: Laravel Middleware

**`JwtAuthMiddleware`** (applied to all protected routes):
```php
// routes/web.php
Route::middleware('auth.jwt')->group(function () {
    // All authenticated routes go here
});
```

The middleware:
1. Checks `session('jwt')` and `session('user')` exist
2. Decodes JWT payload, checks `exp` claim
3. If expired, attempts proactive refresh with `refresh_token`
4. On failure, clears session and redirects to login

**`RoleMiddleware`** (applied per role prefix):
```php
Route::middleware('role:admin')->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'admin'])->name('dashboard');
    // ...
});

Route::middleware('role:lecturer')->prefix('lecturer')->name('lecturer.')->group(function () {
    Route::get('/courses', [CourseController::class, 'index'])->name('courses.index');
    // ...
});

Route::middleware('role:student')->prefix('student')->name('student.')->group(function () {
    Route::get('/courses', [StudentCourseController::class, 'enrolled'])
        ->name('courses.index');
    // ...
});
```

`RoleMiddleware::handle()` verifies `session('user')['role']` matches. On mismatch, redirects to the user's actual role dashboard (or login if unauthenticated).

**`GuestMiddleware`** (applied to auth pages):
```php
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('auth.login.index');
    // ...
});
```

Redirects authenticated users away from login/register pages.

### Layer 2: Frontend Route Definitions (Wayfinder)

Each route has a TypeScript definition in `resources/js/routes/`. These are auto-generated by the `laravel-vite-plugin` wayfinder and provide type-safe URL builders:

```
resources/js/routes/
├── index.ts          # Top-level routes (home, dashboard)
├── auth/             # Login, register, logout
├── student/          # Student-specific routes
│   ├── index.ts      # Aggregates all student sub-routes
│   ├── courses/      # Course routes
│   ├── groups/       # Group routes
│   ├── reflections/  # Reflection routes
│   ├── ai-chat/      # AI chat routes
│   ├── chat-spaces/  # Chat space routes
│   ├── goals/        # Goal routes
│   └── profile/      # Profile routes
├── lecturer/         # Lecturer-specific routes
│   ├── index.ts      # Aggregates all lecturer sub-routes
│   ├── courses/      # Course management routes
│   ├── groups/       # Group overview routes
│   ├── analytics/    # Analytics routes
│   ├── ai-settings/  # AI settings routes
│   ├── sessions/     # Session management routes
│   └── session-templates/
├── admin/            # Admin-specific routes
│   ├── index.ts      # Aggregates all admin sub-routes
│   ├── users/        # User management routes
│   ├── master-data/  # Course master data routes
│   ├── audit-log/    # Audit log routes
│   ├── ai-settings/  # Platform AI settings
│   ├── ai-comparison/ # AI comparison routes
│   └── course-templates/
├── settings/         # Shared settings routes
└── chat/             # Chat API routes
```

Each route definition is type-safe:
```typescript
// resources/js/routes/student/courses/index.ts
export const index = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
    url: index.url(options),
    method: 'get',
});

index.definition = {
    methods: ["get", "head"],
    url: '/student/courses',
} satisfies RouteDefinition<["get", "head"]>;

index.url = (options?: RouteQueryOptions) => {
    return index.definition.url + queryParams(options);
};
```

Usage in components:
```tsx
import student from '@/routes/student';

// Type-safe URL generation
<Link href={student.courses.index.url()}>Mata Kuliah</Link>
<Link href={student.courses.index.url({ query: { page: 2 } })}>Page 2</Link>
```

### Layer 3: Navigation Components

Each role has a dedicated navigation hook that builds the sidebar menu:

| File | Export | Used By |
|------|--------|---------|
| `components/navigation/student-nav.tsx` | `useStudentNav(activePage, context?)` | Student pages |
| `components/navigation/lecturer-nav.tsx` | `useLecturerNav(activePage, context?)` | Lecturer pages |
| `components/navigation/admin-nav.tsx` | `useAdminNav(activePage)` | Admin pages |

Example navigation hook:
```tsx
// student-nav.tsx
export function useStudentNav(activePage: ActivePage, context?: StudentNavContext): NavItem[] {
    return [
        {
            name: 'Mata Kuliah Saya',
            href: student.courses.index.url(),
            icon: Icons.courses,
            active: ['courses', 'course-detail', 'groups', 'chat-spaces', 'chat-room', 'goals']
                .includes(activePage),
        },
        {
            name: 'Refleksi',
            href: student.reflections.index.url(),
            icon: Icons.reflections,
            active: activePage === 'reflections',
        },
        {
            name: 'Chat dengan AI',
            href: student.aiChat.index.url(),
            icon: Icons.aiChat,
            active: activePage === 'ai-chat',
        },
    ];
}
```

Navigation hooks support context-aware sub-items (e.g., when inside a specific course, show course-specific navigation).

### Layer 4: AppLayout Component

`AppLayout` (`resources/js/layouts/app-layout.tsx`) renders the sidebar, top bar, dark mode toggle, search, and keyboard shortcuts. Every dashboard page wraps its content in AppLayout:

```tsx
export default function StudentDashboard({ stats }: Props) {
    const navItems = useStudentNav('courses');
    return (
        <AppLayout title="Dashboard Mahasiswa" navItems={navItems}>
            <Head title="Dashboard Mahasiswa" />
            {/* page content */}
        </AppLayout>
    );
}
```

### Middleware Registration (Kernel)

All middleware aliases are registered in `app/Http/Kernel.php`:
```php
protected $middlewareAliases = [
    'auth.jwt' => JwtAuthMiddleware::class,
    'role' => RoleMiddleware::class,
    'guest' => GuestMiddleware::class,
];
```

### Complete Request Flow

```
Request: GET /lecturer/courses
    ↓
JwtAuthMiddleware: session('jwt') valid? → yes
    ↓
RoleMiddleware('lecturer'): session('user')['role'] === 'lecturer'? → yes
    ↓
CourseController::index()
    ↓
$this->apiRequest()->get('http://localhost:3000/api/courses')
    ↓
Core API returns JSON
    ↓
Inertia::render('lecturer/courses/index', ['courses' => $data])
    ↓
React mounts page, useLecturerNav('courses') builds nav
    ↓
Browser displays lecturer course listing
```

---

## 4. TypeScript Auto-Generated Route Pattern

Route definitions in `resources/js/routes/` are auto-generated by the Laravel Vite plugin's wayfinder feature. They are regenerated whenever a new Laravel route is defined.

**DO NOT manually edit** files under `resources/js/routes/`. They are regenerated during `npm run dev` or `npm run build`.

To regenerate routes:
```bash
npm run dev    # Watch mode - auto-regenerates on route changes
npm run build  # One-time regeneration
```

---

## 5. Environment Configuration

**`.env`** key variables:
```env
API_BASE_URL=http://localhost:3000    # Core API URL
SOCKET_URL=http://localhost:3000      # Socket.io server (same as Core API)
```

**`config/services.php`** maps env to config:
```php
'api' => [
    'base_url' => env('API_BASE_URL', 'http://localhost:3000'),
    'socket_url' => env('SOCKET_URL', 'http://localhost:3000'),
],
```

---

## 6. Quick Reference: Adding a New Page

1. **Create the React page** in `resources/js/pages/{role}/my-page.tsx`
2. **Add Laravel route** in `routes/web.php` inside the appropriate role group:
   ```php
   Route::get('/my-page', [MyController::class, 'index'])->name('my-page.index');
   ```
3. **Create controller method** that renders the Inertia page:
   ```php
   public function index(): Response {
       return Inertia::render('lecturer/my-page', ['data' => $fetchedData]);
   }
   ```
4. **Wait for Vite** to regenerate wayfinder routes (or restart dev server)
5. **Import the route** in a navigation component or link:
   ```tsx
   import lecturer from '@/routes/lecturer';
   <Link href={lecturer.myPage.index.url()}>My Page</Link>
   ```
6. **Add to navigation** in the appropriate nav hook
7. **Define TypeScript interfaces** in `resources/js/types/index.d.ts` if needed
8. **Run `tsc --noEmit`** to verify no type errors