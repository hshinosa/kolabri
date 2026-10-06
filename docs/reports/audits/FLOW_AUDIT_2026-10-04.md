# Flow Audit — Aplikasi Kolabri (kolabri.web.id)

**Tanggal:** 4 Oktober 2026 · **Metode:** E2E live via browser headless (akun demo nyata) + inspeksi source/bundle + query DB produksi + instrumentasi jaringan (XHR/fetch) · **Eksekutor:** Shei (audit agentik)

Status: ✅ terbukti jalan (live) · ⚠️ anomali/butuh verifikasi manual · ❌ rusak (terbukti) · 📋 statis saja (route/kode ada, eksekusi belum)

---

##1. Flow Mahasiswa

| # | Flow | Status | Bukti |
|---|---|---|---|
|1| Login → dashboard/kelas | ✅ | login Andi/Uji/Admin live, redirect benar per role |
|2| Daftar kelas + detail (grup, sesi, kode) | ✅ | live, screenshot panduan terverifikasi |
|3| **Gabung kelas dengan kode gabung** | ✅ | kode `TMQK89` (IF208) → join sukses |
|4| **Gabung kelompok dengan kode** | 📋 | route `POST /groups/join` + UI "Gabung dengan Kode" ada; eksekusi live belum (testernya memilih buat grup) |
|5| **Buat kelompok baru** | ✅ | modal → "Kelompok Uji Panduan" jadi, kode `CQ2NLS2R` |
|6| Keluar kelompok | 📋 | UI + route `POST /:id/leave` ada; belum dieksekusi |
|7| Buat sesi diskusi (Sesi Baru) | ✅ |3 sesi dibuat live |
|8| Gerbang pre-read → tujuan | ✅ | redirect pre-read → goal page |
|9| **Validasi tujuan oleh AI** | ✅ (ketat) | non-SMART →400 + pertanyaan balik AI; versi spesifik+berwaktu → lolos (diuji3x) |
|10| Kirim pesan chat | ✅ | muncul + **bertahan setelah reload** |
|11| Muat pesan lebih lama | ✅ | tombol terlihat & terverifikasi vision |
|12| **@ai → jawaban streaming** | ✅ | engine `POST /api/chat/stream` 200, jawaban muncul |
|13| **Edit pesan (Ubah pesan)** | ✅ (API) | `PATCH .../edit → 200` + audit row; klik UI masih F3 |
|14| **Hapus pesan** | ✅ (API) | `DELETE .../{id} → 200` + audit row (setelah route nginx ditambah); klik UI masih F3 |
|15| Salin teks | 📋 | item menu ada |
|16| Pin/Unpin pesan | 📋 | route pin ada; item tak muncul di menu mahasiswa (kemungkinan khusus moderator — belum diverifikasi) |
|17| **Tutup sesi → ringkasan AI** | ✅ | modal konfirmasi → sesi ditutup → ringkasan live ±15 dtk (isi akurat) |
|18| Ringkasan setelah **reload** | ❌ diketahui | tidak pernah di-fetch ulang (0 GET summary) — sudah didokumentasikan sebagai workaround di panduan |
|19| Refleksi pasca-sesi | ✅ | `POST /reflection → 201`, gate hilang |
|20| Auto attendance pasca-tutup | ✅ | baris "Auto Attendance - <sesi>" muncul di tab dosen |
|21| AI Chat Assistant (kirim, riwayat) | ✅ | e2e percakapan + balasan tersimpan (sesi sebelumnya) |
|22| Profil/pengaturan (4 tab settings) | 📋 | halaman ada; tidak dieksekusi (hindari ubah data) |

##2. Flow Dosen

