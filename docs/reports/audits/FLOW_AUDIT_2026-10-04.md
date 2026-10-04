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
|13| **Edit pesan (Ubah pesan)** | ❌ | lihat Temuan F1/F2 |
|14| **Hapus pesan** | ⚠️/❌ | menu ada; klik tak menghasilkan request (terinstrumentasi); jalur API terpisah bermasalah — lihat F1/F3 |
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

### ❌ F1 — Edit pesan mengembalikan500 (rusak)
- **Bukti:** `PATCH /api/chat/messages/{id}/edit` dengan sesi login valid → `500 Server Error`.
- **Akar (terbaca):** `MessageController::edit` baris22: `$userId = $request->user()->id;` — `$request->user()` = **null** → `Attempt to read property "id" on null` (laravel.log,3 kejadian =3 percobaan audit).
- **Konteks route:** route berada di grup `middleware('auth.jwt')` + `assert.chat.membership`; request ber-cookie sesi lolos middleware namun user tak ter-set →500, bukan401.
- **Dampak:** fitur "Ubah pesan" tidak bisa menyimpan untuk siapa pun yang memakai alur auth halaman (cookie) — editor tetap terbuka.

### ⚠️ F2 — Hapus pesan: jalur API terbukti401 pada pengujian langsung
- `DELETE /api/chat/messages/{id}` → `401 No token provided` (format error ala Core API) sementara route hanya bermiddleware `assert.chat.membership`. Selain itu `destroy()` juga memakai `$request->user()->id` (baris103) → rawan kasus sama dengan F1.

### ⚠️ F3 — Klik "Simpan edit"/"Hapus pesan" tidak menghasilkan request keluar browser (terinstrumentasi)
- XHR/fetch di-patch: **0 request** setelah klik, baik di pesan baru maupun pesan lama hasil muat server; state editor benar (nilai terisi, tombol enabled); jalur keyboard Enter pun nihil.
- Bundle `MessageEditor`/`room` di produksi = source (dicek byte-level handler-nya identik).
- **Belum terpecahkan:** apakah `messages.find()` di `handleSaveEdit` gagal (array vs list render) atau hal lain — **butuh1 verifikasi manual di browser nyata** (apakah muncul error toast/permintaan jaringan saat klik Simpan). Kombinasi dengan F1: walau UI mengirim, server tetap500.

### 📌 F4 — Ringkasan tidak tampil setelah reload (sudah diketahui)
- Ringkasan tersimpan di DB (`summary_generated_at` + isi1491–1420 karakter) tapi halaman segar tidak mem-fetch (0 GET summary) — render hanya pada alur live pasca-tutup. Workaround terdokumentasi di panduan.

### 📌 F5 — Sitasi RAG mati di produksi
- Qdrant:9 collection `course_*` semuanya **`points_count:0`** (materi belum ter-ingest vektor) → `@ai` selalu menjawab "tidak menemukan dokumen" + panel "DIKUTIP DALAM DISKUSI" selalu "Belum ada sitasi".

### 📌 F6 — Pin pesan: route+komponen ada, tak muncul di menu mahasiswa
- Route `POST|DELETE .../pin` + komponen `PinnedMessages` ada; menu aksi mahasiswa hanya Salin/Ubah/Hapus. Kemungkinan `canPin` sengaja dibatasi non-mahasiswa (belum diverifikasi role dosen).

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

1. **Perbaiki F1** (guard `auth.jwt`/`$request->user()` — user harus ter-set; kembalikan401 bukan500) — prioritas1.
2. **Selidiki F3** dengan verifikasi manual sekali (klik Simpan di browser sungguhan + Network tab) untuk memisahkan bug UI vs otomasi.
3. Ingest materi → Qdrant (menghidupkan sitasi, F5).
4. Putuskan F7 (verifikasi email admin) & F6 (aturan pin).
5. Tambahkan sisa flow (F9) ke panduan pengguna setelah lolos uji.
