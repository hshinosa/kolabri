## Why

Wave 1-4 telah mengimplementasikan ~575 tasks across 17 OpenSpec changes. Perlu dilakukan verifikasi komprehensif untuk memastikan semua implementasi benar, tidak ada regression, dan siap untuk production.

## What Changes

Verifikasi mencakup:
- **Lint & Type Check**: Pastikan tidak ada TypeScript/PHP errors
- **Build Verification**: Pastikan frontend dan backend bisa build tanpa error
- **Functional Testing**: Test semua fitur yang diimplementasi via Playwright
- **API Testing**: Test semua endpoint baru via cURL/Postman
- **Integration Testing**: Pastikan tidak ada yang broken setelah perubahan

## Capabilities

### New Capabilities
- `verification-lint`: Lint dan type check semua file yang diubah
- `verification-build`: Build verification untuk frontend dan backend
- `verification-functional`: Functional testing via Playwright
- `verification-api`: API endpoint testing
- `verification-integration`: Integration testing

### Modified Capabilities
_(Tidak ada existing specs yang perlu dimodifikasi)_

## Impact

- **Frontend**: Semua halaman student dan lecturer
- **Backend**: Semua controller, models, migrations, routes
- **Core API**: Socket handlers, validators
- **Database**: Migrations baru
