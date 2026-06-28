# Kolabri Severity-Based Observations

**Generated:** 2026-05-11  
**Scope:** `Kolabri-client-app`, `Kolabri-core-api`, `Kolabri-ai-engine`  
**Purpose:** Mengelompokkan hasil observasi ketiga project berdasarkan severity: `critical`, `high`, `medium`, dan `low`.

---

## How to Read This Document

- **Critical** → masalah yang berdampak langsung pada security, reliability, atau data integrity.
- **High** → masalah yang tidak selalu langsung fatal, tetapi berpotensi besar mengganggu maintainability, operability, atau correctness.
- **Medium** → masalah yang penting untuk kualitas engineering, tetapi belum mendesak secara operasional.
- **Low** → polishing, consistency, dan long-term cleanup.

---

## 1. Kolabri-client-app

### Overall assessment

`Kolabri-client-app` adalah project dengan fondasi UI/BFF yang cukup baik. Struktur role-based UI jelas, integrasi Laravel + React + Inertia tertata, dan TypeScript coverage tinggi. Masalah utamanya lebih banyak berada di area **maintainability**, **duplication**, dan **testing depth**, bukan pada security/reliability level kritis.

### Critical

Tidak ada temuan critical yang menonjol dari hasil inspeksi saat ini.

### High

1. **Controller Laravel terlalu tebal**
   - Beberapa controller memuat terlalu banyak business logic.
   - Dampak: controller makin sulit dirawat, sulit dites, dan mudah menjadi titik duplikasi logic.

2. **Duplikasi logic proxy ke Core API**
   - Banyak controller melakukan pola request ke Core API yang mirip.
   - Dampak: sulit distandarkan, rawan mismatch error handling, dan memperbesar biaya perubahan.

3. **Kesenjangan testing frontend**
   - Testing lebih dominan di feature/e2e, sementara unit/component test belum cukup kuat.
   - Dampak: perubahan UI atau behavior kecil lebih mudah lolos tanpa validasi granular.

### Medium

1. **Ada workaround typing seperti `@ts-ignore` di area legacy**
   - Dampak: mengurangi kekuatan TypeScript sebagai safety net.

2. **Error handling antar controller belum sepenuhnya seragam**
   - Dampak: perilaku UI terhadap error bisa tidak konsisten.

3. **Belum ada strategi code splitting/lazy loading yang kuat**
   - Dampak: potensi pembengkakan bundle dan load performance seiring fitur bertambah.

4. **Belum ada testing komponen React yang sistematis**
   - Dampak: validasi perilaku komponen belum cukup presisi.

### Low

1. **Belum ada visual regression testing**
   - Dampak: perubahan visual halus lebih sulit terdeteksi secara otomatis.

2. **Potensi bundle growth**
   - Belum tentu jadi isu sekarang, tapi akan makin terasa saat dashboard dan analytics bertambah berat.

### Recommended action items

#### High priority actions
- Extract business logic dari controller ke service layer Laravel.
- Buat shared wrapper/service untuk komunikasi ke Core API.
- Tambahkan unit/component tests untuk flow penting.

#### Medium priority actions
- Hilangkan `@ts-ignore` yang tidak perlu.
- Standarkan error mapping dari Core API ke UI.
- Mulai lazy loading untuk halaman besar.

#### Low priority actions
- Evaluasi visual regression testing.
- Review asset/bundle strategy.

---

## 2. Kolabri-core-api

### Overall assessment

`Kolabri-core-api` adalah project yang paling penting secara sistemik karena menjadi **central coordination layer**. Fondasi arsitekturnya cukup baik, tetapi project ini juga punya temuan paling berat, terutama di **security**, **reliability**, dan **data consistency**. Ini adalah service yang paling perlu diprioritaskan.

### Critical

1. **JWT verification tidak memeriksa user ke database**
   - Token bisa tetap dianggap valid walaupun user sudah dihapus atau dinonaktifkan.
   - Dampak: authorization state bisa salah dan membuka celah security.

2. **Tidak ada input sanitization**
   - Input user-facing berisiko membawa XSS payload atau data kotor.
   - Dampak: risiko security di downstream consumer dan risiko penyimpanan data tidak aman.

