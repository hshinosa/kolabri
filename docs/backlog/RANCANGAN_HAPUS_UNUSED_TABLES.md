# Rancangan: Hapus 9 Tabel Unused + Frontend/Backend Code

## Tabel yang Akan Dihapus (9 tabel)

### Group 1: AI Experimentation (5 tabel, 0 rows)

| Tabel | Schema | Dibuat oleh | Alasan |
|---|---|---|---|
| `ai_ab_tests` | Prisma | migration `20260610113940` | 0 data, fitur A/B testing tidak pernah dipakai |
| `ai_ab_test_results` | Prisma | migration `20260610113940` | 0 data, hasil A/B test |
| `ai_model_comparisons` | Prisma | migration `20260610113940` | 0 data, fitur model comparison tidak pernah dipakai |
| `ai_model_comparison_results` | Prisma | migration `20260610113940` | 0 data, hasil comparison |
| `ai_presets` | Laravel | migration `2026_05_23_000014` | 0 data, preset AI lecturer tidak pernah dipakai |

### Group 2: Orphaned Laravel Tables (4 tabel, 0 rows)

| Tabel | Dibuat oleh | Alasan |
|---|---|---|
| `saved_reports` | migration `2026_05_23_000014` | Tidak ada Model, tidak ada Controller baca/tulis |
| `shared_reports` | migration `2026_05_23_000015` | Tidak ada Model, akses via core-api API |
| `learning_sessions` | migration `2026_05_23_000013` | Controller adalah API proxy, tidak pakai tabel lokal |
| `session_templates` | migration `2026_05_23_000012` | Controller adalah API proxy, tidak pakai tabel lokal |

## Code yang Akan Dihapus

### Core-api (Kolabri-core-api)

**Prisma schema (`schema.prisma`):**
- Hapus models: `AiAbTest`, `AiAbTestResult`, `AiModelComparison`, `AiModelComparisonResult`
- Hapus enum: `AbTestStatus`
- Hapus back-relations di `User` model (lines 54-56): `aiComparisons`, `aiAbTests`, `aiAbTestResults`
- Hapus back-relation di `Course` model (line 107): `aiAbTests`
- Hapus back-relation di `AiProvider` model (line 437): `comparisonResults`

**Controller (`lecturer-ai.controller.ts`):**
- Hapus methods: `listAbTests`, `createAbTest`, `getAbTest`, `updateAbTest`, `deleteAbTest`, `getAbTestStats`, `assignAbTestVariant`
- **KEEP**: `preview`, `getCourseContext`, `getHistory`, `archiveHistory` (masih dipakai)

**Controller (`admin-ai.controller.ts`):**
- Hapus method: `compareModels`
- **KEEP**: `getUsageStats`, `getUsageReport`

**Service (`ai.service.ts`):**
- Hapus method: `compareModels`
- Hapus: `defaultComparisonStore`, `ComparisonStore` type

**Routes (`lecturer-ai.routes.ts`):**
- Hapus: 7 AB test routes (lines 28-34)
- **KEEP**: `/preview`, `/courses/:courseId/context`, `/history`, `/history/archive`

**Routes (`admin-ai.routes.ts`):**
- Hapus: `POST /ai-compare` (line 17)
- **KEEP**: `GET /usage-stats`, `GET /usage-report/:userId/:month/:year`

**Validators:**
- `lecturer-ai.validator.ts`: hapus `abTestCreateSchema`, `abTestUpdateSchema`, `abTestParamsSchema`, `abTestListQuerySchema` + type exports
- `admin-ai.validator.ts`: hapus `aiCompareSchema` + `AiCompareInput` type

**Tests:**
- `admin-ai.controller.test.ts`: hapus test untuk `compareModels`
- Cek `lecturer-ai.controller.test.ts` jika ada — hapus AB test tests

### Client-app (Kolabri-client-app)

**Frontend pages (HAPUS FILE):**
- `resources/js/pages/lecturer/ai-settings.tsx` — seluruh page (tabs: preview, presets, history, ab-testing)
  - Semua 4 tab akan hilang. Page ini tidak ada di nav lecturer.
- `resources/js/pages/admin/ai-comparison.tsx` — seluruh page

**Controllers (HAPUS FILE):**
- `app/Http/Controllers/LecturerAISettingsController.php` — seluruh controller (presets + ab-tests + preview + history)
- `app/Http/Controllers/Lecturer/LearningSessionController.php` — seluruh controller (API proxy, tabel lokal unused)
- `app/Http/Controllers/SessionTemplateController.php` — seluruh controller (API proxy, tabel lokal unused)

