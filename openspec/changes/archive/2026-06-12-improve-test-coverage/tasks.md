# Tasks: Improve Test Coverage for Low-Coverage Modules

Mulai setelah **P0 gate** (`docs/p0-release-gate.md`).

## Prerequisites (Must be completed first)
- [x] Fix blackbox test infrastructure:
  - Primary files: `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py` and `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/main.py`.
  - Allowed edits in `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py`: only the `from main import app` import path usage and fixture definitions in that same file.
  - Allowed edits in `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/main.py`: only the smallest testability-only changes needed so pytest collection of `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py` does not trigger the `redis.exceptions` import failure or any top-level network initialization.
  - Goal: `pytest tests/test_blackbox/ -q` must run without the previous `No module named 'redis.exceptions'` import-time error and without any new import-time exception during collection of `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py`.

## Phase 1: Document Processing & Ingestion (Highest Impact)
- [x] Add comprehensive tests for `generate_image_caption` (OpenAI-compatible vision_client path) in `tests/test_unit/test_document_processing_image_extraction.py`:
  - Success case with valid caption.
  - Empty response from vision client.
  - API error / exception handling.
  - RGBA to RGB conversion.
  - RGB image (no conversion needed).
  - Invalid/small images.
- [x] Cover `app/services/document_processing/image_extraction.py` OCR + image extraction branches for PDF/DOCX/PPTX, including small-image rejection, empty OCR result, and caption callback branches.
- [x] Add/update tests in `tests/test_unit/test_document_processor_full.py` for vision/OCR initialization branches (OpenAI path only) and `_generate_image_caption` delegation.
- [x] Verify `app/services/document_processing/text_extraction.py` covers OCR fallback and caption-callback branches, and `app/services/document_processing/chunking.py` covers chunk split/overlap branches.

## Phase 2: Advanced Analytics (Critical for Project Validation)
- [x] Expand tests for `app/services/plan_vs_reality.py` (target: cover topic coverage, deviation scoring, recommendation logic, and edge cases for empty logs, perfect matches, absent goals, and malformed activity entries):
  - Topic coverage calculation with partial/full/no overlap.
  - Plan vs actual comparison with various deviations (missing topics, time overruns).
  - Recommendation generation for different gap types.
  - Edge cases: empty logs, perfect match, no declared goals, malformed activity entries.
  - Test file: `tests/test_unit/test_plan_vs_reality.py` (expand existing or add new cases).
- [x] Expand `app/services/conformance_checker.py` and `app/services/process_mining_anomaly.py`:
  - Alignment score and token replay for perfect sequences vs deviant ones (missing steps, out-of-order, extra activities).
  - Anomaly detection for silence (>15min), participation inequality (Gini >0.6), low HOT quality.
  - XES log parsing and normative path comparison.
  - Use synthetic but realistic activity logs.
- [x] Expand `app/services/srl_classifier.py` and `app/services/goal_validator.py`:
  - SRL phase classification (Forethought/Performance/Reflection) on varied message sequences.
  - SMART goal validation (Bloom verbs, measurable metrics, time bounds, invalid cases).
  - Edge cases and invalid inputs (empty, contradictory, non-operational verbs).
- [x] Add tests for `app/services/nlp_analytics.py` rule-based indicators (HOT detection with 100+ patterns, engagement classification branches, lexical variation/TTR branches, and threshold-based output branches).

## Phase 3: API Layer & Routes
- [x] Add full test coverage for `app/api/dependencies.py`:
  - Target file: `tests/test_unit/test_api_dependencies.py`.
  - Cover all dependency providers (`get_db`, auth/current-user helpers, and failure paths).
- [x] Cover `app/api/routes/track_activity.py` success and error paths:
  - Target file: `tests/test_unit/test_track_activity.py`.
  - Cover success logging, invalid payload, and repository/logger exception path.
- [x] Cover `app/api/routes/health.py` branches for healthy, degraded, and dependency-failure statuses:
  - Healthy status, degraded dependency status, failing dependency branch, and conditional response fields.
- [x] Cover `app/api/batch_routes.py` branches for partial batch failure, retrieval-size mismatch, and alternate response formatting:
  - Partial batch failure, retrieval-size mismatch, and alternate response formatting branches.
- [x] Cover `app/api/routes/documents.py` branches for unsupported file type, validation error, and storage failure:
  - Unsupported file type, validation error, and storage failure path.
- [x] Cover `app/api/routes/chat.py` branches for guarded-response short-circuit and fallback response:
  - Guarded-response short-circuit and fallback response branch.
- [x] Cover `app/api/routes/analytics.py` branches for alternate pagination/filter behavior and `app/api/schemas.py` validator/default branches:
  - Alternate pagination/filter branches and validator/default paths.

## Phase 4: Core Infrastructure
- [x] Add tests for all exception paths in `app/core/error_handlers.py`:
  - Validation error formatting, HTTP exception handling, unexpected exception fallback, and logging branch.
- [x] Cover `app/core/redis_cache.py` get/set/delete, TTL, and connection-failure branches:
  - get/set/delete misses, TTL branch, and redis connection failure path.
