# Kolabri Observations and Action Items

**Generated:** 2026-05-11  
**Scope:** `Kolabri-client-app`, `Kolabri-core-api`, `Kolabri-ai-engine`  
**Sources:** `CODE_INSPECTION_REPORT.md`, `CORE_API_INSPECTION_DETAIL.md`

---

## Executive Summary

Kolabri terdiri dari tiga service utama dengan pembagian tanggung jawab yang cukup jelas:

- **Kolabri-client-app** berperan sebagai **BFF + UI layer** berbasis Laravel + React.
- **Kolabri-core-api** berperan sebagai **central coordination layer** berbasis Express + TypeScript.
- **Kolabri-ai-engine** berperan sebagai **AI/RAG/NLP layer** berbasis FastAPI + Python.

Secara umum, arsitektur sistem sudah solid dan separation of concerns antar service sudah terlihat jelas. Area yang paling butuh perhatian adalah **Kolabri-core-api**, terutama pada sisi **security**, **reliability**, dan **consistency**. Di sisi lain, **Kolabri-client-app** dan **Kolabri-ai-engine** sudah punya fondasi yang baik, tetapi masih memiliki beberapa tech debt yang perlu dirapikan.

---

## 1. Kolabri-client-app Observations

### What is working well

- Menerapkan pola **BFF (Backend-for-Frontend)** dengan baik: Laravel menangani session, CSRF, dan proxy ke Core API, sementara React menangani rendering UI.
- Struktur frontend cukup rapi:
  - `resources/js/pages/` dipisah berdasarkan role (`admin`, `lecturer`, `student`, `auth`)
  - `resources/js/components/` dipisah berdasarkan concern (`ui`, `layout`, `chat`, `analytics`, `forms`)
- **Role-based access control** sudah konsisten antara backend Laravel dan frontend React.
- **TypeScript coverage** tinggi, sekitar **~95%**, dengan pola komponen yang cukup konsisten.
- Integrasi **Socket.IO client** sudah ada untuk real-time chat.
- Secara umum UI layer sudah reusable, cukup accessible, dan maintainable.

### Main issues observed

#### Architecture / code quality

1. Beberapa controller Laravel terlalu panjang dan memuat terlalu banyak business logic.
2. Ada duplikasi pola pemanggilan Core API di banyak controller.
3. Ada indikasi beberapa workaround TypeScript seperti `@ts-ignore` pada area legacy.
4. Error handling antar controller belum sepenuhnya seragam.

#### Testing

1. Test coverage lebih berat ke **e2e/feature**, belum kuat di **unit/component test**.
2. Belum ada pengujian komponen React yang sistematis.
3. Belum ada visual regression testing.

#### Performance / maintainability

1. Belum terlihat strategi code splitting yang jelas.
2. Lazy loading route/component belum jadi pola utama.
3. Potensi bundle frontend membesar seiring pertumbuhan fitur.

### Client-app action items

#### High priority

1. **Extract long controller methods** ke service layer Laravel agar controller tetap tipis.
2. **Buat shared Core API service wrapper** agar logic HTTP ke Core API tidak duplikatif.
3. **Rapikan TypeScript suppressions** (`@ts-ignore`) dan ganti dengan typing yang benar.
4. **Standarkan error response mapping** dari Core API ke Laravel controllers.

#### Medium priority

5. **Tambahkan unit test untuk React components** dengan Vitest/React Testing Library.
6. **Tambahkan component test untuk flow penting** seperti auth, chat, analytics widgets.
7. **Mulai code splitting/lazy loading** untuk halaman besar terutama dashboard dan analytics.
8. **Audit reusable components** agar pola UI tetap konsisten saat fitur bertambah.

#### Low priority

9. Pertimbangkan visual regression testing.
10. Review bundle size dan asset loading strategy.

---

## 2. Kolabri-ai-engine Observations

### What is working well

- AI Engine punya pipeline yang cukup lengkap untuk kebutuhan produk:
  - ingestion dokumen
  - embedding lokal
  - vector retrieval
  - reranking
  - generation
- Struktur modul cukup sehat, dengan pemisahan concern yang jelas antara:
  - `api/`
  - `core/`
  - `services/`
  - `middleware/`
  - `utils/`
- **Type hints** dan **Pydantic v2** dipakai dengan baik.
- Pola **async/await** konsisten dan cocok dengan FastAPI + Motor + Redis.
- Sudah ada **safety layer** yang kuat:
  - prompt injection detection
  - toxicity scoring
  - PII masking
  - content filtering
- Sudah ada **Redis caching** untuk beberapa operasi mahal.
- LLM provider abstraction sudah ada dan mendukung provider switching.

### Main issues observed

#### Code quality / maintainability

