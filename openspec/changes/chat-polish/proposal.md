## Why

Chat room Kolabri perlu polish untuk meningkatkan UX dan accessibility:

1. **AI Thread Summary** — Chat panjang bikin user ketinggalan konteks. AI summary bantu catch-up cepat.
2. **Drag & Drop File Upload** — UX upload files lebih natural, drag langsung ke chat area.
3. **Accessibility Audit** — WCAG compliance untuk screen readers, keyboard navigation, ARIA labels.
4. **Performance Technical** — Debounced typing, batch rendering, virtualization audit.

## What Changes

- **AI Summary Card Enhancement** — Existing `ChatSummaryCard` diperluas dengan "Summarize Thread" button per-thread
- **Drag & Drop Zone** — Drop zone overlay di chat area dengan visual feedback
- **Accessibility** — ARIA labels, role attributes, keyboard shortcuts, focus management
- **Performance** — Typing debounce, message chunk rendering, memoization audit

## Capabilities

### Modified Capabilities
- `chat-room`: Enhanced with drag-drop, accessibility, performance
- `chat-summary`: Thread-level summary support

## Impact

- **Frontend JS**: `room.tsx`, new components for drag-drop, a11y utils
- **Dependencies**: Tidak ada dependency baru
- **Breaking changes**: Tidak ada
