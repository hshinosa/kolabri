## ADDED Requirements

### Requirement: WebSocket errors MUST be logged with context

All WebSocket handler errors SHALL be logged with comprehensive context (user ID, operation type, error message, stack trace) instead of using empty catch blocks.

#### Scenario: AI activity tracking failure is logged
- **WHEN** AI Engine activity tracking call fails in WebSocket handler
- **THEN** error is logged with userId, activityType, error message, and stack trace
- **AND** log level is ERROR
- **AND** log includes timestamp for debugging

#### Scenario: AI intervention failure is logged
- **WHEN** AI Engine intervention call fails in WebSocket handler
- **THEN** error is logged with userId, interventionType, chatSpaceId, error details
- **AND** log level is ERROR
- **AND** monitoring system can alert on repeated failures

#### Scenario: Empty catch blocks are eliminated
- **WHEN** code review scans WebSocket handlers
- **THEN** zero empty catch blocks exist (catch () {} or catch(e) {})
- **AND** all error handlers include logging statements

---

### Requirement: Transient errors MUST trigger retry logic

Network errors and 5xx server errors from AI Engine SHALL trigger automatic retry with exponential backoff (single retry with 5s delay).

#### Scenario: Network timeout triggers retry
- **WHEN** AI Engine call fails with network timeout (ETIMEDOUT)
- **THEN** system waits 5 seconds
- **AND** retries the same operation once
- **AND** logs both attempts (original + retry)

#### Scenario: 503 Service Unavailable triggers retry
- **WHEN** AI Engine returns 503 status
- **THEN** system identifies error as retryable
- **AND** waits 5 seconds before retry
- **AND** logs retry attempt

#### Scenario: 4xx errors do NOT trigger retry
- **WHEN** AI Engine returns 400, 401, 403, or 404 status
- **THEN** system does NOT retry (client error, retry won't help)
- **AND** logs error as non-retryable
- **AND** emits failure event immediately

#### Scenario: Retry failure is logged separately
- **WHEN** retry attempt also fails
- **THEN** system logs final failure with "retry_failed" label
- **AND** does NOT attempt further retries
- **AND** emits monitoring event for alerting

---

### Requirement: Critical failures MUST notify users

When AI features fail after retry attempts, users SHALL receive visible notifications instead of silent degradation.

#### Scenario: Failed activity tracking shows user notification
- **WHEN** activity tracking fails after retry
- **THEN** WebSocket emits "ai_feature_error" event to client
- **AND** frontend displays toast notification: "AI tracking temporarily unavailable"
- **AND** user can continue working (graceful degradation)

#### Scenario: Failed intervention shows user notification
- **WHEN** AI intervention call fails after retry
- **THEN** WebSocket emits "intervention_error" event
- **AND** frontend displays notification: "AI suggestions temporarily unavailable"
- **AND** chat functionality remains operational

#### Scenario: Notification includes retry timestamp
- **WHEN** error notification is sent to user
- **THEN** message includes when system will retry (if applicable)
- **AND** user has visibility into system state

---

### Requirement: Error patterns MUST be monitorable

Logging SHALL enable monitoring, alerting, and root cause analysis for AI Engine integration issues.

#### Scenario: Error logs are structured for querying
- **WHEN** error is logged
- **THEN** log format is JSON with consistent fields
- **AND** includes: timestamp, userId, operation, errorType, errorMessage, retryAttempt
- **AND** log aggregation tools can parse and query

#### Scenario: Repeated failures trigger alerts
- **WHEN** same error occurs 10+ times in 5 minutes
- **THEN** monitoring system detects pattern
- **AND** sends alert to ops team
- **AND** includes error rate, affected users, failure details

#### Scenario: Success rate is measurable
- **WHEN** reviewing AI Engine integration health
- **THEN** logs enable calculation of success rate (successful / total attempts)
- **AND** can measure retry success rate
- **AND** can identify degradation trends

---

### Requirement: Retry strategy MUST be consistent

All AI Engine async operations SHALL use the same retry logic (single retry with 5s delay) for predictable behavior.

#### Scenario: Activity tracking uses standard retry
- **WHEN** activity tracking fails
- **THEN** retry logic: 5s delay, 1 retry, log both attempts

#### Scenario: Intervention tracking uses standard retry
- **WHEN** intervention tracking fails
- **THEN** retry logic: 5s delay, 1 retry, log both attempts

#### Scenario: File processing uses standard retry
- **WHEN** AI-powered file analysis fails
- **THEN** retry logic: 5s delay, 1 retry, log both attempts

#### Scenario: No exponential backoff for simplicity
- **WHEN** any AI Engine call retries
- **THEN** delay is fixed 5 seconds (not exponential)
- **AND** max retry count is 1 (not unbounded)
- **AND** behavior is predictable and bounded

---

### Requirement: Error context MUST preserve debugging information

Logged errors SHALL include sufficient context to reproduce and diagnose issues without access to production systems.

#### Scenario: Network error includes request details
- **WHEN** AI Engine network error is logged
- **THEN** log includes: endpoint URL, request method, timeout duration
- **AND** does NOT include sensitive data (API keys, tokens)

#### Scenario: Server error includes response details
- **WHEN** AI Engine returns 5xx error
- **THEN** log includes: status code, response body (truncated), headers (sanitized)
- **AND** stack trace shows calling function

#### Scenario: User context enables impact assessment
- **WHEN** error affects specific user action
- **THEN** log includes: userId, courseId (if applicable), chatSpaceId (if applicable)
- **AND** support team can identify affected users
- **AND** can assess blast radius of failures
