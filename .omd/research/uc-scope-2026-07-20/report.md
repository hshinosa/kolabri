# Research Report: Use Case Scope Corrections (13 user claims)

**Session:** uc-scope-2026-07-20  
**Date:** 2026-07-20  
**Status:** complete  

## Executive Summary

User corrections re-scope Use Case Inti to match product intent (experiment/research phase), not every route that still exists in code. Key outcomes: (1) session creation is shared Dosen+Mahasiswa; (2) analytics dashboard is Dosen-only in UC-inti, student analytics = future work; (3) AI config = Admin only; (4) student UC IDs should be renumbered into a continuous flow; (5) Logic Listener is a separate support service that *detects*, AI Intervention *generates* responses; (6) pre-read is always required for room entry, shared goal is create-once by any member then others only need pre-read; (7) AI chat mandiri is fully separate; reflection remains a UC tied to end-of-session (page may list history); (8) consent/privacy surfaces out of UC-inti; (9) notifications = future; (10–12) reflection templates/tags, AI chat bookmarks/pages, admin course templates = out of UC-inti (even if routes remain in code); (13) process mining = future / experimental, not UC-inti.

Note: several “removed” features still have routes/pages in `Kolabri-client-app` (bookmarks, reflection templates, student analytics, course templates). Scope decision for **SRS/SDD/UC diagram** is product claim for defense; code cleanup is a separate task.

## Answers to 13 Points

### 1. Pembuatan sesi: mahasiswa + dosen
**Agree.** Code has `storeSessionDiscussion` under both `role:lecturer` and `role:student`.  
**UC impact:** UC buat sesi actor = **Dosen, Mahasiswa** (not Dosen only).

### 2. Dashboard analitik: dosen only; mahasiswa analytics = future
**Agree for UC-inti.** Lecturer analytics routes are thick. Student has `/student/dashboard/analytics` and reflection analytics in code, but product claim for docs: **student analytics = Future Works (FR masa depan)**.  
**UC impact:** UC-030 actor = **Dosen only**. Drop student association to analytics.

### 3. Kelola konfigurasi AI: Admin only
**Agree.** Admin `ai-settings` is the operational surface.  
**UC impact:** UC-036 actor = **Administrator only**.

### 4. Rapihin flow UC ID mahasiswa (tidak loncat)
**Agree.** Use a **continuous student block** for readability while keeping catalog notes.  
Recommended student-facing continuous IDs in diagram/table:

| New sequential label | Meaning | Maps to FR |
|---|---|---|
| UC-S01 / keep UC-001 | Registrasi | FR-001 |
| UC-S02 / keep UC-002 | Login | FR-001 |
| UC-S03 | Join course | FR-006 |
| UC-S04 | Join/kelola group | FR-010 |
| UC-S05 | Buat sesi diskusi (shared w/ dosen) | FR-011 |
| UC-S06 | Pre-read | FR-008 |
| UC-S07 | Tetapkan shared goal (once per sesi) | FR-014 |
| UC-S08 | Ikut diskusi real-time | FR-012 |
| UC-S09 | Submit refleksi pasca-sesi | FR-015 |
| UC-S10 | Chat AI mandiri | FR-020 |

**Decision for implement:** Prefer **renumber student inti as UC-001…UC-010 sequential** and move dosen/admin to UC-011+ **or** keep stable catalog but show “Flow index” column. User asked to rapihin loncat → **resequence inti diagram**.

Proposed final ID set (sequential inti):

| ID | Nama | Aktor |
|---|---|---|
| UC-001 | Registrasi | Mhs, Dosen, Admin |
| UC-002 | Login | Mhs, Dosen, Admin |
| UC-003 | Bergabung Mata Kuliah | Mahasiswa |
| UC-004 | Bergabung/Kelola Kelompok | Mahasiswa |
| UC-005 | Membuat Sesi Diskusi | Mahasiswa, Dosen |
| UC-006 | Menyelesaikan Pre-Read | Mahasiswa |
| UC-007 | Menetapkan Tujuan Belajar (shared) | Mahasiswa |
| UC-008 | Ikut Diskusi Real-Time | Mahasiswa |
| UC-009 | Submit Refleksi | Mahasiswa |
| UC-010 | Chat AI Mandiri | Mahasiswa |
| UC-011 | Pembuatan / Kelola Mata Kuliah | Dosen |
| UC-012 | Upload Knowledge Base *(opsional digabung 011)* | Dosen |
| UC-013 | Dashboard Analitik | Dosen |
| UC-014 | Deteksi Anomali Diskusi (Logic Listener trigger surface) | AI System, Dosen |
| UC-015 | Kelola Konfigurasi AI | Administrator |

