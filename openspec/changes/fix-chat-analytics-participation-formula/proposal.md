## Why

Current participation scoring formula unfairly penalizes small groups (2-3 members) by using absolute participant count instead of participation rate. Groups with 100% participation receive different scores based solely on group size, leading to misleading quality metrics and unfair comparisons in the lecturer dashboard.

## What Changes

- Change participation score calculation from absolute count (`participants × 20`) to percentage-based (`(active / total) × 100`)
- Retrieve actual group member count from database to calculate participation rate
- Update quality score formula to use proportional participation scoring
- Ensure fair comparison across groups of different sizes (2-8 members)

## Capabilities

### New Capabilities
<!-- None - this is a fix to existing capability -->

### Modified Capabilities
- `chat-analytics`: Participation scoring now measures actual participation rate (percentage of group members active) instead of absolute participant count, ensuring fairness across different group sizes

## Impact

**Code:**
- `Kolabri-core-api/src/services/chatAnalytics.service.ts` - `calculateAnalytics()` method (~line 300)
- Requires database query to fetch group member count

**Breaking Changes:**
- Quality scores will change for existing groups (especially small groups will see +8 to +12 point increase)
- Historical analytics comparisons may show discontinuity
- Recommend: Apply formula only to new calculations OR recalculate all historical data

**User Impact:**
- Lecturer dashboard will show corrected quality scores
- Small groups (2-3 members) no longer auto-penalized
- Fair comparison between different group sizes
