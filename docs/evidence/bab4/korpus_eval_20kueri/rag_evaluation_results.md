# RAG Evaluation Results

**Date:** 2026-07-21 09:29:26  
**Dataset:** `data/evaluation/rag_evaluation_dataset.json` (20 queries)

## Overall Metrics

| Metric | RAG | No-RAG | Delta |
|--------|-----|--------|-------|
| MRR@5 | 1.0000 | — | — |
| Precision@3 | 0.9500 | — | — |
| Keyword Coverage | 94.8% | 0.0% | +94.8% |

## Per Query Type (RAG)

| Query Type | MRR@5 | Precision@3 | Keyword Coverage |
|------------|-------|-------------|-----------------|
| factual | 1.0000 | 1.0000 | 100.0% |
| conceptual | 1.0000 | 0.9524 | 100.0% |
| procedural | 1.0000 | 0.8667 | 79.0% |

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
MRR@5 & 1.0000 & — & — \\
Precision@3 & 0.9500 & — & — \\
Keyword Coverage & 94.8\% & 0.0\% & +94.8\% \\
\hline
\end{tabular}
\end{table}
```