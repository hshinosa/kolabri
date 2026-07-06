# lecturer-unified-materials Specification

## Purpose

Single lecturer hub on course detail for all course files, week assignment, and AI vector readiness — replacing separate Materials tab, Minggu tab, and Basis Pengetahuan upload section.

## Requirements

### Requirement: Lecturer uses one Materi hub on course detail

The system SHALL provide a single lecturer tab labeled Materi on course detail that combines upload, a flat list of all course materials, course week management, week assignment, and per-file knowledge-base vector status. The system MUST NOT require separate Materials and Minggu tabs or a separate Basis Pengetahuan upload section for the standard workflow.

#### Scenario: Upload appears in unified list

- **WHEN** lecturer uploads a file from the Materi hub
- **THEN** the file appears in the course material list in that hub without navigating to another tab or section

#### Scenario: Assign from same hub

- **WHEN** lecturer assigns a material to a course week from the Materi hub
- **THEN** the material appears on that week's card in the same hub and is removed from the unassigned-to-week pool list (while remaining the same `course_materials` record)

### Requirement: Per-file vector status with stable join key

The Materi hub SHALL display vector status per material row using `course_material_id` from knowledge-base API responses. The hub SHALL refresh status automatically while any linked row is `pending` or `processing`, without a full page reload.

#### Scenario: Status after upload

- **WHEN** lecturer uploads a material and server queues knowledge-base ingest
- **THEN** the row shows a non-ready status until processing completes or fails

#### Scenario: Polling stops when idle

- **WHEN** no knowledge-base rows for the course are in `pending` or `processing`
- **THEN** the hub stops periodic status polling

### Requirement: Single upload path for class materials and AI ingest

The default lecturer workflow SHALL upload through Laravel `course_materials` only. The system SHALL queue knowledge-base processing for that upload via internal core-api without requiring a second upload through a legacy batch Basis Pengetahuan form on the course page.

#### Scenario: No duplicate upload

- **WHEN** lecturer adds a file only through the Materi hub
- **THEN** the lecturer is not required to upload the same file again via a separate Basis Pengetahuan section for ingest to be queued

### Requirement: All course materials visible without module navigation

The Materi hub SHALL list all course materials for the course in a flat list, including materials previously stored under material modules. The hub SHALL NOT require module folder CRUD as part of the default layout.

#### Scenario: Former module material visible

- **WHEN** a material exists with a non-null `module_id` and no week assignment
- **THEN** it appears in the Materi hub unassigned pool list

### Requirement: Basis Pengetahuan section removed from course detail page

The lecturer course detail page SHALL NOT render a standalone Basis Pengetahuan upload and file list section below the course tabs once the Materi hub is available.

#### Scenario: No duplicate surface

- **WHEN** lecturer views course detail after unified Materi is shipped
- **THEN** there is no second file upload form dedicated to knowledge-base batch upload on the same page outside the Materi tab
