# Rancangan Penyelarasan Slide Sidang ↔ Buku TA (`main.pdf`) ↔ Implementasi

**Sumber slide:** `Sidang Tugas Akhir Capstone - Web Chatbot Kolaboratif (Kolabri).pdf` (24 halaman)  
**Buku TA:** `/Users/hshino/Kuliah/latex-documents/TA/main.pdf` (+ `bab/*.tex`, `frontmatter/abstrak.tex`)  
**Kode fokus TA (Hashfi):** `Kolabri-ai-engine/`  
**Konteks platform (opsional di slide, bukan klaim kontribusi utama):** `Kolabri-core-api/`, `Kolabri-client-app/`  

**Prinsip:**
1. Source of truth angka hasil = **naskah TA final** (`bab4.tex` / `bab5.tex` / `abstrak.tex`) yang sudah diselaraskan dengan verifikasi kode.
2. Slide sidang **tidak boleh** lebih kuat dari buku, dan **tidak boleh** memakai angka jadul yang sudah diganti di `main.pdf`.
3. Fokus utama perbaikan: **bagian IMPLEMENTASI / hasil** (slide 16–24). Bagian latarbelakang–metodologi diperbaiki jika bertentangan dengan implementasi.

**Artefak ekstraksi:** `D3/sidang-slides/slide-01.jpg` … `slide-24.jpg`

---

## 0. Peta alur slide saat ini (24 halaman)

| # | Judul (inti) | Status vs TA/kode |
|---|--------------|-------------------|
| 1 | Cover sidang (3 Juli 2026) | Minor: tanggal/format; judul OK (backend AI FastAPI) |
| 2 | Latar belakang (3 masalah) | OK arah; samakan frasa dengan Bab 1 bila perlu |
| 3 | Gap “yang ada / belum” | Typo + sederhanakan klaim “SSR-specific” |
| 4 | Rumusan masalah (3) | OK; samakan wording dengan Bab 1 (3 rumusan) |
| 5 | Tujuan (3) | OK; samakan urutan dengan Bab 1 |
| 6 | “Yang akan dibangun” | **Ubah tense** → yang dibangun (hasil) |
| 7 | Batasan | OK scope backend; cek OCR/PaddleOCR wording |
| 8 | Tinjauan pustaka | OK ringkas; cek tahun Bogarin typo |
| 9 | Metodologi 5 iterasi | OK dengan Bab 3 |
| 10 | Arsitektur backend | Pastikan diagram = AI Engine (bukan full monolit) |
| 11 | RAG Pipeline (desain) | Samakan Qdrant + embedding lokal + FETCH/NO_FETCH |
| 12 | Desain Guardrails | **KRITIS: hapus BERT Classifier** |
| 13 | Desain Logic Listener | **KRITIS: silence 5 → 10 menit** |
| 14 | Event logging & analitik | Samakan skema XES / field Gen-SRL |
| 15 | Rencana skenario uji | OK; pastikan tidak overclaim 50+ user sebagai “sudah” |
| 16 | Komponen implementasi | OK; lengkapi nama modul nyata |
| 17 | RAG + Guardrails alur | OK; tambah rerank/grounding hybrid bila muat |
| 18 | Logic Listener alur | Samakan trigger dengan kode + Bab 4 |
| 19 | Pengujian fungsional angka | **KRITIS: angka jadul** |
| 20 | Evaluasi RAG | **Update: tambah tahap 2 + rerank** |
| 21 | E2E + logging EPM | **Perbaiki klaim volume log** |
| 22 | (duplikat slide 21) | **Hapus / ganti** |
| 23 | Performa | **KRITIS: RPS & cache selaras abstrak/Bab 4** |
| 24 | Analisis, batasan, lanjutan | Selaraskan Bab 5; kurangi “frontend belum” yang menyesatkan |

---

## 1. Matriks selisih KRITIS (prioritas P0 — hasil implementasi)

### P0-1. Angka pengujian (Slide 19 vs Abstrak/Bab 4/Bab 5)

| Klaim | Slide sekarang | Buku TA (`abstrak` / `bab4` / `bab5`) | Aksi slide |
|-------|----------------|--------------------------------------|------------|
| Total test cases | **2.173** | **>2.400** (verifikasi: **2.414 collected, 2.411 passed**) | Ganti angka |
| Unit tests | **1.972** | **2.199** | Ganti |
| Integration tests | **141** | **147** | Ganti |
| Code coverage | **97,30%** | **99,92%** paket `app` | Ganti + label “paket app” |
| E2E / black-box | (tidak ada di slide 19) | **21 E2E + 38 black-box** | Tambah bullet |
| Security tests | (tidak ada) | **66 test cases keamanan, lulus** | Tambah (atau slide terpisah ringkas) |

