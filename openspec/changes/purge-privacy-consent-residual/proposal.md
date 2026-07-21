## Why

SRS/SDD Kolabri **v2** (format kampus, scope 2026-07-20) **tidak mengklaim** privacy policy, privacy preferences, consent records, AI-interaction consent gate, user data-export portability, atau retention-policy UI sebagai produk rilis inti.

Sebagian besar runtime privacy/consent **sudah dihapus** di codebase (routes/controllers `privacy*` / `consent*`, model `ConsentRecord`, field `ai_interaction_consent` / `data_sharing_consent` / `analytics_visibility`, socket consent gate). Migration forward-only `20260720150000_remove_privacy_consent_stack` sudah ada.

**Sisa residual** masih ada dan membingungkan agent/docs/UI:

| Area | Residual (inventory 2026-07-20) | Tindakan |
|------|----------------------------------|----------|
| Core API | `ExportJob` model + `export_jobs` migration historis | Hapus bila tidak ada consumer non-privacy; jangan buka lagi user export portability |
| Core API | `DataRetentionPolicy` + routes/controllers/services/job `retention-*` + `seed-retention.ts` | Hapus product surface retention admin; atau hard-disable route + UI |
| Core API | `AccountDeletionService` dipakai `admin-user.controller` hard-delete | **PERTAHANKAN** admin operational hard-delete (bukan user privacy rights) |
| Client App | `RetentionPolicyTab.tsx` di settings | Hapus tab + wiring settings |
| Client App | Wayfinder generated `CoreApiProxyController.ts` masih memuat `privacyPolicy`, `privacyPreferencesGet/Put`, path `/api/privacy/*`, `/api/user/privacy-preferences` | Hapus proxy PHP methods + **regenerate** Wayfinder; jangan edit generated file alone |
| Client App | `docs/TIMEOUTS.md` sebut `PrivacyTab.tsx` | Bersihkan referensi |
| OAuth | `GoogleAuthController` `prompt=consent` | **JANGAN SENTUH** (OAuth provider, bukan privacy stack produk) |
| Prisma history | Migrations `20260610113940_add_consent_records`, `...privacy_preferences` | Biarkan history; cleanup migration sudah drop. Jangan rewrite history ke DB production without explicit approve |
| Openspec lama | `nfr-sec-02-data-privacy`, `remove-privacy-and-consent-stack`, `hide-privacy-surfaces-*` | Sudah dihapus dari `openspec/changes/` — jangan buat ulang |

Change ini memastikan residual **tidak menyisakan surface privacy-claim** dan verifikasi grep/tests hijau.

## What Changes

### Core API (`Kolabri-core-api`)
1. Audit semua consumer `ExportJob` / data-export routes. Jika hanya privacy portability → hapus model, service, routes, tests; migration forward-only drop `export_jobs` **opsional** (boleh biarkan tabel orphan + hapus model Prisma saja jika drop table risky — pilih minimal risk: remove model + routes first, drop table di migration baru jika aman).
2. Audit `DataRetentionPolicy` + `retention-policy.*` + job `retention-cleanup.ts` + seeder `seed-retention.ts`. **Default decision:** remove product UI + public/admin product routes yang mengklaim “kebijakan retensi privasi”; keep soft-delete/admin hard-delete operational code.
3. Keep `AccountDeletionService.hardDeleteUserData` for **admin** only.
4. Grep confirm no mounts: `/api/privacy`, `/api/consent`, `/api/user/privacy-preferences`, user data-export portability.
5. Fix any broken imports after deletions.

### Client App (`Kolabri-client-app`)
1. Remove `RetentionPolicyTab` and any settings tab registration / copy.
2. Remove Core API proxy methods for privacy/policy/preferences if still in PHP controller; regenerate Wayfinder/Ziggy so `resources/js/actions/.../CoreApiProxyController.ts` no longer exports privacy helpers.
3. Remove dead `DataExportButton` / export UI if still present (inventory showed component may already be gone — re-verify).
4. Clean docs references (`docs/TIMEOUTS.md` PrivacyTab).
5. **Do not** change Google OAuth `prompt=consent`.

### Docs / OpenSpec
1. Do **not** rewrite SRS/SDD v2 (already clean).
2. Optionally note residual known gaps in this change’s verification section.
3. Supersede any active docs that re-introduce nfr-sec-02 privacy claims when touching them (no mass archive rewrite required).

## Capabilities

### New / enforcing
- `privacy-consent-free-runtime` — no product privacy-policy, privacy-preferences, consent-records, user portability export, retention-policy product UI, or AI-consent gate.

### Preserved
- Admin hard-delete user data (ops)
- OAuth `prompt=consent`
- Soft-delete operational fields where still used by domain
- Lecturer analytics export **course** metrics (bukan user GDPR export) if that endpoint is FR-028 — audit name carefully (`course-export` vs user data-export)

## Impact

- `Kolabri-core-api` Prisma models `ExportJob`, `DataRetentionPolicy` (likely)
- Client settings UI + Wayfinder regeneration
- Smoke: login, settings non-privacy tabs, AI chat (no consent gate), admin user hard-delete if used
- **BREAKING** for any external client still calling removed privacy/export/retention endpoints

## Non-Goals

- Implement privacy/GDPR/UU PDP
- Rewrite SRS/SDD
- Delete OAuth consent
- Drive-by lint of whole monorepo
- Finish `remove-out-of-scope-product-surfaces` (templates/bookmarks) unless import blocks this change

## Handoff readiness

- OpenSpec artifacts in `openspec/changes/purge-privacy-consent-residual/`
- Agent apply via OpenSpec apply workflow or direct implementation of `tasks.md`
- All tasks start **unchecked** for delegated agent re-validation (prior partial checkmarks were optimistic; re-audit required)
