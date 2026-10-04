---
description: 'Kolabri ProjectTA state snapshot — updated at end of significant work.'
label: current-state
limit: 3000
read_only: false
---

# Current State — Kolabri (ProjectTA)
**Last updated:** 2026-10-04

## Ships in this batch (all pushed)

- **Stream-only inference + provider-boundary caching** (research-backed per provider)
  - Engine `21fe814`: non-stream `POST /api/chat` + `/api/chat/personal` + `orchestrator.handle_message` **removed**; prefix reordered (static system byte-identical, RAG context/citation/scaffolding in leading user turn); chunk-replay cache + single-flight (personal + RAG NO_FETCH, SHA-256, success-only); `generate()`-level provider-response cache (TTL600s, bypassed by `ENABLE_EFFICIENCY_GUARD=false`); `llm_prompt_cache_usage` logs; vision caption Redis cache
  - Core `fb2d6d3` → `0b23ad3` → `5ed032f`: `sendMessage` consumes stream SSE; socket FETCH via `orchestratedChatStream`; removed `.personalChat`/`.orchestratedChat`; **green suite** work (below)
  - Umbrella `208ce5e`: pointer bumps + testing-guide stream-only docs
- **Deploy**: sumo1 rsync + rebuild; containers healthy; live proof `llm_prompt_cache miss→hit` on identical stream

## Test suite status (2026-10-04)