**Teks usulan Slide 19 (kiri):**
- Total pytest terkumpul: **2.414** (lulus **2.411**, Juni 2026)
- Unit: **2.199** · Integration: **147**
- Black-box API: **38** · E2E terstruktur: **21**
- Coverage modul `app`: **99,92%**
- Keamanan (injection/PII/NoSQL/rate-limit): **66** cases lulus

**Catatan defensif:** Sebut “pytest suite AI Engine”, jangan bilang “seluruh platform Kolabri 3-service”.

---

### P0-2. Performa (Slide 23 vs Abstrak/Bab 4/Bab 5)

| Klaim | Slide sekarang | Buku TA | Risiko sidang | Aksi |
|-------|----------------|---------|---------------|------|
| Endpoint analitik lokal 2–4 ms | Ada | In-process: **orde μs–ms** (boleh tetap sebagai orde) | Rendah jika dilabel “in-process / lokal” | Pertahankan dengan label jelas |
| Throughput **672 RPS** | Headline | Abstrak final: HTTP engagement **67–122 RPS** (reproduksi Juni 2026) | **Tinggi** — angka lama mudah diserang | **Ganti ke 67–122 RPS** + skenario 5 klien; 672 bisa dihapus atau digeser ke catatan “pengukuran awal/benchmark lain” hanya jika masih ada di lampiran (disarankan **jangan** di slide utama) |
| Cache RAG 2.236 → 286 ms (±7,8×) | Ada | Bab 4: pengulangan kueri identik `/api/ask` dapat turun ke **≈10 ms** (response cache); ada tabel cache terpisah | Sedang — inkonsisten dengan abstract | **Update** ke angka Bab 4; sebutkan endpoint & jenis cache |
| 5 klien paralel | Ada | Konsisten sebagai skala uji (bukan 50+) | OK | Pertahankan + sebut batasan skala |

**Teks usulan Slide 23:**
- Analitik lokal (in-process): latensi **μs–ms**
- HTTP engagement analytics: **67–122 RPS** (Locust/repro, 5 klien, Juni 2026)
- Response cache `/api/ask`: kueri berulang → latensi HTTP **≈10 ms** (cache hit)
- LLM latency **tidak** diklaim sebagai “latensi sistem penuh” (dominasi provider eksternal) — selaras H2/Bab 5

---

### P0-3. Evaluasi RAG (Slide 20 vs Bab 4)

Slide 20 sudah punya:
- Keyword coverage **84,0% → 94,0%**
- **MRR@5 = 0,88**
- **20 kueri** akademik  
→ **cocok tahap 1** di Bab 4.

**Yang hilang (penting di buku, wajib masuk slide hasil):**

| Temuan Bab 4 | Usulan di slide |
|--------------|-----------------|
| Tahap 2: **36 kueri**, 3 MK (IF201/IF202/IF211), 6 PDF/MK | Tambah baris/kartu “Evaluasi tahap 2” |
| P@1 = **1,0000**; P@3 = **0,8426**; MRR@5 = **1,0000** | Tampilkan 3 metrik |
| Reranker cross-encoder: P@3 **0,85 → 0,90**; MRR@5 **0,86 → 0,90** | 1 bullet / mini-chart |
| Grounding hybrid: kelulusan **100% pada 5 kueri aktual** (setelah optimasi) | Boleh 1 bullet **dengan n=5 eksplisit** (jangan headline “100%” tanpa n) |
| Target Bab 3 100+ kueri **belum** | Masuk batasan (slide 24), bukan hasil seolah selesai |

**Layout usulan Slide 20 (atau 20+21):**
1. Kiri: Tahap 1 (20 kueri) — keyword + MRR@5  
2. Kanan: Tahap 2 (36 kueri) — P@k / MRR  
3. Bawah: Rerank + catatan grounding n=5  

---

### P0-4. E2E & logging EPM (Slide 21–22 vs Bab 5)

