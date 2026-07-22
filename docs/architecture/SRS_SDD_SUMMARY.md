# Kolabri — Ringkasan SRS & SDD

> **Sumber:** Laporan D3 (`D3/[D3] Capstone Project Final Report and Documentation - Kolabri.docx`), naskah TA (`/Users/hshino/Kuliah/latex-documents/TA/bab/bab2.tex`–`bab3.tex`), audit kode (`docs/reports/audits/CAPSTONE_AUDIT_REPORT_2026-06-28.md`), dan repo implementasi (Kolabri-core-api, Kolabri-ai-engine, Kolabri-client-app).
> **Status:** Konsolidasi per 2026-07-20. Source of truth = kode.

---

## Bagian 1 — Software Requirements Specification (SRS)

### 1.1 Tujuan Produk

Membangun **Web Chatbot Kolaboratif (Kolabri)** berbasis AI yang memfasilitasi pembelajaran kolaboratif mahasiswa dengan dukungan SRL/CoRL/SSRL, mencegah halusinasi via RAG + Guardrails, serta menghasilkan log terstruktur untuk monitoring dosen dan Educational Process Mining (EPM).

### 1.2 Lingkup

Tiga layanan terintegrasi:
- **Client App (BFF)** — Laravel 12 + Inertia.js/React (port 8000)
- **Core API** — Node.js/TS + Prisma (PostgreSQL) + MongoDB + Redis (port 3000)
- **AI Engine** — Python/FastAPI + Qdrant (port 8001)

Infrastruktur: PostgreSQL 16, MongoDB, Redis 7, Qdrant (docker-compose).

### 1.3 Stakeholder & User Roles

| Role | Tanggung Jawab |
|---|---|
| Student | Join course/group, pre-read, goal, chat sesi, chat AI pribadi, refleksi, analytics personal |
| Lecturer | Kelola course/group/session, knowledge base, analytics, discussion health, attendance, eskalasi |
| Admin | User management, master data course, AI provider settings, usage stats, audit log |

Otorisasi: middleware role di Core API + middleware `role:student|lecturer|admin` di routes Laravel.

### 1.4 Functional Requirements (FR)

**Autentikasi & Otorisasi**
- FR-AUTH-01: Login via email/password atau Google OAuth
- FR-AUTH-02: JWT + role-based access control (3 role)
- FR-AUTH-03: Session management dengan refresh token

**Modul Student**
- FR-STU-01: Course enrollment & group join
- FR-STU-02: Pre-read completion gating sebelum join chat room (`SessionDiscussionPreReadCompletion`)
- FR-STU-03: Learning goal creation dengan validasi Bloom + AI feedback
- FR-STU-04: Chat sesi kelompok real-time (Socket.IO)
- FR-STU-05: Chat AI pribadi (RAG + guardrails)
- FR-STU-06: Session & weekly reflection submission
- FR-STU-07: Personal analytics dashboard

**Modul Lecturer**
- FR-LEC-01: CRUD course, group, session discussion
- FR-LEC-02: Knowledge base management (ingest PDF/DOCX/PPTX)
- FR-LEC-03: Lecturer dashboard (overview, group analytics, course analytics, comparison)
- FR-LEC-04: Discussion health monitoring (real-time)
- FR-LEC-05: Attendance management
- FR-LEC-06: Intervention escalation (nudge → probe → flag-lecturer → resolved)

**Modul Admin**
- FR-ADM-01: User management
- FR-ADM-02: Master data course
- FR-ADM-03: AI provider settings (CRUD, test connection, model discovery, fallback order)
- FR-ADM-04: Usage stats & audit log

**AI Engine**
- FR-AI-01: RAG pipeline (FETCH/NO_FETCH policy, retrieval Qdrant per course, rerank, grounding verify)
- FR-AI-02: Guardrails (input: injection detector, PII masking; output: socratic filter, off-topic)
- FR-AI-03: Logic Listener (silence detection, dominance via Gini, off-topic, SRL phase classification)
- FR-AI-04: Intervention generation (NLG, async via background task)
- FR-AI-05: Discussion summary generation
- FR-AI-06: Goal validation & feedback
- FR-AI-07: Analytics NLP (engagement, HOT, lexical variety)

**Real-time & Logging**
- FR-RT-01: Socket.IO dengan Redis adapter, presence room
- FR-RT-02: Silence lock di Redis (timeout 10 menit)
- FR-LOG-01: Transactional logging ke MongoDB (ChatLog, SilenceEvent, ActivityLog)
- FR-LOG-02: AiUsage tracking (token, latency, cost)
- FR-LOG-03: XES-compatible event logs untuk EPM

