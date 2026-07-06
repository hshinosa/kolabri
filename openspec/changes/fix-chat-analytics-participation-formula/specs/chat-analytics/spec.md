## ADDED Requirements

### Requirement: Participation Score Calculation
The chat analytics service SHALL calculate participation score as the percentage of active group members relative to total group membership.

The formula SHALL be:
```
participation_score = (active_participants / total_group_members) × 100
```

Where:
- `active_participants`: Count of unique participants who sent messages in the discussion
- `total_group_members`: Total count of members in the group (from Group.members relation)
- Result SHALL be rounded to nearest integer
- Result SHALL be capped at 100 (maximum score)

#### Scenario: All members active in small group
- **WHEN** a group has 2 total members and 2 active participants
- **THEN** participation score SHALL be 100

#### Scenario: All members active in medium group
- **WHEN** a group has 5 total members and 5 active participants
- **THEN** participation score SHALL be 100

#### Scenario: Partial participation
- **WHEN** a group has 8 total members and 4 active participants
- **THEN** participation score SHALL be 50

#### Scenario: Single active member
- **WHEN** a group has 3 total members and 1 active participant
- **THEN** participation score SHALL be 33 (rounded from 33.33)

#### Scenario: Zero members edge case
- **WHEN** a group has 0 total members (edge case)
- **THEN** participation score SHALL be 0 to prevent division by zero

### Requirement: Group Member Count Retrieval
The system SHALL retrieve total group member count from the database when calculating analytics.

The query SHALL:
- Fetch from the Group table using groupId
- Count members via the Group.members relation
- Use Prisma's `_count` for efficient counting
- Execute as a single query per analytics request

#### Scenario: Fetch member count for analytics
- **WHEN** calculating analytics for a group
- **THEN** system SHALL query Group.members._count once per analytics calculation

#### Scenario: Member count matches current membership
- **WHEN** members are added or removed from a group
- **THEN** subsequent analytics calculations SHALL reflect the updated member count

### Requirement: Quality Score Integration
The participation score SHALL integrate into the overall quality score calculation using existing weight of 20%.

The quality score formula SHALL remain:
```
quality_score = (hot_percentage × 0.35) + (lexical_variety × 0.25) + (participation_score × 0.20) + (balance_score × 0.20)
```

#### Scenario: Quality score with new participation calculation
- **WHEN** a small group (2 members, 2 active) has HOT 70%, lexical 60, balance 80
- **THEN** quality score SHALL be approximately 76 (was 64 with old formula)

#### Scenario: Quality score with partial participation
- **WHEN** a large group (8 members, 4 active) has HOT 70%, lexical 60, balance 80
- **THEN** quality score SHALL be approximately 66 (participation contributes 10 points)

### Requirement: Backward Compatibility
The system SHALL maintain existing quality score structure and API response format.

The change SHALL:
- NOT modify other quality score components (HOT, lexical, balance)
- NOT change the ChatAnalyticsResult interface
- NOT require changes to dashboard UI code
- Apply to all new analytics requests immediately after deployment

#### Scenario: API response format unchanged
- **WHEN** calling getGroupAnalytics() after the change
- **THEN** response structure SHALL match existing GroupAnalyticsResult interface

#### Scenario: Historical data preservation
- **WHEN** analytics were calculated before deployment
- **THEN** stored scores SHALL remain unchanged (no automatic recalculation)