| Klaim | Slide | Buku | Aksi |
|-------|-------|------|------|
| 21 skenario E2E berhasil | Ada | Ada (lulus) | Pertahankan |
| Data aktual | Ada | Ada | OK |
| **2.270 events / 88 cases** | Ada | Bab 5: volume log produksi **tidak** diklaim kuantitatif di naskah akhir | **Hapus angka 2270/88** atau ganti: “skema XES divalidasi di unit export service; volume kelas belum diklaim” |
| Diagram alur Mongo → XES → EPM | Ada | OK secara arsitektur | Pertahankan tanpa angka volume palsu |
| **Slide 22 = duplikat 21** | — | — | **Hapus slide 22**; ganti dengan konten P0-3 overflow atau “ringkasan hipotesis H1–H3” |

---

## 2. Selisih desain/metodologi yang bertentangan implementasi (P1)

### P1-1. Guardrails — Slide 12

| Slide | Implementasi / TA | Perbaikan teks |
|-------|-------------------|----------------|
| **BERT Classifier (score > 0.8 = blocked)** | `injection_detector.py`: **regex/heuristic weighted score**, threshold **≥ 0.7**; komentar kode: API “compatible with later BERT” — **bukan BERT** | Ganti: “Heuristic / regex injection scorer (threshold ≥ 0,7; 15+ pola bilingual)” |
| Toxicity Check | `toxicity_scorer.py` berbasis bobot kata/heuristik | Tetap, sebut rule-based |
| PII NIM/email/phone | `pii_detector.py` | OK |
| Grounding verification | Hybrid semantic 70% + keyword 30%, threshold 0,4 (Bab 4) | Opsional detail di slide 17 |
| Direct Answer / Socratic | `socratic_filter.py` | OK |
| Pedagogical Alignment | prompt templates + policy | OK |

### P1-2. Logic Listener — Slide 13

| Slide | Kode + Bab 4 | Perbaikan |
|-------|--------------|-----------|
| Silence **Δt > 5 menit** | `SILENCE_THRESHOLD_MINUTES = 10`; Core API `SILENCE_TIMEOUT_MS = 10 * 60 * 1000`; Bab 4: **> 10 menit** | **Ganti 5 → 10 menit** |
| Gini > 0,6 + normalisasi √N | Ada di desain + anomaly | OK; sebut juga di core path |
| SRL phase F/P/R | `srl_classifier.py` rule-based | OK; jangan klaim ML classifier |
| Trigger di Bab 4 | Silence 10 mnt; low quality HOT&lt;30% / lexical&lt;0,3; cek tiap 5 pesan; **cooldown 5 menit** (Bab 4) vs core gate cooldown **3 menit** | Slide: pakai **angka Bab 4** untuk sidang TA AI Engine; jika ditanya integrasi platform, sebut gate socket di Core API 10 mnt silence + cooldown 3 mnt sebagai lapisan orkestrasi |

**Usulan 3 trigger di slide (selaras Bab 4):**
1. Keheningan > **10** menit  
2. Kualitas rendah (HOT &lt; 30% atau lexical &lt; 0,3)  
3. Pengecekan berkala setiap **5** pesan + cooldown  

### P1-3. Slide 6 tense & deliverable

- “**Yang akan dibangun**” → “**Yang dibangun / telah diimplementasikan**”
- Empat kotak: Logic Listener, FastAPI backend, RAG+guardrails, XES logging — **sudah ada di kode**; pastikan tidak terkesan future work.

### P1-4. Slide 3 gap table

- Typo: **Microservicees** → **Microservices**
- “SSR-specific monitoring” → “Logic Listener / SSR-oriented monitoring (**rule-based**)” agar tidak overclaim validasi pedagogis.

### P1-5. Slide 8 referensi

- “Bogarin et al. (**20177**)” → **2017** (typo)
- “Lewis et al. (2020)” di slide vs kadang 2021 di D3 — samakan sitasi dengan `referensi.bib` buku (biasanya Lewis 2020 NeurIPS).

### P1-6. Slide 7 batasan

- “Tidak mengerjakan Frontend” = **benar untuk scope TA individu** (AI Engine).  
- Jangan di penutup bilang “integrasi frontend masih rencana” seolah Core API/Client belum ada: di platform Kolabri **sudah terintegrasi**; yang belum adalah **evaluasi kelas nyata / load 50+**.  
- PaddleOCR: tetap sebagai **opsional / graceful degradation** (Bab 1 & 3).

---

