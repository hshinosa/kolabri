# Core API — Scope & Boundaries

**Generated:** 2026-05-17  
**Scope:** Kolabri-core-api (`/Kolabri-core-api/`)  
**Purpose:** Mendefinisikan batasan pengembangan Core API agar development lanjutan tidak keluar dari scope arsitektur sistem.

---

## 1. Peran dalam Sistem

Core API adalah **Central Coordination Layer**. Semua request dari Client App masuk ke sini, dan Core API yang memutuskan apakah perlu meneruskan ke AI Engine atau cukup diproses sendiri.

```
Client App  →  Core API  →  AI Engine
                  ↓
            PostgreSQL (Prisma)
            MongoDB (Mongoose)
            Redis (optional)
```

Core API adalah **satu-satunya service yang boleh memanggil AI Engine**. Client App tidak pernah memanggil AI Engine langsung.

---

## 2. Batasan Interface

### Yang Boleh Memanggil Core API

| Caller | Protokol | Keterangan |
|---|---|---|
| Client App | HTTP REST | Semua data operations |
| Client App | Socket.IO | Real-time group chat |

### Yang Boleh Dipanggil Core API

| Target | Protokol | Keterangan |
|---|---|---|
| AI Engine | HTTP REST | Semua AI/ML computation |
| PostgreSQL | Prisma ORM | Relational data |
| MongoDB | Mongoose ODM | Chat logs, audit, event logs |
| Redis | Redis client | Caching (optional) |

### Yang TIDAK Boleh Dipanggil Core API

| Target | Alasan |
|---|---|
| LLM API langsung | Semua LLM calls harus lewat AI Engine |
| Qdrant langsung | Vector store adalah domain AI Engine |
| Client App langsung | Komunikasi satu arah: Client App → Core API |

---

## 3. Batasan Tanggung Jawab

### Yang Menjadi Tanggung Jawab Core API

| Domain | Deskripsi |
|---|---|
| **Authentication** | JWT generation, verification, refresh |
| **Authorization** | Role-based access control (student, lecturer, admin) |
| **User Management** | CRUD user, role assignment |
| **Course Management** | CRUD course, enrollment, template |
| **Group Management** | CRUD group, member management, join code |
| **Chat Space Lifecycle** | Open, close, reopen chat spaces |
| **Learning Goals** | CRUD goal per chat space |
| **Reflections** | Submission dan retrieval |
| **Knowledge Base** | Document metadata, upload orchestration |
| **AI Provider Config** | Admin configuration untuk AI providers |
| **Audit Logging** | Semua operasi sensitif dicatat |
| **Usage Tracking** | AI usage per user/course |
| **Real-time (Socket.IO)** | Group chat, silence detection, intervention delivery |
| **AI Engine Proxy** | Forward AI requests, handle timeout/retry |
| **Analytics Aggregation** | Kumpulkan hasil analytics dari AI Engine |

### Yang BUKAN Tanggung Jawab Core API

| Domain | Pemilik yang Benar |
|---|---|
| AI/ML computation | AI Engine |
| NLP analytics | AI Engine |
| Vector embedding | AI Engine |
| Document processing (parse PDF/DOCX) | AI Engine |
| LLM calls | AI Engine |
| Intervention logic | AI Engine |
| Process mining | AI Engine |
| UI rendering | Client App |
| Session management | Client App |
| CSRF protection | Client App |

---

## 4. Batasan Data Ownership

Core API memiliki dua database:

```
PostgreSQL (via Prisma)
  → Users, Courses, CourseTemplates, CourseStudents
  → Groups, GroupMembers
  → ChatSpaces, LearningGoals, Reflections
  → KnowledgeBases, ChatMessages
  → AiChats, AiUsages, AiModelComparisons
  → AuditLogs

MongoDB (via Mongoose)
  → ChatLog          (pesan chat real-time)
  → SilenceEvent     (event silence detection)
```

Core API **tidak memiliki dan tidak boleh menulis langsung ke:**
- Qdrant (domain AI Engine)
- MongoDB event logs milik AI Engine (intervention logs, process mining)
- Redis AI Engine (cache LLM responses)

---

## 5. Batasan Arsitektur Internal

### Controller harus tipis

Controller hanya boleh: terima request → validasi → panggil service → return response.

```typescript
// BENAR
async createCourse(req: Request, res: Response) {
  const data = validateCourseInput(req.body);
  const course = await courseService.create(data, req.user.id);
  res.status(201).json(course);
}

// SALAH — business logic di controller
async createCourse(req: Request, res: Response) {
  // 80+ baris logic, query langsung, transformasi...
}
```

### Service layer adalah tempat business logic

Semua business logic ada di `src/services/`. Controller tidak boleh mengandung query Prisma atau Mongoose langsung.

### aiEngine.service.ts adalah satu-satunya pintu ke AI Engine

Semua panggilan ke AI Engine harus lewat `aiEngine.service.ts`. Tidak ada controller atau service lain yang boleh memanggil AI Engine langsung.

