## Why

Kolabri's mobile experience has gaps that hurt usability on phones and tablets: touch targets are too small for reliable tapping, iOS devices with notches clip content, tap highlights are inconsistent, the sidebar lacks swipe gestures, and the chat input doesn't handle mobile keyboards or safe areas. These issues violate the NFR mobile responsiveness requirement and create a subpar experience for mobile users, who represent a growing share of Kolabri's audience.

## What Changes

- Enforce minimum 44x44px touch targets across all interactive elements with `touch-manipulation` globally and `active:scale-95` press feedback
- Add CSS safe-area-inset support (`env(safe-area-inset-*)`) and `viewport-fit=cover` for iOS notch/home indicator devices
- Standardize tap highlight behavior with `webkit-tap-highlight-color`, `touch-action`, and `user-select` overrides
- Implement swipe gestures on the mobile sidebar (swipe right to open, swipe left to close, 50px threshold)
- Polish mobile chat UX with fixed bottom input, safe-area aware padding, keyboard handling, and overscroll prevention

## Capabilities

### New Capabilities
- `touch-targets`: Minimum 44x44px hit areas, global touch-manipulation, active press feedback
- `safe-area-support`: CSS env() safe-area insets and viewport-fit=cover for notched devices
- `tap-highlight-optimization`: Webkit tap highlight color, touch-action, user-select standardization
- `swipe-sidebar`: Swipe right to open / left to close sidebar with 50px threshold
- `mobile-chat-ux`: Fixed bottom input, safe-area padding, keyboard handling, overscroll prevention

### Modified Capabilities
<!-- No existing specs require requirement-level changes -->

## Impact

- **CSS/Global styles**: New utility classes and base styles for touch targets, safe areas, tap highlights
- **app-layout.tsx**: Sidebar swipe gesture integration, safe-area padding
- **Chat components**: Bottom input bar refactored for mobile keyboard and safe area
- **viewport meta tag**: Updated to include `viewport-fit=cover`
- **tailwind.config.ts**: Possible new theme extensions for safe-area spacing
- **Dependencies**: May need a lightweight gesture library (e.g., use-gesture) or custom hook implementation
