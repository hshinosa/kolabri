# RAG Evaluation Results

**Date:** 2026-05-18 00:22:11  
**Dataset:** `data/evaluation/rag_evaluation_dataset.json` (20 queries)

## Overall Metrics

| Metric | RAG | No-RAG | Delta |
|--------|-----|--------|-------|
| MRR@5 | 0.8750 | — | — |
| Precision@3 | 0.6167 | — | — |
| Keyword Coverage | 94.0% | 84.0% | +10.0% |

## Per Query Type (RAG)

| Query Type | MRR@5 | Precision@3 | Keyword Coverage |
|------------|-------|-------------|-----------------|
| factual | 0.7500 | 0.4583 | 96.9% |
| conceptual | 1.0000 | 0.8571 | 96.4% |
| procedural | 0.9000 | 0.5333 | 86.0% |

## LaTeX Table (untuk Bab 4)

```latex
\begin{table}[h]
\centering
\caption{Perbandingan Kualitas Jawaban RAG vs Tanpa RAG}
\label{tab:rag-baseline}
\begin{tabular}{lccc}
\hline
\textbf{Metrik} & \textbf{RAG} & \textbf{Tanpa RAG} & \textbf{Peningkatan} \\
\hline
MRR@5 & 0.8750 & — & — \\
Precision@3 & 0.6167 & — & — \\
Keyword Coverage & 94.0\% & 84.0\% & +10.0\% \\
\hline
\end{tabular}
\end{table}
```