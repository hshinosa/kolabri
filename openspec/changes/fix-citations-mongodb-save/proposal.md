## Why

AI-generated citations from RAG (Retrieval-Augmented Generation) are being created successfully by the AI engine but are not being persisted to MongoDB, breaking the structured citation display UI. Investigation revealed citations exist at the AI engine layer (proven with logging showing `num_citations=1`) but are missing from MongoDB ChatLog documents (proven with direct query). This prevents students from seeing clickable source references when AI uses course materials to answer questions.

## What Changes

- Diagnose exact failure point in core-api socket handler where citations are lost between receiving HTTP response from AI engine and saving to MongoDB
- Fix data flow issue causing `filteredCitations` variable to be empty despite AI engine returning citations
- Verify citations properly serialize from AI engine FastAPI response through core-api TypeScript deserialization to MongoDB document
- Ensure comprehensive logging (already deployed) captures citation counts at critical points for root cause identification

## Capabilities

### New Capabilities

_None - this is a bug fix for existing functionality_

### Modified Capabilities

- `ai-citation-chips`: Fix broken citation persistence layer. Citations are currently created by RAG but not saved to MongoDB, preventing UI from displaying source references. The capability exists and UI is implemented, but data flow is broken in the save path.

## Impact

**Affected Components**:
- Core-API socket handler (`Kolabri-core-api/src/socket/index.ts` lines 1327-1400)
- Core-API AI Engine service client (`Kolabri-core-api/src/services/aiEngine.service.ts`)
- MongoDB ChatLog model/schema (`Kolabri-core-api/src/models/ChatLog.js`)
- TypeScript type definitions for `OrchestrationResponse` in core-api

**No Breaking Changes**: This is a bug fix that restores intended functionality. AI text responses already mention source materials, so user experience is degraded but not broken.

**Dependencies**:
- Diagnostic logging already deployed to production (06:13:08 rebuild)
- Requires one test execution to capture logs and identify exact failure point
- Fix expected to be surgical (single-line to few-line change once diagnosed)

**Evidence Base**: 2+ hour production investigation session with comprehensive logging at AI engine (RAG + orchestration) and core-api layers, direct MongoDB inspection, HTTP response schema verification.
