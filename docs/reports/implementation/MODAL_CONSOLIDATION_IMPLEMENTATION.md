# Modal Consolidation Implementation Guide

**Project**: Kolabri Platform  
**Date**: 14 Juni 2026  
**Related**: [Security & Quality Audit Report](./SECURITY_AUDIT_REPORT.md) - Issue M1  
**Status**: Implementation Plan  
**Estimated Time**: 10 hours (1.25 days)

---

## Executive Summary

### Problem Statement

Kolabri platform memiliki **25+ modal instances** scattered across codebase dengan:
- ❌ **3 duplicate admin FormModal** copies (nearly identical)
- ❌ **22+ modals tanpa accessibility** (no role="dialog", aria-modal, focus trap, ESC handler)
- ❌ **Inconsistent patterns** (backdrop blur, z-index, state management)
- ❌ **No code reuse** (inline implementations everywhere)

### Solution

Consolidate ke **3-4 specialized modal components** dengan **shared BaseModal** yang handle semua accessibility features:

```
BaseModal (accessibility core)
├── AlertModal (simple messages)
├── ConfirmDialog (yes/no confirmations)
└── FormModal (complex forms)
```

### Benefits

✅ **Remove ~300 lines** duplicate code  
✅ **Fix 25+ modals** accessibility at once  
✅ **WCAG AA compliant** across platform  
✅ **Save ~40 hours** future maintenance  
✅ **Type-safe** & easy to use  
✅ **Single source of truth** for modal behavior

---

## Current State Analysis

### Audit Findings Summary

**Total Modal Count**: 25+ instances

| Category | Count | Status |
|----------|-------|--------|
| Shared reusable components | 6 | ⚠️ Missing accessibility |
| Duplicate admin FormModal | 3 | ❌ Need consolidation |
| Admin inline modals | 6 | ❌ Not extracted |
| Lecturer inline modals | 3 | ❌ Not extracted |
| Student inline modals | 6 | ❌ Not extracted |
| Duplicate search/shortcut | 2 | ❌ Need merge |

### Accessibility Baseline

**✅ Good Examples (3 files)**:
- `student/chat/room.tsx` - Full accessibility (reference implementation)
- `components/course/DocumentViewerModal.tsx` - Basic accessibility
- `components/lecturer/UnifiedMaterialsTab.tsx` - Partial accessibility

**❌ Missing Accessibility (22+ files)**:
- No `role="dialog"` or `aria-modal="true"`
- No focus trap implementation
- No ESC key handler
- No focus return to trigger element

### Modal Types in Use

**Type 1: Form Modal** (10 instances)
- Admin: Create/edit/delete AI providers, users, courses, templates
- Pattern: Reusable wrapper with title, description, form children
- **Problem**: 3 duplicate copies (user-management, master-data, ai-settings)

**Type 2: Simple Dialog** (5 instances)
- Lecturer: Create sessions
- Student: Create groups, templates, reflections
- Pattern: Inline fixed positioning with AnimatePresence
- **Problem**: No accessibility, not extracted to components

**Type 3: Confirmation** (4 instances)
- Destructive actions: Delete account, delete chat
- Info/preview: View documents, session summaries
- Pattern: Warning banner with confirmation input
- **Problem**: No dedicated ConfirmDialog component

**Type 4: Complex Interactive** (2 instances)
- Avatar crop modal (drag, zoom, reset)
- File/document viewers (dynamic content)
- Pattern: Multi-step with internal state
- **Status**: Keep separate (too specialized)

---

## Consolidation Strategy

### Architecture Overview

```typescript
// Base accessibility logic
components/ui/BaseModal.tsx
  ↓ (provides: role, aria, focus trap, ESC handler)
  ├── AlertModal.tsx        // Simple messages
  ├── ConfirmDialog.tsx     // Yes/no confirmations
  └── FormModal.tsx         // Complex forms

// Specialized (keep separate)
components/ui/ImagePreviewModal.tsx
components/ui/DateRangeModal.tsx
```

### Why 3-4 Components (Not 1)?

**❌ Single Universal Modal**:
```tsx
<UniversalModal
    type="form|alert|confirm"
    variant="danger|success|warning"
    onSubmit={...}
    confirmLabel="..."
    // ... 20+ props (confusing!)
>
```
- Too many props
- Complex type definitions
- Hard to maintain
- Different concerns mixed

