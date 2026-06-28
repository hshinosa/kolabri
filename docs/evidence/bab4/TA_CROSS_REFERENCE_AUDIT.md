# Audit referensi silang naskah TA (2026-06-12)

Sumber kebenaran angka hasil: `bab/bab4.tex` + `docs/evidence/bab4/*`.

| File | Baris / konteks | Klaim | Status | Aksi |
|------|-----------------|-------|--------|------|
| `frontmatter/abstrak.tex` | ID + EN ¶ hasil | 672 RPS, 2270/88 | ~~STALE~~ | **DONE** ✅ (sesi audit) |
| `bab/bab1.tex` | L48 | DeepSeek | ~~PARTIAL~~ | **DONE** ✅ `.env` |
| `bab/bab2.tex` | — | Bednarz 3800 RPS | **KEEP** | Tidak diubah |
| `bab/bab3.tex` | L23, L237 | DeepSeek | ~~PARTIAL~~ | **DONE** ✅ |
| `bab/bab3.tex` | L640–648 | ms-marco rerank | ~~STALE~~ | **DONE** ✅ Jina |
| `bab/bab3.tex` | target Bab 3 | 80%, 50+ user, 100 kueri | **KEEP** | Target rencana (sengaja) |
| `bab/bab4.tex` | — | hasil pengujian | **KEEP** | Sudah aligned sebelumnya |
| `bab/bab5.tex` | kesimpulan/saran | 672, 7,8×, 2270, 2173 | ~~STALE~~ | **DONE** ✅ |
| `lampiran/*` | — | Jejak perintah | **KEEP** | — |
| `kata_pengantar.tex` dll. | — | Tanpa angka performa | **KEEP** | — |

## Verifikasi pasca-patch (grep semua `*.tex`)
Tidak ada: 672, 673, 433, 2173, 97,30, 2270, 7,8×, DeepSeek, ms-marco.

Masih ada (sengaja): **100 kueri / 50+ user / >80%** di Bab 3 sebagai *target metodologi*; **28%** hanya di Bab 4 sebagai penolakan klaim tanpa bukti.

## Background task `bg_31c6a660` (explore) — status **FINAL**
- Output agent = daftar temuan per bab (sama dengan matriks di atas).
- Semua baris **STALE/UPDATE** dari agent sudah dipatch + diverifikasi grep.
- Agent **tidak** menemukan temuan tambahan di `bab2`, frontmatter selain abstrak, lampiran.
- **Tidak perlu** re-run agent kecuali naskah LaTeX diubah lagi.

## Patch diterapkan
`abstrak.tex`, `bab1.tex`, `bab3.tex`, `bab5.tex` — `main.pdf` compile OK.