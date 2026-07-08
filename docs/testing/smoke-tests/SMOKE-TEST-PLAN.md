# Smoke Test Plan — Full Application
**Created:** 2026-05-22  
**Purpose:** Comprehensive smoke test untuk Kolabri sebelum demo ke dosen  
**Execution:** Delegate ke agent lain via Playwright browser automation  
**Base URL:** `http://localhost:8000` (Laravel frontend)

---

## Kredensial

### Dosen
| Email | Password | Nama | Role |
|-------|----------|------|------|
| `budi.santoso@univ.ac.id` | `password123` | Dr. Budi Santoso, M.Kom. | lecturer |
| `siti.rahayu@univ.ac.id` | `password123` | Prof. Siti Rahayu, Ph.D. | lecturer |

### Mahasiswa
| Email | Password | Nama | Engagement Level |
|-------|----------|------|-----------------|
| `andi.pratama@student.ac.id` | `password123` | Andi Pratama | high |
| `dewi.kusuma@student.ac.id` | `password123` | Dewi Kusuma | high |
| `dimas.anggara@student.ac.id` | `password123` | Dimas Anggara | high |
| `grace.natalia@student.ac.id` | `password123` | Grace Natalia | high |
| `rudi.hartono@student.ac.id` | `password123` | Rudi Hartono | medium |
| `maya.sari@student.ac.id` | `password123` | Maya Sari | medium |
| `eko.wijaya@student.ac.id` | `password123` | Eko Wijaya | medium |
| `lisa.permata@student.ac.id` | `password123` | Lisa Permata | medium |
| `nina.safitri@student.ac.id` | `password123` | Nina Safitri | medium |
| `yoga.putra@student.ac.id` | `password123` | Yoga Putra | medium |
| `rina.putri@student.ac.id` | `password123` | Rina Putri | low |
| `ahmad.fauzi@student.ac.id` | `password123` | Ahmad Fauzi | low |
| `fajar.setiawan@student.ac.id` | `password123` | Fajar Setiawan | low |
| `rizki.pratama@student.ac.id` | `password123` | Rizki Pratama | silent |
| `indah.lestari@student.ac.id` | `password123` | Indah Lestari | silent |

> **Catatan:** Password semua akun adalah `password123`. Enrollment mahasiswa ke kelas bersifat random saat seed, jadi mapping pasti mahasiswa-kelas bisa berbeda tiap kali seed ulang. Pakai `andi.pratama@student.ac.id` karena terbukti enrolled di beberapa kelas.

### Join Codes (Kelas)
| Kode | Nama Kelas |
|------|-----------|
| `JOIN-IF201` | Pemrograman Web |
| `JOIN-IF202` | Basis Data |
| `JOIN-IF203` | Algoritma dan Struktur Data |
| `JOIN-IF204` | Jaringan Komputer |
| `JOIN-IF205` | Kecerdasan Buatan |
| `JOIN-IF206` | Rekayasa Perangkat Lunak |
| `JOIN-IF207` | Sistem Operasi |
| `JOIN-IF208` | Pemrograman Mobile |
| `JOIN-IF209` | Grafika Komputer |
| `JOIN-IF210` | Keamanan Informasi |
| `JOIN-IF211` | Data Mining |
| `JOIN-IF212` | Cloud Computing |

### Group Codes
| Pattern | Contoh |
|---------|--------|
| `GRP-{kode_kelas}-{nomor}` | `GRP-IF211-1`, `GRP-IF211-2`, `GRP-IF212-1` |

---

## Server yang Harus Running

| Service | Port | Start Command |
|---------|------|---------------|
| Laravel Frontend | 8000 | `php artisan serve` (di `Kolabri-client-app/`) |
| Vite Dev Server | 5173 | `npm run dev` (di `Kolabri-client-app/`) |
| Core-API (Express) | 3000 | `npm run dev` (di `Kolabri-core-api/`) |
| AI Engine (FastAPI) | 8001 | `uvicorn app.main:app --reload` (di `Kolabri-ai-engine/`) |
| Qdrant | 6333 | Docker: `docker start kolabri-qdrant` |