| # | Flow | Status | Bukti |
|---|---|---|---|
|1| Login → dashboard | ✅ | live (Budi) |
|2| Tab kelas: Aktivitas/Attendance/Materi + Aturan AI | ✅ | live, aturan guardrail AI tampil |
|3| **Kehadiran: daftar sesi + filter + Export CSV** | ✅ | live + screenshot |
|4| **Detail & koreksi kehadiran** | ✅ (lihat) | panel "Koreksi Kehadiran" (pesan/HOT/status/Simpan Koreksi) tampil; **eksekusi simpan belum diuji** |
|5| Kelola materi (upload/edit/hapus) | 📋 | kode+route ada; tidak dieksekusi |
|6| Analytics (index/detail/comparison/overview + Radar) | 📋 | **6 halaman ada** — panduan hanya membahas tab analytics; halaman standalone belum diuji |
|7| Buat kelas / hapus kelas / arsip | 📋 | tidak dieksekusi (hindari mutasi data dosen) |
|8| Kelola grup (daftar/detail/hapus anggota) | 📋 | kode ada; tidak dieksekusi |

##3. Flow Admin

| # | Flow | Status | Bukti |
|---|---|---|---|
|1| Login `admin@kolabri.id` | ✅ | masuk `/admin/dashboard` |
|2|5 halaman (Dasbor, Pengguna, Data Kelas, Pengaturan AI, Log Audit) | ✅ render | screenshot lengkap terverifikasi |
|3| Filter/pencarian (read-only) | 📋 | kontrol ada di UI |
|4| Mutasi (tambah pengguna, toggle provider, hapus) | 📋 sengaja | **tidak diuji** — mengubah data produksi |

**Catatan F7:** akun admin punya `email_verified_at = NULL` namun tetap bisa login (alur verifikasi email memblokir mahasiswa/dosen — admin tampak dibebankan/dilewati). Perlu dikonfirmasi: disengaja atau celah.

##4. Temuan (diurut keparahan)

### ✅ F1 — Edit pesan mengembalikan500 (DIPERBAIKI 2026-10-04)
- **Bukti:** `PATCH /api/chat/messages/{id}/edit` dengan sesi login valid → `500 Server Error`.
- **Akar (terbaca):** `MessageController::edit` baris22: `$userId = $request->user()->id;` — `$request->user()` = **null** → `Attempt to read property "id" on null` (laravel.log,3 kejadian =3 percobaan audit).
- **Konteks route:** route berada di grup `middleware('auth.jwt')` + `assert.chat.membership`; request ber-cookie sesi lolos middleware namun user tak ter-set →500, bukan401.
- **Dampak:** fitur "Ubah pesan" tidak bisa menyimpan untuk siapa pun yang memakai alur auth halaman (cookie) — editor tetap terbuka.

### ✅ F2 — Hapus pesan: jalur API 401 (DIPERBAIKI 2026-10-04; akar ganda)
- `DELETE /api/chat/messages/{id}` → `401 No token provided` (format error ala Core API) sementara route hanya bermiddleware `assert.chat.membership`. Selain itu `destroy()` juga memakai `$request->user()->id` (baris103) → rawan kasus sama dengan F1.

### Perbaikan F1/F2 (bukti verifikasi live)

**Akar 1 (kedua temuan):** `auth.jwt` (`app/Http/Middleware/JwtAuthMiddleware.php:73`) hanya
`$request->merge(['auth_user' => session('user')])` dan **tidak pernah mengisi auth guard Laravel**,
jadi `$request->user()` selalu `null`. `MessageController:22/103/120` + `PinnedMessageController:23/26/84`
memakai `$request->user()` → `Attempt to read property "id" on null` → 500.

**Akar 2 (khusus F2):** route `DELETE /api/chat/messages/{messageId}` **tidak terdaftar di nginx**
(`/etc/nginx/sites-enabled/kolabri.web.id:69` hanya mencocokkan `[^/]+/(edit|audit|pin)`), sehingga request
jatuh ke `location /api/` → core-api → `401 No token provided`. Ditambahkan `location ~ ^/api/chat/messages/[^/]+$`.

