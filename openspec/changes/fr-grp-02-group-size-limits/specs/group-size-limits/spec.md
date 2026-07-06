## ADDED Requirements

### Requirement: Lecturer can configure course group size limits
The system SHALL allow a lecturer to define minimum and maximum members per group for each course that uses student groups.

#### Scenario: Lecturer saves valid member limits
- **WHEN** a lecturer sets a minimum member count greater than or equal to 1 and a maximum member count greater than or equal to the minimum
- **THEN** the system saves the limits for that course and applies them to subsequent group operations

#### Scenario: Lecturer views current course group policy
- **WHEN** a lecturer opens the relevant course or group management settings
- **THEN** the system shows the configured minimum and maximum members per group for that course

### Requirement: Student group creation and membership changes must respect course limits
The system SHALL reject any group creation, join, or invitation-based membership change that would violate the configured course group size limits.

#### Scenario: Student creates group within allowed range
- **WHEN** a student creates a group under a course whose configured limits permit the resulting group size
- **THEN** the system allows the group to be created

#### Scenario: Student cannot join a full group
- **WHEN** a student attempts to join a group whose current member count already equals the configured maximum
- **THEN** the system rejects the request and returns an error explaining that the group has reached its member limit

#### Scenario: Membership change cannot reduce group below minimum
- **WHEN** a membership removal or leave action would cause a group to fall below the configured minimum
- **THEN** the system rejects the action and returns feedback that the group would fall below the configured minimum member count

### Requirement: Users must see applicable group size rules before acting
The system SHALL display the allowed group size range in relevant student and lecturer group workflows before users attempt membership actions.

#### Scenario: Student sees allowed group size before joining
- **WHEN** a student opens a course group selection or join flow
- **THEN** the system shows the minimum and maximum members allowed for groups in that course

#### Scenario: Validation message references course policy
- **WHEN** a group action is rejected because of course member limits
- **THEN** the system returns feedback that states the allowed minimum and maximum member counts