3. **Tidak ada rate limiting pada Socket.IO events**
   - User bisa spam event, terutama `send_message`.
   - Dampak: abuse, degraded performance, bahkan denial-of-service di layer realtime.

4. **Tidak ada circuit breaker untuk AI Engine integration**
   - Bila AI Engine gagal/timeout, Core API tidak punya isolasi kegagalan yang cukup.
   - Dampak: cascading failure ke service utama.

5. **Tidak ada soft delete**
   - Penghapusan data bersifat permanen.
   - Dampak: risiko kehilangan data, auditability rendah, rollback bisnis sulit.

### High

1. **Duplicate source of truth untuk `AIChatSession`**
   - Data berada di Prisma/PostgreSQL dan juga Mongoose/MongoDB.
   - Dampak: sinkronisasi sulit, potensi data drift tinggi.

2. **Tidak ada retry logic untuk panggilan ke AI Engine**
   - Single transient failure langsung menjadi user-facing failure.
   - Dampak: reliability rendah untuk integrasi AI.

3. **Tidak ada timeout yang tegas untuk request ke AI Engine**
   - Request bisa menggantung terlalu lama.
   - Dampak: resource exhaustion, latency spike.

4. **Validation coverage tidak merata**
   - Beberapa endpoint divalidasi dengan baik, sebagian lain masih parsial atau tidak ada.
   - Dampak: API correctness dan safety jadi tidak konsisten.

5. **Socket.IO payload tidak tervalidasi**
   - Event payload berpotensi malformed.
   - Dampak: crash, runtime error, atau state corruption di flow realtime.

6. **Missing database indexes**
   - Beberapa jalur query penting tidak dioptimalkan.
   - Dampak: query lambat dan bottleneck saat skala naik.

7. **Belum ada error tracking seperti Sentry**
   - Dampak: visibility atas runtime failure rendah.

### Medium

1. **Controller masih memuat business logic di beberapa area**
   - Dampak: tanggung jawab layer bercampur.

2. **Service-to-service coupling terlalu rapat**
   - Dampak: sulit diuji dan sulit di-refactor.

3. **Masih ada `any` dan loose typing**
   - Terutama di error handling dan Socket.IO payload typing.
   - Dampak: TypeScript tidak memberi safety maksimal.

4. **Tidak ada unit tests yang kuat**
   - Dominan integration tests.
   - Dampak: diagnosis bug di level logic lebih mahal.

5. **Tidak ada coverage report yang jelas**
   - Dampak: sulit tahu area yang under-tested.

6. **Ada flaky tests**
   - Dampak: test suite kurang dipercaya.

7. **Error response belum sepenuhnya distandarkan**
   - Dampak: client-side error handling lebih sulit dibuat konsisten.

### Low

1. **Naming inconsistency**
   - Ada campuran kebab-case, camelCase filename tertentu, dan snake_case legacy variable.

2. **Code duplication di helper/pagination/error response**
   - Dampak: biaya maintenance meningkat.

3. **Belum ada distributed tracing**
   - Dampak: root-cause analysis lintas service lebih sulit.

### Recommended action items

#### Critical priority actions
- Tambahkan database existence/active check pada JWT verification.
- Sanitasi semua input user-facing.
- Tambahkan Socket.IO rate limiting.
- Tambahkan circuit breaker untuk integrasi AI Engine.
- Implement soft delete strategy.

#### High priority actions
- Putuskan satu source of truth untuk `AIChatSession`.
- Tambahkan retry + timeout ke AI Engine calls.
- Lengkapi validation endpoint dan Socket.IO payload validation.
- Tambahkan missing indexes.
- Integrasikan error tracking.

#### Medium priority actions
- Tipiskan controller dan kurangi service coupling.
- Rapikan typing.
- Tambahkan unit tests + coverage reporting.
- Investigasi flaky tests.

#### Low priority actions
- Rapikan naming.
- Refactor shared helpers.
- Tambahkan tracing.

---

## 3. Kolabri-ai-engine

### Overall assessment

`Kolabri-ai-engine` terlihat paling matang secara teknis dari sisi service internals. Pipeline AI cukup lengkap, struktur modular cukup rapi, dan safety layer sudah lebih maju daripada dua project lainnya. Temuan utamanya berada di area **maintainability**, **operational tuning**, dan **testing/performance depth**, bukan di area critical security yang langsung menghambat operasi.

