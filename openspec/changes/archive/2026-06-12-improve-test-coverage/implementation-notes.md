# Implementation Notes

## Session 2026-06-12 (P1 continuation)

### Full suite (verified 2026-06-12)
- `pytest tests/test_unit tests/test_integration tests/test_blackbox -q --cov=app --cov-branch`: **2216 passed**, 85 warnings (~3m11s).
- Total `app` coverage: **98.23%** statements (6268 stmts, 70 miss); branch partials remain on a few modules.

### New / expanded test files
| File | Purpose |
|------|---------|
| `tests/test_unit/test_discussion_direction.py` | `classify-relevance`, `session-summary`, `_parse_json_object` (was 0 tests) |
| `tests/test_unit/test_error_handlers.py` | HTTP/validation/unhandled handlers + `ExceptionMiddleware` (incl. re-raise HTTP/validation/LLMDegraded) |
| `tests/test_unit/test_track_activity.py` | `user_id` → `track_participation` branch |
| `tests/test_unit/test_chat_reading_recommendations.py` | `/reading-recommendations`, `build_recommendation_fallback` |
| `tests/test_unit/test_activity_log_repository_expanded.py` | list/cursor paths on `ActivityLogRepository` |

### Schema validators
- `test_api_schemas.py`: path-traversal rejects on `QueryRequest`, `AskRequest`, `ReadingRecommendationRequest`, `OrchestrationRequest`.

### Image extraction
- `test_document_processing_image_extraction.py`: `initialize_ocr_engine` success/fail, `run_ocr` wrapper, `run_page_ocr`, OCR exception branch.

### Acceptance modules (full-suite cov snapshot)
All **tasks.md** listed modules meet **≥90% statement** coverage. **100%** on: `dependencies`, `track_activity`, `schemas`, `error_handlers`, `activity_log_repository`, `plan_vs_reality`, `conformance_checker`, `srl_classifier`, `nlp_analytics`, `grounding_verifier`, many others.

Below 90% **effective branch** (BrPart only) or stmt edge cases:
| Module | Cover (stmt) | Notes |
|--------|----------------|-------|
| `image_extraction.py` | 95.95% | missing import path 22-24, `del image` 67-68 |
| `rag.py` | 93.93% | 389-397 |
| `health.py` | 95.59% | 69-70 |
| `mongodb_logger.py` | 91.67% | 160-165 |
| `llm.py` | 96.06% | 145-148 |

`error_handlers.py` → **100%** after `test_error_handlers.py`. `chat.py` → **99.27%** after reading-recommendations tests.

### Kolabri-core-api (parallel track)
- **700/700** vitest, 0 skipped (rate-limit test env, unskipped ITs).

### Final verification (2026-06-12)
- **2222 passed**, `--cov-fail-under=90` → **98.48%** total.
- Gap tests: RAG scaffolding early/late, health redis failure paths, `run_paddle_ocr` NameError branch.
- Change **archived**; CI runs full unit+integration+blackbox with 90% gate.

## Coverage Delta (document processing — earlier)
- `app/services/document_processing/image_extraction.py` | isolated runs documented previously; full-suite % varies with import paths.
- `app/services/document_processor.py` | **98.71%** stmt (full suite).

## Test Strategy Additions (document processing — earlier)
- See `test_document_processing_image_extraction.py` and `test_document_processor_full.py` for vision/OCR branches.
