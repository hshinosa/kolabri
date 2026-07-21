# KOLABRI AI ENGINE - COMPREHENSIVE SYSTEM INVENTORY

## PROJECT METADATA
- **Service**: Kolabri AI Engine
- **Language**: Python 3.10+
- **Framework**: FastAPI
- **Port**: 8001
- **Architecture**: Microservice (RAG + Analytics + Interventions + Guardrails)
- **Primary Dependencies**: FastAPI, Pydantic, OpenAI SDK, Qdrant, MongoDB, Redis
- **Deployment**: Docker + Docker Compose

---

## SECTION 1: API ROUTES BY DOMAIN

### 1.1 HEALTH & MONITORING ENDPOINTS
**File**: `app/api/routes/health.py`
- `GET /health` - System health check
  - Checks: vector_store, llm, mongo, redis, circuit_breaker
  - Response: HealthResponse with status for each service

**File**: `app/api/routes/monitoring.py`
- `GET /metrics` - Prometheus metrics export
- `GET /health/monitoring` - Detailed monitoring info
- `GET /health/circuit-breakers` - Circuit breaker states for all services
- `GET /health/reranker` - Reranker service status

### 1.2 DOCUMENT INGESTION & MANAGEMENT
**File**: `app/api/routes/documents.py`
- `POST /ingest` - Single document upload
  - Accepts: PDF, DOCX, PPTX, images (JPG, PNG)
  - Processing: Chunking, embedding, vector store insertion
  - Response: DocumentProcessResult with doc_id, chunks_created

- `POST /ingest/batch` - Batch document upload
  - Input: List of files
  - Response: BatchUploadResponse with status per document

- `DELETE /documents/{id}` - Remove document from vector store
  - Cascades deletion across Qdrant collections
  - Response: {"success": bool, "message": str}

### 1.3 CHAT & RAG ENDPOINTS
**File**: `app/api/routes/chat.py`
- `POST /ask` - RAG query (simple, no orchestration)
  - Input: QueryRequest (query, collection_id, top_k)
  - Output: AskResponse (answer, sources, citations)
  - Uses: RAG pipeline directly

- `POST /chat/personal` - Personal/1-to-1 chat with RAG
  - Input: PersonalChatRequest (message, user_id, course_id)
  - Output: ChatMessage response with sources
  - Context: User-specific learning context

- `POST /chat/personal/stream` - Streaming personal chat
  - Server-Sent Events (SSE) streaming
  - Real-time token streaming for responsiveness

- `POST /reading-recommendations` - Suggest materials to read
  - Input: ReadingRecommendationRequest (user_id, goal, level)
  - Output: List of recommended materials with relevance scores
  - Uses: Vector similarity + engagement analysis

### 1.4 ORCHESTRATION (FULL PIPELINE)
**File**: `app/api/routes/orchestration.py`
- `POST /chat` - Full orchestration pipeline
  - Input: OrchestrationRequest (user_id, group_id, message, topic, etc.)
  - Orchestrates: RAG → Analytics → Intervention Detection → Guardrails
  - Output: OrchestrationResponse with reply, interventions, analytics

- `POST /chat/stream` - Streaming orchestration
  - Server-Sent Events (SSE)
  - Streams: Partial reply, analytics, intervention metadata
  - Real-time pipeline execution

### 1.5 ANALYTICS & REPORTING
**File**: `app/api/routes/analytics.py`
- `GET /analytics/engagement` - Engagement analysis for a group
  - Returns: EngagementAnalysisResponse (hot_score, col_score, lexical_variety, participation)

- `GET /analytics/dashboard/group/{id}` - Group performance dashboard
  - Returns: GroupAnalyticsResponse with engagement, process mining, anomalies

- `GET /analytics/dashboard/individual/{id}` - Individual student analytics
  - Returns: StudentAnalyticsResponse (participation, goal progress, ai_usage)

- `GET /export/activity/group/{id}` - Export group activity as CSV
  - Format: Columns for user, timestamp, message_count, engagement_level

- `GET /export/activity/chat-space/{id}` - Export chat space activity
  - Format: Conversation transcript + metadata

- `GET /export/process-mining/case/{id}` - Export process mining data
  - Format: Events for process discovery algorithm
  - Response: ProcessMiningExportResponse (events, case_id, timestamp)

### 1.6 INTERVENTION MANAGEMENT
**File**: `app/api/routes/interventions.py`
- `POST /intervention/analyze` - Analyze group for intervention need
  - Input: InterventionRequest (group_id, recent_messages, topic)
  - Output: InterventionResponse (should_intervene, type, suggested_action)

- `POST /intervention/summary` - Generate intervention summary
  - Input: SummaryRequest (group_id, message_count)
  - Output: Summary text for teacher notification

- `POST /intervention/prompt` - Generate redirecting prompt
  - Input: PromptRequest (group_id, issue_type, topic)
  - Output: Suggested prompt text for group intervention

### 1.7 EFFICIENCY & PERFORMANCE
**File**: `app/api/routes/efficiency.py`
- `GET /efficiency/cache/statistics` - Cache hit/miss statistics
  - Returns: CacheStatsResponse (hits, misses, hit_rate, entries)

- `POST /efficiency/cache/clear` - Clear cache
  - Clears Redis cache for efficiency optimization

- `GET /efficiency/statistics` - System efficiency metrics
  - Returns: Query latency, token usage, processing overhead

- `GET /efficiency/rate-limit/{id}` - Check rate limit for user/group
  - Returns: RateLimitResponse (remaining_requests, reset_time)

- `GET /efficiency/high-frequency-queries` - Identify repeated queries
  - Returns: Top query patterns for caching optimization

### 1.8 GOAL VALIDATION
**File**: `app/api/routes/goals.py`
- `POST /goals/validate` - Validate SMART goal
  - Input: GoalRequest (goal_text, course_id, student_id)
  - Uses: Goal validator service with Socratic method
  - Output: GoalValidationResponse (is_valid, feedback, suggestions)

- `POST /goals/refine` - Refine goal using Socratic questions
  - Input: GoalRequest + conversation_history
  - Output: GoalRefinementResponse (refined_goal, questions, feedback)

### 1.9 GROUP MONITORING & LOGIC LISTENER
**File**: `app/api/routes/groups.py`
- `GET /groups/{id}/status` - Real-time group status
  - Returns: GroupStatusResponse (active_users, last_message, engagement_level)

