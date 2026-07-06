## 1. Touch Target Audit & Fix

- [ ] 1.1 Add `.touch-target` utility class (min-w-11 min-h-11) and global `touch-action: manipulation` to base CSS
- [ ] 1.2 Add `active:scale-95` (or equivalent active state) to all button/link base styles
- [ ] 1.3 Audit all interactive elements for <44px touch targets and apply `.touch-target` class
- [ ] 1.4 Add `user-select: none` to interactive non-text elements (buttons, icons, cards)

## 2. Safe Area Support

- [ ] 2.1 Update viewport meta tag to include `viewport-fit=cover`
- [ ] 2.2 Define CSS custom properties (`--safe-top`, `--safe-right`, `--safe-bottom`, `--safe-left`) mapping to `env(safe-area-inset-*)` with 0 fallback
- [ ] 2.3 Add Tailwind theme extension for safe-area spacing tokens
- [ ] 2.4 Apply safe-area padding to fixed header, sidebar, bottom bar, and modals

## 3. Tap Highlight & Touch Optimization

- [ ] 3.1 Set `webkit-tap-highlight-color: transparent` in global CSS
- [ ] 3.2 Verify `touch-action: manipulation` is applied globally (from task 1.1)
- [ ] 3.3 Ensure all interactive elements have visible `active:` state feedback (from task 1.2)
- [ ] 3.4 Test on iOS Safari that no default blue/gray highlight appears on tap

## 4. Swipe Gesture Sidebar

- [ ] 4.1 Create `useSwipe` hook using pointer events with 50px threshold and horizontal/vertical delta check
- [ ] 4.2 Integrate `useSwipe` into `app-layout.tsx` sidebar: swipe right from left edge to open
- [ ] 4.3 Add swipe left on sidebar overlay to close
- [ ] 4.4 Test swipe does not conflict with vertical scroll (deltaX > deltaY check)

## 5. Mobile Chat UX Polish

- [ ] 5.1 Make chat input fixed to bottom of viewport on mobile viewports
- [ ] 5.2 Apply `env(safe-area-inset-bottom)` padding to chat input bar
- [ ] 5.3 Implement keyboard detection via Visual Viewport API with `window.innerHeight` fallback
- [ ] 5.4 Add `overscroll-behavior: contain` to chat message scroll area
- [ ] 5.5 Test chat input visibility with keyboard open on iOS and Android
