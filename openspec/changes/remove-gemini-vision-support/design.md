# Design: Remove Gemini Vision Support

## Overview
Remove all Gemini-specific code and configuration. The OpenAI-compatible vision path and the `vision_available` flag will remain functional for non-Gemini providers. Only Gemini-related branches and initialization will be removed.

## Changes by File

### 1. `app/services/document_processing/image_extraction.py`
- Remove parameters `vision_model` and `vision_client` from `extract_images_from_pdf(...)`.
- Delete the `if vision_model:` branch that calls Gemini.
- Keep only the PaddleOCR path.

### 2. `app/services/document_processing/text_extraction.py`
- Keep the `vision_available: bool` parameter and the `if vision_available and caption_fn:` block (used by OpenAI-compatible vision).
- Only remove any Gemini-specific logic inside those paths (if any).

### 3. `app/services/document_processor.py`
- Remove `import google.generativeai as genai` and Gemini initialization.
- Keep `self.vision_available` and `ENABLE_MULTIMODAL_PROCESSING` (used by OpenAI-compatible vision).
- Remove only Gemini-specific branches.

### 4. `app/core/config.py`
- Remove `GEMINI_VISION_MODEL` and `GEMINI_API_KEY`.
- Keep `ENABLE_MULTIMODAL_PROCESSING` (controls OpenAI-compatible vision).
- Remove the fallback logic `GEMINI_API_KEY` ← `GOOGLE_API_KEY`.

### 5. Tests
- Delete or rewrite tests that assert `vision_available=True` behavior.
- Update mocks that simulate Gemini Vision responses.
- Remove mocks for Gemini Vision.

## Backward Compatibility
- Documents that previously used vision captions will now only have OCR text (if available).
- No breaking change for text-only or OCR-only processing.

## Risks & Mitigations

- **Config fallback risk**: `GEMINI_API_KEY` currently falls back from `GOOGLE_API_KEY`. **Mitigation**: Remove the fallback logic together with `GEMINI_API_KEY`.
- **OpenAI-compatible vision path stays**: The multimodal vision capability via OpenAI-compatible endpoint remains. Only Gemini-specific code is removed.
- **Test volume**: There are more vision-related tests than initially listed. **Mitigation**: Use `rg` / `grep` to find all occurrences of `vision_available` before deleting tests.