> **Penting:** User sendiri yang nyalain server. Jangan restart server tanpa izin.

---

## Flow Test & Cara Kerjain

### Test 1: Lecturer Login → Dashboard → Analytics Overview → Detail Grup

**Goal:** Verifikasi seluruh flow dosen dari login sampai analisis grup.

**Steps:**

1. **Navigate** ke `http://localhost:8000/login`
2. **Snapshot** — pastikan form login muncul dengan field "Alamat Email" dan "Kata Sandi"
3. **Type** email: `budi.santoso@univ.ac.id`
4. **Type** password: `password123`
5. **Click** tombol "Masuk"
6. **Verify** redirect ke halaman Kelas Saya (`/lecturer/courses`)
7. **Snapshot** — pastikan course cards muncul (code, nama, siswa count, grup count)
8. **Click** menu "Analytics" di sidebar
9. **Verify** redirect ke `/lecturer/analytics`
10. **Snapshot** — pastikan halaman Analytics Overview muncul dengan card grid per kelas
11. **Verify** setiap card menampilkan: course code, nama, quality score badge, jumlah siswa & grup
12. **Click** salah satu course card
13. **Verify** redirect ke `/lecturer/courses/:courseId/analytics`
14. **Snapshot** — pastikan halaman analytics detail muncul dengan metrik (quality score, HOT%, engagement)
15. **Click** salah satu grup untuk buka modal detail
16. **Snapshot** — pastikan modal muncul dengan solid white background (bukan glassmorphism)
17. **Screenshot** — save sebagai `test-lecturer-analytics-modal.png`

**Expected:** Semua halaman render tanpa error. Modal terlihat jelas. Quality score 0-100.

---

### Test 2: Chat Room — Kirim Pesan & Cek Response

**Goal:** Verifikasi siswa bisa masuk chat room dan UI chat render dengan benar.

**Steps:**

1. **Navigate** ke `http://localhost:8000/login`
2. **Login** sebagai `andi.pratama@student.ac.id` / `password123`
3. **Verify** redirect ke `/student/courses`
4. **Click** salah satu course card (yang enrolled)
5. **Click** "Sesi Diskusi" di sidebar submenu
6. **Verify** halaman chat spaces muncul, ada "Diskusi Utama"
7. **Click** "Diskusi Utama" / "Masuk Diskusi"
8. **Verify** redirect ke chat room (`/student/courses/:id/chat/:chatSpaceId`)
9. **Snapshot** — pastikan chat room muncul dengan:
   - Header nama grup + nama kelas
   - Chat message list (pesan-pesan dari seed data harusnya ada)
   - Input field "Ketik @ untuk menyebut..."
   - Tombol "Kirim" (disabled kalau input kosong)
   - Tombol "Tutup Sesi"
10. **Type** pesan di input: `Halo ini test smoke test`
11. **Verify** tombol "Kirim" become enabled
12. **Click** tombol "Kirim"
13. **Wait** 2 detik
14. **Verify** pesan muncul di chat list (atau minimal tidak crash)
15. **Screenshot** — save sebagai `test-chat-room.png`

**Expected:** Chat room render dengan pesan-pesan seed. Input dan kirim pesan berfungsi. WebSocket mungkin tidak connect (socket.io port 3000) — ini OK, UI tetap jalan.

---

### Test 3: Tutup Sesi → Submit Refleksi

**Goal:** Verifikasi flow menutup sesi diskusi dan submit refleksi.

**Steps:**

1. (Lanjutan dari Test 2, masih di chat room)
2. **Click** tombol "Tutup Sesi"
3. **Verify** ada konfirmasi atau form refleksi muncul
4. **Snapshot** — lihat apa yang muncul
5. **Jika form refleksi muncul:**
   - **Type** refleksi: `Sesi diskusi hari ini membahas topik penting. Saya belajar banyak dari teman satu grup.`
   - **Click** tombol submit
   - **Verify** redirect atau sukses message