### 1.5 Non-Functional Requirements (NFR)

| Kategori | Requirement |
|---|---|
| **Keamanan** | Helmet, rate limit (express-rate-limit/slowapi), JWT, role checks, XSS sanitization, injection detector, PII masking |
| **Real-time** | Socket.IO + Redis adapter; presence room; silence lock Redis (10 menit) |
| **Ketahanan AI** | Circuit breaker service, fallback order provider (admin), degraded error handling LLM; LLM timeout 10s connect + 45s read, retry 3× exponential backoff (1s/2s/4s) |
| **Observabilitas** | Winston logger, structured AI logger, AiUsage (token/latency/cost), monitoring endpoints AI Engine |
| **Kinerja chat** | Semantic cache (Redis, threshold 0.85, TTL 1 jam); dashboard cache di Core API |
| **RAG akurasi** | Faithfulness > 0.85 (target), grounding verifier, rerank (Jina v2 multilingual) |
| **Multi-tenancy** | Isolasi materi via `course_id` filter di Qdrant |
| **Skalabilitas** | Microservices, independent scaling per service |

### 1.6 Ambang Operasional (dari kode)

| Parameter | Nilai | Sumber |
|---|---|---|
| Silence timeout socket gate | 10 menit | `SILENCE_TIMEOUT_MS` Core API |
| Silence threshold AI Engine | 10 menit | `SILENCE_THRESHOLD_MINUTES` |
| Cooldown intervensi | 3 menit | interventionGate |
| Quality check interval | Setiap 5 pesan | `MESSAGES_BEFORE_CHECK` |
| Off-topic similarity threshold | 0.6 | logic_listener default |
| Consecutive off-topic | 3 | logic_listener default |
| Inequity (Gini) threshold | 0.6 (normalisasi √N, min 10 pesan) | logic_listener default |
| Eskalasi nudge | 5 menit | `nudgeAfterMs` default |
| Eskalasi probe | 10 menit | `probeAfterMs` default |
| LLM temperature (RAG) | 0.0 | `GenerasiLLM` |
| LLM max_tokens (RAG) | 2048 | `GenerasiLLM` |
| Semantic cache similarity | 0.85 | threshold cache |
| Semantic cache TTL | 1 jam | cache config |
| RAG retrieve_k / top_k | 10 / 3 | rerank config |

### 1.7 Data Model Utama

**PostgreSQL (Prisma) — entitas inti:**
- User, Course, CourseStudent, Group, GroupMember
- SessionDiscussion, SessionDiscussionPreReadCompletion, ChatMessage
- LearningGoal, Reflection
- KnowledgeBase, CourseWeek, CourseMaterial, CourseWeekMaterial
- AiChat, AiChatMessage, AiProvider, AiUsage
- EscalationState, Notification, AuditLog, ExportJob
- AttendanceSession, AttendanceRecord

**MongoDB (Mongoose/Motor) — log runtime:**
- ChatLog (pesan real-time + engagement analysis, pin, attachments)
- SilenceEvent, EscalationState (mirror runtime), ActivityLog
- Log aktivitas/intervensi AI Engine (mongodb_logger)

**Qdrant — vektor:**
- Collection `course_{id}` dengan metadata filter `course_id` (multi-tenancy)

**File storage (Client App):**
- PDF materi; metadata course weeks dan materials berada di PostgreSQL melalui Core API.

---

## Bagian 2 — Software Design Document (SDD)

### 2.1 Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────────┐
│                    Browser (React/Inertia)                   │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTP + WebSocket
┌───────────────────────────▼─────────────────────────────────┐
│  Client App (Laravel BFF, port 8000)                        │
│  - Inertia SSR + React/TS                                   │
│  - Proxy ke Core API                                        │
│  - File storage (PDF materi)                                 │
└──────────────┬────────────────────────────┬─────────────────┘
               │ REST                       │ Socket.IO
┌──────────────▼──────────────┐  ┌──────────▼─────────────────┐
│  Core API (Node/TS, 3000)   │  │  Socket.IO + Redis adapter │
│  - Prisma (PostgreSQL)      │  │  - Presence room           │
│  - MongoDB (log)            │  │  - Silence lock            │
│  - Redis (cache, lock)      │  │  - Intervention gate       │
│  - JWT auth + role MW       │  └────────────────────────────┘
└──────────────┬──────────────┘
               │ HTTP (aiEngine.service)
┌──────────────▼──────────────────────────────────────────────┐
│  AI Engine (Python/FastAPI, 8001)                           │
│  - RAG pipeline (Qdrant + rerank + grounding)               │
│  - Guardrails (input/output)                                │
│  - Logic Listener (async background task)                   │
│  - Intervention + NLG                                       │
│  - Semantic cache (Redis)                                   │
│  - MongoDB logger                                           │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Boundary Layanan

