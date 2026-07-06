## 1. Migration & Clean Environment

- [ ] 1.1 Run `npx prisma migrate dev` in a clean checkout and confirm tracking row + column.
- [ ] 1.2 Document one-command migration script for CI/CD and local dev (in runbook).
- [ ] 1.3 Add migration step to deployment runbook (docs/deployment/runbook-scaffolding.md).

## 2. Automated Tests

- [ ] 2.1 Add Jest tests in core-api (pattern: aiEngine.service.test.ts) for early/late/auto/disabled policy selection (exact handleAIQuestion path).
- [ ] 2.2 Add pytest in ai-engine for orchestration/rag scaffolding injection.
- [ ] 2.3 Ensure tests run as gate in CI (.github/workflows/ci.yml) before deploy.
- [ ] 2.4 Verify tests cover policy constraints (enabled=false → disabled outcome).

## 3. Real RAG Data Verification

- [ ] 3.1 Extend prisma/scripts/seed-demo-data.ts to insert ≥10 points per demo course Qdrant collection.
- [ ] 3.2 Run full E2E with real RAG (not empty collections) and confirm scaffolding_level/outcome + action_taken.
- [ ] 3.3 Document RAG population steps in runbook.

## 4. Monitoring & Alerts

- [ ] 4.1 Create mongo aggregation query for scaffolding_level/outcome counts (last 24h).
- [ ] 4.2 Add simple alert (email/Slack) on anomalous distribution using env var `SCAFFOLDING_ALERT_THRESHOLD` (default 80%).
- [ ] 4.3 Document monitoring query and alert setup in runbook.

## 5. Documentation & Rollback

- [ ] 5.1 Create deployment runbook at docs/deployment/runbook-scaffolding.md covering migration, test gate, RAG population, monitoring.
- [ ] 5.2 Document rollback path (enabled=false or migration revert).
- [ ] 5.3 Add production-readiness checklist to docs.

## 6. Final Verification

- [ ] 6.1 Run full production-readiness checklist in clean env.
- [ ] 6.2 Confirm all automated tests pass + real RAG + monitoring query.
- [ ] 6.3 Mark change ready for archive after successful production deploy.