- `POST /groups/{id}/track-participation` - Log participation event
  - Input: TrackActivityRequest (user_id, message_count, quality_score)
  - Updates: Logic Listener state for participation tracking

- `POST /groups/{id}/update-last-message` - Update group's last message timestamp
  - Updates: Silence detection tracking

- `POST /groups/{id}/set-topic` - Set/update group discussion topic
  - Updates: Topic for off-topic detection in Logic Listener

### 1.10 DISCUSSION DIRECTION
**File**: `app/api/routes/discussion_direction.py`
- `POST /classify-relevance` - Check if message is relevant to topic
  - Input: message, topic
  - Uses: Embedding similarity comparison
  - Output: RelevanceCheckResponse (is_relevant, confidence_score)

- `POST /session-summary` - Generate summary of discussion session
  - Input: message_list, topic
  - Output: SessionSummaryResponse (summary_text, key_points, sentiment)

### 1.11 ACTIVITY TRACKING
**File**: `app/api/routes/track_activity.py`
- `POST /track-activity` - Log user activity (general endpoint)
  - Input: Activity metadata (action, user_id, resource_id, timestamp)
  - Stores: MongoDB activity_logs collection for analytics

---

## SECTION 2: CORE SERVICES (BUSINESS LOGIC LAYER) - PART A

### 2.1 ORCHESTRATION SERVICE
**File**: `app/services/orchestration.py` (975 lines)
**Purpose**: Central coordinator implementing Teacher-AI Complementarity loop

**Key Methods**:
- `handle_message()` - Main orchestration: RAG → Analytics → Intervention → Guardrails
- `_perform_rag_generation()` - Generate RAG response with scaffolding
- `_analyze_group_dynamics()` - Run NLP analytics + engagement analysis
- `_check_intervention_needed()` - Detect intervention triggers (silence, off-topic, inequity)
- `_generate_intervention()` - Create intervention message/action
- `_log_to_mongo()` - Persist chat data to MongoDB
- `_notify_teacher()` - Trigger teacher notifications
- `_score_response_quality()` - Compute quality metrics

**State Tracking** (in-memory, per-process):
- `_last_intervention`: Dict[group_id, datetime] - intervention cooldown
- `_group_messages`: Dict[group_id, List] - recent message history
- `_group_fading_levels`: Dict[group_id, float] - participation fading
- `_group_smart_streak`: Dict[group_id, int] - engagement streak

**Data Flow**:
1. User message + context → NLP analysis
2. Policy decision: FETCH or NO_FETCH documents
3. If FETCH: Vector search + reranking
4. LLM generation with scaffolding (full/minimal/none)
5. Engagement analysis (HOT/COL scoring)
6. Intervention detection (silence, off-topic, participation)
7. Guardrail checks (toxicity, PII, injection)
8. Response returned with metadata

### 2.2 RAG PIPELINE SERVICE
**File**: `app/services/rag.py` (910 lines)
**Purpose**: Retrieval-Augmented Generation with Policy-Based optimization

**Key Methods**:
- `query()` - Main RAG query with policy decision
- `_policy_decision()` - FETCH vs NO_FETCH based on query pattern
- `_retrieve_documents()` - Vector search + reranking
- `_format_context()` - Prepare context for LLM
- `_generate_response()` - LLM generation with scaffolding
- `_ground_response()` - Verify grounding in retrieved documents

**Policy Agent Logic**:
- SKIP_PATTERNS: greetings, acknowledgments, simple queries
- MIN_QUERY_WORDS: 3 (skip retrieval if fewer)
- FETCH: Used for substantive questions, complex queries
- NO_FETCH: Used for greetings, follow-ups, efficiency

**Scaffolding Levels**:
- `full`: Detailed explanations, many examples (threshold 0.3)
- `minimal`: Concise answers, key points (threshold 0.7)
- `none`: Direct answers (threshold 1.0)
- `auto`: Dynamically selected based on engagement/fading

**Vector Store Integration**:
- Qdrant at localhost:6333
- Collections: `{course_id}-materials`, `{course_id}-shared-knowledge`
- TOP_K_RESULTS: 7, SIMILARITY_THRESHOLD: 0.35
- Reranking: jinaai/jina-reranker-v2-base-multilingual (top-7 → top-3)


### 2.3 NLP ANALYTICS SERVICE
**File**: `app/services/nlp_analytics.py` (429 lines)
**Purpose**: Real-time engagement analysis using NLP metrics

**Metrics Tracked**:
- **HOT Score** (Help Others Teaching): % of messages helping peers
  - Indicators: "kamu", "kami", "ayo", "mari", "coba"
  - Target: >= 40% for healthy discussion

- **COL Score** (Collective Orientation): % of messages showing collective concern
  - Indicators: "kita", "bersama", "tim", "kelompok"
  - Target: >= 30% for group cohesion

- **Lexical Variety**: Unique word count normalized
- **Message Diversity**: Variety in message lengths/types
- **Sentiment Analysis**: Positive/negative/neutral distribution

**Key Methods**:
- `analyze_interaction()` - Analyze single message
- `analyze_group()` - Group-level engagement analysis
- `calculate_hot_score()` - Compute HOT indicators
- `calculate_col_score()` - Compute COL indicators
- `detect_engagement_type()` - Classify: ACTIVE, PASSIVE, OFF_TOPIC, TOXIC

**Output**: EngagementAnalysis dataclass with all metrics

### 2.4 LOGIC LISTENER SERVICE
**File**: `app/services/logic_listener.py` (529 lines)
**Purpose**: Real-time monitoring for group dynamics (SSRL support)

**Monitors**:
1. **Silence Detection**
   - Tracks last message timestamp per group
   - Triggers if silent > 5 minutes (configurable)
   - InterventionType.SILENCE

2. **Off-Topic Detection**
   - Uses embedding similarity to topic
   - Similarity < THRESHOLD → off-topic
   - InterventionType.OFF_TOPIC
   - Suggested: "Mari kita kembali ke topik utama: {topic}"

3. **Participation Inequity**
   - Gini coefficient calculation on message counts
   - Detects if 1-2 students dominate
   - InterventionType.PARTICIPATION_INEQUITY
   - Suggested: "@{user}, apa pendapatmu?"

**Key Methods**:
- `check_intervention_needed()` - Returns InterventionTrigger
- `_calculate_gini_coefficient()` - Measure participation inequality
- `_is_off_topic()` - Embedding-based relevance check
- `_is_silent()` - Time-based silence check
- `update_group_state()` - Track messages per user
- `cleanup_old_state()` - Prevent memory leaks (max 1000 groups)