**Perubahan kode:** helper `resolveAuthUser()` di kedua controller (pola rumah: `auth_user` ?? `session('user')`,
tolak 401 jika kosong, cast id ke string; role check jadi strict `in_array(..., true)`).
Commit: `Kolabri-client-app@a74fa05`, pointer root `ac30a03`.

**Verifikasi live (kolabri.web.id, akun pemilik sesi):**
| Aksi | Sebelum | Sesudah |
|---|---|---|
| `PATCH /api/chat/messages/{id}/edit` | 500 | **200** + row `chat_message_audit(action=edit, user_id=620e742a…)` |
| `DELETE /api/chat/messages/{id}` | 401 | **200** + row `chat_message_audit(action=delete)` |
| Edit oleh non-anggota | 500 | **403** |
| Log client-app | 500 berulang | **0 error** |

> **UPDATE 2026-10-06:** penyebab tambahan ditemukan & diperbaiki — edit/hapus memang **tidak
> pernah tersimpan** ke store pesan (MongoDB `chatlogs`): listener `edit_message` tidak ada di
> core-api, dan `delete_message` dikirim dengan `sessionDiscussionId` sedangkan skema minta
> `roomId` → zod reject. Row `chat_message_audit` tetap terisi sehingga API terlihat `200`.
> Fix: `Kolabri-core-api@4b93a1a` + `Kolabri-client-app@503c400`, ter-deploy & terbukti live
> (`deletedAt`/`editedAt`/`version` kini terisi; sebelumnya **0 dari 1307** dokumen punya
> `deletedAt`). F3 di bawah (klik tak menghasilkan request) **masih terbuka** — sisa murni klien.
>
> **DITUTUP 2026-10-06:** direproduksi di browser nyata dengan **dua metode** — klik
> programatis (`el.click()`) dan **klik koordinat asli** (`Input.dispatchMouseEvent`, kena
> hit-testing) — keduanya sukses: `PATCH .../edit` + `DELETE .../{id}` keluar, toast
> "berhasil", **persist di Mongo** (`editedAt`+`version` / `deletedAt` terisi), console
> bersih, `window.confirm` & `Array.prototype.find` terpanggil normal. Kode handler identik
> dengan versi 4 Okt (commit `b9be6a1`); bundle berubah karena deploy `503c400` (6 Okt).
> Kesimpulan: tidak repro pada produksi terkini — jika muncul lagi, butuh 1 kasus klik user
> nyata untuk repro. Bukti: `e2e_flows/f3_repro.js` + `e2e_flows/f3_trusted.js`.

### ✅ F3 — Klik "Simpan edit"/"Hapus pesan" tidak menghasilkan request keluar browser (DITUTUP 2026-10-06 — tidak repro lagi)
- XHR/fetch di-patch: **0 request** setelah klik, baik di pesan baru maupun pesan lama hasil muat server; state editor benar (nilai terisi, tombol enabled); jalur keyboard Enter pun nihil.
- Bundle `MessageEditor`/`room` di produksi = source (dicek byte-level handler-nya identik).
- **Belum terpecahkan:** apakah `messages.find()` di `handleSaveEdit` gagal (array vs list render) atau hal lain — **butuh1 verifikasi manual di browser nyata** (apakah muncul error toast/permintaan jaringan saat klik Simpan). Kombinasi dengan F1: walau UI mengirim, server tetap500.

