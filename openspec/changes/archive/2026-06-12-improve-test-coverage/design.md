# Design: Improve Test Coverage for Low-Coverage Modules

## Overview
We will systematically add tests for under-covered modules, grouped by risk and dependency. Tests will use the existing patterns in the project:
- Unit tests with heavy mocking for external services (LLM, DB, Redis, vision clients).
- Integration-style tests within unit/integration folders for composed logic, including RAG flows and analytics pipelines.
- Fixtures and helpers from existing test files, including `proc`, `proc_vision`, and mock settings.
- Focus on branches, error paths, and edge cases shown by current module behavior and existing test gaps.

The OpenAI-compatible vision path (post-Gemini removal) will be explicitly tested in image extraction and document processor.

Blackbox test infrastructure will be fixed first as a prerequisite for E2E measurement.

## Categorized Modules & Test Strategy

All work in this design must target only the modules explicitly listed below in this file; no unnamed module, grouped placeholder, or "and others" bucket is allowed, and every listed module must reach at least 90% statement coverage and 90% branch coverage.

### 1. High Priority - Document Processing & Ingestion (Biggest current gap)
- `app/services/document_processing/image_extraction.py` (76.3%, 35 misses)
  - Add tests for `generate_image_caption` with OpenAI-compatible client (success, empty, errors, RGBA conversion, no conversion).
  - Cover OCR paths, image size filtering, extraction from PDF/DOCX/PPTX.
  - Use mocks for vision_client and paddleocr.
- `app/services/document_processor.py` (vision/OCR initialization branches and `_generate_image_caption` delegation branch)
  - Ensure vision/OCR init branches are covered (OpenAI path only).
- `app/services/document_processing/text_extraction.py`
  - Cover PDF/text extraction branches for OCR fallback, caption callback usage, and alternate extraction outcomes.
- `app/services/document_processing/chunking.py`
  - Cover chunk splitting and overlap decision branches.

### 2. High Priority - Advanced Analytics (Critical for thesis validation)
- `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`
  - Add tests for alignment scoring, topic coverage, deviation detection, SRL phase classification, SMART goal validation.
  - Use synthetic XES/activity logs.
  - Cover edge cases: empty logs, perfect conformance, various anomaly types (silence, inequality, low quality).
- `app/services/nlp_analytics.py` (rule-based HOT/engagement) - cover HOT indicator branches, engagement classification branches, lexical-variation/TTR branches, and threshold-based output branches.

### 3. API & Routes Layer
- `app/api/dependencies.py` (0%)
  - Test `get_db`, authentication/current-user providers, and their failure branches with mocks.
- `app/api/routes/track_activity.py` (50%)
  - Cover activity logging endpoints and error paths.
- `app/api/routes/health.py` (89.71%)
  - Cover all health check branches and dependency failures.
- `app/api/batch_routes.py`
- Cover partial batch failure, retrieval-size mismatch branches, and alternate response-formatting paths.
- `app/api/schemas.py`
- Cover validator branches and default-value branches.
- `app/api/routes/documents.py`
  - Cover upload validation edge cases, unsupported file type branch, and storage error handling.
- `app/api/routes/chat.py`
  - Cover guarded response / short-circuit branches and fallback responses.
- `app/api/routes/analytics.py`
  - Cover alternate pagination/filter branches and conditional response shaping.

### 4. Core Infrastructure
- `app/core/error_handlers.py` (81.48%)
  - Test validation-error, HTTP-exception, unhandled-exception, and logging branches.
- `app/core/redis_cache.py` (97.52%)
  - Cover cache get/set/delete, connection failures, TTL.
- `app/core/cache_analyzer.py`
  - Cover low-frequency recommendation branch and analyzer summary edge cases.
- `app/core/circuit_breaker.py`
  - Cover half-open/exit branches and recovery transitions still marked partial.
- `app/core/guardrails.py`
- Cover late-stage decision branches and final fallback path.

### 5. Services & Orchestration
- `app/services/llm.py` (96.06%)
  - Retry logic, timeout, error classification, circuit breaker integration.
- `app/services/mongodb_logger.py` (91.67%)
  - Connect, logging activity, XES export paths, error handling.
- `app/services/logic_listener.py`
  - Silence detection, off-topic detection, participation inequity thresholds, and fallback outputs.
- `app/services/intervention.py`
  - Intervention type selection, confidence thresholds, and prompt assembly branches.
- `app/services/orchestration.py`
  - State transitions, cooldown enforcement, and teacher-notification gating.
- `app/services/rag.py`
  - Full RAG flows with/without retrieval, FETCH/NO_FETCH policy decisions, grounding success/failure, semantic-cache hit/miss.
- `app/services/grounding_verifier.py`
  - Support/mismatch scoring thresholds and low-confidence branches.
- `app/services/reranker.py`
  - Enabled path, disabled path when fastembed unavailable, empty input, and rerank truncation logic.
- `app/services/rag_benchmark_runner.py`
  - Benchmark orchestration with mocked inputs, empty dataset, and result aggregation branches.
- `app/services/rag_benchmark_bootstrap.py`
  - Bootstrap setup and disabled/empty benchmark branches.
