## ADDED Requirements

### Requirement: REST chat message operations MUST validate group membership

REST API chat message operations (search, pin, unpin, topic) SHALL verify that the requesting user is a member of the group associated with the message's chat space. Note: Socket.IO already validates room membership (`socket.rooms.has(roomId)`) and sender ownership for delete.

#### Scenario: Pin message succeeds for group member via REST
- **WHEN** authenticated user is a member of the group owning the chat space
- **AND** requests to pin a message via REST API
- **THEN** assertChatMembership middleware validates group membership via Mongoose populate
- **AND** allows pin operation to proceed
- **AND** returns 200 success with updated message

#### Scenario: Pin message fails for non-member with 403 via REST
- **WHEN** authenticated user is NOT a member of the group
- **AND** attempts to pin a message via REST API
- **THEN** assertChatMembership middleware detects user is not in group.members
- **AND** rejects request with 403 Forbidden
- **AND** error message: "Not authorized to access this chat"

#### Scenario: Search messages validates group membership via REST
- **WHEN** user searches messages within a chat space via REST API
- **THEN** assertChatMembership loads ChatLog with chatSpaceId.groupId.members populate
- **AND** verifies requesting userId exists in members list
- **AND** returns 403 if user not a member

#### Scenario: Unpin message validates group membership via REST
- **WHEN** user attempts to unpin a message via REST API
- **THEN** assertChatMembership validates user is group member before unpinning
- **AND** rejects with 403 if not a member

#### Scenario: Socket.IO delete message already validates ownership (EXISTING)
- **WHEN** user deletes a message via Socket.IO
- **THEN** system checks `socket.rooms.has(roomId)` (room membership)
- **AND** checks `message.senderId !== socket.user.userId` (ownership)
- **AND** no additional changes needed

---

### Requirement: Reflection operations MUST validate ownership (verify existing)

Reflection read/write operations ALREADY verify ownership via `req.user.userId` and role-based access. This requirement verifies the existing implementation is comprehensive and adds authorization logging.

#### Scenario: Get reflection succeeds for owner (EXISTING)
- **WHEN** authenticated user requests reflection by goalId
- **AND** user owns the reflection (validated by getGoalReflections service)
- **THEN** system returns reflection data

#### Scenario: Get reflection fails for non-owner with 404 (EXISTING)
- **WHEN** authenticated user requests reflection by goalId
- **AND** reflection belongs to different user
- **THEN** service validates group membership and returns 404
- **AND** does NOT reveal that reflection exists for another user

#### Scenario: Unauthorized reflection access is logged (NEW)
- **WHEN** user attempts to access another user's reflection
- **THEN** security log records: requestingUserId, targetGoalId, timestamp, "unauthorized_reflection_access"
- **AND** monitoring system can detect probing patterns

---

### Requirement: Authorization checks MUST precede business logic

All authorization validation SHALL occur before executing business logic or database modifications.

#### Scenario: Authorization happens before message pin logic
- **WHEN** pin message request is processed
- **THEN** system validates group membership FIRST
- **AND** only proceeds to pin logic if authorized
- **AND** unauthorized requests exit early without DB queries

#### Scenario: Authorization happens before reflection update logic
- **WHEN** update reflection request is processed
- **THEN** system validates ownership FIRST
- **AND** only proceeds to update logic if authorized
- **AND** prevents processing of unauthorized requests

#### Scenario: Failed authorization does not trigger side effects
- **WHEN** authorization check fails (403 or 404)
- **THEN** no database writes occur
- **AND** no notifications sent
- **AND** no audit logs created for business logic
- **AND** only security audit log records unauthorized attempt

---

### Requirement: Authorization errors MUST be distinguishable for monitoring

Failed authorization attempts SHALL be logged separately from business logic errors for security monitoring.

#### Scenario: Unauthorized chat access is logged
- **WHEN** user attempts to access chat they're not a member of
- **THEN** security log records: userId, targetChatSpaceId, timestamp, "unauthorized_chat_access"
- **AND** monitoring system can detect patterns of abuse

#### Scenario: Unauthorized reflection access is logged
- **WHEN** user attempts to access another user's reflection
- **THEN** security log records: requestingUserId, targetGoalId, timestamp, "unauthorized_reflection_access"
- **AND** can detect if single user probing multiple reflections

#### Scenario: Repeated unauthorized attempts trigger alerts
- **WHEN** same user makes 10+ unauthorized access attempts in 5 minutes
- **THEN** monitoring system detects anomaly
- **AND** sends security alert to ops team
- **AND** includes user ID, target resources, attempt count

---

### Requirement: Authorization logic MUST be consistent across endpoints

All related operations SHALL use identical authorization logic to prevent bypass through endpoint inconsistencies.

#### Scenario: All chat operations use same membership check
- **WHEN** reviewing chat endpoints (pin, unpin, search, delete)
- **THEN** all use identical group membership validation code
- **AND** no endpoint has weaker checks than others

#### Scenario: All reflection operations use same ownership check
- **WHEN** reviewing reflection endpoints (get, update, delete)
- **THEN** all use identical userId ownership validation
- **AND** no endpoint bypasses ownership check

#### Scenario: Authorization middleware is reusable
- **WHEN** implementing authorization checks
- **THEN** shared function/middleware is used: `assertGroupMembership(userId, chatSpaceId)`
- **AND** shared function for reflections: `assertReflectionOwnership(userId, goalId)`
- **AND** reduces code duplication and inconsistency risk
