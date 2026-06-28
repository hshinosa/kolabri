# Kolabri — Full Project Inspection

**Generated:** 2026-05-17  
**Scope:** `Kolabri-core-api`, `Kolabri-ai-engine`, `docs/`  
**Method:** Manual deep inspection via parallel file reads

> **Update 2026-05-17 (end of day):** Semua open issues AI Engine dari inspeksi ini sudah diselesaikan. Lihat [`AI_ENGINE_IMPLEMENTATION_REPORT.md`](./AI_ENGINE_IMPLEMENTATION_REPORT.md) untuk detail lengkap. Semua gap TA (ChromaDB→Qdrant, embedding, LLM provider) sudah resolved — lihat [`TA_ALIGNMENT_PLAN.md`](./TA_ALIGNMENT_PLAN.md). Core API issues sudah diselesaikan — lihat [`CORE_API_IMPLEMENTATION_REPORT.md`](./CORE_API_IMPLEMENTATION_REPORT.md).

---

## Arsitektur Keseluruhan

3-service microservices dengan separation of concerns yang jelas:

```
┌─────────────────────────────────────────┐
│  Client App (Laravel 12 + React 19)     │
│  Port 8000 — BFF + UI Layer             │
└──────────────────┬──────────────────────┘
                   │ proxy
┌──────────────────▼──────────────────────┐
│  Core API (Express + TypeScript)        │
│  Port 3000 — Central Coordination       │
└──────────┬──────────────────────────────┘
           │ CORE_API_SECRET
┌──────────▼──────────────────────────────┐
│  AI Engine (FastAPI + Python)           │
│  Port 8001 — AI/RAG/NLP Layer           │
└──────────┬──────────────────────────────┘
           │
  ┌────────┴──────────────────────────────┐
  │         │              │              │
PostgreSQL  MongoDB      Qdrant         Redis
  :5432     :27017        :6333          :6379
(Prisma)  (Motor async) (Vector DB)   (Cache)
```

---

## 1. Kolabri-core-api

### Tech Stack

- **Framework:** Express 4 + TypeScript 5.7
- **ORM:** Prisma 6 (PostgreSQL)
- **ODM:** Mongoose 8 (MongoDB)
- **Real-time:** Socket.IO 4
- **Auth:** JWT + bcrypt
- **Validation:** Zod
- **Security:** helmet, express-rate-limit
- **Multi-provider AI:** OpenAI SDK + Google Generative AI + Anthropic SDK
- **Testing:** Vitest 2

### Struktur Folder

```
src/
├── app.ts                  # Express app setup, middleware chain
├── server.ts               # HTTP server + Socket.IO + WebSocket init
├── config/                 # database.ts, redis.ts, logger.ts
├── controllers/            # 14 controllers
├── services/               # 18+ services
├── routes/                 # 17 route files
├── middleware/             # auth, role, validate, errorHandler, rateLimiter, logger
├── models/                 # Mongoose models (ChatLog, SilenceEvent, dll)
├── socket/                 # Socket.IO handler
├── types/                  # TypeScript type definitions
├── utils/                  # Utilities
├── validators/             # Zod validators
└── websocket/              # WebSocket handler
```

### Controllers yang Sudah Diimplementasikan (14)

| Controller | Fungsi |
|---|---|
| `auth.controller.ts` | Login, register, logout, JWT |
| `course.controller.ts` | Lecturer CRUD course, student enrollment |
| `course-admin.controller.ts` | Admin course management |
| `group.controller.ts` | Group management, join code |
| `chatSpace.controller.ts` | Chat space lifecycle (close/reopen) |
| `goal.controller.ts` | Student learning goal per chat space |
| `reflection.controller.ts` | Reflection submission |
| `aiChat.controller.ts` | Personal AI chat sessions |
| `analytics.controller.ts` | Lecturer analytics dashboard |
| `dashboard.controller.ts` | Role-based dashboard routing |
| `user.controller.ts` | User management |
| `ai-provider.controller.ts` | Admin AI provider config |
| `admin-ai.controller.ts` | Admin AI settings |
| `audit-log.controller.ts` | Admin audit trail |

### Services yang Sudah Diimplementasikan (18+)

| Service | Fungsi |
|---|---|
| `auth.service.ts` | Auth logic, token management |
| `course.service.ts` | Course business logic |
| `course-admin.service.ts` | Admin course operations |
| `group.service.ts` | Group management logic |
| `chatSpace.service.ts` | Chat space lifecycle |
| `goal.service.ts` | Learning goal management |
| `reflection.service.ts` | Reflection handling |
| `aiChat.service.ts` | Personal AI chat |
| `knowledgeBase.service.ts` | Document upload/management |
| `analytics.service.ts` | Analytics computation |
| `chatAnalytics.service.ts` | Chat-specific analytics |
| `aiEngine.service.ts` | **Proxy ke AI Engine** (semua AI calls) |
| `dashboard.service.ts` | Dashboard data aggregation |
| `user.service.ts` | User CRUD |
| `ai-provider.service.ts` | AI provider config |
| `audit-log.service.ts` | Audit trail logging |
| `usage-tracking.service.ts` | AI usage tracking |
| `ai.service.ts` | AI abstraction layer |

