## ADDED Requirements

### Requirement: All text MUST meet WCAG AA contrast ratio

All text elements SHALL maintain a minimum contrast ratio of 4.5:1 against their background to meet WCAG AA compliance.

#### Scenario: Gray-400 text replaced with gray-600
- **WHEN** scanning codebase for text-[#9CA3AF], text-[#9ca3af], text-slate-400, text-gray-400
- **THEN** all ~166 instances across ~50 files are replaced with text-gray-600
- **AND** contrast ratio on white background is 4.6:1 (PASSES WCAG AA)

#### Scenario: Zero contrast violations in Lighthouse
- **WHEN** Lighthouse accessibility audit runs on all pages
- **THEN** zero "Background and foreground colors do not have sufficient contrast" warnings
- **AND** accessibility score is not reduced by color issues

#### Scenario: Non-white backgrounds are verified manually
- **WHEN** text appears on colored backgrounds (cards, badges, buttons)
- **THEN** contrast ratio still meets 4.5:1
- **AND** gray-600 is not blindly applied where it would fail

#### Scenario: Visual hierarchy preserved
- **WHEN** secondary text uses gray-600 instead of gray-400
- **THEN** secondary text is still visually distinct from primary body text (gray-900)
- **AND** visual hierarchy is maintained
- **AND** UI does not appear too heavy or dark

#### Scenario: Dark mode not broken
- **WHEN** dark mode is active (if implemented)
- **THEN** text-gray-600 maps to appropriate dark mode color
- **AND** contrast ratios still meet 4.5:1 on dark backgrounds

---

### Requirement: Color changes MUST be systematic

Color contrast fixes SHALL be applied systematically via find-and-replace, not case-by-case.

#### Scenario: All variants of hex color replaced
- **WHEN** applying fix
- **THEN** text-[#9CA3AF] (uppercase) replaced
- **AND** text-[#9ca3af] (lowercase) replaced
- **AND** no instances remain after fix

#### Scenario: Tailwind color classes replaced
- **WHEN** applying fix
- **THEN** text-slate-400 replaced with text-gray-600
- **AND** text-gray-400 replaced with text-gray-600

#### Scenario: Non-text color uses not affected
- **WHEN** applying find & replace
- **THEN** only text- prefixed classes are changed
- **AND** border-gray-400, bg-gray-400, ring-gray-400 are NOT changed
- **AND** those are evaluated separately for contrast needs

---

### Requirement: Contrast MUST be verified after changes

After applying color fixes, all pages SHALL be verified to have zero contrast violations.

#### Scenario: Automated scan passes
- **WHEN** axe-core or Lighthouse scans all pages
- **THEN** zero contrast ratio violations reported
- **AND** all text meets 4.5:1 minimum ratio

#### Scenario: Manual spot check confirms readability
- **WHEN** developer reviews pages with changed colors
- **THEN** all text is clearly readable
- **AND** secondary text is distinguishable from primary text
- **AND** no text appears too dark or heavy
