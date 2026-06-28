# Kolabri Documentation Index

**Last updated:** 2026-06-28

Comprehensive documentation for the Kolabri collaborative learning platform.

**Note:** The docs/ directory was reorganized on 2026-06-28 for better navigation and maintainability.

---

## 📋 Reports

### Audits
Latest comprehensive system audits and evaluations.

| Document | Date | Scope |
|---|---|---|
| [`AUDIT_REPORT_FINAL.md`](../reports/audits/AUDIT_REPORT_FINAL.md) | 2026-06-28 | Final audit - Provider testing migration |
| [`ARCHITECTURE_AUDIT_2026-06-28.md`](../reports/audits/ARCHITECTURE_AUDIT_2026-06-28.md) | 2026-06-28 | Architecture review |
| [`CAPSTONE_AUDIT_REPORT_2026-06-28.md`](../reports/audits/CAPSTONE_AUDIT_2026-06-28.md) | 2026-06-28 | Capstone evaluation |
| [`audit-report-2026-05-25.md`](../reports/audits/audit-report-2026-05-25.md) | 2026-05-25 | Mid-project audit |
| [`openspec-audit.md`](../reports/audits/openspec-audit.md) | — | OpenSpec workflow audit |

### Implementation Reports
Feature implementation summaries and technical reports.

| Document | Scope | Status |
|---|---|---|
| [`IMPLEMENTATION_SUMMARY.md`](../reports/implementation/IMPLEMENTATION_SUMMARY.md) | Provider testing migration | ✅ Complete |
| [`PROVIDER_TESTING_MIGRATION.md`](../reports/implementation/PROVIDER_TESTING_MIGRATION.md) | Detailed migration guide | ✅ Complete |
| [`AI_ENGINE_IMPLEMENTATION_REPORT.md`](../reports/implementation/AI_ENGINE_IMPLEMENTATION_REPORT.md) | AI Engine - 2 OpenSpec changes | ✅ 2026-05-17 |
| [`CORE_API_IMPLEMENTATION_REPORT.md`](../reports/implementation/CORE_API_IMPLEMENTATION_REPORT.md) | Core API - 12 OpenSpec changes | ✅ 2026-05-17 |

### Code Inspections
Deep technical inspections of the codebase.

| Document | Date | Focus |
|---|---|---|
| [`FULL_INSPECTION_2026_05_17.md`](../reports/inspection/FULL_INSPECTION_2026_05_17.md) | 2026-05-17 | Full project snapshot |
| [`PROJECT_INSPECTION_REPORT.md`](../reports/inspection/PROJECT_INSPECTION_REPORT.md) | 2026-05-11 | Architecture overview |
| [`CODE_INSPECTION_REPORT.md`](../reports/inspection/CODE_INSPECTION_REPORT.md) | 2026-05-11 | 3 services deep dive |
| [`CORE_API_INSPECTION_DETAIL.md`](../reports/inspection/CORE_API_INSPECTION_DETAIL.md) | 2026-05-11 | Core API structure |
| [`PAGE_AUDIT_REPORT.md`](../reports/inspection/PAGE_AUDIT_REPORT.md) | — | Page-level audit |

---

## 🏗️ Architecture

| Document | Purpose |
|---|---|
| [`adr/`](../architecture/adr/) | Architecture Decision Records |
| [`architecture-decisions.md`](../architecture/architecture-decisions.md) | Key architectural decisions |
| [`AI_ENGINE_SCOPE_BOUNDARIES.md`](../architecture/AI_ENGINE_SCOPE_BOUNDARIES.md) | AI Engine development boundaries |
| [`CORE_API_SCOPE_BOUNDARIES.md`](../architecture/CORE_API_SCOPE_BOUNDARIES.md) | Core API development boundaries |
| [`CLIENT_APP_SCOPE_BOUNDARIES.md`](../architecture/CLIENT_APP_SCOPE_BOUNDARIES.md) | Client App development boundaries |
| [`implementation-patterns.md`](../architecture/implementation-patterns.md) | Common implementation patterns |

---

## 🎓 Thesis (TA) Documentation

| Document | Status |
|---|---|
| [`FINAL_REPORT.md`](../thesis/FINAL_REPORT.md) | Final thesis report |
| [`TA_ALIGNMENT_PLAN.md`](../thesis/TA_ALIGNMENT_PLAN.md) | Gap 1-3 alignment (all ✅) |
| [`TA_BAB4_ALIGNMENT_PLAN.md`](../thesis/TA_BAB4_ALIGNMENT_PLAN.md) | Chapter 4 alignment |
| [`TA_FINAL_HOSTILE_REVIEW.md`](../thesis/TA_FINAL_HOSTILE_REVIEW.md) | Hostile review from examiner perspective |
| [`TA_FINAL_REVIEW_CONTEXT.md`](../thesis/TA_FINAL_REVIEW_CONTEXT.md) | Final thesis state |

---

## 📊 Questionnaires & UAT

### Dosen (Lecturer)
Located in: `questionnaires/dosen/`
- Kuesioner_Dosen_Kolabri.md/docx
- Kuesioner_Dosen_Kolabri_Compact.md/docx
- Kuesioner_Dosen_Kolabri_SuperCompact.md/docx
- UAT_Dosen_Kolabri.md/docx

