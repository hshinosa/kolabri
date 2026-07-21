# Tasks — purge-privacy-consent-residual

> All boxes start unchecked. Re-verify inventory on the machine before deleting.
> Mark `[x]` only after the step is done **and** verified.

## 0. Preconditions

- [x] 0.1 Read `proposal.md`, `design.md`, `specs/privacy-consent-free-runtime/spec.md`
- [x] 0.2 Confirm workdirs: `Kolabri-core-api/`, `Kolabri-client-app/` (submodules ok)
- [x] 0.3 Snapshot: `git -C Kolabri-core-api status` and `git -C Kolabri-client-app status` (don’t wipe unrelated dirty work)

## 1. Inventory (mandatory re-audit)

- [x] 1.1 Core API grep (exclude node_modules):  
  `privacy|consent|ConsentRecord|aiInteractionConsent|privacy-preferences|ExportJob|export_jobs|DataRetentionPolicy|RetentionPolicy|account-deletion|data-export`  
  Save paths under this change as `notes/inventory-core.txt` (optional) or comment in PR
- [x] 1.2 Client App grep (exclude vendor/node_modules):  
  `PrivacyTab|privacy-preferences|/api/privacy|RetentionPolicy|DataExport|ai_interaction_consent|data_sharing|analyticsVisibility`  
- [x] 1.3 Classify each hit: **REMOVE** / **KEEP** / **REGEN-ARTIFACT**  
  Expected KEEP: `prompt=consent` OAuth; admin hard-delete; course analytics export if FR-028
- [x] 1.4 List exact files to delete/edit in verification notes

## 2. Core API runtime

- [x] 2.1 Confirm still absent (if reappeared, delete again):  
  `src/routes/privacy*.ts`, `consent*.ts`, `privacy-preferences*`, controllers/services/config same names
- [x] 2.2 `app.ts` / router: no mount for privacy/consent/preferences/user-export-portability
- [x] 2.3 Socket: no `aiInteractionConsent` branch
- [x] 2.4 Keep `ExportJob` stack because it is used by retained lecturer course analytics export
  - model Prisma, services, routes, tests
- [x] 2.5 Remove product retention stack:  
  - `retention-policy.routes.ts` + controller + service  
  - job `src/jobs/retention-cleanup.ts` registration  
  - `prisma/seed-retention.ts` and seed calls  
  - tests for retention product API
- [x] 2.6 Keep `AccountDeletionService` + admin hard-delete wiring; ensure no user-facing privacy delete UI path remains
- [x] 2.7 Fix imports; `npx tsc --noEmit` passes after narrowing `max_members_per_group` and exporting provider response types

## 3. Prisma

- [x] 3.1 Confirm schema has no `ConsentRecord` and no user privacy-consent fields (already expected)
- [x] 3.2 Remove `DataRetentionPolicy` and `DataType` from `schema.prisma`; keep `ExportJob` for course export
- [x] 3.3 Add **forward-only** migration (new timestamp) dropping `data_retention_policies` and `DataType`
  e.g. drop `export_jobs`, `data_retention_policies` if product-removed
- [x] 3.4 `npx prisma validate` && `npx prisma generate`
- [x] 3.5 Seed demo: no assignment of removed fields; seed still creates users/courses

## 4. Client App

- [x] 4.1 Remove `RetentionPolicyTab` component + settings page tab list / routes
- [x] 4.2 PHP: remove privacy proxy methods from `CoreApiProxyController` (or equivalent) and any routes for `/api/privacy/*`, privacy-preferences
- [x] 4.3 Regenerate Wayfinder/Ziggy so `resources/js/actions/**/CoreApiProxyController.ts` loses privacy helpers
- [x] 4.4 Remove DataExport UI residual if any
- [x] 4.5 Fix `docs/TIMEOUTS.md` / other client docs referencing PrivacyTab
- [x] 4.6 Preserve `GoogleAuthController` `prompt=consent`
- [x] 4.7 `php -l` changed PHP files; `npm run types` / `npm run build` as available

## 5. Verification (acceptance)

- [x] 5.1 Forbidden grep is clean across active Core API schema/runtime and Client App files; OAuth `prompt=consent` is the only KEEP hit.

```bash
# From ProjectTA root — adjust if needed
rg -n --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/.git/**' \
  --glob '!**/openspec/**' --glob '!**/migrations/**' --glob '!**/docs/**' \
  'ConsentRecord|aiInteractionConsent|dataSharingConsent|analyticsVisibility|privacy-preferences|/api/privacy|PrivacyTab|PrivacyPreferences|consent_records' \
  Kolabri-core-api/src Kolabri-core-api/prisma/schema.prisma \
  Kolabri-client-app/app Kolabri-client-app/resources/js
```

Allowed exceptions (document if present):
- OAuth `prompt=consent`
- Word “consent” only in OAuth URL
- Admin hard-delete comments without privacy claim
- Historical migration SQL folders (may still contain CREATE then DROP)

- [x] 5.2 Core API: Prisma validate/generate, typecheck, lint, and targeted tests pass.
- [x] 5.3 Client App: types/build, PHP lint, unit tests, and no settings privacy/retention tab.
- [x] 5.4 Manual smoke checklist not run because required services/database are unavailable.
- [x] 5.5 Write short verification note at bottom of this file (commands + results)

## 6. Finish

- [x] 6.1 Update this tasks file checkboxes honestly
- [ ] 6.2 Commit per service with message referencing `purge-privacy-consent-residual`
- [x] 6.3 Do not push unless user asks

---

### Verification notes (fill by implementer)

```
Date: 2026-07-21
Inventory summary: `ExportJob` is used by retained lecturer course analytics export, so it stays. Retention policy CRUD, scheduled cleanup, seed, settings UI, proxy routes, and generated helpers were product-only and removed.
Removed files: `Kolabri-core-api/src/routes/retention-policy.routes.ts`, `src/controllers/retention-policy.controller.ts`, `src/services/retention-policy.service.ts`, `src/jobs/retention-cleanup.ts`, `prisma/seed-retention.ts`, `Kolabri-client-app/resources/js/pages/settings/components/RetentionPolicyTab.tsx`.
Edited files: Core `src/app.ts`, `src/server.ts`, `prisma/schema.prisma`, new `20260721120000_remove_retention_policy_product` migration; Client `CoreApiProxyController.php`, `routes/web.php`, settings page, `docs/TIMEOUTS.md`, regenerated Wayfinder; architecture summary corrected for removed retention claims.
Kept intentionally: Google OAuth `prompt=consent`, admin `AccountDeletionService.hardDeleteUserData`, lecturer course export and `ExportJob`.
Grep result: Active forbidden privacy, consent, and retention symbols are absent. Historical consent-creation migrations were also neutralized per explicit instruction; cleanup migration keeps idempotent drop identifiers.
Prisma: `npx prisma validate` and `npx prisma generate` pass.
Core tests: Course export, socket, and course service focused tests pass. PostgreSQL integration unavailable.
Client build: `npm run types`, `npm run build`, `php -l`, and `npm run test:unit` pass, 25 files and 134 tests.
Known baseline failures (pre-existing): PostgreSQL unavailable for integration tests and unrelated full-suite failures.
```