**✅ Specialized Components**:
```tsx
<AlertModal title="Success" message="..." type="success" />
<ConfirmDialog title="Delete?" onConfirm={...} variant="danger" />
<FormModal title="Create User" onSubmit={...}>{children}</FormModal>
```
- Clear separation
- Type-safe props
- Easy to understand
- Maintainable

### Shared vs. Specialized Logic

**BaseModal (Shared)**:
- ✅ role="dialog", aria-modal="true", aria-labelledby
- ✅ Focus trap (keyboard users can't tab out)
- ✅ ESC key handler (close on Escape)
- ✅ Focus return (restore focus to trigger element)
- ✅ Backdrop with click-to-close
- ✅ AnimatePresence animations
- ✅ Z-index management

**Specialized Components (Own)**:
- AlertModal: Icon based on type (info/success/warning/error)
- ConfirmDialog: Confirmation input for destructive actions
- FormModal: Form layout with submit/cancel buttons

---

## Component Specifications

### 1. BaseModal (Core Accessibility)

**File**: `components/ui/BaseModal.tsx`

**Purpose**: Provides all accessibility features for modals. Other modal components extend this.

**Props**:
```typescript
interface BaseModalProps {
    isOpen: boolean;
    onClose: () => void;
    title: string;
    children: ReactNode;
    size?: 'sm' | 'md' | 'lg' | 'xl';
    showCloseButton?: boolean;
    closeOnBackdropClick?: boolean;
}
```

**Features**:
- ✅ `role="dialog"` on modal container
- ✅ `aria-modal="true"` to indicate modal state
- ✅ `aria-labelledby` linked to title
- ✅ Focus trap: keyboard users stay in modal
- ✅ ESC key handler: close modal on Escape
- ✅ Focus return: restore focus to trigger element on close
- ✅ Backdrop: fixed inset-0 with blur
- ✅ Animation: scale + opacity with Framer Motion

**Implementation Pattern** (extracted from `chat/room.tsx` lines 816-839, 1356-1371):
```typescript
export function BaseModal({ isOpen, onClose, title, children, size = 'md' }: BaseModalProps) {
    const dialogRef = useRef<HTMLDivElement>(null);
    const previousFocusRef = useRef<HTMLElement | null>(null);
    
    useEffect(() => {
        if (!isOpen) return;
        
        // Remember what was focused before modal opened
        previousFocusRef.current = document.activeElement as HTMLElement;
        
        const dialog = dialogRef.current;
        if (!dialog) return;
        
        // Get focusable elements
        const focusable = dialog.querySelectorAll<HTMLElement>(
            'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        );
        const firstElement = focusable[0];
        const lastElement = focusable[focusable.length - 1];
        
        // Focus first element
        firstElement?.focus();
        
        // Handle keyboard
        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.key === 'Escape') {
                onClose();
                return;
            }
            
            // Tab focus trap
            if (e.key === 'Tab') {
                if (focusable.length === 0) return;
                
                if (e.shiftKey && document.activeElement === firstElement) {
                    e.preventDefault();
                    lastElement?.focus();
                } else if (!e.shiftKey && document.activeElement === lastElement) {
                    e.preventDefault();
                    firstElement?.focus();
                }
            }
        };
        
        dialog.addEventListener('keydown', handleKeyDown);
        
        return () => {
            dialog.removeEventListener('keydown', handleKeyDown);
            // Return focus to trigger element after modal close
            previousFocusRef.current?.focus();
        };
    }, [isOpen, onClose]);
    
    if (!isOpen) return null;
    
    const sizeClasses = {
        sm: 'max-w-md',
        md: 'max-w-lg',
        lg: 'max-w-2xl',
        xl: 'max-w-4xl'
    };
    
    return (
        <AnimatePresence>
            <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
                {/* Backdrop */}
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    className="fixed inset-0 bg-black/50 backdrop-blur-sm"
                    onClick={onClose}
                    aria-hidden="true"
                />
                
                {/* Modal */}
                <motion.div
                    ref={dialogRef}
                    initial={{ scale: 0.95, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    exit={{ scale: 0.95, opacity: 0 }}
                    role="dialog"
                    aria-modal="true"
                    aria-labelledby="modal-title"
                    className={`relative bg-white rounded-lg shadow-xl ${sizeClasses[size]} w-full max-h-[90vh] overflow-y-auto`}
                >
                    {/* Header */}
                    <div className="flex items-center justify-between p-6 border-b">
                        <h2 id="modal-title" className="text-xl font-semibold">
                            {title}
                        </h2>
                        <button
                            onClick={onClose}
                            className="text-gray-400 hover:text-gray-600"
                            aria-label="Close dialog"
                        >
                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                    
                    {/* Content */}
                    <div className="p-6">
                        {children}
                    </div>
                </motion.div>
            </div>
        </AnimatePresence>
    );
}
```

**Testing Checklist**:
- [ ] Keyboard: Tab cycles through focusable elements only
- [ ] Keyboard: Shift+Tab cycles backwards
- [ ] Keyboard: ESC closes modal
- [ ] Focus: First element focused on open
- [ ] Focus: Returns to trigger on close
- [ ] Screen reader: Announces "dialog" role
- [ ] Screen reader: Reads title
- [ ] Mouse: Backdrop click closes modal
- [ ] Visual: Animations smooth (scale + opacity)


### 2. AlertModal (Simple Messages)

**File**: `components/ui/AlertModal.tsx`

**Purpose**: Display simple messages/alerts to users with OK button.

**Props**:
```typescript
interface AlertModalProps {
    isOpen: boolean;
    onClose: () => void;
    title: string;
    message: string;
    type?: 'info' | 'success' | 'warning' | 'error';
    confirmLabel?: string;
}
```

**Implementation**:
```typescript
import { BaseModal } from './BaseModal';

export function AlertModal({
    isOpen,
    onClose,
    title,
    message,
    type = 'info',
    confirmLabel = 'OK'
}: AlertModalProps) {
    const icons = {
        info: { icon: 'ℹ️', color: 'text-blue-600' },
        success: { icon: '✅', color: 'text-green-600' },
        warning: { icon: '⚠️', color: 'text-yellow-600' },
        error: { icon: '❌', color: 'text-red-600' }
    };
    
    const { icon, color } = icons[type];
    
    return (
        <BaseModal isOpen={isOpen} onClose={onClose} title={title} size="sm">
            <div className="flex items-start space-x-3">
                <span className={`text-2xl ${color}`}>{icon}</span>
                <p className="text-gray-600 flex-1">{message}</p>
            </div>
            
            <div className="mt-6 flex justify-end">
                <button
                    onClick={onClose}
                    className="px-4 py-2 bg-brand-primary text-white rounded hover:bg-brand-primary/90"
                >
                    {confirmLabel}
                </button>
            </div>
        </BaseModal>
    );
}
```

**Usage**:
```typescript
const [showAlert, setShowAlert] = useState(false);

<AlertModal
    isOpen={showAlert}
    onClose={() => setShowAlert(false)}
    title="Success"
    message="Data berhasil disimpan!"
    type="success"
/>
```

---

### 3. ConfirmDialog (Yes/No Confirmations)

**File**: `components/ui/ConfirmDialog.tsx` (refactor existing)

**Purpose**: Confirm destructive or important actions with Yes/No choice.

**Props**:
```typescript
interface ConfirmDialogProps {
    isOpen: boolean;
    onClose: () => void;
    onConfirm: () => void | Promise<void>;
    title: string;
    message: string;
    confirmLabel?: string;
    cancelLabel?: string;
    variant?: 'danger' | 'warning' | 'default';
    requiresInput?: boolean;
    inputPlaceholder?: string;
    isLoading?: boolean;
}
```

**Implementation**:
```typescript
import { BaseModal } from './BaseModal';
import { useState } from 'react';

export function ConfirmDialog({
    isOpen,
    onClose,
    onConfirm,
    title,
    message,
    confirmLabel = 'Confirm',
    cancelLabel = 'Cancel',
    variant = 'default',
    requiresInput = false,
    inputPlaceholder = 'Type to confirm',
    isLoading = false
}: ConfirmDialogProps) {
    const [inputValue, setInputValue] = useState('');
    
    const handleConfirm = async () => {
        await onConfirm();
        setInputValue('');
        onClose();
    };
    
    const variantStyles = {
        danger: 'bg-red-600 hover:bg-red-700',
        warning: 'bg-yellow-600 hover:bg-yellow-700',
        default: 'bg-brand-primary hover:bg-brand-primary/90'
    };
    
    const canConfirm = !requiresInput || inputValue.toLowerCase() === inputPlaceholder.toLowerCase();
    
    return (
        <BaseModal isOpen={isOpen} onClose={onClose} title={title} size="sm">
            <div className="space-y-4">
                <p className="text-gray-600">{message}</p>
                
                {requiresInput && (
                    <input
                        type="text"
                        value={inputValue}
                        onChange={(e) => setInputValue(e.target.value)}
                        placeholder={inputPlaceholder}
                        className="w-full border rounded px-3 py-2"
                    />
                )}
            </div>
            
            <div className="mt-6 flex justify-end space-x-3">
                <button
                    onClick={onClose}
                    disabled={isLoading}
                    className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-50"
                >
                    {cancelLabel}
                </button>
                <button
                    onClick={handleConfirm}
                    disabled={isLoading || !canConfirm}
                    className={`px-4 py-2 text-white rounded disabled:opacity-50 ${variantStyles[variant]}`}
                >
                    {isLoading ? 'Processing...' : confirmLabel}
                </button>
            </div>
        </BaseModal>
    );
}
```

**Usage**:
```typescript
const [showConfirm, setShowConfirm] = useState(false);

<ConfirmDialog
    isOpen={showConfirm}
    onClose={() => setShowConfirm(false)}
    onConfirm={handleDelete}
    title="Delete Account"
    message="This action cannot be undone. All your data will be permanently deleted."
    confirmLabel="Delete"
    cancelLabel="Cancel"
    variant="danger"
    requiresInput={true}
    inputPlaceholder="HAPUS"
/>
```

---

### 4. FormModal (Complex Forms)

**File**: `components/ui/FormModal.tsx` (merge 3 admin copies)

**Purpose**: Display forms with validation, submit/cancel buttons.

**Props**:
```typescript
interface FormModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (e: React.FormEvent) => void | Promise<void>;
    title: string;
    description?: string;
    children: ReactNode;
    submitLabel?: string;
    cancelLabel?: string;
    isSubmitting?: boolean;
    maxWidth?: 'sm' | 'md' | 'lg' | 'xl' | '2xl';
}
```

**Implementation**:
```typescript
import { BaseModal } from './BaseModal';
import { ReactNode } from 'react';

export function FormModal({
    isOpen,
    onClose,
    onSubmit,
    title,
    description,
    children,
    submitLabel = 'Save',
    cancelLabel = 'Cancel',
    isSubmitting = false,
    maxWidth = 'lg'
}: FormModalProps) {
    return (
        <BaseModal 
            isOpen={isOpen} 
            onClose={onClose} 
            title={title}
            size={maxWidth}
            showCloseButton={true}
        >
            {description && (
                <p className="text-sm text-gray-600 mb-4">{description}</p>
            )}
            
            <form onSubmit={onSubmit}>
                <div className="space-y-4">
                    {children}
                </div>
                
                <div className="mt-6 flex justify-end space-x-3">
                    <button
                        type="button"
                        onClick={onClose}
                        disabled={isSubmitting}
                        className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-50"
                    >
                        {cancelLabel}
                    </button>
                    <button
                        type="submit"
                        disabled={isSubmitting}
                        className="px-4 py-2 bg-brand-primary text-white rounded hover:bg-brand-primary/90 disabled:opacity-50"
                    >
                        {isSubmitting ? 'Saving...' : submitLabel}
                    </button>
                </div>
            </form>
        </BaseModal>
    );
}
```

**Usage**:
```typescript
const [isOpen, setIsOpen] = useState(false);
const [data, setData] = useState({ name: '', email: '' });
const [isSubmitting, setIsSubmitting] = useState(false);

const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
        await createUser(data);
        toast.success('User created!');
        setIsOpen(false);
    } catch (error) {
        toast.error('Failed to create user');
    } finally {
        setIsSubmitting(false);
    }
};

<FormModal
    isOpen={isOpen}
    onClose={() => setIsOpen(false)}
    onSubmit={handleSubmit}
    title="Create User"
    description="Fill in the details to create a new user."
    isSubmitting={isSubmitting}
>
    <div>
        <label htmlFor="name" className="block text-sm font-medium mb-1">
            Name
        </label>
        <input
            id="name"
            type="text"
            value={data.name}
            onChange={e => setData({ ...data, name: e.target.value })}
            className="w-full border rounded px-3 py-2"
            required
        />
    </div>
    
    <div>
        <label htmlFor="email" className="block text-sm font-medium mb-1">
            Email
        </label>
        <input
            id="email"
            type="email"
            value={data.email}
            onChange={e => setData({ ...data, email: e.target.value })}
            className="w-full border rounded px-3 py-2"
            required
        />
    </div>
</FormModal>
```

---

## Migration Guide

### Phase 1: Create Base Components (2 hours)

**Step 1.1: Create BaseModal** (1 hour)

```bash
# Create file
touch resources/js/components/ui/BaseModal.tsx
```

Copy implementation from section "1. BaseModal" above.

**Testing**:
```bash
# Run TypeScript check
cd Kolabri-client-app
npx tsc --noEmit

# Test in browser with Playwright (optional)
npm run test:e2e
```

**Step 1.2: Create Specialized Components** (1 hour)

```bash
# Create files
touch resources/js/components/ui/AlertModal.tsx
touch resources/js/components/ui/FormModal.tsx
# ConfirmDialog.tsx already exists, will refactor
```

Copy implementations from sections above.

---

### Phase 2: Merge Duplicate Admin FormModal (2 hours)

**Step 2.1: Remove Duplicate Definitions**

Replace local FormModal in 3 files:

**File 1**: `admin/user-management.tsx`
```typescript
// REMOVE lines 135-185 (local FormModal definition)

// ADD import at top
import { FormModal } from '@/components/ui/FormModal';

// UPDATE usage (no changes needed, props compatible)
<FormModal
    isOpen={showCreateModal}
    onClose={() => setShowCreateModal(false)}
    title="Create User"
    description="..."
    onSubmit={handleCreate}
    isSubmitting={isSubmitting}
>
    {/* form fields */}
</FormModal>
```

**File 2**: `admin/master-data.tsx`
```typescript
// REMOVE lines 240-290 (local FormModal definition)

// ADD import
import { FormModal } from '@/components/ui/FormModal';

// UPDATE usage
<FormModal
    isOpen={showCreateCourseModal}
    onClose={() => setShowCreateCourseModal(false)}
    title="Create Course"
    maxWidth="lg"  // Now supported!
    onSubmit={handleCreateCourse}
>
    {/* form fields */}
</FormModal>
```

**File 3**: `admin/ai-settings.tsx`
```typescript
// REMOVE lines 124-174 (local FormModal definition)

// ADD import
import { FormModal } from '@/components/ui/FormModal';

// UPDATE usage
<FormModal
    isOpen={showCreateModal}
    onClose={closeCreateModal}
    title="Add AI Provider"
    maxWidth="2xl"  // Now supported!
    onSubmit={handleCreate}
>
    {/* form fields */}
</FormModal>
```

**Step 2.2: Verify No Regressions**

```bash
# TypeScript check
npx tsc --noEmit

# Test each admin page manually
npm run dev
# Navigate to /admin/user-management
# Navigate to /admin/master-data
# Navigate to /admin/ai-settings
# Verify modals open/close, forms submit correctly
```

---

### Phase 3: Add Accessibility to Existing Components (4 hours)

**Step 3.1: Refactor ConfirmDialog** (1 hour)

Update existing `components/ui/ConfirmDialog.tsx`:

```typescript
// REPLACE entire file with new implementation using BaseModal
import { BaseModal } from './BaseModal';

// Copy implementation from section "3. ConfirmDialog" above
```

**Step 3.2: Refactor GlobalSearchModal** (1 hour)

Update `components/ui/GlobalSearchModal.tsx`:

```typescript
// ADD at top
import { BaseModal } from './BaseModal';

// WRAP modal content with BaseModal instead of inline fixed positioning
export function GlobalSearchModal({ open, onClose, ... }) {
    return (
        <BaseModal
            isOpen={open}
            onClose={onClose}
            title="Search"
            size="xl"
        >
            {/* existing search content */}
        </BaseModal>
    );
}
```

**Step 3.3: Refactor KeyboardShortcutsHelpModal** (1 hour)

Update `components/ui/KeyboardShortcutsHelpModal.tsx`:

```typescript
import { BaseModal } from './BaseModal';

export function KeyboardShortcutsHelpModal({ open, onClose, shortcuts }) {
    return (
        <BaseModal
            isOpen={open}
            onClose={onClose}
            title="Keyboard Shortcuts"
            size="lg"
        >
            {/* existing shortcuts list */}
        </BaseModal>
    );
}
```

**Step 3.4: Refactor SessionSummaryModal & TemplateModal** (1 hour)

Similar pattern for both:

```typescript
import { BaseModal } from './BaseModal';

export function SessionSummaryModal({ onClose, ... }) {
    return (
        <BaseModal
            isOpen={true}
            onClose={onClose}
            title="Session Summary"
            size="lg"
        >
            {/* existing content */}
        </BaseModal>
    );
}
```

---

### Phase 4: Extract Inline Modals (Optional, 6 hours)

**Priority Extractions**:

1. **ImagePreviewModal** from `student/chat/room.tsx` (1h)
2. **DateRangeModal** from `admin/dashboard.tsx` (1h)
3. Replace inline modals in `lecturer/ai-settings.tsx` with FormModal (1h)
4. Replace inline modals in `admin/templates.tsx` with FormModal (1h)
5. Update remaining inline modals in student pages (2h)

---

## Testing Checklist

### Automated Tests

```typescript
// __tests__/components/ui/BaseModal.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { BaseModal } from '@/components/ui/BaseModal';

describe('BaseModal', () => {
    it('renders when open', () => {
        render(<BaseModal isOpen={true} onClose={jest.fn()} title="Test">Content</BaseModal>);
        expect(screen.getByText('Test')).toBeInTheDocument();
    });
    
    it('closes on ESC key', () => {
        const onClose = jest.fn();
        render(<BaseModal isOpen={true} onClose={onClose} title="Test">Content</BaseModal>);
        fireEvent.keyDown(screen.getByRole('dialog'), { key: 'Escape' });
        expect(onClose).toHaveBeenCalled();
    });
    
    it('has proper ARIA attributes', () => {
        render(<BaseModal isOpen={true} onClose={jest.fn()} title="Test">Content</BaseModal>);
        const dialog = screen.getByRole('dialog');
        expect(dialog).toHaveAttribute('aria-modal', 'true');
        expect(dialog).toHaveAttribute('aria-labelledby', 'modal-title');
    });
    
    it('traps focus within modal', () => {
        // Test focus trap logic
    });
});
```

### Manual Testing

**Keyboard Navigation**:
- [ ] Tab cycles through focusable elements
- [ ] Shift+Tab cycles backwards
- [ ] First element focused on open
- [ ] ESC closes modal
- [ ] Focus returns to trigger on close

**Screen Reader** (use NVDA/JAWS/VoiceOver):
- [ ] Announces "dialog" role
- [ ] Reads modal title
- [ ] Announces buttons clearly
- [ ] No content behind modal is read

**Mouse Interaction**:
- [ ] Backdrop click closes modal
- [ ] Close button works
- [ ] Form submission works
- [ ] Cancel button works

**Visual**:
- [ ] Animations smooth (scale + opacity)
- [ ] Backdrop blur visible
- [ ] Z-index correct (modal above content)
- [ ] Responsive on mobile (fits screen)

---

## Timeline & Estimates

### Phase 1: Create Base Components
- BaseModal: 1 hour
- AlertModal + FormModal: 1 hour
- **Total**: 2 hours

### Phase 2: Merge Admin FormModal
- Remove duplicates: 1 hour
- Test & verify: 1 hour
- **Total**: 2 hours

### Phase 3: Add Accessibility
- ConfirmDialog: 1 hour
- GlobalSearchModal: 1 hour
- KeyboardShortcutsHelpModal: 1 hour
- SessionSummary + Template: 1 hour
- **Total**: 4 hours

### Phase 4: Extract Inline (Optional)
- ImagePreviewModal: 1 hour
- DateRangeModal: 1 hour
- Other inline modals: 4 hours
- **Total**: 6 hours

### Testing & Documentation
- Automated tests: 1 hour
- Manual testing: 1 hour
- **Total**: 2 hours

---

## **GRAND TOTAL**: 10 hours (Phases 1-3) or 16 hours (all phases)

---

## Success Criteria

✅ All 25+ modals use BaseModal or specialized components  
✅ No duplicate modal definitions  
✅ All modals WCAG AA compliant  
✅ Keyboard navigation works everywhere  
✅ Screen reader announces properly  
✅ Focus management correct  
✅ Automated tests pass  
✅ Manual testing complete  

---

## Rollback Plan

If issues arise:
1. Keep old implementations in `_deprecated/` folder
2. Feature flag: `USE_NEW_MODALS=true/false`
3. Gradual rollout: Enable per page/feature
4. Monitor errors via Sentry

---

**End of Implementation Guide**  
**Last Updated**: 14 Juni 2026  
**Next Review**: After Phase 1 completion

