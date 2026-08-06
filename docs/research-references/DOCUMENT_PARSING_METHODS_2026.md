# Document Parsing Methods: Actual Design Reference (2026)

**Purpose**: Compare mainstream document-understanding/OCR approaches to identify thesis oversimplifications.

**Current Date**: July 2026 | **Status**: Research-grounded evidence-based comparison

---

## 1. **LayoutLM / LayoutLMv2 / LayoutLMv3** (Microsoft, 2020-2022)

**Actual Design**:
- **NOT** a simple text-extraction-then-OCR fallback
- **Multimodal pretraining**: jointly learns text + layout + visual image features
- LayoutLM v1 requires external OCR (Tesseract, etc.) to provide text + bounding boxes; model fusion happens post-OCR
- LayoutLMv2 adds two-stream Transformer + spatial-aware self-attention for better cross-modality interaction
- LayoutLMv3 (latest): unified masking objectives (MLM + MIM + Word-Patch Alignment); first CNN-free design using vision patches like ViT

**Training Model Required**: Yes — pretrained transformer weights essential; fine-tuning on downstream tasks.

**Multimodal Fusion Method**: Cross-modal alignment via MLM (text) + MIM (image) + WPA (word-patch alignment).

**Common Oversimplification in Theses**: 
⚠️ Described as "OCR + layout encoder" when it's actually a **multimodal fusion architecture** with cross-modal alignment objectives. Not a simple two-stage pipeline.

