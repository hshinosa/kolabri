# Handoff — purge-privacy-consent-residual

Copy-paste prompt for another agent:

---

```text
# Task: Apply OpenSpec change `purge-privacy-consent-residual`

## Repo
/Users/hshino/Kuliah/ProjectTA

## Read first (in order)
1. openspec/changes/purge-privacy-consent-residual/proposal.md
2. openspec/changes/purge-privacy-consent-residual/design.md
3. openspec/changes/purge-privacy-consent-residual/specs/privacy-consent-free-runtime/spec.md
4. openspec/changes/purge-privacy-consent-residual/tasks.md

## Context (do not skip)
- SRS/SDD v2 already claim NO privacy/consent product stack. Do NOT edit SRS/SDD unless you find a false claim.
- Many privacy routes/controllers already deleted; Prisma migration `20260720150000_remove_privacy_consent_stack` already drops consent_records + user privacy columns.
- Your job is **residual cleanup + verify**, not recreate nfr-sec-02 privacy features.
- KEEP: Google OAuth `prompt=consent`, admin AccountDeletionService hard-delete.
- REMOVE residual product: RetentionPolicy* product API/UI, ExportJob if privacy-only, Wayfinder privacy proxy exports, docs mentioning PrivacyTab.
- CAREFUL: lecturer course export (FR-028) is NOT the same as user data-export portability.

## Working rules
- Follow tasks.md checkboxes; mark [x] only after verified.
- Re-run inventory grep before deleting (D1).
- No drive-by lint of unrelated files.
- Prefer minimal diffs; separate commits per submodule if dirty.
- Do not push unless asked.
- Do not revive openspec changes nfr-sec-02-data-privacy / remove-privacy-and-consent-stack / hide-privacy-surfaces-for-presentation.

## Acceptance
- tasks.md §5.1 forbidden grep clean (except documented KEEP exceptions)
- prisma validate + generate OK
- Client settings: no Privacy / Retention product tabs
- AI chat works without consent flag
- Verification notes filled at bottom of tasks.md

## Deliverable back to user
- List of removed files
- What was kept and why
- Commands run + results
- Any residual knowingly left (with reason)
```

---

## Quick path list (starting inventory 2026-07-20)

### Likely REMOVE
- `Kolabri-core-api/src/routes/retention-policy.routes.ts`
- `Kolabri-core-api/src/controllers/retention-policy.controller.ts`
- `Kolabri-core-api/src/services/retention-policy.service.ts`
- `Kolabri-core-api/src/jobs/retention-cleanup.ts` (+ registration)
- `Kolabri-core-api/prisma/seed-retention.ts`
- Prisma models `DataRetentionPolicy`, maybe `ExportJob` (after audit)
- `Kolabri-client-app/resources/js/pages/settings/components/RetentionPolicyTab.tsx` (+ tab wiring)
- Privacy methods in CoreApi proxy PHP + regenerate `resources/js/actions/.../CoreApiProxyController.ts`
- Client `docs/TIMEOUTS.md` PrivacyTab reference

### KEEP
- `Kolabri-core-api/src/services/account-deletion.service.ts` (admin)
- `Kolabri-core-api/src/controllers/admin-user.controller.ts` hard-delete use
- `Kolabri-client-app/app/Http/Controllers/GoogleAuthController.php` OAuth consent prompt
- Historical migrations that CREATED consent (do not delete folder); drop already in `20260720150000_remove_privacy_consent_stack`

### ALREADY GONE (verify still gone)
- privacy*.ts / consent*.ts routes controllers services
- PrivacyTab.tsx
- ConsentRecord in schema
- socket aiInteractionConsent gate

## Status of this OpenSpec package
- **Ready for apply** by delegated agent
- Tasks intentionally all `[ ]` for honest re-implementation
- Created/refreshed: 2026-07-20