- [x] Cover `app/core/cache_analyzer.py` recommendation and analyzer-summary branches:
  - Recommendation branch and analyzer-summary edge cases.
- [x] Cover `app/core/circuit_breaker.py` half-open transition, exit, and recovery branches:
  - Half-open transition, exit branches, and recovery path.
- [x] Cover `app/core/guardrails.py` late decision and fallback branches:
  - Late decision/fallback branches.

## Phase 5: Services & Orchestration
- [x] Expand `app/services/llm.py` tests:
  - Retry logic, timeout handling, error classification, and circuit-breaker integration.
- [x] Cover connection and logging paths in `app/services/mongodb_logger.py`:
  - connect/disconnect, failed insert, malformed payload, and uncovered end-of-file branches.
- [x] Add tests for `app/services/logic_listener.py`:
  - silence detection, off-topic detection, participation inequity thresholds, and fallback outputs.
- [x] Expand `app/services/intervention.py`:
  - intervention type selection, confidence thresholds, prompt assembly branches.
- [x] Expand `app/services/orchestration.py`:
  - cooldowns, state transitions, and teacher-notification gating.
- [x] Improve coverage for `app/services/rag.py`:
  - FETCH/NO_FETCH policy decisions, semantic-cache hit/miss, retrieval/no-retrieval, and grounding fail/pass.
- [x] Add targeted tests for `app/services/grounding_verifier.py`:
  - support threshold, mismatch threshold, and low-confidence branch.
- [x] Add targeted tests for `app/services/reranker.py`:
  - enabled path, disabled path when fastembed unavailable, empty input, and truncation logic.
- [x] Add targeted tests for `app/services/rag_benchmark_runner.py` and `app/services/rag_benchmark_bootstrap.py`:
  - empty dataset, disabled benchmark branch, and result aggregation path.
- [x] Add real pattern tests for `app/services/toxicity_scorer.py`, `app/services/socratic_filter.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`.
- [x] Cover `app/services/efficiency_guard.py`, `app/services/goal_validator.py`, and `app/services/batch_llm.py` with explicit edge cases (thresholds, evidence scoring, partial batch failure).

## Phase 6: Data & Export Layer
- [x] Add tests for `app/services/vector_store.py`:
  - initialization success/failure, collection creation, upsert/query/delete, and client error branches.
- [x] Cover `app/services/export_service.py`:
  - CSV export formatting, empty dataset branch, and write failure.
- [x] Cover `app/services/xes_exporter.py`:
  - empty event list, malformed event data, successful serialization, and serialization failure.
- [x] Cover `app/services/repositories/activity_log_repository.py`:
  - CRUD with mocked DB sessions, empty query results, and repository exceptions.

## Phase 7: Verification & Cleanup
- [x] Re-run full coverage report and confirm `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py` each reach at least 90% statement coverage and 90% branch coverage.
- [x] Update `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/.github/workflows/ci.yml` to enforce minimum thresholds of 90% statement coverage and 90% branch coverage for `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py`.
- [x] Document test strategy additions and before/after per-module coverage deltas in `openspec/changes/improve-test-coverage/implementation-notes.md`.
- [x] Ensure no listed module drops below 90% statement coverage or 90% branch coverage in the final verification run.
- [x] Run full test suite (unit + integration + blackbox) and confirm all pass.

## Verification (Mandatory Gates)
- After all test work: Run `pytest tests/test_unit tests/test_integration tests/test_blackbox --cov=app --cov-branch --cov-report=term-missing -q` and confirm `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py` are each ≥90% statement coverage and ≥90% branch coverage.
- Run `pytest tests/test_blackbox/ -q` and confirm it passes cleanly (no import errors).
- Confirm `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py` all finish at or above 90% statement coverage and 90% branch coverage.
- Spot-check specific gaps: At least the following must now be exercised:
  - `app/services/document_processing/image_extraction.py` vision-caption branches
  - All functions in `app/api/dependencies.py`
  - `app/core/error_handlers.py` exception-handler branches
  - `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, and `app/services/process_mining_anomaly.py` analytics edge cases for empty logs, perfect conformance, and anomaly types
- Full suite green: `pytest tests/test_unit tests/test_integration tests/test_blackbox -q` must pass with no failures.

## Acceptance Criteria
- Coverage report shows `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py` at or above 90% statement coverage and 90% branch coverage.
- Blackbox tests are green and included in the same `--cov=app --cov-branch` coverage measurement.
- New tests are maintainable and follow project conventions.
- Key educational AI features (analytics, RAG, document processing with OpenAI-compatible vision) have explicit branch coverage for their core logic.
- Verification gates above are all satisfied and documented.

## Estimated Scope
This is a medium-to-large testing effort. Prioritize Phases 1-2 first (document processing + analytics), then execute Phases 3-7 in order until every explicit target module meets the acceptance gate. Individual tasks can be broken into smaller PRs if needed.

## Dependencies
- Completion of Gemini vision removal (already done).
- Working test environment with installed dependencies required by the targeted tests; when a dependency such as `fastembed` is unavailable, cover the explicit disabled-path behavior instead of adding new environment requirements.

Start with blackbox fixes and Phase 1 for maximum early impact.
