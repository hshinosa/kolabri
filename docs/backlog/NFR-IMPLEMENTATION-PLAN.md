# NFR Implementation Plan — Kolabri

> **Tanggal**: 10 Juni 2026
> **Sumber**: final-requirements-gap-matrix.md + codebase audit
> **Scope**: 9 NFR yang belum fully implemented

---

## Prioritas Global

| Rank | NFR | Judul | Prioritas | Effort | Alasan |
|---:|---|---|---|---|---|
| 1 | NFR-PERF-02 | Dashboard TTI < 2s | 🔴 HIGH | 🟢 Low | Infra cache udah ada, tinggal dipasang. Impact langsung ke UX dosen. |
| 2 | NFR-RELIABILITY-02 | Autosave/Stability | 🔴 HIGH | 🟡 Medium | Pain nyata dari mahasiswa (Daffa). Data loss = trust loss. |
| 3 | NFR-MNT-02 | AI Explainability | 🔴 HIGH | 🟡 Medium | Metadata explanation udah ada di AI Engine, tinggal persist + surface. Audit trail AI penting buat akuntabilitas. |
| 4 | NFR-SEC-02 | Data Privacy | 🟠 MEDIUM-HIGH | 🟡 Medium | Compliance penting, tapi konteks akademik Indonesia belum ketat. Tetap perlu baseline. |
| 5 | NFR-DATA-02 | Data Export/Portability | 🟠 MEDIUM-HIGH | 🟡 Medium | Dosen butuh rekap data. Export infrastructure bisa dipakai buat NFR-DATA-01 juga. |
| 6 | NFR-DATA-01 | Data Retention Policy | 🟡 MEDIUM | 🟡 Medium | Soft delete udah ada. Perlu enforcement + cleanup. |
| 7 | NFR-UI-02 | Mobile Responsiveness | 🟡 MEDIUM | 🟡 Medium | Responsive framework bagus, tapi detail mobile polish kurang. |
| 8 | NFR-USABILITY-04 | Discussion Control/Visibility | 🟢 LOW-MEDIUM | 🟠 High | Soft requirement — sulit di-quantify. Fitur pendukung udah ada. |
| 9 | NFR-INTEG-02 | LTI/LMS Standard | ⚪ LOW | 🔴 High | Evidence lemah. Effort tinggi. Skip dulu. |

---

## 1. NFR-PERF-02 — Dashboard TTI < 2s

### Kondisi Saat Ini
- `SimpleCache` (in-memory, 5min TTL) ada di `src/utils/cache.ts` — **hanya dipakai di `course.service.ts`**
- `RedisCache` ada di AI Engine `app/core/redis_cache.py` — **analytics route bypass cache**
- `dashboard.service.ts` jalankan 14 parallel Prisma query + fetch 5000 message buat in-memory filter **setiap request**
- `analytics.service.ts` MongoDB aggregation tanpa cache
- Nol `Cache-Control` header, nol pre-aggregation, nol materialized view

### Rencana Implementasi

#### Task 1.1: Wire SimpleCache ke Dashboard Service
**File**: `Kolabri-core-api/src/services/dashboard.service.ts`
- Wrap `getStats()`, `getActivityFeed()`, `getUserGrowthChart()`, `getMessageActivityChart()` dengan `SimpleCache`
- TTL: 30 detik (dashboard perlu relatif fresh, tapi 30s cache masih 30x improvement vs 0)
- Invalidasi: manual via `cache.delete('dashboard:*')` saat event penting (new message, new user)

```ts
// Contoh pattern
const cacheKey = `dashboard:stats:${courseId}`;
const cached = cache.get(cacheKey);
if (cached) return cached;
const result = await heavyQuery();
cache.set(cacheKey, result, 30); // 30s TTL
return result;
```

