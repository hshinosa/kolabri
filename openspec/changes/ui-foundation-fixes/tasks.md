## 1. Foundation Setup

- [x] 1.1 Update tailwind.config.js with fontFamily.sans configuration
- [x] 1.2 Add semantic color tokens (brand.primary, brand.dark, brand.muted, brand.muted-dark) to Tailwind theme
- [x] 1.3 Add brand-tinted shadow utilities (shadow-brand-sm, shadow-brand, shadow-brand-lg) to Tailwind theme
- [x] 1.4 Verify Tailwind build compiles successfully with new configuration
- [x] 1.5 Create migration checklist from DESIGN-AUDIT.md findings

## 2. Auth Pages Migration

- [x] 2.1 Remove inline fontFamily declarations from login.tsx
- [x] 2.2 Replace hardcoded hex colors with semantic tokens in login.tsx
- [x] 2.3 Add focus-visible ring styles to all inputs in login.tsx
- [x] 2.4 Replace generic shadows with brand-tinted shadows in login.tsx
- [x] 2.5 Remove inline fontFamily declarations from register.tsx
- [x] 2.6 Replace hardcoded hex colors with semantic tokens in register.tsx
- [x] 2.7 Add focus-visible ring styles to all inputs in register.tsx
- [x] 2.8 Replace generic shadows with brand-tinted shadows in register.tsx
- [x] 2.9 Remove inline fontFamily declarations from forgot-password.tsx
- [x] 2.10 Replace hardcoded hex colors with semantic tokens in forgot-password.tsx
- [x] 2.11 Add focus-visible ring styles to all inputs in forgot-password.tsx
- [x] 2.12 Verify auth pages in light mode (visual QA)
- [x] 2.13 Verify auth pages in dark mode (visual QA)
- [x] 2.14 Test keyboard navigation and focus indicators on auth pages
- [x] 2.15 Run WCAG contrast checker on auth pages

## 3. Student Dashboard Migration

- [x] 3.1 Remove inline fontFamily declarations from student/dashboard.tsx
- [x] 3.2 Replace hardcoded hex colors with semantic tokens in student/dashboard.tsx
- [x] 3.3 Update text colors from #6B7280 to brand-muted-dark for WCAG compliance
- [x] 3.4 Replace generic shadows with brand-tinted shadows in student/dashboard.tsx
- [x] 3.5 Add focus-visible ring styles to quick action links
- [x] 3.6 Verify student dashboard in light mode (visual QA)
- [x] 3.7 Verify student dashboard in dark mode (visual QA)
- [x] 3.8 Test keyboard navigation on student dashboard

## 4. Student Courses Migration

- [x] 4.1 Remove inline fontFamily declarations from student/courses/index.tsx
- [x] 4.2 Replace hardcoded hex colors with semantic tokens in student/courses/index.tsx
- [x] 4.3 Add focus-visible ring styles to course cards and buttons
- [x] 4.4 Remove inline fontFamily declarations from student/courses/show.tsx
- [x] 4.5 Replace hardcoded hex colors with semantic tokens in student/courses/show.tsx
- [x] 4.6 Replace generic shadows with brand-tinted shadows in course components
- [x] 4.7 Verify student courses pages in light mode (visual QA)
- [x] 4.8 Verify student courses pages in dark mode (visual QA)

## 5. Lecturer Dashboard Migration

- [x] 5.1 Remove inline fontFamily declarations from lecturer/dashboard.tsx
- [x] 5.2 Replace hardcoded hex colors with semantic tokens in lecturer/dashboard.tsx
- [x] 5.3 Replace generic shadows with brand-tinted shadows in lecturer/dashboard.tsx
- [x] 5.4 Add focus-visible ring styles to navigation and action buttons
- [x] 5.5 Verify lecturer dashboard in light mode (visual QA)
- [x] 5.6 Verify lecturer dashboard in dark mode (visual QA)

## 6. Lecturer Analytics Migration

- [x] 6.1 Remove inline fontFamily declarations from lecturer/analytics/detail.tsx
- [x] 6.2 Replace hardcoded hex colors with semantic tokens in lecturer/analytics/detail.tsx
- [x] 6.3 Update headingStyle constant to use theme tokens instead of inline styles
- [x] 6.4 Replace generic shadows with brand-tinted shadows in analytics cards
- [x] 6.5 Add focus-visible ring styles to analytics controls (date picker, filters)
- [x] 6.6 Remove inline fontFamily declarations from lecturer/analytics/index.tsx
- [x] 6.7 Replace hardcoded hex colors with semantic tokens in lecturer/analytics/index.tsx
- [x] 6.8 Verify lecturer analytics pages in light mode (visual QA)
- [x] 6.9 Verify lecturer analytics pages in dark mode (visual QA)

## 7. Admin Dashboard Migration

- [x] 7.1 Remove inline fontFamily declarations from admin/dashboard.tsx
- [x] 7.2 Replace hardcoded hex colors with semantic tokens in admin/dashboard.tsx
- [x] 7.3 Replace generic shadows with brand-tinted shadows in admin/dashboard.tsx
- [x] 7.4 Add focus-visible ring styles to admin controls and buttons
- [x] 7.5 Verify admin dashboard in light mode (visual QA)
- [x] 7.6 Verify admin dashboard in dark mode (visual QA)
- [x] 7.7 Test keyboard navigation on admin dashboard

## 8. Chat Interfaces Migration

- [x] 8.1 Remove inline fontFamily declarations from student/chat/room.tsx
- [x] 8.2 Replace hardcoded hex colors with semantic tokens in student/chat/room.tsx
- [x] 8.3 Add focus-visible ring styles to message input and action buttons
- [x] 8.4 Remove inline fontFamily declarations from student/chat-spaces/index.tsx
- [x] 8.5 Replace hardcoded hex colors with semantic tokens in student/chat-spaces/index.tsx
- [x] 8.6 Remove inline fontFamily declarations from student/ai-chat/index.tsx
- [x] 8.7 Replace hardcoded hex colors with semantic tokens in student/ai-chat/index.tsx
- [x] 8.8 Replace generic shadows with brand-tinted shadows in chat components
- [x] 8.9 Verify chat interfaces in light mode (visual QA)
- [x] 8.10 Verify chat interfaces in dark mode (visual QA)

## 9. Shared Components Migration

- [x] 9.1 Update LiquidGlassCard component to use brand-tinted shadows
- [x] 9.2 Remove inline fontFamily from shared helper components
- [x] 9.3 Update form input components to use consistent focus-visible styles
- [x] 9.4 Update button components to use semantic color tokens
- [x] 9.5 Verify shared components work correctly across all pages

## 10. Verification and Cleanup

- [x] 10.1 Run grep search to verify no inline fontFamily declarations remain
- [x] 10.2 Run grep search to verify no hardcoded #88161c, #4A4A4A, #6B7280 remain
- [x] 10.3 Run grep search to verify no generic shadow-sm/lg/2xl without brand prefix
- [x] 10.4 Test keyboard navigation across all major pages
- [x] 10.5 Run automated WCAG contrast checker on all pages
- [x] 10.6 Take before/after screenshots for documentation
- [x] 10.7 Update component documentation with new token usage patterns
- [x] 10.8 Create PR with comprehensive description and screenshots

## 11. Deployment

- [x] 11.1 Deploy to staging environment
- [x] 11.2 Perform full regression testing on staging
- [x] 11.3 Get stakeholder approval on visual changes
- [x] 11.4 Deploy to production
- [x] 11.5 Monitor for any visual regressions or user feedback
