## ADDED Requirements

### Requirement: All failed API operations MUST show user notification

Every fetch/axios call with a console.error() catch handler SHALL additionally display a toast.error() notification visible to the user.

#### Scenario: Failed message send shows toast
- **WHEN** AI chat message send fails
- **THEN** console.error logs error for developer tools
- **AND** toast.error displays "Failed to send message. Please try again."
- **AND** toast auto-dismisses after 5 seconds

#### Scenario: Failed file upload shows toast
- **WHEN** file upload to knowledge base fails
- **THEN** toast.error displays "File upload failed. Please try again."
- **AND** user can retry the upload

#### Scenario: Failed save operation shows toast
- **WHEN** reflection save fails
- **THEN** toast.error displays "Failed to save reflection."
- **AND** unsaved data remains in form for retry

#### Scenario: Console error preserved for debugging
- **WHEN** any API call fails
- **THEN** console.error still logs full error object
- **AND** developers can inspect error in browser dev tools
- **AND** toast message is user-friendly (no stack traces)

---

### Requirement: Error messages MUST be user-friendly

Toast error messages SHALL be human-readable, contextual, and actionable.

#### Scenario: Error message references the operation
- **WHEN** displaying error toast
- **THEN** message identifies the failed operation (e.g., "send message", "upload file", "save reflection")
- **AND** does NOT show technical details (TypeError, HTTP 500, etc.)

#### Scenario: Error message includes retry guidance
- **WHEN** error is retryable (network error, timeout)
- **THEN** message includes "Please try again"
- **AND** user understands they can retry the action

#### Scenario: Error message for permanent failures
- **WHEN** error is not retryable (403 Forbidden, 404 Not Found)
- **THEN** message explains the situation: "You don't have permission" or "Item not found"
- **AND** does NOT suggest retrying

---

### Requirement: Loading states MUST accompany async operations

All operations that display error toasts SHALL also show loading indicators during execution.

#### Scenario: Button shows loading state during API call
- **WHEN** user clicks submit button that triggers API call
- **THEN** button shows loading spinner and is disabled
- **AND** button re-enables on success or failure

#### Scenario: Form fields disabled during submission
- **WHEN** form is being submitted
- **THEN** all input fields are disabled
- **AND** prevents double-submission

---

### Requirement: Toast notifications MUST not overwhelm users

Error toasts SHALL be configured to avoid notification fatigue.

#### Scenario: Toast auto-dismisses after 5 seconds
- **WHEN** error toast appears
- **THEN** toast automatically dismisses after 5000ms
- **AND** user can manually dismiss earlier via close button

#### Scenario: Duplicate toasts are not stacked
- **WHEN** same operation fails rapidly (user clicking retry)
- **THEN** previous toast is replaced (not stacked)
- **AND** only one error toast visible at a time per operation

#### Scenario: Success toasts are brief
- **WHEN** operation succeeds after previous failure
- **THEN** success toast (if shown) dismisses after 3 seconds
- **AND** does not linger
