# AI Engine — Scope & Boundaries

**Generated:** 2026-05-17  
**Scope:** Kolabri-ai-engine (`/Kolabri-ai-engine/`)  
**Purpose:** Mendefinisikan batasan pengembangan AI Engine agar development lanjutan tidak keluar dari scope thesis dan arsitektur sistem.

---

## 1. Batasan Interface (Siapa yang Boleh Memanggil)

**Hanya Core API yang boleh memanggil AI Engine.** Semua endpoint dilindungi `CORE_API_SECRET`. Client App tidak pernah memanggil AI Engine secara langsung.

Satu-satunya komunikasi balik yang diizinkan adalah AI Engine → Core API via `notification_service` (push intervention ke Socket.IO).

```
Client App  →  Core API  →  AI Engine
                ↑               |
                └───────────────┘  (notification push only)
```

> **Pelanggaran scope:** Jika ada fitur baru yang membutuhkan AI Engine dipanggil langsung dari browser atau Client App — itu keluar dari scope.

---

## 2. Batasan Tanggung Jawab

### Yang Menjadi Tanggung Jawab AI Engine

| Domain | Deskripsi |
|---|---|
| **RAG Pipeline** | Ingest dokumen, chunking, embedding, retrieval, reranking, answer generation |
| **LLM Calls** | Semua panggilan ke LLM API hanya lewat AI Engine — tidak ada service lain yang boleh call LLM langsung |
| **NLP Analytics** | HOT detection, TTR/lexical variety, engagement classification (cognitive / behavioral / emotional) |
| **Intervention** | Analyze, generate prompt/summary, trigger logic |
| **Orchestration** | Teacher-AI Complementarity loop |
| **Process Mining** | XES export, conformance checking, anomaly detection, plan vs reality analysis |
| **Safety Layer** | Guardrails, toxicity scoring, injection detection, PII masking, grounding verification |
| **Goal Validation** | Bloom's taxonomy validation dan refinement |
| **Logic Listener** | Off-topic detection, silence detection, participation inequity detection |
| **Storage** | Qdrant collections (per course), MongoDB event logs, Redis cache |

### Yang BUKAN Tanggung Jawab AI Engine

| Domain | Pemilik yang Benar |
|---|---|
| User auth / authorization | Core API |
| Course, group, user data management | Core API (PostgreSQL via Prisma) |
| Chat message persistence | Core API (MongoDB ChatLog) |
| Real-time Socket.IO | Core API |
| File storage / serving | Core API |
| Session management | Client App |
| UI rendering | Client App |

---

## 3. Batasan Data Ownership

AI Engine hanya memiliki tiga storage:

```
Qdrant     → vector embeddings, diorganisir per course
               collection naming: course_{course_id}

MongoDB    → event logs: intervention logs, analytics logs,
               process mining events (via Motor async driver)

Redis      → LLM response cache, embedding cache
```

AI Engine **tidak boleh menulis langsung ke PostgreSQL**. PostgreSQL adalah domain Core API via Prisma. Jika ada fitur baru yang membutuhkan AI Engine menyimpan data ke PostgreSQL, data tersebut harus dikirim ke Core API terlebih dahulu, bukan diakses langsung.

---

## 4. Batasan Teknologi

Tech choices berikut sudah terikat ke naskah TA (bab 2 dan bab 3). Jangan diganti tanpa update TA terlebih dahulu.

| Komponen | Pilihan Saat Ini | Jangan Diganti Ke |
|---|---|---|
| Vector DB | **Qdrant** (Docker, port 6333) | ChromaDB, Pinecone, Weaviate |
| Embedding Model | **`paraphrase-multilingual-MiniLM-L12-v2`** via FastEmbed, 384 dimensi | Google text-embedding-004, OpenAI embeddings |
| LLM Provider | **OpenAI-compatible API** (DeepSeek V4 Flash) | Direct Gemini SDK, Anthropic SDK |
| Framework | **FastAPI** + Uvicorn | Flask, Django |
| Async DB Driver | **Motor** (MongoDB async) | PyMongo sync |
| Language | **Python 3.11+** | — |