**Controllers (EDIT — hapus method comparison):**
- `app/Http/Controllers/AISettingsController.php`:
  - Hapus method: `comparisonPage`, `compare`
  - **KEEP**: `index`, `show`, `store`, `update`, `destroy`, `activate`, `test`, `fallbackOrder`, `usageStats`, `usageReport`

**Models (HAPUS FILE):**
- `app/Models/AiPreset.php`

**Migrations (HAPUS FILE):**
- `database/migrations/2026_05_23_000014_create_saved_reports_table.php`
- `database/migrations/2026_05_23_000015_create_shared_reports_table.php`
- `database/migrations/2026_05_23_000013_create_sessions_table.php` (learning_sessions, NOT Laravel sessions table)
- `database/migrations/2026_05_23_000012_create_session_templates_table.php`
- `database/migrations/2026_05_23_000014_create_ai_presets_table.php` (ai_presets)

Wait — need to check: migration `2026_05_23_000014` creates BOTH `ai_presets` AND `saved_reports`? Let me check.

**Routes (`routes/web.php`):**
- Hapus route group: `Route::prefix('ai-settings')` under lecturer (lines 285-329)
- Hapus route: `Route::get('/ai-comparison', ...)` (line 230)
- Hapus route: `Route::post('/ai-compare', ...)` (line 231)
- Hapus route group: `Route::prefix('session-templates')` (lines 377-384)
- Hapus route group: `Route::prefix('sessions')` under lecturer (lines 387-400)

**Navigation:**
- `components/navigation/admin-nav.tsx`: hapus "AI Comparison" menu item (line 74-78)
- `components/navigation/lecturer-nav.tsx`: tidak ada yang dihapus (ai-settings tidak ada di nav)
- `config/shortcuts/admin.ts`: hapus `ctrl+5` AI Comparison (line 9)
- `config/shortcuts/lecturer.ts`: hapus `ctrl+5` AI Settings (line 9)
- `hooks/useAdminKeyboardShortcuts.ts`: hapus `/admin/ai-comparison` (line 10)
- `components/admin/GlobalSearch.tsx`: hapus AI Comparison entry (lines 41-47) + AI Settings lecturer entry

## Yang TIDAK Dihapus

- `ai_providers` — dipakai oleh admin AI settings (CRUD provider)
- `ai_usages` — dipakai oleh admin usage stats + lecturer history
- `ai_chats` + `ai_chat_messages` — dipakai oleh student AI chat
- `sessions` (Laravel framework) — dipakai untuk session storage
- `cache`, `cache_locks`, `jobs`, `job_batches`, `failed_jobs` — Laravel framework
- `migrations` (Laravel) — migration tracker
- `material_modules` — dipakai oleh LecturerMaterialsController

## Prisma Migration

Setelah hapus models dari `schema.prisma`, buat migration:
```bash
npx prisma migrate dev --name remove_unused_ai_tables
```

Ini akan generate SQL:
```sql
DROP TABLE "ai_ab_test_results" CASCADE;
DROP TABLE "ai_ab_tests" CASCADE;
DROP TABLE "ai_model_comparison_results" CASCADE;
DROP TABLE "ai_model_comparisons" CASCADE;
DROP TYPE "AbTestStatus";
```

## Laravel Migration

Hapus 5 migration files (saved_reports, shared_reports, learning_sessions, session_templates, ai_presets).

Karena tabel sudah ada di DB, perlu juga drop manual:
```sql
DROP TABLE IF EXISTS "saved_reports" CASCADE;
DROP TABLE IF EXISTS "shared_reports" CASCADE;
DROP TABLE IF EXISTS "learning_sessions" CASCADE;
DROP TABLE IF EXISTS "session_templates" CASCADE;
DROP TABLE IF EXISTS "ai_presets" CASCADE;
```

Atau jalankan `php artisan migrate:fresh` (tapi ini akan drop semua tabel Laravel + re-seed).

**Approach yang dipilih**: Drop manual via SQL + hapus migration files + remove dari `migrations` table.

## Execution Order

1. Core-api: edit schema.prisma + hapus code + `prisma migrate dev`
2. Client-app: hapus files + edit routes + edit controllers
3. VPS: deploy + drop tables via SQL + remove migration entries
4. Verify: TypeScript compile + web 200 + API 200