**Evidence**:
- [LayoutLMv3 Paper](https://arxiv.org/pdf/2204.08387): Section 3 details unified masking objectives
- [Microsoft GitHub](https://github.com/microsoft/unilm/tree/master/layoutlm): Shows v2 spatial-aware attention mechanism
- [HF Docs](https://huggingface.co/docs/transformers/en/model_doc/layoutlm): Confirms multimodal pretraining approach

---

## 2. **PaddleOCR** (Baidu/PaddlePaddle, ongoing evolution)

**Actual Design**:
- **Pure OCR pipeline**: Text Detection → Text Recognition (separate models)
- Latest (v6): PP-OCRv6 uses PPLCNetV4 backbone + RepLKFPN; supports 50 languages in single model
- Multiple tiers: tiny (0.43M params edge), small (mobile), medium/server (higher accuracy)
- **No layout understanding or multimodal fusion**—strictly text localization + recognition
- Optional preprocessing: document orientation classification, text unwarping, text-line orientation

**Training Model Required**: Yes — needs trained detection + recognition models (or use pre-downloaded weights).

**Multimodal Fusion Method**: None. Pipeline is sequential: detect regions → recognize text within regions.

**Common Oversimplification in Theses**:
⚠️ Often cited as a "comprehensive document parser" when it's only **text extraction**. Does not handle layout, tables, or structured regions.

**Evidence**:
- [PaddleOCR Docs](http://www.paddleocr.ai/latest/en/version3.x/pipeline_usage/OCR.html): Explicit 5-module pipeline (no layout)
- [Medium Explainer (Feb 2026)](https://medium.com/data-science-in-your-pocket/from-pixels-to-words-paddleocr-pipeline-explained-60900cec85e1): Confirms text-only focus
- GitHub Discussion #14785: Community clarifies PPOCRv6 is OCR-only, not layout-aware

---

## 3. **Donut** (Naver CLOVA, 2021)

**Actual Design**:
- **OCR-free** end-to-end Transformer (Vision Encoder: Swin + Text Decoder: BART)
- No external OCR engine; directly predicts structured document output (e.g., JSON, HTML)
- Pre-trained on synthetic + real documents; fine-tuned per downstream task (form understanding, receipt parsing, etc.)
- Designed to avoid OCR error propagation and multi-stage pipeline overhead

**Training Model Required**: Yes — pretrained model needed; cannot run inference on raw weights.

**Multimodal Fusion Method**: End-to-end vision-to-text via Swin encoder embeddings → BART decoder.

**Common Oversimplification in Theses**:
⚠️ Marketed as "OCR replacement" but is actually a **VDU (Visual Document Understanding) model**—it reconstructs semantic content, not raw text. Different use case than traditional OCR.

**Evidence**:
- [GitHub](https://github.com/clovaai/donut): "OCR-free Document Understanding Transformer"
- [HF Docs](https://huggingface.co/docs/transformers/model_doc/donut): Emphasizes end-to-end structured output
- [Paper (2111.15664)](https://arxiv.org/abs/2111.15664): Sec 1 argues against OCR pipeline overhead

---

## 4. **MinerU** (OpenDataLab, 2024-2026)

**Actual Design**:
- **Multi-module strategy**: Layout detection → region-specific recognizers (OCR for text, formula recognition, table recognition)
- Latest (v2.5, 2026): Decoupled Vision-Language Model (1.2B params) with two-stage parsing
  - Stage 1: Efficient layout analysis on downsampled image
  - Stage 2: Targeted content recognition on native-resolution crops (preserves fine details)
- Combines PDF-Extract-Kit models + extensive preprocessing/postprocessing rules
- Handles scanned PDFs, diverse layouts, complex formulas, tables

**Training Model Required**: Yes — uses pre-trained layout detection, formula recognition, table recognition models; also fine-tuned on diverse datasets.

**Multimodal Fusion Method**: Multi-model orchestration: layout model identifies regions → task-specific recognizers (OCR, formula, table) process each region.

**Common Oversimplification in Theses**:
⚠️ Often treated as a monolithic "document parser" when it's actually a **carefully orchestrated multi-model pipeline**. Each region type uses domain-specific recognizer. Not a single model.

**Evidence**:
- [MinerU Paper (2409.18839)](https://arxiv.org/pdf/2409.18839): Sec 2.2 describes multi-module parsing strategy
- [MinerU2.5 Paper (2509.22186)](https://arxiv.org/html/2509.22186): Decoupled VLM architecture with coarse-to-fine stages
- [GitHub](https://github.com/opendatalab/MinerU): Changelog v3.4.0 documents model orchestration


---

## 5. **Docling** (IBM, 2024-2026)

**Actual Design**:
- **Pluggable architecture**: Multiple stages with configurable models
  - Layout detection: RT-DETR-based object detection
  - OCR: Pluggable engines (Tesseract, EasyOCR, RapidOCR, macOS Vision, SuryaOCR, etc.)
  - VLM conversion: Vision-Language Models (Granite, DeepSeek-OCR, GOT-OCR, etc.) for full-page understanding
- Output formats: DocTags (structured XML-like), Markdown, JSON
- Optional forced OCR override (replace digital text with OCR output for consistency)

**Training Model Required**: Depends on backend. Layout detection needs pretrained RT-DETR. VLM stage needs API or local model.

**Multimodal Fusion Method**: Pluggable pipelines—each stage (layout, OCR, VLM) can use different models; user configures the chain.

**Common Oversimplification in Theses**:
⚠️ Presented as a monolithic tool when it's a **configurable pipeline** where each stage is interchangeable. Users can swap OCR engines, VLMs, etc.

**Evidence**:
- [Docling Model Catalog](https://docling-project.github.io/docling/usage/model_catalog/): Lists all swappable stages
- [CLI Reference](https://docling-project.github.io/docling/reference/cli/): Shows `--ocr-engine`, `--vlm-model` flags
- [GitHub](https://github.com/docling-project/docling): Architecture docs confirm modular design

---

## 6. **Surya OCR 2** (Datalab, May 2026)

**Actual Design**:
- **Unified 650M-param VLM** (v2.0, May 2026): single model handles OCR + layout + table recognition
- Text detection remains separate lightweight torch model
- Served via vLLM (GPU) or llama.cpp (CPU/Apple Silicon)
- Multilingual: 90+ languages in single model; scores 83.3% on olmOCR-bench, 87.2% on 91-language eval
- Previous v1 used separate models; v2 consolidated into one for inference efficiency

**Training Model Required**: Yes — 650M VLM model weights required; text detection model separate.

**Multimodal Fusion Method**: Single VLM encoder processes image patches → unified decoder outputs text + layout + table structured tokens.

**Common Oversimplification in Theses**:
⚠️ Conflating v1 (multi-model) with v2 (unified model). Major architecture difference in May 2026 release.

**Evidence**:
- [GitHub Release v0.20.0 (May 27, 2026)](https://github.com/datalab-to/surya/releases/tag/v0.20.0): "Surya 2 is a ground-up rework: single 650M-param model"
- [Blog Announcement (May 27, 2026)](https://www.datalab.to/blog/surya-2): Details v2 consolidation and breaking changes
- [PyPI v0.17.0](https://pypi.org/project/surya-ocr/0.17.0/): Confirms v1 multi-model architecture

---

## 7. **Dots MOCR (Multimodal OCR)** (RedNote HiLab, 2026)

**Actual Design**:
- **Document parsing paradigm** (not just text extraction): parses text + graphics (charts, diagrams, icons, SVG-renderable elements) into unified output
- 3B-param model trained on PDFs, rendered webpages, native SVG assets
- Staged pretraining: general vision → broad document parsing → graphics-centric signals
- Outputs both text and SVG code for graphics (enables reconstruction and downstream reuse)
- Treats visual elements as first-class parsing targets, not discarded raster crops

**Training Model Required**: Yes — large-scale pretraining on diverse data; weights available.

**Multimodal Fusion Method**: End-to-end vision language model with instruction tuning; text and SVG outputs both from same decoder.

**Common Oversimplification in Theses**:
⚠️ If called "OCR," it's only technically correct for the text component. The main innovation is **graphics-to-SVG parsing**, which is fundamentally different from traditional OCR.

**Evidence**:
- [Paper (2603.13032)](https://arxiv.org/abs/2603.13032): Section 1 argues against discarding graphics as raster crops
- [GitHub](https://github.com/rednote-hilab/dots.mocr): Shows SVG output format alongside text
- Leaderboard results (olmOCR Arena): Ranks second only to Gemini 3 Pro on document parsing


---

## 8. **MultiDocFusion** (Hierarchical Multimodal Chunking, 2026)

**Actual Design**:
- **RAG-optimized chunking pipeline** (not a standalone parser):
  1. Document Parsing (DP): vision-based layout detection
  2. OCR: text extraction from regions
  3. DSHP-LLM: Document Section Hierarchical Parsing (LLM-based structure reconstruction)
  4. DFS-based Grouping: construct hierarchical chunks preserving structure
- Explicitly reconstructs document hierarchy (sections, subsections, etc.)
- Designed for industrial documents with complex layouts

**Training Model Required**: Yes — layout detection model + fine-tuned DSHP-LLM for hierarchical parsing.

**Multimodal Fusion Method**: Sequential: layout detection → OCR on regions → LLM hierarchical parsing → chunk assembly.

**Common Oversimplification in Theses**:
⚠️ Often presented as a "parser" when it's a **retrieval pipeline** for RAG. Optimizes for downstream retrieval, not document understanding per se.

**Evidence**:
- [Paper (2604.12352)](https://www.arxiv.org/pdf/2604.12352): Section 2 describes four-stage pipeline explicitly
- Evaluations: Tests on VQA benchmarks (not traditional parsing metrics)
- DSHP-LLM: Requires fine-tuning on hierarchical parsing tasks

---

## Quick Comparison Matrix

| Method | Type | Training Model Required | Text+Layout? | True Multimodal? | Core Innovation |
|--------|------|---------|------------|-----------------|-----------------|
| LayoutLM v3 | Multimodal Transformer | Yes | Yes | Yes (MLM+MIM+WPA) | Unified masking objectives |
| PaddleOCR | Text Pipeline | Yes | No | No | Efficient text det+rec |
| Donut | End-to-end VDU | Yes | Yes (implicit) | Yes (vision→text) | OCR-free structured output |
| MinerU | Multi-module Orchestration | Yes | Yes | Yes (layout→task-specific) | Diverse-dataset fine-tuning |
| Docling | Configurable Pipeline | Partial | Yes (pluggable) | Yes (swappable) | Flexible backend selection |
| Surya v2 | Unified VLM | Yes | Yes | Yes (single 650M model) | Consolidated v2.0 (May 2026) |
| Dots MOCR | Document Paradigm | Yes | Yes | Yes (text+SVG graphics) | Graphics-to-SVG first-class |
| MultiDocFusion | RAG Chunker | Yes | Yes | Yes (DP+OCR+LLM) | Hierarchical structure preservation |

---

## Key Warnings for Thesis Accuracy

### 1. "Text extraction + OCR fallback"
❌ **INACCURATE**: None of these are simple conditional logic. They're pretrained models with complex fusion objectives.
✅ **ACCURATE**: "LayoutLMv3 jointly processes text and layout via unified masking objectives (MLM + MIM + WPA)."

### 2. "Layout + text separately"
❌ **INACCURATE**: Models process layout and text sequentially as two stages.
✅ **ACCURATE**: "LayoutLMv3, Donut, Surya v2, MinerU all jointly fuse layout and text representations."

### 3. "Unified/single model"
❌ **INACCURATE**: All models use a single unified architecture.
✅ **ACCURATE**: "Only Surya v2 (May 2026) uses one model; others are orchestrated multi-model pipelines."

### 4. "Doesn't need training"
❌ **INACCURATE**: Models are zero-shot and require no fine-tuning.
✅ **ACCURATE**: "All methods require pretrained weights or fine-tuning on downstream tasks."

### 5. "Removes OCR"
❌ **INACCURATE**: Donut eliminates all OCR component.
✅ **ACCURATE**: "Donut removes external OCR engines but uses vision encoding; others integrate OCR as one component."

---

## Recommendation: Thesis Citation Template

**DO THIS** when citing any method:

"[Method X] is a [type] that [specific architecture]. It combines:
1. [Component A] via [mechanism] to [output]
2. [Component B] via [mechanism] to [output]
3. [Component C] via [mechanism] to [output]

This differs from [similar method Y] in that [specific distinction].

[Method X] requires [pretrained weights / fine-tuning] and outputs [structured format: JSON/Markdown/etc.]."

**DO NOT** say:
- "extracts text and uses OCR as fallback" (oversimplified)
- "combines layout and text" (vague about mechanism)
- "unified model" (unless specifically Surya v2)
- "doesn't need training" (false for all methods)

---

## Quick Reference: What Each Method ACTUALLY Does

| Method | DOES Handle | DOES NOT Handle |
|--------|------------|-----------------|
| **LayoutLM v3** | Text + layout + visual features | Standalone OCR; scanned PDFs without preprocessing |
| **PaddleOCR** | Text detection + recognition | Layout, tables, structure, graphics |
| **Donut** | Structured output from document images | Raw text extraction; layout analysis; scanned PDFs |
| **MinerU** | Layout + text + formulas + tables + scanned PDFs | Real-time inference; very small device deployment |
| **Docling** | Pluggable stages (layout, OCR, VLM) | Specific domain tasks without configuration |
| **Surya v2** | OCR + layout + tables (single model) | Formulas, complex graphics, scanned handwriting |
| **Dots MOCR** | Text + graphics (SVG output) | Traditional OCR-only use cases; non-graphic-rich docs |
| **MultiDocFusion** | Document hierarchy + RAG chunking | Standalone parsing; real-time inference |


---

## Source Evidence Index

### LayoutLM Family
- **LayoutLMv3 Paper**: https://arxiv.org/pdf/2204.08387 (Section 3: Unified masking objectives)
- **Microsoft GitHub**: https://github.com/microsoft/unilm/tree/master/layoutlm
- **HuggingFace Docs**: https://huggingface.co/docs/transformers/en/model_doc/layoutlm

### PaddleOCR
- **Official Docs**: http://www.paddleocr.ai/latest/en/version3.x/pipeline_usage/OCR.html
- **Medium Explainer (Feb 2026)**: https://medium.com/data-science-in-your-pocket/from-pixels-to-words-paddleocr-pipeline-explained-60900cec85e1
- **GitHub**: https://github.com/PaddlePaddle/PaddleOCR

### Donut
- **GitHub**: https://github.com/clovaai/donut
- **Paper**: https://arxiv.org/abs/2111.15664
- **HuggingFace**: https://huggingface.co/docs/transformers/model_doc/donut

### MinerU
- **Original Paper (2409.18839)**: https://arxiv.org/pdf/2409.18839
- **MinerU2.5 Paper (2509.22186)**: https://arxiv.org/html/2509.22186
- **GitHub**: https://github.com/opendatalab/MinerU (Latest: v3.4.0, June 2026)

### Docling
- **Model Catalog**: https://docling-project.github.io/docling/usage/model_catalog/
- **CLI Reference**: https://docling-project.github.io/docling/reference/cli/
- **GitHub**: https://github.com/docling-project/docling

### Surya OCR
- **Release v0.20.0 (May 27, 2026)**: https://github.com/datalab-to/surya/releases/tag/v0.20.0
- **Blog Post**: https://www.datalab.to/blog/surya-2
- **PyPI**: https://pypi.org/project/surya-ocr/

### Dots MOCR
- **Paper (2603.13032)**: https://arxiv.org/abs/2603.13032
- **GitHub**: https://github.com/rednote-hilab/dots.mocr

### MultiDocFusion
- **Paper (2604.12352)**: https://www.arxiv.org/pdf/2604.12352

---

## How to Use This Reference

**When you find a method mentioned in your thesis:**

1. Locate it in the table above
2. Read the "Actual Design" section
3. Check the "Common Oversimplification" warning
4. Compare against what your thesis says
5. If mismatch: revise thesis to match "Actual Design" + cite Evidence section

**Example workflow:**

Your thesis says: "MinerU combines text extraction and OCR as fallback."

Reference says: "Multi-module strategy: Layout detection → region-specific recognizers"

Action: Revise to: "MinerU uses a multi-module pipeline where layout detection guides region-specific recognizers (OCR for text, formula recognition for formulas, table recognition for tables)."

---

## Version Notes (Critical for Accuracy)

- **PaddleOCR v6** (latest): PP-OCRv6 with PPLCNetV4 backbone (2026)
- **LayoutLMv3** (Microsoft): Latest multimodal version with unified masking (2022, actively maintained)
- **Surya v2.0** (May 27, 2026): **BREAKING CHANGE** from v1—unified 650M model, not multi-model
- **MinerU v3.4.0** (June 2026): Latest with improved layout detection
- **Docling**: Active development; check version for available OCR engines
- **Donut**: Stable since 2021; fine-tuning variations common

---

**Last Updated**: July 9, 2026
**Reliability**: Evidence-grounded from 2026 documentation, papers, and GitHub releases
**Intended Use**: Thesis accuracy verification and oversimplification detection