**State Management**:
- Per-group: user message counts, last message time, topic
- Thread-safe with asyncio.Lock()
- Auto-cleanup when exceeds MAX_STATE_SIZE

### 2.5 INTERVENTION SERVICE
**File**: `app/services/intervention.py` (412 lines)
**Purpose**: Generate context-aware interventions for teachers/groups

**Intervention Types**:
1. **Redirect** - Guide group back to topic
2. **Prompt** - Encourage participation (@user mentions)
3. **Summarize** - Recap discussion progress

**Key Methods**:
- `analyze_need()` - Determine intervention type
- `generate_redirect()` - Create redirect intervention
- `generate_prompt()` - Create prompt intervention
- `generate_summary()` - Create summary intervention
- `_get_context_aware_message()` - Personalize based on group dynamics

**Cooldown Logic**:
- min_intervention_cooldown: 5 minutes
- min_messages_before_check: 5
- Prevents intervention spam

### 2.6 GOAL VALIDATOR SERVICE
**File**: `app/services/goal_validator.py` (755 lines)
**Purpose**: SMART goal validation + Socratic refinement

**SMART Criteria**:
- **S**pecific: Clearly defined
- **M**easurable: Has measurable outcome
- **A**chievable: Realistic within course scope
- **R**elevant: Related to course learning outcomes
- **T**ime-bound: Has deadline

**Key Methods**:
- `validate()` - Check SMART criteria, return feedback
- `refine()` - Socratic questioning for goal improvement
- `_check_specificity()` - Is goal clearly defined?
- `_check_measurability()` - Can outcome be measured?
- `_check_achievability()` - Is it realistic?
- `_check_relevance()` - Relates to course?
- `_check_timebound()` - Has deadline?
- `_generate_socratic_questions()` - Ask guiding questions

**Socratic Method**:
- Asks clarifying questions instead of direct answers
- Guides student to refine their own goal
- Questions stored for conversation context

### 2.7 DOCUMENT PROCESSOR SERVICE
**File**: `app/services/document_processor.py` (921 lines)
**Purpose**: Multimodal document ingestion + chunking + embedding

**Supported Formats**:
- PDF (text + images via OCR)
- DOCX (text extraction)
- PPTX (slides as images)
- Images (JPG, PNG via OCR)

**Processing Pipeline**:
1. Format Detection
2. Text Extraction
3. OCR (if images): pytesseract
4. Chunking: ~1000 token chunks, 200 token overlap
5. Metadata Extraction
6. Embedding: OpenAI embedding-2 model
7. Vector Store Insertion

**Configuration**:
- MAX_FILE_SIZE_MB: 10
- CHUNK_SIZE: 1000 tokens
- CHUNK_OVERLAP: 200 tokens
- OCR_ENABLED: True


### 2.8 VECTOR STORE SERVICE
**File**: `app/services/vector_store.py` (307 lines)
**Purpose**: Qdrant vector database operations

**Key Methods**:
- `search()` - Similarity search, return top-k documents
- `insert()` - Add embeddings to collection
- `delete()` - Remove document/chunk from collection
- `create_collection()` - Initialize new collection
- `list_collections()` - List all collections
- `get_collection_info()` - Stats for collection

**Collection Naming**: `{course_id}-{collection_type}`
**Configuration**:
- Host: localhost, Port: 6333
- Embedding dimension: 1536 (OpenAI embedding-2)

### 2.9 RERANKER SERVICE
**File**: `app/services/reranker.py` (157 lines)
**Purpose**: Cross-encoder reranking for retrieval optimization

**Model**: jinaai/jina-reranker-v2-base-multilingual
**Workflow**: Takes top-7 vector results → returns top-3 after cross-encoder scoring

### 2.10 EFFICIENCY GUARD SERVICE
**File**: `app/services/efficiency_guard.py` (482 lines)
**Purpose**: Caching, rate limiting, performance optimization

**Features**:
1. **Query Caching**
   - Redis-backed, TTL: 24 hours
   - Cache key: hash(user_id + query + collection_id)

2. **Rate Limiting**
   - Per-user: 100 req/min, Per-group: 500 req/min
   - Using slowapi + Redis, in-memory fallback

3. **Performance Monitoring**
   - Query latency tracking
   - Token usage per user/day
   - High-frequency query identification

### 2.11 MONITORING SERVICE
**File**: `app/services/monitoring.py` (305 lines)
**Purpose**: Prometheus metrics + health checks

**Metrics**:
- Request count/latency (histogram)
- LLM token usage
- Vector store query count
- Cache hit rate
- Rate limit violations
- Circuit breaker state

### 2.12 ADDITIONAL CORE SERVICES

**LLM Service** (`app/services/llm.py` - 412 lines)
- OpenAI-compatible LLM interface (DeepSeek)
- Circuit breaker pattern for resilience
- Streaming support
- Retry logic with exponential backoff

**Embeddings Service** (`app/services/embeddings.py`)
- OpenAI embedding-2 model
- Batch embedding for efficiency
- Caching layer

**MongoDB Logger** (`app/services/mongodb_logger.py`)
- Persistent storage of chat logs
- Analytics data storage
- Collections: chat_logs, activity_logs, analytics

**Batch LLM Service** (`app/services/batch_llm.py`)
- Batch processing for multiple queries
- Optimized for cost/throughput

---

## SECTION 3: GUARDRAILS & SECURITY SERVICES

### 3.1 GUARDRAILS CORE
**File**: `app/core/guardrails.py` (289 lines)
**Purpose**: Unified guardrail enforcement

**Guardrail Types**:
1. **Toxicity Check** - Detect offensive content
2. **PII Detection** - Identify personal information leaks
3. **Injection Detection** - Prevent prompt/SQL injection
4. **Conformance Check** - Verify response adheres to constraints
5. **Grounding Verification** - Ensure response grounded in sources

**Key Methods**:
- `check()` - Run all guardrails on content
- `get_guardrails()` - Singleton instance
- Returns: GuardrailResult (passed: bool, issues: List, recommendations: str)

**Guardrail Actions**:
- PASS: Content is safe
- WARN: Content has minor issues, log for monitoring
- BLOCK: Content blocked, return safe error message