#### Task 1.2: Wire RedisCache ke AI Engine Analytics
**File**: `Kolabri-ai-engine/app/api/routes/analytics.py`
- Gunakan `redis_cache.get_or_set()` dengan TTL `analytics: 300` (5 menit, udah didefinisikan di config)
- Wrap: `/analytics/dashboard/group/{id}`, `/analytics/engagement`, `/analytics/export/{id}`

#### Task 1.3: Optimasi Dashboard Query
**File**: `Kolabri-core-api/src/services/dashboard.service.ts`
- Ganti `take: 5000` + in-memory filter → DB-level aggregation (Prisma `groupBy` atau raw SQL)
- Pre-aggregate message activity chart ke summary table / materialized view
- Tambah `Cache-Control: public, max-age=30` header di response

#### Task 1.4: Cache Invalidation Hook
**File**: `Kolabri-core-api/src/socket/index.ts`
- Saat `send_message` berhasil → invalidate `dashboard:stats:*` dan `dashboard:message-activity:*`
- Saat user join/leave course → invalidate `dashboard:stats:*`

### Success Criteria
- [ ] Dashboard `/api/admin/dashboard/stats` response time < 500ms (cached)
- [ ] Dashboard `/api/admin/dashboard/stats` response time < 2s (cold)
- [ ] AI Engine analytics endpoint response time < 1s (cached)
- [ ] Cache hit rate > 80% pada normal traffic

---

## 2. NFR-RELIABILITY-02 — Autosave/Stability/Data-loss Prevention

### Kondisi Saat Ini
- Optimistic message pattern ada (`sending/sent/failed` status)
- Manual retry via "Coba lagi" button
- Socket reconnection: 5 attempts, flat 1s delay
- **Nihil**: draft autosave, offline queue, auto-retry with backoff, conflict resolution

### Rencana Implementasi

#### Task 2.1: Draft Autosave ke localStorage
**File**: `Kolabri-client-app/resources/js/pages/student/chat/room.tsx`
- Simpan draft message ke `localStorage` dengan key `draft:{chatSpaceId}:{userId}`
- Debounce 1 detik (gunakan `useDebounce` hook yang udah ada)
- Restore draft saat page load / rejoin room
- Clear draft saat message berhasil terkirim
- Juga apply ke: AI chat input, reflection input, goal input

```ts
// Pattern
const [message, setMessage] = useState(() => {
  return localStorage.getItem(`draft:${chatSpaceId}:${userId}`) ?? '';
});

useDebounce(() => {
  if (message.trim()) localStorage.setItem(`draft:${chatSpaceId}:${userId}`, message);
  else localStorage.removeItem(`draft:${chatSpaceId}:${userId}`);
}, 1000, [message]);
```

#### Task 2.2: Offline Message Queue (Outbox)
**File**: `Kolabri-client-app/resources/js/hooks/useSocketRoom.ts`
- Buat `useMessageOutbox` hook
- Saat `emitChatMessage()` dipanggil tapi `!socketRef.current` → simpan ke IndexedDB outbox
- Saat socket reconnect → flush outbox (kirim semua pending messages berurutan)
- Status: `pending` → `sending` → `sent`/`failed`

#### Task 2.3: Auto-retry with Exponential Backoff
**File**: `Kolabri-client-app/resources/js/features/chat/optimistic-message.ts`
- Failed message: auto-retry max 3x dengan backoff (1s, 2s, 4s)
- Setelah 3x gagal → tampilkan "Coba lagi" button (manual retry)
- Jitter: `delay * (0.5 + Math.random() * 0.5)` untuk menghindari thundering herd

#### Task 2.4: Socket Reconnection Improvement
**File**: `Kolabri-client-app/resources/js/hooks/useSocketRoom.ts`
- Ganti `reconnectionAttempts: 5` → `Infinity` (jangan pernah give up)
- Ganti `reconnectionDelay: 1000` → exponential backoff: 1s, 2s, 4s, 8s, 16s, max 30s
- Tambah jitter: `delay * (0.5 + Math.random() * 0.5)`
- Re-auth on reconnect: udah ada, tapi perlu retry token refresh max 2x

