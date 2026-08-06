# Document Parsing Methods Reference Index

**Location**: `docs/research-references/DOCUMENT_PARSING_METHODS_2026.md`

**Last Updated**: July 9, 2026 | **Methods Covered**: 8 | **Total Lines**: 348

## Quick Lookup by Method

| Method | Category | Status | Key Finding |
|--------|----------|--------|------------|
| LayoutLMv3 | Multimodal Transformer | ✅ Current | Unified masking (MLM+MIM+WPA), not text→layout seq |
| PaddleOCR v6 | Pure OCR | ✅ Current | Text only, no layout/structure handling |
| Donut | End-to-end VDU | ✅ Stable | OCR-free but outputs structured content, not raw text |
| MinerU v3.4.0 | Multi-module Pipeline | ✅ Current | Layout detection → task-specific recognizers |
| Docling | Configurable Pipeline | ✅ Active | Swappable stages (layout, OCR, VLM) |
| Surya v2.0 | Unified VLM | ⚠️ Breaking Change | **May 2026**: 650M single model (was multi-model v1) |
| Dots MOCR | Document Paradigm | ✅ New (2026) | Text + SVG graphics parsing (not traditional OCR) |
| MultiDocFusion | RAG Chunker | ✅ Current | Hierarchical parsing for retrieval (not standalone) |

## Common Oversimplifications Found in Academic Writing

1. **"Text extraction + OCR fallback"** → ❌ All are pretrained fusion architectures
2. **"Layout + text separately"** → ❌ Most jointly fuse (except PaddleOCR which is text-only)
3. **"Single unified model"** → ⚠️ Only Surya v2 (May 2026); others are pipelines
4. **"Doesn't need training"** → ❌ All require pretrained weights or fine-tuning
5. **"Removes OCR entirely"** → ⚠️ Donut removes external engines but uses vision encoding

## How to Use This Reference

**Thesis Review Workflow**:
1. Identify method mentioned in your thesis
2. Look up row in Quick Lookup table
3. Open full document (DOCUMENT_PARSING_METHODS_2026.md)
4. Read "Actual Design" section (top of each method)
5. Check "Common Oversimplification" warning
6. Compare against thesis wording
7. If mismatch → revise thesis to match evidence

## Critical Version Notes

- **Surya v2.0 (May 27, 2026)**: BREAKING CHANGE—unified model architecture (not v1 multi-model)
- **MinerU v3.4.0 (June 2026)**: Latest with improved layout detection
- **PaddleOCR v6**: Latest PP-OCRv6 with PPLCNetV4 backbone
- **LayoutLMv3**: Microsoft's latest; actively maintained
- **Docling**: Version-dependent; check available OCR engines

## Evidence Sources

All claims backed by:
- Official GitHub repositories (2026 state)
- Published papers (2020-2026)
- Official documentation (current)
- Release notes and announcements (May-July 2026)

See "Source Evidence Index" section in main document for full citations.

---

**Next Step**: Open `DOCUMENT_PARSING_METHODS_2026.md` and compare each cited method against the "Actual Design" and "Common Oversimplification" sections.
