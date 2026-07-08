# Kolabri — AI Agent Guide

## Project Overview

Kolabri is a collaborative learning platform for university students. Three services run locally:

| Service | Directory | Port | Stack |
|---------|-----------|------|-------|
| Core API | `Kolabri-core-api/` | 3000 | Node.js + TypeScript, Prisma (PostgreSQL), MongoDB |
| AI Engine | `Kolabri-ai-engine/` | 8001 | Python, FastAPI |
| Client App (BFF) | `Kolabri-client-app/` | 8000 | Laravel 12, Inertia.js + React/TypeScript |

## Quick Start

```bash
# Start all services
./dev.sh start

# Check status
./dev.sh status

# Stop all services
./dev.sh stop
```

## Seeding Demo Data

Run the seed script from the project root:

```bash
# Full seed (resets core-api DB + generates PDFs for materials)
./scripts/seed-demo.sh

# Only seed core-api (PostgreSQL + MongoDB)
./scripts/seed-demo.sh --core-only

# Only seed client-app materials (MySQL + PDFs)
./scripts/seed-demo.sh --client-only

# Seed without regenerating existing PDFs (faster)
./scripts/seed-demo.sh --skip-pdf
```

**Prerequisites:**
- PostgreSQL and MongoDB must be running (`brew services start postgresql` / `brew services start mongodb-community`)
- Core API must be running on port 3000 for client-app seeding (the materials seeder calls the API to fetch course IDs)
- Redis must be running for the core API

**What the seed creates:**
- 2 lecturers, 15 students, 12 courses
- 36 groups (2-4 per course), 37 chat spaces with messages
- 36 course weeks (3 per course), 72 materials with real PDF content
- Learning goals, reflections, AI usage records, notifications

**Demo credentials:**
- Lecturer 1: `budi.santoso@univ.ac.id` / `password123`
- Lecturer 2: `siti.rahayu@univ.ac.id` / `password123`
- Student: `andi.pratama@student.ac.id` / `password123`

### Manual Seeding (if script fails)

```bash
# Core API — reset + seed (runs migrations, seeds PostgreSQL + MongoDB)
cd Kolabri-core-api
npm run db:reset:demo-data

# Client App — seed materials + generate PDFs
cd Kolabri-client-app
php artisan db:seed --class=MaterialsDemoSeeder
```

### Re-seeding

To completely re-seed from scratch:
```bash
./scripts/seed-demo.sh
```
The `--skip-pdf` flag skips PDF regeneration if files already exist in `storage/app/public/demo-materials/`. Without this flag, old PDFs are deleted and regenerated.

## AI Provider Configuration (Database-Driven)

Kolabri uses a **database-driven AI provider configuration** system where AI Engine dynamically fetches provider settings from Core API instead of relying solely on environment variables.

### How It Works

1. **Core API** stores AI provider configuration in `ai_providers` table (PostgreSQL)
2. **AI Engine** fetches active provider via internal endpoint `/api/internal/ai-provider/active`
3. **Redis cache** stores provider config for 5 minutes to minimize database load
4. **Fallback** to environment variables when fetch fails or flag is disabled

### Configuration Flags

- `UNIFIED_PROVIDER_ENABLED=false` (default): Use environment variables
- `UNIFIED_PROVIDER_ENABLED=true`: Fetch from database (cached for 5 minutes)

### Setup

**Enable database-driven config:**
```bash
# In Kolabri-ai-engine/.env
UNIFIED_PROVIDER_ENABLED=true
CORE_API_URL=http://localhost:3000
CORE_API_SECRET=your-shared-secret
```

**Manage providers via Core API:**
- Seeding creates default provider: `cli-proxy-api-plus` (deepseek-v4-flash)
- Admin can update provider via UI or API
- Changes reflect in AI Engine within 5 minutes (cache TTL)

**Emergency fallback:**
If Core API is down or provider fetch fails, AI Engine falls back to:
```bash
OPENAI_API_KEY=your-api-key
OPENAI_BASE_URL=https://your-api-url
OPENAI_MODEL=your-model
```

### Internal Endpoint

**Core API exposes:**
```
GET /api/internal/ai-provider/active
Header: X-Internal-Secret: <CORE_API_SECRET>
```

**Returns:**
```json
{
  "data": {
    "id": "uuid",
    "name": "cli-proxy-api-plus",
    "displayName": "CLI Proxy API Plus",
    "apiKey": "sk-ama",
    "baseUrl": "http://...",
    "config": {
      "defaultModel": "deepseek-v4-flash",
      "temperature": 0.7,
      "maxTokens": 8192
    }
  }
}
```

