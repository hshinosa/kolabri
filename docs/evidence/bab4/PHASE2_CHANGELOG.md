# Fase 2 — Changelog edit bab4.tex (2026-06-12)

## Selesai
- `tab:test_coverage`: 2406 / 2405 lulus, coverage 99,92%, unit 2199, integration 147
- Paragraf cakupan + blackbox 38
- `tab:integration_results`: total 147
- Cross-encoder rerank: Jina, P@3 0,85→0,90, skrip repro
- § performa: metodologi dua lapisan; `tab:benchmark_cache` RAG + engagement HTTP; `tab:throughput` angka repro; H3 + pembahasan async/cache
- E2E: footnote blackbox 38

## Putaran 2 (selesai)
- `tab:test_env`: macOS, LLM via `.env`
- `tab:benchmark_cache` / `tab:llm_perf`: reframed; baris LLM tanpa jejak dihapus
- Process mining, multi-tenancy, semantic cache: reframed ke bukti repo
- Modul analitik **222** tests; keterbatasan dirapikan
- Fase 4: Lampiran A + `docs/evidence/bab4/`; `main.pdf` 85 halaman OK

## Pytest (sesi akhir)
- `test_reranker.py`: `enable()` dalam `with patch`
- `test_routes_integration.py`: mock `citations=[]`
- goal validate / blackbox: 200 + `is_valid=false` (bukan 422)
- **2411 passed**, collected 2414