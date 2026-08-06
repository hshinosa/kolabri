# Document Parsing Methods Reference Library

**Created**: July 9, 2026 | **Scope**: 8 mainstream document-understanding/OCR methods
**Purpose**: Thesis accuracy verification and oversimplification detection

## Files in This Directory

### 1. `QUICK_REFERENCE.txt` (172 lines)
**Start here** - Quick lookup guide with 8-method summary, top 5 oversimplifications, and workflow.
- 8 methods with 1-line key finding
- ⚠️ warnings for each
- Top 5 common thesis errors
- Step-by-step usage workflow

### 2. `INDEX.md` (59 lines)
**Navigation guide** - Method lookup table with status, key findings, and usage instructions.
- Quick lookup by method name
- Common oversimplifications summary
- Critical version notes
- Workflow checklist

### 3. `DOCUMENT_PARSING_METHODS_2026.md` (348 lines)
**Full reference** - Detailed technical documentation for each method.
- Actual Design section for each method
- Training model requirements
- Multimodal fusion approach
- Common oversimplification warning
- Evidence links (GitHub, papers, docs)
- Comparison matrix
- What each method DOES vs DOESN'T
- Thesis citation template

## Quick Start (60 seconds)

1. Open `QUICK_REFERENCE.txt`
2. Find your method in the 8-method list
3. Read the ⚠️ warning
4. If citing that method in thesis, check "Common Oversimplifications in Theses"
5. For full details, open `DOCUMENT_PARSING_METHODS_2026.md` and find the method

## Methods Covered

| # | Method | Category | Latest Version | Breaking Changes? |
|---|--------|----------|-----------------|-------------------|
| 1 | LayoutLMv3 | Multimodal Transformer | v3 (2022) | No |
| 2 | PaddleOCR | Pure OCR Pipeline | v6 (2026) | Ongoing |
| 3 | Donut | End-to-end VDU | Stable (2021) | No |
| 4 | MinerU | Multi-module Pipeline | v3.4.0 (June 2026) | Yes (v2→v3) |
| 5 | Docling | Configurable Pipeline | Active (2026) | N/A (modular) |
| 6 | Surya | Unified VLM | v2.0 (May 2026) | **YES (v1→v2 breaking)** |
| 7 | Dots MOCR | Document Paradigm | New (2026) | N/A |
| 8 | MultiDocFusion | RAG Chunker | Current (2026) | N/A |

## Top 5 Thesis Oversimplifications

1. **"Text extraction + OCR fallback"**
   - ❌ Wrong: All are pretrained fusion architectures
   - ✅ Right: "Multimodal fusion via [specific mechanism]"

2. **"Layout + text separately"**
   - ❌ Wrong: Most jointly fuse (except PaddleOCR which is text-only)
   - ✅ Right: "Jointly fuse layout and text via [mechanism]"

3. **"Single unified model"**
   - ❌ Wrong: Only Surya v2; others are orchestrated pipelines
   - ✅ Right: "[Method] uses [X models/stages] orchestrated as..."

4. **"Doesn't need training"**
   - ❌ Wrong: All require pretrained weights or fine-tuning
   - ✅ Right: "[Method] requires pretrained weights; fine-tuned on..."

5. **"Removes OCR entirely"**
   - ❌ Wrong: Donut removes external engines but uses vision encoding
   - ✅ Right: "Eliminates external OCR engines; uses direct vision encoding"

## Evidence Standards

All claims are **evidence-grounded**:
- ✅ Official GitHub repositories (July 2026 state)
- ✅ Published papers (2020-2026, arxiv.org)
- ✅ Official documentation (current)
- ✅ Release notes (May-July 2026)

Every method entry includes source links in the Evidence section.

## How to Use This Reference

### Scenario 1: Cite a method in thesis
1. Find method in `QUICK_REFERENCE.txt`
2. Read ⚠️ warning
3. Open `DOCUMENT_PARSING_METHODS_2026.md`
4. Copy text from "Actual Design" section
5. Cite evidence links in your thesis bibliography

### Scenario 2: Check if thesis wording is accurate
1. Open `QUICK_REFERENCE.txt`
2. Find "TOP 5 OVERSIMPLIFICATIONS" section
3. Check if your wording matches ❌ column
4. If yes, revise using ✅ column template
5. Cite the method's Evidence section

### Scenario 3: Understand a method fully
1. Open `DOCUMENT_PARSING_METHODS_2026.md`
2. Find method by name (Ctrl+F)
3. Read all 6 subsections:
   - Actual Design
   - Training Model Required
   - Multimodal Fusion Method
   - Common Oversimplification
   - Evidence
   - Comparison Matrix (bottom)

## Critical Version Notes

⚠️ **Surya v2.0 (May 27, 2026): BREAKING CHANGE**
- v1: Separate models for OCR, layout, tables
- v2: Single 650M unified model
- Do NOT conflate versions in thesis

⚠️ **MinerU v3.4.0 (June 2026)**
- Latest; check if thesis cites older version
- Architecture differences between versions

⚠️ **PaddleOCR v6 (2026)**
- Latest with PPLCNetV4 backbone
- Only handles text extraction, not layout

⚠️ **LayoutLMv3 (Microsoft, 2022)**
- Actively maintained; latest version
- v1, v2, v3 have different architectures

## Next Steps

1. **If reviewing thesis**: Start with `QUICK_REFERENCE.txt`
2. **If citing a method**: Open `DOCUMENT_PARSING_METHODS_2026.md` for full details
3. **If uncertain about accuracy**: Compare against "Common Oversimplification" sections
4. **If citing evidence**: Use links in "Source Evidence Index"

---

**Last Updated**: July 9, 2026, 01:30 UTC
**Reliability**: Evidence-grounded from current documentation, papers, and releases
**Contact**: For verification, cross-reference with GitHub permalinks in Evidence section
