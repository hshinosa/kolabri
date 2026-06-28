# Rancangan Penyelarasan Bab 4 TA dengan Bukti Kolabri-ai-engine

**Tujuan:** Menyelaraskan naskah `latex-documents/TA/bab/bab4.tex` dengan artefak yang **sudah ada** di repo — **tanpa** membuat harness benchmark baru.

**Prinsip:**
- Setiap angka di Bab 4 harus punya **sumber** (perintah + file output) atau diubah menjadi **klaim kualitatif** + batasan.
- Perubahan **surgical** (tabel/paragraf target), bukan rewrite bab.
- Bukti performa mengacu ke `Kolabri-ai-engine/data/evaluation/performance/` dan skrip yang sudah dibuat.

---

## Fase 0 — Persiapan (sekali, sebelum edit LaTeX)

| # | Tindakan | Perintah / file |
|---|----------|-----------------|
| 0.1 | Infra eval | `cd ProjectTA && docker compose up -d qdrant` (+ mongo/redis jika uji HTTP penuh) |
| 0.2 | Ingest eval RAG | `python Kolabri-ai-engine/scripts/setup_eval_collection.py` |
| 0.3 | Snapshot pytest | `pytest --cov=app -q` → catat **passed**, **failed**, **coverage %** |
| 0.4 | Salin bukti ke git (opsional) | Copy `REPRODUCTION_REPORT.md` + `rerank_ablation_*.json` ke `ProjectTA/docs/evidence/bab4/` (karena `data/` di `.gitignore`) |
| 0.5 | Catat lingkungan aktual | OS (macOS vs Arch di TA), tanggal run, commit hash ai-engine |

---

## Fase 1 — Matriks klaim → bukti → aksi

Legenda aksi: **KEEP** = tetap | **UPDATE** = ganti angka/teks | **REFRAME** = ubah cara menyampaikan (metode/batasan) | **VERIFY** = cek sekali lagi sebelum sidang

### 1.1 Pengujian fungsional & cakupan

| Klaim Bab 4 (lokasi) | Bukti repo | Status | Aksi |
|----------------------|------------|--------|------|
| Total **2.173** test, coverage **97,30%** (`tab:test_coverage`) | Run terbaru ~**2.351 passed**, **~99,78%** `--cov=app` | Mismatch | **UPDATE** tabel + paragraf L99–118; pecah unit vs integration jika perlu |
| Integration **141** (`tab:integration_results`) | **147** integration tests (audit sesi) | Mismatch | **UPDATE** total + baris tabel jika breakdown berubah |
| **66** security tests (L122–126) | `tests/test_unit/test_security.py` | Match | **KEEP** |
| **50** RAG accuracy tests (L130–151) | `test_rag_accuracy.py` + `tests/rag_accuracy/` | Match | **KEEP** |
| E2E **21** skenario (`tab:e2e_results`) | **38** blackbox (`tests/test_blackbox/`) | Mismatch definisi | **REFRAME**: jelaskan E2E = skenario manual/live vs blackbox pytest; **UPDATE** tabel atau gabungkan definisi di footnote |
| Logic Listener F1 **1,00** (30 gold) (`tab:logic_listener_eval`) | `data/evaluation/logic_listener_*.json`, harness pytest + mock | Match dengan caveat | **KEEP** + pertahankan paragraf “validasi fungsional, bukan skala produksi” (L221–223) |

### 1.2 Evaluasi RAG kuantitatif (20 kueri)

| Klaim | Bukti | Status | Aksi |
|-------|-------|--------|------|
| Tabel `tab:rag_eval_quantitative` (MRR 0,88, P@3 0,62, per tipe) | `data/evaluation/rag_evaluation_results.md` | Match (pembulatan) | **KEEP** atau sesuaikan digit jika re-run `scripts/run_rag_evaluation.py` |
| Tabel `tab:rag_baseline_comparison` (+10% keyword) | File sama | Match | **KEEP** |
| Paragraf H1 (L418) | Idem | Match | **KEEP** setelah tabel konsisten |

### 1.3 Performa — latensi & throughput (bagian paling sensitif)