#### Task 2.5: Conflict Resolution (Basic)
**File**: `Kolabri-core-api/src/socket/index.ts`
- Tambah `version` field di message edit
- Saat edit: cek `version` match, jika mismatch → reject edit, return current version
- Client: jika edit rejected → tampilkan pesan terbaru + notifikasi "Pesan telah diubah orang lain"

### Success Criteria
- [ ] Draft message survive page refresh
- [ ] Draft message survive navigation away + back
- [ ] Offline message queue flush on reconnect
- [ ] Auto-retry 3x with backoff before showing "Coba lagi"
- [ ] Socket reconnect with exponential backoff (no flat delay)
- [ ] Edit conflict detected and surfaced to user

---

## 3. NFR-MNT-02 — AI Explainability / Audit Log

### Kondisi Saat Ini
- AI Engine return rich metadata: `reason`, `guardrail_reason`, `intervention_type`, `explanation`, `rationale`
- Core API socket handler **drop semua metadata** saat save ke ChatLog — cuma `content` yang disimpan
- Audit log capture guardrail triggers, tapi normal AI responses nggak di-audit
- Escalation history ada `reason` tapi student nggak lihat

### Rencana Implementasi

#### Task 3.1: Extend ChatLog Schema dengan Explanation Fields
**File**: `Kolabri-core-api/src/models/ChatLog.ts`
- Tambah field:
  ```ts
  guardrailReason: String,      // e.g., "prompt_injection", "off_topic"
  guardrailOutcome: String,     // e.g., "blocked", "modified", "allowed"
  interventionType: String,     // e.g., "low_lexical", "silence_nudge", "participation_inequity"
  interventionReason: String,   // e.g., "Silence detected, sending nudge"
  scaffoldingLevel: String,     // e.g., "high", "medium", "low"
  qualityScore: Number,         // engagement quality score
  ```
- Semua optional (backward compatible)

#### Task 3.2: Persist AI Metadata di Socket Handler
**File**: `Kolabri-core-api/src/socket/index.ts` (line ~992-1003)
- Saat save `ChatLog`, include metadata dari AI Engine response:
  ```ts
  const chatLog = new ChatLog({
    // ... existing fields
    content: response,
    guardrailReason: orchestrationResult.guardrail_reason,
    guardrailOutcome: orchestrationResult.guardrail_outcome,
    interventionType: orchestrationResult.intervention_type,
    interventionReason: orchestrationResult.reason,
    scaffoldingLevel: orchestrationResult.scaffolding_level,
    qualityScore: orchestrationResult.quality_score,
  });
  ```

#### Task 3.3: Audit Log untuk Semua AI Responses
**File**: `Kolabri-core-api/src/socket/index.ts`
- Log semua AI responses (bukan cuma guardrail triggers) ke `prisma.auditLog`
- Action: `ai_response_generated`
- Metadata: `{ interventionType, guardrailOutcome, scaffoldingLevel, qualityScore }`

#### Task 3.4: Surface Explanation ke User (UI)
**File**: `Kolabri-client-app/resources/js/pages/student/chat/room.tsx`
- Tampilkan badge kecil di message AI: "Intervensi: {reason}" atau "Guardrail: {outcome}"
- Tooltip/click buat detail lengkap
- Hanya tampilkan jika `interventionType` atau `guardrailReason` ada
- Lecturer view: tampilkan semua AI explanation metadata di chat history

#### Task 3.5: Escalation Reason Visibility
**File**: `Kolabri-client-app/resources/js/pages/lecturer/dashboard.tsx`
- Di escalation panel, tampilkan `reason` dari history entries
- Student: tampilkan "AI sedang membantu mengarahkan diskusi" saat intervention aktif

