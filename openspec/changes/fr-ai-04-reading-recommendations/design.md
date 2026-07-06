## Context

Kolabri already stores course knowledge sources and uses RAG-style retrieval for AI answers, but it stops at direct question answering. Interview evidence from Pak Ive indicates a need for AI to guide students toward relevant readings, especially as part of learning support rather than one-shot answers. This change spans AI retrieval logic, API orchestration, validation, and student-facing presentation.

## Goals / Non-Goals

**Goals:**
- Generate structured reading recommendations from course-approved knowledge sources.
- Explain why each source is recommended and what the student should read next.
- Reuse the existing course knowledge base and avoid introducing untrusted external sources by default.
- Provide graceful fallback when no relevant material is available.

**Non-Goals:**
- Internet-wide recommendation search.
- Full adaptive scaffolding by semester level.
- Automated syllabus generation or complete learning path authoring.

## Decisions

### Use existing course knowledge base as the recommendation corpus
Recommendations will be sourced only from materials already uploaded to the course knowledge base unless future policy expands the source set. This keeps recommendations aligned with lecturer-approved material.

**Alternatives considered:**
- External web search: rejected due to trust, moderation, and source consistency concerns.
- Manual lecturer-curated recommendation lists only: rejected because it adds extra authoring burden and misses AI retrieval value.

### Return structured recommendation items, not free-form prose only
The API should return a list of recommendation objects containing source title, snippet or section reference, recommendation rationale, and suggested action. This supports clean UI rendering and downstream analytics.

**Alternatives considered:**
- Plain text paragraph output only: rejected because it is harder to present consistently and harder to test.

### Treat recommendation generation as a separate intent from normal Q&A
Recommendation requests should be explicitly invoked by UI or agent orchestration, even if they reuse the same retrieval stack. This avoids overloading normal answer flows and allows clearer fallback behavior.

**Alternatives considered:**
- Inject recommendations into every AI answer automatically: rejected because it may add noise and degrade focus.

## Risks / Trade-offs

- **Knowledge base quality may be uneven** → Use relevance thresholding and no-result fallback instead of low-confidence recommendations.
- **Recommendations may repeat the same source too often** → Add diversity heuristics at ranking stage.
- **Students may treat recommendations as final answers** → Include rationale/action wording that emphasizes further reading, not answer substitution.

## Migration Plan

1. Add recommendation request/response contract.
2. Implement retrieval and ranking pipeline using existing course knowledge source metadata.
3. Add API endpoint and UI trigger/presentation.
4. Test with courses that have rich and sparse knowledge bases.

Rollback: disable the endpoint/UI while preserving the underlying knowledge base and retrieval infrastructure.

## Open Questions

- Which UI entry points should trigger recommendations first: AI chat, course page, group discussion, or all three?
- Should recommendations point to file-level items only, or also to page/section-level anchors when available?