1. Beberapa service punya fungsi yang terlalu panjang.
2. Ada threshold penting yang masih hardcoded, padahal semestinya configurable.
3. Beberapa area masih bisa dipisah lebih kecil agar logic lebih mudah diuji.

#### Feature / quality gaps

1. **Reranker disabled by default**, padahal bisa meningkatkan kualitas retrieval.
2. Belum ada distributed tracing untuk melihat bottleneck lintas service.
3. Belum ada framework pembanding prompt/model secara sistematis.

#### Testing / performance

1. Unit test service layer belum cukup kuat.
2. Belum banyak mocking untuk dependency eksternal.
3. Belum ada gambaran load/performance testing yang matang.
4. Batch processing dan streaming response masih bisa dioptimalkan.

### AI-engine action items

> **Last updated:** 2026-05-17 — Items yang sudah diselesaikan ditandai ✅

#### High priority

1. **Refactor long service functions** menjadi helper/helper module yang lebih kecil. *(open)*
2. **Pindahkan threshold penting ke config/env** agar bisa di-tuning tanpa ubah kode. ✅ **Done 2026-05-17** — `LOGIC_LISTENER_OFF_TOPIC_SIMILARITY_THRESHOLD`, `LOGIC_LISTENER_OFF_TOPIC_CONSECUTIVE_THRESHOLD`, `LOGIC_LISTENER_PARTICIPATION_INEQUITY_THRESHOLD` ditambahkan ke `config.py`. `GINI_THRESHOLD` dihapus dan diganti nama. `LogicListener.__init__` sekarang baca dari `settings.*`.
3. **Enable reranker by default atau via feature flag/config** setelah diverifikasi. ⚠️ **Partial 2026-05-17** — `ENABLE_RERANKING=True` sudah di config, health endpoint sudah expose `reranker_enabled`. Tapi PyTorch tidak tersedia untuk Python 3.13 di macOS, sehingga reranker tetap disabled at runtime. Fix: install Python 3.11/3.12 atau `conda install pytorch`.
4. **Perkuat unit tests** untuk service inti: `llm`, `rag`, `intervention`, `nlp_analytics`. ✅ **Done 2026-05-17** — Evaluation harness ditambahkan: `test_logic_listener_evaluation.py` (5 tests, F1=1.0 untuk semua 3 intervention type). RAG evaluation script dengan gold standard 20 queries (MRR@5=0.88, Coverage=94.0% vs 84.0% no-RAG).

#### Medium priority

5. **Tambahkan request/load testing** untuk endpoint RAG, chat, analytics.
6. **Tambahkan batch optimization** untuk ingest dokumen.
7. **Tambahkan streaming response** untuk response AI yang panjang.
8. **Tambahkan distributed tracing** untuk observability lintas service.

#### Low priority

9. Evaluasi framework A/B testing prompt/model.
10. Review cache invalidation strategy agar lebih presisi.

---

## 3. Kolabri-core-api Observations

### What is working well

- Arsitektur utama sudah jelas: **routes → controllers → services → models**.
- Middleware pattern sudah cukup baik dan composable.
- Prisma dipakai untuk relational domain utama, dan ini memberi type-safe query foundation.
- Integrasi real-time sudah mencakup dua channel:
  - **Socket.IO** untuk group chat
  - **WebSocket** untuk admin notification
- Integrasi ke AI Engine sudah terpusat di service khusus.
- **78 integration tests** menunjukkan flow utama sudah di-cover cukup baik di level integrasi.

### Main issues observed

#### Critical security / reliability issues

1. **JWT verification tidak memeriksa user ke database** setelah token tervalidasi.
2. **Belum ada input sanitization**, sehingga ada risiko XSS.
3. **Belum ada rate limiting di Socket.IO**, sehingga rawan spam/abuse.
4. **Belum ada circuit breaker untuk AI Engine**, sehingga failure di AI Engine bisa menjalar ke Core API.
5. **Belum ada soft delete**, sehingga risiko kehilangan data permanen lebih tinggi.

#### High priority architecture / data issues

1. Ada **duplicate data concern** untuk `AIChatSession` antara PostgreSQL dan MongoDB.
2. Belum ada retry logic untuk panggilan ke AI Engine.
3. Belum ada timeout yang tegas untuk request ke AI Engine.
4. Validasi request belum merata di semua endpoint.
5. Socket.IO event payload belum tervalidasi dengan baik.
6. Masih ada index database yang kurang.
7. Belum ada error tracking seperti Sentry.

#### Medium priority code quality / testing issues

1. Beberapa controller masih memuat business logic.
2. Ada service yang saling memanggil terlalu erat.
3. Ada code duplication pada pagination, format error, dan beberapa helper.
4. Masih ada `any` type dan loose typing, terutama di area error handling dan Socket.IO.
5. Test masih dominan integration-level; unit test belum cukup kuat.
6. Ada flaky tests dan belum ada coverage report yang jelas.

