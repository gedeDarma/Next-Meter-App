# Next Meter
Last updated: 2025-12-10

Water token management app built with Flutter. Features local persistence, customer management, transaction history with filters, and WhatsApp sharing.

## Features
- Local persistence using Hive (customers, transactions, settings)
- Auto-refresh UI via ValueListenableBuilder
- Settings: currency symbol, service fee, base amount, pulses per base
- Transactions: form, summary, receipt with token; WhatsApp share; PDF receipt share/print
- History: grouped by date, filters (Today, Last 7 days, Range), detail modal with share
- Home: Summary cards (This Month total and count; Customers count), Recent 5 transactions, Settings button in AppBar
- Backup/Restore: export/import JSON to app documents directory
- Dark/Light theme toggle

## Requirements
- Flutter SDK 3.9.2+
- Android SDK/API 21+
- Dependencies: `hive`, `hive_flutter`, `mobile_scanner`, `url_launcher`, `path_provider`, `pdf`, `printing`

## Setup
```bash
flutter pub get
flutter run
```

## Build Release (Android)
```bash
# optional: split per ABI
flutter build apk --release --split-per-abi
# standard single APK
flutter build apk --release
# run directly on device in release mode
flutter run --release
```
APK output: `build/app/outputs/apk/release/`

## Navigation
- Home → Summary, Quick Actions
- Quick Actions → New Transaction, Transaction History, Customers
- Back buttons on History and Customers return to Home

## Notes
- WhatsApp share uses `url_launcher` (falls back to wa.me if app not installed)
- PDF receipts use `pdf`/`printing` and can be shared from the receipt page
- Backup file path: `getApplicationDocumentsDirectory()/next_meter_backup.json`
- Hive boxes: `customers`, `transactions`, `settings` (adapters in `lib/models`)

## Upcoming Features
- Favorites/tags for customers; bulk import/export (CSV/JSON) with validation
- Advanced history filters, KPIs dashboard, export reports
- Backup/restore with encryption; schema migrations; duplicate detection
- UX: real-time validation, input masks, accessibility, i18n
- Transactions: status lifecycle, drafts, Bluetooth printing, token verification
- Sharing: SMS/email/files; templates per channel/locale; contact integration
- Performance: pagination, indexes/cache, memoized summaries
- Security: app lock (PIN/biometric), redaction, privacy mode
- DevEx: state management (Provider/Riverpod), repository pattern, tests, CI/CD, error reporting
- Integrations: optional cloud sync, notifications, user roles

### Suggested Roadmap
- Phase 1: Settings, improved validators, favorites, share to SMS/email
- Phase 2: Backup/restore with encryption, PDF receipts, audit log, pagination
- Phase 3: State management refactor, tests, CI, analytics dashboard
- Phase 4: Cloud sync, roles, notifications, Bluetooth printing

## License
Provided as-is for educational and commercial use.