### Phase 2 (Future)

- **Webhook invalidation**: Core API sends webhook to AI Engine on provider update for immediate cache invalidation (instead of waiting 5 minutes)
- **Auto-failover**: Support multiple active providers with automatic failover on error

## Architecture Notes

### Data Flow

- **Core API** owns: users, courses, groups, chat spaces, messages, learning goals, reflections, AI data, course weeks, course materials metadata (PostgreSQL + MongoDB)
- **Client App (Laravel BFF)** owns: course weeks, course materials (metadata + PDF files), material modules, material views (MySQL)
- **Week binding**: Chat spaces in core-api have a `weekId` field that references `course_weeks.id`. This is now a real FK in PostgreSQL (also exists in MySQL for Laravel).

### Dual-Write: Course Weeks & Materials

`course_weeks`, `course_materials`, and `course_week_materials` exist in **both** PostgreSQL (core-api) and MySQL (client-app). This is intentional:

| Why PostgreSQL needs it | Why MySQL needs it |
|---|---|
| `resolveWeekLabelsByIds()` — returns `weekTitle`/`weekIndex` in API responses | Laravel Eloquent models for pre-read flow |
| `assertCourseWeekBelongsToCourse()` — validates `week_id` on session creation | PDF file storage + serving via `Storage::disk('public')` |
| `WeekContextService` — provides week context to AI engine | Material views tracking, module grouping |
| `citationFilter` — scopes AI citations by week | `MaterialsDemoSeeder` generates actual PDF content |

Both seeds use the same `seedUuid()` function → IDs are identical across databases. When seeding, **both must be run**:

```bash
# 1. Core-api seed (PostgreSQL)
cd Kolabri-core-api && npm run db:reset:demo-data

# 2. Client-app seed (MySQL + PDFs)
cd Kolabri-client-app && php artisan db:seed --class=MaterialsDemoSeeder
```

Or use the unified script: `./scripts/seed-demo.sh`

**Future improvement**: Make core-api the single source of truth for course weeks/materials metadata. Client-app would call core-api API instead of maintaining its own MySQL copy.

### Pre-read Flow

1. Chat spaces have a `weekId` linking them to a course week
2. When a student tries to enter a discussion session, the system checks if they've completed pre-read
3. If not completed → redirect to pre-read page showing materials for that week
4. Student reads materials (PDFs served via `Storage::disk('public')`) and clicks "complete"
5. `ChatSpacePreReadCompletion` record created → student can now access the chat room

### Deterministic Week IDs

Both the core-api seed (TypeScript) and client-app seed (PHP) use the same `seedUuid()` function to generate matching UUIDs:
- Input: `"{courseCode}-week-{weekNumber}"` (e.g., `"IF211-week-1"`)
- Both use MD5 hash formatted as UUID v4
- This ensures `chatSpace.weekId` in PostgreSQL matches `course_weeks.id` in MySQL
- Material IDs also use deterministic UUIDs: `"{courseCode}-week-{weekNum}-mat-{matIndex}"`

### Course Week & Material Data

The core-api seed now creates full week + material metadata in PostgreSQL:

| Table | Count | Content |
|---|---|---|
| `course_weeks` | 36 (3/course × 12 courses) | id, course_id, week_index, title, sort_order |
| `course_materials` | 72 (2/week × 36 weeks) | id, course_id, title, file_name, file_path |
| `course_week_materials` | 72 | Links weeks to materials with sort_order |

Week titles match the client-app's `MaterialsDemoSeeder.php` exactly (e.g., IF201 = "Fundamental Web & React", "API & Authentication", "Deployment & Optimization").

### Group Leader (Ketua Kelompok)

- The `Group.createdBy` field stores the user ID of the group creator
- In seeded data, `createdBy` is set to the first student member (not the lecturer)
- The group leader can kick members via `DELETE /api/groups/{groupId}/members/{memberId}`
- Lecturers who own the course can also remove members

### PDF Materials

- Generated by `MaterialsDemoSeeder` using `dompdf/dompdf`
- Stored in `storage/app/public/demo-materials/`
- Served via `Storage::disk('public')` through the stream endpoint
- Each PDF contains educational content: concepts, code examples, comparison tables, summaries
- Topics are course-specific (e.g., IF201 = React/SPA/JWT, IF211 = K-Means/Decision Trees)

## Common Commands

