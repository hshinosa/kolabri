---
description: 'Kolabri ProjectTA state snapshot — updated at end of significant work.'
label: current-state
limit: 3000
read_only: false
---

# Current State — Kolabri (ProjectTA)
**Last updated:** 2026-10-06

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

## Docker deploy — bisa jalan dari clone segar (2026-10-06, verified)

**Masalah lama:** `deploy.sh` ada di `.gitignore` → fresh clone tak pernah dapatnya, padahal
`DEPLOYMENT.md` menyuruh menjalankan. Kalau dijalankan pun gagal: wajib `docker-compose` (v1) yang
tak ada di sumo1/vpsgw, menolak root, `read` prompt (abort di non-TTY karena `set -e`), typo
`Kolibri-` di `rm`, dan `nginx/ssl/` kosong → nginx crash di `listen 443`.

**Fix (repo root):**
- `31fe863` — `deploy.sh` tracked + ditulis ulang: deteksi `docker compose` v2 / v1, boleh root,
  non-interactive safe (`--yes`), flag baru `--check`/`--no-cache`/`--no-nginx`/`--status`,
  auto-mint TLS self-signed, **rotate `APP_KEY`** kalau masih memakai nilai yang ter-commit di
  `.env.production.example` (nilai itu publik → semua deploy berbagi satu encryption key),
  aktifkan profile `docker-nginx` default. Juga: `DB_SCHEMA app→public` di `docker-compose.yml`,
 14 typo `Kolibri-`→`Kolabri-`, docs pindah ke `docker compose` v2.
- `38baace` — ignore root `/.env` (berisi password kompose, dibuat `deploy.sh`).
- `37f49ec` — **`client-app`/`core-api` tidak mem-publish port host** → tanpa nginx, deploy selesai
  tapi tak bisa diakses. Tambah loopback `127.0.0.1:${CLIENT_APP_PORT:-18000}:80` dan
  `${CORE_API_PORT:-13000}:3000` (persis pola sumo1). `deploy.sh` kini fail-fast kalau `:80/:443`
  sudah dipakai host (nginx sumo1/vpsgw) dan menyarankan `--no-nginx`.

**Terverifikasi (vpsgw, clone segar):** `./deploy.sh --yes --check` → buat3 `.env.production` +
root `.env` + TLS, `APP_KEY` di-rotate, config valid,8 service di profile `docker-nginx`, deteksi
port conflict bekerja; `docker compose build core-api` **sukses** (106 detik).

**BELUM diverifikasi:** boot stack penuh (`up -d`) dan build `client-app`/`ai-engine` — RAM vpsgw
hanya ~1.8Gi tersedia dengan52 container berjalan, risiko OOM & mengganggu service lain. Perlu host
bersih / RAM bebas untuk uji end-to-end.

**Jalur deploy berbeda, jangan tertukar:**
- **sumo1 (produksi)** → `/opt/kolabri/docker-compose.yml`, varian di-patch manual (password
  `df432ee3…`, port `15432`/`27018`/`16333`, mongo `--auth`), **beda117 baris** dgn repo.
  JANGAN ditimpa dari repo.
- **host baru** → `./deploy.sh` (memakai `docker-compose.production.yml`).

**Secret lintas-service konsisten** dengan nilai default `.env.production.example`
(`change-this-to-strong-secret-in-production`): client-app→core-api pakai `CORE_API_INTERNAL_SECRET`
(fallback `AI_ENGINE_SECRET`), core-api→ai-engine pakai `AI_ENGINE_SECRET` divalidasi sbg
`CORE_API_SECRET`; `verifyInternalSecret` menerima `X-Internal-Secret` ATAU `Authorization: Bearer`.

