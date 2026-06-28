# Fase 5 — Checklist siap sidang (2026-06-12)

- [x] Fase 0 snapshot — `PHASE0_SNAPSHOT_2026-06-12.md`
- [x] Fase 2 edit `bab4.tex` — cakupan, integrasi 147, rerank Jina, performa HTTP repro, LLM reframed, semantic cache/multi-tenancy/process mining reframed, modul analitik 222 tests
- [x] `tab:test_env` — macOS + OpenAI-compatible `.env`
- [x] Angka stale (673, 433, 2173, 0,52, 2.236, 7,8×) — tidak ada di bab4; penolakan klaim cache tanpa angka lama
- [x] Bukti disalin ke `docs/evidence/bab4/` (REPRODUCTION_REPORT, JSON, rag_evaluation_results.md)
- [x] Fase 4 — `latex-documents/TA/lampiran/lampiran_jejak_pengujian.tex` + `\include` di `main.tex`
- [x] Kompilasi PDF TA — `pdflatex main.tex` → 85 halaman (2026-06-12)
- [x] pytest penuh — **2411 passed** (reranker scope, citations mock, goal validate 200)
- [x] Audit referensi silang (bg explore + patch) — `TA_CROSS_REFERENCE_AUDIT.md`
- [x] Second-pass review artefak — `TA_SECOND_PASS_REVIEW.md`; patch README 2411, banner `BENCHMARK_AUDIT_REPORT.md` + `TA_FINAL_REVIEW_CONTEXT.md`, bab4 parafrase cache tanpa 28%/420
- [x] bg_31c6a660 / bg_31d60482 — FINAL
- [ ] **Review pembimbing satu putaran** — item **non-teknis / proses sidang**: minta dosen pembimbing membaca naskah final (post-alignment Juni 2026) dan memberi masukan; bukan tugas agent/repo. Teknis alignment sudah [x].

## Matriks Fase 1 — status ringkas

| Area | Aksi |
|------|------|
| pytest/coverage | UPDATE ✅ |
| integration 147 | UPDATE ✅ |
| E2E + blackbox 38 | REFRAME ✅ |
| RAG 20-query tables | KEEP ✅ |
| benchmark_cache / throughput | UPDATE/REFRAME ✅ |
| llm_perf | REFRAME ✅ |
| rerank | UPDATE ✅ |
| semantic cache 28% | REFRAME ✅ |
| multi-tenancy skala besar | REFRAME ✅ |
| process mining 2270 | REFRAME ✅ |
| modul analitik 145→222 | UPDATE ✅ |
| keterbatasan | UPDATE ✅ |