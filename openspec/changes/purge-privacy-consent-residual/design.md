## Context

Product docs (SRS/SDD v2) removed privacy/consent claims. Runtime already dropped:

- Express privacy/consent/privacy-preferences routes and controllers (files gone)
- Prisma `ConsentRecord` and user columns `analytics_visibility`, `ai_interaction_consent`, `data_sharing_consent`
- Migration `20260720150000_remove_privacy_consent_stack`
- Client `PrivacyTab` (settings components now: Profile, Appearance, Notification, Security, **RetentionPolicy**)

Remaining surfaces look like “privacy adjacent” product leftovers (export jobs, retention policies, Wayfinder dead privacy methods) and must be cleaned without damaging admin ops or OAuth.

## Goals / Non-Goals

**Goals**

1. Zero product API/UI for privacy policy, privacy preferences, consent grants, user personal-data export portability, retention-policy product admin.
2. Regenerated Client App proxies without privacy paths.
3. Document and keep admin hard-delete.
4. Acceptance grep green for forbidden active symbols (list in tasks).

**Non-Goals**

- No legal compliance framework.
- No SRS/SDD edits unless a false claim appears (should not).
- No deletion of lecturer **course analytics** export if it maps to FR-028.
- No full monorepo lint fix.

## Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | Re-inventory before delete | Prior task checkboxes were optimistic; code may differ on agent machine/submodules |
| D2 | Retention product surface OUT | Not in UC-inti; tab + CRUD API claim “policy” product |
| D3 | ExportJob OUT unless proven FR-028 course export | User export portability = out of scope; course analytics export may stay under different module |
| D4 | Admin `AccountDeletionService` KEEP | Operational hard-delete for admin, not privacy rights UX |
| D5 | OAuth `prompt=consent` KEEP | Provider OAuth semantics |
| D6 | Do not rewrite old Prisma migrations that created consent | Only forward cleanup; history remains for applied DBs |
| D7 | Regenerate Wayfinder after PHP proxy cleanup | Generated TS under `resources/js/actions` must not be hand-edited only |
| D8 | Minimal commits per service | Core API and Client App as separate commits if submodules |

## Architecture impact

```
Browser
  └─ Client App settings  [NO PrivacyTab] [NO RetentionPolicyTab after change]
       └─ HTTP proxy      [NO /api/privacy/*] [NO privacy-preferences]
            └─ Core API
                 ├─ Auth / domain / Socket  [NO consent gate]  KEEP
                 ├─ Admin hard-delete       KEEP
                 ├─ Retention CRUD/job      REMOVE product
                 └─ ExportJob user portability REMOVE if present
```

## Risks

| Risk | Mitigation |
|------|------------|
| Dropping `export_jobs` breaks something unexpected | Grep all `ExportJob` / `exportJob` first; if only dead, remove |
| Retention job scheduled in production | Disable job registration when removing service |
| Wayfinder regen misses routes | Run project’s documented wayfinder/ziggy command after PHP change |
| Submodule dirty | Work inside `Kolabri-core-api` / `Kolabri-client-app` paths; don’t force parent commit |

## Migration plan

1. Inventory (tasks §1)
2. Core API residual delete (tasks §2)
3. Prisma optional drop export/retention tables (tasks §3) — forward-only
4. Client App residual delete + Wayfinder regen (tasks §4)
5. Verification grep + targeted tests (tasks §5)

Rollback: restore files from git; reverse migration only if table drops applied (write reverse carefully or restore DB snapshot).

## Open questions for implementer (resolve in inventory, do not block start)

1. Is `course-export.routes.ts` lecturer analytics (FR-028) or user privacy export?  
   → If course metrics JSON/CSV for dosen: **keep**. If user data dump: **remove**.
2. Is `RetentionPolicyTab` linked from settings layout only, or also admin menu?
3. Is retention-cleanup registered in process managers (`app.ts` cron, bull, node-cron)?

## References

- SRS: `SRS-SDD/SRS - Kolabri Platform Diskusi Kolaboratif v2.md` (no privacy claims)
- SDD: `SRS-SDD/SDD - Kolabri Platform Diskusi Kolaboratif v2.md`
- Existing drop migration: `Kolabri-core-api/prisma/migrations/20260720150000_remove_privacy_consent_stack/migration.sql`
- Related change (dead product UI, not privacy): `openspec/changes/remove-out-of-scope-product-surfaces/`
