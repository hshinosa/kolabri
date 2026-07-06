## Context

**Current State:**
- 61+ page components across admin, lecturer, student, and auth sections
- Inline font declarations: `fontFamily: "'Plus Jakarta Sans', sans-serif"` scattered throughout
- Hardcoded hex colors: `#88161c` (brand red), `#4A4A4A` (dark gray), `#6B7280` (medium gray) used directly in components
- No centralized theme system - changes require editing dozens of files
- Missing focus states on form inputs - fails WCAG 2.1 Level AA
- Generic Tailwind shadows (`shadow-sm`, `shadow-lg`) without brand tinting
- Low contrast text (`#6B7280` on light backgrounds) - contrast ratio ~3.8:1, below WCAG AA requirement of 4.5:1

**Tech Stack:**
- Laravel 11 + React 18 + Inertia.js
- Tailwind CSS 3.x
- TypeScript
- Framer Motion for animations

**Constraints:**
- Cannot break existing functionality
- Must maintain dark mode support
- Changes should be incremental (can be deployed in stages)
- No new dependencies allowed

## Goals / Non-Goals

**Goals:**
- Centralize all design tokens (fonts, colors, shadows) in Tailwind config
- Achieve WCAG 2.1 Level AA compliance for all text and interactive elements
- Enable theme changes by editing single config file instead of 61+ components
- Establish consistent focus indicator system for keyboard navigation
- Improve visual quality with brand-tinted shadows

**Non-Goals:**
- Complete design system documentation (future work)
- Component library refactor (out of scope)
- Dark mode improvements beyond maintaining current functionality
- Advanced animations or micro-interactions (separate change)
- Layout changes or bento grid implementation (separate change)

## Decisions

### Decision 1: Tailwind Config Extension vs CSS Variables

**Chosen:** Extend Tailwind config with semantic tokens

**Rationale:**
- Tailwind's JIT compiler provides better tree-shaking
- Type-safe with TypeScript + Tailwind IntelliSense
- No runtime CSS variable overhead
- Easier migration path - can use both old and new values during transition

**Alternatives Considered:**
- CSS Variables: More flexible for runtime theming, but adds complexity and runtime cost
- Styled Components: Would require major refactor, against "no new dependencies" constraint

**Implementation:**
```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['Plus Jakarta Sans', 'system-ui', 'sans-serif'],
      },
      colors: {
        brand: {
          primary: '#88161c',
          dark: '#4A4A4A',
          muted: '#6B7280',
          'muted-dark': '#374151', // WCAG AA compliant
        }
      },
      boxShadow: {
        'brand-sm': '0 1px 2px 0 rgba(136, 22, 28, 0.05)',
        'brand': '0 4px 6px -1px rgba(136, 22, 28, 0.1)',
        'brand-lg': '0 10px 15px -3px rgba(136, 22, 28, 0.1)',
      }
    }
  }
}
```

### Decision 2: Migration Strategy - Big Bang vs Incremental

**Chosen:** Incremental migration with coexistence period

**Rationale:**
- Lower risk - can test each section independently
- Allows rollback of individual changes
- Team can review changes in smaller PRs
- Doesn't block other development work

**Migration Order:**
1. Add new tokens to Tailwind config (non-breaking)
2. Migrate auth pages (smallest surface area, high visibility)
3. Migrate student dashboard (most used by end users)
4. Migrate lecturer/admin dashboards
5. Migrate chat interfaces
6. Remove old inline styles after verification

**Alternatives Considered:**
- Big Bang: Migrate everything at once - too risky, hard to review
- Feature Flags: Overkill for styling changes, adds complexity

### Decision 3: Focus State Pattern

**Chosen:** Tailwind's `focus-visible` with ring pattern

**Rationale:**
- `focus-visible` only shows on keyboard navigation (not mouse clicks)
- Ring pattern is modern, accessible, and consistent with Tailwind conventions
- 2px ring with offset provides clear visual indicator
- Brand color ring maintains visual consistency

