# Migration Guide: Extending UX Features

This guide covers adding UX features to the Kolabri Client App. UX features are shared enhancements like dark mode, keyboard shortcuts, global search, and notification systems that apply across roles.

---

## Step 1: Identify the Feature Scope

Decide whether the feature applies to:
- **All roles** (dark mode, keyboard shortcuts) -- implement as hooks + contexts, add to `AppLayout`
- **One role** (admin-specific search) -- implement in role-specific components
- **Shared but role-aware** (global search with role-scoped results) -- implement as shared component with role-aware backends

This guide covers **all-roles** UX features, since that is the most complex case.

---

## Step 2: Create the Hook

Hooks encapsulate UX logic and state. Place them in `resources/js/hooks/`.

**Example: Dark Mode Hook**

**File:** `Kolabri-client-app/resources/js/hooks/useDarkMode.ts`

```tsx
import { useState, useEffect, useCallback } from 'react';

export function useDarkMode() {
    const [darkMode, setDarkMode] = useState<boolean>(() => {
        if (typeof window === 'undefined') return false;
        return localStorage.getItem('kolabri_theme') === 'dark';
    });

    useEffect(() => {
        const root = document.documentElement;
        if (darkMode) {
            root.classList.add('dark');
            localStorage.setItem('kolabri_theme', 'dark');
        } else {
            root.classList.remove('dark');
            localStorage.setItem('kolabri_theme', 'light');
        }
    }, [darkMode]);

    const toggleDarkMode = useCallback(() => {
        setDarkMode(prev => !prev);
    }, []);

    return { darkMode, toggleDarkMode };
}
```

**Pattern rules:**
- Persist state via `localStorage`
- Expose state + toggle/mutate functions
- Use `useCallback` for stable function references
- Handle SSR (`window` check)

---

## Step 3: Create the Context (Optional)

For features that need global state across the component tree, create a context:

**File:** `Kolabri-client-app/resources/js/contexts/ThemeContext.tsx`

```tsx
import { createContext, useContext, PropsWithChildren } from 'react';
import { useDarkMode } from '@/hooks/useDarkMode';

interface ThemeContextValue {
    darkMode: boolean;
    toggleDarkMode: () => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

export function ThemeProvider({ children }: PropsWithChildren) {
    const theme = useDarkMode();
    return (
        <ThemeContext.Provider value={theme}>
            {children}
        </ThemeContext.Provider>
    );
}

export function useTheme(): ThemeContextValue {
    const ctx = useContext(ThemeContext);
    if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
    return ctx;
}
```

Use contexts when multiple components need access to the same UX state. Skip contexts when the state is local to one component.

---

## Step 4: Create Role-Specific Configuration

If the feature varies by role, create role-specific config:

**File:** `Kolabri-client-app/resources/js/config/shortcuts/student.ts`

```typescript
import { ShortcutMap } from '@/hooks/useKeyboardShortcuts';

export const studentShortcuts: ShortcutMap = {
    'courseSearch': {
        keys: ['Ctrl', 'k'],
        description: 'Cari mata kuliah',
        action: () => { /* trigger course search */ },
    },
    'profile': {
        keys: ['Ctrl', 'p'],
        description: 'Buka profil',
        action: () => { /* navigate to profile */ },
    },
};
```

**File:** `Kolabri-client-app/resources/js/config/shortcuts/lecturer.ts`

```typescript
export const lecturerShortcuts: ShortcutMap = {
    'sessionManagement': {
        keys: ['Ctrl', 's'],
        description: 'Manajemen sesi',
        action: () => { /* navigate to sessions */ },
    },
    'analytics': {
        keys: ['Ctrl', 'a'],
        description: 'Dashboard analitik',
        action: () => { /* navigate to analytics */ },
    },
};
```

---

## Step 5: Create the UI Component

Place the component in `resources/js/components/ui/` for reusable UI, or `resources/js/components/{feature}/` for feature-specific components.

**Example: Dark Mode Toggle**

**File:** `Kolabri-client-app/resources/js/components/ui/DarkModeToggle.tsx`

```tsx
import { Moon, Sun } from 'lucide-react';

interface DarkModeToggleProps {
    darkMode: boolean;
    onToggle: () => void;
}

export default function DarkModeToggle({ darkMode, onToggle }: DarkModeToggleProps) {
    return (
        <button
            onClick={onToggle}
            className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
            aria-label={darkMode ? 'Switch to light mode' : 'Switch to dark mode'}
        >
            {darkMode ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
        </button>
    );
}
```