### 3.2 TOXICITY SCORER
**File**: `app/services/toxicity_scorer.py` (183 lines)
**Purpose**: Detect offensive/toxic language

**Model**: detoxify (transformer-based toxicity classifier)
**Toxicity Types**: Profanity, insult, obscene, threat, identity attack
**Threshold**: 0.5 (configurable)

### 3.3 PII DETECTOR
**File**: `app/services/pii_detector.py` (194 lines)
**Purpose**: Detect personally identifiable information

**Detects**:
- Email addresses, phone numbers
- Social security numbers, credit card numbers
- Named entities (names, locations)

**Key Methods**:
- `detect()` - Find PII in text
- `mask()` - Replace PII with placeholders

### 3.4 INJECTION DETECTOR
**File**: `app/services/injection_detector.py` (156 lines)
**Purpose**: Prevent prompt injection attacks

**Detects**:
- Prompt injection patterns
- SQL injection attempts
- Command injection attempts

### 3.5 CONFORMANCE CHECKER
**File**: `app/services/conformance_checker.py` (287 lines)
**Purpose**: Verify response adheres to pedagogical constraints

**Constraints**:
- Response length within bounds
- No direct answers (hints instead)
- Supports learning goals
- Appropriate scaffolding level
- Cites sources

### 3.6 GROUNDING VERIFIER
**File**: `app/services/grounding_verifier.py` (203 lines)
**Purpose**: Verify response grounded in retrieved documents

**Verification**:
- Semantic similarity between response and sources
- Coverage: % of response explained by sources
- Min similarity: 0.6, Min coverage: 0.7


---

## SECTION 4: DATA MODELS & SCHEMAS

**File**: `app/api/schemas.py` (521 lines)

### Core Request/Response Schemas:
- **HealthResponse**: Status of all services (vector_store, llm, mongo, redis, circuit_breaker)
- **PDFUploadResponse**: Success/failure for PDF upload
- **DocumentProcessResult**: Chunks created, embeddings generated, storage location
- **BatchUploadResponse**: Status for batch of documents (per-file success/error)
- **IngestResponse**: Unified ingest response with collection info

### Chat & RAG:
- **QueryRequest/Response**: Simple RAG query (query, collection_id, top_k)
- **AskRequest/Response**: Ask endpoint (query, filters, user_context)
- **ReadingRecommendationRequest/Response**: Recommend materials (user_id, goal, level)
- **ChatMessage**: Message in chat history (role, content, timestamp, user_id)
- **PersonalChatRequest/Response**: 1-to-1 chat (message, user_id, course_id, context)

### Orchestration:
- **OrchestrationRequest**: Full pipeline request
  - Fields: user_id, group_id, message, topic, scaffolding_config, course_id, week_id
- **OrchestrationResponse**: Full pipeline response
  - Fields: reply, intervention, analytics, quality_score, citations, action_taken

### Interventions:
- **InterventionRequest/Response**: Analyze intervention need
- **SummaryRequest/Response**: Generate summary for group discussion
- **PromptRequest/Response**: Generate redirecting prompt

### Analytics:
- **GroupAnalyticsResponse**: Group performance metrics (engagement, participation, anomalies)
- **EngagementAnalysisRequest/Response**: Engagement metrics (HOT, COL, lexical_variety)
- **ProcessMiningExportResponse**: Process mining events for analysis
- **StudentAnalyticsResponse**: Individual student analytics (goals, ai_usage, participation)

### Goals:
- **GoalRequest**: Validate/refine goal (goal_text, course_id, student_id, deadline)
- **GoalValidationResponse**: Validation result with feedback (is_valid, score, suggestions)
- **GoalRefinementResponse**: Refined goal + Socratic questions (refined_goal, questions, feedback)

### Guardrails:
- **GuardrailCheckRequest/Response**: Run guardrails on content
- **GuardrailResult**: Aggregated guardrail checks (passed, issues, recommendations)

### Provider Configuration:
- **ProviderContextV1**: Unified provider support (provider_name, config, auth)
- **ProviderIdentity**: Provider identification (name, version, capabilities)
- **ProviderExecutionConfig**: LLM model, temperature, params, max_tokens
- **ProviderAuthConfig**: API keys, credentials, endpoints

---

## SECTION 5: DATABASE INTEGRATIONS

### 5.1 MONGODB COLLECTIONS
**Connection**: MongoDB at default port (27017)
**Database**: `kolabri_ai_engine`

**Collections**:
1. **chat_logs**
   - Stores: user_id, group_id, message, timestamp, metadata
   - Indexes: group_id, user_id, timestamp
   - Retention: Configurable (default 90 days)

2. **activity_logs**
   - Stores: user_id, action, resource_id, timestamp, metadata
   - Used for: User behavior tracking, audit trails
   - Indexes: user_id, action, timestamp

3. **analytics**
   - Stores: group_id, engagement_metrics, anomalies, process_mining_events
   - Used for: Analytics dashboard, reporting

4. **notifications**
   - Stores: recipient_id, message, type, sent_at, read_at
   - Used for: Teacher notifications, student alerts

### 5.2 QDRANT VECTOR DATABASE
**Connection**: Qdrant at localhost:6333
**Embedding Model**: OpenAI embedding-2 (1536 dimensions)

**Collections by Course**:
- `{course_id}-materials`: Course materials (lectures, slides, etc.)
- `{course_id}-shared-knowledge`: Student-shared knowledge base
- `{course_id}-discussion`: Discussion transcripts

**Collection Schema**:
- Vector: 1536 dimensions (OpenAI embedding-2)
- Payload: {doc_id, title, content_chunk, metadata, chunk_index, source}

### 5.3 REDIS CACHE
**Connection**: Redis at default port (6379)

**Cache Keys**:
- `query_cache:{hash(user_id + query + collection_id)}` - Query results (TTL: 24h)
- `rate_limit:{user_id}` - Rate limit counters (TTL: 1 minute)
- `embeddings_cache:{hash(text)}` - Embedding cache (TTL: 7 days)
- `session:{session_id}` - User session state (TTL: 2 hours)

---

## SECTION 6: CONFIGURATION & SETTINGS

**File**: `app/core/config.py` (273 lines)

### LLM Configuration:
- **Provider**: OpenAI-compatible (DeepSeek)
- **Model**: embedding-2 (for text embedding)
- **Temperature**: 0.7 (default, adjustable per request)
- **Max Tokens**: 2000 (default)
- **Retry Strategy**: Exponential backoff (3 retries)
- **Circuit Breaker**: Open after 5 consecutive failures