**Akses GitHub dari vpsgw — aktif (2026-10-06):** key `root@personal`
(`SHA256:I4xcJX5s…L9A9rZw`) terdaftar di akun `hshinosa` (key ID `165511503`, title
`vpsgw (root@personal) — kolabri deploy`); remote root + 3 submodule sudah SSH
(`git@github.com:hshinosa/…`); `ssh -T git@github.com` → `Hi hshinosa!`; push dry-run OK.
Token `gh` di laptop kini punya scope `admin:public_key` (di-refresh untuk mendaftarkan key itu).

## Batch 2026-10-06 — persistensi edit/hapus pesan (socket) ✅ selesai

**Akar masalah (ditemukan dari query DB, bukan dari kode):** edit & hapus pesan "sukses" di UI
(REST `200` + row `chat_message_audit`) tapi **tidak pernah sampai ke store pesan asli**.

- Store pesan live = **MongoDB `kolabri.chatlogs`** (`_id` ObjectId24-hex). Postgres
  `chat_messages` (UUID, Prisma `ChatMessage`) hanya berisi seed 2026-09-22…28 — **bukan data live**.
- `chat_message_audit.message_id` merujuk ObjectId Mongo, jadi audit ≠ persistensi.
- **Bukti sebelum fix:** `WITH_DELETED_AT: 0` dari **1307** dokumen;3 pesan yang di-audit
  2026-10-04 (`6ac228ba…`, `6ac22a52…`, `6ac242d1…`) masih `content` asli, `version: 0`, `deletedAt: null`.

**Bug 1 — edit tak pernah tersimpan.** Klien `useSocketRoom` meng-emit `edit_message`, tapi
core-api **tidak punya listener sama sekali** → drop senyap. REST `MessageController::edit` hanya
`ChatMessageAudit::create` (Postgres), tak pernah menyentuh Mongo.
**Bug 2 — hapus tak pernah tersimpan.** Klien kirim `{messageId, sessionDiscussionId}`;
`deleteMessageSchema` minta **`roomId`** → zod reject → handler berhenti sebelum
`message.deletedAt = new Date()`.

**Fix (push):**
- `Kolabri-core-api@4b93a1a` — listener `registerEditMessage` (rate limit `edit_message`,
  validasi zod, cek room membership, owner-only, jendela24 jam sama dgn REST), skema
  `editMessageSchema`, `deleteMessageSchema` menerima `roomId` **atau** `sessionDiscussionId`
  (+ helper `resolveRoomId`), field `editedAt` di `ChatLog` + `ChatHistoryItem`, dan `editedAt`
  ikut di payload `chat_history` / `chat_history_page` (badge "diedit" selamat reload).
  `edit_message` ditambahkan ke `EVENT_LIMITS` (20/60s).
- `Kolabri-client-app@503c400` — kirim `roomId` di `edit_message` **dan** `delete_message`
  (keduanya tetap membawa `sessionDiscussionId`), buang argumen `oldContent` yang tak terpakai,
  map socket `editedAt` → display `edited_at`.
- Umbrella `6d33973` — bump kedua pointer.

**Deploy sumo1:** rsync `src/` + `resources/js/` (drift = **0 file** selain yang diubah),
backup lama di `/opt/kolabri/backups/pre-f3-persist-20261006-084219.tar`, rebuild
`core-api` + `client-app`, semua container healthy. Bundle produksi terverifikasi memuat
`edit_message",{…roomId:t,sessionDiscussionId:t}` dan `delete_message",{…roomId:t,…}`.

**Verifikasi live (E2E socket, JWT student Andi, tunnel ke core-api `:13000`):**
join room → kirim pesan → `edit_message` → `message_edited` → `delete_message` dengan **payload
lawas hanya `sessionDiscussionId`** → `message_deleted`. Hasil Mongo untuk
`6ac4bc1713838048f1f2de6c`: `content` = "[E2E] konten setelah edit", `editedAt` =
`2026-10-06T09:15:04.095Z`, `version: 1`, `deletedAt` = `2026-10-06T09:15:04.130Z` —
`TOTAL_DELETED_SET: 1` dan `TOTAL_EDITS_SET: 1` (dari nol sebelumnya).

