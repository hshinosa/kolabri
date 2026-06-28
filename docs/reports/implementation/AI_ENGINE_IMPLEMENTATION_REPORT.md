# AI Engine — Implementation Report

> **Catatan (Juni 2026):** Angka tes di bawah adalah snapshot **Mei 2025**. Verifikasi TA terbaru: **2411 passed / 2414 collected**, **99,92%** cov — lihat `evidence/bab4/PHASE0_SNAPSHOT.md`.

**Date**: 2026-05-17  
**Status**: ✅ Complete *(konten historis Mei 2025)*  
**Test Results**: 2.209 unit tests (98.86% coverage) + 5 evaluation tests (all passing) *(→ 2411 / 99,92% post-repro)*  
**OpenSpec Changes**: 2  

---

## Overview

Dua OpenSpec changes dikerjakan untuk memperkuat kualitas ilmiah AI Engine dan mempersiapkan bukti evaluasi untuk sidang TA. Fokus utama: (1) validasi Logic Listener dengan gold standard dataset dan precision/recall, (2) evaluasi kuantitatif RAG dengan baseline comparison RAG vs no-RAG.

---

## Change 1: `logic-listener-scientific-validation`

**Issue**: Logic Listener hanya bisa dibuktikan secara fungsional — tidak ada gold standard, precision, recall, atau F1-score. Rentan diserang penguji sidang.

### Yang dikerjakan

**Task 1 — Gold Standard Dataset:**
- Buat `data/evaluation/logic_listener_gold_standard.json`: 30 item berlabel
- Distribusi: 10 item per intervention type (off_topic, silence, participation_inequity)
- Setiap type: 5 positive (harus intervensi) + 5 negative (tidak perlu)
- Setiap item memiliki `labeling_rationale` yang menjelaskan alasan label

**Task 2 — Evaluation Harness:**
- Buat `tests/test_unit/test_logic_listener_evaluation.py`: 5 tests
- `make_mock_embedding_service()`: mock dengan vektor ortogonal (off-topic) vs identik (on-topic)
- `evaluate_off_topic()`: inject mock embedding, jalankan `check_relevance` per message
- `evaluate_silence()`: inject `_last_message_timestamp` langsung, jalankan `check_silence`
- `evaluate_participation_inequity()`: inject `_participation_counts` langsung, jalankan `check_participation_inequity`
- `compute_metrics()`: hitung precision, recall, F1 dari TP/FP/FN
- `print_evaluation_table()`: cetak tabel hasil dalam format yang bisa dikutip ke TA

**Task 3 — Pytest Integration:**
- Tambah marker `evaluation` ke `pyproject.toml`
- Semua test ditandai `@pytest.mark.evaluation`

**Task 4 — Dokumentasi Hasil:**
- Simpan hasil ke `data/evaluation/results.md` dengan tabel LaTeX siap paste ke `bab4.tex`

### Hasil Evaluasi

| Tipe Intervensi | Precision | Recall | F1-Score |
|---|---|---|---|
| Off-Topic Detection | 1.00 | 1.00 | 1.00 |
| Silence Detection | 1.00 | 1.00 | 1.00 |
| Participation Inequity | 1.00 | 1.00 | 1.00 |
| **Macro Average** | **1.00** | **1.00** | **1.00** |

> F1=1.0 karena silence dan participation inequity bersifat deterministik (threshold-based), dan off-topic dievaluasi dengan mock embedding yang dikontrol — memverifikasi logika threshold dan counter, bukan akurasi embedding model.

### Files changed

| File | Tipe | Keterangan |
|---|---|---|
| `data/evaluation/logic_listener_gold_standard.json` | New | 30 item gold standard dataset |
| `tests/test_unit/test_logic_listener_evaluation.py` | New | Evaluation harness, 5 tests |
| `data/evaluation/results.md` | New | Hasil evaluasi + tabel LaTeX |
| `pyproject.toml` | Modified | Tambah marker `evaluation` |

---

## Change 2: `ai-engine-quality-improvements`

**Issue**: Tiga improvement independen — threshold hardcoded, reranker perlu observability, RAG belum pernah dievaluasi formal dengan baseline comparison.

### 2a. Threshold Consolidation

**Yang dikerjakan:**
- Tambah 3 setting baru ke `app/core/config.py` dalam section `# Logic Listener Thresholds`:
  - `LOGIC_LISTENER_OFF_TOPIC_SIMILARITY_THRESHOLD: float = 0.6`
  - `LOGIC_LISTENER_OFF_TOPIC_CONSECUTIVE_THRESHOLD: int = 3`
  - `LOGIC_LISTENER_PARTICIPATION_INEQUITY_THRESHOLD: float = 0.6`