6. **Navigate** ke `/student/reflections`
7. **Verify** refleksi baru muncul di daftar
8. **Screenshot** — save sebagai `test-refleksi.png`

**Expected:** Tutup sesi memicu form refleksi. Refleksi tersimpan dan muncul di halaman Refleksi.

---

### Test 4: Join Course pakai Join Code

**Goal:** Verifikasi siswa bisa join kelas baru pakai join code.

**Steps:**

1. **Login** sebagai `andi.pratama@student.ac.id` / `password123`
2. **Navigate** ke `/student/courses`
3. **Click** tombol "Gabung Mata Kuliah"
4. **Verify** modal "Gabung Mata Kuliah" muncul
5. **Snapshot** — pastikan ada input field untuk join code
6. **Type** join code: `JOIN-IF201`
7. **Click** tombol submit / "Gabung"
8. **Wait** 3 detik
9. **Verify:**
   - **Success:** Redirect atau course baru muncul di daftar, atau
   - **Already enrolled:** Error message "Anda sudah terdaftar" (ini OK, student mungkin sudah enrolled dari seed)
   - **Error:** Valid error message muncul (bukan crash)
10. **Screenshot** — save sebagai `test-join-course.png`

**Expected:** Join code diterima. Kalau sudah enrolled, tampilkan pesan yang jelas.

---

### Test 5: Buat Grup Baru

**Goal:** Verifikasi siswa bisa membuat grup baru.

**Steps:**

1. **Login** sebagai `andi.pratama@student.ac.id` / `password123`
2. **Navigate** ke `/student/courses`
3. **Click** salah satu course card
4. **Click** "Cari atau Buat Grup"
5. **Verify** halaman groups muncul
6. **Snapshot** — lihat apakah ada tombol "Buat Grup" atau form create group
7. **Jika tombol "Buat Grup" ada:**
   - **Click** tombol "Buat Grup"
   - **Verify** form muncul (nama grup, dll)
   - **Type** nama grup: `Kelompok Test Smoke`
   - **Click** submit
   - **Verify** grup baru muncul di daftar atau redirect
   - **Screenshot** — save sebagai `test-create-group.png`
8. **Jika tidak ada tombol "Buat Grup":**
   - **Screenshot** — save sebagai `test-groups-no-create.png`
   - **Catat** bahwa fitur create group tidak tersedia di halaman ini

**Expected:** Grup baru bisa dibuat atau tombol create group visible.

---

## Format Pelaporan

Setiap test case harus dilaporkan dalam format:

```
### Test X: [Nama Test]
- **Status:** ✅ PASS / ❌ FAIL / ⚠️ PARTIAL
- **Screenshot:** [path ke screenshot]
- **Console Errors:** [jumlah dan deskripsi]
- **Issues Found:** [kalau ada, deskripsi singkat]
- **Notes:** [observasi tambahan]
```

---

## Akhir Test

Setelah semua test selesai:
1. **Close browser** via `browser_close`
2. **Compile report** gabungan semua test case
3. **Summary:** total PASS/FAIL/PARTIAL
4. **List bugs** yang ditemukan (kalau ada)
5. **Screenshots** disimpan di `.playwright-mcp/`

---

## Catatan Penting

- **WebSocket errors** (`ws://localhost:3000/socket.io/`) adalah expected — socket.io server berjalan terpisah. Ini bukan bug.
- **Enrollment random** — karena seed data pakai `randomSubset()`, mapping mahasiswa-kelas bisa berbeda tiap seed. Pakai `andi.pratama@student.ac.id` karena terbukti punya enrollment.
- **Jangan restart server** — server dijalankan oleh user sendiri.
- **CSRF token** — kalau kena "Page Expired" (419), refresh page dulu lalu coba lagi. CSRF fix sudah diterapkan tapi edge case mungkin masih ada.
- **Modal background** — kalau ada overlay modal yang intercept clicks, tutup modal dulu pakai tombol X sebelum klik element lain.