| Klaim Bab 4 | Bukti repro | Status | Aksi |
|-------------|-------------|--------|------|
| `tab:benchmark_cache` (RAG cold **2.236 ms**, cache **286 ms**, **7,8×**) | `reproduction_*.json`: cold ~9,2 s, cache ~10 ms, speedup ~919× (env berbeda) | Tidak ada file lama di repo | **UPDATE** tabel dari JSON **atau** **REFRAME**: pisahkan “komponen NLP lokal (pytest-benchmark µs)” vs “HTTP end-to-end (skrip repro)” |
| Engagement NLP **2–4 ms** (L347, L354) | pytest-benchmark **~217 µs** in-process; HTTP **~75 ms** | Partial | **REFRAME**: 2–4 ms → in-process; tambah kalimat “latensi HTTP termasuk stack FastAPI” jika pakai angka HTTP |
| `tab:throughput` (433, 673, 311, 672, 0,57 RPS) | Locust repro **~67–122 RPS** engagement; angka TA tidak di repo | Mismatch | **UPDATE** dari `tests/load/results/*.csv` setelah run resmi **atau** hapus angka spesifik → “diukur dengan Locust KOL-42, lihat lampiran” |
| `tab:llm_perf` (TPS 220, token 830, dll.) | Tidak di-repro sesi ini | Unverified | **VERIFY** dengan skrip terpisah / log LLM **atau** **REFRAME** sebagai estimasi + batasan |
| H2/H3 (L420–422): 672 RPS, 7,8× cache | Sama | Mismatch | **UPDATE** angka mengikuti tabel performa yang baru |
| Keterbatasan beban 5 klien (L507) | Locust bisa 20–100 users | OK | **KEEP** atau update jika sudah run skenario lebih besar |

**Sumber perintah (sudah ada, jangan buat file baru):**
- HTTP: `scripts/reproduce_ta_benchmarks.py`
- Locust: `tests/load/locustfile.py` + `run_load_test.py --scenario smoke|load`
- NLP mikro: `pytest tests/test_benchmarks/test_performance.py --benchmark-only`
- Laporan: `data/evaluation/performance/REPRODUCTION_REPORT.md`

### 1.4 Fitur lanjutan

| Klaim | Bukti | Status | Aksi |
|-------|-------|--------|------|
| Rerank **0,52 → 0,61**, model **ms-marco** (L448–450) | `rerank_ablation_20260612_014332.json`: **0,85 → 0,90**, model **Jina** | Mismatch | **UPDATE** paragraf + (opsional) tabel kecil; sebut **A/B** `reproduce_rerank_ablation.py`, retrieve_k=10, top_k=3 |
| Semantic cache **28%** hit, **18 ms** vs **420 ms** (L463–471) | Belum di-repro eksplisit sesi ini | Unverified | **VERIFY** dari test/redis **atau** **REFRAME** + catat sebagai target desain jika tidak ada log |
| Multi-tenancy 10 course × 50 doc (L452–461) | Cari test/integration terkait | VERIFY | **KEEP** jika test ada; else kurangi klaim |
| Modul analitik **145** tests (L488) | `grep`/pytest count modul terkait | VERIFY | **UPDATE** jika jumlah berubah |
| Process mining **2.270** events / **88** cases (L440) | `data/event_logs/` atau export test | VERIFY | **KEEP** jika file masih sama |

### 1.5 Lingkungan pengujian

| Klaim | Realita | Aksi |
|-------|---------|------|
| Tabel `tab:test_env` Arch Linux | Dev user macOS | **UPDATE** OS ke lingkungan tempat angka final diukur **atau** tulis “pengujian utama di Arch; reproduksi tambahan di macOS” |
| LLM DeepSeek V4 Flash | `.env` user (glm/gpt) | **UPDATE** agar sama dengan `.env` saat pengujian |

---

## Fase 2 — Urutan edit `bab4.tex` (disarankan)

1. **§ Pengujian Fungsional** — `tab:test_coverage`, paragraf jumlah test & coverage.
2. **§ Pengujian Integrasi** — total 141 → angka baru (jika breakdown dipertahankan, hitung ulang per baris dari pytest).
3. **§ E2E** — selaraskan definisi dengan blackbox atau pisahkan subbab.
4. **§ Pengujian Performa** — `tab:benchmark_cache`, `tab:throughput`, `tab:llm_perf` + paragraf pembahasan H2/H3 yang mengutip angka tersebut.
5. **§ Cross-Encoder Re-ranking** — L448–450.
6. **§ Keterbatasan** — sesuaikan angka yang sudah diupdate (latensi, skala beban, dataset RAG).
7. **Proofread** — cari sisa angka lama: `2173`, `97,30`, `673`, `433`, `0,52`, `0,61`, `2.236`, `7,8`.

**Tidak wajib di bab ini:** refactor kode ai-engine; fix 1 pytest fail reranker (bisa lampiran “known issue”).