```bash
# Build client app frontend
cd Kolabri-client-app && npm run build

# Run core API tests
cd Kolabri-core-api && npm test

# Run client app tests
cd Kolabri-client-app && php artisan test

# Open Prisma Studio
cd Kolabri-core-api && npm run db:studio

# Check TypeScript errors
cd Kolabri-core-api && npx tsc --noEmit
cd Kolabri-client-app && npx tsc --noEmit

# PHP syntax check
cd Kolabri-client-app && php -l <file>

# LSP diagnostics (from any editor)
# Use lsp_diagnostics tool on specific files
```

## Key Files

| File | Purpose |
|------|---------|
| `Kolabri-core-api/prisma/schema.prisma` | Database schema (PostgreSQL) — includes CourseWeek, CourseMaterial, CourseWeekMaterial |
| `Kolabri-core-api/prisma/scripts/seed-demo-data.ts` | Core API seed data (weeks + materials included) |
| `Kolabri-core-api/src/services/group.service.ts` | Group + chat space logic, `resolveWeekLabelsByIds`, `assertCourseWeekBelongsToCourse` |
| `Kolabri-core-api/src/services/weekContext.service.ts` | Week context for AI engine (queries course_weeks) |
| `Kolabri-core-api/src/utils/citationFilter.ts` | AI citation filtering by week (queries course_weeks) |
| `Kolabri-client-app/app/Http/Controllers/StudentCourseController.php` | Student course pages |
| `Kolabri-client-app/database/seeders/MaterialsDemoSeeder.php` | Materials + PDF seeder (MySQL + file storage) |
| `Kolabri-client-app/resources/js/pages/student/courses/show.tsx` | Unified course detail page |
| `Kolabri-client-app/resources/js/pages/student/groups/show.tsx` | Group detail page |
| `Kolabri-client-app/resources/js/pages/student/goals/create.tsx` | Goal creation page (navigates to pre-read on back) |
| `Kolabri-client-app/resources/js/pages/student/pre-read/show.tsx` | Pre-read page |
| `Kolabri-client-app/resources/js/components/navigation/student-nav.tsx` | Student navigation |
| `Kolabri-client-app/routes/web.php` | Laravel routes (BFF) |

## Documentation Organization (Updated 2026-06-28)

The `docs/` directory has been reorganized into a clean folder structure for better navigation:

```
docs/
├── architecture/          # Architecture decisions & service boundaries
│   ├── adr/              # Architecture Decision Records
│   ├── *_SCOPE_BOUNDARIES.md
│   └── implementation-patterns.md
│
├── reports/              # All audit & implementation reports
│   ├── audits/          # System audits (5 reports)
│   ├── implementation/  # Feature implementation reports (4 reports)
│   └── inspection/      # Code inspection reports (5 reports)
│
├── thesis/              # TA/Thesis documentation
│   ├── TA_ALIGNMENT_PLAN.md
│   ├── TA_BAB4_ALIGNMENT_PLAN.md
│   ├── TA_FINAL_HOSTILE_REVIEW.md
│   └── FINAL_REPORT.md
│
├── questionnaires/      # User research & UAT
│   ├── dosen/          # Lecturer questionnaires & UAT (8 files)
│   ├── mahasiswa/      # Student questionnaires & UAT (5 files)
│   └── generators/     # Python scripts to generate forms (3 files)
│
├── testing/             # Test documentation
│   ├── smoke-tests/
│   ├── test-coverage-wave1-4.md
│   └── INTEGRATION_TEST_CHECKPOINT.md
│
├── migrations/          # Migration guides & notes
│   ├── course-weeks-migration-notes.md
│   └── openspec-workflow.md
│
├── guides/              # How-to guides
│   ├── DEMO-GUIDE.md
│   ├── code-review-checklist.md
│   └── DOCS_INDEX.md
│
├── backlog/             # Planning & roadmap
│   ├── CHAT_ENHANCEMENT_BACKLOG.md
│   ├── NFR-IMPLEMENTATION-PLAN.md
│   └── p0-release-gate.md
│
├── observations/        # Issue tracking & fixes
│   ├── KOLABRI_OBSERVATIONS_ACTION_ITEMS.md
│   └── GROUP_STUCK_FIX.md
│
└── (supporting folders)
    ├── evidence/       # Test evidence & screenshots
    ├── deployment/     # Deployment configs & guides
    ├── debugging/      # Debug logs & troubleshooting
    ├── superpowers/    # Agent skills & workflows
    └── sample-materials/ # Sample course materials
```

**Quick Links:**
- Latest audit: `reports/audits/AUDIT_REPORT_FINAL.md`
- Latest implementation: `reports/implementation/IMPLEMENTATION_SUMMARY.md`
- Architecture decisions: `architecture/adr/`
- Demo guide: `guides/DEMO-GUIDE.md`
- Testing: `testing/smoke-tests/`
