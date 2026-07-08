## 1. Audit and Spec

- [ ] 1.1 Document lecturer, student, and admin copy findings in a consolidated audit report
- [ ] 1.2 Create scoped OpenSpec artifacts for cross-role UI copy clarity
- [ ] 1.3 Review proposal, design, and spec scope against the intended frontend-only change

## 2. Lecturer Copy Refinement

- [ ] 2.1 Update high-visibility lecturer navigation and page copy to consistent Indonesian terminology

## 3. Student Copy Refinement

- [ ] 3.1 Update student navigation and primary workflow pages to use consistent Indonesian copy
- [ ] 3.2 Normalize student collaboration terminology around `kelompok`
- [ ] 3.3 Localize student pre-read and assistant wording on major surfaces

## 4. Admin Copy Refinement

- [ ] 4.1 Update admin navigation and dashboard headings to Indonesian management language
- [ ] 4.2 Update admin user-management copy for filters, actions, and modals
- [ ] 4.3 Update admin class-management and AI-settings copy for headings, actions, and empty states

## 5. Verification

- [ ] 5.1 Run `npm run test:unit -- resources/js/components/navigation/NotificationsBell.test.tsx` only if impacted by shared changes
- [ ] 5.2 Run `npm run types` in `Kolabri-client-app`
- [ ] 5.3 Re-read edited files to verify key copy replacements landed as intended