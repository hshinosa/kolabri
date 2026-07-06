## Context

fr-ai-06 (semester-adaptive scaffolding) is implemented and manually verified. Migration column + data exist, but tracking row was manually inserted because `prisma migrate resolve` had wrapper issues in the dev env. Automated tests (3.2) were deferred. RAG path with real Qdrant data is untested. No monitoring or clean-env deployment process exists. This change makes the feature production-ready.

Existing patterns:
- Tests: Jest (core-api), pytest (ai-engine)
- CI: .github/workflows/ci.yml (both repos)
- Seeding: prisma/scripts/seed-demo-data.ts
- Docs: docs/ folder (no runbook yet)

## Goals / Non-Goals

**Goals:**
- Official migration applied via `prisma migrate dev` / deploy in clean environments.
- Automated tests for early/late behavior selection + policy constraints (Jest + pytest).
- Full E2E with real RAG data (≥10 points in Qdrant, using existing seed script).
- Monitoring/alerts for scaffolding_level/outcome in mongo activity_logs (configurable threshold via env).
- Updated docs + deployment runbooks (new file docs/deployment/runbook-scaffolding.md).
- Rollback path documented.

**Non-Goals:**
- Changing the core scaffolding logic (already done).
- Adding per-student semester tracking (still course-scoped only).
- New UI features.
- Custom alert system (simple aggregation + env threshold only).

## Decisions

- Use existing `aiScaffoldingConfig` shape; no schema change.
- Add Jest tests in core-api (pattern: aiEngine.service.test.ts) and pytest in ai-engine.
- Use existing mongo activity_logs for monitoring (add aggregation query + env var `SCAFFOLDING_ALERT_THRESHOLD`).
- Migration: run `npx prisma migrate dev` in clean checkout; keep manual insert as fallback only.
- Rollback: disable via course config (enabled=false) or revert migration if needed.
- RAG population: extend existing seed-demo-data.ts (no new script).
- Runbook location: docs/deployment/runbook-scaffolding.md (new file).

## Risks / Trade-offs

- [RAG data not ready] → Mitigation: extend seed-demo-data.ts to insert ≥10 points; scaffolding injection path already proven.
- [Test maintenance] → Mitigation: keep tests focused on policy selection + outcome, not full LLM calls.
- [Migration drift] → Mitigation: document exact steps + provide one-command script in runbook.
- [Alert noise] → Mitigation: threshold configurable via env (default 80%).

## Migration Plan

1. Clean checkout → `npx prisma migrate dev`.
2. Run new automated tests (gate in CI).
3. Populate demo Qdrant via extended seed → run E2E with real RAG.
4. Enable mongo monitoring query + alert (env threshold).
5. Update runbooks.
6. Deploy.

Rollback: set enabled=false on course or revert migration file.

## Open Questions

- Exact default threshold for scaffolding anomalies? (80% disabled — configurable via env).
- Frequency of RAG population in demo env? (ops decision, documented in runbook).