- Hapus `GINI_THRESHOLD` (diganti nama ke `LOGIC_LISTENER_PARTICIPATION_INEQUITY_THRESHOLD`)
- Update `LogicListener.__init__` untuk membaca dari `settings.*` bukan class constants
- Hapus 4 class constants dari `LogicListener`: `OFF_TOPIC_SIMILARITY_THRESHOLD`, `OFF_TOPIC_CONSECUTIVE_THRESHOLD`, `SILENCE_THRESHOLD_MINUTES`, `PARTICIPATION_INEQUITY_THRESHOLD`
- Update semua referensi ke instance variables lowercase
- Fix `orchestration.py`: `settings.GINI_THRESHOLD` → `settings.LOGIC_LISTENER_PARTICIPATION_INEQUITY_THRESHOLD`
- Fix `tests/test_unit/test_orchestration_coverage.py`: update mock settings
- Fix `tests/test_unit/test_logic_listener.py`: update 5 referensi class constants → instance variables

**Files changed:**
- `app/core/config.py`
- `app/services/logic_listener.py`
- `app/services/orchestration.py`
- `tests/test_unit/test_logic_listener.py`
- `tests/test_unit/test_orchestration_coverage.py`

### 2b. Reranker Observability

**Yang dikerjakan:**
- Tambah field `reranker_enabled: bool = False` ke `HealthResponse` schema di `app/api/schemas.py`
- Update `/api/health` endpoint di `app/api/routes.py` untuk menyertakan `reranker.enabled` aktual
- Update startup log di `app/services/reranker.py`: catat `reason` disabled + `install_hint`
- Update `README.md`: tech stack diupdate (Qdrant, FastEmbed, OpenAI-compatible), tambah section reranker setup

**Files changed:**
- `app/api/schemas.py`
- `app/api/routes.py`
- `app/services/reranker.py`
- `README.md`

### 2c. RAG Evaluation

**Yang dikerjakan:**
- Buat `data/evaluation/rag_evaluation_dataset.json`: 20 query akademik
  - 8 factual, 7 conceptual, 5 procedural
  - 7 easy, 8 medium, 5 hard
- Buat `scripts/setup_eval_collection.py`: ingest 20 chunks ke Qdrant `course_eval` collection
- Buat `data/evaluation/course_eval_content.txt`: dokumen akademik 7 topik (algoritma, basis data, jaringan, web, ML, OOP)
- Buat `scripts/run_rag_evaluation.py`: CLI evaluation script
  - `run_retrieval_evaluation()`: MRR@5, Precision@3
  - `run_answer_evaluation()`: keyword coverage dengan RAG context
  - `run_no_rag_evaluation()`: keyword coverage tanpa RAG (baseline)
  - `compute_per_type_metrics()`: breakdown per query type
  - `print_results_table()`: tabel perbandingan RAG vs no-RAG
  - `save_results()`: simpan ke MD + tabel LaTeX
- Jalankan evaluasi: `python scripts/run_rag_evaluation.py --save-results`

**Files changed:**
- `data/evaluation/rag_evaluation_dataset.json` *(new)*
- `data/evaluation/course_eval_content.txt` *(new)*
- `data/evaluation/rag_evaluation_results.md` *(new, auto-generated)*
- `scripts/setup_eval_collection.py` *(new)*
- `scripts/run_rag_evaluation.py` *(new)*

### Hasil Evaluasi RAG

| Tipe Kueri | MRR@5 | Precision@3 | Keyword Coverage (RAG) |
|---|---|---|---|
| Faktual | 0.75 | 0.46 | 96.9% |
| Konseptual | 1.00 | 0.86 | 96.4% |
| Prosedural | 0.90 | 0.53 | 86.0% |
| **Rata-rata** | **0.88** | **0.62** | **94.0%** |

**Perbandingan RAG vs No-RAG:**

| Metrik | Dengan RAG | Tanpa RAG | Delta |
|---|---|---|---|
| Keyword Coverage | 94.0% | 84.0% | **+10.0%** |

---

## TA Updates

Semua perubahan berikut dilakukan di `Kuliah/latex-documents/TA/`:

