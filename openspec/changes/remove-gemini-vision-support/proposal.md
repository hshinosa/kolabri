# Proposal: Remove Gemini Vision Support

## Problem
The project has decided to focus exclusively on:
- OpenAI-compatible LLM APIs (via custom base URL)
- Local embeddings via fastembed

Support for **Google Generative AI (Gemini / Gemini Vision)** — including any direct Gemini provider usage — is no longer required. The project will focus exclusively on OpenAI-compatible providers.

The existing OpenAI-compatible vision path (multimodal model via custom base URL) will remain, but all Gemini-specific configuration and code must be removed.

Keeping Gemini-specific code adds:
- Unnecessary dependency (`google-generativeai`)
- Extra configuration complexity
- Dead code paths that are never exercised in the target deployment

## Impact
From the inspection, the following areas are affected:

**Core Code**
- `app/services/document_processing/image_extraction.py`
- `app/services/document_processing/text_extraction.py`
- `app/services/document_processor.py`
- `app/core/config.py`

**Tests**
- `tests/test_unit/test_document_processing_text_extraction.py`
- `tests/test_unit/test_document_processor_full.py`
- `tests/test_unit/test_document_processor.py` (and related comprehensive/memory tests)

**Configuration & Dependencies**
- `requirements.txt`
- `.env` / `.env.example`
- Possibly `pyproject.toml`

**Historical Documentation**
- Old OpenSpec changes under `openspec/changes/decompose-document-processor-remaining-modalities/` (reference only)

## Proposed Solution
Remove all Gemini-specific code, configuration, and dependency (`google-generativeai`). The OpenAI-compatible vision path and the `vision_available` flag will remain functional for non-Gemini providers.

## Scope
- Remove all Gemini-specific code, configuration, and the `google-generativeai` dependency
- Keep the OpenAI-compatible vision path and `vision_available` flag functional
- Update tests that specifically test Gemini behavior
- Clean up `requirements.txt` / `pyproject.toml` if the dependency is no longer needed

## Non-Goals
- Removing OCR support (PaddleOCR) — this remains
- Changing the overall document processing architecture

## Success Criteria
- No references to `genai`, `GEMINI_VISION_MODEL`, or `google-generativeai` remain in the active codebase.
- OpenAI-compatible vision path and `vision_available` flag still work.
- Document processing works for text + OCR + OpenAI-compatible vision.
- All tests pass after cleanup.
