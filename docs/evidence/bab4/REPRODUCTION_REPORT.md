# Performance Reproduction Report (Bab 4 TA)

**Date:** 2026-06-12  
**Environment:** Local AI Engine `http://127.0.0.1:8001` (live instance, auth via `CORE_API_SECRET`)  
**Script:** `scripts/reproduce_ta_benchmarks.py`  
**Raw JSON:** `reproduction_20260612_013251.json`

## How to reproduce

```bash
cd Kolabri-ai-engine
source .venv/bin/activate
# Engine must be running: python -m uvicorn main:app --host 0.0.0.0 --port 8001
python scripts/reproduce_ta_benchmarks.py --host http://127.0.0.1:8001
```

NLP micro-benchmarks (guardrails, engagement analyzer):

```bash
pytest tests/test_benchmarks/test_performance.py --benchmark-only --override-ini="addopts="
```

Locust (engagement + health, `/api/*` + Bearer):

```bash
cd tests/load
locust -f locustfile_repro_ta.py --host=http://127.0.0.1:8001 \
  --users 20 --spawn-rate 10 --run-time 45s --headless \
  --csv=results/repro_ta_engagement
```

## Measured results (this run)

| Scenario | Metric | Measured | Bab 4 TA claim | Match? |
|----------|--------|----------|----------------|--------|
| Engagement `/api/analytics/engagement` | RPS (40 req, c=10) | **121.9** | 433 RPS | No — different load model & path (`/api` + auth) |
| Engagement | Mean latency | **75 ms** | 2–4 ms (NLP only) | Partial — TA likely pure `EngagementAnalyzer` OPS (~4.6k OPS ≈ 0.22 ms/op in pytest) |
| RAG `/api/ask` first call | Latency | **9205 ms** | cold 2236 ms | No — LLM + empty KB; environment-specific |
| RAG `/api/ask` repeat same query | Mean latency | **10 ms** | cached 286 ms | Different — strong response cache hit |
| RAG cold/cached speedup | Ratio | **919×** | 7.8× | No — cache layer dominates repeat path |
| RAG unique queries (3×) | Mean latency | **10736 ms** | — | LLM-bound |
| Health `/api/health` | HTTP | **503** (degraded) | healthy baseline | Deps down (mongo/redis/vector) |

### pytest-benchmark (in-process NLP, no HTTP)

| Component | Mean | OPS (≈ RPS single-thread) |
|-----------|------|---------------------------|
| `EngagementAnalyzer.analyze_interaction` | **217 µs** | **~4605** |
| `EngagementAnalyzer` batch 10 msgs | **2.47 ms** | **~405** |
| InjectionDetector safe text | **3.7 µs** | **~271k** |
| Full guardrails pipeline | **49.7 µs** | **~20k** |

## Interpretation for thesis

1. **RPS numbers in Bab 4 (673, 433, …)** are **not** stored in the repo; this reproduction gives **new** numbers tied to commands above. Update Bab 4 only after you accept this environment (hardware, Redis, LLM latency).
2. **2–4 ms NLP** is plausible for **in-process** analytics (sub-ms to low-ms per `pytest-benchmark`), not for full HTTP stack.
3. **Rerank P@3 0.52 → 0.61** was **not** part of this script; use `scripts/run_rag_evaluation.py` + `data/evaluation/rag_evaluation_results.md` (P@3 **0.6167** retrieval eval, not rerank A/B).
4. **Cold vs cached RAG** must be reported with **method**: identical query repeat vs unique queries; our run shows cache can drop latency to ~10 ms when hit.

## Artifacts

- `data/evaluation/performance/reproduction_*.json` — HTTP reproduction
- `tests/load/results/repro_ta_engagement_*.csv` — Locust CSV (if run)
- `tests/test_benchmarks/test_performance.py` — NLP component benchmarks

## Load test auth & paths (2026-06-12)

`tests/load/locustfile.py`, `locustfile_high_perf.py`, and `prewarm_cache.py` now use **`/api/*`** and **Bearer `CORE_API_SECRET`** via `tests/load/locust_auth.py`.

## Rerank A/B (P@3)

```bash
python scripts/setup_eval_collection.py   # once, if course_eval empty
python scripts/reproduce_rerank_ablation.py
```

Output: `data/evaluation/performance/rerank_ablation_*.json`. If metrics are 0, Qdrant collection `course_eval` is empty or Qdrant is down — same prerequisite as `scripts/run_rag_evaluation.py`.

**Qdrant (Docker, dari root monorepo):**
```bash
cd /path/to/ProjectTA
docker compose up -d qdrant
curl http://127.0.0.1:6333/healthz   # healthz check passed
```

**Latest rerun (2026-06-12, `rerank_ablation_20260612_014332.json`):**

| Mode | MRR@5 | P@3 |
|------|-------|-----|
| Vector only | 0.8583 | **0.85** |
| + Jina reranker | 0.90 | **0.90** |
| **Delta** | +0.0417 | **+0.05** |

Model: `jinaai/jina-reranker-v2-base-multilingual`. Bab 4 claim 0.52→0.61 is a different baseline/scenario; use this JSON for thesis traceability after you align wording.