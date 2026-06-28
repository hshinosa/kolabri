# Minggu 3 — Aturan Asosiasi (Association Rules)

## 1. Konteks

Dipakai untuk **market basket analysis**: menemukan item yang sering muncul bersamaan (transaksi retail, log akses, kombinasi modul kuliah).

## 2. Metrik utama

- **Support** — seberapa sering itemset X ∪ Y muncul di semua transaksi  
- **Confidence** — P(Y | X): jika beli X, seberapa sering juga beli Y  
- **Lift** — confidence dibanding baseline; lift > 1 → asosiasi positif

## 3. Algoritma Apriori (ringkas)

Prinsip **anti-monotone**: subset dari itemset jarang harus ≥ support subsetnya.  
Cari frequent itemsets lalu turunkan aturan dengan threshold support & confidence.

## 4. Interpretasi hati-hati

Aturan tinggi confidence **belum tentu** berguna bisnis (bisa trivial: “yang beli pensil beli kertas”).  
Selalu gabungkan dengan **domain knowledge** dan biaya promosi.

## 5. Diskusi

Bandingkan satu aturan dengan lift rendah vs tinggi — kapan masing-masing tetap actionable?

**Kata kunci goal:** support, confidence, lift, Apriori, frequent itemset, market basket.