### 5. Logic Listener vs AI Intervention
**Separate layers, not the same oval.**

| Komponen | Role | Code |
|---|---|---|
| **Logic Listener** | **Deteksi** silence, off-topic, participation inequity, quality signals | `Kolabri-ai-engine/app/services/logic_listener.py` |
| **AI Intervention** | **NLG / generate** prompt/summary/redirect when triggered | `Kolabri-ai-engine/app/services/intervention.py` + routes `/api/intervention/*` |
| **Escalation gate** | Core API timing/cooldown (nudge→probe→flag) | `Kolabri-core-api/src/socket/interventionGate.ts`, `escalation.service.ts` |

**UC/support design:**
- Support oval **S-LL Logic Listener** (detect)
- Support oval **S-IV AI Intervention** (respond)
- S-LL `--include-->` or triggers S-IV
- Both `<<extend>>` / attached to **UC-008 Diskusi Real-Time** (base discussion)

**Not** folded only into “AI Intervention” without Listener — that hides detection engine (thesis contribution).

Also keep:
- **S-GR AI Guardrails** on AI output (017-like / chat personal / session AI)
- **S-GV AI Goal Validation** on UC-007 goal
- Optional: **S-RAG** only if diagram needs explicit RAG (else fold into “AI Fasilitasi” include)

### 6. Pre-read & goals (shared goal once)
**Code-aligned.** `goal.service.ts`: *shared goal for entire session discussion*; first member creates, others reuse.

| Gate | Siapa | Wajib? |
|---|---|---|
| Pre-read complete | **Setiap** anggota sebelum masuk room | Ya always |
| Goal | **Salah satu** anggota (saat/sebelum sesi aktif); shared | Ya 1× per sesi; anggota lain **tidak** create ulang |

**UC modeling:**
- UC-006 Pre-Read: `<<include>>` from UC-008 Diskusi (all members)
- UC-007 Goal: created by session creator or any first member; **alternative flow**: if shared goal exists → skip create, only pre-read

### 7. Chat AI mandiri + refleksi
**Chat AI mandiri:** fully separate vertical — no include/extend ke sesi diskusi. Own UC-010.  
**Refleksi:** keep **UC-009** as core because: (a) end-of-session reflection is product SRL; (b) ada page history `/student/reflections` for list/view — but **inti use case** = *submit refleksi setelah sesi*, not template management. Page index = UI of same UC, not separate UC.

### 8. Consent / privacy stack
**Out of UC-inti and drop from FR body claims for experiment phase.**  
Align with openspec changes `remove-privacy-and-consent-stack` / presentation hide.  
FR-003 consent/export/retention → remove or future/research footnote only. No consent UC.

### 9. Notifikasi
**Future Works.** FR-026 → appendix future. No UC, no NFR as must-have for defense.

### 10. Template refleksi / tag
**Out of UC-inti.** Even if routes remain, product story: **tidak ada**. Cleanup code later. UC-009 = free-text/session reflection only.

### 11. Bookmark AI chat
**Out.** Only lightweight template **in chatbox** (inline prompts), not dedicated page/modal CRUD. UC-010 description: stream chat + optional inline templates; **no** bookmarks/saved-materials in SRS claim.

### 12. Master data / course templates admin
**Out of UC-inti.** Admin inti: users ops (if needed) + **UC-015 AI config** only for AI story. No course-template UC. Course CRUD = Dosen UC-011.

### 13. Process mining “berat”
**Positioning:**
- **Bukan UC-inti produk.**
- Kalau masih diklaim di AI-engine thesis: **evaluation/research capability** (event log XES-compatible export / plan-vs-reality analysis) under **Future / experimental appendix**, or “backend analytics pipeline” without student/dosen dedicated UC.
- Route `plan-vs-diskusi` exists as experimental surface — **do not** put on main UC diagram.
- FR-030 → Future Works (or “research logging only”).

---

## Revised Use Case Inti Plan (authoritative)