| Service | Owns | Tidak Boleh |
|---|---|---|
| Client App | UI, BFF proxy, file storage PDF | Logika AI/ML, domain business logic |
| Core API | Users, courses, groups, chat spaces, messages, goals, reflections, AI data, weeks metadata (PG), socket orchestration | Direct LLM adapters (migrated to AI Engine) |
| AI Engine | RAG, LLM, guardrails, logic listener, intervention, analytics NLP | Domain business logic, user management |

### 2.3 Alur Utama

#### 2.3.1 SRL Flow (Student)

1. Login → dashboard student
2. Masuk course → pilih group/session discussion (terikat week)
3. Pre-read materi minggu → complete (`SessionDiscussionPreReadCompletion`)
4. Buat learning goal sesi (Bloom validation + AI feedback)
5. Join room Socket.IO (server tolak jika pre-read/gate belum terpenuhi)
6. Kirim pesan → Core API simpan log → panggil AI Engine orchestration
7. Tutup sesi → generate summary → submit reflection (session/weekly)

#### 2.3.2 AI Orchestration Pipeline

1. NLP analysis pesan (engagement/HOT/lexical bila dijalankan)
2. RAG query/stream:
   - Policy FETCH/NO_FETCH
   - Retrieval Qdrant per course_id
   - Rerank (Jina v2, retrieve_k=10 → top_k=3)
   - Generasi LLM (temperature=0.0, max_tokens=2048)
   - Grounding verifier
3. Guardrails input (injection detector, PII masking) + output (socratic filter, off-topic)
4. Logging ke MongoDB
5. Logic Listener (async): off-topic, silence, participation inequity, quality
6. Intervention generation + escalation bertahap (nudge → probe → flag-lecturer → resolved)

#### 2.3.3 Eskalasi Intervention

```
new → nudge (5 menit) → probe-blocker (10 menit) → flag-lecturer → resolved
```

Cooldown antar intervensi: 3 menit. Quality check setiap 5 pesan.

### 2.4 Pipeline Pemrosesan Pesan (Algoritma)

```
Input: M (pesan), H (riwayat), G (konteks grup)
1. M_clean = SanitasiDanMaskingPII(M)
2. IF InputGuardrails(M_clean) = GAGAL → return error message
3. R, S = EksekusiRAG(M_clean, H, G.CourseID)  // jawaban + sumber
4. Background Task: JalankanLogicListenerAsync(H, G)
5. IF OutputGuardrails(R, S) = GAGAL → R = PerbaikiRespons(R)
6. LogTransaksi(M, R, S)  // XES-compatible
7. return R
```

### 2.5 Algoritma RAG

```
Input: Q (kueri), k (jumlah dok), VectorDB, ContextID
1. V_q = EmbedKueri(Q)
2. D = CariVektor(VectorDB, V_q, filter={course_id: ContextID}, top_k=k)
3. IF |D| = 0 → return "tidak ada informasi relevan"
4. Konteks = GabungDenganMetadata(D)
5. Prompt = KonstruksiPrompt(Q, Konteks)
6. A = GenerasiLLM(Prompt, temperature=0.0, max_tokens=2048)
7. IF VerifikasiGrounding(A, D) = SALAH → A = "tidak dapat berspekulasi"
8. return A, D
```

### 2.6 Algoritma Logic Listener (Async)

```
Input: L (log sesi), T_diam (ambang diam), M_SRL (model klasifikasi SRL)
1. t_akhir = AmbilWaktuPesanTerakhir(L)
2. Δt = Sekarang() - t_akhir
3. IF Δt > T_diam:
   - I = GenerateNLGSilencePrompt()
   - LogKejadian("silence", Δt)
   - PublishEvent("intervention", I)
   - return
4. Distribusi = HitungPesanPerPengguna(L)
5. Gini = HitungKetimpangan(Distribusi)
6. Gini_norm = Gini × √N_users
7. IF Gini_norm > 0.6 AND message_count > 10:
   - I = GenerateNLGDominancePrompt(Distribusi)
   - LogKejadian("dominance", Gini)
8. FOR each message m in L:
   - phase = M_SRL(m.content)  // Forethought/Performance/Reflection
   - m.phase = phase
   - LogKejadian("srl_phase", phase)
```

### 2.7 AI Provider Configuration (Database-Driven)

```
Core API (ai_providers table)
  ↓ GET /api/internal/ai-provider/active (X-Internal-Secret)
  ↓ Redis cache (TTL 5 menit)
AI Engine fetches active provider
  ↓ Fallback to env vars if fetch fails
```