---

## 6. Batasan Teknologi

| Komponen | Pilihan Saat Ini | Jangan Diganti Ke |
|---|---|---|
| Framework | **Express 4** + TypeScript 5.7 | Fastify, NestJS, Hapi |
| Relational ORM | **Prisma 6** (PostgreSQL) | TypeORM, Sequelize, raw SQL |
| Document ODM | **Mongoose 8** (MongoDB) | Motor, raw MongoDB driver |
| Real-time | **Socket.IO 4** | WebSocket raw, SSE |
| Validation | **Zod** | Joi, class-validator |
| Auth | **JWT** (jsonwebtoken) | Session-based, OAuth only |
| Security | **helmet** + **express-rate-limit** | Jangan hapus tanpa pengganti |
| Testing | **Vitest 2** | Jest, Mocha |
| Runtime | **Node.js ≥ 20** | Deno, Bun |

---

## 7. Batasan Fitur

### In Scope — Boleh Dikembangkan

- Tambah endpoint baru untuk domain yang sudah ada (course, group, chat, dll)
- Improve auth: tambah token refresh, user status check saat verify JWT
- Tambah input sanitization dan validation yang lebih kuat
- Tambah rate limiting ke Socket.IO events
- Tambah circuit breaker untuk panggilan ke AI Engine
- Tambah retry logic + timeout yang tegas untuk AI Engine calls
- Tambah soft delete untuk model-model penting
- Improve audit logging coverage
- Tambah integration test untuk flow yang belum ter-cover

### Out of Scope — Jangan Masuk ke Core API

- AI/ML computation (embedding, LLM calls, NLP)
- Direct Qdrant access
- UI rendering logic
- Business logic yang seharusnya di AI Engine
- Menambah database baru tanpa justifikasi arsitektur yang kuat

---

## 8. Critical Issues yang Harus Diselesaikan

Ini issues dari inspeksi yang berdampak langsung pada security dan reliability:

### Critical (Security / Reliability)

| # | Issue | Dampak | Action |
|---|---|---|---|
| 1 | JWT verification tidak cek user ke database | Token valid meski user dihapus/dinonaktifkan | Tambah DB lookup saat verify JWT |
| 2 | Tidak ada input sanitization | Risiko XSS payload masuk ke storage | Tambah sanitization di middleware |
| 3 | Tidak ada rate limiting di Socket.IO events | Abuse, spam, potensi DoS | Tambah rate limiter per socket event |
| 4 | Tidak ada circuit breaker untuk AI Engine | Cascading failure saat AI Engine down | Implementasi circuit breaker di `aiEngine.service.ts` |
| 5 | Tidak ada soft delete | Data hilang permanen, auditability rendah | Tambah `deletedAt` field ke model penting |

### High Priority

| # | Issue | Action |
|---|---|---|
| 6 | Duplicate source of truth `AIChatSession` (PostgreSQL + MongoDB) | Tentukan satu sumber kebenaran, hapus duplikasi |
| 7 | Tidak ada retry logic untuk AI Engine calls | Tambah exponential backoff retry |
| 8 | Tidak ada timeout tegas untuk AI Engine requests | Set explicit timeout di `aiEngine.service.ts` |
| 9 | Validation coverage tidak merata | Audit semua endpoint, standarkan Zod schema |

### Medium Priority

| # | Issue | Action |
|---|---|---|
| 10 | Error handling tidak seragam | Standarkan error response format |
| 11 | Beberapa controller masih tebal | Extract ke service layer |

---

## 9. Checklist Sebelum Menambah Fitur Baru

- [ ] Apakah fitur ini adalah coordination / data management concern? (bukan AI/ML computation)
- [ ] Apakah controller tetap tipis setelah fitur ini ditambahkan?
- [ ] Apakah semua AI calls lewat `aiEngine.service.ts`?
- [ ] Apakah ada Zod validation untuk semua input baru?
- [ ] Apakah ada audit log untuk operasi sensitif baru?
- [ ] Apakah ada unit test + integration test untuk fitur ini?
- [ ] Apakah fitur ini tidak membuat duplikasi data antara PostgreSQL dan MongoDB?

---

## Referensi

- [FULL_INSPECTION_2026_05_17.md](./FULL_INSPECTION_2026_05_17.md)
- [KOLABRI_OBSERVATIONS_ACTION_ITEMS.md](./KOLABRI_OBSERVATIONS_ACTION_ITEMS.md)
- [KOLABRI_SEVERITY_BASED_OBSERVATIONS.md](./KOLABRI_SEVERITY_BASED_OBSERVATIONS.md)
- [AI_ENGINE_SCOPE_BOUNDARIES.md](./AI_ENGINE_SCOPE_BOUNDARIES.md)
- [CLIENT_APP_SCOPE_BOUNDARIES.md](./CLIENT_APP_SCOPE_BOUNDARIES.md)
- [INTEGRATION_VERIFICATION.md](./INTEGRATION_VERIFICATION.md)
