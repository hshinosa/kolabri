# Kolabri Architecture Audit Report

**Date**: 2026-06-28  
**Scope**: Service boundary violations between `Kolabri-core-api` and `Kolabri-ai-engine`  
**Auditor**: Sisyphus

## Executive Summary

This audit identifies logic that lives in `Kolabri-core-api` but should live in `Kolabri-ai-engine` based on separation of concerns. The core finding: **Core-API contains direct LLM provider adapters and SDK imports**, violating the architectural principle that core-api should orchestrate while ai-engine handles all AI/ML work.

**Verdict**: Minor violation with **isolated impact**. The problematic code is used only for admin provider testing, not production AI features. Most production services correctly delegate to ai-engine.

## Architecture Principles

The intended architecture separates concerns cleanly:

| Service | Responsibility |
|---|---|
| **Core-API** | Orchestration, business logic, data persistence, HTTP routing, authentication |
| **AI-Engine** | All AI/ML work - LLM calls, prompt construction, RAG, guardrails, scoring, classification |

**Golden Rule**: Core-API should never import LLM SDKs or make direct API calls to OpenAI/Anthropic/etc. It should delegate all AI work to ai-engine via HTTP.

## Violations Found

### 1. Direct LLM Adapters in Core-API

**Location**: `Kolabri-core-api/src/services/ai-providers/`

**Files**:
- `openai-adapter.ts` - Imports `openai` SDK, makes direct GPT API calls
- `anthropic-adapter.ts` - Imports `@anthropic-ai/sdk`, makes direct Claude API calls
- `gemini-adapter.ts` - Makes direct Gemini API calls
- `base-adapter.ts` - Base class for adapters

**Evidence** (`openai-adapter.ts` lines 1-28):
```typescript
import OpenAI from 'openai';

export class OpenAIAdapter extends BaseAIProviderAdapter {
    async sendMessage(prompt: string, config: AIProviderSendConfig): Promise<AIProviderResponse> {
        const client = new OpenAI({
            apiKey: this.apiKey,
            baseURL: config.baseUrl || undefined,
        });

        const completion = await client.chat.completions.create({
            model: config.model,
            temperature: config.temperature,
            max_tokens: config.maxTokens,
            messages: [
                ...(config.systemPrompt ? [{ role: 'system' as const, content: config.systemPrompt }] : []),
                ...((config.history ?? []).map((item) => ({ role: item.role, content: item.content }))),
                { role: 'user', content: prompt },
            ],
        });

        return {
            content: completion.choices[0]?.message?.content ?? '',
            promptTokens: completion.usage?.prompt_tokens ?? 0,
            completionTokens: completion.usage?.completion_tokens ?? 0,
            totalTokens: completion.usage?.total_tokens ?? 0,
            model: completion.model,
            latencyMs: Date.now() - startedAt,
        };
    }
}
```

**Impact**: Core-API directly instantiates LLM clients and constructs API requests. This is AI logic that belongs in ai-engine.

### 2. AIService Orchestrator

**Location**: `Kolabri-core-api/src/services/ai.service.ts`

**Size**: 294 lines

**Role**: 
- Imports and instantiates LLM adapters
- Provides `send()` method that routes to correct provider
- Handles fallback, retry logic, usage tracking
- Contains token pricing logic

**Evidence** (lines 1-10):
```typescript
import { AnthropicAdapter } from './ai-providers/anthropic-adapter.js';
import type { AIProviderAdapter, AIProviderResponse } from './ai-providers/base-adapter.js';
import { GeminiAdapter } from './ai-providers/gemini-adapter.js';
import { OpenAIAdapter } from './ai-providers/openai-adapter.js';
import { usageTrackingService, type AiUsageData, type UsageTrackingService } from './usage-tracking.service.js';
```

**Impact**: Core-API has a complete LLM provider abstraction layer. This duplicates responsibility that ai-engine already handles.

### 3. Usage Scope

**Who uses AIService?**

Only **1 service** uses it:
- `ai-provider.service.ts` line 274: `aiService.send(input.testPrompt || 'Hello', provider.name, {...})`

**Purpose**: Admin provider connection testing. When admins configure a new AI provider, they can test if the API key works by sending a test prompt.

**Who DOESN'T use it?**

**11 production services** correctly use `aiEngineService` (delegation to ai-engine):
1. `socket/index.ts`
2. `socket/interventions.ts`
3. `goal.service.ts`
4. `courseMaterialKb.service.ts`
5. `aiChat.service.ts`
6. `knowledgeBase.service.ts`
7. `analytics.service.ts`
8. `readingRecommendation.service.ts`
9. `sessionDiscussion.service.ts`
10. `discussion-direction.service.ts`
11. `aiChat.controller.ts`

## Correct Architecture Examples

### Example 1: discussion-direction.service.ts (CORRECT)

```typescript
import { aiEngineCircuitBreaker } from '../utils/circuitBreaker.js';
import { providerResolutionService } from './providerResolution.service.js';

static async classifyMessages(
    messages: Array<{ id: string; content: string }>,
    goal: string
): Promise<Array<{ messageId: string; isRelevant: boolean }>> {
    return await providerResolutionService.executeWithFallback(
        { featureFamily: 'orchestration' },
        async (providerContext) => {
            const aiEngineUrl = process.env.AI_ENGINE_URL || 'http://localhost:8001';
            const response = await fetch(`${aiEngineUrl}/api/classify-relevance`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ messages, goal, provider_context: providerContext }),
            });
            return await response.json();
        },
    );
}
```

**Why this is correct**:
- No LLM SDK imports
- Calls ai-engine HTTP endpoint
- Core-API orchestrates, ai-engine does AI work