### Success Criteria
- [ ] ChatLog menyimpan `guardrailReason`, `interventionType`, `qualityScore`
- [ ] Semua AI responses ter-audit di `auditLog`
- [ ] User bisa lihat kenapa AI intervene (badge/tooltip di chat)
- [ ] Lecturer bisa lihat escalation reason di dashboard

---

## 4. NFR-SEC-02 — Data Privacy

### Kondisi Saat Ini
- Account deletion (soft) ada, hard delete (admin only) ada
- Nihil: consent management, privacy policy, user data export, privacy preferences, cascade delete

### Rencana Implementasi

#### Task 4.1: Privacy Policy Endpoint
**File baru**: `Kolabri-core-api/src/routes/privacy.routes.ts`
- `GET /api/privacy/policy` — return privacy policy document (versioned)
- `GET /api/privacy/data-categories` — return kategori data yang dikumpulkan + tujuan
- Policy disimpan di config/DB, bisa di-update admin

#### Task 4.2: Consent Tracking
**File**: `Kolabri-core-api/prisma/schema.prisma`
- Tambah model `ConsentRecord`:
  ```prisma
  model ConsentRecord {
    id          String   @id @default(cuid())
    userId      String
    user        User     @relation(fields: [userId], references: [id])
    consentType String   // "privacy_policy", "data_collection", "ai_interaction"
    version     String   // policy version
    grantedAt   DateTime @default(now())
    revokedAt   DateTime?
    @@index([userId, consentType])
  }
  ```
- `POST /api/privacy/consent` — user accept privacy policy
- `DELETE /api/privacy/consent/:type` — user revoke consent
- `GET /api/privacy/consent` — list user's consent status

#### Task 4.3: User Data Export ( Portability)
**File baru**: `Kolabri-core-api/src/services/data-export.service.ts`
- `POST /api/user/data-export` — trigger export semua data user:
  - Profile data (Prisma User)
  - Chat messages (MongoDB ChatLog)
  - AI chat history (Prisma AiChat + AiChatMessage)
  - Learning goals (Prisma LearningGoal)
  - Reflections (Prisma Reflection)
  - Analytics summary
- Format: JSON bundle (zip file)
- Async: return job ID, user bisa download saat ready
- Rate limit: 1 export per 24 jam

#### Task 4.4: Cascade Delete pada Account Deletion
**File**: `Kolabri-core-api/src/services/account-deletion.service.ts`
- Saat user delete account, selain soft-delete user:
  - Anonymize chat messages (ganti senderName → "Deleted User")
  - Delete AI chat history
  - Delete learning goals
  - Delete reflections
  - Delete notifications
  - Keep audit log (compliance requirement)
- Tambah scheduled job: setelah 30 hari soft-delete → hard delete semua related data

#### Task 4.5: Privacy Preferences
**File**: `Kolabri-core-api/src/services/user-preferences.service.ts`
- Extend user preferences dengan privacy controls:
  - `analyticsVisibility`: "lecturer_only" | "private" — siapa bisa lihat analytics saya
  - `aiInteractionConsent`: boolean — izinkan AI intervene di diskusi saya
  - `dataSharingConsent`: boolean — izinkan data saya dipakai buat research

### Success Criteria
- [ ] Privacy policy accessible via API
- [ ] User bisa accept/revoke consent
- [ ] User bisa export semua data mereka (JSON zip)
- [ ] Account deletion cascade ke related data
- [ ] Privacy preferences tersimpan dan dihormati sistem

---

## 5. NFR-DATA-02 — Data Export/Portability

### Kondisi Saat Ini
- `GET /api/analytics/export/:courseId` — process mining JSON (lecturer only)
- CSV import ada, export nihil
- Nihil: user data export, bulk download, PDF export

### Rencana Implementasi