### Primary UCs

| ID | Nama | Aktor | Include/Extend |
|---|---|---|---|
| UC-001 | Registrasi | Mhs, Dosen, Admin | — |
| UC-002 | Login | Mhs, Dosen, Admin | — |
| UC-003 | Bergabung Mata Kuliah | Mahasiswa | — |
| UC-004 | Bergabung/Kelola Kelompok | Mahasiswa | — |
| UC-005 | Membuat Sesi Diskusi | Mahasiswa, Dosen | — |
| UC-006 | Menyelesaikan Pre-Read | Mahasiswa | included by UC-008 |
| UC-007 | Menetapkan Tujuan Belajar (shared) | Mahasiswa | includes S-GV; skip if exists |
| UC-008 | Ikut Diskusi Real-Time | Mahasiswa | includes UC-006, S-AI (RAG+guardrails); extended by S-LL/S-IV |
| UC-009 | Submit Refleksi (pasca-sesi) | Mahasiswa | after session close |
| UC-010 | Chat AI Mandiri | Mahasiswa | includes S-GR (+RAG); **no** link to UC-008 |
| UC-011 | Kelola Mata Kuliah (+ KB) | Dosen | — |
| UC-012 | Dashboard Analitik | Dosen | — |
| UC-013 | Kelola Konfigurasi AI | Administrator | — |

(Merge old “UC-018 Deteksi” into **support+extension** of UC-008 rather than human primary oval, OR keep thin primary UC for Dosen “Pantau kesehatan diskusi” if needed — prefer support path.)

### Support ovals

| ID | Nama | Role |
|---|---|---|
| S-GV | AI Goal Validation | validate SMART/Bloom |
| S-AI | AI Fasilitasi / RAG | answer with grounding in session |
| S-GR | AI Guardrails | input/output safety |
| S-LL | Logic Listener | detect silence/off-topic/inequity |
| S-IV | AI Intervention | generate intervention NLG |

Flow support:
`S-LL detect → S-IV generate → message into UC-008 room`  
`S-AI → S-GR`  
`UC-007 → S-GV`  
`UC-010 → S-GR (+ retrieval)`

### Happy path

```
UC-001/002
 → UC-003 Join course
 → UC-004 Join group
 → UC-005 Create session (Mhs or Dosen)
 → UC-006 Pre-read (all)
 → UC-007 Goal once (any member; others skip)
 → UC-008 Diskusi (+ S-AI, S-GR, S-LL, S-IV)
 → UC-009 Reflection
∥ UC-010 AI personal (independent)

Dosen: UC-011 course, UC-012 analytics, view interventions from S-LL/S-IV
Admin: UC-013 AI config
```

### Out of UC-inti / Future / Drop

| Item | Bucket |
|---|---|
| Student dashboard analytics | Future FR |
| Notifications | Future FR |
| Consent/privacy UI & FR-003 body claim | Drop (experiment phase) |
| Reflection templates/tags | Drop from claims |
| AI chat bookmarks / dedicated template pages | Drop; inline only |
| Admin course templates / master templates | Drop from claims |
| Process mining / plan-vs-reality | Future/research appendix |
| FR-026, FR-030, heavy FR-032 template ops | Future or drop |

---

## Doc update checklist (when applying)

1. SRS §5 UC table + descriptions (resequence IDs)  
2. SRS §3 FR: reclassify future/drop (analytics mhs, notif, process mining, consent)  
3. SRS §10 US→FR + RTM simplify  
4. SDD sequences/actors align (session create dual role; admin-only AI)  
5. Drawio UC page rewrite layout  
6. Regenerate DOCX  
7. Optional later: code cleanup dead template/bookmark/consent routes (separate change)

## Confidence

| Claim | Confidence |
|---|---|
| Dual role session create | HIGH (routes both roles) |
| Shared goal once | HIGH (goal.service tests/comments) |
| Logic Listener ≠ Intervention | HIGH (separate modules) |
| Student analytics exists in code but user wants future | HIGH (user policy override for docs) |
| Templates/bookmarks still in code but out of claim | HIGH (routes still present) |

## Limitations

- Did not re-audit full Prisma for consent tables cleanup status.  
- Did not implement docs/diagram changes in this research pass — plan only per user request “jawab dulu… sesuaikan perencanaan”.
