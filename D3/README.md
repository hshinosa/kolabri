# D3 — Capstone Project Final Report and Documentation (Kolabri)

## Isi folder

| File | Keterangan |
|------|------------|
| `[D3] Capstone Project Final Report and Documentation.docx` | Salinan asli dari Downloads (template + background terisi) |
| `[D3] Capstone Project Final Report and Documentation - Kolabri.docx` | **Laporan final** yang diisi selaras kode repositori |
| `extract_original.py` | Ekstrak teks template asli → `extracted_original.md` |
| `compile_d3_report.py` | Compile ulang laporan D3 (python-docx) berbasis fakta kode |
| `extracted_original.md` | Hasil ekstraksi template |

## Cara regenerate

```bash
cd D3
python3 extract_original.py
python3 compile_d3_report.py
```

Butuh: `python-docx` (`pip install python-docx`).

## Prinsip isi laporan

- **Source of truth**: kode di `Kolabri-core-api/`, `Kolabri-ai-engine/`, `Kolabri-client-app/`.
- Background/Motivation/Problem Definition dari template asli **dipertahankan**.
- Bagian yang tadinya placeholder diisi dari implementasi aktual.
- Tidak menambah klaim metrik pedagogis/performa yang tidak diukur di laporan ini.
- Dokumen di `docs/` boleh jadi referensi silang, tetapi tidak menggantikan audit kode.
