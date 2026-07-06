# Proposal: Improve Test Coverage for Low-Coverage Modules

## Problem
The Kolabri AI Engine currently has uneven test coverage. While many API routes and core components reach 98-100% coverage after recent cleanups, several critical modules remain significantly under-tested (below 95%, with some at 0-76%).

**Explicit target modules** (all must reach ≥90% statement + branch coverage; this list is exhaustive for this change):

**API Layer**
- `app/api/dependencies.py` (0%)
- `app/api/routes/track_activity.py` (50%)
- `app/api/routes/health.py` (89.71%)
- `app/api/batch_routes.py`
- `app/api/routes/documents.py`
- `app/api/routes/chat.py`
- `app/api/routes/analytics.py`
- `app/api/schemas.py`

**Core Infrastructure**
- `app/core/error_handlers.py` (81.48%)
- `app/core/redis_cache.py` (97.52%)
- `app/core/cache_analyzer.py`
- `app/core/circuit_breaker.py`
- `app/core/guardrails.py`

**Document Processing (highest priority)**
- `app/services/document_processing/image_extraction.py` (76.30% — largest gap, vision/OCR/caption paths)
- `app/services/document_processor.py` (vision/OCR initialization and `_generate_image_caption` delegation branches)
- `app/services/document_processing/text_extraction.py`
- `app/services/document_processing/chunking.py`

**Advanced Analytics (thesis-critical)**
- `app/services/plan_vs_reality.py`
- `app/services/conformance_checker.py`
- `app/services/process_mining_anomaly.py`
- `app/services/srl_classifier.py`
- `app/services/goal_validator.py` (95.77%)
- `app/services/nlp_analytics.py`

**RAG, Orchestration & Guardrails**
- `app/services/rag.py`
- `app/services/grounding_verifier.py`
- `app/services/reranker.py`
- `app/services/rag_benchmark_runner.py`
- `app/services/rag_benchmark_bootstrap.py`
- `app/services/orchestration.py`
- `app/services/logic_listener.py`
- `app/services/intervention.py`
- `app/services/socratic_filter.py`
- `app/services/toxicity_scorer.py`
- `app/services/pii_detector.py`
- `app/services/injection_detector.py`

**Data & Export Layer**
- `app/services/mongodb_logger.py` (91.67%)
- `app/services/vector_store.py`
- `app/services/export_service.py`
- `app/services/xes_exporter.py`
- `app/services/repositories/activity_log_repository.py`

**Other Services**
- `app/services/llm.py` (96.06%)
- `app/services/efficiency_guard.py`
- `app/services/batch_llm.py`

**Infrastructure Fixes (prerequisite)**
- Blackbox/E2E test infrastructure (`tests/test_blackbox/`) — currently broken due to import issues.

This list is the complete set of modules that must be addressed. No modules from the coverage gaps are omitted or left as family placeholders like "integration", "and others", or grouped wildcards.

Low coverage in these areas risks undetected bugs in:
- Document ingestion & multimodal processing (core for knowledge base)
- Analytics & intervention logic (central to the educational AI thesis)
- RAG quality, caching, error handling, and resilience
- Database logging and export (XES for process mining)

Blackbox tests are currently non-functional because `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py` fails during import, preventing E2E coverage measurement.

## Impact
- Reduced confidence in production behavior for critical paths.
- Difficulty maintaining and evolving features like advanced analytics and RAG.
- Potential gaps in security/resilience (error handlers, guardrails, circuit breakers).
- Inconsistent with academic requirements for thorough validation of the implemented methods (process mining, SRL, goal setting, etc.).

## Proposed Solution
Create a comprehensive test improvement initiative:
- Add/fix unit tests targeting missing statements and branches for all listed low-coverage modules.
- Add integration tests for DB/LLM interactions, RAG flows, and analytics pipelines.
- Fix blackbox test infrastructure so E2E coverage can be measured and improved.
- Prioritize by risk/impact: document processing + analytics first, then core services, then infrastructure.
- Aim for minimum 90% coverage (statements + branches) on all modules in the explicit target list.
- Update `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/.github/workflows/ci.yml` to enforce minimum thresholds of 90% statement coverage and 90% branch coverage for `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py`.
- Document test strategies for complex areas, including process mining alignment and vision captioning.

This change will not alter production behavior—only add tests and fix test infrastructure.

