# Minggu 2 — Data Preprocessing & K-Means Clustering

**Prasyarat:** Minggu 1 (CRISP-DM & jenis tugas mining)

## 1. Data preprocessing

Langkah umum:

- **Handling missing values** — hapus baris, imputasi mean/median/mode, atau model-based  
- **Outlier** — deteksi (IQR, z-score), cap, atau analisis domain  
- **Encoding** — one-hot untuk kategorikal, scaling untuk numerik  
- **Normalisasi / standardisasi** — penting untuk jarak (mis. K-Means)

Kesalahan preprocessing → cluster atau model **tidak stabil** dan sulit diinterpretasi.

## 2. K-Means (intuisi)

Algoritma **unsupervised**:

1. Pilih jumlah cluster **k**  
2. Inisialisasi **k** centroid  
3. Assign setiap titik ke centroid terdekat (biasanya jarak Euclidean)  
4. Update centroid = rata-rata titik di cluster  
5. Ulangi 3–4 hingga konvergen

## 3. Memilih k

- **Elbow method** — plot inertia vs k, cari “siku”  
- **Silhouette score** — semakin tinggi, pemisahan cluster semakin jelas (dalam batas tertentu)

## 4. Latihan konseptual

Dataset: skor mahasiswa pada 3 fitur numerik (quiz, proyek, partisipasi).  
Jelaskan mengapa scaling diperlulu sebelum K-Means.

**Kata kunci goal:** preprocessing, missing values, K-Means, centroid, silhouette, elbow.