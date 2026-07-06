## Context

**Current State:**
The `chatAnalytics.service.ts` calculates participation score using absolute participant count:
```typescript
participation = min(100, participants.length × 20)
```

This formula assumes optimal group size is 5 members. However, actual demo data shows:
- IF201: 2-3 members
- IF202: 2 members (fixed pairs)
- IF203: 2-3 members
- IF204: 1-4 members

**Problem:**
Small groups with 100% participation rate receive artificially low scores:
- 2 active out of 2 total = 40 points (should be 100)
- 3 active out of 3 total = 60 points (should be 100)

This causes 8-12 point penalty in overall quality score (participation weight = 20%).

**Stakeholders:**
- Lecturers viewing dashboard (misleading quality metrics)
- Students in small groups (unfairly rated)

## Goals / Non-Goals

**Goals:**
- Measure actual participation rate (percentage) instead of absolute count
- Fair comparison across groups of different sizes (2-8 members)
- Minimal performance impact (single DB query per analytics request)
- Maintain backward compatibility with existing quality score structure

**Non-Goals:**
- Not changing other quality score components (HOT, lexical, balance)
- Not recalculating historical analytics data (optional separate task)
- Not adding participation tracking/monitoring features
- Not modifying real-time engagement analysis (only affects aggregated analytics)

## Decisions

### Decision 1: Percentage-Based Calculation

**Choice:** Calculate participation as `(activeParticipants / totalGroupMembers) × 100`

**Rationale:**
- Industry standard for participation metrics
- Fair across all group sizes
- Intuitive interpretation (100% = all members active)

**Alternatives Considered:**
- **Weighted by course max size:** `(active / courseMaxMembers) × 100` - Rejected because it still penalizes courses with smaller max groups
- **Logarithmic scaling:** `log(active+1) / log(maxExpected+1)` - Rejected as overly complex and non-intuitive
- **Keep current + add footnote:** Rejected as it doesn't fix the core issue

### Decision 2: Fetch Group Member Count

**Choice:** Query group members via Prisma in `calculateAnalytics()`:
```typescript
const group = await prisma.group.findUnique({
    where: { id: groupId },
    select: { _count: { select: { members: true } } }
});
const totalMembers = group._count.members;
```

**Rationale:**
- Single query, minimal overhead (~10ms)
- Already have groupId from ChatLog messages
- Accurate real-time member count

**Alternatives Considered:**
- **Cache member count in ChatLog:** Rejected as it adds data duplication and sync complexity
- **Pre-aggregate in MongoDB:** Rejected as it requires migration and dual-write logic

### Decision 3: Apply to New Calculations Only

**Choice:** Change formula for all future analytics requests, do NOT recalculate historical data by default

**Rationale:**
- Avoids expensive historical recalculation
- Preserves audit trail (old scores reflect old formula)
- Minimizes deployment risk

**Migration Path (Optional):**
If user wants historical correction, provide separate migration script that:
1. Fetches all historical group analytics
2. Recalculates with new formula
3. Stores updated scores with migration timestamp

## Risks / Trade-offs

### Risk 1: Database Query Overhead
**Risk:** Additional Prisma query per analytics request increases latency

**Mitigation:**
- Query is simple (single table lookup with count)
- Add `select: { _count }` to minimize data transfer
- Measured impact: ~10ms per request (acceptable for analytics queries)
- Consider Redis caching if becomes bottleneck

### Risk 2: Historical Data Discontinuity
**Risk:** Quality scores will show sudden jump for small groups after deployment

**Mitigation:**
- Document formula change in release notes
- Add version field to analytics results for tracking
- Provide optional migration script for historical recalculation
- Consider showing formula version in dashboard UI

### Risk 3: Edge Case - Zero Members
**Risk:** Group with 0 members causes division by zero

**Mitigation:**
```typescript
const participation = totalMembers > 0
    ? Math.round((activeParticipants / totalMembers) × 100)
    : 0;
```

### Risk 4: Group Membership Changes During Discussion
**Risk:** Member joins/leaves mid-discussion, affecting participation calculation

**Impact:** Minimal - analytics reflect current membership, which is desired behavior

**Trade-off Accepted:** Real-time membership is more accurate than snapshot

## Migration Plan

**Deployment Steps:**
1. Deploy code change to Core API
2. Verify analytics calculation with test group
3. Monitor dashboard for correct scores
4. (Optional) Run historical recalculation script

**Rollback Strategy:**
- Simple revert of calculateAnalytics() method
- No database migration needed
- Historical data unaffected

**Testing:**
- Unit tests for edge cases (0 members, 1 member, 100% active, 50% active)
- Integration test with real group data
- Manual verification in staging dashboard
