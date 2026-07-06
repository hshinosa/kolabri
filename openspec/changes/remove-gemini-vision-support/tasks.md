# Tasks: Remove Gemini Vision Support

## Implementation Tasks

### 1. Remove Gemini Code from Image Extraction
- [ ] Edit `app/services/document_processing/image_extraction.py`
- [ ] Remove `vision_model` / `vision_client` parameters and related logic
- [ ] Remove Gemini API call branches

### 2. Clean Up Text Extraction
- [ ] Edit `app/services/document_processing/text_extraction.py`
- [ ] Remove `vision_available` parameter and caption logic

### 3. Simplify Document Processor
- [ ] Edit `app/services/document_processor.py`
- [ ] Remove `genai` initialization and `vision_available` handling

### 4. Remove Configuration
- [ ] Edit `app/core/config.py`
- [ ] Remove `ENABLE_MULTIMODAL_PROCESSING`, `GEMINI_VISION_MODEL`, and related Gemini settings

### 5. Update Tests
- [ ] In `tests/test_unit/test_document_processing_text_extraction.py`: remove tests using `vision_available=True`
- [ ] In `tests/test_unit/test_document_processor_full.py`: remove `test_pdf_multimodal_vision_captions` and related vision tests
- [ ] Delete or rewrite any test that asserts multimodal caption behavior

### 6. Verification
- [ ] Run full test suite
- [ ] Verify document processing still works for PDF/DOCX/PPTX + OCR
- [ ] Confirm no remaining references to `genai` or `GEMINI_VISION_MODEL`

## Acceptance Criteria
- Gemini Vision code is completely removed from the active codebase.
- Document processing pipeline remains functional for text and OCR.
- All tests pass.

## Estimated Effort
- Medium (2–4 hours) — mainly due to test cleanup.
