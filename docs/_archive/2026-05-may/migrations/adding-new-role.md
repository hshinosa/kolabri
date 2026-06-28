# Migration Guide: Adding a New Role

This guide walks through adding a new role to the Kolabri system. The existing three roles are `student`, `lecturer`, and `admin`. This guide assumes you want to add a fourth role (e.g., `moderator`).

---

## Step 1: Add Role to Core API

Roles originate in the Core API database. Add the new role to the Prisma schema:

**File:** `Kolabri-core-api/prisma/schema.prisma`

```prisma
enum UserRole {
    student
    lecturer
    admin
    moderator   // NEW
}
```

Run the migration:
```bash
cd Kolabri-core-api
npx prisma migrate dev --name add-moderator-role
```

Update any role enum validators in Core API middleware or controllers. Check:
- `Kolabri-core-api/src/middleware/` for role-based guards
- `Kolabri-core-api/src/validators/` for role validation schemas

---

## Step 2: Add TypeScript Type Definition

**File:** `Kolabri-client-app/resources/js/types/index.d.ts`

```typescript
export type UserRole = 'lecturer' | 'student' | 'admin' | 'moderator';  // ADD new role
```

---

## Step 3: Add Role Middleware Redirect

**File:** `Kolabri-client-app/app/Http/Middleware/RoleMiddleware.php`

Add the new role's redirect logic in the `handle()` method:

```php
public function handle(Request $request, Closure $next, string $role): Response
{
    $user = session('user');

    if (!$user || $user['role'] !== $role) {
        if ($request->expectsJson()) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // ADD new role redirect:
        if ($user && $user['role'] === 'moderator') {
            return redirect()->route('moderator.dashboard');
        }

        // Existing role redirects...
        if ($user && $user['role'] === 'admin') {
            return redirect()->route('admin.dashboard');
        }
        // ...
    }

    return $next($request);
}
```

Also update `GuestMiddleware` and `DashboardController` to handle the new role.

---

## Step 4: Create Laravel Route Group

**File:** `Kolabri-client-app/routes/web.php`

Add a new route group after the existing role groups:

```php
/*
|--------------------------------------------------------------------------
| Moderator Routes
|--------------------------------------------------------------------------
*/
Route::middleware('auth.jwt')->middleware('role:moderator')
    ->prefix('moderator')->name('moderator.')->group(function () {
        Route::get('/dashboard', [ModeratorDashboardController::class, 'index'])
            ->name('dashboard');
        
        // Add more moderator routes here
    });
```

If the route file is getting large, extract moderator routes to a separate file:
```php
// routes/web.php
require __DIR__ . '/moderator.php';
```

```php
// routes/moderator.php
Route::middleware('auth.jwt')->middleware('role:moderator')
    ->prefix('moderator')->name('moderator.')->group(function () {
        // Moderator routes
    });
```

---

## Step 5: Create Controllers

Create controller(s) for the new role:

```bash
mkdir -p Kolabri-client-app/app/Http/Controllers/Moderator
```

**Example:** `Kolabri-client-app/app/Http/Controllers/Moderator/ModeratorDashboardController.php`

```php
<?php

namespace App\Http\Controllers\Moderator;

use App\Http\Controllers\Controller;
use Inertia\Inertia;
use Inertia\Response;

class ModeratorDashboardController extends Controller
{
    public function index(): Response
    {
        // Fetch role-specific data from Core API
        try {
            $response = $this->apiRequest()->get(
                $this->apiUrl() . '/api/moderator/dashboard'
            );
            $stats = $response->successful() ? $response->json('data', []) : [];
        } catch (\Exception $e) {
            $stats = [];
        }

        return Inertia::render('moderator/dashboard', [
            'stats' => $stats,
        ]);
    }
}
```

---

## Step 6: Create React Page Component

```bash
mkdir -p Kolabri-client-app/resources/js/pages/moderator
```

**Example:** `Kolabri-client-app/resources/js/pages/moderator/dashboard.tsx`

```tsx
import { Head } from '@inertiajs/react';
import AppLayout from '@/layouts/app-layout';
import { useModeratorNav } from '@/components/navigation/moderator-nav';

interface ModeratorStats {
    pendingReports: number;
    resolvedReports: number;
    activeUsers: number;
}

interface Props {
    stats?: ModeratorStats;
}

export default function ModeratorDashboard({ stats }: Props) {
    const navItems = useModeratorNav('dashboard');

    return (
        <AppLayout title="Dashboard Moderator" navItems={navItems}>
            <Head title="Dashboard Moderator" />
            <div>
                <h1>Moderator Dashboard</h1>
                {/* Dashboard content */}
            </div>
        </AppLayout>
    );
}
```

---

## Step 7: Create Navigation Hook

**File:** `Kolabri-client-app/resources/js/components/navigation/moderator-nav.tsx`

```tsx
import moderator from '@/routes/moderator';

export function useModeratorNav(activePage: string) {
    return [
        {
            name: 'Dashboard',
            href: moderator.dashboard.url(),
            icon: /* SVG icon */,
            active: activePage === 'dashboard',
        },
        {
            name: 'Reports',
            href: moderator.reports.index.url(),
            icon: /* SVG icon */,
            active: activePage === 'reports',
        },
    ];
}
```

---

## Step 8: Wait for Route Generation

The wayfinder auto-generates TypeScript route definitions. Restart the dev server:

```bash
npm run dev
```

Check that `resources/js/routes/moderator/` was generated with the correct route definitions.

If the directory does not appear, check your `vite.config.ts` wayfinder configuration.

---

## Step 9: Register Controller in web.php Imports

**File:** `Kolabri-client-app/routes/web.php`

Add the import at the top:
```php
use App\Http\Controllers\Moderator\ModeratorDashboardController;
```

---

## Step 10: Test the New Role

1. **Login as moderator** -- ensure the Core API returns a user with `role: 'moderator'`
2. **Visit `/moderator/dashboard`** -- verify the page renders
3. **Verify middleware blocks cross-role access** -- a student should not be able to visit `/moderator/dashboard`
4. **Check navigation** -- verify the sidebar shows moderator nav items
5. **Run type check** -- `npm run tsc --noEmit` must pass

---

## Checklist

- [ ] Core API: Prisma enum updated, migration run
- [ ] Client App: `UserRole` type updated
- [ ] Client App: `RoleMiddleware` handles new role
- [ ] Client App: `GuestMiddleware` handles new role
- [ ] Client App: `DashboardController` redirects for new role
- [ ] Client App: Laravel route group created
- [ ] Client App: Controller(s) created
- [ ] Client App: React page component(s) created
- [ ] Client App: Navigation hook created
- [ ] Client App: Route imports added to `web.php`
- [ ] Client App: `tsc --noEmit` passes
- [ ] Manual test: login, dashboard, cross-role blocking