### Vector DB Configuration:
- **Service**: Qdrant
- **Host**: localhost
- **Port**: 6333
- **Top-K Results**: 7 (initial retrieval)
- **Similarity Threshold**: 0.35 (minimum relevance)
- **Reranking Model**: jinaai/jina-reranker-v2-base-multilingual

### Document Processing:
- **Max File Size**: 10 MB
- **Chunk Size**: 1000 tokens
- **Chunk Overlap**: 200 tokens
- **OCR Enabled**: True (for scanned PDFs)
- **Supported Formats**: PDF, DOCX, PPTX, JPG, PNG

### RAG Configuration:
- **TOP_K_RESULTS**: 7
- **SIMILARITY_THRESHOLD**: 0.35
- **RERANKING_ENABLED**: True
- **SCAFFOLDING**: {full: 0.3, minimal: 0.7, none: 1.0}

### NLP Analytics Thresholds:
- **HOT Target**: >= 40% (Help Others Teaching)
- **COL Target**: >= 30% (Collective Orientation)
- **Lexical Variety Alert**: < 0.5 (normalized)
- **Quality Check Threshold**: 5 messages minimum

### Intervention Configuration:
- **Cooldown Period**: 5 minutes (between interventions for same group)
- **Min Messages Before Check**: 5
- **Silence Timeout**: 5 minutes
- **Max Interventions Per Hour**: 3 (per group, to prevent spam)

### Scaffolding Configuration:
- **Full Scaffolding Threshold**: 0.3 (engagement level)
- **Minimal Scaffolding Threshold**: 0.7
- **None Scaffolding Threshold**: 1.0
- **Max Messages Before Reduced Scaffolding**: 20

### Security & Rate Limiting:
- **HTTPS**: Enforced in production
- **Rate Limit (per-user)**: 100 requests/minute
- **Rate Limit (per-group)**: 500 requests/minute
- **Request Size Limit**: 10 MB
- **CORS Origins**: core-api, localhost:3000, localhost:8000

### Caching:
- **Query Cache TTL**: 24 hours
- **Embedding Cache TTL**: 7 days
- **Session Cache TTL**: 2 hours
- **Cache Backend**: Redis


---

## SECTION 7: MIDDLEWARE & CORE INFRASTRUCTURE

**File**: `app/core/logging.py`
- Structured logging with JSON format
- Log levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
- Request ID tracking for distributed tracing

**File**: `app/middleware/request_id.py`
- Injects unique request ID into each request
- Used for tracing requests across services
- Propagates to logs and MongoDB records

**File**: `app/middleware/auth.py`
- Token validation for protected routes
- Extracts user_id from JWT token
- Dependency: `require_auth` decorator

**File**: `app/middleware/request_size_limit.py`
- Enforces 10 MB request size limit
- Prevents memory exhaustion from large uploads
- Returns 413 Payload Too Large if exceeded

**File**: `app/core/error_handlers.py`
- Custom exception handling
- LLMDegradedError → 503 Service Unavailable
- Validation errors → 400 Bad Request
- User-safe error messages in responses

**File**: `app/core/redis_cache.py`
- Redis connection pooling
- Supports cluster mode for scaling
- Fallback to in-memory cache if Redis unavailable
- Automatic retry with exponential backoff

**File**: `app/core/circuit_breaker.py`
- Monitors service health
- Opens circuit on repeated failures (5+ consecutive)
- Implements: CLOSED → OPEN → HALF_OPEN → CLOSED
- Prevents cascading failures

---

## SECTION 8: BACKGROUND TASKS & LIFESPAN EVENTS

### Background Tasks:

**silence_monitor_task()** (in `app/services/logic_listener.py`)
- Runs every 60 seconds
- Checks all groups for extended silence (> 5 minutes)
- Triggers interventions for silent groups
- Logs events to MongoDB for analytics

**notification_background_task()** (proposed for future)
- Send notifications to teachers
- Batch processing for efficiency
- Rate limiting to prevent notification spam

### Lifespan Events:

**Startup**:
```
1. Initialize FastAPI app
2. Connect to MongoDB
3. Connect to Qdrant vector store
4. Connect to Redis cache
5. Initialize LLM service with circuit breaker
6. Initialize RAG pipeline
7. Initialize embedding service
8. Start silence monitor background task
9. Initialize all guardrail services
10. Load Prometheus metrics
```

**Shutdown**:
```
1. Cancel silence monitor task
2. Close MongoDB connection
3. Close Redis connection
4. Close Qdrant connection
5. Flush any pending logs/metrics
```

---

## SECTION 9: DATA FLOW DIAGRAMS

### Flow 1: Orchestration Pipeline (Full Chat Message)

```
User Message (group_id, topic, user_id)
    ↓
NLP Analysis (HOT/COL/lexical_variety)
    ↓
Policy Decision (FETCH vs NO_FETCH)
    ├─→ FETCH: Vector Search + Reranking
    ├─→ Top-3 documents selected
    └─→ Context formatted
    ↓
RAG Generation
    ├─→ LLM called with scaffolding_level
    └─→ Response generated
    ↓
Engagement Analysis
    ├─→ Calculate engagement_type
    ├─→ Update fading_level
    └─→ Detect quality issues
    ↓
Intervention Check (Logic Listener)
    ├─→ Silence detection
    ├─→ Off-topic detection
    └─→ Participation inequity detection
    ↓
Intervention Generation (if needed)
    ├─→ Determine intervention_type
    └─→ Generate intervention message
    ↓
Guardrail Checks
    ├─→ Toxicity check
    ├─→ PII detection
    ├─→ Injection detection
    ├─→ Conformance check
    └─→ Grounding verification
    ↓
MongoDB Logging
    ├─→ Store chat_log
    ├─→ Store activity_log
    └─→ Update analytics
    ↓
Notification Check
    ├─→ If intervention needed & should_notify_teacher
    └─→ Create notification record
    ↓
Response (reply, interventions, analytics, citations)
```

### Flow 2: Document Ingestion

```
Document Upload
    ↓
Format Detection (PDF/DOCX/PPTX/Image)
    ↓
Text Extraction
    ├─→ Parse format-specific content
    └─→ OCR (if images/scanned)
    ↓
Chunking (1000 tokens, 200 overlap)
    ↓
Embedding (OpenAI embedding-2)
    ├─→ Batch embedding for efficiency
    └─→ Cache results in Redis
    ↓
Vector Store Insertion (Qdrant)
    ├─→ Create collection if needed
    └─→ Insert chunks with metadata
    ↓
Response (doc_id, chunks_created, status)
```

