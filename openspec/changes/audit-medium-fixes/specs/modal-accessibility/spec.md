## ADDED Requirements

### Requirement: BaseModal MUST implement full accessibility

The BaseModal component SHALL implement focus trap, ESC key handler, aria attributes, overlay click, and body scroll lock for WCAG AA compliance.

#### Scenario: Modal opens with focus trap
- **WHEN** BaseModal opens (isOpen transitions to true)
- **THEN** focus moves to first focusable element inside modal
- **AND** Tab key cycles only through focusable elements within modal
- **AND** Shift+Tab cycles backward through focusable elements
- **AND** focus cannot escape modal boundaries

#### Scenario: ESC key closes modal
- **WHEN** modal is open and user presses ESC key
- **THEN** modal closes (onClose callback fires)
- **AND** focus returns to element that triggered modal open

#### Scenario: Modal has correct ARIA attributes
- **WHEN** BaseModal renders
- **THEN** container has role="dialog"
- **AND** container has aria-modal="true"
- **AND** container has aria-labelledby pointing to title element
- **AND** title element has unique ID matching aria-labelledby

#### Scenario: Overlay click closes modal (configurable)
- **WHEN** closeOnOverlayClick is true (default)
- **AND** user clicks overlay background
- **THEN** modal closes
- **WHEN** closeOnOverlayClick is false
- **AND** user clicks overlay background
- **THEN** modal remains open

#### Scenario: Body scroll is locked when modal open
- **WHEN** modal opens
- **THEN** body element has overflow: hidden applied
- **AND** background page cannot scroll
- **WHEN** modal closes
- **THEN** body overflow is restored to original value

#### Scenario: Focus returns to trigger on close
- **WHEN** modal closes (any method)
- **THEN** focus returns to the element that opened the modal
- **AND** user can continue keyboard navigation from trigger point

---

### Requirement: Specialized modal components MUST extend BaseModal

AlertModal, ConfirmDialog, and FormModal SHALL extend BaseModal with specialized behavior for common patterns.

#### Scenario: AlertModal shows information with single action
- **WHEN** AlertModal is used with message and action button
- **THEN** modal displays title, message text, and single button
- **AND** button closes modal on click
- **AND** focus is on button when modal opens

#### Scenario: ConfirmDialog has dual action with danger variant
- **WHEN** ConfirmDialog is used with confirm/cancel actions
- **THEN** modal displays title, message, cancel button, confirm button
- **AND** confirm button supports danger variant (red styling)
- **AND** ESC closes (same as cancel)

#### Scenario: FormModal handles form submission
- **WHEN** FormModal contains a form with validation
- **THEN** modal displays form fields, cancel button, submit button
- **AND** submit button disabled during submission (loading state)
- **AND** modal closes on successful submission
- **AND** modal stays open on validation error (shows errors inline)

#### Scenario: All specialized modals inherit accessibility
- **WHEN** any specialized modal renders
- **THEN** focus trap, ESC handler, aria attributes all inherited from BaseModal
- **AND** no accessibility features need to be re-implemented

---

### Requirement: Existing modals MUST be refactored to use accessible components

All 25+ existing modal implementations SHALL be replaced with accessible shared components. Before building new components, audit existing shared modals (`ConfirmDialog.tsx`, `GlobalSearchModal.tsx`, `DocumentViewerModal.tsx`, `SessionSummaryModal.tsx`, `KeyboardShortcutsHelpModal.tsx`) and reuse/extend patterns where possible.

#### Scenario: Existing shared modals are audited first
- **WHEN** reviewing modal components
- **THEN** existing shared modals are cataloged
- **AND** their accessibility gaps are identified
- **AND** decision is made to extend or replace each

#### Scenario: Admin FormModal duplicates consolidated
- **WHEN** reviewing admin section modals
- **THEN** 3 duplicate FormModal copies replaced with single shared FormModal
- **AND** all admin forms use shared accessible FormModal component

#### Scenario: Simple alert modals use AlertModal
- **WHEN** existing modal only shows message + OK button
- **THEN** replaced with AlertModal component
- **AND** accessibility features inherited automatically

#### Scenario: Confirmation dialogs use ConfirmDialog
- **WHEN** existing modal asks "Are you sure?" with Yes/No
- **THEN** replaced with ConfirmDialog component (migrating existing `ConfirmDialog.tsx` to use BaseModal)
- **AND** danger actions use danger variant

#### Scenario: Complex modals use BaseModal directly
- **WHEN** existing modal has complex custom content
- **THEN** wrapped in BaseModal with accessible attributes
- **AND** custom content renders inside BaseModal body

---

### Requirement: Modal accessibility MUST be verifiable

Accessibility SHALL be testable through automated tools and manual keyboard testing.

#### Scenario: axe-core reports zero modal violations
- **WHEN** axe-core scans page with open modal
- **THEN** zero accessibility violations related to modal
- **AND** zero violations for focus management, ARIA attributes

#### Scenario: Keyboard-only navigation works
- **WHEN** user navigates with Tab, Enter, ESC only (no mouse)
- **THEN** can open modal, interact with all controls, close modal
- **AND** focus is always visible and logical

#### Scenario: Screen reader announces modal correctly
- **WHEN** screen reader user opens modal
- **THEN** screen reader announces: "dialog, [title], modal"
- **AND** can navigate content within modal
- **AND** screen reader does not read background content
