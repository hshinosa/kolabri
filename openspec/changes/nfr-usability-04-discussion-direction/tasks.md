## Status

**P0 gate:** `docs/p0-release-gate.md`. Checkbox = implementasi di repo + smoke API (2026-06-12). UI manual: `docs/smoke-tests/nfr-usability-04-p0.md`.

## 1. Data Model & AI Service

- [x] 1.1 `isRelevant` on message model (`ChatLog`, socket)
- [x] 1.2 Classify endpoint — AI `/api/classify-relevance`, core `DiscussionDirectionService`
- [x] 1.3 Session summary — AI `/api/session-summary`, core `generateSessionSummary`
- [x] 1.4 Debounced batch classify on send (socket / discussion-direction)
- [x] 1.5 Fallback `isRelevant = true` on classify failure

## 2. Discussion Progress Indicator

- [x] 2.1 `DiscussionProgressBar`
- [x] 2.2 Progress from relevant/total
- [x] 2.3 Hide without learning goal
- [x] 2.4 Reactive updates

## 3. Goal Alignment Badge

- [x] 3.1 `RelevanceBadge`
- [x] 3.2 Badge on message row
- [x] 3.3 Header aggregate counts
- [x] 3.4 Hide without goal

## 4. Session Summary on Close

- [x] 4.1 `SessionSummaryModal`
- [x] 4.2 Summary on close
- [x] 4.3 Modal after generation
- [x] 4.4 Persist summary
- [x] 4.5 View summary on closed session

## 5. Discussion Health

- [x] 5.1–5.6 `discussion-health.service`, `HealthScoreCard`, lecturer API

## 6. Dashboard Integration

- [x] 6.1–6.4 `DiscussionHealthWidget`
- [ ] 6.5 Real-time stream on widget — confirm in manual smoke (polling OK for P0 if documented)

## P0 verification

- [x] `run-smoke-checklist.sh`: discussion-health + classify-relevance
- [ ] Manual sections in `nfr-usability-04-p0.md`