**Pattern rules:**
- Accept state via props, not internal state (keep hook at layout level)
- Use `lucide-react` icons (consistent across the app)
- Add `aria-label` for accessibility
- Support dark mode classes (`dark:` prefix)

---

## Step 6: Add to AppLayout

The `AppLayout` component is the single integration point for cross-role UX features:

**File:** `Kolabri-client-app/resources/js/layouts/app-layout.tsx`

```tsx
import DarkModeToggle from '@/components/ui/DarkModeToggle';
import { useDarkMode } from '@/hooks/useDarkMode';
import { GlobalSearch } from '@/components/admin/GlobalSearch';
import { KeyboardShortcutsHelp } from '@/components/admin/KeyboardShortcutsHelp';

export default function AppLayout({ children, title, navItems }: AppLayoutProps) {
    const { darkMode, toggleDarkMode } = useDarkMode();
    const [searchOpen, setSearchOpen] = useState(false);

    return (
        <div className="flex h-screen">
            {/* Sidebar */}
            <aside className="sidebar">
                {/* navigation */}
                <DarkModeToggle darkMode={darkMode} onToggle={toggleDarkMode} />
            </aside>

            {/* Main content */}
            <main>
                {/* Top bar with search trigger */}
                <button onClick={() => setSearchOpen(true)}>Search (Ctrl+K)</button>
                {children}
            </main>

            {/* Global modals */}
            {searchOpen && <GlobalSearch onClose={() => setSearchOpen(false)} />}
        </div>
    );
}
```

**Do NOT add role-specific UI directly to AppLayout.** If a feature is only for one role, add it to that role's page components, not AppLayout. AppLayout is shared by all roles.

---

## Step 7: Add BFF Endpoints (If Feature Needs Backend)

If the UX feature needs server-side data (e.g., global search needs search results), create a BFF endpoint:

**Route:** `Kolabri-client-app/routes/web.php`
```php
// Add inside the auth.jwt group
Route::get('/api/search', [SearchController::class, 'globalSearch'])
    ->name('search.global');
```

**Controller:**
```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function globalSearch(Request $request): JsonResponse
    {
        $query = $request->validate(['q' => 'required|string|min:2|max:100'])['q'];
        $user = session('user');

        try {
            $response = $this->apiRequest()->get(
                $this->apiUrl() . '/api/search',
                ['q' => $query, 'role' => $user['role']]
            );

            return $this->proxyResponse($response);
        } catch (\Exception $e) {
            return response()->json(['data' => [], 'error' => 'Search failed'], 503);
        }
    }
}
```

Role-scoping happens at the Core API level. The BFF simply passes the user's role to the Core API's search endpoint.

---

## Step 8: Add to navigation (if applicable)

If the feature adds a new nav item, update the role's navigation hook:

```tsx
export function useStudentNav(activePage: ActivePage): NavItem[] {
    return [
        // existing items...
        {
            name: 'Search',
            href: '#' /* triggers modal, not route */,
            icon: Icons.search,
            active: false,
        },
    ];
}
```

---

## Step 9: TypeScript Verification

Run type checking to ensure all new code is type-safe:

```bash
cd Kolabri-client-app
npx tsc --noEmit
```

Fix any errors before proceeding.

---

## Step 10: Test Across Roles

UX features must work identically across all roles:

1. **Student**: Login, verify feature appears and works
2. **Lecturer**: Login, verify feature appears and works
3. **Admin**: Login, verify feature appears and works
4. **Cross-role**: Toggle dark mode as student, login as lecturer, verify theme persists
5. **Edge cases**: Empty state, loading state, error state for any data-dependent features

---

## Checklist

- [ ] Hook created in `resources/js/hooks/`
- [ ] Context created in `resources/js/contexts/` (if needed)
- [ ] Role-specific config created in `resources/js/config/` (if needed)
- [ ] UI component created in `resources/js/components/ui/`
- [ ] Feature integrated into `AppLayout`
- [ ] BFF endpoint created (if backend needed)
- [ ] Navigation updated (if new nav item)
- [ ] `localStorage` persistence implemented
- [ ] `tsc --noEmit` passes
- [ ] Tested across all three roles
- [ ] Accessibility: `aria-label` on interactive elements
- [ ] Dark mode support: `dark:` Tailwind classes