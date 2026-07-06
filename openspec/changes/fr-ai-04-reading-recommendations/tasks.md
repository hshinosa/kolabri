## 1. Recommendation Contract and Retrieval

- [x] 1.1 Define validated request and response contracts for reading recommendation generation
- [x] 1.2 Implement ranking and selection logic that reuses the existing course knowledge base retrieval pipeline
- [x] 1.3 Add no-result fallback behavior for sparse or irrelevant course materials

## 2. API and UI Integration

- [x] 2.1 Add core API orchestration endpoint for reading recommendations
- [x] 2.2 Surface recommendations in the selected student-facing entry point with source attribution and rationale

## 3. Verification

- [x] 3.1 Add tests for valid recommendations, invalid requests, and no-result fallback behavior
- [x] 3.2 Validate that recommendations only reference approved materials from the active course
