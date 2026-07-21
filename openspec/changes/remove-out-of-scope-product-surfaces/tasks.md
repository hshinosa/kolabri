## 1. Inventory residual (Client App)

- [x] 1.1 List all files for StudentAnalytics, ReflectionTemplate*, ReflectionTag*, ReflectionAnalytics*, AiChatTemplate*, AiChatBookmark*, SavedMaterial*, PlanVsDiskusi*
- [x] 1.2 Grep TS/PHP references and Wayfinder/Ziggy names
- [x] 1.3 Confirm `routes/web.php` has no live routes (already stripped)

## 2. Remove Client App dead code

- [x] 2.1 Delete controllers + models + seeders for residual surfaces
- [x] 2.2 Delete pages/components only used by residual surfaces
- [x] 2.3 Remove template panel UX from `admin/master-data.tsx` (not just stub handlers)
- [x] 2.4 Remove unit tests that only cover PlanVsDiskusi / templates / bookmarks
- [x] 2.5 Fix any broken imports; regenerate Wayfinder if used

## 3. Core API residual (optional phase)

- [x] 3.1 Audit course-templates, bookmarks, saved-materials, consent endpoints for external deps
- [x] 3.2 Remove or deprecate unreferenced endpoints only after 3.1
- [x] 3.3 Tests + OpenAPI update

## 4. Verification

- [x] 4.1 `php -l` / PHPUnit subset green
- [x] 4.2 Frontend typecheck/build relevant package
- [x] 4.3 Smoke: student join→pre-read→goal→chat→reflection; AI personal chat; lecturer analytics; admin AI settings + master-data
- [x] 4.4 Document residual known gaps in change archive notes

## Verification evidence

- 1.1–1.3: residual inventory, reference grep, and `routes/web.php` review completed.
- 2.1–2.5: dead controllers/models/seeders/pages/components/tests removed; master-data template UX and proxy methods removed; typecheck/build passed.
- 3.1–3.3: Core API audit found course-template endpoints still externally callable and internally linked, so no unsafe deletion; no Core bookmark/saved-material endpoints or OpenAPI artifacts found; consent stack left untouched.
- 4.1: `php -l` passed for changed PHP files; direct `vendor/bin/phpunit --filter AiChatIntegrationTest --do-not-fail-on-deprecation` passed 4 tests, 27 assertions, with one pre-existing missing-class warning and PHP 8.5 deprecations. Full `php artisan test` remains blocked by pre-existing auth/database failures.
- 4.2: `npm run types`, `npm run build`, and `npm run test:unit` passed, 25 files and 134 tests.
- 4.3: `./dev.sh status` confirmed PostgreSQL, MongoDB, Redis, Qdrant, Core API, AI Engine, and Client App unavailable; live manual smoke could not run.
- 4.4: known residuals are historical Client App migrations/docs and Core API course-template endpoints; no active Client App product entry points remain.
- Baseline checks outside this cleanup remain failing: full ESLint, Prettier, Pint, and `git diff --check` report pre-existing issues in unrelated files; no drive-by fixes applied.