#### Task 5.1: Analytics Export Enhancement
**File**: `Kolabri-core-api/src/services/analytics.service.ts`
- Extend `exportProcessMining` → support format: `json`, `csv`
- Tambah parameter `format` di query: `?format=csv|json`
- CSV: generate proper CSV with headers, stream response
- Tambah endpoint: `GET /api/analytics/export/:courseId/summary` — ringkasan analytics (bukan raw process mining)

#### Task 5.2: Course Data Export (Lecturer)
**File baru**: `Kolabri-core-api/src/services/course-export.service.ts`
- `POST /api/courses/:id/export` — export semua data course:
  - Course metadata + settings
  - Groups + members
  - Chat spaces + messages (JSON/CSV)
  - Learning goals
  - Reflections
  - Analytics summary
- Format: JSON atau CSV bundle (zip)
- Lecturer-only access

#### Task 5.3: User Data Export
- Sudah dicover di Task 4.3 (NFR-SEC-02)

#### Task 5.4: Export UI
**File**: `Kolabri-client-app/resources/js/pages/lecturer/analytics/show.tsx`
- Tambah "Export" dropdown: JSON, CSV
- Tambah "Export Course Data" button di course detail page
- Student: "Download Data Saya" button di profile/settings page

### Success Criteria
- [ ] Analytics export support CSV + JSON
- [ ] Lecturer bisa export course data bundle
- [ ] Student bisa export personal data
- [ ] Export UI accessible di relevant pages

---

## 6. NFR-DATA-01 — Data Retention Policy

### Kondisi Saat Ini
- Soft delete (`deletedAt`) ada di: User, Course, Group, ChatSpace, KnowledgeBase
- ChatLog (MongoDB) pakai `isDeleted: boolean` — inkonsisten
- Course archive/restore/permanent-delete ada
- Nihil: automated purge, TTL, scheduled cleanup, retention config

### Rencana Implementasi

#### Task 6.1: Standardize ChatLog Delete Pattern
**File**: `Kolabri-core-api/src/models/ChatLog.ts`
- Ganti `isDeleted: boolean` → `deletedAt: Date | null`
- Migration script: update existing `isDeleted: true` → `deletedAt: ISODate(creation_date)`, `isDeleted: false` → `deletedAt: null`
- Update semua query yang pakai `isDeleted: { $ne: true }` → `deletedAt: null`

#### Task 6.2: Retention Policy Model
**File**: `Kolabri-core-api/prisma/schema.prisma`
- Tambah model `DataRetentionPolicy`:
  ```prisma
  model DataRetentionPolicy {
    id              String   @id @default(cuid())
    dataType        String   @unique // "chat_log", "activity_log", "silence_event", "audit_log", "analytics"
    retentionDays   Int      // berapa hari data disimpan
    archiveAfterDays Int?    // setelah berapa hari data diarsip
    autoPurge       Boolean  @default(false) // auto delete setelah retention period
    updatedAt       DateTime @updatedAt
  }
  ```
- Default values:
  - `chat_log`: 365 hari, archive 180, autoPurge false
  - `activity_log`: 365 hari, archive 180, autoPurge false
  - `silence_event`: 90 hari, archive 60, autoPurge false
  - `audit_log`: 730 hari (2 tahun), archive 365, autoPurge false
  - `analytics`: 365 hari, archive 180, autoPurge false

#### Task 6.3: Retention Admin UI
**File**: `Kolabri-client-app/resources/js/pages/admin/dashboard.tsx`
- Tambah "Data Retention" section di admin settings
- Tabel: data type, retention days, archive days, auto-purge toggle
- Hanya admin bisa ubah

#### Task 6.4: Scheduled Cleanup Job
**File baru**: `Kolabri-core-api/src/jobs/retention-cleanup.ts`
- Cron job (daily): cek `DataRetentionPolicy` per data type
- Archive: set `isArchived=true` pada data yang melewati `archiveAfterDays`
- Purge: hard delete data yang melewati `retentionDays` DAN `autoPurge=true`
- Log setiap run ke audit log
- Gunakan `node-cron` atau external scheduler