### Critical

Tidak ada temuan critical yang menonjol dari hasil inspeksi saat ini.

### High

1. **Beberapa service functions terlalu panjang**
   - Dampak: sulit dipahami, sulit diuji, dan rawan perubahan merembet.

2. **Threshold penting masih hardcoded**
   - Dampak: tuning operasional jadi lambat dan rawan edit kode untuk perubahan kecil.

3. **Unit test service layer belum cukup kuat**
   - Dampak: logic AI/NLP/RAG sulit divalidasi granular.

4. **Reranker disabled by default**
   - Dampak: kualitas retrieval mungkin belum optimal dibanding potensi pipeline yang tersedia.

### Medium

1. **Belum ada distributed tracing**
   - Dampak: bottleneck lintas request/LLM/vector store lebih sulit didiagnosis.

2. **Load/performance testing belum matang**
   - Dampak: karakteristik performa saat traffic naik belum terukur kuat.

3. **Batch processing masih bisa dioptimalkan**
   - Dampak: ingest throughput mungkin belum efisien.

4. **Streaming response masih bisa diperkuat**
   - Dampak: UX untuk response panjang belum maksimal.

5. **Cache invalidation strategy bisa lebih presisi**
   - Dampak: cache stale atau invalidation yang terlalu kasar bisa memengaruhi accuracy/performance.

### Low

1. **Belum ada framework A/B testing prompt/model**
   - Dampak: evaluasi peningkatan kualitas model/prompt belum sistematis.

2. **Beberapa error/operational message masih bisa dibuat lebih ramah**
   - Dampak: developer/operator experience bisa lebih baik.

### Recommended action items

#### High priority actions
- Pecah long service functions menjadi helper/module yang lebih kecil.
- Pindahkan threshold penting ke config/env.
- Perkuat unit tests service inti.
- Evaluasi mengaktifkan reranker melalui config/flag.

#### Medium priority actions
- Tambahkan load testing.
- Optimalkan batch ingestion.
- Perkuat streaming response path.
- Tambahkan distributed tracing.
- Review cache invalidation strategy.

#### Low priority actions
- Evaluasi A/B testing prompt/model.
- Rapikan developer/operator feedback messages.

---

## Cross-Project Severity Summary

### Critical

Semua temuan critical saat ini terpusat di **Kolabri-core-api**:

1. JWT verification tidak cek database.
2. Tidak ada input sanitization.
3. Tidak ada Socket.IO rate limiting.
4. Tidak ada AI Engine circuit breaker.
5. Tidak ada soft delete.

### High

Temuan high tersebar sebagai berikut:

- **Client App**
  - controller terlalu tebal
  - duplikasi proxy logic
  - gap di component/unit testing

- **Core API**
  - duplicate source of truth
  - AI retry/timeout gap
  - validation tidak merata
  - realtime payload validation belum ada
  - missing indexes
  - error tracking belum ada

- **AI Engine**
  - long service functions
  - hardcoded thresholds
  - unit test depth kurang
  - reranker belum aktif secara default

### Medium

Temuan medium paling banyak terkait:

- maintainability
- typing consistency
- observability
- testing depth
- performance tuning

### Low

Temuan low terutama terkait:

- naming consistency
- helper duplication
- visual regression / documentation / polishing
- long-term observability improvements

---

## Recommended Order of Work

1. **Core API critical fixes**
2. **Core API high priority hardening**
3. **Client App maintainability cleanup**
4. **AI Engine tuning + test strengthening**
5. **Cross-project observability and consistency work**

---

## Related Documents

- [Kolabri observations and action items](file:///Users/hshino/Kuliah/ProjectTA/docs/KOLABRI_OBSERVATIONS_ACTION_ITEMS.md)
- [Deep inspection report](file:///Users/hshino/Kuliah/ProjectTA/docs/CODE_INSPECTION_REPORT.md)
- [Core API detailed inspection](file:///Users/hshino/Kuliah/ProjectTA/docs/CORE_API_INSPECTION_DETAIL.md)