- **Core local (Postgres OFF, guarded)**: `85 passed | 8 skipped` files, `608 passed | 161 skipped`, **0 failed**; tsc clean
- **Core sumo1 (live DB, container `node:20`, throwaway DB)**: `92 passed | 1 skipped (pre-existing indonesian-text-verification)`, **763 passed | 6 skipped, 0 failed** — the161 DB tests PROVEN green
- Engine: `2327 passed / 0 failed` + admin6/6
- **Key fixes**: npm12 `allowScripts` (bcrypt binding missing →8 files couldn't collect); `vitest.setup.ts` loads `dotenv/config` (was only in `server.ts` entry → auth tests500 `JWT secret not configured`); DB-off `describe.skipIf` probes in9 files;2 real bugs: socket `interventions.ts` + `index.ts` broadcast empty bot message on AI failure (`{success:false,message:''}` never threw; `prompt ?? pool` misses `''`)

## E2E live (kolabri.web.id, student Andi → IF203 → Kelompok A)

Full lifecycle ✅: create session → pre-read gate → AI goal validator (400 on non-SMART, passes with time-bound) → chat send + reload persist → **@ai mention → engine `/api/chat/stream` 200** → close session → **AI ringkasan accurate**. Test session "Uji Chat E2E Andi" left in prod by user's choice (`tidak apa apa`).

## Local laptop (user directive: focus on sumo1, laptop must stay clean)

- `kolabri-db` dropped; brew postgres+redis stopped; colima/docker stopped; `.dev-logs` removed
- Other projects' DBs (flicknfit, antares, …) left on disk untouched
- sumo1 keeps `/opt/kolabri/core-api-test/` (code + node_modules) for future test runs; `kolabri_test` DB dropped after verification

## Chat edit/delete auth fix (2026-10-04, deployed + verified live)

- **Root cause 1:** `auth.jwt` (`JwtAuthMiddleware:73`) only does `$request->merge(['auth_user' => session('user')])` — it **never populates Laravel's auth guard**, so `$request->user()` is always `null` on those routes. Only 2 controllers used it: `Student/MessageController` (edit `:22`, destroy `:103`, moderator `:120`) and `Student/PinnedMessageController` (`:23/:26/:84`). House pattern is `data_get($request->input('auth_user'), 'id', session('user.id'))` (see `LecturerCourseWeeksController:158`).
- **Root cause 2 (delete-only):** `DELETE /api/chat/messages/{id}` was **missing from host nginx** — only `[^/]+/(edit|audit|pin)` matched, so the request fell through to `location /api/` → core-api → `401 No token provided`.
- **Fix:** `resolveAuthUser(Request): ?array` helper in both controllers (`auth_user` ?? `session('user')`, 401 when absent, `(string)` id, strict role check). Client-app `a74fa05`; root pointer `ac30a03`. Nginx: added `location ~ ^/api/chat/messages/[^/]+$` (backup in `/etc/nginx/backups/`).
- **Verified live:** `PATCH .../edit → 200` + `chat_message_audit(edit)` row; `DELETE .../{id} → 200` + `chat_message_audit(delete)` row; non-member → 403; student pin → 403 clean; unpin → 404 clean; 0 `ERROR` in client-app logs.
- **Still open:** F3 — clicking "Simpan edit"/"Hapus" in the UI emits **no** XHR/fetch (probed with patched `window.confirm`, `Array.prototype.find`, XHR/fetch). Bundle == source verified (`room.tsx:444-445` id-bound lambdas; compiled `onDelete:x` maps correctly). API path now proven 200, so F3 is purely client-side.
- **Deploy gotcha:** the live compose file is **`/opt/kolabri/docker-compose.yml`** (project `kolabri`; its `name:` makes `docker compose ls` also list `docker-compose.production.yml`). PHP source is **baked into the image** (no `app/` bind-mount) — rsync alone does nothing, a rebuild is required. Published ports `127.0.0.1:18000→80`, `:13000→3000`, `:15432→5432`, `:27018→27017` are what host nginx proxies.

## RAG ingest & retrieval (2026-10-04, fixed + verified live)

**Panduan lengkap:** `docs/guides/RAG-INGEST-DAN-RETRIEVE.md`

Rantai ingest: UI dosen (tab Materials) → `POST /lecturer/courses/{c}/materials` → file ke
`storage/app/private/materials/{course}/` → Core API `CourseMaterialKbService` → AI Engine
`POST /api/ingest` (multipart, `Authorization: Bearer <CORE_API_SECRET>`) → chunk 1200 char → embed
voyage-3.5 1024d → Qdrant `course_<course_id>`. Retrieve: `POST /api/ask` (atau `@ai` di chat).

**Tiga bug yang membuat Qdrant selalu kosong / kotor:**

1. **Permission (client-app)** — disk `private` pakai `visibility: 'private'` → file mode **0600**.
   Core API jalan sebagai uid `node`(1000), client-app `www-data`(33) → `EACCES` saat baca →
   ingest selalu gagal, `vector_status=failed`. Fix: `config/filesystems.php` permissions 0664/0775 +
   `umask=002` di `docker/supervisord.conf`. (Juga: `storage/app/private` harus `chown 33:33` +
   setgid `2775` agar file baru satu grup dengan core-api.)
2. **Hapus materi tidak menghapus vektor (core-api)** — `softDeleteForCourseMaterial()` hanya
   soft-delete baris DB. Fix: panggil `aiEngineService.deleteDocument()` per KB row.
3. **Hapus vektor tidak pernah cocok (ai-engine)** — akar ganda:
   `delete_documents(ids=[...])` menghitung `uuid5(document_id)`, padahal point disimpan sebagai
   `uuid5(chunk_id)` dengan `chunk_id = f"{document_id}_p{page}_c{index}"`; **dan**
   `add_documents()` menimpa payload `document_id` dengan chunk id, sehingga filter
   `where={"document_id": kb_id}` juga tidak cocok. Fix: delete pakai payload filter per
   `document_id`; payload simpan `document_id` asli + `chunk_id` terpisah.

**Terverifikasi live:** upload PDF → `vector_status=ready` → 3 chunks di Qdrant (payload benar) →
hapus materi → collection kembali **0 points**. Retrieval terbukti: `CRISP-DM` score 0.707 / 0.704.

**Catatan penting:**
- `POST /api/ask` bergantung LLM; provider kena 429 → balasan "tidak menemukan jawaban" **meski
  retrieval sukses**. Pisahkan dengan log: `rag_search_started` → `reranking_completed` → `llm_request`.
- Dedup konten: ingest dokumen dengan isi identik → `document_already_processed`, `chunks=0`
  (by design, bukan bug).
- Demo lama `knowledge_bases.file_path = /demo/kb/...` → file tidak ada di container; tidak akan
  pernah selesai ingest. Hanya materi yang di-upload lewat aplikasi yang bisa `ready`.

## Open items (not started)

1. **CI**: core `ci.yml` runs `test:run` WITHOUT postgres →161 DB tests skip on GitHub; wiring service postgres now safe (proven green with live DB)
2. **OpenSpec backlog**:53 active change dirs vs9 archived (repo mandates spec-first + archive)
3. **Dead module**: `providerResolution.service.ts` + its unit test —0 production callers since `de64e41`; cleanup candidate (also leftover test-file refs)
4. Engine nits: `/metrics` Prometheus endpoint (metrics are log-based now), `enable_semantic_cache` flag, `B008`×2 in `documents.py`
5. `prompt_cache_hit_tokens` never appears with sumopod (provider doesn't return it) — auto-valuable if provider moves to DeepSeek/OpenAI
