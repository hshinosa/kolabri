# Sample materi — smoke test minggu & pre-read (IF211)

File ini untuk **upload manual** di tab **Materials** (pool), lalu **assign** di tab **Minggu**.

## File siap upload

| File | Judul di UI (saran) | Minggu (saran) |
|------|---------------------|----------------|
| `if211-minggu-1-pengenalan-data-mining.pdf` | Minggu 1 — Pengenalan Data Mining | Minggu 1 |
| `if211-minggu-2-preprocessing-dan-kmeans.pdf` | Minggu 2 — Preprocessing & K-Means | Minggu 2 |
| `if211-minggu-3-association-rules.pdf` | Minggu 3 — Aturan Asosiasi | Minggu 3 |

Sumber teks: file `.md` di folder yang sama. Regenerate PDF:

```bash
cd docs/sample-materials
python3 generate_pdfs.py
```

## Alur test cepat

1. Login dosen `budi.santoso@univ.ac.id` / `password123`
2. Buka **IF211** → tab **Materials** (bukan bagian “Basis Pengetahuan” di bawah) → **Upload Materi** → **Pilih berkas** → isi judul → **Upload ke pool**
3. Tab **Minggu** → buat minggu 1–3 (atau pakai yang sudah ada) → **Tambah dari pool**
4. **Kelola grup** → **Tambah Sesi Diskusi** → pilih minggu → buat sesi
5. Login mahasiswa `andi.pratama@student.ac.id` → buka sesi → pre-read → goal → chat

## Goal contoh (on-topic minggu 1)

> Saya ingin memahami tahapan CRISP-DM dan peran **data preprocessing** sebelum analisis pola pada dataset transaksi.

## Goal contoh (off-topic → revise)

> Saya ingin menguasai React hooks dan Tailwind untuk landing page.