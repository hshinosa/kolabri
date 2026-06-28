# Final thesis review context

> **SUPERSEDED (Juni 2026):** Angka di bawah adalah snapshot **pra-alignment**. Naskah final + bukti: `docs/evidence/bab4/` (`PHASE0_SNAPSHOT.md`, `TA_CROSS_REFERENCE_AUDIT.md`, `PHASE5_CHECKLIST.md`). Ringkas: **2411 passed / 2414 collected**, **99,92%** cov, **85 hal** `main.pdf`, HTTP **67–122 RPS**, rerank P@3 **0,85→0,90**.

This document preserves the **historical** final-state review context for the thesis in `/Users/hshino/Kuliah/latex-documents/TA` before Bab 4 alignment (Mei–Juni 2026).

## Current verified state *(historical — see banner above)*

- Thesis scope has been narrowed so that **results, testing, abstract, chapter 4, and chapter 5 focus on AI Engine only**.
- The thesis compiles successfully to `main.pdf`.
- Last known clean compile state after polishing/layout cleanup *(pre-alignment)*:
  - `main.pdf` = 66 pages *(now ~85 after Bab 4/lampiran)*
  - no LaTeX errors
  - no overfull / underfull box warnings in the final checked compile log
- AI-engine-related implementation/results already reflected in the thesis include:
  - Qdrant replacing ChromaDB
  - local multilingual embedding model `paraphrase-multilingual-MiniLM-L12-v2`
  - OpenAI-compatible API for LLM access
  - AI Engine-only test totals: `2.209` tests, `98,86%` coverage *(→ 2411 / 99,92% post-repro)*
  - AI Engine-only E2E total: `21` scenarios

## Files reviewed in current state

- `frontmatter/abstrak.tex`
- `bab/bab1.tex`
- `bab/bab2.tex`
- `bab/bab3.tex`
- `bab/bab4.tex`
- `bab/bab5.tex`

## Executive review verdict

The thesis is **strong as an engineering/backend TA** and already looks much closer to a finished final thesis than a proposal or project note. However, from the perspective of a harsh examiner, the main remaining risks are **not implementation risks** but **claim-discipline risks**:

1. some claims are still slightly stronger than the available evidence,
2. methodology targets in chapter 3 still exceed the executed evaluation in chapter 4,
3. several places blur the boundary between **software verification** and **scientific validation**.

In short:

- **implementation credibility:** strong
- **research-method rigor:** still attackable in some sections
- **defense risk:** concentrated in hypotheses, evaluation scale, and Logic Listener validation

---

## Final hostile review by file

### 1. `frontmatter/abstrak.tex`

#### Risk A — overclaiming impact of guardrails and hallucination control
- **Line 4**
- Problematic wording:
  - `guardrails berlapis diterapkan ... agar risiko halusinasi dapat ditekan`
- Why it is attackable:
  - sounds like measured impact, but the abstract does not immediately state the evaluation is limited and the strongest real-data evidence is still small-sample.
- Severity: **High**

#### Risk B — Logic Listener phrased as if its analytical correctness is established
- **Line 4**
- Problematic wording:
  - `mendeteksi indikator Higher-Order Thinking ... dan memicu intervensi otomatis ketika kualitas diskusi menurun`
- Why it is attackable:
  - this sounds like validated analytic correctness, but chapter 4 does not yet present strong precision/recall-style validation for HOT detection or intervention relevance.
- Severity: **High**

#### Risk C — “100% grounding” headline with very small sample
- **Line 4**
- Problematic wording:
  - `tingkat kelulusan grounding 100% pada pengujian 5 kueri berbasis data aktual`
- Why it is attackable:
  - 100% is rhetorically strong, but `n=5` is easy to challenge as too small.
- Severity: **High**

#### Risk D — performance framing may be misread as whole-system performance
- **Line 4**
- Problematic wording:
  - `latensi 2--4 ms untuk endpoint analitik (hingga 672 RPS pada 5 klien paralel)`
- Why it is attackable:
  - without care, this can be read as chatbot-system performance instead of non-LLM analytic endpoint performance.
- Severity: **Medium-High**

#### Risk E — “divalidasi” is stronger than “scenario pass”
- **Line 4 / 14**
- Problematic wording:
  - `seluruh 21 skenario end-to-end ... berhasil divalidasi`
- Why it is attackable:
  - “validated” can be challenged as too broad if what is really meant is “all scenarios passed”.
- Severity: **Medium**

---

### 2. `bab/bab1.tex`

#### Risk A — imported hallucination baseline may be attacked if not tightly supported
- **Line 9**
- Problematic wording:
  - `Studi dari Stanford University (2024) menunjukkan ... 23-42%`
