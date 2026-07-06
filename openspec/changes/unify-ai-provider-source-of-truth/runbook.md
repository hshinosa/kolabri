# Rollout Runbook — Unify AI Provider Source of Truth

This runbook covers safe deployment, verification, and rollback of the `unify-ai-provider-source-of-truth` change.

## Prerequisites

- [ ] Core-api and ai-engine are on the version that includes `provider_context.v1` support.
- [ ] At least one active `AiProvider` record exists in core-api PostgreSQL with a valid fallback order.
- [ ] `OPENAI_API_KEY` and `OPENAI_BASE_URL` are still set in ai-engine env as compatibility bootstrap values.
- [ ] Provider credentials are encrypted in DB and decryptable by core-api.
- [ ] Logs/traces are configured to redact `provider_context.auth.credential`.

## Deployment sequencing

1. **Deploy ai-engine first**
   - Confirm ai-engine health endpoint returns `200`.
   - Confirm ai-engine can still start with existing env vars (compatibility mode).

2. **Deploy core-api second**
   - Confirm core-api health endpoint returns `200`.
   - Confirm core-api can resolve active providers from DB.

3. **Keep all feature flags disabled initially**
   - `UNIFIED_PROVIDER_ENABLED=false`
   - `UNIFIED_PROVIDER_PERSONAL_CHAT=false`
   - `UNIFIED_PROVIDER_ORCHESTRATION=false`
   - `UNIFIED_PROVIDER_INTERVENTIONS=false`
   - `UNIFIED_PROVIDER_SUMMARIES=false`
   - `UNIFIED_PROVIDER_GOALS=false`
   - `UNIFIED_PROVIDER_RAG=false`
   - `UNIFIED_PROVIDER_ANALYTICS=false`

4. **Enable feature families one at a time**
   - Start with lowest-risk background flows (summaries, analytics).
   - Move to interactive flows (personal chat, orchestration, interventions, goals, RAG).
   - Wait for acceptance criteria before enabling the next family.

## Feature flags

| Flag | Purpose | Default | Rollback |
|------|---------|---------|----------|
| `UNIFIED_PROVIDER_ENABLED` | Global kill switch for unified provider routing | `false` | Set `false` to revert all families to legacy env-based routing |
| `UNIFIED_PROVIDER_PERSONAL_CHAT` | Use DB provider context for personal chat | `false` | Set `false` to revert personal chat |
| `UNIFIED_PROVIDER_ORCHESTRATION` | Use DB provider context for orchestrated group chat | `false` | Set `false` to revert orchestration |
| `UNIFIED_PROVIDER_INTERVENTIONS` | Use DB provider context for silence/quality interventions | `false` | Set `false` to revert interventions |
| `UNIFIED_PROVIDER_SUMMARIES` | Use DB provider context for session summaries | `false` | Set `false` to revert summaries |
| `UNIFIED_PROVIDER_GOALS` | Use DB provider context for goal validation/refinement | `false` | Set `false` to revert goals |
| `UNIFIED_PROVIDER_RAG` | Use DB provider context for reading recommendations/RAG | `false` | Set `false` to revert RAG |
| `UNIFIED_PROVIDER_ANALYTICS` | Use DB provider context for engagement/process-mining analytics | `false` | Set `false` to revert analytics |
| `UNIFIED_PROVIDER_COMPATIBILITY_MODE` | Allow ai-engine to fall back to env-based client when no provider_context is supplied | `true` | Keep `true` during rollout; set `false` only after full verification |

## Verification commands

### 1. Provider resolution works

```bash
cd Kolabri-core-api
npx vitest run src/services/providerResolution.service.test.ts
```

Expected: all tests pass.

### 2. Migrated callers attach provider_context

```bash
cd Kolabri-core-api
npx vitest run src/services/aiChat.service.test.ts src/controllers/aiChat.controller.test.ts src/services/chatSpace.service.test.ts src/socket/interventions.test.ts src/services/goal.service.test.ts src/services/readingRecommendation.service.test.ts src/services/analytics.service.test.ts src/services/aiEngine.service.test.ts
```