#### Task 6.5: Soft Delete Cascade
**File**: `Kolabri-core-api/src/services/course-admin.service.ts`
- Saat course di-soft-delete → cascade soft-delete ke Group, ChatSpace, KnowledgeBase
- Saat course di-restore → cascade restore
- Saat course permanent-delete → cascade hard delete semua related data

### Success Criteria
- [ ] ChatLog konsisten pakai `deletedAt` (bukan `isDeleted`)
- [ ] Retention policy terdefinisi per data type
- [ ] Admin bisa configure retention via UI
- [ ] Scheduled cleanup job berjalan
- [ ] Soft delete cascade Course → Group → ChatSpace

---

## 7. NFR-UI-02 — Mobile Responsiveness

### Kondisi Saat Ini
- Tailwind responsive breakpoints luas (20+ file)
- Mobile sidebar drawer ada
- Viewport meta tag ada
- Touch targets minim, safe-area nihil, swipe gestures nihil

### Rencana Implementasi

#### Task 7.1: Touch Target Audit & Fix
**Scope**: Semua interactive elements di client app
- Audit semua button, link, input: minimum 44x44px touch target
- Tambah `min-h-[44px] min-w-[44px]` pada small buttons/icons
- Tambah `touch-manipulation` pada semua interactive elements (global CSS)
- Tambah `active:scale-[0.98]` untuk press feedback konsisten

#### Task 7.2: Safe Area Support
**File**: `Kolabri-client-app/resources/css/app.css`
- Tambah CSS custom properties:
  ```css
  :root {
    --safe-area-top: env(safe-area-inset-top, 0px);
    --safe-area-bottom: env(safe-area-inset-bottom, 0px);
    --safe-area-left: env(safe-area-inset-left, 0px);
    --safe-area-right: env(safe-area-inset-right, 0px);
  }
  ```
- Apply pada layout: `padding-top: var(--safe-area-top)`, dll
- Update `app.blade.php` viewport meta: tambah `viewport-fit=cover`

#### Task 7.3: Tap Highlight & Touch Optimization
**File**: `Kolabri-client-app/resources/css/app.css`
- Global: `-webkit-tap-highlight-color: transparent`
- Global: `touch-action: manipulation` pada interactive elements
- Global: `user-select: none` pada UI chrome, `user-select: text` pada content

#### Task 7.4: Swipe Gesture Sidebar
**File**: `Kolabri-client-app/resources/js/layouts/app-layout.tsx`
- Tambah swipe gesture: swipe right → open sidebar, swipe left → close
- Gunakan `touchstart`/`touchmove`/`touchend` events
- Threshold: 50px minimum swipe distance
- Hanya aktif di mobile (`window.innerWidth < 1024`)

#### Task 7.5: Mobile Chat UX Polish
**File**: `Kolabri-client-app/resources/js/pages/student/chat/room.tsx`
- Input area: fixed bottom, safe-area aware
- Message list: overscroll behavior, pull-to-refresh (load older messages)
- Keyboard handling: scroll to bottom saat keyboard muncul
- Image/attachment: tap to preview, long-press for options

### Success Criteria
- [ ] Semua interactive elements ≥ 44px touch target
- [ ] Safe-area insets handled di iOS
- [ ] Tap highlight suppressed globally
- [ ] Swipe gesture buka/tutup sidebar
- [ ] Chat input area mobile-friendly

---

## 8. NFR-USABILITY-04 — Directed Online Discussion Experience

### Kondisi Saat Ini
- Fitur pendukung ada: lock/unlock session, goal setting, AI intervention, escalation
- Nggak ada UX metric atau pattern yang explicitly measures "terarah" feel
- Ini soft requirement — sulit di-quantify

### Rencana Implementasi

