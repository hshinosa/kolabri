## Context

Kolabri already has `ChatSpace`, `ChatMessage`, and `replyToId`, which provides a basic reply chain but not first-class topic organization. Interview evidence shows the real user problem is broader: students need to find important messages later, keep multiple assignment topics from mixing, and navigate back to prior decisions or documents. The solution therefore needs both retrieval (search) and structure (topics/threads).

## Goals / Non-Goals

**Goals:**
- Make important discussion content discoverable after the fact.
- Let teams separate topics/tasks inside the same collaboration space.
- Support efficient navigation from search results back into message context.

**Non-Goals:**
- Full enterprise search across every platform artifact in v1.
- Replacing existing chat spaces with a completely new forum product.

## Decisions

### Introduce explicit topic/thread metadata beyond reply chains
Reply chains alone are not enough to represent assignment topics, planning threads, or recoverable discussion structure. A topic/thread entity or equivalent metadata layer is needed.

### Search must operate on message content, not space names only
Current space-level filtering is insufficient because the problem described by students is lost message content within a conversation. Message-level search is therefore mandatory.

### Search results should deep-link into context
Results need to open the relevant room and navigate to the matching message or thread so users do not still have to scroll manually.

## Risks / Trade-offs

- **Search indexing adds storage/query complexity** → Start with scoped message search and optimize later.
- **Too many organizational primitives may overwhelm users** → Keep v1 to topics/threads plus search, not full taxonomy explosion.
- **Older messages may need backfill** → Handle legacy messages without requiring perfect retrospective threading.

## Migration Plan

1. Extend chat data model with topic/thread metadata.
2. Add message indexing/query capabilities.
3. Update chat UI with search and topic/thread organization.
4. Validate navigation and performance on existing chat history.

Rollback: disable new search/topic UI while preserving raw chat history and reply relationships.

## Open Questions

- Should v1 use explicit user-created topics, automatic thread grouping, or both?
- What search scope should be supported first: current room only, current course, or all accessible chats?