## 3. Perubahan per-slide (checklist eksekusi)

### Blok A — Pembuka (1–8) — P2 kecuali yang bertentangan

| Slide | Perubahan konkret |
|-------|-------------------|
| 1 | Update tanggal sidang jika sudah final; pastikan subjudul “AI Engine / FastAPI” |
| 2 | Opsional: 3 bullet selaras abstrak (halusinasi, monitoring kolaboratif, infrastruktur analitik) |
| 3 | Typo microservices; soften wording |
| 4–5 | Samakan urutan rumusan/tujuan dengan Bab 1 (arsitektur async, RAG+guardrails, logging EPM) |
| 6 | Tense hasil; 4 deliverable = past tense |
| 7 | Batasan: backend only; Qdrant+Mongo; OpenAI-compatible; OCR opsional; multi-tenant course |
| 8 | Fix tahun sitasi |

### Blok B — Metodologi (9–15) — P1

| Slide | Perubahan konkret |
|-------|-------------------|
| 9 | 5 iterasi: tetap; pastikan iterasi 3 = Guardrails & OCR, 4 = Logic Listener, 5 = optimasi & testing |
| 10 | Diagram hanya **AI Engine** + Qdrant + Mongo + Redis + LLM API (boleh panah “dipanggil Core API” kecil) |
| 11 | RAG: embed lokal MiniLM-L12-v2 (384-d) → Qdrant top-k → (rerank) → LLM temp 0 → grounding |
| 12 | **Hapus BERT**; tulis rule-based injection scorer |
| 13 | Silence **10 menit**; tambah quality + every-5-messages |
| 14 | Field log: CaseID, Activity, Timestamp, Resource, Lifecycle + anotasi pedagogis; export XES unit-tested |
| 15 | Tabel verifikasi: jangan centang “50+ user load” sebagai done |

### Blok C — Implementasi & hasil (16–24) — **P0, fokus utama**

| Slide | Perubahan konkret |
|-------|-------------------|
| 16 | Komponen + path modul: `rag.py`, `guardrails.py`, `logic_listener.py`, `orchestration.py`, `xes_exporter.py` |
| 17 | Pipeline visual + sebut **reranker** + **grounding hybrid** |
| 18 | Trigger 10 mnt / Gini / SRL F-P-R / intervention types yang ada di `intervention.py` (redirect, prompt, summarize, …) |
| 19 | **Angka pytest final** (lihat P0-1) |
| 20 | **RAG tahap 1+2 + rerank** (lihat P0-3) |
| 21 | E2E 21 + XES schema validation; **tanpa 2270/88** |
| 22 | **Hapus duplikat** → ganti opsi: (A) ringkasan H1–H3 hasil, atau (B) keamanan 66 tests, atau (C) posisi AI Engine dalam 3-service Kolabri (1 diagram kecil) |
| 23 | **Performa final** (lihat P0-2) |
| 24 | Analisis = 4–5 poin Bab 5; keterbatasan = 50+ user, 100+ kueri RAG, eval kelas nyata, dependensi LLM; lanjutan = jangan “frontend belum ada”, ganti “UAT kelas / load penuh / grounding LLM-as-judge / process mining lanjutan” |

---

## 4. Usulan struktur slide **setelah** revisi (tetap ~22–24 halaman)

1. Cover  
2. Latar belakang  
3. Gap  
4. Rumusan masalah  
5. Tujuan  
6. Deliverable yang dibangun  
7. Batasan  
8. Tinjauan pustaka  
9. Metodologi 5 iterasi  
10. Arsitektur AI Engine  
11. Desain RAG  
12. Desain Guardrails (**tanpa BERT**)  
13. Desain Logic Listener (**10 menit**)  
14. Desain logging XES  
15. Rencana pengujian  
16. Implementasi komponen  
17. Implementasi RAG + Guardrails  
18. Implementasi Logic Listener  
19. **Hasil pengujian fungsional (angka final)**  
20. **Hasil evaluasi RAG (tahap 1+2 + rerank)**  
21. **Hasil E2E + validasi skema logging**  
22. **(baru) Ringkasan hipotesis H1–H3 / keamanan 66 tests** ← mengganti duplikat  
23. **Hasil performa (angka final)**  
24. Analisis, keterbatasan, saran  

---

## 5. Sinkronisasi tiga artefak (jika masih beda)