### Mahasiswa (Student)
Located in: `questionnaires/mahasiswa/`
- Kuesioner_Mahasiswa_Kolabri.md/docx
- Kuesioner_Mahasiswa_Kolabri_Compact.md/docx
- UAT_Mahasiswa_Kolabri.md/docx

### Generators
Python scripts for generating questionnaire forms:
- `generate_kuesioner_compact.py`
- `generate_kuesioner_docx.py`
- `generate_uat_docx.py`

---

## 🧪 Testing

| Document | Focus |
|---|---|
| [`smoke-tests/`](../testing/smoke-tests/) | Smoke test suites |
| [`test-coverage-wave1-4.md`](../testing/test-coverage-wave1-4.md) | Test coverage across 4 waves |
| [`INTEGRATION_TEST_CHECKPOINT.md`](../testing/INTEGRATION_TEST_CHECKPOINT.md) | 92 integration tests, all passing |
| [`INTEGRATION_VERIFICATION.md`](../testing/INTEGRATION_VERIFICATION.md) | Core API ↔ AI Engine endpoint mapping |

---

## 🔄 Migrations

Migration guides and transition documentation.

| Document | Purpose |
|---|---|
| [`course-weeks-migration-notes.md`](../migrations/course-weeks-migration-notes.md) | Course weeks feature migration |
| [`course-weeks-cross-service-smoke.md`](../migrations/course-weeks-cross-service-smoke.md) | Cross-service smoke tests |
| [`adding-new-role.md`](../migrations/adding-new-role.md) | Adding new user roles |
| [`extending-ux-features.md`](../migrations/extending-ux-features.md) | UX feature extensions |
| [`openspec-workflow.md`](../migrations/openspec-workflow.md) | OpenSpec workflow guide |

---

## 📚 Guides

| Document | Purpose |
|---|---|
| [`DEMO-GUIDE.md`](./DEMO-GUIDE.md) | Demo walkthrough for presentations |
| [`code-review-checklist.md`](./code-review-checklist.md) | Code review standards |
| [`DOCS_INDEX.md`](./DOCS_INDEX.md) | This file |

---

## 📝 Backlog & Planning

Feature backlogs and roadmap planning.

| Document | Focus |
|---|---|
| [`CHAT_ENHANCEMENT_BACKLOG.md`](../backlog/CHAT_ENHANCEMENT_BACKLOG.md) | Chat feature enhancements |
| [`NFR-IMPLEMENTATION-PLAN.md`](../backlog/NFR-IMPLEMENTATION-PLAN.md) | Non-functional requirements |
| [`p0-release-gate.md`](../backlog/p0-release-gate.md) | P0 release criteria |
| [`weekly-readings-discussion-spec.md`](../backlog/weekly-readings-discussion-spec.md) | Weekly readings feature spec |

---

## 🔍 Observations & Issues

Issue tracking and problem resolution.

| Document | Focus |
|---|---|
| [`KOLABRI_OBSERVATIONS_ACTION_ITEMS.md`](../observations/KOLABRI_OBSERVATIONS_ACTION_ITEMS.md) | Action items per service |
| [`KOLABRI_SEVERITY_BASED_OBSERVATIONS.md`](../observations/KOLABRI_SEVERITY_BASED_OBSERVATIONS.md) | Issues by severity |
| [`ai-slop-detection-report.md`](../observations/ai-slop-detection-report.md) | AI code quality review |
| [`GROUP_STUCK_FIX.md`](../observations/GROUP_STUCK_FIX.md) | Group creation bug fix |

---

## 🗂️ Supporting Directories

| Directory | Contents |
|---|---|
| `evidence/` | Test evidence, screenshots, recordings |
| `deployment/` | Deployment configs and guides |
| `debugging/` | Debug logs and troubleshooting notes |
| `superpowers/` | Agent skills and workflow definitions |
| `sample-materials/` | Sample course materials for testing |

---

## Quick Navigation

**Most Important Documents:**
1. Latest audit: [`reports/audits/AUDIT_REPORT_FINAL.md`](../reports/audits/AUDIT_REPORT_FINAL.md)
2. Latest implementation: [`reports/implementation/IMPLEMENTATION_SUMMARY.md`](../reports/implementation/IMPLEMENTATION_SUMMARY.md)
3. Architecture overview: [`reports/inspection/PROJECT_INSPECTION_REPORT.md`](../reports/inspection/PROJECT_INSPECTION_REPORT.md)
4. Demo guide: [`guides/DEMO-GUIDE.md`](./DEMO-GUIDE.md)
5. Final thesis: [`thesis/FINAL_REPORT.md`](../thesis/FINAL_REPORT.md)

**For Development:**
- Architecture decisions: [`architecture/adr/`](../architecture/adr/)
- Scope boundaries: [`architecture/*_SCOPE_BOUNDARIES.md`](../architecture/)
- Testing: [`testing/smoke-tests/`](../testing/smoke-tests/)
- Migration guides: [`migrations/`](../migrations/)

**For Defense:**
- Thesis alignment: [`thesis/TA_ALIGNMENT_PLAN.md`](../thesis/TA_ALIGNMENT_PLAN.md)
- Hostile review: [`thesis/TA_FINAL_HOSTILE_REVIEW.md`](../thesis/TA_FINAL_HOSTILE_REVIEW.md)
- Demo walkthrough: [`guides/DEMO-GUIDE.md`](./DEMO-GUIDE.md)