### Core-api action items

#### Critical priority

1. **Tambahkan database check pada JWT verification** untuk memastikan user masih ada dan aktif.
2. **Tambahkan sanitization pada semua input user-facing** sebelum disimpan/diproses.
3. **Tambahkan rate limiting pada Socket.IO events** terutama `send_message`.
4. **Tambahkan circuit breaker pada AI Engine integration**.
5. **Implement soft delete** pada model yang relevan.

#### High priority

6. **Tambahkan retry logic** untuk request ke AI Engine.
7. **Tambahkan timeout** pada semua panggilan ke AI Engine.
8. **Putuskan satu source of truth untuk AIChatSession** lalu migrasikan datanya.
9. **Lengkapi Zod validation** untuk endpoint yang masih parsial atau kosong.
10. **Tambahkan validation untuk Socket.IO event payloads**.
11. **Tambahkan missing indexes** di PostgreSQL/MongoDB sesuai query path aktual.
12. **Integrasikan error tracking** seperti Sentry.

#### Medium priority

13. **Pindahkan business logic keluar dari controller** ke service layer.
14. **Kurangi service-to-service coupling** yang terlalu rapat.
15. **Standarkan error response structure** supaya frontend lebih mudah memetakan error.
16. **Perbaiki typing** pada area yang masih longgar.
17. **Tambahkan unit tests** untuk service penting.
18. **Tambahkan test coverage report**.
19. **Investigasi flaky tests** dan buat test isolation lebih kuat.

#### Low priority

20. Rapikan naming inconsistency.
21. Refactor helper/helper duplication.
22. Tambahkan distributed tracing.

---

## Cross-Project Observations

### Positive patterns across the system

- Pola arsitektur tiga service cukup jelas dan masuk akal.
- Alur auth lintas sistem konsisten secara konsep:
  - Client App menangani session
  - Core API menangani JWT domain logic
  - AI Engine menerima bearer secret untuk komunikasi internal
- Tiap service punya concern yang cukup terpisah.
- Validation dan logging sudah ada di semua layer, walau tingkat konsistensinya berbeda.

### Cross-project weaknesses

1. **Testing strategy belum seimbang**:
   - Core API kuat di integration test, lemah di unit test.
   - Client App lemah di component/unit test.
   - AI Engine masih perlu pendalaman unit/load test.
2. **Observability belum matang**:
   - belum ada distributed tracing yang menyatukan tiga service
   - error tracking belum konsisten
3. **Consistency gap** masih terlihat pada:
   - linting/style enforcement
   - validation completeness
   - error response shape
   - naming conventions di beberapa area

---

## Consolidated Action Items by Priority

### Priority 1 — Immediate

1. Core API: database check pada JWT verification.
2. Core API: input sanitization untuk semua input user-facing.
3. Core API: Socket.IO rate limiting.
4. Core API: AI Engine circuit breaker.
5. Core API: soft delete strategy.

### Priority 2 — Near-term

6. Core API: retry + timeout untuk AI Engine.
7. Core API: hilangkan duplicate source of truth untuk AIChatSession.
8. Core API: lengkapi validation endpoint + Socket.IO payload validation.
9. Core API: tambahkan missing indexes + error tracking.
10. Client App: extract long controller methods ke service layer.
11. Client App: buat shared Core API wrapper/service.
12. AI Engine: enable/configure reranker dan rapikan hardcoded thresholds.
13. AI Engine: refactor long service functions.

### Priority 3 — Medium-term

14. Tambahkan unit tests secara sistematis di ketiga project.
15. Tambahkan coverage reporting yang jelas.
16. Tambahkan load/performance testing untuk AI Engine dan real-time flow.
17. Tambahkan code splitting/lazy loading di client app.
18. Standarkan error response format lintas service.
19. Kurangi code duplication dan loose typing pada Core API.

### Priority 4 — Long-term

20. Tambahkan distributed tracing / observability end-to-end.
21. Tambahkan visual regression / richer UI testing.
22. Review cache invalidation strategy di AI Engine.
23. Rapikan linting/style consistency lintas repo.
24. Evaluasi A/B testing prompt/model dan peningkatan developer ergonomics.

---

## Recommended Execution Order

Kalau dikerjakan bertahap, urutan paling masuk akal adalah:

1. **Core API critical security & reliability fixes**
2. **Core API validation, indexing, and AI integration hardening**
3. **Client App controller/service cleanup**
4. **AI Engine quality improvements (reranker, config, tests)**
5. **Cross-project testing and observability improvements**

---

## Related Documents

- [Deep inspection summary](file:///Users/hshino/Kuliah/ProjectTA/docs/CODE_INSPECTION_REPORT.md)
- [Core API detailed inspection](file:///Users/hshino/Kuliah/ProjectTA/docs/CORE_API_INSPECTION_DETAIL.md)
