# P0 Release Gate (Kolabri TA)

Dokumen gate sebelum **P1** (`improve-test-coverage` dan hardening lanjutan).

## Scope P0

- `nfr-usability-04-discussion-direction` — diskusi terarah (classify, health, summary, UI)
- `nfr-sec-02-data-privacy` — policy + privacy preferences (BFF)
- `nfr-data-01-retention-policy` — retensi admin (smoke API)

Bukan P0: full coverage OpenSpec, perf-02 lengkap, export portability penuh.

## Lulus P0

### A. Otomatis (wajib)

```bash
cd Kolabri-core-api && npm run test:run    # 700 passed, 0 skipped
cd Kolabri-ai-engine && pytest -q
./scripts/run-smoke-checklist.sh         # fail=0
```

Env demo: lihat `docs/smoke-tests/README.md` (`SMOKE_*_EMAIL/PASS`).

### B. Manual (sekali per rilis demo)

`docs/smoke-tests/nfr-usability-04-p0.md` — Privasi, Retensi, chat room (badge/progress/health), ringkasan tutup sesi.

Stack: core-api :3000, ai-engine :8001, Laravel :8000 + Vite.

### C. OpenSpec

- `openspec/changes/nfr-usability-04-discussion-direction/tasks.md` — sinkron implementasi
- `openspec/changes/nfr-sec-02-data-privacy/tasks.md` — bagian policy + preferences P0

## P1 (setelah gate) — fokus aktif

**Track tunggal:** `openspec/changes/improve-test-coverage/tasks.md`

| Urutan | Fase | Isi |
|--------|------|-----|
| 1 | Phase 1 sisa | `text_extraction` OCR/caption + `chunking` split/overlap |
| 2 | Phase 2 | Analytics: `plan_vs_reality`, conformance, SRL, NLP |
| 3 | Phase 3–7 | API, core, services, RAG, blackbox gates |

Change lain (nfr-sec-02 sisa, perf-02, FR) = **P2+**, bukan P1.

## Status

| Tanggal | Automated | Manual UI | Catatan |
|---------|-----------|-----------|---------|
| 2026-06-12 | core-api 700/700; ai-engine **2222** pytest + **98.48%** cov; smoke **12/0/3** (`last-run-20260612-025435.md`) | UI manual skip=3 | P1 **archived** → `openspec/changes/archive/2026-06-12-improve-test-coverage/` |