| File | Perubahan |
|---|---|
| `bab4.tex` | +§4.3.4 Evaluasi Logic Listener (tabel precision/recall/F1) |
| `bab4.tex` | +Tabel evaluasi kuantitatif RAG (MRR@5, P@3, Coverage per type) |
| `bab4.tex` | +Tabel perbandingan RAG vs no-RAG baseline (+10.0%) |
| `bab4.tex` | H1 validation diupdate: sebutkan +10.0 poin persentase |
| `bab4.tex` | Keterbatasan diupdate: "diperluas dari 5 ke 20 kueri" |
| `bab5.tex` | Kesimpulan poin 2 diupdate: 94.0% RAG vs 84.0% no-RAG |
| `abstrak.tex` (ID) | Ditambahkan MRR@5=0.88, Coverage 94.0% vs 84.0%, +10.0% |
| `abstrak.tex` (EN) | Sama, versi Inggris |

---

## Infrastructure Changes

| Item | Perubahan |
|---|---|
| Docker | Hapus `codebase-wiki-qdrant` dan `codebase-wiki-pgvector` |
| Docker | Buat `kolabri-qdrant` (fresh, port 6333) |
| `.env` | `OPENAI_API_KEY=sk-ama`, `OPENAI_MODEL=gpt-5.4-mini` |
| Python packages | `sentence-transformers` installed (--no-deps), `transformers` installed |

---

## New Files Created

| File | Deskripsi |
|---|---|
| `data/evaluation/logic_listener_gold_standard.json` | 30 item gold standard dataset untuk Logic Listener |
| `data/evaluation/results.md` | Hasil evaluasi Logic Listener + tabel LaTeX |
| `data/evaluation/rag_evaluation_dataset.json` | 20 query akademik untuk evaluasi RAG |
| `data/evaluation/course_eval_content.txt` | Dokumen akademik 7 topik untuk Qdrant collection |
| `data/evaluation/rag_evaluation_results.md` | Hasil evaluasi RAG + tabel LaTeX |
| `tests/test_unit/test_logic_listener_evaluation.py` | Evaluation harness Logic Listener (5 tests) |
| `scripts/setup_eval_collection.py` | Setup script: ingest dokumen ke Qdrant course_eval |
| `scripts/run_rag_evaluation.py` | CLI evaluation script: RAG vs no-RAG comparison |

---

## Test Results

| Kategori | Sebelum | Sesudah |
|---|---|---|
| Unit tests | 2.209 | 2.209 + 5 evaluation |
| Coverage | 98.86% | 98.86% (evaluation tests excluded) |
| Orchestration tests | 35 passed | 35 passed |
| Pre-existing failures | 8 (Python 3.13 asyncio) | 8 (unchanged, pre-existing) |

---

## OpenSpec Changes

Tersimpan di `Kolabri-ai-engine/openspec/changes/`:

```
logic-listener-scientific-validation/
  proposal.md, design.md, tasks.md (all ✅)
  specs/logic-listener-evaluation/spec.md
  specs/gold-standard-dataset/spec.md

ai-engine-quality-improvements/
  proposal.md, design.md, tasks.md (all ✅)
  specs/reranker-activation/spec.md
  specs/rag-evaluation/spec.md
  specs/rag-evaluation-dataset/spec.md
  specs/threshold-config/spec.md
```

---

## Known Limitations

- **Reranker masih disabled**: `sentence-transformers` terinstall tapi PyTorch tidak tersedia untuk Python 3.13 di macOS via pip. Reranker membutuhkan PyTorch untuk load cross-encoder model. Fix: install Python 3.11/3.12 atau gunakan `conda install pytorch -c pytorch`.
- **8 pre-existing test failures**: `test_logic_listener.py` menggunakan `asyncio.get_event_loop()` yang deprecated di Python 3.13. Bukan dari perubahan ini — sudah ada sebelumnya.
- **RAG evaluation collection tidak persistent**: Qdrant container `kolabri-qdrant` tidak menggunakan volume mount. Jika container restart, collection `course_eval` hilang. Re-run `python scripts/setup_eval_collection.py` untuk re-ingest.
- **`deepseek-v4-flash` broken di endpoint ini**: Model mengembalikan `content: null` dengan reasoning garbage. Gunakan `gpt-5.4-mini` yang sudah terbukti jalan.
- **RAG evaluation 20 queries**: Masih di bawah target 100 kueri yang direncanakan di Bab 3. Evaluasi dengan dataset lebih besar dan evaluator manusia masih diperlukan untuk validasi komprehensif.
