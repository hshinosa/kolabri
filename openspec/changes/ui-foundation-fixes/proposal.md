## Why

Design audit revealed critical foundation issues affecting maintainability, accessibility, and brand consistency across all pages. Hardcoded fonts and colors are scattered throughout 61+ components, making theme changes impossible. Missing focus states violate WCAG accessibility standards. Generic shadows and low-contrast text create a generic, unprofessional appearance. These foundation issues must be fixed before any advanced design improvements.

## What Changes

- **Move font declarations to Tailwind config** - Remove all inline `fontFamily: "'Plus Jakarta Sans', sans-serif"` declarations, centralize in theme
- **Define semantic color system** - Replace hardcoded `#88161c`, `#4A4A4A`, `#6B7280` with semantic tokens in Tailwind config
- **Add focus states to all interactive elements** - Implement `focus-visible:ring-2` pattern for keyboard navigation and WCAG compliance
- **Fix text contrast issues** - Darken gray text from `#6B7280` to `#374151` for WCAG AA compliance
- **Implement tinted shadow system** - Replace generic `shadow-sm/lg/2xl` with brand-tinted shadows

## Capabilities

### New Capabilities
- `design-system-foundation`: Centralized theme configuration for fonts, colors, and shadows in Tailwind config
- `accessibility-focus-states`: Consistent focus indicator system for keyboard navigation across all interactive elements

### Modified Capabilities
- `ui-components`: All existing UI components will use theme tokens instead of hardcoded values
- `form-inputs`: Form inputs will have proper focus states and contrast ratios

## Impact

**Affected Files:**
- `Kolabri-client-app/tailwind.config.js` - Add fonts, colors, shadows to theme
- All page components (61 files in `resources/js/pages/`) - Remove inline styles
- All form components - Add focus states
- `LiquidGlassCard` and shared components - Update to use theme tokens

**Breaking Changes:** None - purely visual improvements, no API or behavior changes

**Dependencies:** None - self-contained changes to frontend styling

**Testing Required:**
- Visual regression testing across all pages
- Keyboard navigation testing for focus states
- Contrast ratio verification with WCAG checker
- Cross-browser testing (Chrome, Firefox, Safari)
