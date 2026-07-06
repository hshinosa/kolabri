## Context

Kolabri is a Next.js app using Tailwind CSS with existing responsive breakpoints (sm/md/lg/xl/2xl) across 20+ files. A mobile sidebar drawer already exists in `app-layout.tsx`. The viewport meta tag is present but lacks `viewport-fit=cover`. Touch handling is sparse: only 3 `touch-manipulation` instances across the codebase, no systematic 44px enforcement, no safe-area support, no swipe gestures, and no mobile-specific chat optimizations.

## Goals / Non-Goals

**Goals:**
- All interactive elements meet 44x44px minimum touch target
- iOS notched devices render correctly with safe-area insets
- Consistent tap/press feedback across the app
- Sidebar opens/closes via swipe gestures on mobile
- Chat input stays usable when mobile keyboard is visible

**Non-Goals:**
- Desktop layout changes (existing breakpoints are sufficient)
- PWA install prompt or offline support
- Native mobile app wrapper (Capacitor, etc.)
- Redesigning the sidebar component itself
- Supporting landscape-specific layouts beyond what Tailwind breakpoints already handle

## Decisions

### 1. Touch target enforcement via CSS utilities + audit

**Decision**: Add `min-w-11 min-h-11` (44px) as minimum size on interactive elements via a Tailwind utility class `.touch-target`, plus a global `touch-manipulation` rule. Audit existing interactive elements and patch undersized ones.

**Alternatives considered**:
- *JS-based enforcement*: Too heavy, CSS is sufficient for sizing
- *Tailwind plugin generating variants*: Overkill for a one-time audit; utility class is simpler

### 2. Safe-area via CSS env() + Tailwind theme extension

**Decision**: Add `viewport-fit=cover` to the viewport meta tag. Create Tailwind theme spacing tokens referencing `env(safe-area-inset-*)` via CSS custom properties. Apply these tokens to layout containers and fixed elements.

**Alternatives considered**:
- *Inline styles with env()*: Harder to maintain, no Tailwind integration
- *JavaScript window.safeAreaInsets*: Unnecessary when CSS env() is well supported

### 3. Custom swipe hook over library

**Decision**: Implement a `useSwipe` hook using pointer events (pointerdown/pointermove/pointerup) rather than adding a dependency like `use-gesture`.

**Rationale**: The gesture is simple (horizontal swipe with threshold). A custom hook avoids bundle size increase and gives full control over the 50px threshold and animation behavior. Pointer events work across touch and mouse.

**Alternatives considered**:
- *use-gesture library*: Adds ~8KB, overkill for one gesture
- *Touch events only*: Pointer events cover touch + mouse + pen

### 4. Mobile chat input via visual viewport API

**Decision**: Use `window.visualViewport` API to detect keyboard state and adjust the fixed bottom input position. Combine with safe-area insets and `overscroll-behavior: contain` on the chat scroll area.

**Alternatives considered**:
- *CSS `keyboard-inset-*`*: Limited browser support
- *ResizeObserver on window.innerHeight*: VisualViewport is more reliable and accounts for pinch-zoom

### 5. Global tap highlight via CSS base styles

**Decision**: Set `webkit-tap-highlight-color: transparent` globally and replace with Tailwind `active:` variants for press feedback. Add `user-select: none` on interactive non-text elements and `touch-action: manipulation` globally.

**Rationale**: Transparent tap highlight + explicit active states gives consistent cross-browser behavior. `touch-action: manipulation` prevents 300ms delay without needing FastClick.

## Risks / Trade-offs

- **Touch target audit may miss dynamic elements** → Mitigation: combine CSS audit with manual testing on small screens (320px width)
- **Safe-area env() fallback is 0** → Mitigation: custom properties default to 0, which is correct for non-notched devices
- **Custom swipe hook edge cases (scroll vs swipe conflict)** → Mitigation: only activate horizontal swipe when deltaX > deltaY and deltaX exceeds 10px before capturing
- **VisualViewport API not available in older browsers** → Mitigation: feature detect and fall back to `window.innerHeight` resize
- **Global touch-manipulation may break pinch-zoom on maps/images** → Mitigation: override `touch-action` locally on elements that need pinch-zoom