**Implementation Pattern:**
```tsx
<input className="
  focus-visible:outline-none
  focus-visible:ring-2
  focus-visible:ring-brand-primary
  focus-visible:ring-offset-2
" />
```

**Alternatives Considered:**
- Outline: Less visually appealing, harder to customize
- Border: Can conflict with existing border styles
- Box Shadow: Works but less semantic than ring

### Decision 4: Contrast Fix Approach

**Chosen:** Replace `#6B7280` with `#374151` for body text

**Rationale:**
- `#374151` (gray-700) provides 7.0:1 contrast on white (exceeds WCAG AA)
- Maintains visual hierarchy - still clearly secondary to `#4A4A4A` headings
- Single token replacement - easy to implement and verify
- No need for complex color calculations

**Verification:**
- Use WebAIM Contrast Checker during implementation
- Automated testing with axe-core or similar

## Risks / Trade-offs

### Risk 1: Visual Regression
**Risk:** Changes might subtly break layouts or cause unexpected visual issues
**Mitigation:**
- Take screenshots before/after for each page
- Manual QA on all major pages
- Deploy to staging first
- Incremental rollout allows quick rollback

### Risk 2: Missed Inline Styles
**Risk:** Some hardcoded values might be missed during migration
**Mitigation:**
- Use grep/ast-grep to find all instances: `grep -r "fontFamily.*Plus Jakarta" resources/js/`
- Create checklist from audit findings
- Code review focuses on completeness

### Risk 3: Dark Mode Breakage
**Risk:** New color tokens might not work well in dark mode
**Mitigation:**
- Test dark mode explicitly for each migrated section
- Use Tailwind's `dark:` variants for dark mode overrides
- Keep existing dark mode logic intact

### Risk 4: Performance Impact
**Risk:** Tailwind config changes might increase bundle size
**Mitigation:**
- Tailwind's JIT compiler only includes used classes
- Monitor bundle size before/after
- Remove old unused styles after migration

### Trade-off: Coexistence Period Complexity
**Trade-off:** During migration, codebase will have both old and new patterns
**Acceptance:** Temporary complexity is acceptable for lower risk. Document clearly which sections are migrated.

## Migration Plan

### Phase 1: Foundation (Week 1)
1. Update `tailwind.config.js` with new tokens
2. Verify Tailwind build works
3. Create migration checklist from audit

### Phase 2: Auth Pages (Week 1)
1. Migrate login.tsx, register.tsx, forgot-password.tsx
2. Add focus states to all inputs
3. Visual QA + accessibility testing
4. Deploy to staging

### Phase 3: Student Section (Week 2)
1. Migrate student dashboard
2. Migrate student courses pages
3. Visual QA + accessibility testing
4. Deploy to staging

### Phase 4: Lecturer/Admin (Week 2)
1. Migrate lecturer dashboard + analytics
2. Migrate admin dashboard
3. Visual QA + accessibility testing
4. Deploy to staging

### Phase 5: Chat Interfaces (Week 3)
1. Migrate chat room, chat spaces, AI chat
2. Visual QA + accessibility testing
3. Deploy to staging

### Phase 6: Cleanup (Week 3)
1. Remove all old inline styles
2. Verify no hardcoded values remain
3. Update documentation
4. Deploy to production

### Rollback Strategy
- Each phase is independently deployable
- Git revert of specific commits if issues found
- Staging environment allows testing before production
- Can pause migration at any phase boundary

## Open Questions

1. **Should we add CSS custom properties for runtime theming in the future?**
   - Decision: Defer to future change. Current approach is sufficient for static theming.

2. **Do we need to update component library documentation?**
   - Decision: Yes, but as separate task after implementation. Document new token usage patterns.

3. **Should we automate contrast checking in CI?**
   - Decision: Nice to have, but not blocking. Manual verification sufficient for this change.