### Flow 3: Goal Validation & Refinement

```
Goal Input (goal_text, course_id, student_id)
    ↓
SMART Validation
    ├─→ Check specificity
    ├─→ Check measurability
    ├─→ Check achievability
    ├─→ Check relevance
    └─→ Check time-bound
    ↓
Validation Result
    ├─→ PASS: Return feedback
    └─→ FAIL: Proceed to refinement
    ↓
Socratic Questioning (if FAIL)
    ├─→ Generate clarifying questions
    ├─→ Ask user for feedback
    └─→ Store conversation history
    ↓
Goal Refinement
    ├─→ Re-validate refined goal
    └─→ Return refined_goal + feedback
```


---

## SECTION 10: ANALYTICS SERVICES (SPECIALIZED)

### 10.1 PLAN VS REALITY ANALYZER
**File**: `app/services/plan_vs_reality.py` (754 lines)
**Purpose**: Track student progress vs learning goals

**Tracks**:
- Learning goal set by student
- Actual learning achievements (participation, quiz scores, etc.)
- Deviation analysis
- Intervention recommendations if off-track

**Key Methods**:
- `analyze_progress()` - Compare plan vs reality
- `calculate_deviation()` - Compute progress gap
- `generate_recommendations()` - Suggest corrective actions

### 10.2 PROCESS MINING ANOMALY DETECTION
**File**: `app/services/process_mining_anomaly.py` (772 lines)
**Purpose**: Detect anomalous discussion patterns

**Anomaly Types**:
- Sudden silence (no activity > 10 minutes)
- Rapid escalation (many messages in <5 minutes)
- Topic drift (semantic similarity drops)
- Participation collapse (active → inactive)
- Emotional escalation (toxicity increase)

**Key Methods**:
- `detect_anomalies()` - Identify anomalies in event stream
- `classify_anomaly_type()` - Determine anomaly category
- `generate_alert()` - Create teacher notification

**Output**: Exported for process mining algorithms (PM4Py, etc.)

### 10.3 EXPORT SERVICE
**File**: `app/services/export_service.py` (366 lines)
**Purpose**: CSV export for external analysis

**Exports**:
1. **Activity Export**
   - Format: user_id, timestamp, action, resource_id, metadata
   - Use: Behavioral analysis, audit trails

2. **Process Mining Export**
   - Format: case_id, event, timestamp, resource, activity_type
   - Use: Process discovery, conformance checking

**Key Methods**:
- `export_activity_csv()` - Export activity logs
- `export_process_mining_csv()` - Export PM4Py-compatible events

---

## SECTION 11: PROMPT TEMPLATES & STYLES

**File**: `app/core/prompt_templates.py`
- SYSTEM_PERSONAL_CHAT: System prompt for 1-to-1 chat
- SYSTEM_RAG_NO_CONTEXT: System prompt when no context retrieved
- SYSTEM_ORCHESTRATION: System prompt for full pipeline

**File**: `app/core/prompt_styles.py`
- SCAFFOLDING_EARLY_STYLE: For early-stage learning (full scaffolding)
- SCAFFOLDING_LATE_STYLE: For advanced stage (minimal scaffolding)
- Examples, detailed explanations, vs. concise answers

---

## SECTION 12: UTILITY SERVICES

### 12.1 SENSITIVE DATA HANDLING
**File**: `app/utils/sensitive_data.py`
- PII masking for logs
- Sanitization before storing in MongoDB

### 12.2 TEXT PROCESSOR
**File**: `app/utils/text_processor.py`
- Text cleaning (remove special chars, normalize)
- Tokenization
- Stop word removal
- Language detection

### 12.3 LOGGER UTILITIES
**File**: `app/utils/logger.py`
- Process mining logger (structured events)
- Activity logger (user actions)
- Structured JSON logging

---

## SECTION 13: EXTERNAL SERVICE INTEGRATIONS

### 13.1 LLM PROVIDER (OpenAI-Compatible)
**Service**: DeepSeek (OpenAI-compatible API)
**Model**: Configurable (default: appropriate model for task)
**Integration Points**:
- LLM service for text generation
- Embedding service for vector representations
- Streaming support for real-time responses

**Fallback Strategy**:
- Circuit breaker opens after 5 consecutive failures
- Returns cached response or error message to user

### 13.2 VECTOR DATABASE
**Service**: Qdrant
**Purpose**: Semantic search for retrieved documents
**Integration Points**:
- Document ingestion pipeline
- RAG query retrieval
- Similarity search for off-topic detection

### 13.3 DOCUMENT PROCESSING
**Tools**:
- pytesseract: OCR for scanned documents
- pdfplumber: PDF text extraction
- python-pptx: PowerPoint extraction
- PIL (Pillow): Image processing

### 13.4 NLP LIBRARIES
**Libraries**:
- NLTK: Tokenization, stop words
- spaCy: Named entity recognition (for PII detection)
- TextBlob: Sentiment analysis
- Transformers: Toxicity detection (detoxify)

---

## SECTION 14: DEPLOYMENT & DOCKER

**File**: `Dockerfile` (Python 3.10+ base)
- FastAPI server on port 8001
- Includes all Python dependencies
- Environment variables for configuration

**File**: `docker-compose.yml`
- AI Engine service (port 8001)
- Qdrant vector store (port 6333)
- MongoDB (port 27017)
- Redis (port 6379)
- Network: kolabri-network (shared with core-api)

**Health Checks**:
- GET /health endpoint (every 30 seconds)
- Restart policy: on-failure (max 3 retries)

---

## SECTION 15: AUTHENTICATION & AUTHORIZATION

**Protected Routes**:
- All routes in `orchestration.py`
- All routes in `analytics.py`
- All intervention routes

**Authentication Method**:
- JWT token in Authorization header
- Extracted by `require_auth` middleware
- User ID propagated through request context

**Scope-Based Access** (proposed):
- `read:analytics` - Read analytics dashboards
- `write:intervention` - Create interventions
- `admin:guardrails` - Manage guardrail settings

---

## SECTION 16: TESTING & VALIDATION

