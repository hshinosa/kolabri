# Minggu 1 — Pengenalan Data Mining

**Mata kuliah:** IF211 Data Mining  
**Tujuan bacaan:** Memahami definisi, tujuan, dan kerangka kerja penambangan data.

## 1. Apa itu Data Mining?

Data mining adalah proses menemukan **pola, hubungan, dan anomali** yang bermakna dari volume data besar, dengan kombinasi statistik, machine learning, dan eksplorasi domain.

Perbedaan dengan query biasa: kita tidak selalu tahu pertanyaan pasti di awal; mining membantu **menemukan insight** (segmentasi pelanggan, aturan belanja, indikator churn).

## 2. Kerangka CRISP-DM (ringkas)

1. **Business understanding** — tujuan bisnis & kriteria sukses  
2. **Data understanding** — eksplorasi, kualitas, missing values  
3. **Data preparation** — cleaning, transformasi, feature engineering  
4. **Modeling** — clustering, klasifikasi, asosiasi, dll.  
5. **Evaluation** — apakah model/jawaban memenuhi tujuan bisnis?  
6. **Deployment** — operasionalisasi (dashboard, batch scoring)

Untuk diskusi minggu ini, fokus pada langkah 1–3: tanpa data yang dipahami dan dibersihkan, hasil mining biasanya **menyesatkan**.

## 3. Jenis tugas mining (overview)

| Tugas | Contoh pertanyaan |
|-------|-------------------|
| Clustering | Segmen pelanggan mana yang mirip? |
| Classification | Apakah transaksi ini fraud? |
| Association rules | Produk apa sering dibeli bersamaan? |
| Anomaly detection | Transaksi mana yang tidak wajar? |

## 4. Diskusi kelompok (prompt)

- Sebutkan satu kasus di kampus atau UMKM yang cocok untuk data mining.  
- Langkah CRISP-DM mana yang paling sering di-skip di praktik? Mengapa?  
- Mengapa **preprocessing** disebut langkah yang paling memakan waktu?

**Kata kunci untuk goal minggu ini:** CRISP-DM, preprocessing, pola, segmentasi, kualitas data.