**Uji regresi:** core-api `npm run build` bersih + `602 passed / 0 failed`.
client-app `tsc --noEmit` =27 error semuanya `@/routes/*` (wayfinder belum digenerate, pre-existing)
dan `vitest`3 file gagal — **sama persis saat working tree dibersihkan** (`git stash`), jadi bukan
regresi batch ini.

**Catatan operasional:**
- Semua52 `session_discussions` berstatus **closed**; untuk uji, sesi
  `31605650-eeba-4292-974a-8bca4e743c8b` dibuka sementara lalu **`closed_at` dikembalikan persis**
  `2026-10-04 09:19:25.13`.
- **nginx sumo1 ada dua file**: `sites-enabled/kolabri.web.id` (yang di-load, memuat fix route
  DELETE) ≠ `sites-available/kolabri.web.id` (stale, tanpa fix). Ubah yang `sites-enabled`,
  selalu cek dengan `sudo nginx -T`.
- vpsgw juga punya salinan nginx untuk `kolabri.web.id` yang **502** — produksi diservis sumo1.

## Batch 2026-10-06 — E2E seluruh flow (live) ✅ 42 PASS / 0 FAIL / 1 SKIP

Suite `e2e_flows/flows.js` (di mesin ini, tunnel SSH ke sumo1:13000) terhadap produksi:
mahasiswa (kelas/kelompok/sesi diskusi → pre-read → goal validator → chat/edit/hapus/@ai →
tutup → ringkasan → refleksi), dosen (analisis sesi, analytics, kehadiran), admin.
Verifikasi bukti: Postgres (session/goal/reflection/auto-attendance), Mongo
(`editedAt`/`deletedAt`), render UI headless Chrome (tab Attendance dosen, halaman analitik,
ruang chat sesi tertutup). Laporan: `docs/reports/audits/E2E_FLOW_TEST_2026-10-06.md` (commit `b917f52`).

- **F4 DIPERBAIKI** — `room.tsx` `isSummaryVisible` kini init dari `sessionDiscussion.isClosed`;
  terverifikasi live: reload sesi tertutup → `GET .../summary → 200` + kartu "Ringkasan Diskusi" tampil.
- **F10 DIPERBAIKI** — tab **"Sesi & Analisis"** di halaman kelas dosen: core-api
  `GET /api/courses/:id/sessions` (lecturer-only) + proxy client-app
  `LecturerSessionInsightController` (`/lecturer/courses/{c}/sessions[/detail]`) + `SessionsTab.tsx`
  (tujuan, ringkasan AI, skor kualitas+rekomendasi, metrik, kontribusi) + `DiscussionHealthWidget`
  kini dirender. Terverifikasi render nyata di browser.
- **F11 DIPERBAIKI** — legenda aturan kehadiran otomatis (`present = ≥3 pesan AND ≥1 HOT`)
  di tab Attendance; terverifikasi tampil.
- **Regresi penuh setelah deploy: 42 PASS / 0 FAIL / 1 SKIP**; core-api 602 passed/0 failed;
  client-app tsc & vitest = baseline identik (bukan regresi).
- **F3 DITUTUP (tidak repro lagi)** — klik nyata via programatis DAN koordinat asli
  (`Input.dispatchMouseEvent`) sukses: `PATCH .../edit` + `DELETE .../{id}` keluar, toast OK,
  persist Mongo (`editedAt`/`version`/`deletedAt`), console bersih. Handler identik dgn
  versi 4 Okt (`b9be6a1`); bundle berubah karena deploy `503c400`. Bukti:
  `e2e_flows/f3_repro.js`, `f3_trusted.js`.
- **F6 DIPERBAIKI (mahasiswa kini boleh pin)** — `PinnedMessageController::store` buang gate
  moderator; UI `canPin` untuk semua role + prop baru `canDeleteOthers` (hapus pesan orang
  lain tetap moderator/dosen). Live: pin mahasiswa `403→200`, klik "Sematkan pesan" → toast +
  `POST .../pin` → row `pinned_messages` (pinned_by=Andi); unpin via `DELETE .../pin`.
