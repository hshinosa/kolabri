# Scaffolding Production Readiness Runbook

## 1. Prerequisites
- Clean checkout of the repo
- Docker / local services running (postgres, mongodb, qdrant)
- Environment variables set (including `SCAFFOLDING_ALERT_THRESHOLD` if custom)

## 2. Migration (Clean Environment)
```bash
cd Kolabri-core-api
npx prisma migrate dev
```
Expected: Migration `20260610_add_course_ai_scaffolding_config` appears in `_prisma_migrations` with `finished_at`.

If already applied manually, run:
```bash
npx prisma migrate resolve --applied 20260610_add_course_ai_scaffolding_config
```

## 3. Automated Tests
Core API (Jest):
```bash
cd Kolabri-core-api
npm test -- --testPathPattern="scaffolding|aiEngine.service"
```

AI Engine (pytest):
```bash
cd Kolabri-ai-engine
pytest tests/test_scaffolding*.py -v
```

Both must pass before deploy.

## 4. Real RAG Data
Use the ai-engine ingestion endpoint or dedicated qdrant seed to ensure ≥10 points per demo course collection.

Example (ai-engine):
```bash
curl -X POST http://localhost:8001/api/ingest \
  -H "Authorization: Bearer shared-secret-key" \
  -F "file=@/path/to/sample.pdf" \
  -F "course_id=<IF201_ID>" \
  -F "file_id=<uuid>"
```

Verify scaffolding with real RAG:
```bash
curl -X POST http://localhost:8001/api/chat \
  -H "Authorization: Bearer shared-secret-key" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test","group_id":"g-test","message":"test","topic":"test","collection_name":"course_IF201","course_id":"<IF201_ID>","chat_room_id":"cs-test","guardrail_policy":{"preset":"balanced"},"scaffolding_config":{"scaffolding_level":"early","enabled":true}}'
```
Expected: `scaffolding_level=early`, `scaffolding_outcome=applied`, `action_taken` reflects actual RAG fetch (not NO_FETCH).

## 5. Monitoring
Mongo aggregation (last 24h):
```js
db.activity_logs.aggregate([
  { $match: { "Attributes.scaffolding_level": { $exists: true }, Timestamp: { $gte: new Date(Date.now() - 24*3600000) } } },
  { $group: { _id: "$Attributes.scaffolding_level", count: { $sum: 1 } } }
])
```

Alert (simple threshold):
- If `disabled` > `SCAFFOLDING_ALERT_THRESHOLD` (default 80%), send alert.

## 6. Rollback
- Immediate: Set `enabled=false` on the course via lecturer settings (aiScaffoldingConfig.enabled=false). This disables scaffolding without code changes.
- Full revert: Revert the migration file and run `prisma migrate resolve --rolled-back` (only if data model change is required).

## 7. Production Checklist
- [ ] Migration applied via `prisma migrate dev` (tracking row present)
- [ ] All automated tests pass (Jest + pytest for scaffolding policy)
- [ ] Real RAG data populated (≥10 points per demo course)
- [ ] Monitoring query + alert configured (`SCAFFOLDING_ALERT_THRESHOLD`)
- [ ] Runbook followed end-to-end
- [ ] Rollback tested (enabled=false works)
- [ ] Fresh E2E verification with real RAG succeeds (scaffolding_level/outcome correct)

After successful deploy, mark this change ready for archive.