### Routes (17 file)

`auth`, `course`, `course-admin`, `course-template`, `group`, `chatSpace`, `goal`, `reflection`, `aiChat`, `analytics`, `dashboard`, `user`, `ai-provider`, `admin-ai`, `audit-log`, `health`, `health.routes.test`

### Prisma Schema — Model yang Sudah Ada

| Model | Keterangan |
|---|---|
| `User` | 3 roles: student, lecturer, admin |
| `Course` | Dengan join code, archive support |
| `CourseTemplate` | Template untuk bulk course creation |
| `CourseStudent` | Enrollment junction table |
| `Group` | Group per course, dengan join code |
| `GroupMember` | Member junction table |
| `ChatSpace` | Multiple chat spaces per group |
| `LearningGoal` | Student goal per chat space |
| `Reflection` | Reflection submission |
| `KnowledgeBase` | Document metadata |
| `ChatMessage` | Chat message records |
| `AiChat` | Personal AI chat sessions |
| `AiUsage` | AI usage tracking per user/course |
| `AiModelComparison` | Model comparison logs |
| `AuditLog` | Admin audit trail |

Semua model sudah memiliki index yang proper (`@@index`).

### Socket.IO — Sudah Diimplementasikan

File: `src/socket/index.ts`

- Real-time group chat dengan room management
- Silence detection timer: **10 menit**
- HOT keyword detection (Bahasa Indonesia + English)
- Engagement classification: cognitive / behavioral / emotional
- AI intervention trigger: setiap **5 pesan**, cooldown **3 menit**
- Quality thresholds: HOT < 20%, cognitive < 25%, lexical < 25%
- Online user tracking per room

### Testing — Core API

| Tipe | Jumlah | Status |
|---|---|---|
| Unit tests | 22 | ✅ Passing |
| Integration tests | 78 (6 file) | ✅ All passing |
| **Total** | **100** | ✅ |

Integration test files:
- `aiChat.integration.test.ts` — 13 tests (AI Chat lifecycle, provider branching)
- `chatSpace.integration.test.ts` — 15 tests (close/reopen, reflection)
- `goal.integration.test.ts` — 10 tests (Bloom validation, duplicate handling)
- `knowledgeBase.integration.test.ts` — 12 tests (PDF upload, batch, AI Engine ingestion)
- `analytics.integration.test.ts` — 8 tests (engagement analysis, export)
- `socket.integration.test.ts` — 20 tests (Socket.IO contracts, quality thresholds)

---

## 2. Kolabri-ai-engine

### Tech Stack

- **Framework:** FastAPI 0.115+ + Uvicorn
- **LLM:** OpenAI-compatible API → DeepSeek V4 Flash (bukan Gemini)
- **Vector DB:** Qdrant (Docker, port 6333)
- **Embedding:** `paraphrase-multilingual-MiniLM-L12-v2` via FastEmbed — **384 dimensi** (lokal, bukan Google)
- **Document Processing:** PyPDF, PyMuPDF, python-docx, python-pptx
- **Caching:** Redis
- **Logging:** MongoDB via Motor (async)
- **Monitoring:** Prometheus client
- **Rate Limiting:** slowapi

### Struktur Folder

```
app/
├── api/
│   ├── routes.py              # 14 API endpoints
│   ├── batch_routes.py        # Batch processing endpoints
│   └── schemas.py             # Pydantic request/response models
├── core/
│   ├── config.py              # Pydantic settings
│   ├── logging.py             # structlog setup
│   ├── prompt_templates.py    # LLM prompt templates
│   ├── prompt_styles.py       # Scaffolding styles
│   ├── circuit_breaker.py     # Fault tolerance
│   ├── guardrails.py          # Multi-layer safety checks
│   ├── redis_cache.py         # Cache layer
│   └── cache_analyzer.py      # Cache metrics
├── services/                  # 33 service files
├── middleware/
└── utils/
```

### API Endpoints yang Sudah Diimplementasikan (14, semua verified)

