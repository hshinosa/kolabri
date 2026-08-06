Keluaran pengujian Bab 4 — unggah seluruh isi folder ini ke Drive:
https://drive.google.com/drive/folders/1N8VCky-HHdtB8E4mVvrX5h4IXeajorE5?usp=share_link

Isi ringkas (log / angka):
- REPRODUCTION_REPORT_20260721.md  : ringkasan reproduksi
- rag_evaluation_results.md        : evaluasi RAG 20 kueri
- rag_eval_console_*.txt           : log konsol evaluasi RAG
- http_bench_*.txt                 : benchmark HTTP
- locust_*.txt                     : keluaran Locust
- pytest_bench_*.txt               : pytest-benchmark
- pytest_cov_*.txt                 : cakupan pytest
- repro_ta_*_stats*.csv            : statistik Locust/repro
- reproduction_*.json              : artefak benchmark HTTP
- rerank_ablation_*.json           : artefak A/B rerank
- ai_engine_commit_*.txt           : commit AI Engine saat run

Korpus data (baru digabung, bukti sidang):
- korpus_pdf_simulasi/IF201/       : 6 PDF simulasi (eval 36 kueri)
- korpus_pdf_simulasi/IF202/       : 6 PDF simulasi
- korpus_pdf_simulasi/IF211/       : 6 PDF simulasi
- korpus_pdf_simulasi/sample_if211_minggu/ : PDF/MD contoh minggu IF211 (docs)
- korpus_eval_20kueri/             : course_eval_content.txt + rag_evaluation_dataset.json
  (korpus teks untuk gold 20 kueri / koleksi Qdrant course_eval)
- korpus_logic_listener/           : gold JSON Logic Listener (uji fungsional)

Asal file:
- PDF simulasi: Kolabri-client-app/storage/app/public/demo-materials/if201|if202|if211-*.pdf
- Eval 20 kueri: Kolabri-ai-engine/data/evaluation/

Angka naskah (ringkas): pytest 2500 lulus; cov 94,75%; MRR@5 1,00; P@3 0,95;
keyword 94,8% (RAG) vs 84,0% (tanpa RAG) → selisih sekitar 10 poin persentase;
engagement ~122 RPS (skrip) / ~67 RPS (Locust).