| Artefak | Tindakan |
|---------|----------|
| **Slide PDF** | Edit sesuai matriks P0/P1 di atas (prioritas sidang) |
| **`main.pdf` / LaTeX** | Angka hasil sudah relatif final (Juni 2026). Hanya ubah jika setelah re-run pytest angka coverage/test berubah — **update abstrak+bab4+bab5+slide bersamaan** |
| **Kode `Kolabri-ai-engine`** | Tidak perlu diubah hanya demi slide. Jika ada inkonsistensi **internal** (contoh cooldown 3 vs 5 menit lintas layanan), dokumentasikan di slide sebagai “AI Engine design vs Core API orchestration gate”, jangan samarkan |

### Hal yang **tidak** perlu dipaksa ke slide individu Hashfi
- Fitur full platform (pre-read UI, attendance, admin AI settings UI, dual-write materials) — boleh **1 diagram konteks** “dipanggil oleh Core API”, bukan klaim deliverable TA.
- Klaim peningkatan nilai mahasiswa di kelas — **tidak ada bukti** di Bab 4; jangan masuk slide.

---

## 6. Frasa yang dilarang di slide (klaim berbahaya)

| Jangan | Ganti dengan |
|--------|----------------|
| “BERT classifier memblokir injection” | “Detektor injection berbasis pola/regex + skor heuristik” |
| “Silence 5 menit” (tanpa catatan) | “Silence **10** menit (desain & konfigurasi)” |
| “672 RPS” sebagai headline performa final | “**67–122 RPS** HTTP engagement (repro Juni 2026)” |
| “2.173 tests / 97,3% coverage” | “**2.414** collected / **99,92%** coverage `app`” |
| “2.270 events, 88 cases = EPM validated di kelas” | “Skema XES divalidasi unit; volume kelas belum diklaim” |
| “Frontend belum diintegrasikan” | “Evaluasi di kelas nyata & load 50+ belum dilakukan; integrasi platform via Core API sudah ada di ekosistem Kolabri” |
| “Mengurangi halusinasi 100% / 80%” tanpa n | Keyword +10 pp; grounding 100% **pada 5 kueri**; H1 **parsial** |

---

## 7. Urutan kerja yang disarankan

1. **Revisi angka hasil dulu** (slide 19, 20, 21, 23) — paling sering ditanya penguji.  
2. **Perbaiki kontradiksi desain** (slide 12 BERT, slide 13 silence 5→10).  
3. **Hapus duplikat 22**, isi H1–H3 / security.  
4. **Rapikan penutup 24** agar = Bab 5.  
5. **Lint** slide 1–11 (typo, tense, sitasi).  
6. Dry-run 10–12 menit: pastikan tiap angka di slide ada “jejak” di `main.pdf` halaman terkait.

---

## 8. Lampiran cepat: angka “boleh diucapkan” (cheat sheet sidang)

Salin dari naskah final — jangan dari slide lama:

- Pytest: **2414 collected / 2411 passed**; unit **2199**; integration **147**; coverage **99,92%** (`app`)
- E2E **21**; black-box **38**; security **66**
- RAG tahap 1 (20 q): keyword **84% → 94%**; MRR@5 **0,88**
- RAG tahap 2 (36 q): P@1 **1,00**; P@3 **0,8426**; MRR@5 **1,00**
- Rerank: P@3 **0,85 → 0,90**
- Grounding hybrid: **100% lulus pada 5 kueri aktual** (n kecil, sebutkan)
- Performa: analitik lokal μs–ms; HTTP engagement **67–122 RPS**; cache hit `/api/ask` **≈10 ms**
- Silence design: **10 menit**
- Injection: **rule-based**, **bukan BERT**
- H1 **parsial**; H2 didukung untuk komponen lokal; H3 **belum** full 50+ user

---

## 9. File di folder ini

```
D3/sidang-slides/
├── Sidang Tugas Akhir Capstone - Web Chatbot Kolaboratif (Kolabri).pdf  # asli
├── slide-01.jpg … slide-24.jpg                                          # ekstraksi per halaman
└── SIDANG_SLIDE_ALIGNMENT_PLAN.md                                       # dokumen ini
```

**Next step (jika diminta):**  
(A) generate outline teks final per slide siap copy-paste ke PowerPoint/Keynote, atau  
(B) langsung buat deck PPTX baru yang sudah selaras, atau  
(C) patch LaTeX jika setelah re-run test angka berubah.