## Scope
**In scope (test-only changes):**
- Adding new unit and integration tests for every module in the explicit target list.
- Fixing blackbox test infrastructure by updating `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/tests/test_blackbox/conftest.py` and making only the minimum testability-only adjustments in `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/main.py` strictly required to make blackbox tests importable and runnable, with no functional changes to production logic.
- Minor test helpers, fixtures, or mocks needed to exercise the explicit branches and edge cases named in this change.
- Updating `/Users/hshino/Kuliah/ProjectTA/Kolabri-ai-engine/.github/workflows/ci.yml` to enforce minimum thresholds of 90% statement coverage and 90% branch coverage for `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py`.

**Explicitly out of scope for production code changes:**
- Any modifications to production behavior, algorithms, or APIs unless they are the absolute minimum required for testability, such as making an import lazy solely to allow blackbox collection. Such changes must be documented and kept to the smallest possible diff.
- Bug fixes discovered during testing must be fixed within this change only when they are the minimum change required to make the targeted tests pass and preserve existing behavior; broader behavioral changes are out of scope.

This keeps the change strictly focused on test addition and infrastructure fixes.

## Non-Goals
- Achieving 100% coverage (diminishing returns on some optional paths like reranker when disabled).
- Rewriting existing high-coverage tests.
- Adding performance/load tests (separate concern).
- Changing the overall test framework or adding new tools.

## Success Criteria
- The modules `app/api/dependencies.py`, `app/api/routes/track_activity.py`, `app/api/routes/health.py`, `app/api/batch_routes.py`, `app/api/routes/documents.py`, `app/api/routes/chat.py`, `app/api/routes/analytics.py`, `app/api/schemas.py`, `app/core/error_handlers.py`, `app/core/redis_cache.py`, `app/core/cache_analyzer.py`, `app/core/circuit_breaker.py`, `app/core/guardrails.py`, `app/services/document_processing/image_extraction.py`, `app/services/document_processor.py`, `app/services/document_processing/text_extraction.py`, `app/services/document_processing/chunking.py`, `app/services/plan_vs_reality.py`, `app/services/conformance_checker.py`, `app/services/process_mining_anomaly.py`, `app/services/srl_classifier.py`, `app/services/goal_validator.py`, `app/services/nlp_analytics.py`, `app/services/rag.py`, `app/services/grounding_verifier.py`, `app/services/reranker.py`, `app/services/rag_benchmark_runner.py`, `app/services/rag_benchmark_bootstrap.py`, `app/services/orchestration.py`, `app/services/logic_listener.py`, `app/services/intervention.py`, `app/services/socratic_filter.py`, `app/services/toxicity_scorer.py`, `app/services/pii_detector.py`, `app/services/injection_detector.py`, `app/services/mongodb_logger.py`, `app/services/vector_store.py`, `app/services/export_service.py`, `app/services/xes_exporter.py`, `app/services/repositories/activity_log_repository.py`, `app/services/llm.py`, `app/services/efficiency_guard.py`, and `app/services/batch_llm.py` each reach ≥90% statement coverage and ≥90% branch coverage when measured with `pytest tests/test_unit tests/test_integration tests/test_blackbox --cov=app --cov-branch --cov-report=term-missing -q`.
- Blackbox tests run successfully with `pytest tests/test_blackbox/ -q`, and those same blackbox tests are included in `pytest tests/test_unit tests/test_integration tests/test_blackbox --cov=app --cov-branch --cov-report=term-missing -q`.
- New tests follow existing project patterns (heavy mocking for external services like LLM/DB/vision, real logic for pure functions, table-driven/parameterized tests for edge cases).
- No module listed in this change may drop below 90% statement coverage or 90% branch coverage after the final verification run.
- Specific target branches are exercised, including: vision caption paths in `app/services/document_processing/image_extraction.py`, every dependency-provider function in `app/api/dependencies.py`, explicit exception-handler branches in `app/core/error_handlers.py`, and analytics edge cases like empty logs or perfect conformance.
- A before/after coverage delta summary (per module) is included in `openspec/changes/improve-test-coverage/implementation-notes.md`.
- All new tests pass cleanly together with the existing test suite.

## Out of Scope for This Change
- Full E2E user scenarios beyond blackbox fixes.
- Coverage for code outside the explicitly listed modules in this change.
- Dependency on external services in CI (use mocks).

This proposal addresses the "improve test coverage" need identified during post-cleanup analysis.
