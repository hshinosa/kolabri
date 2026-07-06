## Why

Students repeatedly described a core discussion problem: important messages sink in busy chats, multiple task topics get mixed together, and prior decisions or documents become hard to find. Kolabri already has chat spaces and message replies, but it lacks message-level search and robust topic organization, so discussion quality degrades as chat volume grows.

## What Changes

- Add message search across relevant discussion history.
- Add explicit topic/thread organization inside discussion spaces.
- Surface pinned or otherwise important discussion items more reliably.
- Preserve discoverability of past decisions and shared references without forcing users into many separate groups.

## Capabilities

### New Capabilities
- `discussion-search-and-topics`: Search discussion content and organize messages by topic or thread.

### Modified Capabilities
- `dashboard`: Extend relevant discussion surfaces to surface searchable and organized discussion context.

## Impact

- `Kolabri-core-api`: chat models, search query endpoints, topic/thread metadata.
- `Kolabri-client-app`: chat room/search UI, topic/thread views, message navigation.
- Search indexing/storage strategy in chat persistence layer.