### Example 2: readingRecommendation.service.ts (CORRECT)

```typescript
import { aiEngineService } from './aiEngine.service.js';
import { providerResolutionService } from './providerResolution.service.js';

const engineResult = await providerResolutionService.executeWithFallback(
    { featureFamily: 'reading-recommendations' },
    (providerContext) => aiEngineService.generateReadingRecommendations(
        input.topic,
        courseId,
        input.limit ?? 3,
        providerContext,
    ),
    {
        isSuccess: (response) => response.success,
        perProviderTimeoutMs: 30000,
    },
);
```

**Why this is correct**:
- Uses `aiEngineService` delegation layer
- No direct AI logic
- Clean separation of concerns

## Architecture Comparison

| Component | Current Location | Should Be In | Status |
|---|---|---|---|
| `openai-adapter.ts` | Core-API | AI-Engine | ❌ Violation |
| `anthropic-adapter.ts` | Core-API | AI-Engine | ❌ Violation |
| `gemini-adapter.ts` | Core-API | AI-Engine | ❌ Violation |
| `ai.service.ts` | Core-API | AI-Engine | ❌ Violation |
| `aiEngine.service.ts` | Core-API | Core-API | ✅ Correct (delegation layer) |
| Provider testing logic | Core-API | AI-Engine or Core-API | ⚠️ Debatable |

## Impact Analysis

### Severity: **LOW**

**Why low severity?**
1. **Isolated usage**: Only used for admin provider testing, not production AI features
2. **Correct pattern dominance**: 11 production services use correct delegation
3. **No functional bug**: System works as intended
4. **No user impact**: Admin feature only

### Risks:

1. **Maintenance burden**: LLM provider changes require updates in 2 places (core-api AND ai-engine)
2. **Consistency risk**: Provider logic could drift between services
3. **Onboarding confusion**: New developers see conflicting patterns
4. **Architectural debt**: Violates stated separation of concerns

### Why it exists:

**Hypothesis**: Admin provider testing needs to work even if ai-engine is down or misconfigured. Direct LLM access in core-api provides this independence.

**Alternative**: Make provider testing delegate to ai-engine, accept that ai-engine must be healthy to test providers.

## Recommendations

### Option A: Move to AI-Engine (Ideal)

**Action**:
1. Create `/admin/test-provider` endpoint in ai-engine
2. Move adapters from core-api to ai-engine
3. Update `ai-provider.service.ts` to call ai-engine endpoint
4. Delete `ai.service.ts` and `ai-providers/` from core-api

**Pros**:
- Clean architecture
- Single source of truth for LLM logic
- Easier maintenance

**Cons**:
- AI-engine must be running to test providers
- Slight added complexity for admin testing

**Effort**: Medium (4-6 hours)

### Option B: Accept as Technical Debt (Pragmatic)

**Action**:
1. Document this exception in architecture docs
2. Add comment in `ai.service.ts`: "Only for admin provider testing. Production AI features use aiEngineService."
3. Monitor to ensure pattern doesn't spread

**Pros**:
- No refactor needed
- Admin testing remains independent
- Low effort

**Cons**:
- Architectural violation persists
- Maintenance burden remains

**Effort**: Low (1 hour for docs)

### Option C: Hybrid Approach

**Action**:
1. Keep minimal test adapter in core-api
2. Move production provider logic fully to ai-engine
3. Clearly separate "admin tooling" from "production AI"

**Effort**: Low-Medium (2-3 hours)

## Conclusion

Kolabri's architecture is **mostly correct**. The violation found is narrow and isolated:

- ✅ **11 production services** correctly delegate to ai-engine
- ❌ **1 admin service** uses direct LLM adapters
- ✅ **Separation of concerns** generally respected

The violation exists for **admin provider testing** only. This is technical debt, not a critical flaw.

**Recommended action**: **Option B** (document as exception) for thesis defense timeline. **Option A** (refactor) for post-release cleanup.

## Appendix: File Analysis

### Core-API Files with AI Logic

| File | Lines | Purpose | Violation? |
|---|---|---|---|
| `ai.service.ts` | 294 | LLM provider orchestration | ❌ Yes |
| `ai-providers/openai-adapter.ts` | 44 | OpenAI SDK wrapper | ❌ Yes |
| `ai-providers/anthropic-adapter.ts` | ~40 | Anthropic SDK wrapper | ❌ Yes |
| `ai-providers/gemini-adapter.ts` | ~40 | Gemini SDK wrapper | ❌ Yes |
| `ai-providers/base-adapter.ts` | ~30 | Adapter interface | ❌ Yes |
| `aiEngine.service.ts` | 1083 | HTTP client for ai-engine | ✅ Correct |
| `ai-provider.service.ts` | 396 | Admin provider CRUD + testing | ⚠️ Mixed |

### Core-API Files with CORRECT Delegation

All these files properly delegate AI work to ai-engine:

1. `socket/interventions.ts` - Intervention logic
2. `goal.service.ts` - Goal validation
3. `aiChat.service.ts` - Chat orchestration
4. `knowledgeBase.service.ts` - RAG ingestion
5. `courseMaterialKb.service.ts` - Material processing
6. `readingRecommendation.service.ts` - Recommendation generation
7. `discussion-direction.service.ts` - Message classification
8. `sessionDiscussion.service.ts` - Discussion summaries
9. `analytics.service.ts` - Analytics insights

These services import `aiEngineService`, not `AIService`.

## Evidence Summary

**Architectural Violation**: Present but isolated  
**Scope**: Admin provider testing only  
**Production Impact**: None  
**Maintenance Risk**: Low-Medium  
**Recommended Fix**: Document as exception, refactor post-release  
**Overall Architecture Health**: Good (91% correct delegation)