> Jika salah satu dari ini perlu diganti, update minimal `bab2.tex` dan `bab3.tex` di naskah TA sebelum melanjutkan development.

---

## 5. Batasan Fitur

### In Scope — Boleh Dikembangkan

- Improve RAG quality: chunking strategy, hybrid search, reranking algorithm
- Improve NLP analytics: akurasi HOT detection, engagement classifier
- Tambah intervention type baru (selain `off_topic`, `silence`, `participation_inequity`)
- Improve process mining analysis
- Improve safety layer (guardrails, grounding verifier)
- Optimize performance: caching strategy, batch processing
- **Tambah precision/recall measurement untuk Logic Listener** — ini justru dibutuhkan untuk memperkuat thesis defense

### Out of Scope — Jangan Masuk ke AI Engine

- User role management atau permission logic
- Course / group lifecycle management
- File storage management
- Autentikasi end-user (JWT validation sudah di Core API)
- Fitur yang tidak ada hubungannya dengan AI/ML/NLP computation

---

## 6. Batasan Thesis Scope

Thesis hanya mengklaim kontribusi di **AI Engine**. Bukan Core API, bukan Client App.

Setiap fitur baru yang dikembangkan di AI Engine harus bisa menjawab pertanyaan:

> *"Apakah fitur ini mendukung atau setidaknya tidak melemahkan klaim penelitian di Bab 1–3?"*

### Klaim Utama yang Harus Didukung

| Klaim | Status | Catatan |
|---|---|---|
| RAG meningkatkan relevansi jawaban (H1) | Perlu bukti kuantitatif | Setiap improvement RAG harus bisa diukur: precision, recall, atau MRR |
| NLP analytics mendeteksi kualitas diskusi | Fungsional, belum ilmiah | Logic Listener butuh gold standard + precision/recall sebelum sidang |
| Sistem intervensi otomatis berjalan | Sudah ada | Perlu evaluasi skenario yang lebih kuat |
| Guardrails menekan risiko halusinasi | Sudah ada | Framing hati-hati — jangan klaim "100% grounding" |

### Risiko Sidang yang Harus Diantisipasi

1. **H1 evidence terlalu kecil** — jika hanya dibuktikan dengan sedikit query real-data, penguji akan menyerang
2. **Logic Listener belum ilmiah** — tidak ada precision/recall/gold standard, masih fungsional saja
3. **Coverage ≠ validasi ilmiah** — 98.86% coverage adalah bukti software quality, bukan research validation
4. **Metodologi Bab 3 melebihi eksekusi Bab 4** — jangan tambah klaim baru di Bab 3 tanpa eksekusi yang matching

---

## 7. Checklist Sebelum Menambah Fitur Baru

Sebelum menambahkan fitur baru ke AI Engine, jawab semua pertanyaan berikut:

- [ ] Apakah fitur ini adalah computation / AI / ML / NLP? (bukan data management)
- [ ] Apakah fitur ini dipanggil dari Core API, bukan langsung dari Client App?
- [ ] Apakah fitur ini tidak membutuhkan akses langsung ke PostgreSQL?
- [ ] Apakah fitur ini tidak mengubah tech stack yang sudah terikat ke TA?
- [ ] Apakah fitur ini mendukung atau setidaknya tidak melemahkan klaim thesis?
- [ ] Apakah ada test yang bisa memverifikasi fitur ini? (target coverage tetap ≥ 98%)

Jika ada satu jawaban "tidak" — evaluasi ulang sebelum lanjut.

---

## Referensi

- [PROJECT_INSPECTION_REPORT.md](./PROJECT_INSPECTION_REPORT.md) — Architecture overview
- [TA_ALIGNMENT_PLAN.md](./TA_ALIGNMENT_PLAN.md) — Gap analysis TA vs implementasi
- [TA_FINAL_HOSTILE_REVIEW.md](./TA_FINAL_HOSTILE_REVIEW.md) — Risiko sidang
- [INTEGRATION_VERIFICATION.md](./INTEGRATION_VERIFICATION.md) — Endpoint mapping Core API ↔ AI Engine