- **Chat @ai diau ulang pasca-deploy: OK** — sesi baru → pre-read → goal → pesan biasa →
  `@ai` dibalas **7.5 dtk / 1537 karakter** (jujur "tidak ada dokumen materi" utk IF203,
  tanpa fallback error); sesi ditutup, ringkasan otomatis sesuai isi percakapan.
- Residu batch ini: sesi "Tes Chat AI …" (ditutup, ada ringkasan) + sesi E2E ke-N; 2 row
  `pinned_messages` (id1 sudah di-unpin via UI, id2 masih tersemat).
- Harness notes: `my-group` kosong = `200 {data:null}`; goal harus selaras materi minggu
  (validator bisa 2 ronde); login rate-limit 429 perlu backoff; kelas `min_members=2`
  menolak leave (by design).
- Residu: 3 sesi "E2E Analisis Dosen 1" (lengkap) di Kelompok A/IF203, grup
  "Kelompok Uji E2E" IF206 (`K9M26S93`), 1 enrollment Dewi di IF203; sesi gagal run awal sudah soft-delete.

## Open items (not started)

1. **CI**: core `ci.yml` runs `test:run` WITHOUT postgres →161 DB tests skip on GitHub; wiring service postgres now safe (proven green with live DB)
2. **OpenSpec backlog**:53 active change dirs vs9 archived (repo mandates spec-first + archive)
3. **Dead module**: `providerResolution.service.ts` + its unit test —0 production callers since `de64e41`; cleanup candidate (also leftover test-file refs)
4. Engine nits: `/metrics` Prometheus endpoint (metrics are log-based now), `enable_semantic_cache` flag, `B008`×2 in `documents.py`
5. `prompt_cache_hit_tokens` never appears with sumopod (provider doesn't return it) — auto-valuable if provider moves to DeepSeek/OpenAI
6. **F3 masih terbuka** — klik "Simpan edit"/"Hapus pesan" di UI tidak menghasilkan request
   (audit 2026-10-04: 0 panggilan `window.confirm` / `Array.prototype.find` / XHR). Backend kini
   sudah benar, jadi sisa murni di klien. Petunjuk statis: `handleDelete` (`room.tsx` baris ~1638)
   **tidak punya guard sebelum** `messages.find()` — kalau handler keburu jalan, `find` wajib
   tercatat; karenanya kemungkinan klik tak sampai ke handler. Perlu repro di browser nyata
   (klik + Network tab).


## 2026-10-06 · SRL Zimmerman end-to-end (ai-engine + core-api + client-app)
**Sebelum:** hanya pesan @ai sampai ke classifier; distribusi 64% fase default (performance, conf 0.3); tak ada satupun tampil di UI; kolom SRL hilang di CSV.
**Sekarang (semua live & terverifikasi):**
- Classifier: pola `kasus terburuk*` + `apakah/bisakah/dapatkah` → default 64%→7%, sub-phase 2→6 (57 unit + 31 edge cases + 4 route test hijau).
- Endpoint baru `POST /api/srl/classify` (api/routes/srl.py, auth Bearer secret) — core-api `classifySrl` fire-and-forget dari socket untuk pesan non-@ai; hanya log bila ada indikator nyata (CaseID `<groupId>_session_<sessionDiscussionId>`).
- core-api `AnalyticsService.getSrlDistribution()` → field `srl` di group/session/course analytics.
- UI dosen: radar analitik menampilkan share real (bukan estimasi) + legend "Fase SRL Zimmerman dari N pesan"; tab Sesi & Analisis blok "Fase SRL Zimmerman" per-sesi (distribution + sub-phase + sampel pesan).
- CSV export engine: kolom `srl_phase,srl_sub_phase,srl_confidence`.
- Backfill: 1250 pesan lama terklasifikasi (P1023/R221/F6) — total 1276 event SRL di activity_logs.
- Bonus fix: `StudentCourseController::closeSession` BFF timeout 10s→30s (ringkasan LLM bisa >10s; sebelumnya close sukses tapi klien 500).
**Bukti live:** sesi uji 3b6e4250 →3 pesan biasa terklasifikasi forethought .92 / performance .95 / reflection .87; group analytics total 38 (F1/P34/R3, avg 79%); course total 96; UI kelompok & sesi tampil nyata; ekspor CSV berkolom SRL.


## 2026-10-06 · Batch 3: cakupan route mahasiswa sisa + audit dosen penuh
- 38 tes route mahasiswa baru (s2a/s2b2/s2c/s2d) → semua PASS setelah fix.
- Fix M1: `PUT /api/users/me` tak pernah ada (mount `/api/users` + route /me, admin tetap 403). Fix M2: guard `deletedAt` join/invite/getGroupById grup (bug join grup terhapus terbukti live). M3 OPEN: update role anggota = dead feature (route 404, tanpa kolom role di DB, tanpa UI) — perlu keputusan implement/buang.
- Fix D1: `LecturerMaterialsController::index()` tak pernah dibuat (GET materials 500). Fix D2: renumber week dua fase (reorder 500 unique violation). Fix D3: endpoint core-api analytics live/trends/share + halaman shared.tsx diimplement (fitur dosen sebelumnya mati 404 total; share token stateless JWT+exp). Fix D4: alias `GET /api/analytics/export?courseId=`.
- Deploy & verifikasi live semua fix; vitest core-api 602/0; client tsc baseline 27.
- Commits: core-api `caf7b5b`, `f810845`; client-app `291365d`.


## 2026-10-06 · Batch 4: retrieval RAG per-minggu (empiris)
- Uji: sesi Minggu 3 tanya materi Minggu 1 → citations lintas minggu **5/5 PASS** + sidebar Chrome menampilkan tepat dokumen terkutip.
- 4 bug ditemukan & fix live: R1 client-app `assignMaterial` kirim path Laravel ke core-api (re-ingest week_index gagal) → `CoreApiFilePath::resolve()`; R2 ai-engine ingest duplikat buang metadata minggu → `update_payload_metadata()` merge ke chunk existing; R3 ai-engine ungrounded result tanpa citations → ikutkan `sources_to_citations`; R4 core-api stream timeout 30s < cold-start reranker45s → `STREAM_TIMEOUT` 120s.
- Desain: filter per-minggu sengaja OFF (AI akses seluruh kelas) + boost minggu sesi; sidebar = dokumen terkutip saja.
- Regresi: core-api602/0; subset engine651/24failed — A/B terbukti pre-existing (identik kode lama).
- Commit: ai-engine `cae6204`, core-api `a29527b`, client-app `0106e85`.


## 2026-10-07 · Rate limit dimatikan sementara
- Permintaan user: matikan rate limit untuk sekarang.
- Kode: `socketRateLimiter.ts` (flag SOCKET_RATE_LIMIT=0) + `rateLimiter.ts` express (flag RATE_LIMIT_DISABLED=1, via opsi skip) — default TETAP aktif, hanya mati saat env diset.
- Deploy: docker-compose sumo1 blok core-api tambah `SOCKET_RATE_LIMIT: "0"` + `RATE_LIMIT_DISABLED: "1"` (backup `docker-compose.yml.bak-ratelimit`).
- Verifikasi live:15 pesan serentak <10s (batas lama10) → 15/15 diterima,0 rate-limit event;150 request paralel (batas global lama100/15m) →0×429. Vitest602/0.
- Cara mengaktifkan lagi: hapus2 baris env itu dari compose lalu `docker compose up -d core-api`.
- Catatan: throttle login Laravel (5/5m per IP,10/jam per email) TIDAK dimatikan.