**Test Files** (inferred from project structure):
- `tests/unit/test_rag.py` - RAG pipeline tests
- `tests/unit/test_orchestration.py` - Orchestration tests
- `tests/integration/test_chat_flow.py` - End-to-end chat flow
- `tests/integration/test_document_ingestion.py` - Document processing

**Test Frameworks**:
- pytest (unit testing)
- pytest-asyncio (async test support)
- unittest.mock (mocking external services)

---

## SECTION 17: MONITORING & OBSERVABILITY

### Prometheus Metrics Exported:
- `kolabri_ai_requests_total` - Total requests by route/method
- `kolabri_ai_request_duration_seconds` - Request latency histogram
- `kolabri_ai_llm_tokens_used_total` - LLM token usage
- `kolabri_ai_vector_store_queries_total` - Vector search count
- `kolabri_ai_cache_hits_total` - Cache hit count
- `kolabri_ai_cache_misses_total` - Cache miss count
- `kolabri_ai_rate_limit_violations_total` - Rate limit violations
- `kolabri_ai_circuit_breaker_state` - Circuit breaker state (0=closed, 1=open, 2=half_open)

### Logging:
- Structured JSON logs to stdout
- Log level configurable via environment variable
- Request IDs for tracing

### Health Checks:
- GET /health - Full system health
- GET /health/monitoring - Detailed monitoring
- GET /health/circuit-breakers - Individual service health


---

## SECTION 18: KEY INTEGRATION POINTS WITH CORE API

### 18.1 User & Course Context
**Core API provides**:
- User authentication & authorization
- Course enrollment data
- Learning goals from goal_validator in core-api
- Group membership

**AI Engine uses**:
- user_id for personalization
- course_id for document filtering
- group_id for intervention targeting
- Learning goals for progress tracking

### 18.2 Chat Space Integration
**Core API owns**: Chat spaces, messages, message history
**AI Engine uses**:
- chat_space_id for context
- week_id for week-based filtering (from course_weeks)
- Recent message history for context window
- Participation metadata

### 18.3 Notifications
**AI Engine triggers**:
- Teacher notifications for interventions
- Student notifications for reading recommendations
- Group notifications for announcements

**Core API**:
- Stores notification records
- Manages delivery status
- Tracks read/unread state

### 18.4 Analytics Data Exchange
**AI Engine sends to Core API**:
- Engagement metrics (HOT, COL scores)
- Participation data
- Anomaly alerts
- Process mining events

**Core API stores in**:
- analytics collection (MongoDB)
- activity_logs collection
- Displayed in dashboards

---

## SECTION 19: KNOWN LIMITATIONS & FUTURE IMPROVEMENTS

### Current Limitations:
1. **In-Memory State**: Analytics (fading, streaks) are per-process, lost on restart
   - Future: Persist all state to MongoDB

2. **Single LLM Provider**: Only OpenAI-compatible
   - Future: Plugin architecture for multiple providers

3. **Synchronous Processing**: Long-running tasks block requests
   - Future: Async task queue (Celery/Dramatiq)

4. **Local Vector Store**: Qdrant on single machine
   - Future: Distributed Qdrant cluster

5. **Limited Reranking**: Only Jina cross-encoder
   - Future: Multiple reranker options, A/B testing

### Proposed Enhancements:
1. **Multilingual Support**: Currently Indonesian/English
   - Add language detection + model selection

2. **Real-time Collaboration**: Current analysis is post-hoc
   - Future: Stream processing for live insights

3. **Teacher Dashboard**: Limited teacher visibility
   - Future: Real-time intervention dashboard

4. **Student Goal Tracking**: Basic tracking
   - Future: ML-based goal achievement prediction

---

## SECTION 20: QUICK REFERENCE - FILE LOCATIONS

