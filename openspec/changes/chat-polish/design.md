## Context

Kolabri chat room sudah functional tapi perlu polish:
- `ChatSummaryCard` sudah ada di `features/chat/summary/`
- File upload sudah ada via `uploadAttachments` utility
- Chat room ~2420 baris, perlu performance audit
- Accessibility belum teraudit

## Goals / Non-Goals

**Goals:**
- AI summary bisa di-trigger per-thread atau per-section
- File upload via drag & drop dengan visual feedback
- WCAG 2.1 AA compliance untuk chat room
- Performance improvements untuk chat panjang

**Non-Goals:**
- Rewrite chat room dari awal
- Tambah dependency baru
- Mobile native app

## Decisions

### 1. AI Thread Summary
**Pilihan**: Extend existing `ChatSummaryCard` dengan trigger button.
- Tambah "Ringkas percakapan" button di chat header
- Reuse existing AI summary backend
- Render summary di collapsible card

### 2. Drag & Drop
**Pilihan**: Overlay drop zone dengan visual feedback.
- Detect dragenter/dragleave/drop events di chat area
- Tampilkan drop zone overlay dengan border animasi
- Reuse existing `uploadAttachments` utility
- Support multiple files

### 3. Accessibility
**Pilihan**: Systematic ARIA + keyboard audit.
- Add aria-labels pada interactive elements
- Ensure keyboard navigation (Tab, Enter, Escape)
- Add role attributes pada custom components
- Focus management untuk modals/dropdowns

### 4. Performance
**Pilihan**: Targeted optimizations tanpa rewrite.
- Debounce typing indicator (300ms)
- Memoize expensive computations
- Audit React.memo opportunities
- Lazy load non-critical components

## Risks / Trade-offs

- **Drag & Drop** — Mobile browsers punya drag behavior berbeda, perlu fallback
- **Accessibility** — Beberapa components mungkin perlu refactor untuk a11y
- **Performance** — Memoization bisa menambah complexity