#### Task 8.1: Discussion Progress Indicator
**File**: `Kolabri-client-app/resources/js/pages/student/chat/room.tsx`
- Tampilkan progress bar/indicator berdasarkan learning goal
- Metric: berapa persen pesan yang relevant ke goal (via AI topic classification)
- Visual: "🎯 60% diskusi relevan ke goal"

#### Task 8.2: Goal Alignment Badge
**File**: `Kolabri-client-app/resources/js/pages/student/chat/room.tsx`
- Setiap message: tampilkan badge "Relevan" / "Off-topic" (berdasarkan AI classification)
- Summary di top: "12/15 pesan relevan ke goal"

#### Task 8.3: Session Summary on Close
**File**: `Kolabri-core-api/src/services/chatSpace.service.ts`
- Saat chat space di-close → generate summary:
  - Goal tercapai atau tidak
  - Topik yang dibahas
  - Kontribusi per member
  - AI assessment: "Diskusi cukup terarah" / "Diskusi perlu perbaikan"
- Tampilkan summary saat lecturer close session + saat student buka reflection

#### Task 8.4: Discussion Health Dashboard
**File**: `Kolabri-client-app/resources/js/pages/lecturer/groups/show.tsx`
- Per chat space: tampilkan "health score" (0-100)
- Factor: goal alignment %, participation equity, message quality, intervention rate
- Color coding: 🟢 >70, 🟡 40-70, 🔴 <40

### Success Criteria
- [ ] Discussion progress visible ke student
- [ ] Goal alignment metric computed dan ditampilkan
- [ ] Session summary generated saat close
- [ ] Discussion health score visible ke lecturer

---

## 9. NFR-INTEG-02 — LTI/LMS Standard

### Kondisi Saat Ini
- Not implemented
- Evidence lemah (Pak Villy cuma nyebut LMS sebagai platform)
- Effort tinggi, value rendah

### Rekomendasi: **SKIP / DEFER**
- Tidak ada demand kuat dari wawancara
- Implementasi LTI 1.3 kompleks (OAuth2 + OIDC flow)
- Jika dibutuhkan di masa depan, bisa jadi phase terpisah
- Alternatif: export/import data via CSV/JSON (sudah dicover di NFR-DATA-02)

---

## Dependency Map

```
NFR-PERF-02 ──────────────────────────── (independent, quick win)
NFR-RELIABILITY-02 ──────────────────── (independent)
NFR-MNT-02 ──────────────────────────── (independent)
NFR-SEC-02 ──┬── NFR-DATA-02 ────────── (4.3 → 5.3 shared export service)
             └── NFR-DATA-01 ────────── (4.4 cascade delete → 6.5 soft delete cascade)
NFR-UI-02 ───────────────────────────── (independent)
NFR-USABILITY-04 ────────────────────── (depends on NFR-MNT-02 for AI metadata)
NFR-INTEG-02 ────────────────────────── (SKIP)
```

## Rekomendasi Urutan Eksekusi

**Wave 1 (Quick wins, 1-2 hari)**:
1. NFR-PERF-02 — Cache wiring (infra udah ada)
2. NFR-MNT-02 Task 3.1-3.3 — Persist AI metadata (schema + socket handler)

**Wave 2 (Core reliability, 3-5 hari)**:
3. NFR-RELIABILITY-02 — Autosave, offline queue, auto-retry
4. NFR-MNT-02 Task 3.4-3.5 — Surface explanation ke UI

**Wave 3 (Privacy & data, 5-7 hari)**:
5. NFR-SEC-02 — Privacy framework (consent, policy, cascade delete)
6. NFR-DATA-02 — Export enhancement (CSV, course export, user export)
7. NFR-DATA-01 — Retention policy + cleanup job

**Wave 4 (Polish, 3-5 hari)**:
8. NFR-UI-02 — Mobile responsiveness polish
9. NFR-USABILITY-04 — Discussion direction UX

**Total estimasi: 12-19 hari kerja**
