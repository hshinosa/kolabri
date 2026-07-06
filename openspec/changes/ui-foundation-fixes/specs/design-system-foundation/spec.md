## ADDED Requirements

### Requirement: Centralized font configuration
The system SHALL define all font families in Tailwind configuration file, not in component inline styles.

#### Scenario: Font family is defined in Tailwind config
- **WHEN** developer inspects tailwind.config.js
- **THEN** fontFamily.sans is defined as ['Plus Jakarta Sans', 'system-ui', 'sans-serif']

#### Scenario: Components use Tailwind font utilities
- **WHEN** developer inspects any component file
- **THEN** no inline fontFamily style declarations exist
- **AND** components use className="font-sans" instead

### Requirement: Semantic color system
The system SHALL define semantic color tokens in Tailwind configuration, replacing all hardcoded hex values.

#### Scenario: Brand colors are defined in theme
- **WHEN** developer inspects tailwind.config.js
- **THEN** colors.brand.primary is defined as '#88161c'
- **AND** colors.brand.dark is defined as '#4A4A4A'
- **AND** colors.brand.muted is defined as '#6B7280'
- **AND** colors.brand['muted-dark'] is defined as '#374151'

#### Scenario: Components use semantic color tokens
- **WHEN** developer inspects any component file
- **THEN** no hardcoded hex color values exist in className or style attributes
- **AND** components use semantic tokens like 'text-brand-primary' or 'bg-brand-dark'

### Requirement: Brand-tinted shadow system
The system SHALL define custom shadow utilities with brand color tinting in Tailwind configuration.

#### Scenario: Tinted shadows are defined in theme
- **WHEN** developer inspects tailwind.config.js
- **THEN** boxShadow.brand-sm is defined with rgba(136, 22, 28, 0.05)
- **AND** boxShadow.brand is defined with rgba(136, 22, 28, 0.1)
- **AND** boxShadow.brand-lg is defined with rgba(136, 22, 28, 0.1)

#### Scenario: Components use brand-tinted shadows
- **WHEN** developer inspects card or modal components
- **THEN** components use 'shadow-brand' or 'shadow-brand-lg' instead of generic 'shadow-sm' or 'shadow-lg'

### Requirement: WCAG AA compliant text contrast
The system SHALL use text colors that meet WCAG 2.1 Level AA contrast ratio requirements (4.5:1 for normal text).

#### Scenario: Body text has sufficient contrast
- **WHEN** body text is rendered on white background
- **THEN** text color is #374151 (gray-700) or darker
- **AND** contrast ratio is at least 4.5:1

#### Scenario: Muted text has sufficient contrast
- **WHEN** secondary/muted text is rendered on white background
- **THEN** text color is #374151 (brand-muted-dark) not #6B7280
- **AND** contrast ratio is at least 4.5:1

### Requirement: Dark mode support maintained
The system SHALL maintain existing dark mode functionality when using new theme tokens.

#### Scenario: Dark mode colors work correctly
- **WHEN** user switches to dark mode
- **THEN** all components using theme tokens render correctly
- **AND** no visual regressions occur compared to previous dark mode implementation
