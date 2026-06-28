# Fase 0 — Snapshot pengujian (2026-06-12)

| Metrik | Nilai |
|--------|-------|
| pytest collected | 2414 (sesi akhir; sebelumnya 2406) |
| passed | 2411 (sesi akhir, 2026-06-12) |
| failed | 0 setelah perbaikan tes goal validate + reranker + orchestration mock |
| `--cov=app` | **99,92%** |
| `tests/test_integration` | 147 |
| `tests/test_blackbox` | 38 |

**Rerank A/B:** `data/evaluation/performance/rerank_ablation_20260612_014332.json` (P@3 0,85 → 0,90)

**HTTP repro:** `data/evaluation/performance/reproduction_20260612_013251.json`