| Method | Path | Fungsi |
|---|---|---|
| GET | `/api/health` | Health check |
| POST | `/api/ask` | RAG query (untuk @AI mention di group chat) |
| POST | `/api/ingest` | Ingest single document |
| POST | `/api/ingest/batch` | Batch document ingestion |
| DELETE | `/api/documents/{id}` | Hapus dokumen dari vector store |
| POST | `/api/intervention/analyze` | Cek apakah group butuh intervensi |
| POST | `/api/intervention/summary` | Generate summary diskusi |
| POST | `/api/intervention/prompt` | Generate intervention prompt |
| POST | `/api/chat/personal` | Personal AI chat |
| POST | `/api/chat/personal/stream` | SSE streaming personal chat |
| POST | `/api/chat` | Orchestrated chat (Teacher-AI loop) |
| GET | `/api/analytics/group/{id}` | Group analytics |
| POST | `/api/analytics/engagement` | Engagement analysis |
| GET | `/api/analytics/export` | Process mining data export |

### Services yang Sudah Diimplementasikan (33 file)

#### RAG & Document Processing
| Service | Fungsi |
|---|---|
| `rag.py` | RAG pipeline: retrieve → rerank → generate |
| `vector_store.py` | Qdrant operations (CRUD collections) |
| `embeddings.py` | FastEmbed embedding service |
| `reranker.py` | Result reranking |
| `document_processor.py` | Parse PDF, DOCX, PPTX (+ OCR) |
| `rag_quality.py` | RAG quality metrics |
| `rag_benchmark_bootstrap.py` | RAG benchmark setup |
| `rag_benchmark_runner.py` | RAG benchmark execution |

#### LLM
| Service | Fungsi |
|---|---|
| `llm.py` | LLM service (OpenAI-compatible + Gemini legacy) |
| `batch_llm.py` | Batch inference untuk high throughput |

#### Orchestration & Intervention
| Service | Fungsi |
|---|---|
| `orchestration.py` | **Teacher-AI Complementarity loop** — central coordinator |
| `intervention.py` | Intervention logic (analyze, generate) |
| `goal_validator.py` | Bloom's taxonomy validation & refinement |

#### NLP Analytics
| Service | Fungsi |
|---|---|
| `nlp_analytics.py` | HOT detection, TTR/lexical variety, engagement classification |
| `srl_classifier.py` | SRL (Self-Regulated Learning) classification |
| `socratic_filter.py` | Socratic questioning filter |
| `logic_listener.py` | Real-time monitoring: off-topic, silence, participation inequity |

#### Safety & Security
| Service | Fungsi |
|---|---|
| `guardrails.py` (core) | Multi-layer safety checks |
| `toxicity_scorer.py` | Content safety scoring |
| `injection_detector.py` | Prompt injection detection |
| `pii_detector.py` | PII masking |
| `grounding_verifier.py` | Answer grounding verification |

#### Process Mining
| Service | Fungsi |
|---|---|
| `process_mining_anomaly.py` | Anomaly detection |
| `conformance_checker.py` | Process conformance checking |
| `plan_vs_reality.py` | Plan vs reality analysis |
| `xes_exporter.py` | XES format export (ProM/Disco compatible) |
| `export_service.py` | Data export orchestration |

#### Infrastructure
| Service | Fungsi |
|---|---|
| `circuit_breaker.py` | Fault tolerance (services layer) |
| `redis_cache.py` (core) | Cache layer |
| `cache_analyzer.py` (core) | Cache metrics |
| `mongodb_logger.py` | MongoDB async logging |
| `monitoring.py` | Prometheus metrics |
| `notification_service.py` | Push notification ke Core API |
| `efficiency_guard.py` | Resource efficiency guard |

### Background Task

`main.py` menjalankan `silence_monitor_task()` sebagai background task:
- Polling setiap **60 detik**
- Deteksi group yang silent
- Push intervention ke Core API via `notification_service`

### Testing — AI Engine

| Tipe | Jumlah File | Jumlah Tests | Coverage |
|---|---|---|---|
| Unit tests | 88 file | ~2.195 | 98.86% |
| Integration tests | 7 file | 14 | — |
| E2E scenarios | — | 21 | — |
| Security tests | ada | — | — |
| Benchmark tests | ada | — | — |
| Load tests | ada | — | — |
| **Total** | **100+** | **~2.209** | **98.86%** |

Unit test coverage per domain (88 file di `tests/test_unit/`):
- RAG: rag, rag_full, rag_comprehensive, rag_simple, rag_token, rag_quality, rag_accuracy, rag_benchmark_*
- LLM: llm, llm_comprehensive, llm_expanded, llm_fixed
- Vector store: vector_store, vector_store_full, vector_store_comprehensive, vector_store_extra
- NLP: nlp_analytics, nlp_analytics_full, nlp_analytics_comprehensive, logic_listener, logic_listener_full, srl_classifier, socratic_filter
- Safety: guardrails, toxicity_scorer, injection_detector, pii_detector, grounding_verifier
- Process mining: process_mining_anomaly, conformance_checker, plan_vs_reality, xes_exporter
- Infrastructure: circuit_breaker, redis_cache, cache_analyzer, mongodb_logger, monitoring

---

## 3. Docs — Tracking yang Sudah Ada (11 file setelah ini)