- `app/services/toxicity_scorer.py`
  - Pattern scoring, neutral input, and threshold crossing cases.
- `app/services/socratic_filter.py`
  - Valid Socratic prompt, direct-answer rejection, and formatting edge cases.
- `app/services/pii_detector.py`
  - NIM/email/phone detection and clean input paths.
- `app/services/injection_detector.py`
  - Prompt-injection pattern hits, multilingual cases, and safe input path.
- `app/services/efficiency_guard.py`
  - Duplicate detection, cache interaction, and edge thresholds.
- `app/services/goal_validator.py`
- Evidence-scoring branches and SMART fallback-logic branches.
- `app/services/batch_llm.py`
  - Batch success, partial failure, and aggregation error handling.

### 6. Data & Export Layer
- `app/services/vector_store.py`
  - Initialization success/failure, collection creation, upsert/query/delete, and client error branches.
- `app/services/export_service.py`
  - CSV export formatting, empty dataset branch, and write failure handling.
- `app/services/xes_exporter.py`
  - XES structure generation, empty event list, malformed event data, and serialization failure.
- `app/services/repositories/activity_log_repository.py`
  - CRUD operations with mocked DB sessions, empty query results, and repository-level exceptions.

### 7. Blackbox / E2E Infrastructure (Prerequisite)
- Fix `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py` import issue caused by `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/main.py`.
- Ensure `pytest tests/test_blackbox/ -q` runs successfully and that those blackbox tests are included in `pytest tests/test_unit tests/test_integration tests/test_blackbox --cov=app --cov-branch --cov-report=term-missing -q`.
- Decision rule: restore blackbox importability within this change using the smallest testability-only diff needed in `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/main.py`, and do not mark this OpenSpec complete until blackbox coverage is included in the final gate.

## Test Design Principles
- Prefer fast unit tests with mocks for external I/O (OpenAI, Qdrant, Mongo, Redis, vision).
- Use real logic for pure/composed functions (analytics calculations, caption logic, policy decisions).
- Parameterize tests for multiple scenarios (different log sequences, image types, error types).
- Maintain existing test organization by placing tests in explicit files such as `tests/test_unit/test_document_processing_image_extraction.py`, `tests/test_unit/test_document_processor_full.py`, `tests/test_unit/test_plan_vs_reality.py`, `tests/test_unit/test_api_dependencies.py`, `tests/test_unit/test_track_activity.py`, and other explicit test files under `tests/test_unit/`, `tests/test_integration/`, or `tests/test_blackbox/` that map to the targeted source module.
- For complex stateful logic (orchestration, process mining), use table-driven tests or synthetic event logs.

## Risks & Mitigations
- Risk: Adding tests reveals latent bugs in production code. Mitigation: Apply only the minimum behavior-preserving fix required for the targeted tests in this change.
- Risk: Blackbox fixes require changes to `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/main.py` (import-time issues). Mitigation: Keep changes minimal and isolated while still resolving blackbox importability within this change.
- Risk: Over-testing optional paths when reranker is disabled. Mitigation: Focus on enabled paths plus explicit disabled-path tests.
- Risk: Time to reach 90%+ on everything. Mitigation: Prioritize by the list above and break work into phases, but do not mark this change complete until every explicitly listed target module meets the stated threshold.

## Verification (Rigorous & Measurable)
- **Per-module targets**: `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py` must each show ≥90% statement coverage and ≥90% branch coverage in the final report generated by `pytest tests/test_unit tests/test_integration tests/test_blackbox --cov=app --cov-branch --cov-report=term-missing -q`.
- **Blackbox gate**: `pytest tests/test_blackbox/ -q` must pass cleanly (no import errors), and those same blackbox tests must be included in `pytest tests/test_unit tests/test_integration tests/test_blackbox --cov=app --cov-branch --cov-report=term-missing -q`.
- **No regression**: No module explicitly named in this design may finish below 90% statement coverage or 90% branch coverage in the final report.
- **Specific coverage**: Spot-check that key target branches are now green, including vision caption paths in `app/services/document_processing/image_extraction.py`, all functions in `app/api/dependencies.py`, exception-handler branches in `app/core/error_handlers.py`, and analytics edge cases like empty logs or perfect conformance sequences.
- **Test quality**: All new tests must pass in a single `pytest tests/test_unit tests/test_integration tests/test_blackbox -q` run.
- **Documentation**: Record before/after per-module coverage deltas in `openspec/changes/improve-test-coverage/implementation-notes.md`.

This makes verification objective and auditable.

## Blackbox Infrastructure Fix (Concrete Scope)
- Primary files: `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py` and `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/main.py`.
- Goal: Make `from main import app` succeed inside `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py` without side effects or external service requirements during collection.
- Any change to `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/main.py` must be the smallest possible diff and must be justified only for testability in `/Users/hshino/Kuliah/ProjectTA/openspec/changes/improve-test-coverage/implementation-notes.md`.
- After the fix, blackbox tests must execute without the previous redis import error.

This design ensures targeted, high-value test additions without overhauling the test suite or blurring test vs production changes.
