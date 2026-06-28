# Review putaran 2 — artefak lain (2026-06-12)

Background: `bg_31d60482` (explore) + verifikasi manual.

## Ringkasan

| Area | Status |
|------|--------|
| Naskah TA `*.tex` (bab1–5, abstrak, lampiran, frontmatter) | **Angka stale utama sudah bersih** |
| `bab4.tex` internal | **OK** (H2 tanpa 2–4 ms HTTP; keterbatasan 1–12 berurutan) |
| Repo docs / README | **Masih ada angka lama** (bukan naskah sidang, tapi membingungkan) |

---

## Temuan per file

### HIGH — perlu update jika dibaca penguji/dosen dari repo

| File | Isu | Aksi disarankan |
|------|-----|-----------------|
| `Kolabri-ai-engine/README.md` | **1378 tests** (aktual **2411 passed** / 2414 collected) | UPDATE badge & struktur proyek |
| `docs/TA_FINAL_REVIEW_CONTEXT.md` | Snapshot lama: **66 hal**, **2209 / 98,86%**, **672 RPS** di abstrak | Tambah banner **SUPERSEDED Juni 2026** atau update header |
| `docs/AI_ENGINE_IMPLEMENTATION_REPORT.md` | **2.209 / 98,86%** (Mei 2026) | Banner historis + pointer ke `PHASE0_SNAPSHOT` |

### MEDIUM — dokumentasi internal / risiko sidang (narasi)

| File | Isu | Aksi |
|------|-----|-----|
| `Kolabri-ai-engine/BENCHMARK_AUDIT_REPORT.md` | Judul "ALL 8 CLAIMS UNVERIFIED" — **pra-repro** | Tambah paragraf atas: superseded oleh `docs/evidence/bab4/REPRODUCTION_REPORT.md` + edit Bab 4 |
| `docs/TA_FINAL_HOSTILE_REVIEW.md` | Masih mengasumsikan abstrak lama (672, coverage sebagai klaim ilmiah) | Catatan di awal: abstrak/bab5 sudah diselaraskan; risiko **narasi** (H1 n=5, Logic Listener) tetap valid |
| `docs/AI_ENGINE_SCOPE_BOUNDARIES.md` | **98,86%** / DeepSeek jika masih ada | Grep & patch ringan |
| `THESIS_CODE_AUDIT_REPORT.md` / `THESIS_AUDIT_REPORT.md` | DeepSeek sebagai model tunggal | Banner historis |

### LOW — sengaja / jejak audit

| File | Isu | Aksi |
|------|-----|-----|
| `docs/TA_BAB4_ALIGNMENT_PLAN.md` | Kolom "klaim lama" | KEEP (dokumen rencana) |
| `docs/evidence/bab4/*` | Menyebut angka lama sebagai perbandingan | KEEP |
| `frontmatter/` (cover, kata pengantar, dll.) | Tanpa metrik performa | OK |
| `lampiran/lampiran_jejak_pengujian.tex` | Perintah repro; `locustfile_repro_ta.py` ada | OK |
| `referensi.bib` | Tidak ada klaim angka TA | OK |
| `bab/bab2.tex` | Bednarz 3800 RPS | KEEP (literatur) |
| `bab/bab3.tex` | Tabel cache **target** >25% (bukan hasil 28%) | OK selaras Bab 4 |

### Naskah — opsional kecil

| File | Isu | Severity |
|------|-----|----------|
| `bab/bab4.tex` ~L450 | Menyebut literal **28% / 18 ms / 420 ms** saat menolak klaim | **Low** — bisa parafrase tanpa angka |
| `bab/bab3.tex` vs `bab4.tex` | Python **3.11+** (Bab 3) vs **3.13** (Bab 4 env) | **Low** — selaraskan satu kalimat |

---

## Background task `bg_31d60482`

**Status: FINAL** untuk scope yang diminta.

- Explore menemukan README 1378 + docs Mei + audit report pra-repro.
- **Tidak** menemukan masalah baru di `bab4` duplicate numbering / H2 2–4 ms (sudah fixed).
- Rekomendasi agent = daftar di atas; **belum** semua dipatch (hanya laporan ini).

## Prioritas jika mau lanjut patch

1. `Kolabri-ai-engine/README.md` (1378 → 2411+)
2. Banner di `BENCHMARK_AUDIT_REPORT.md` + `TA_FINAL_REVIEW_CONTEXT.md`
3. Opsional: parafrase `bab4.tex` L450 tanpa 28%/420