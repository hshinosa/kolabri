## 1. AI Thread Summary

- [x] 1.1 Create `AISummaryButton` component with loading state
- [x] 1.2 Integrate summary trigger into chat header
- [x] 1.3 Reuse existing `ChatSummaryCard` for display
- [x] 1.4 Add summary refresh capability

## 2. Drag & Drop File Upload

- [x] 2.1 Create `useDragDrop` hook for drag/drop events
- [x] 2.2 Create `DropZoneOverlay` component with visual feedback
- [x] 2.3 Integrate drag-drop into chat message area
- [x] 2.4 Add file validation (type, size) on drop
- [x] 2.5 Add mobile touch fallback (tap to upload)

## 3. Accessibility Audit

- [x] 3.1 Add aria-labels to message list and individual messages
- [x] 3.2 Add role attributes to custom interactive elements
- [x] 3.3 Implement keyboard shortcuts (Escape to close modals)
- [x] 3.4 Add focus management for modals and dropdowns
- [x] 3.5 Add screen reader announcements for new messages
- [x] 3.6 Audit and fix color contrast issues

## 4. Performance Technical

- [x] 4.1 Debounce typing indicator (300ms send, 1000ms stop)
- [x] 4.2 Memoize message component with React.memo
- [x] 4.3 Add useMemo for expensive computations (filteredMembers, etc.)
- [x] 4.4 Audit and optimize re-render triggers