### Route Files (`app/api/routes/`)
| File | Endpoints | Purpose |
|------|-----------|---------|
| health.py | /health | System health |
| documents.py | /ingest, /ingest/batch, /documents/{id} | Document management |
| chat.py | /ask, /chat/personal, /reading-recommendations | RAG queries |
| orchestration.py | /chat, /chat/stream | Full pipeline |
| analytics.py | /analytics/*, /export/* | Analytics & reporting |
| interventions.py | /intervention/* | Intervention generation |
| efficiency.py | /efficiency/* | Caching & rate limiting |
| goals.py | /goals/* | Goal validation |
| groups.py | /groups/* | Group monitoring |
| discussion_direction.py | /classify-relevance, /session-summary | Message classification |
| track_activity.py | /track-activity | Activity logging |
| monitoring.py | /metrics, /health/* | Monitoring |

### Service Files (`app/services/`)
| File | Purpose | Lines |
|------|---------|-------|
| orchestration.py | Central coordinator | 975 |
| rag.py | RAG pipeline | 910 |
| document_processor.py | Document ingestion | 921 |
| goal_validator.py | Goal validation | 755 |
| plan_vs_reality.py | Progress tracking | 754 |
| process_mining_anomaly.py | Anomaly detection | 772 |
| logic_listener.py | Group monitoring | 529 |
| efficiency_guard.py | Caching/rate limiting | 482 |
| nlp_analytics.py | Engagement analysis | 429 |
| llm.py | LLM service | 412 |
| intervention.py | Intervention generation | 412 |
| vector_store.py | Vector DB operations | 307 |
| monitoring.py | Prometheus metrics | 305 |
| conformance_checker.py | Response validation | 287 |
| mongodb_logger.py | MongoDB logging | - |
| reranker.py | Cross-encoder reranking | 157 |
| toxicity_scorer.py | Toxicity detection | 183 |
| pii_detector.py | PII detection | 194 |
| injection_detector.py | Injection detection | 156 |
| grounding_verifier.py | Grounding verification | 203 |

### Core Configuration (`app/core/`)
| File | Purpose |
|------|---------|
| config.py | Central configuration (273 lines) |
| guardrails.py | Guardrail enforcement (289 lines) |
| prompt_templates.py | Prompt templates |
| prompt_styles.py | Scaffolding styles |
| logging.py | Structured logging |
| error_handlers.py | Exception handling |
| redis_cache.py | Redis connection |
| circuit_breaker.py | Service resilience |

### Middleware (`app/middleware/`)
| File | Purpose |
|------|---------|
| request_id.py | Request tracking |
| auth.py | Token validation |
| request_size_limit.py | Request size enforcement |


---

## SECTION 21: SUMMARY OF KEY STATISTICS

### Codebase Metrics:
- **Total Service Files**: 34
- **Route Files**: 11
- **Total Lines of Code**: ~10,000+ (estimated)
- **Primary Language**: Python 3.10+
- **Framework**: FastAPI

### Service Sizes (in lines):
- orchestration.py: 975 (largest)
- document_processor.py: 921
- rag.py: 910
- process_mining_anomaly.py: 772
- plan_vs_reality.py: 754
- goal_validator.py: 755
- logic_listener.py: 529
- efficiency_guard.py: 482
- nlp_analytics.py: 429
- llm.py: 412
- intervention.py: 412
- (and 22 smaller services)

### Key Dependencies:
- **FastAPI**: Web framework
- **Pydantic**: Data validation
- **OpenAI SDK**: LLM integration
- **Qdrant-client**: Vector DB client
- **PyMongo**: MongoDB driver
- **Redis**: Cache client
- **slowapi**: Rate limiting
- **Prometheus-client**: Metrics
- **pytesseract**: OCR
- **pdfplumber**: PDF parsing
- **python-pptx**: PowerPoint parsing
- **Transformers**: Toxicity detection (detoxify)
- **NLTK**: NLP utilities
- **spaCy**: NER for PII detection

### Database Collections:
- MongoDB: chat_logs, activity_logs, analytics, notifications
- Qdrant: {course_id}-materials, {course_id}-shared-knowledge, {course_id}-discussion
- Redis: query_cache, rate_limit, embeddings_cache, session

### API Endpoints:
- **Total Routes**: 30+ endpoints
- **Health Endpoints**: 4
- **Document Endpoints**: 3
- **Chat Endpoints**: 4
- **Orchestration Endpoints**: 2
- **Analytics Endpoints**: 6
- **Intervention Endpoints**: 3
- **Efficiency Endpoints**: 5
- **Goal Endpoints**: 2
- **Group Endpoints**: 4
- **Discussion Endpoints**: 2
- **Activity Endpoints**: 1

---

## SECTION 22: READING GUIDE FOR STAKEHOLDERS

### For **System Architects**:
- Read: Sections 1, 13, 18 (Routes, External Integrations, Core API Integration)
- Focus: Data flows, system boundaries, dependency graph

### For **Backend Developers**:
- Read: Sections 2, 3, 4, 7 (Services, Guardrails, Data Models, Middleware)
- Focus: Service implementation, request/response schemas, error handling

### For **DevOps/Infrastructure**:
- Read: Sections 14, 15, 17 (Deployment, Auth, Monitoring)
- Focus: Docker setup, health checks, metrics, scaling considerations

### For **QA/Testers**:
- Read: Sections 9, 16 (Data Flows, Testing)
- Focus: Integration test cases, edge cases, error scenarios

### For **Product/Stakeholders**:
- Read: Sections 1.1-1.11 (API Routes by domain)
- Focus: Feature set, user-facing capabilities, analytics export

### For **Documentation Writers**:
- Read: Entire inventory (reference document)
- Focus: All sections for comprehensive documentation

---

## SECTION 23: IMPLEMENTATION VERIFICATION CHECKLIST

Use this checklist when implementing or auditing the AI Engine:

- [ ] All 11 route files present and registered in FastAPI app
- [ ] All 34+ service modules importable without errors
- [ ] MongoDB collections created with proper indexes
- [ ] Qdrant collections initialized for each course
- [ ] Redis connection pool configured
- [ ] LLM circuit breaker initialized on startup
- [ ] Prometheus metrics registered
- [ ] Request ID middleware active on all routes
- [ ] Auth middleware protecting sensitive routes
- [ ] Error handlers registered for all exception types
- [ ] Background silence monitor task scheduled
- [ ] Guardrail checks implemented on orchestration path
- [ ] RAG policy decision logic working (FETCH/NO_FETCH)
- [ ] Reranking applied to top-7 retrieval results
- [ ] Scaffolding levels adjusting based on engagement
- [ ] Logic Listener detecting silence (5+ min)
- [ ] Logic Listener detecting off-topic (embedding similarity)
- [ ] Logic Listener detecting participation inequity (Gini)
- [ ] Interventions respecting cooldown (5 min)
- [ ] Interventions not exceeding spam threshold (3/hour)
- [ ] Goal validation checking all 5 SMART criteria
- [ ] Document processor supporting all 5 file types
- [ ] Vector embeddings cached in Redis
- [ ] Query cache functioning (24h TTL)
- [ ] Rate limiting enforced (100 user/min, 500 group/min)
- [ ] PII detector masking before MongoDB storage
- [ ] Toxicity checker blocking harmful content
- [ ] Injection detector preventing prompt attacks
- [ ] Conformance checker validating response length/format
- [ ] Grounding verifier checking similarity threshold
- [ ] Activity logs being recorded for all interactions
- [ ] Engagement metrics exported via /analytics endpoints
- [ ] Process mining events exported in proper format
- [ ] Health endpoint returning service status
- [ ] Prometheus metrics accessible at /metrics
- [ ] Structured JSON logging to stdout
- [ ] Request tracing via request IDs functional

---

## SECTION 24: RELATED DOCUMENTATION

**See also**:
- `Kolabri-core-api/prisma/schema.prisma` - PostgreSQL schema (User, Course, Group, ChatSpace, etc.)
- `Kolabri-core-api/src/services/` - Core API services
- `Kolabri-client-app/database/seeders/MaterialsDemoSeeder.php` - Sample course materials
- `Kolabri-core-api/src/services/weekContext.service.ts` - Week context for AI Engine
- `Kolabri-core-api/src/utils/citationFilter.ts` - Citation filtering in core-api

---

## FINAL NOTES

This inventory was created by comprehensive codebase exploration of Kolabri AI Engine (Python/FastAPI). It captures:

1. **All API routes** organized by domain
2. **All services** with purpose and key methods
3. **All schemas** for requests/responses
4. **All database integrations** (MongoDB, Qdrant, Redis)
5. **All configuration options** with defaults
6. **All middleware and infrastructure**
7. **All data flows** with diagrams
8. **All external integrations** and dependencies
9. **All known limitations** and future improvements
10. **File locations and metrics** for quick reference

This document is suitable for:
- System Design Document (SDD) generation
- Software Requirements Specification (SRS) writing
- Architecture documentation
- Onboarding new developers
- API client integration
- Testing strategy development

---

**Document Version**: 1.0
**Date**: 2026-06-21
**Status**: Complete & Verified