Expected: all tests pass.

### 3. End-to-end propagation across feature families

```bash
cd Kolabri-core-api
npx vitest run src/services/aiChat.integration.test.ts src/services/unifiedProvider.integration.test.ts
```

Expected: all tests pass.

### 4. Full affected suite

```bash
cd Kolabri-core-api
npx vitest run src/services/providerResolution.service.test.ts src/services/aiChat.service.test.ts src/controllers/aiChat.controller.test.ts src/services/chatSpace.service.test.ts src/socket/interventions.test.ts src/services/goal.service.test.ts src/services/readingRecommendation.service.test.ts src/services/aiEngine.service.test.ts src/services/aiChat.integration.test.ts src/services/unifiedProvider.integration.test.ts
```

Expected: all tests pass.

### 5. Type-check core-api

```bash
cd Kolabri-core-api
npx tsc --noEmit
```

Expected: no new type errors introduced by this change.

## Acceptance criteria per feature family

Before enabling the next feature flag, verify:

- [ ] Error rate for the feature family is within baseline (±10%).
- [ ] P95 latency for synchronous flows is within agreed budget.
- [ ] No raw provider credentials appear in logs or traces.
- [ ] Degraded outcomes (fallback messages, empty summaries, etc.) are surfaced gracefully.
- [ ] Rollback to legacy behavior works by disabling the feature flag.

## Degraded outcomes and detection

| Symptom | Likely cause | Mitigation |
|---------|--------------|------------|
| `No active AI provider configured` errors | No active `AiProvider` records | Add/configure an active provider in core-api admin |
| Feature returns canned fallback message | Primary provider failed and no fallback succeeded | Check provider health, fallback order, and credentials |
| Increased latency | Provider resolution + ai-engine round trip | Verify DB query performance; consider short TTL cache if needed |
| Ai-engine fails to start | Missing bootstrap env vars | Keep `OPENAI_API_KEY`/`OPENAI_BASE_URL` set during compatibility mode |
| Provider changes not reflected | Feature flag still disabled or cache stale | Enable flag; verify provider resolution logs |

## Rollback procedures

### Per-feature rollback

1. Set the feature flag to `false`:
   ```bash
   UNIFIED_PROVIDER_<FEATURE>=false
   ```
2. Restart core-api and ai-engine if required by env loading.
3. Verify the feature returns to legacy behavior.
4. Investigate and fix the regression before re-enabling.

### Global rollback

1. Set the global kill switch to `false`:
   ```bash
   UNIFIED_PROVIDER_ENABLED=false
   ```
2. Keep `UNIFIED_PROVIDER_COMPATIBILITY_MODE=true`.
3. Restart core-api and ai-engine if required.
4. Verify all migrated features revert to env-based provider routing.
5. Investigate root cause before re-enabling.

### Emergency rollback

If provider credentials are suspected to be leaking:

1. Disable `UNIFIED_PROVIDER_ENABLED` immediately.
2. Rotate the affected provider API key.
3. Review logs/traces for credential exposure.
4. Fix redaction before re-enabling.

## Post-rollout cleanup

After all feature families are verified in production for at least one full usage cycle:

1. Set `UNIFIED_PROVIDER_COMPATIBILITY_MODE=false`.
2. Remove ai-engine runtime dependence on `OPENAI_API_KEY` and `OPENAI_BASE_URL` as provider sources.
3. Keep env vars only if required for infrastructure/bootstrap concerns unrelated to provider selection.
4. Update monitoring dashboards to treat legacy env-based routing as an error path.

## Contacts and references

- OpenSpec change: `openspec/changes/unify-ai-provider-source-of-truth/`
- Design doc: `openspec/changes/unify-ai-provider-source-of-truth/design.md`
- Tasks: `openspec/changes/unify-ai-provider-source-of-truth/tasks.md`
- Core-api provider resolution: `Kolabri-core-api/src/services/providerResolution.service.ts`
- Integration tests: `Kolabri-core-api/src/services/unifiedProvider.integration.test.ts`