- Why it is attackable:
  - the number is precise and strong; an examiner may ask for exact source, domain, and definition of hallucination.
- Severity: **High**

#### Risk B — latency target `<500ms` invites later attack
- **Line 26**
- Problematic wording:
  - `target: <500ms untuk respons chat`
- Why it is attackable:
  - later results reinterpret this as realistic mainly for local/non-LLM backend work, which can look like post-hoc reframing.
- Severity: **High**

#### Risk C — `mengurangi halusinasi hingga 80%` is too sharp for current evidence
- **Line 27**
- Problematic wording:
  - `target: mengurangi halusinasi hingga 80%`
- Why it is attackable:
  - chapter 4 does not provide a clean controlled baseline-vs-treatment experiment proving an 80% reduction.
- Severity: **High**

#### Risk D — `>95% kelengkapan atribut SRL` not transparently evidenced
- **Line 28**
- Problematic wording:
  - `target: >95% kelengkapan atribut SRL`
- Why it is attackable:
  - chapter 4 describes structured logging and export results, but not a clearly reported measured completeness percentage.
- Severity: **High**

#### Risk E — H3 overcommits on concurrency scale
- **Lines 58–62**
- Problematic wording:
  - `50+ pengguna konkuren`
- Why it is attackable:
  - actual evidence is only 5 parallel clients, so the stated hypothesis is stronger than the executed evaluation.
- Severity: **High**

---

### 3. `bab/bab2.tex`

#### Risk A — literature phrasing may overextend source claims
- **Lines 49–50**
- Problematic wording:
  - `state-of-the-art`, `faithfulness`, `relevansi`
- Why it is attackable:
  - if the cited paper is paraphrased too freely, an examiner may challenge whether the exact performance framing or metric wording is sourced accurately.
- Severity: **Medium-High**

#### Risk B — pedagogical benefit phrased too strongly
- **Line 53**
- Problematic wording:
  - `mengoptimalkan capaian pembelajaran mahasiswa`
- Why it is attackable:
  - the thesis does not appear to measure actual learning outcomes, so this sounds stronger than the evidence base.
- Severity: **High**

#### Risk C — literature-to-gap moves can be challenged as interpretive stretch
- **Lines 70–72**
- Problematic wording:
  - `guru sangat membutuhkan classroom awareness ...`
  - `implementasi mereka masih offline atau batch`
- Why it is attackable:
  - this may be fair, but it is a classic place where an examiner asks whether the paper really says that directly.
- Severity: **Medium**

#### Risk D — “sangat sesuai” lacks criteria
- **Line 81**
- Problematic wording:
  - `sangat sesuai`
- Why it is attackable:
  - evaluative wording without explicit criteria is vulnerable.
- Severity: **Medium**

#### Risk E — “harus mampu” and “setiap pesan” can exceed later evidence
- **Lines 280–304**
- Problematic wording:
  - `harus mampu menganotasi setiap pesan`
- Why it is attackable:
  - chapter 4 does not strongly prove annotation correctness for every message.
- Severity: **Medium-High**

---

### 4. `bab/bab3.tex`

#### Risk A — methodology promises more than results deliver
- **Lines 521–529 and 546–551**
- Problematic wording includes:
  - `human evaluation pada 100 kueri uji`
  - `50+ pengguna`
  - `Logic Listener Accuracy: >=80% precision dan recall`
  - `Data Completeness: >=95%`
- Why it is attackable:
  - chapter 4 does not appear to fully deliver these evaluation targets.
- Severity: **Critical**

#### Risk B — silence threshold inconsistency
- **Line 574** versus discussion/results elsewhere using 10 minutes
- Problematic wording:
  - `Tidak ada pesan 5 menit`
- Why it is attackable:
  - inconsistent threshold values signal poor alignment between design and implementation.
- Severity: **Critical**

#### Risk C — SQL/ORM/autoscaling language may not match the real stack
- **Lines 648–650**
- Problematic wording:
  - `Injeksi SQL`, `ORM`, `autoscaling`
- Why it is attackable:
  - the AI Engine stack here is MongoDB / Qdrant / FastAPI-focused; SQL/ORM wording and autoscaling claims may look like stale template residue.
- Severity: **Critical**

#### Risk D — circuit breaker / fallback may sound implemented when later text says otherwise
- **Lines 668–673**
- Problematic wording:
  - `Sistem menerapkan circuit breaker pattern... fallback...`
- Why it is attackable:
  - later chapters acknowledge failover is not fully implemented, creating direct contradiction.