---

## Fase 3 — Template narasi (copy-adapt ke LaTeX)

### Rerank (ganti L448–450)

> Evaluasi A/B pada *gold standard dataset* 20 kueri (koleksi `course_eval`, Qdrant) membandingkan pengambilan vektor saja dengan penambahan cross-encoder reranking (`jinaai/jina-reranker-v2-base-multilingual`). Tanpa reranking, Precision@3 = **0,85** dan MRR@5 = **0,86**; dengan reranking, Precision@3 = **0,90** dan MRR@5 = **0,90** (Δ Precision@3 = **+0,05**). Evaluasi dijalankan dengan `scripts/reproduce_rerank_ablation.py` setelah `setup_eval_collection.py`.

### Performa HTTP (jika ganti tabel throughput)

> Pengujian beban menggunakan Locust (KOL-42) terhadap endpoint `/api/*` dengan autentikasi Bearer. Pada skenario [sebutkan: users, durasi, tanggal], endpoint analisis engagement mencapai [X] RPS dengan latensi rata-rata [Y] ms (berkas `tests/load/results/...csv`). Angka ini mencerminkan tumpukan HTTP lengkap, berbeda dari pengujian mikro komponen NLP berbasis pytest-benchmark.

### Cakupan pytest (ganti paragraf L99)

> Pada [tanggal], pytest mengumpulkan [N] tes dengan [P] lulus dan [F] gagal; cakupan modul `app` mencapai [C]% (`pytest --cov=app`). Peningkatan jumlah tes dibandingkan baseline pengembangan awal mencerminkan penambahan pengujian integrasi, keamanan, dan RAG tanpa mengurangi cakupan komponen kritis.

---

## Fase 4 — Lampiran / traceability (opsional tapi kuat untuk sidang)

Satu halaman **“Lampiran A — Jejak Perintah Pengujian”**:

| Uji | Perintah | Output |
|-----|----------|--------|
| Cakupan | `pytest --cov=app` | terminal / `htmlcov/` |
| RAG 20 query | `python scripts/run_rag_evaluation.py` | `rag_evaluation_results.md` |
| Rerank A/B | `python scripts/reproduce_rerank_ablation.py` | `rerank_ablation_*.json` |
| Performa HTTP | `python scripts/reproduce_ta_benchmarks.py` | `reproduction_*.json` |
| Beban | `cd tests/load && python run_load_test.py --scenario smoke` | `results/*.csv` |
| Logic Listener | `tests/test_integration/logic_listener_*.py` | `data/evaluation/*.json` |

Tidak perlu file benchmark baru — ini **indeks** ke yang sudah ada.

---

## Fase 5 — Checklist “siap sidang”

- [x] Fase 0 snapshot — `docs/evidence/bab4/PHASE0_SNAPSHOT_2026-06-12.md`
- [x] Fase 2 lengkap — `bab4.tex` 2026-06-12 (dua putaran); lihat `docs/evidence/bab4/PHASE2_CHANGELOG.md`
- [x] Matriks Fase 1 — aksi selesai untuk semua item sensitif (lihat `PHASE5_CHECKLIST.md`)
- [x] Angka performa/RPS/rerank hanya dari repro JSON atau reframed
- [x] `tab:test_env` — macOS Juni 2026
- [x] Keterbatasan Bab 4 selaras target Bab 3 (100 kueri, 50 user, 500 ms LLM)
- [x] Bukti di `docs/evidence/bab4/` + Lampiran A di `latex-documents/TA/lampiran/`
- [ ] Dosen/pembimbing: satu putaran review

---

## Ringkasan: apa yang **tidak** perlu dilakukan

- Membuat skrip benchmark baru (sudah cukup: repro TA, rerank ablation, locust, pytest-benchmark).
- Menghapus seluruh § performa — cukup **perbaiki sumber angka** atau **batasi klaim**.
- Mengubah Bab 1–3 kecuali referensi silang ke angka Bab 4 (cek setelah edit).

---

## Prioritas jika waktu terbatas (minimum viable alignment)

1. **UPDATE** pytest totals + coverage (`tab:test_coverage`).
2. **UPDATE** rerank subsection (0,85 → 0,90, model Jina).
3. **REFRAME** § throughput: hapus 433/673 atau ganti dari satu run Locust terdokumentasi.
4. **KEEP** RAG 20-query tables + 66/50 tests + Logic Listener dengan caveat.

Setelah minimum ini, naskah **jujur secara metodologis** dan **terlacak ke repo** tanpa harness tambahan.