Phase 2 (future): webhook invalidation + auto-failover multi-provider.

### 2.8 Endpoint Overview

**Core API:**
- Auth, users, courses, groups, sessions, chat, goals, reflections
- Analytics (student/lecturer), dashboard, discussion health
- Admin: AI providers, audit log
- Internal: `/api/internal/ai-provider/active`

**AI Engine:**
- Health & monitoring: health, metrics, circuit-breakers, reranker health
- Documents: ingest, batch ingest, delete collection
- Chat & RAG: /ask, personal chat (+stream), reading recommendations
- Orchestration: /chat, /chat/stream
- Interventions: analyze, summary, prompt
- Goals: validation/feedback
- Analytics & groups: metrics, efficiency, plan/analytics
- Discussion direction: classify-relevance, session-summary
- Admin: test-provider, providers/{provider}/models

### 2.9 Struktur Repositori

```
ProjectTA/
├── Kolabri-client-app/   # UI + BFF Laravel
├── Kolabri-core-api/     # Domain API + socket + Prisma
├── Kolabri-ai-engine/    # RAG, LLM, analytics, interventions
├── docs/                 # Arsitektur, testing, kuesioner (referensi)
├── D3/                   # Laporan capstone final + skrip
├── dev.sh, docker-compose.yml, scripts/seed-demo.sh
└── AGENTS.md
```

### 2.10 Desain Pengujian

| Jenis | Pendekatan | Tools | Target |
|---|---|---|---|
| Fungsional | Black-box | Pytest, Postman | 100% pass |
| Integrasi | Hybrid | Pytest, Docker | Semua layanan terhubung |
| Beban/Performa | Black-box | Locust, k6 | Latensi layak (skenario konkuren bertahap) |
| Keamanan | Hybrid | OWASP ZAP, Bandit | 0 kerentanan kritis |
| Akurasi RAG | White-box | Custom eval script | Faithfulness > 0.85 |
| Logic Listener | White-box | Unit tests | > 80% precision/recall |
| Code Coverage | White-box | pytest-cov | > 80% |

**Status aktual (post-alignment, Juni 2026):**
- pytest: ~2411 passed / 2414 collected, 99.92% coverage
- AI Engine E2E: 21 skenario
- RAG eval: 20 kueri gold standard, P@3 0.85 → 0.90 dengan rerank
- HTTP throughput: 67–122 RPS (engagement endpoint)

---

## Bagian 3 — Traceability

| Sumber | Lokasi |
|---|---|
| Laporan D3 final | `D3/[D3] Capstone Project Final Report and Documentation - Kolabri.docx` |
| Skrip compile D3 | `D3/compile_d3_report.py` |
| Naskah TA (LaTeX) | `/Users/hshino/Kuliah/latex-documents/TA/bab/bab{1..5}.tex` |
| Audit capstone | `docs/reports/audits/CAPSTONE_AUDIT_REPORT_2026-06-28.md` |
| Audit arsitektur | `docs/reports/audits/ARCHITECTURE_AUDIT_2026-06-28.md` |
| Prisma schema | `Kolabri-core-api/prisma/schema.prisma` |
| RAG service | `Kolabri-ai-engine/app/services/rag.py` |
| Logic Listener | `Kolabri-ai-engine/app/services/logic_listener.py` |
| Guardrails | `Kolabri-ai-engine/app/core/guardrails.py` |
| Socket & gates | `Kolabri-core-api/src/socket/{index,interventionGate,engagement}.ts` |
| Scope boundaries | `docs/architecture/*_SCOPE_BOUNDARIES.md` |

---

## Bagian 4 — Gap & Catatan

1. **Naskah TA vs kode**: Bab 4 TA sudah di-align (Juni 2026). Angka lama (2173 tests, 97.30% cov, 673 RPS) sudah diupdate ke angka aktual.
2. **Logic Listener**: Validasi F1 = 1.00 pada 30 gold sample — ini validasi fungsional, bukan skala produksi. Tetap attackable secara metodologis.
3. **E2E vs blackbox**: TA menyebut 21 skenario E2E; ada 38 blackbox pytest. Definisi perlu disambungkan di footnote.
4. **Bab 3 metodologi**: Beberapa target (100 kueri, 50+ users konkuren) melebihi eksekusi aktual. Sudah di-reframe di Bab 4 keterbatasan.
5. **Circuit breaker/fallback**: Diimplementasi di Core API (circuit breaker service) tapi failover multi-provider belum full (Phase 2 future work).
6. **Course weeks dan materials**: PostgreSQL Core API adalah sumber data tunggal; Client App hanya menangani UI, BFF, dan file PDF.