- Severity: **Critical**

#### Risk E — contextual system features can still dilute AI-Engine-only focus
- **Lines 655–664**
- Problematic wording:
  - dashboard-heavy or system-wide feature framing
- Why it is attackable:
  - if too strong, examiner may ask whether the thesis scope is still broader than AI Engine.
- Severity: **High**

---

### 5. `bab/bab4.tex`

#### Risk A — E2E count contradiction
- **Lines 204–205 vs 232**
- Problematic wording:
  - text says `Total 15 skenario E2E diuji`
  - table total says `21`
- Why it is attackable:
  - this is the clearest credibility-damaging inconsistency in the current thesis.
- Severity: **Critical**

#### Risk B — latency notation is easy to misread and therefore dangerous
- **Lines 253–265 and 283**
- Problematic wording:
  - `2.236 ms = 2.236 milidetik ≈ 2,2 detik`
- Why it is attackable:
  - the notation depends on Indonesian thousands-separator interpretation and can still confuse readers badly.
- Severity: **Critical**

#### Risk C — RAG metrics mix incompatible signals
- **Lines 138–146, 153–154, 347, 355–359**
- Problematic wording:
  - `Lulus`
  - `rata-rata 0,9`
  - `100%`
  - `didukung secara parsial`
- Why it is attackable:
  - these are different metric styles that can make the evaluation look ad hoc rather than systematically designed.
- Severity: **Critical**

#### Risk D — projection to 50+ users exceeds evidence
- **Lines 347–351**
- Problematic wording:
  - `diproyeksikan bahwa sistem mampu ...`
- Why it is attackable:
  - projections are not the same as tested results.
- Severity: **High**

#### Risk E — compatibility/export claim may be too strong
- **Lines 371–372**
- Problematic wording:
  - `dapat langsung diimpor ... tanpa transformasi tambahan`
- Why it is attackable:
  - unless import was actually demonstrated with tools like ProM/Disco, this can be challenged as overclaiming compatibility.
- Severity: **High**

---

### 6. `bab/bab5.tex`

#### Risk A — H3 conclusion still slightly too strong
- **Line 10**
- Problematic wording:
  - `mendukung hipotesis H3 ... throughput melampaui target 100 RPS`
- Why it is attackable:
  - H3 in chapter 1 also includes 50+ concurrent users, which was not actually tested at that scale.
- Severity: **High**

#### Risk B — hallucination-reduction claim still stronger than evidence
- **Line 12**
- Problematic wording:
  - `mengurangi halusinasi`
- Why it is attackable:
  - reduction language implies comparative evidence stronger than what is presented.
- Severity: **High**

#### Risk C — “validated through 66 security tests” may still sound too broad
- **Line 14**
- Problematic wording:
  - `berhasil divalidasi melalui 66 test cases`
- Why it is attackable:
  - good software testing evidence, but an examiner may say it proves scenario pass, not comprehensive security validation.
- Severity: **Medium-High**

#### Risk D — XES compatibility claim is strong without visible import proof
- **Line 16**
- Problematic wording:
  - `kompatibel dengan standar XES`
- Why it is attackable:
  - may require stronger direct proof.
- Severity: **High**

#### Risk E — Logic Listener claim still reads more validated than implemented
- **Line 18**
- Problematic wording:
  - `berhasil menganalisis... mengklasifikasikan... memicu intervensi otomatis`
- Why it is attackable:
  - chapter 4 does not fully support all of those as high-confidence validated claims.
- Severity: **High**

---

## Highest-risk cross-file issues (priority order)

1. **Critical:** `bab4.tex` E2E count inconsistency (`15` vs `21`)
2. **Critical:** `bab4.tex` latency notation that can be misread (`2.236 ms ≈ 2.2 detik` style)
3. **Critical:** `bab3.tex` methodology targets not matched by executed evaluation (100 query / 50+ users / precision-recall / completeness)
4. **Critical:** `bab3.tex` contradiction-prone implementation wording (circuit breaker / fallback / autoscaling / SQL-ORM residue)
5. **High:** Abstract + conclusions still slightly stronger than the available evidence on hallucination reduction / HOT detection / intervention correctness
6. **High:** Logic Listener remains the most weakly validated major contribution

## Defensive reading of current thesis

If defended carefully, the thesis is still strongest when framed as:

- an AI Engine engineering contribution,
- with strong implementation and software verification evidence,
- with promising but still limited empirical validation for some research claims,
- and explicit acknowledgment that several larger-scale validations remain future work.

If defended incautiously, it is vulnerable wherever software verification is implicitly treated as equal to scientific validation.
