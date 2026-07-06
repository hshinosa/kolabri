# reading-recommendations Specification

## Purpose
TBD - created by archiving change course-weeks-discussion-readings. Update Purpose after archive.
## Requirements
### Requirement: Course-page reading recommendations remain separate from session week materials

The existing course-level reading recommendation capability (topic-based request on student course page) SHALL remain available as a distinct entry point. Session chat week materials and pre-read flows MUST NOT depend on that endpoint for listing assigned week materials.

#### Scenario: Session materials not from topic recommendation API

- **WHEN** student views pre-read or chat materials panel
- **THEN** materials are loaded from week assignment data, not from the topic-based reading recommendation response alone
