## Why

The semester-adaptive scaffolding feature (fr-ai-06) is functionally complete and manually verified, but not yet production-ready. Migration tracking is manually inserted, automated tests are deferred, RAG behavior with real data is untested, and there is no monitoring or clean-env deployment process. This blocks safe rollout to production.

## What Changes

- Run official `prisma migrate dev` / deploy in clean environments.
- Add automated tests for early/late behavior selection and policy constraints (Jest in core-api, pytest in ai-engine).
- Verify full path with real RAG data (Qdrant collections with ≥10 points, using existing seed-demo-data.ts).
- Add monitoring/alerts for scaffolding_level/outcome in mongo activity_logs (simple aggregation + configurable threshold via env).
- Update documentation and deployment runbooks (new file: docs/deployment/runbook-scaffolding.md).
- Ensure rollback path exists if scaffolding causes issues.

**BREAKING**: None (pure additive + verification).

## Capabilities

### New Capabilities
- `scaffolding-production-readiness`: Production checklist, automated tests, monitoring, and clean deployment for semester-adaptive scaffolding.

### Modified Capabilities
- `semester-adaptive-scaffolding`: Add automated test requirements and monitoring expectations to the existing spec.

## Impact

- Kolabri-core-api: prisma migration, new test files (Jest), monitoring hooks, CI gate in .github/workflows/ci.yml.
- Kolabri-ai-engine: pytest coverage for orchestration/rag scaffolding injection, CI gate.
- Prisma + Mongo: official migration + log monitoring.
- Deployment pipeline: new steps for clean-env migrate + test gate.
- Documentation: new runbook at docs/deployment/runbook-scaffolding.md + monitoring guides.