| File | Tanggal | Isi |
|---|---|---|
| `PROJECT_INSPECTION_REPORT.md` | 2026-05-11 | Architecture overview, component breakdown |
| `CODE_INSPECTION_REPORT.md` | 2026-05-11 | Deep inspection 3 services |
| `CORE_API_INSPECTION_DETAIL.md` | 2026-05-11 | Core API detailed structure |
| `INTEGRATION_VERIFICATION.md` | 2026-05-11 | Endpoint mapping Core API ↔ AI Engine, semua verified |
| `INTEGRATION_TEST_CHECKPOINT.md` | 2026-05-11 | 92 integration tests, all passing |
| `KOLABRI_OBSERVATIONS_ACTION_ITEMS.md` | 2026-05-11 | Action items per service |
| `KOLABRI_SEVERITY_BASED_OBSERVATIONS.md` | 2026-05-11 | Issues dikelompokkan by severity |
| `TA_ALIGNMENT_PLAN.md` | — | Gap analysis TA vs implementasi aktual |
| `TA_FINAL_REVIEW_CONTEXT.md` | — | State thesis terakhir (66 hal, compile clean) |
| `TA_FINAL_HOSTILE_REVIEW.md` | — | Hostile review dari sudut pandang penguji |
| `AI_ENGINE_SCOPE_BOUNDARIES.md` | 2026-05-17 | Batasan scope AI Engine untuk development lanjutan |

---

## 4. Observasi Kritis

### Yang Sudah Solid ✅

- Separation of concerns antar 3 service sangat jelas
- AI Engine punya test coverage luar biasa: **98.86%, 2.209 tests**
- Semua 14 endpoint Core API ↔ AI Engine sudah verified dan passing
- Socket.IO real-time sudah fully implemented dengan intervention logic
- Prisma schema lengkap dan well-indexed (15 model)
- Multi-layer safety: guardrails + toxicity + injection detection + PII + grounding verifier
- Process mining sudah ada: XES export, conformance checking, anomaly detection
- Circuit breaker sudah ada di level service

### Gap TA vs Implementasi (dari `TA_ALIGNMENT_PLAN.md`) 🔧

| Gap | TA Bilang | Aktual | File yang Perlu Diupdate |
|---|---|---|---|
| Vector DB | ChromaDB | **Qdrant** | bab1, bab2, bab3, bab5 |
| Embedding | Google text-embedding-004, 768 dim | **FastEmbed multilingual, 384 dim** | bab2, bab3 |
| LLM Provider | Google Gemini 2.0 Flash | **OpenAI-compatible API, DeepSeek V4 Flash** | bab3 |

### Issues Open (dari `KOLABRI_SEVERITY_BASED_OBSERVATIONS.md`)

#### Core API — High Priority
1. Input validation belum konsisten di semua endpoint
2. Error handling belum seragam antar controller
3. Rate limiting belum merata di semua route sensitif
4. Beberapa controller terlalu tebal (business logic di controller)

#### Client App — High Priority
1. Fat controllers Laravel (business logic di controller)
2. Duplikasi pola proxy ke Core API di banyak controller
3. Tidak ada component test React yang sistematis

#### AI Engine — Thesis Risk
1. **Logic Listener belum ilmiah** — tidak ada precision/recall/gold standard, masih fungsional saja
2. **H1 evidence kecil** — klaim RAG meningkatkan relevansi hanya dibuktikan dengan sedikit query real-data

---

## 5. Risiko Sidang TA (dari `TA_FINAL_HOSTILE_REVIEW.md`)

Empat titik serangan utama penguji:

| # | Risiko | Severity |
|---|---|---|
| 1 | Jarak metodologi Bab 3 vs hasil aktual Bab 4 | High |
| 2 | Klaim H1 terlalu kuat untuk jumlah query real-data yang kecil | High |
| 3 | Coverage 98% ≠ bukti ilmiah (itu software quality, bukan research validation) | High |
| 4 | Logic Listener belum ada precision/recall/gold standard | High |

**Thesis state terakhir:** 66 halaman, compile clean, no LaTeX errors.  
**Verdict:** Implementasi credibility kuat. Research-method rigor masih attackable di beberapa section.

---

## Referensi

- [AI_ENGINE_SCOPE_BOUNDARIES.md](./AI_ENGINE_SCOPE_BOUNDARIES.md)
- [TA_ALIGNMENT_PLAN.md](./TA_ALIGNMENT_PLAN.md)
- [TA_FINAL_HOSTILE_REVIEW.md](./TA_FINAL_HOSTILE_REVIEW.md)
- [INTEGRATION_VERIFICATION.md](./INTEGRATION_VERIFICATION.md)
- [INTEGRATION_TEST_CHECKPOINT.md](./INTEGRATION_TEST_CHECKPOINT.md)