### ✅ F4 — Ringkasan tidak tampil setelah reload (DIPERBAIKI 2026-10-06)
> **UPDATE 2026-10-06 (E2E ulang):** masih terbukti buka — instrumentasi jaringan CDP pada
> muat ulang ruang chat sesi tertutup = **0 GET `/summary`** (API-nya sendiri `200`, 743 karakter).
> **Akar:** `resources/js/pages/student/chat/room.tsx:662` `isSummaryVisible` default `false`
> dan hanya di-set `true` di baris 579 (alur tutup sesi dalam halaman yang sama);
> `useChatSummary` (baris 750) memakai `enabled: isSummaryVisible`. Fix: init dari
> `sessionDiscussion.isClosed`. Rincian: `docs/reports/audits/E2E_FLOW_TEST_2026-10-06.md`.
> **FIXED & terverifikasi live 2026-10-06:** `useState(!!sessionDiscussion.isClosed)` — reload
> kini memanggil `GET .../summary → 200` dan kartu "Ringkasan Diskusi" tampil.
- Ringkasan tersimpan di DB (`summary_generated_at` + isi1491–1420 karakter) tapi halaman segar tidak mem-fetch (0 GET summary) — render hanya pada alur live pasca-tutup. Workaround terdokumentasi di panduan.

### 📌 F5 — Sitasi RAG mati di produksi
- Qdrant:9 collection `course_*` semuanya **`points_count:0`** (materi belum ter-ingest vektor) → `@ai` selalu menjawab "tidak menemukan dokumen" + panel "DIKUTIP DALAM DISKUSI" selalu "Belum ada sitasi".

### ✅ F6 — Pin pesan: route+komponen ada, tak muncul di menu mahasiswa (DIPERBAIKI 2026-10-06)
- Route `POST|DELETE .../pin` + komponen `PinnedMessages` ada; menu aksi mahasiswa hanya Salin/Ubah/Hapus. Kemungkinan `canPin` sengaja dibatasi non-mahasiswa (belum diverifikasi role dosen).
- **FIXED 2026-10-06 (keputusan: mahasiswa juga boleh pin):** `PinnedMessageController::store`
  tak lagi menolak non-moderator (konsisten dengan `destroy` yang tak pernah membatasi role);
  UI `canPin` dibuka untuk semua role, sementara **hapus pesan orang lain tetap moderator**
  (prop baru `canDeleteOthers` → `showDelete = isOwn || canDeleteOthers`).
  **Terverifikasi live:** API pin sebagai mahasiswa `403 → 200`; klik koordinat asli menu
  "Sematkan pesan" → toast + `POST .../pin` → row `pinned_messages` id=2
  `pinned_by=9b9e224b…` (Andi); "Lepas sematan" → `DELETE .../pin` + toast. Console bersih.

### ℹ️ F8 — Reopen sesi dimatikan by design (BR-023) — panduan sudah disesuaikan.
### ℹ️ F9 — Cakupan panduan vs aplikasi: masih ada permukaan tak tercakup: pencarian chat (`Buka pencarian` + `SearchResults`), halaman kehadiran mahasiswa (`student/courses/attendance`),6 halaman analytics dosen, tab Notification/Appearance settings, alur lupa/reset password.

##5. Yang TERBUKTI BAIK (regresi utama aman)

- Stream-only inference live (`/api/chat/stream`200) + prompt-cache miss→hit terbukti.
- Lifecycle sesi penuh: buat → pre-read → goal-AI → chat → tutup → ringkasan → refleksi.
- Auto-attendance, kehadiran tercatat & tampil di dosen.
- Validator tujuan AI bekerja (menolak tujuan lemah, menerima yang spesifik+berwaktu).
-5 halaman admin render dengan data live.
- Persistensi pesan antar reload (pengambilan via socket).

##6. Rekomendasi tindakan

1. ~~Perbaiki F1~~ **SELESAI** — `resolveAuthUser()` + jalur nginx delete; terverifikasi live 200.
2. **Selidiki F3** dengan verifikasi manual sekali (klik Simpan di browser sungguhan + Network tab) untuk memisahkan bug UI vs otomasi. **Catatan penting:** jalur API sudah 200, jadi bila klik UI tetap tak mengirim request, akar F3 murni di klien.
3. Ingest materi → Qdrant (menghidupkan sitasi, F5).
4. Putuskan F7 (verifikasi email admin) & F6 (aturan pin).
5. Tambahkan sisa flow (F9) ke panduan pengguna setelah lolos uji.
